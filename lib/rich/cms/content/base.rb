module Rich
  module Cms
    module Content
      module Base

        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods
          base.class_eval do
            @attr_accessors = nil
          end
          Rich::Cms::Content.add_class base
        end

        module ClassMethods

          def attr_accessor(*vars)
            to_add = vars - attr_accessors
            super *to_add unless to_add.empty?
            attr_accessors.concat to_add
          end

        private

          def attr_accessors
            @attr_accessors.try :uniq!
            @attr_accessors ||= []
          end

        end

        module InstanceMethods

          def initialize(arg = nil)
            self.class.send(:prepare_identifiers)

            attributes = [String, Symbol].include?(arg.class) ? self.class.send(:identity_hash_for, arg) : arg
            return unless attributes.is_a?(Hash)

            attributes.assert_valid_keys *self.class.send(:attr_accessors)
            attributes.each_pair do |k, v|
              send :"#{k}=", v
            end
          end

          def editable?
            cmsable? && Auth.can_edit?(self)
          end

          def ==(other)
            other && @store_value == other.instance_variable_get(:"@store_value") && self.class.identifiers.all?{|x| send(x) == other.send(x)} && value == other.value
          end

        end

      end
    end
  end
end