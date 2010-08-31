require 'spec_helper'

describe History do
  before(:each) do
    History.delete_all # FIXME: it has no fixtures, so we need to delete manually
    @valid_attributes = {
      :versionable_type => 'Test',
      :versionable_id => 1,
      :version_attributes => { :one => 'attribute', :user_id => 2 },
      :version_associations => { :who_did_it => { :id => 2, :login => 'john' } },
      :extra_info => {},
      :changed_fields => [:one],
      :kind_of_version => 'update',
      :who_did_it => 2
    }
    @history = History.new
  end

  it "should create a new instance given valid attributes" do
    History.create!(@valid_attributes)
  end

  describe "validation" do
    [:versionable_type, :versionable_id, :kind_of_version, :version_attributes].each do |key|
      it "should require a #{key}" do
        @history.send("#{key}=", nil)
        @history.should_not be_valid
        @history.errors.on(key).should_not be_nil
      end
    end
  end

  describe "class methods" do
    describe "self.versionate(object, kind_of_version, options={})" do
      before(:each) do
        @options = {
                    :ignore => [:depreciated_value, :last_exported_on, :locked_by_job],
                    :associations => [:my_test_association],
                    :extra_info_fields => [:tag_list]
                  }
        @my_test = MyTest.new 1, "obladi oblada", 2
        @my_test.tag_list = "obla, di, tags"
        @my_test.my_test_association= MyTestAssociation.new(2, 'teste')
      end
      it "should return false if there is no object to versionate" do
        History.versionate(nil, 'update', @options).should be_false
        History.versionate(nil, 'destroy', @options).should be_false
        History.versionate(nil, 'create', @options).should be_false
      end
      it "should call create_version" do
        History.stub(:new).and_return(@history)
        @history.should_receive(:create_version).and_return(true)
        History.versionate(@my_test, 'update', @options).should be_true
      end
    end
  end

  describe "instance methods" do
    before(:each) do
      @options = {
                  :ignore => [],
                  :associations => [:my_test_association],
                  :extra_info_fields => [:tag_list]
                }
      @my_test = MyTest.new 1, "obladi oblada", 2
      @my_test.tag_list = "obla, di, tags"
      @my_test.my_test_association= MyTestAssociation.new(2, 'teste')
    end
    describe "create_version(object, kind_of_version, options={})" do
      it "should record object attributes" do
        @history.create_version(@my_test, 'update', @options)
        @history.version_attributes.is_a?(Hash).should be_true
        @history.version_attributes.sort.should == @my_test.attributes.sort
      end
      it "should record object association my_test_association" do
        @history.create_version(@my_test, 'update', @options)
        @history.version_associations.should == { 'my_test_association' => @my_test.my_test_association.attributes }
      end
      it "should record extra info" do
        @history.create_version(@my_test, 'update', @options)
        @history.extra_info.should == { 'tag_list' => @my_test.tag_list }
      end
      it "should store kind of version correctly" do
        @history.create_version(@my_test, 'destroy', @options)
        @history.kind_of_version.should == 'destroy'

        @history.create_version(@my_test, 'update', @options)
        @history.kind_of_version.should == 'update'

        @history.create_version(@my_test, 'create', @options)
        @history.kind_of_version.should == 'create'
      end
      it "should store changed_fields" do
        @history.create_version(@my_test, 'update', @options)
        @history.changed_fields.should == [:name]
      end
      it "should not store changed_fields on destroy" do
        @history.create_version(@my_test, 'destroy', @options)
        @history.changed_fields.should == []
      end
      describe "who_did_it" do
        it "should store whodidit if option exists" do
          @history.create_version(@my_test, 'destroy', @options.merge(:who_did_it => 'otavio'))
          @history.who_did_it.should == 'otavio'
        end
        it "should store a number or a string" do
          @history.create_version(@my_test, 'create', @options.merge(:who_did_it => 'otavio'))
          @history.who_did_it.should == 'otavio'
          @history.create_version(@my_test, 'update', @options.merge(:who_did_it => 1112))
          @history.who_did_it.should == "1112"
        end
        it "should look for an Authlogic session model to retrieve user id if it is a class" do
          @history.create_version(@my_test, 'update', @options.merge(:who_did_it => FakeAuthLogicSession))
          @history.who_did_it.should == "10"
        end
        it "should not throw an error if Authlogic session model cannot be activated or is not a Authlogic session class" do
          @history.create_version(@my_test, 'update', @options.merge(:who_did_it => FakeUser))
          @history.who_did_it.should be_nil
        end
      end
      it "should not save if all changed fields are ignored ones" do
        @history.create_version(@my_test, 'update', @options.merge(:ignore => [:name]))
        @history.should be_new_record
        @history.create_version(@my_test, 'create', @options.merge(:ignore => [:name]))
        @history.should be_new_record
      end
      it "should ask for a version_changes method in the object to be versionated" do
        @my_test.should_receive(:version_changes).twice.and_return([:name])
        @history.create_version(@my_test, 'update', @options)
      end
    end

    describe "has_changed?(object)" do
      it "should verify if object has a version_changes method" do
        @my_test.should_receive(:version_changes).twice.and_return([])
        @history.has_changed?(@my_test).should be_false
      end
      it "should receive store_changed_fields and verify if it is empty" do
        @history.should_receive(:store_changed_fields).and_return([])
        @history.has_changed?(@my_test).should be_false
      end
      it "should return true if it has changed_fields" do
        @history.should_receive(:store_changed_fields).and_return([:name])
        @history.has_changed?(@my_test).should be_true
      end
      it "should set changed_fields with object's changed fields" do
        @my_test.should_receive(:version_changes).twice.and_return([:arroba])
        @history.changed_fields.should be_empty
        @history.has_changed?(@my_test).should be_true
        @history.changed_fields=[:arroba]
      end
    end

    describe "ignored_fields" do
      it "should have default ignored fields" do
        @history.ignored_fields.should == History::DEFAULT_IGNORED_FIELDS
      end
      it "should add ignored fields to the default ones" do
        @history.ignored_fields=[:name]
        @history.ignored_fields.should == History::DEFAULT_IGNORED_FIELDS + [:name]
        @history.ignored_fields.should_not == [:name]
      end
    end

    describe "version" do
      it "should return nil for non saved records" do
        @history.version.should be_nil
      end
      it "should recreate object versionated" do
        @history.create_version(@my_test, 'create', @options)
        @history = History.first :order => "created_at desc"
        @history.version.class.is_a?(MyTest)
        @history.version.name.should == @my_test.name
      end
      it "should recreate object associations" do
        @history.create_version(@my_test, 'create', @options)
        @history = History.first :order => "created_at desc"
        @history.version.my_test_association.is_a?(MyTestAssociation)
        @history.version.my_test_association.should == MyTestAssociation.new(2, 'teste')
      end
      it "should restore extra info" do
        @history.create_version(@my_test, 'create', @options)
        @history = History.first :order => "created_at desc"
        @history.version.tag_list.should == @my_test.tag_list
      end
    end

    describe "next_version" do
      it "should return next version by creation date" do
        @history.create_version(@my_test, 'create', @options)
        @my_test.name = "it's another one"
        @new_history = History.new
        @new_history.create_version(@my_test, 'update', @options)
        History.count.should == 2
        @history.next_version.should_not be_nil
        @history.next_version.id.to_s.should_not == @history.id.to_s
        @history.next_version.id.to_s.should == @new_history.id.to_s
      end
    end

    describe "previous version" do
      it "should return previous version by creation date" do
        @history.create_version(@my_test, 'create', @options)
        @my_test.name = "it's another one"
        @new_history = History.new
        @new_history.create_version(@my_test, 'update', @options)
        History.all.size.should == 2
        @new_history.previous_version.should_not be_nil
        @new_history.previous_version.id.to_s.should_not == @new_history.id.to_s
        @new_history.previous_version.id.to_s.should == @history.id.to_s
      end
    end
  end
end

# Fake Authlogic behavior. Search in a session (FakeAuthLogicSession instance) for an user (FakeUser)
class FakeAuthLogicSession
  def self.find
    FakeAuthLogicSession.new
  end

  def user
    FakeUser.new
  end
end

class FakeUser < Struct.new(:id)
  def initialize
    self.id = 10
  end
end
