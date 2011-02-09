require File.expand_path("../../../test_helper.rb", __FILE__)

module Rails
  class EngineTest < ActiveSupport::TestCase

    context "Rails::Engine" do
      should "be defined" do
        assert defined?(Rails::Engine)
      end
    end

  end
end