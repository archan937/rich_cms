class <%= model_class_name %> < ActiveRecord::Base

  acts_as_authentic do |c|
    c.login_field            = :email
    c.crypted_password_field = :crypted_password
  end

  def to_key
    new_record? ? nil : [self.send self.class.primary_key]
  end

end