require File.expand_path("../../../../test_helper.rb", __FILE__)

module Core
  module String
    class HtmlSafeTest < ActiveSupport::TestCase

      context "A String" do
        should "respond to :html_safe" do
          assert "".respond_to?(:html_safe)
        end
      end

    end
  end
end