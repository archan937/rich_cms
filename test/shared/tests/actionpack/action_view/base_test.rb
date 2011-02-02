require File.expand_path("../../../../test_helper.rb", __FILE__)

module Actionpack
  module ActionView
    class BaseTest < ActiveSupport::TestCase

      context "An ActionView instance" do
        should "respond to :rich_cms" do
          assert ::ActionView::Base.new.respond_to? :rich_cms
        end

        should "respond to :display_rich_cms?" do
          assert ::ActionView::Base.new.respond_to? :display_rich_cms?
        end

        should "respond to :link" do
          assert ::ActionView::Base.new.respond_to? :link
        end

        should "respond to :rich_cms_tag" do
          assert ::ActionView::Base.new.respond_to? :rich_cms_tag
        end
      end

    end
  end
end