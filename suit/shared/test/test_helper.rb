require "rubygems"
require "gem_suit/test_help"

class ActiveSupport::TestCase
  def clear_content_classes
    Rich::Cms::Content.classes.clear
  end

  def forge_rich_i18n
    load File.expand_path("../suit_application/rich/i18n_forgery.rb", __FILE__)
    Translation.send(:content_store).clear
  end
end

Rich::Cms::Auth.setup do |config|
  config.logic = nil
end