class Product < ActiveRecord::Base
  has_deja_vue :associations => [:supplier]

  belongs_to :supplier
end

class Supplier < ActiveRecord::Base
  has_many :products
end

