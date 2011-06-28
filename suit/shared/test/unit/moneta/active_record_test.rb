require File.expand_path("../../../suit_application.rb", __FILE__)
require File.expand_path("../../../test_helper.rb"     , __FILE__)

SuitApplication.setup :moneta => :active_record

module Unit
  module Moneta
    class ActiveRecordTest < ActiveSupport::TestCase

      context "A Rich-CMS content class" do
        context "using the ActiveRecord store engine" do
          should "be able to be stored and fetched" do
            class CmsContent
              include Rich::Cms::Content
              storage :active_record, :table_name => "cms_contents" # NOTE: specified table because of the test namespaces
            end

            key, value = "header", "Welcome to Rich-CMS"

            content = CmsContent.new key
            content.value = value
            content.save

            assert_equal value, CmsContent.find(key).value
          end

          context "using a custom content class" do
            should "be able to be stored and fetched" do
              class CustomCmsContent
                include Rich::Cms::Content
                storage :active_record, :table_name => "custom_cms_contents", :key => :custom_key, :value => :custom_value # NOTE: specified table because of the test namespaces
              end

              key, value = "header", "Welcome to Rich-CMS"

              content = CustomCmsContent.new key
              content.value = value
              content.save

              assert_equal value, CustomCmsContent.find(key).value
            end
          end
        end
      end

    end
  end
end