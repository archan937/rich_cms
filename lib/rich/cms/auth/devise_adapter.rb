module Rich
  module Cms
    module Auth

      class DeviseAdapter < Adapter
        def login
          if Devise::VERSION.to_f < 1.1
            warden.authenticate(:scope => klass_symbol)
          else
            begin
              sessions = Devise.mappings[klass_symbol].controllers[:sessions]
              Devise.mappings[klass_symbol].controllers[:sessions] = "rich/cms_sessions"
              warden.authenticate(:scope => klass_symbol)
            ensure
              Devise.mappings[klass_symbol].controllers[:sessions] = sessions
            end
          end
        end

        def logout
          sign_out klass_symbol
        end

        def admin
          current_controller.try :send, current_admin_method
        end
      end

    end
  end
end