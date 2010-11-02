
module Rich
  class CmsController < ::ApplicationController

    before_filter :require_current_rich_cms_admin, :except => [:display, :position, :login]

    def display
      (session[:rich_cms] ||= {})[:display] = params[:display]
      request.xhr? ? render(:nothing => true) : redirect_to(request.referrer)
    end

    def position
      session[:rich_cms][:position] = params[:position]
      render :nothing => true
    end

    def login
      case rich_cms_auth.logic
      when :authlogic
        @current_rich_cms_admin_session = rich_cms_authenticated_class.new params[key = rich_cms_authenticated_class.name.underscore.gsub("/", "_")]
        authenticated = @current_rich_cms_admin_session.save

        after_rich_cms_login authenticated, key
      end
    end

    def logout
      case rich_cms_auth.logic
      when :authlogic
        (@current_rich_cms_admin_session ||= rich_cms_authenticated_class.find).destroy
      end
      session[:rich_cms] = nil

      after_rich_cms_logout
    end

    unless ::ApplicationController.instance_methods.include?("after_rich_cms_login")
      def after_rich_cms_login(authenticated, key)
        if request.xhr?
          render :update do |page|
            if authenticated
              page.reload
            else
              page["##{key}_#{rich_cms_authentication_inputs.first}"].focus
            end
          end
        else
          redirect_to request.referrer
        end
      end
    end

    unless ::ApplicationController.instance_methods.include?("after_rich_cms_logout")
      def after_rich_cms_logout
        redirect_to request.referrer
      end
    end

    def update
      render :json => Cms::Content::Item.new(params[:content_item]).save
    end

  end

end
