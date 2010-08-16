
module ActionController
  class Base

    around_filter :assign_current_controller
    helper_method :current_rich_cms_admin, :current_rich_cms_admin_name, :rich_cms_authenticated_class, :rich_cms_authentication_inputs
    
    def assign_current_controller
      ::Rich::Cms::Engine.current_controller = self
      yield
    ensure
      ::Rich::Cms::Engine.current_controller = nil
    end

    def require_current_rich_cms_admin
      unless current_rich_cms_admin
        redirect_to root_url
        return false
      end
    end

    def current_rich_cms_admin
      case rich_cms_auth.logic
      when :authlogic
        return @current_rich_cms_admin if defined?(@current_rich_cms_admin)
        @current_rich_cms_admin_session ||= rich_cms_authenticated_class.find
        @current_rich_cms_admin = @current_rich_cms_admin_session.try rich_cms_auth.specs[:class_name].demodulize.underscore
      end
    end

    def current_rich_cms_admin_name
      current_rich_cms_admin[rich_cms_auth.specs[:identifier]] if current_rich_cms_admin
    end
    
    def rich_cms_auth
      ::Rich::Cms::Engine.authentication
    end
    
    def rich_cms_authenticated_class
      case rich_cms_auth.logic
      when :authlogic
        "#{rich_cms_auth.specs[:class_name]}Session".constantize
      end
    end
    
    def rich_cms_authentication_inputs
      case rich_cms_auth.logic
      when :authlogic
        rich_cms_auth.specs[:inputs] || [:email, :password]
      end
    end
    
  end
end
