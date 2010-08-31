ActiveRecord::Schema.define :version => 0 do
  create_table "suppliers", :force => true do |t|
    t.string  "name"
  end

  create_table "products", :force => true do |t|
    t.string "title"
    t.string "description"
    t.integer "supplier_id"
  end
  
  create_table 'my_tests', :force => true do |t|
    t.string 'name'
    t.integer 'my_test_association_id'
  end

  create_table 'my_test_associations', :force => true do |t|
    t.string 'name'
  end

end
