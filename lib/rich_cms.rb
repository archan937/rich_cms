require "jzip"
require "haml"

begin
  require "authlogic"
rescue MissingSourceFile
end
begin
  require "devise"
  require "devise/version"
rescue MissingSourceFile
end

require "rich/cms/core"
require "rich/cms/activesupport"
require "rich/cms/actionpack"
require "rich/cms/rails"
require "rich/cms/auth"
require "rich/cms/engine"
require "rich/cms/content/group"
require "rich/cms/content/item"

require File.expand_path("../../config/routes", __FILE__) if Rails::VERSION::MAJOR < 3