module Rich
  module Cms
    module Content
      module Rendering

        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods
          base.class_eval do
            @css_selector = nil
            @config       = nil
          end
        end

        module ClassMethods
          def css_selector(selector = nil)
            (@css_selector = selector.to_s.downcase unless selector.nil?) || @css_selector || ".rcms_#{self.name.demodulize.underscore}"
          end

          def configure(*args)
            @config = args.extract_options!.symbolize_keys!
            @css_selector = args.first unless args.first.nil?
          end

          def config
            @config ||= {}
          end
        end

        module InstanceMethods
        private

          def config
            self.class.send :config
          end

        end

      end
    end
  end
end