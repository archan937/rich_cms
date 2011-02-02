module Rich
  class CmsController < ::ApplicationController

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