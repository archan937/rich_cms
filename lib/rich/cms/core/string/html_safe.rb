module Rich
  module Cms
    module Core
      module String
        module HtmlSafe

          unless ::String.new.respond_to? :html_safe
            def html_safe
              self
            end
          end

        end
      end
    end
  end
end