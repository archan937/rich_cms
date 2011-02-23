module Rich
  module Cms
    module Content
      module Rendering

        CALLBACKS = [:before_edit, :after_update]

        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods
          base.class_eval do
            @css_selector = nil
            @config       = nil
          end
        end

        module ClassMethods
          def callbacks(hash)
            raise ArgumentError, "Expected a hash containing callbacks" unless hash.is_a?(Hash)
            hash.symbolize_keys!.assert_valid_keys *CALLBACKS
            @callbacks = hash
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

          def to_javascript_hash
            "{#{data_pairs.concat(callback_pairs).reject(&:blank?).join ", "}}".html_safe
          end

        private

          def data_pairs
            pairs              = ActiveSupport::OrderedHash.new
            pairs[:identifier] = identifiers
            pairs[:value]      = "value"

            pairs.collect do |key, value|
              collected = [value].flatten.collect{|x| "data-#{x}"}
              value     = (value.is_a?(Array) ? collected : collected.first).inspect
              "#{key}: #{value}"
            end
          end

          def callback_pairs
            [].tap do |array|
              (@callbacks || {}).values_at(*CALLBACKS).each_with_index do |value, index|
                next if value.blank?
                key = CALLBACKS[index].to_s.camelize(:lower)
                array << "#{key}: #{value}"
              end
            end
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