module DejaVue

  def self.included(base)
    base.send :extend, ClassMethods
  end


  module ClassMethods
    # Options:
    # :ignore    an array of attributes for which a new +Version+ will not be created if only they change.
    def has_deja_vue(options = {})
      send :include, InstanceMethods

      cattr_accessor :deja_vue_options
      options[:ignore] = options[:ignore].map &:to_s if options[:ignore]
      self.deja_vue_options = options

      cattr_accessor :deja_vue_active
      self.deja_vue_active = true

      before_save :check_for_version_changes
      after_update :record_update_version
      after_create :record_create_version
      after_destroy :record_destroy_version

    end

		# FIXME: not implemented yet
    def deja_vue_off
      self.deja_vue_active = false
    end

		# FIXME: not implemented yet
    def deja_vue_on
      self.deja_vue_active = true
    end
  end

  module InstanceMethods

    # return array with changed fields after object has been saved
		# (created or updated). 
		# Whe need this to validate if the changes must be recorded after save
    def version_changes
      @version_changes
    end

    # Search for all change history from the current object
    def histories(extra_options={})
      default_options = {:versionable_type => self.class.to_s, :versionable_id => self.id.to_s}
      History.where(extra_options.merge(default_options)).sort(:created_at.desc).all
    end

    # Search for a change history from the current object by id
    def history(param_id)
      History.where(:versionable_type => self.class.to_s, :versionable_id => self.id.to_s, :id => param_id).first
    end

    private

      def check_for_version_changes
        @version_changes = self.changed
      end

      def versionate_as(kind_of_version)
        History.versionate(self, kind_of_version, deja_vue_options.merge(:who_did_it => DejaVue.who_did_it)) if DejaVue.who_did_it
        History.versionate(self, kind_of_version, deja_vue_options) unless DejaVue.who_did_it
      end

      def record_update_version
        versionate_as("update")
      end

      def record_create_version
        versionate_as("create")
      end

      def record_destroy_version
        versionate_as("destroy")
      end
  end

end

ActiveRecord::Base.send :include, DejaVue
