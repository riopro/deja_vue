ActiveRecord::Schema.define :version => 0 do
  create_table "suppliers", :force => true do |t|
    t.string  "name"
  end

  create_table "products", :force => true do |t|
    t.string "title",
    t.string "description",
    t.integer "supplier_id",
  end
  
end
