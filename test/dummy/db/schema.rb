ActiveRecord::Schema.define do

  create_table "cms_contents", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_contents", ["key"], :name => "index_cms_contents_on_key"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.string   "persistence_token"  , :default => "", :null => false
    t.string   "single_access_token", :default => "", :null => false
    t.string   "perishable_token"   , :default => "", :null => false
    t.integer  "login_count"
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"

end