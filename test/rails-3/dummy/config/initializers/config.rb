Rich::Cms::Auth.setup do |config|
  config.logic = :devise
  config.klass = "DeviseUser"
end
Rich::Cms::Engine.register(".cms_content", {:class_name => "CmsContent"})