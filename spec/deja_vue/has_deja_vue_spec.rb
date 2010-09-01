require 'spec_helper'

describe DejaVue::InstanceMethods do
  before(:each) do
    clear_dbs
	  @supplier = Supplier.new(:name => 'a supplier')
		@product = Product.new(:title => 'The Product', :description => 'The Product is the new kid on the block', :dimensions => '12x12')
	end
	describe "version_changes" do
		describe "after save" do
			before(:each) do
				@supplier.save
				@product.save
			end
			it "should keep track changed fields" do
				@product.version_changes.should == ["dimensions", "title", "description"]
				@supplier.version_changes.should == ['name']
			end
			it "should keep track on update to" do	
				@product.title = "TTT Prod"
				@product.save!
				@product.version_changes.should == ["title"]
			end
		end
		describe "before save" do
			it "should be nil" do
				@product.version_changes.should be_nil
				@supplier.version_changes.should be_nil
			end
		end
	end
	describe "histories(extra_options={})" do
		it "should return an empty array for new record" do
			@product.should be_new_record
			@product.histories.should be_empty
			@supplier.should be_new_record
			@supplier.histories.should be_empty
		end
	end
end
