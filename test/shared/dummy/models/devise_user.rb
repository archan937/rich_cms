class DeviseUser < ::ActiveRecord::Base
  devise :database_authenticatable
end