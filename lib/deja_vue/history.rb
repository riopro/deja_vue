class History
  include MongoMapper::Document

  key :versionable_type,    String,  :required => true, :index => true
  key :versionable_id,      String,  :required => true, :index => true
  key :kind_of_version,     String,  :required => true
  key :version_attributes,  Hash,   :required => true
  key :version_associations,Hash,   :index => true
  key :extra_info,          Hash  # para armazenar informações relacionadas, como tag_list
  key :changed_fields,      Array
  key :who_did_it,          String
  timestamps!
  ensure_index :created_at


  #
  # Validations
  #
  validates_true_for :version_attributes, :logic => lambda { !version_attributes.empty? }

  #
  # Constants
  #

  DEFAULT_IGNORED_FIELDS = ["updated_at", "created_at"]

  KIND_OF_VERSIONS = %w( create update destroy )
  
  #
  # Class Methods
  #

  def self.versionate(object, kind_of_version, options={})
    return false if object.blank?
    History.new.create_version(object, kind_of_version, options)
  end

  # marreta para teste rodar, por causa do i18n do remarkable, FIXME
  def self.human_name(foo)
    "History"
  end

  #
  # Instance Methods
  #

  def create_version(object, kind_of_version, options={})
    self.ignored_fields= options[:ignore] if options[:ignore]
    self.who_did_it = check_and_retrieve_user(options[:who_did_it]) if options[:who_did_it]
    self.kind_of_version  = kind_of_version
    self.versionable_type = object.class.name
    self.versionable_id   = object.id.to_s

    unless self.kind_of_version == "destroy"
      return false unless self.has_changed?(object)
    end
    self.version_attributes = attributes_filter(object.attributes)
    store_version_associations object, options
    store_extra_info(object, options)
    self.save
  end

  # Rebuild the versionated object.
  # Do not rebuild if it's not saved
  def version
    return nil if self.new_record?
    @version ||= recreate_version_object
  end

  # fields that whose change won't cause a history trace
  def ignored_fields
    @ignored_fields || DEFAULT_IGNORED_FIELDS
  end

  def ignored_fields=(fields_array)
    fields = nil
    fields = fields_array if fields_array.is_a?(Array)
    fields = [fields_array.to_s] if ( fields_array.is_a?(String) || fields_array.is_a?(Symbol) )
    return false unless fields.is_a?(Array)
    @ignored_fields = ( DEFAULT_IGNORED_FIELDS  + fields ).uniq
  end

  # return true id object has changed
  def has_changed?(object)
    return false unless object.try(:version_changes)    
    !store_changed_fields(object).empty?
  end

  def next_version
    History.where(:created_at.gte => self.created_at,  # could have the same creation date, as long it's not the same object
                      :id.ne => self.id.to_s,         # ne => not equal to
                      :versionable_type => self.versionable_type,
                      :versionable_id => self.versionable_id).sort(:created_at.asc).first
  end

  def previous_version
    History.where(:created_at.lte => self.created_at,  # could have the same creation date, as long it's not the same object
                      :id.ne => self.id.to_s,         # ne => not equal to
                      :versionable_type => self.versionable_type,
                      :versionable_id => self.versionable_id).sort(:created_at.desc).first
  end

  protected

    # Retrieve the versionated object
    def recreate_version_object
      model = recreate_model(self.versionable_type, self.version_attributes)
      model.id = self.versionable_id

      self.version_associations.each do |associated_object, associated_object_attributes|
        model.try "#{associated_object.to_s}=", recreate_model(associated_object, associated_object_attributes)
      end
      update_fields model, self.extra_info
      model
    end

    # recreates object from a class name and its attributes
    def recreate_model(class_name, attributes_hash={})
      associated_klass = class_name.to_s.camelize.constantize.new
      update_fields associated_klass, attributes_hash
      associated_klass
    end

    # updates values for an instantiated class
    def update_fields(class_object, attributes_hash={})
      attributes_hash.each do |key, value|
        class_object.send "#{key.to_s}=", value
      end
    end

    # If user is a Class, try to retrieve user
    # from an Authlogic User Session.
    # If it is an Authlogic object, return the user id.
    #
    # Else it returns the current object.
    def check_and_retrieve_user(user)
      if user.is_a? Class
        begin
          user.find.user.id
        rescue
          nil
        end
      else
        user
      end
    end

    def store_version_associations(object, options)
      self.version_associations = {}
      options[:associations].each do |association|
        self.version_associations.store(association, attributes_filter( object.try(association).attributes) ) if object.try(association)
      end if options[:associations]
      true
    end

    def store_changed_fields(object)
      self.changed_fields = object.version_changes - self.ignored_fields if self.ignored_fields.is_a?(Array)
      self.changed_fields
    end

    def store_extra_info(object, options)
      self.extra_info = {}
      options[:extra_info_fields].each do |extra_info|
        self.extra_info.store( extra_info, object.try(extra_info) ) if object.try(extra_info)
      end if options[:extra_info_fields]
      self.extra_info = attributes_filter(self.extra_info)
      true
    end

    def attributes_filter(key_value={})
      key_value.each do |k,v|
        key_value[k]=v.to_s if key_value[k].is_a?(Date)
      end
      key_value.each do |k,v|
        key_value[k]=v.utc.to_s if key_value[k].is_a?(Time)
      end
      key_value.each do |k,v|
        key_value[k]=v.to_f if key_value[k].is_a?(BigDecimal)
      end

      key_value
    end

end
