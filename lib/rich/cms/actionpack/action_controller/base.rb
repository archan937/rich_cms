module ActionController
  class Base

    around_filter :prepare_rich_cms

    def prepare_rich_cms
      ::Rich::Cms::Content.check_in_memory_storage
      ::Rich::Cms::Auth.current_controller = self
      yield
    ensure
      ::Rich::Cms::Auth.current_controller = nil
    end

  end
end