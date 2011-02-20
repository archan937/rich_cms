module Rich
  module Cms
    module Content
      module Storage

        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods
          base.class_eval do
            attr_accessors << :value
            @specs         = nil
            @content_store = nil
          end
        end

        module ClassMethods
          def storage(engine, options = {}, &block)
            @specs = Specs.new
            specs.engine  = engine
            specs.options = options
            yield specs if block_given?
          end

          def find(identifier)
            self.new(identity_hash_for identifier).tap do |instance|
              if content_store.has_key? instance.store_key
                instance.instance_variable_set :"@store_value", content_store[instance.store_key]
              end
            end
          end

        private

          def content_store
            @content_store ||= specs.instantiate_store
          end

          def specs
            @specs ||= Specs.new
          end

          class Specs
            attr_accessor :engine, :options

            def engine=(name)
              @engine = name.to_s.underscore
              require "moneta/#{engine}"
            end

            def store_class
              "Moneta::#{engine.classify}".constantize if engine
            end

            def instantiate_store
              store_class.new options
            end
          end
        end

        module InstanceMethods
          def store_key
            self.class.identifiers.collect{|x| send x}.join self.class.delimiter
          end

          def value
            @value || @store_value || (@default_value = default_value)
          end

          def value=(val)
            @value = val
          end

          def save
            !!(content_store[store_key] = @value if !!@value && editable?)
          end

          def destroy
            !!(content_store.delete(store_key) if editable?)
          end

        protected

          def default_value
            store_key.split(".").last.gsub("_", "")
          end

        private

          def content_store
            self.class.send :content_store
          end
        end

      end
    end
  end
end