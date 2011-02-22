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
          def to_javascript_hash
            ""
          end

          def css_selector(selector = nil)
            (@css_selector = selector.to_s.downcase unless selector.nil?) || @css_selector || ".rcms_#{self.name.demodulize.underscore}".gsub(/(cms_){2,}/, "cms_")
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

          def to_tag(options = {})
            value
          end

          # def to_rich_cms_response

        private

          def config
            self.class.send :config
          end

        end

      end
    end
  end
end