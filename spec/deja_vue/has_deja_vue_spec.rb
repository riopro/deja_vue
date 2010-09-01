require 'spec_helper'


describe DejaVue::ClassMethods do
	
end

describe DejaVue::InstanceMethods do
  before(:each) do
    clear_dbs
	end
	describe "version_changes" do
		before(:each) do
			@supplier = Supplier.new(:name => 'a supplier')
			@product = Product.new(:title => 'The Product', :description => 'The Product is the new kid on the block', :dimensions => '12x12')
		end
		it "should keep track changed fields" do
			@supplier.version_changes.should == [:name]
		end
		it "should ignore fields setted to be ignored" do
		end
		it "should be empty if object has no changes" do
		end
	end
end
