
module Rich
  module Cms
    module Helper
    
    	def rich_cms
    	  render :file => File.join(File.dirname(__FILE__), "..", "..", "..", "app", "views", "rich_cms.html.erb") if session[:rich_cms].try(:fetch, :display, nil)
    	end
  	
    	def link(name, options = nil)
    	  options = {:class => options || name.underscore} unless options.is_a?(Hash)
    	  link_to name, "#", options
    	end
  	
    end
  end
end
