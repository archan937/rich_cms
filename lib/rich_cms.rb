require "authlogic"
require "formtastic"
require "jzip"
require "haml"

require "rich/cms/core"
require "rich/cms/activesupport"
require "rich/cms/actionpack"
require "rich/cms/rails"
require "rich/cms/engine"
require "rich/cms/content/group"
require "rich/cms/content/item"

require File.expand_path("../../config/routes", __FILE__) if Rails::VERSION::MAJOR < 3