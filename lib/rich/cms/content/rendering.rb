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
            "{#{data_pairs.concat(callback_pairs).collect{|key, value| "#{key}: #{value}"}.join ", "}}".html_safe
          end

        private

          def data_pairs
            pairs         = ActiveSupport::OrderedHash.new
            pairs[:keys ] = identifiers.sort{|a, b| a.to_s <=> b.to_s}
            pairs[:value] = "value"

            pairs.collect do |key, value|
              collected = [value].flatten.collect{|x| "data-#{x}"}
              value     = (value.is_a?(Array) ? collected : collected.first).inspect
              [key, value]
            end
          end

          def callback_pairs
            [].tap do |array|
              (@callbacks || {}).values_at(*CALLBACKS).each_with_index do |value, index|
                next if value.blank?
                key = CALLBACKS[index].to_s.camelize(:lower)
                array << [key, value]
              end
            end
          end
        end

        module InstanceMethods

          def to_tag(options = {})
            if (tag = derive_tag(options)).nil?
              value
            else
              if class_name = self.class.css_selector.match(/^\.\w+$/)
                (options[:html] ||= {}).store :class, [class_name.to_s.gsub(/^\./, ""), options[:html].try(:fetch, :class, nil)].compact.join(" ")
              end

              attrs = ActiveSupport::OrderedHash.new

              if editable?
                attrs["class"] = options[:html].delete(:class)
                self.class.identifiers.sort{|a, b| a.to_s <=> b.to_s}.each do |x|
                  attrs["data-#{x}"] = send(x)
                end
                attrs["data-value"] = value
              end

              # :editable_input_type
              # options[:html]
              # :derivative_key, :derivative_value (additional keys)

              attrs = attrs.collect{|key, value| "#{key}=\"#{::ERB::Util.html_escape value}\""}.join(" ")
              text  = editable? && default_value? ? "< #{value} >" : value

              "<#{tag} #{attrs}>#{text}</#{tag}>"

            end.html_safe
          end

          # def to_rich_cms_response

        private

          def derive_tag(options)
            tag = options[:tag] || config[:tag]
            return if !editable? && tag == :none
            (tag unless tag == :none) || (%w(text html).include?(options[:as].to_s.downcase) ? :div : :span)
          end

          def config
            self.class.send :config
          end

        end

      end
    end
  end
end