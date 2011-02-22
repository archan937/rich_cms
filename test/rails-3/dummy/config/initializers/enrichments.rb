Rich::Cms::Auth.setup do |config|
  config.logic = :devise
  config.klass = "DeviseUser"
end