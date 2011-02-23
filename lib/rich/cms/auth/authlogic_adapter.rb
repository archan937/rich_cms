module Rich
  module Cms
    module Auth

      class AuthlogicAdapter < Adapter
        def login
          user_session = "#{klass.name}Session".constantize.new params[klass_symbol]
          user_session.save
        end

        def logout
          user_session = "#{klass.name}Session".constantize.find
          user_session.try :destroy
        end

        def admin
          user_session = "#{klass.name}Session".constantize.find
          user_session.try klass_symbol
        end
      end

    end
  end
end