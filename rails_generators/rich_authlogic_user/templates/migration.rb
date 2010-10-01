class <%= migration_class_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
      t.string   :name
      t.string   :email
      t.string   :crypted_password
      t.string   :password_salt
      t.datetime :created_at
      t.string   :persistence_token  , :default => "", :null => false
      t.string   :single_access_token, :default => "", :null => false
      t.string   :perishable_token   , :default => "", :null => false
      t.integer  :login_count
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.timestamps
    end
    
    add_index :<%= table_name %>, :email
  end

  def self.down
    drop_table :<%= table_name %>
  end
end