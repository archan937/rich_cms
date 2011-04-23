require File.expand_path("../../../suit_application.rb", __FILE__)
require File.expand_path("../../../test_helper.rb"     , __FILE__)

SuitApplication.setup :moneta => :active_record

module Unit
  module Moneta
    class ActiveRecordTest < ActiveSupport::TestCase

      context "A Rich-CMS content class" do
        context "using the ActiveRecord store engine" do
          setup do
            class CmsContent
              include Rich::Cms::Content
              storage :active_record, :table_name => "cms_contents" # NOTE: specified table because of the test namespaces
            end
            @key, @value = "header", "Welcome to Rich-CMS"
          end

          should "be defined" do
            content = CmsContent.new(@key)
            content.value = @value
            content.save

            assert_equal @value, CmsContent.find(@key).value
          end
        end
      end

    end
  end
end