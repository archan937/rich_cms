Rich::Cms::Auth.setup do |config|
  config.logic = :devise
  config.klass = "AuthDeviseUser"
end
Rich::Cms::Engine.register(".cms_content", {:class_name => "CmsContent"})