require "rubygems"
require "shoulda"
require "mocha"

begin
  require "rails/all"
rescue LoadError
end

begin
  require File.expand_path("../../../../lib/rich_cms", __FILE__)
rescue LoadError
  require File.expand_path("../../../../../lib/rich_cms", __FILE__)
end

include Rich::Cms

def forge_rich_i18n
  require File.expand_path("../support/rich/i18n_forgery.rb", __FILE__)
  Translation.send(:content_store).clear
end