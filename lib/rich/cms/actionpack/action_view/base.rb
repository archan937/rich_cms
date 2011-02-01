module ActionView
  class Base

    def rich_cms
      render :file => File.expand_path("../../../../../../app/views/rich_cms.html.erb", __FILE__) if display_rich_cms?
    end

    def display_rich_cms?
      !!session[:rich_cms].try(:fetch, :display, nil)
    end

    def link(name, options = nil)
      options = {:class => options || name.underscore} unless options.is_a?(Hash)
      link_to name, "#", options
    end

    def rich_cms_tag(*args)
      Rich::Cms::Engine.to_content_tag *args
    end

  end
end