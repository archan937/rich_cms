
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
      
        def to_tag
          default = @object.attributes.values_at(*@group.identifiers) if @object.new_record?
          
          return value unless Engine.can_render_metadata?
          
          keys  = @group.keys << @group.value.to_s
          data  = @object.attributes.reject{|k, v| !keys.include?(k.to_s)}
                
          tag   = @group.tag || :span             
          attrs = data.collect{|k, v| "data-#{k}=\"#{::ERB::Util.html_escape v}\""}.join " "
          value = @object.new_record? ? "< #{default.size == 1 ? default.first : default.inspect} >" : @object.send(@group.value)
          
          if class_name = @group.selector.match(/^\.\w+$/)
            attrs = "class=\"#{class_name.to_s.gsub(/^\./, "")}\" #{attrs}"
          end
          
          "<#{tag} #{attrs}>#{value}</#{tag}>"
        end
      
      end

    end
  end
end
