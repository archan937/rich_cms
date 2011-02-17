module Rich
  module Cms
    module Content

      class Item

        def initialize(*args)
          if args.size == 1 && args.first.is_a?(Hash)
            hash  = args.first
          elsif args.size == 2
            array = args
          else
            raise ArgumentError, "Invalid arguments #{args.inspect} passed for #{self.class.name}"
          end

          if hash && (selector = hash.stringify_keys["__selector__"])
            @group  = Engine.editable_content[selector]
            @object = @group.fetch hash, false

            attributes, params = hash.partition{|k, v| @object.attribute_names.include? k.to_s}

            @object.attributes = Hash[*attributes.flatten]
            @params            = HashWithIndifferentAccess[*params.flatten]

          elsif array && array.first.is_a?(Group) && array.last.is_a?(::ActiveRecord::Base)
            @group, @object = *array
          end
        end

        def save
          @object.save

          if @object.respond_to? :to_rich_cms_response
            hash = @object.to_rich_cms_response @params
          else
            keys = @group.keys << @group.value.to_s
            hash = @object.attributes.reject{|k, v| !keys.include?(k.to_s)}
          end

          selector   = @group.selector
          identifier = @group.identifiers.inject({}){|h, k| h[k] = @object.send(k); h}

          hash.merge({:__selector__ => selector, :__identifier__ => identifier})
        end

        def to_tag(options = {})
          attrs   = []
          default = @group.identifiers.size == 1 ? @object.send(@group.identifiers.first) : @object.attributes.values_at(*@group.identifiers).inspect
          value   = @object.send(@group.value)

          unless Auth.login_required?
            default = "< #{default} >"
            keys    = @group.keys << @group.value.to_s
            data    = @object.attributes.reject{|k, v| !keys.include?(k.to_s)}

            data[:editable_input_type] = options[:as] if %w(string text html).include? options[:as].to_s.downcase

            if class_name = @group.selector.match(/^\.\w+$/)
              (options[:html] ||= {}).store :class, [class_name.to_s.gsub(/^\./, ""), options[:html].try(:fetch, :class, nil)].compact.join(" ")
            end

            attrs << data          .collect{|k, v| "data-#{k}=\"#{::ERB::Util.html_escape v}\""}.join(" ")
          end

          attrs << options[:html].collect{|k, v|      "#{k}=\"#{::ERB::Util.html_escape v}\""}.join(" ") if options[:html]

          tag = options[:tag] || @group.tag || (%w(text html).include?(options[:as].to_s.downcase) ? :div : :span)

          if options[:tag] == :none && !Auth.can_edit?(@object)
            "#{value.blank? ? default : value}"
          else
            # Make default for editable
            tag = :span if tag == :none
            "<#{tag} #{attrs.join(" ")}>#{value.blank? ? default : value}</#{tag}>".html_safe
          end
        end

      end

    end
  end
end
