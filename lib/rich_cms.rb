require "rich_support"
require "jzip"
require "haml"
require "moneta"

Rich::Support.append_gem_path File.expand_path("../..", __FILE__)

%w(authlogic devise devise/version).each do |lib|
  begin
    require lib
  rescue LoadError
  end
end

require "rich/cms/actionpack"
require "rich/cms/engine"
require "rich/cms/content"
require "rich/cms/auth"
require "rich/cms/version"