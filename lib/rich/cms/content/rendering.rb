module Rich
  module Cms
    module Content
      module Rendering

        CALLBACKS = [:before_edit, :after_update]

        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods
          base.class_eval do
            @css_selector  = nil
            @configuration = nil
          end
        end

        module ClassMethods
          def configuration
            @configuration ||= {}
          end

          def css_selector(selector = nil)
            (@css_selector = selector.to_s.downcase unless selector.nil?) || @css_selector || ".rcms_#{self.name.demodulize.underscore}".gsub(/(cms_){2,}/, "cms_")
          end

          def configure(*args, &block)
            @configuration = args.extract_options!.symbolize_keys!
            @css_selector  = args.first unless args.first.nil?
            config_mock.instance_eval(&block) if block_given?
          end

          def to_javascript_hash
            "{#{data_pairs.concat(callback_pairs).collect{|key, value| "#{key}: #{value}"}.join ", "}}".html_safe
          end

        private

          def config_mock
            @config_mock ||= ConfigMock.new self
          end

          class ConfigMock
            def initialize(klass)
              @klass = klass
            end

            def method_missing(method, *args)
              if %w(selector tag before_edit after_update).include? method.to_s
                @klass.instance_variable_get(:@configuration)[method] = args.first
              else
                super
              end
            end
          end

          def data_pairs
            pairs         = ActiveSupport::OrderedHash.new
            pairs[:keys ] = ["store_key"]
            pairs[:value] = "value"

            pairs.collect do |key, value|
              collected = [value].flatten.collect{|x| "data-#{x}"}
              value     = (value.is_a?(Array) ? collected : collected.first).inspect
              [key, value]
            end
          end

          def callback_pairs
            [].tap do |array|
              configuration.values_at(*CALLBACKS).each_with_index do |value, index|
                next if value.blank?
                key = CALLBACKS[index].to_s.camelize(:lower)
                array << [key, value]
              end
            end
          end
        end

        module InstanceMethods

          # TODO: Clean up this method and add tests! Also include options[:html] and additional keys (e.g. :derivative_key, :derivative_value)
          def to_tag(options = {})
            if (tag = derive_tag(options)).nil?
              value
            else
              if class_name = self.class.css_selector.match(/^\.\w+$/)
                (options[:html] ||= {}).store :class, [class_name.to_s.gsub(/^\./, ""), options[:html].try(:fetch, :class, nil)].compact.join(" ")
              end

              attrs = ActiveSupport::OrderedHash.new

              if editable?
                attrs["class"]                    = options[:html].delete(:class)
                attrs["data-store_key"]           = store_key
                attrs["data-value"]               = @store_value
                attrs["data-editable_input_type"] = options[:as] if %w(string text html).include? options[:as].to_s.downcase
              end

              attrs = attrs.collect{|key, value| "#{key}=\"#{::ERB::Util.html_escape value}\""}.join(" ")
              text  = editable? && default_value? ? "< #{value} >" : value

              "<#{tag} #{attrs}>#{text}</#{tag}>"

            end.html_safe
          end

          # TODO: Complete this method and add tests!
          def to_rich_cms_response
            {:__selector__ => self.class.css_selector, :__identifier__ => {:store_key => store_key}, :value => value}
          end

        private

          def derive_tag(options)
            tag = options[:tag] || configuration[:tag]
            return if !editable? && tag == :none
            (tag unless tag == :none) || (%w(text html).include?(options[:as].to_s.downcase) ? :div : :span)
          end

          def configuration
            self.class.send :configuration
          end

        end

      end
    end
  end
end