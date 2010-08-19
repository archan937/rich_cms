
module Rich
  class CmsController < ::ApplicationController

    before_filter :require_current_rich_cms_admin, :except => [:display, :login]
  
    def display
      (session[:rich_cms] ||= {})[[:display, params[:element]].compact.join("_").to_sym] = params[:display]

      if params[:element].blank? and !!params[:display]
        session[:rich_cms][:display_menu ] = true
        session[:rich_cms][:display_panel] = true
      end

      request.xhr? ? render(:nothing => true) : redirect_to(request.referrer)
    end

    def login
      case rich_cms_auth.logic
      when :authlogic
        @current_rich_cms_admin_session = rich_cms_authenticated_class.new params[key = rich_cms_authenticated_class.name.underscore.gsub("/", "_")]

        if (authenticated = @current_rich_cms_admin_session.save)
          # reset_dock_state
        end

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

    def logout
      case rich_cms_auth.logic
      when :authlogic
        (@current_rich_cms_admin_session ||= rich_cms_authenticated_class.find).destroy
      end
      hide
    end

    def update
      render :json => Cms::Content::Item.new(params[:content_item]).save
    end

  end
  
end
