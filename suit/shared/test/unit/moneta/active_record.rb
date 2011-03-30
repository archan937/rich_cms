require File.expand_path("../../../test_helper.rb"     , __FILE__)
# require File.expand_path("../../../suit_application.rb", __FILE__)

# SuitApplication.test :moneta => :active_record

module Moneta
  class ActiveRecordTest < ActiveSupport::TestCase

    context "A Rich-CMS content class" do
      context "using the ActiveRecord store engine" do
        setup do
          class Content
            include Rich::Cms::Content
            storage :active_record
          end
        end

        should "be defined" do
          content = Content.new(@key)
          content.value = @value
          content.save

          assert_equal @value, Content.find(@key).value
        end
      end
    end

  end
end