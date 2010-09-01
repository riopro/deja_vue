require 'spec_helper'

class TestsController < ActionController::Base
  def test_set_deja_vue_user
		set_deja_vue_user
  end

	def test_user_for_deja_vue
		user_for_deja_vue
  end

  def current_user
		@the_user
  end

  def current_user=(user)
		@the_user = user
  end
end

describe TestsController do
	before(:each) do
		User.destroy_all
		@user = User.create(:login => 'mylogin', :country => 'Brazil')
		@tests_controller = TestsController.new
	end
	describe "user_for_deja_vue" do
		it "should return current user id" do
			@tests_controller.current_user= @user
			@tests_controller.test_user_for_deja_vue.should == @user.id
		end	
		it "should return nil if has no current user" do
			@tests_controller.current_user= nil
			@tests_controller.test_user_for_deja_vue.should == nil
		end	
	end
  describe "set_deja_vue_user" do
		it "should try to set deja vue user from current user" do
			@tests_controller.current_user= @user
			@tests_controller.test_set_deja_vue_user.should == @user.id
		end
		it "should set thread who_did_it" do
			@tests_controller.current_user= @user
			@tests_controller.test_set_deja_vue_user.should == @user.id
			Thread.current[:who_did_it].should == @user.id
		end
		it "should set who_did_it as nil if has no current_user" do
			@tests_controller.current_user= nil
			@tests_controller.test_set_deja_vue_user.should == nil
			Thread.current[:who_did_it].should == nil
		end
	end
end

