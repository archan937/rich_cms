require File.expand_path("../../../test_helper.rb", __FILE__)

module Auth
  class EngineTest < ActiveSupport::TestCase

    context "Rich::Auth::Engine" do
      should "be defined" do
        assert defined?(::Rich::Auth::Engine)
      end
    end

  end
end