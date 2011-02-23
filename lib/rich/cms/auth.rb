require File.expand_path("../auth/adapter.rb", __FILE__)

Dir[File.expand_path("../auth/*.rb", __FILE__)].each do |file|
  require file
end

module Rich
  module Cms
    module Auth
      extend self

      delegate :logic, :klass, :klass_symbol, :inputs, :to => :specs

      def current_controller=(controller)
        adapter.current_controller = controller if enabled?
      end

      def setup
        @specs = Specs.new
        yield specs
      end

      def enabled?
        !!logic
      end

      def admin?
        !!admin
      end

      def login_required?
        enabled? && !admin?
      end

      def login
        adapter.login if enabled?
        admin?
      end

      def logout
        adapter.logout if enabled?
        session[:rich_cms] = nil
      end

      def admin
        adapter.admin if enabled?
      end

      def admin_label
        (admin.try(:send, specs.identifier) if enabled?) || "Rich-CMS"
      end

      def can_edit?(object)
        return true unless login_required?
        admin? && (!admin.respond_to?(:can_edit?) || admin.can_edit?(object))
      end

    private

      def adapter
        @adapter ||= specs.instantiate_adapter
      end

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

        def adapter_class
          "Rich::Cms::Auth::#{logic.to_s.classify}".constantize
        end

        def instantiate_adapter
          adapter_class.new self
        end
      end

    end
  end
end