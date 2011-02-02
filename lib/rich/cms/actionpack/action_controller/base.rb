module ActionController
  class Base

    around_filter :prepare_rich_cms

    def prepare_rich_cms
      ::Rich::Cms::Auth.current_controller = self
      yield
    ensure
      ::Rich::Cms::Auth.current_controller = nil
    end

    view_path = File.expand_path "../../../../../../app/views", __FILE__
    if respond_to? :append_view_path
      self.append_view_path view_path
    elsif respond_to? :view_paths
      self.view_paths << view_path
    end

  end
end