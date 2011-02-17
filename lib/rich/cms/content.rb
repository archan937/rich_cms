module Rich
  module Cms
    module Content

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods

        def setup(engine, options = {}, &block)
          @specs = Specs.new
          specs.engine  = engine
          specs.options = options
          yield specs if block_given?
        end

        def find(key)
          self.new :key => key, :value => to_cache(:[], key)
        end

        def store(key, value)
          to_cache(:store, key, value)
        end

        def destroy(key)
          to_cache(:delete, key)
        end

      protected

        def key_for(key)
          key
        end

      private

        delegate :cache, :to => :specs

        def specs
          @specs ||= Specs.new
        end

        def to_cache(method, *args)
          key = args.shift
          cache.send method, *args.unshift(key_for(key))
        end

        class Specs
          attr_accessor :engine, :options

          def engine=(value)
            @engine = value.to_s.underscore
            require "moneta/#{engine}"
          end

          def cache
            @cache ||= cache_class.new(options)
          end

          def cache_class
            "Moneta::#{engine.classify}".constantize if engine
          end
        end
      end

      module InstanceMethods
        def self.included(base)
          base.class_eval do
            attr_accessor :key, :value
          end
        end

        def initialize(attributes = nil)
          attributes.each_pair do |key, value|
            send :"#{key}=", value
          end if attributes.is_a?(Hash)
        end

        def default_value

        end

        def to_tag

        end
      end

    end
  end
end