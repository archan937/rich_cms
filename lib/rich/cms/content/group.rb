
module Rich
  module Cms
    module Content
      
      class Group < Struct.new(:selector, :tag, :class_name, :key, :value, :add, :before_edit, :after_update)
        
        def self.build(selector, specs)
          self.new *{:selector => selector, :key => :key, :value => :value}.merge(specs).stringify_keys.values_at(*self.members)
        end
        
        def fetch(ref, as_content_item = true)
          reference = if ref.is_a?(Hash)
                        ref
                      elsif identifier.size == 1
                        {identifiers.first => ref}
                      end
          reference.stringify_keys! if reference.is_a?(Hash)
          
          unless valid_reference?(reference)
            raise ArgumentError, "Invalid reference #{reference.inspect} (#{reference.values_at(*identifiers).inspect}) passed for #{identifiers.inspect}"
          end
          
          object = self.class_name.constantize.send :"find_or_initialize_by_#{identifiers.join "_and_"}", *reference.values_at(*identifiers)
          
          as_content_item ? Cms::Content::Item.new(self, object) : object
        end
        
        def keys
          (identifiers + [self.add || []].flatten.collect(&:to_s)).sort
        end
      
        def identifiers
          @identifiers ||= [self.key].flatten.collect(&:to_s).sort
        end
        
        def to_javascript_hash
          "#{self.selector.inspect}: {#{
            members.collect do |k|
              if v = self[k]
                case k
                when "key"
                  "keys: [#{
                  [v].flatten.collect do |key|
                    "data-#{key}".inspect
                  end.join ", "
                  }]"
                when "value"
                  "#{k}: #{"data-#{v}".inspect}"
                when "before_edit", "after_update"
                  "#{k.camelize :lower}: #{v}"
                end
              end
            end.compact.join(", ")
          }}"
        end
        
      private
        
        def valid_reference?(reference)
          reference.is_a?(Hash) && (identifiers - reference.keys).empty? && reference.values_at(*identifiers).compact!.nil?
        end
        
      end
      
    end
  end
end
