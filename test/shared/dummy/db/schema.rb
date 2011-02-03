ActiveRecord::Schema.define do

  create_table "authlogic_users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.datetime "last_request_at"
  end

  add_index "authlogic_users", ["email"], :name => "index_authlogic_users_on_email"

  create_table "devise_users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.integer  "sign_in_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip"
    t.datetime "last_sign_in_at"
    t.string   "last_sign_in_ip"
  end

  add_index "devise_users", ["email"], :name => "index_devise_users_on_email", :unique => true

  create_table "cms_contents", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cms_contents", ["key"], :name => "index_cms_contents_on_key"

end