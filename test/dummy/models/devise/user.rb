class Devise::User < ActiveRecord::Base
  set_table_name :devise_users
  # devise :database_authenticatable
end