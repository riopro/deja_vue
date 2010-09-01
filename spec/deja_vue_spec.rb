require 'spec_helper'

class TestsController < ActionController::Base
  def test_set_deja_vue_user
		set_deja_vue_user
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
	end
end

