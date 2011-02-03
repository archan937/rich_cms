module Rich
  class CmsController < ::ApplicationController
    
    def login
      Rich::Cms::Auth.login
      if request.xhr?
        render :update do |page|
          if Rich::Cms::Auth.admin
            page.reload
          else
            page["##{Rich::Cms::Auth.klass_symbol}_#{Rich::Cms::Auth.inputs.first}"].focus
          end
        end
      else
        redirect_to request.referrer
      end
    end
    
    def logout
      Rich::Cms::Auth.logout
      if request.xhr?
        render :update do |page|
          page.reload
        end
      else
        redirect_to request.referrer
      end 
    end

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

  end
end