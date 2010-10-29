require "authlogic"
require "jzip"
require "sass/plugin"

require "formtastic"
ActionView::Base.send :include, Formtastic::SemanticFormHelper

require "config/routes"
require "rich/cms/actionpack"
require "rich/cms/engine"
require "rich/cms/content/group"
require "rich/cms/content/item"
