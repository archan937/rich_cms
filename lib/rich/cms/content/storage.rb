module Rich
  module Cms
    module Content
      module Storage

        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods
          base.class_eval do
            attr_accessors << :value
          end
        end

        module ClassMethods

          delegate :has_key?, :to => :content_store

          def storage(engine_name, options = {})
            @specs ||= Specs.new self
            @specs.engine  = engine_name
            @specs.options = options
          end

          def find(identifier, *alternatives)
            raise NotImplementedError, "Please specify the storage engine of #{self.name}." if @specs.nil?

            default = nil
            [identifier, *alternatives].each do |arg|
              if arg.is_a?(Hash) && arg.size == 1 && arg.values.first == :default
                id = default = arg.keys.first
              else
                id = arg
              end
              if content = find_by_identifier(id)
                return content
              end
            end
            self.new identity_hash_for(default || identifier)
          end

        private

          delegate :content_store, :to => :"@specs"

          def find_by_identifier(identifier)
            instance = self.new identity_hash_for(identifier)

            return unless has_key?(instance.store_key) || valid_match?(instance)

            instance.tap do |i|
              instance.instance_variable_set :"@store_value", content_store[instance.store_key]
            end
          end

          def valid_match?(instance)
            false
          end

          class Specs
            attr_accessor :engine, :options

            def initialize(klass)
              @klass = klass
            end

            def engine=(engine_name)
              @engine = engine_name.to_s.underscore
              @store  = nil
              begin
                require "moneta/#{engine}"
              rescue LoadError
                require "rich/cms/moneta/#{engine}"
              end
            end

            def store_class
              "Moneta::#{engine.classify}".constantize if engine
            end

            def content_store
              @store ||= begin
                opts = case engine
                       when "active_record"
                         {:connection => YAML.load_file(File.expand_path("config/database.yml", Rails.root))[Rails.env],
                          :table_name => @klass.name.tableize}
                       else
                         {}
                       end
                store_class.new opts.merge(@options)
              end
            end
          end

        end

        module InstanceMethods

          def store_key
            self.class.identifiers.collect{|x| send x}.join self.class.delimiter
          end

          def value
            ((@value unless @value.blank?) || (@store_value unless @store_value.blank?)).try(:html_safe) || default_value
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
            @default_value ||= store_key.split(/#{self.class.delimiter}|\./).last.gsub("_", " ")
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