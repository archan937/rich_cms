require File.expand_path("../../../../test_helper.rb", __FILE__)

module Actionpack
  module ActionView
    class BaseTest < ActiveSupport::TestCase

      context "An ActionView instance" do
        should "respond to :rich_cms" do
          assert ::ActionView::Base.new.respond_to? :rich_cms
        end
      end

    end
  end
end