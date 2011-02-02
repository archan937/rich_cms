module ActionController
  class Base

    around_filter :prepare_rich_cms

    def prepare_rich_cms
      ::Rich::Cms::Engine.current_controller = self
      yield
    ensure
      ::Rich::Cms::Engine.current_controller = nil
    end

# ///////////////////////////////////////////////////////////////////////////
# /// Doubtfull code [begin]
# ///////////////////////////////////////////////////////////////////////////

    view_path = File.expand_path "../../../../../../app/views", __FILE__
    if respond_to? :append_view_path
      self.append_view_path view_path
    elsif respond_to? :view_paths
      self.view_paths << view_path
    end

    def current_rich_cms_admin
      true
    end

    def current_rich_cms_admin_name
      "paul.engel@holder.nl"
    end

    helper_method :current_rich_cms_admin, :current_rich_cms_admin_name

# ///////////////////////////////////////////////////////////////////////////
# /// Doubtfull code [end]
# ///////////////////////////////////////////////////////////////////////////

  end
end