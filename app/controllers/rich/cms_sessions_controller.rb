module Rich
  class CmsSessionsController < ::ApplicationController

    def login
      success = Rich::Cms::Auth.login
      if request.xhr?
        render :update do |page|
          if success
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

  end
end