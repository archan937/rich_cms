
module ActionView
  class Base
    
  	def rich_cms
  	  render :file => File.join(File.dirname(__FILE__), "..", "..", "..", "..", "app", "views", "rich_cms.html.erb") if display_rich_cms?
  	end
  	
    def display_rich_cms?;       !!session[:rich_cms].try(:fetch, :display      , nil)                                ; end
    def display_rich_cms_menu?;  !!session[:rich_cms].try(:fetch, :display_menu , nil)                                ; end
    def display_rich_cms_panel?; !!session[:rich_cms].try(:fetch, :display_panel, nil) and current_rich_cms_admin.nil?; end
  	
  	def link(name, options = nil)
  	  options = {:class => options || name.underscore} unless options.is_a?(Hash)
  	  link_to name, "#", options
  	end
  	
  	def rich_cms_tag(selector, key)
  	  Rich::Cms::Engine.to_content_tag selector, key
  	end

  end
end
