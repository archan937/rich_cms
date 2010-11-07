
require "rich/cms/core/string/html_safe"

class String
  include Rich::Cms::Core::String::HtmlSafe unless String.new.respond_to? :html_safe
end
