
module Rich
  class CmsController < ::ApplicationController

    before_filter :require_current_rich_cms_admin, :except => [:show, :hide, :login]
  
    def show
      display_bar(true)
    end

    def hide
      display_bar(false)
    end

    def login
      case rich_cms_auth.logic
      when :authlogic
        @current_rich_cms_admin_session = rich_cms_authenticated_class.new params[key = rich_cms_authenticated_class.name.underscore.gsub("/", "_")]
        authenticated = @current_rich_cms_admin_session.save

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
      render :json => Cms::EditableContent.new(params[:editable_content]).save
    end

  private

    def display_bar(display)
      (session[:rich_cms] ||= {})[:display] = display
      redirect_to request.referrer
    end

  end
  
end
