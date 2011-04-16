module ActionView
  class Base

    def rich_cms
      render :file => File.expand_path("../../../../../../app/views/rich_cms.html.erb", __FILE__) if !!session[:rich_cms].try(:fetch, :display, nil)
    end

    # //////////////////////////////////
    # // Rich::Cms::Auth related
    # //////////////////////////////////

    def rich_cms_login_required?
      Rich::Cms::Auth.login_required?
    end

    def rich_cms_admin_class
      Rich::Cms::Auth.klass
    end

    def rich_cms_admin_inputs
      Rich::Cms::Auth.inputs
    end

    def current_rich_cms_admin
      Rich::Cms::Auth.admin
    end

    def current_rich_cms_admin_label
      Rich::Cms::Auth.admin_label
    end

    # //////////////////////////////////
    # // Rich::Cms::Content related
    # //////////////////////////////////

    def rich_cms_content_javascript_hash
      Rich::Cms::Content.javascript_hash
    end

    def rich_cms_tag(*args)
      raise ArgumentError, "wrong number of arguments (#{args.size} for 3)" if args.size > 3

      options    = args.extract_options!
      identifier = args.pop
      css_class  = args.pop

      raise ArgumentError unless args.empty? # just to be sure

      if css_class.nil?
        case Rich::Cms::Content.classes.size
        when 0
          # let Rich::Cms::Content.fetch raise an error
        when 1
          css_class = Rich::Cms::Content.classes.first.css_class
        else
          raise ArgumentError, "Specify the Rich-CMS content CSS class as there are more than one Rich-CMS content classes: #{Rich::Cms::Content.classes.collect(&:name).join(", ")}"
        end
      end

      begin
        Rich::Cms::Content.fetch(css_class, identifier).to_tag options
      rescue Rich::Cms::Content::CssClassNotMatchedError => e
        raise unless Rich::Cms::Content.classes.size == 1
        css_class = Rich::Cms::Content.classes.first.css_class
        warn "[WARNING] #{e.message} and thus using #{css_class.inspect} instead".yellow
        retry
      end
    end

  end
end