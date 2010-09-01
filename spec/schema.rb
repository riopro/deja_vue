ActiveRecord::Schema.define :version => 0 do
  create_table "suppliers", :force => true do |t|
    t.string  "name"
  end

  create_table "products", :force => true do |t|
    t.string "title"
    t.string "description"
    t.integer "supplier_id"
    t.string "dimensions"
  end
  
  create_table 'users', :force => true do |t|
    t.string 'login'
    t.integer 'account_id'
    t.string 'website'
    t.string 'city'
    t.string 'country'
    t.string 'about'
  end

  create_table 'accounts', :force => true do |t|
    t.string 'name'
  end

end
