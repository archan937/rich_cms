
require "rich/cms/core/string/html_safe"

class String
  include Rich::Cms::Core::String::HtmlSafe unless "".respond_to? :html_safe
end
