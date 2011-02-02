module Rich
  module Cms
    module Auth
      mattr_accessor :current_controller

      extend self

      delegate :identifier, :to => :specs

      def setup
        @specs = Specs.new
        yield specs
      end

      def enabled?
        !!specs.logic
      end

      def klass
        case specs.klass.class.name
        when "String"
          specs.klass.constantize
        when "Class"
          specs.klass
        end
      end

      def inputs
        specs.inputs || [:email, :password]
      end

      def admin
        current_controller.try :send, specs.current_admin_method if specs.current_admin_method
      end

    private

      Specs = Struct.new :logic, :klass, :inputs, :identifier, :current_admin_method

      def specs
        @specs ||= Specs.new
      end

    end
  end
end