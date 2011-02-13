require "jzip"
require "haml"

begin
  require "authlogic"
rescue LoadError
end
begin
  require "devise"
  require "devise/version"
rescue LoadError
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