require File.expand_path("../../../../test_helper.rb", __FILE__)

module Unit
  module Actionpack
    module ActionController
      class BaseTest < ActiveSupport::TestCase

        context "An ActionController instance" do
          should "respond to :prepare_rich_cms" do
            assert ::ActionController::Base.new.respond_to? :prepare_rich_cms
          end
        end

      end
    end
  end
end