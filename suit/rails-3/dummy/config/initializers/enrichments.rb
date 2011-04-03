Rich::Cms::Auth.setup do |config|
  config.logic = :devise
  config.klass = "DeviseUser"
end

require File.expand_path("test/suit_application/rich/i18n_forgery", Rails.root)