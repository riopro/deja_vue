require 'deja_vue/has_deja_vue'
require 'deja_vue/history'

# Based on PaperTrail (http://github.com/airblade/paper_trail/).
# Using:
# Add an initializer at config/initializers and require 'deja_vue'
# Add to your model:
# has_deja_vue
# You might pass some options, including:
# :ignore                 | An Array of fields that will be ignored. If
#                         | only those fields have changed, then no version
#                         | will be created.
#                         | has_deja_vue :ignore => :last_exported_on
# :associations           | Store associated models to be record with the model
#                         | so it can be fully restored. Right now it works only
#                         | with has_one / belongs_to relationships.
#                         | Ex.:
#                         | class Account < ActiveRecord::Base
#                         |   has_one :account_preference
#                         |
#                         |   has_deja_vue :associations => [:account_preference]
#                         | end
#                         |
# :extra_info_fields      | Almost the same as the above option. But it handles
#                         | more simple info (like strings, integers, floats).
#                         | Useful to store a tag_list field or a counter cache
#                         | Ex:
#                         |
#                         | class BlogPost < ActiveRecord::Base
#                         |   acts_as_taggable_on :tags
#                         |
#                         |   has_deja_vue :extra_info_fields => [:tag_list]
#                         | end
#                         |
# :who_did_it             | a default value for record who_did_it when you
#                         | are not in a request-response cycle (ex. in a job).
#                         | Ex.:
#                         | has_deja_vue :who_did_it => 'admin'
#                         | Alternatively you are able to set the user right
#                         | before save the model that will be versionated, using:
#                         | DejaVue.who_did_it = 'otavio'
#                         | SomeModel.save
#
# There are 3 kinds of versioning: create, update, destroy
# Differently from PaperTrail, each version will record the current model info.
# So PapelTrail _create_ versions have reify == nil
# DejaVue have _create_ version == model_version_when_creating
module DejaVue

  def self.included(base)
    base.before_filter :set_deja_vue_user
  end

  def self.who_did_it
    Thread.current[:who_did_it]
  end

  def self.who_did_it=(value)
    Thread.current[:who_did_it] = value
  end

  # Used to set an user to be versionated, execute the block and
  # then rollback to the thread's regular user.
  # Example:
  #
  # @blog_post = BlogPost.find 10
  # @blog_post.title = "new title"
  # DejaVue.setting_user_as('someone') do
  #   @blog_post.save
  # end
  def self.setting_user_as(value, &block)
    actual_user = Thread.current[:who_did_it]
    Thread.current[:who_did_it] = value
    yield if block_given?
    Thread.current[:who_did_it] = actual_user
  end

  protected

    # Returns the user who is responsible for any changes that occur.
    # By default this calls `current_user` and returns the result.
    #
    # Override this method in your controller to call a different
    # method, e.g. `current_person`, or anything you like.
    def user_for_deja_vue
			begin
				current_user if current_user && current_user.is_a?(String)
				current_user[:id] if current_user && current_user[:id]
			rescue
				nil
			end
    end

  private

    # Verifies if current controller responds to current_user method
    def set_deja_vue_user
      Thread.current[:who_did_it] = user_for_deja_vue
    end
end

ActionController::Base.send :include, DejaVue
