class Auth::Authlogic::User < ActiveRecord::Base
  set_table_name :auth_authlogic_users

  acts_as_authentic do |c|
    c.login_field            = :email
    c.crypted_password_field = :crypted_password
  end

end