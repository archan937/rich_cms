require File.expand_path("../../../test_helper.rb", __FILE__)

module Content
  class CmsableTest < ActiveSupport::TestCase

    context "A Rich-CMS content class" do
      context "at default" do
        setup do
          class Content
            include Rich::Cms::Content
          end
        end

        should "be cmsable" do
          assert Content.cmsable?
          assert Content.new.cmsable?
          assert Content.new.editable?
        end
      end

      context "which is not cmsable" do
        setup do
          class NonCmsableContent
            include Rich::Cms::Content
            cmsable false
          end
        end

        should "not have cmsable behaviour" do
          assert !NonCmsableContent.cmsable?
          assert !NonCmsableContent.new.cmsable?
          assert !NonCmsableContent.new.editable?

          assert_equal ""                , NonCmsableContent.to_javascript_hash
          assert_equal "<span>foo</span>", NonCmsableContent.new(:key => "foo").to_tag
          assert_equal "foo"             , NonCmsableContent.new(:key => "foo").to_tag(:tag => :none)
          assert_equal({}                , NonCmsableContent.new(:key => "foo").to_json)
        end
      end
    end

  end
end