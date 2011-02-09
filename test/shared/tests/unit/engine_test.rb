require File.expand_path("../../test_helper.rb", __FILE__)

class EngineTest < ActiveSupport::TestCase

  context "Rich::Cms::Engine" do
    should "be defined" do
      assert defined?(Rich::Cms::Engine)
    end

    should "respond to :init" do
      assert Rich::Cms::Engine.respond_to?(:init)
    end

    context "on initialization" do
      # test something
    end
  end

end