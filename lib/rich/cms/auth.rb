module Rich
  module Cms
    module Auth
      mattr_accessor :current_controller

      extend self

      delegate :logic, :klass, :klass_symbol, :inputs, :to => :specs

      def setup
        @specs = Specs.new
        yield specs
      end

      def enabled?
        !!logic
      end

      def login_required?
        enabled? && admin.nil?
      end

      def login
        case logic
        when :authlogic
          user_session = "#{klass.name}Session".constantize.new params[klass_symbol]
          user_session.save
        when :devise
          case Devise::VERSION
          when "1.0.8", "1.0.9"
            warden.authenticate(:scope => klass_symbol)
          when "1.1.5"
            begin
              sessions = Devise.mappings[klass_symbol].controllers[:sessions]
              Devise.mappings[klass_symbol].controllers[:sessions] = "rich/cms_sessions"
              warden.authenticate(:scope => klass_symbol)
            ensure
              Devise.mappings[klass_symbol].controllers[:sessions] = sessions
            end
          end
        end if enabled?
        !!admin
      end

      def logout
        case logic
        when :authlogic
          user_session = "#{klass.name}Session".constantize.find
          user_session.try :destroy
        when :devise
          sign_out klass_symbol
        end if enabled?
        session[:rich_cms] = nil
      end

      def admin
        case logic
        when :authlogic
          user_session = "#{klass.name}Session".constantize.find
          user_session.try klass_symbol
        when :devise
          current_controller.try :send, specs.current_admin_method if enabled? && specs.current_admin_method
        end if enabled?
      end

      def admin_label
        (admin.try(:send, specs.identifier) if enabled?) || "Rich-CMS"
      end

    private

      delegate :sign_out, :warden, :params, :session, :to => :current_controller

      def specs
        @specs ||= Specs.new
      end

      class Specs
        attr_accessor :logic, :klass, :inputs, :identifier, :current_admin_method

        def klass
          return unless [:devise, :authlogic].include? logic
          case @klass.class.name
          when "String"
            @klass.constantize
          when "Class"
            @klass
          end
        end

        def klass_symbol
          klass.name.underscore.gsub("/", "_").to_sym if klass
        end

        def inputs
          @inputs || [:email, :password] if klass
        end

        def identifier
          @identifier || inputs.first if klass
        end

        def current_admin_method
          @current_admin_method || :"current_#{klass_symbol}" if klass
        end
      end

    end
  end
end