Rich::Cms::Engine.authenticate(:authlogic, {:class_name => "User", :identifier => :email})
Rich::Cms::Engine.register(".cms_content", {:class_name => "CmsContent"})