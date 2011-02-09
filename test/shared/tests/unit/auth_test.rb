require File.expand_path("../../test_helper.rb", __FILE__)

class AuthTest < ActiveSupport::TestCase

  context "Rich::Cms::Auth" do
    should "be defined" do
      assert defined?(::Rich::Cms::Auth)
    end
  end

end