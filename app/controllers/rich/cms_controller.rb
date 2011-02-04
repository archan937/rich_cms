module Rich
  class CmsController < ::ApplicationController
    before_filter :require_login, :except => [:display, :position]

    def display
      (session[:rich_cms] ||= {})[:display] = params[:display]
      request.xhr? ? render(:nothing => true) : redirect_to(request.referrer)
    end

    def position
      session[:rich_cms][:position] = params[:position]
      render :nothing => true
    end

    def update
      render :json => Cms::Content::Item.new(params[:content_item]).save
    end

  private

    def require_login
      if Rich::Cms::Auth.login_required?
        if request.xhr?
          render :update do |page|
            page.reload
          end
        else
          redirect_to request.referrer
        end
        return false
      end
      true
    end

  end
end