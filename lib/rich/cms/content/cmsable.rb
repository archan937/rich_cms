module Rich
  module Cms
    module Content
      module Cmsable

        def self.included(base)
          base.extend ClassMethods
          base.send :include, InstanceMethods
          base.class_eval do
            @cmsable = true
          end
        end

        module ClassMethods

          def cmsable(bool = true)
            @cmsable = bool
          end

          def cmsable?
            !!@cmsable
          end

        end

        module InstanceMethods

          def cmsable?
            self.class.cmsable?
          end

        end

      end
    end
  end
end