module Rich
  module Cms
    module Auth
      mattr_accessor :current_controller

      extend self

      delegate :klass, :inputs, :to => :specs

      def setup
        @specs = Specs.new
        yield specs
      end

      def enabled?
        !!specs.logic
      end
      
      def login(params)
        begin
          current_controller.sign_in specs.klass_symbol, klass.new(params[specs.klass_symbol])
          true
        rescue ::Exception => e
          puts e.message
        end
      end
      
      def logout
        begin
          current_controller.sign_out specs.klass_symbol
          true
        rescue ::Exception => e
          puts e.message
        end
      end

      def admin
        current_controller.try :send, specs.current_admin_method if specs.current_admin_method
      end
      
      def admin_label
        admin.try(:send, specs.identifier) || "Rich-CMS"
      end

    private

      def specs
        @specs ||= Specs.new
      end
    
      class Specs
        attr_accessor :logic, :klass, :inputs, :identifier, :current_admin_method

        def klass
          case @klass.class.name
          when "String"
            @klass.constantize
          when "Class"
            @klass
          end
        end
      
        def klass_symbol
          klass.name.underscore.gsub("/", "_").to_sym
        end

        def inputs
          @inputs || [:email, :password]
        end

        def identifier
          @identifier || inputs.first
        end
        
        def current_admin_method
          @current_admin_method || :"current_#{klass_symbol}"
        end
      end

    end
  end
end