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

if Rails::VERSION::MAJOR < 3
  require "config/routes"
  ActionView::Base.send :include, Formtastic::SemanticFormHelper # still required?
end