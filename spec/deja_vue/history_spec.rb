require 'spec_helper'

describe History do
  before(:each) do
    History.delete_all # FIXME: it has no fixtures, so we need to delete manually
    Account.destroy_all
    User.destroy_all

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
                    :ignore => [:city, :country],
                    :associations => [:account],
                    :extra_info_fields => [:tag_list]
                  }
        account = Account.create(:name => 'teste')
        @user = User.new :login => "me_myself", :account => account
        @user.tag_list = "obla, di, tags"
      end
      it "should return false if there is no object to versionate" do
        History.versionate(nil, 'update', @options).should be_false
        History.versionate(nil, 'destroy', @options).should be_false
        History.versionate(nil, 'create', @options).should be_false
      end
      it "should call create_version" do
        History.stub(:new).and_return(@history)
        @history.should_receive(:create_version).and_return(true)
        History.versionate(@user, 'update', @options).should be_true
      end
    end
  end

  describe "instance methods" do
    before(:each) do
      @options = {
                  :ignore => [],
                  :associations => [:account],
                  :extra_info_fields => [:tag_list]
                }
      account = Account.create(:name => 'teste')
      @user = User.new :login => "me_myself", :account => account
      @user.tag_list = "obla, di, tags"
    end
    describe "create_version(object, kind_of_version, options={})" do
      it "should record object attributes" do
        @history.create_version(@user, 'update', @options)
        @history.version_attributes.is_a?(Hash).should be_true
        @history.version_attributes.sort.should == @user.attributes.sort
      end
      it "should record object association account" do
        @history.create_version(@user, 'update', @options)
        @history.version_associations.should == { 'account' => @user.account.attributes }
      end
      it "should record extra info" do
        @history.create_version(@user, 'update', @options)
        @history.extra_info.should == { 'tag_list' => @user.tag_list }
      end
      it "should store kind of version correctly" do
        @history.create_version(@user, 'destroy', @options)
        @history.kind_of_version.should == 'destroy'

        @history.create_version(@user, 'update', @options)
        @history.kind_of_version.should == 'update'

        @history.create_version(@user, 'create', @options)
        @history.kind_of_version.should == 'create'
      end
      it "should store changed_fields" do
        @history.create_version(@user, 'update', @options)
        @history.changed_fields.should == [:login]
      end
      it "should not store changed_fields on destroy" do
        @history.create_version(@user, 'destroy', @options)
        @history.changed_fields.should == []
      end
      describe "who_did_it" do
        it "should store whodidit if option exists" do
          @history.create_version(@user, 'destroy', @options.merge(:who_did_it => 'otavio'))
          @history.who_did_it.should == 'otavio'
        end
        it "should store a number or a string" do
          @history.create_version(@user, 'create', @options.merge(:who_did_it => 'otavio'))
          @history.who_did_it.should == 'otavio'
          @history.create_version(@user, 'update', @options.merge(:who_did_it => 1112))
          @history.who_did_it.should == "1112"
        end
        it "should look for an Authlogic session model to retrieve user id if it is a class" do
          @history.create_version(@user, 'update', @options.merge(:who_did_it => FakeAuthLogicSession))
          @history.who_did_it.should == "10"
        end
        it "should not throw an error if Authlogic session model cannot be activated or is not a Authlogic session class" do
          @history.create_version(@user, 'update', @options.merge(:who_did_it => FakeUser))
          @history.who_did_it.should be_nil
        end
      end
      it "should not save if all changed fields are ignored ones" do
        @history.create_version(@user, 'update', @options.merge(:ignore => [:login]))
        @history.should be_new_record
        @history.create_version(@user, 'create', @options.merge(:ignore => [:login]))
        @history.should be_new_record
      end
      it "should ask for a version_changes method in the object to be versionated" do
        @user.should_receive(:version_changes).twice.and_return([:login])
        @history.create_version(@user, 'update', @options)
      end
    end

    describe "has_changed?(object)" do
      it "should verify if object has a version_changes method" do
        @user.should_receive(:version_changes).twice.and_return([])
        @history.has_changed?(@user).should be_false
      end
      it "should receive store_changed_fields and verify if it is empty" do
        @history.should_receive(:store_changed_fields).and_return([])
        @history.has_changed?(@user).should be_false
      end
      it "should return true if it has changed_fields" do
        @history.should_receive(:store_changed_fields).and_return([:login])
        @history.has_changed?(@user).should be_true
      end
      it "should set changed_fields with object's changed fields" do
        @user.should_receive(:version_changes).twice.and_return([:arroba])
        @history.changed_fields.should be_empty
        @history.has_changed?(@user).should be_true
        @history.changed_fields=[:arroba]
      end
    end

    describe "ignored_fields" do
      it "should have default ignored fields" do
        @history.ignored_fields.should == History::DEFAULT_IGNORED_FIELDS
      end
      it "should add ignored fields to the default ones" do
        @history.ignored_fields=[:login]
        @history.ignored_fields.should == History::DEFAULT_IGNORED_FIELDS + [:login]
        @history.ignored_fields.should_not == [:login]
      end
    end

    describe "version" do
      before(:each) do
        @user.save
      end
      it "should not have user as a new record" do
        @user.should_not be_new_record
      end
      it "should return nil for non saved records" do
        @history.version.should be_nil
      end
      it "should recreate object versionated" do
        @history.create_version(@user, 'create', @options).should be_true
        @history = History.first :order => "created_at desc"
        @history.version.class.is_a?(User)
        @history.version.login.should == @user.login
      end
      it "should recreate object associations" do
	@history.create_version(@user, 'create', @options).should be_true
        @history = History.first :order => "created_at desc"
        @history.version.account.is_a?(Account).should be_true
        @history.version.account.should == Account.first
      end
      it "should restore extra info" do
        @history.create_version(@user, 'create', @options).should be_true
        @history = History.first :order => "created_at desc"
        @history.version.tag_list.should == @user.tag_list
      end
    end

    describe "next_version" do
      it "should return next version by creation date" do
	@user.stub(:version_changes).and_return([:login])
        @user.save
        @history.create_version(@user, 'create', @options)
        @user.login = "it's another one"
        @new_history = History.new
        @new_history.create_version(@user, 'update', @options)
        History.count.should == 2
        @history.next_version.should_not be_nil
        @history.next_version.id.to_s.should_not == @history.id.to_s
        @history.next_version.id.to_s.should == @new_history.id.to_s
      end
    end

    describe "previous version" do
      it "should return previous version by creation date" do
	@user.stub(:version_changes).and_return([:login])
        @user.save
        @history.create_version(@user, 'create', @options)
        @user.login = "it's another one"
        @new_history = History.new
        @new_history.create_version(@user, 'update', @options)
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
    u = User.new
    u.id = 10
    u
  end
end

class FakeUser < Struct.new(:id)
  def initialize
    self.id = 10
  end
end

