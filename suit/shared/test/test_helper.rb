require "rubygems"

begin
  require "rails/all"
rescue LoadError
end

require "shoulda"
require "mocha"

begin
  require File.expand_path("../../../../lib/rich_cms", __FILE__)
rescue LoadError => e
  begin
    require File.expand_path("../../../../../lib/rich_cms", __FILE__)
  rescue LoadError
    puts "ERROR: #{e.message}\n\n"
  end
end

def forge_rich_i18n
  require File.expand_path("../suit_application/rich/i18n_forgery.rb", __FILE__)
  Translation.send(:content_store).clear
end