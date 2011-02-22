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

    def rich_cms_tag(selector, identifier, options = {})
      Rich::Cms::Content.fetch(selector, identifier).to_tag options
    end

  end
end