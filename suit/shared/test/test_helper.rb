require "rubygems"
require "gem_suit/test_help"

class ActiveSupport::TestCase
  def forge_rich_i18n
    require File.expand_path("../suit_application/rich/i18n_forgery.rb", __FILE__)
    Translation.send(:content_store).clear
  end
end