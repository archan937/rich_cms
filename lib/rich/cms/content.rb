module Rich
  module Cms
    module Content

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods

        delegate :clear, :to => :cache

        def setup(engine, options = {}, &block)
          @specs = Specs.new
          specs.engine  = engine
          specs.options = options
          yield specs if block_given?
        end

        def method_missing(method, *args)
          if DELEGATED.include?(method)
            key = args.shift
            cache.send method, *args.unshift(key_for(key))
          else
            super
          end
        end

      protected

        def key_for(key)
          key
        end

      private

        DELEGATED = [:[], :fetch, :[]=, :delete, :key?, :has_key?, :store, :update_key]

        delegate :cache, :to => :specs

        def specs
          @specs ||= Specs.new
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
        def default_value

        end

        def to_tag

        end
      end

    end
  end
end