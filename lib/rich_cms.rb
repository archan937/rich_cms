require "jzip"
require "haml"
require "moneta"

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