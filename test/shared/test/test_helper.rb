require "rubygems"

begin
  require "rails/all"
rescue LoadError
end

if File.basename(File.expand_path("../..", __FILE__)) == "shared"
  $:.unshift File.expand_path("../../../../lib", __FILE__)
else
  $:.unshift File.expand_path("../../../../../lib", __FILE__)
end

require "shoulda"
require "mocha"
require "rich_cms"