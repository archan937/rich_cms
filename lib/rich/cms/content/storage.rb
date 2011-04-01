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
            @specs_args    = {:klass => base}
          end
        end

        module ClassMethods
          def storage(engine, options = {}, &block)
            @specs_args[:options] = options
            specs.engine  = engine
            yield specs if block_given?
          end

          def find(identifier, *alternatives)
            default = nil
            [identifier, *alternatives].each do |arg|
              if arg.is_a?(Hash) && arg.size == 1 && arg.values.first == :is_default
                identifier = default = arg.keys.first
              else
                identifier = arg
              end
              if content = find_by_identifier(identifier)
                return content
              end
            end
            self.new default unless default.nil?
          end

          def find_or_initialize(identifier, *alternatives)
            find(identifier, *alternatives) || self.new(identifier)
          end

        private

          def find_by_identifier(identifier)
            instance = self.new identity_hash_for(identifier)

            return unless content_store.has_key? instance.store_key

            instance.tap do |i|
              instance.instance_variable_set :"@store_value", content_store[instance.store_key]
            end
          end

          def content_store
            @content_store ||= specs.instantiate_store
          end

          def specs
            @specs ||= Specs.new *@specs_args.values_at(:klass, :options).compact
          end

          class Specs
            attr_accessor :engine, :options

            def initialize(klass, options = {})
              @klass   = klass
              @options = options
            end

            def engine=(name)
              @engine = name.to_s.underscore
              begin
                require "moneta/#{engine}"
              rescue LoadError
                require "rich/cms/moneta/#{engine}"
              end
            end

            def store_class
              "Moneta::#{engine.classify}".constantize if engine
            end

            def instantiate_store
              case engine
              when "active_record"
                options = {:connection => YAML.load_file(File.expand_path("config/database.yml", Rails.root))[Rails.env], :table => @klass.name.tableize}.merge @options
              end
              store_class.new options
            end
          end
        end

        module InstanceMethods
          def store_key
            self.class.identifiers.collect{|x| send x}.join self.class.delimiter
          end

          def value
            ((@value unless @value.blank?) || (@store_value unless @store_value.blank?)).try(:html_safe) || (@default_value ||= default_value)
          end

          def value=(val)
            @value = val
          end

          def default_value?
            value
            !!@default_value
          end

          def save
            !!(content_store[store_key] = @value if !!@value && editable?).tap do |result|
              if result
                @store_value = @value
                @value = @default_value = nil
              end
            end
          end

          def save_and_return(condition = nil)
            self if save || (condition == :always)
          end

          def destroy
            !!(content_store.delete(store_key) if editable?)
          end

        protected

          def default_value
            store_key.split(/#{self.class.delimiter}|\./).last.gsub("_", " ")
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