class Product < ActiveRecord::Base
  has_deja_vue :associations => [:supplier]

  belongs_to :supplier
end

class Supplier < ActiveRecord::Base
  has_many :products
end


# A mock class simulating an ActiveRecord class that is going to be versionated
class MyTest < ActiveRecord::Base
  
  belongs_to :my_test_association

  def version_changes
    # mocked method that simply returns that name field has changed
    [:name]
  end

  attr_accessible :tag_list

end

class MyTestAssociation < ActiveRecord::Base

end
