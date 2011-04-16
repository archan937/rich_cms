require File.expand_path("../../../../test_helper.rb", __FILE__)
require "hpricot"

module Unit
  module Actionpack
    module ActionView
      class BaseTest < ActiveSupport::TestCase

        context "An ActionView instance" do
          setup do
            @key = "some_key"
          end

          should "respond to :rich_cms" do
            assert ::ActionView::Base.new.respond_to? :rich_cms
          end

          should "respond to :rich_cms_tag" do
            assert ::ActionView::Base.new.respond_to? :rich_cms_tag
          end

          context "without any Rich-CMS content" do
            setup do
              Rich::Cms::Content.classes.clear
            end

            should "raise the expected error when calling rich_cms_tag" do
              assert_raise NotImplementedError do
                ::ActionView::Base.new.rich_cms_tag
              end
              assert_raise NotImplementedError do
                ::ActionView::Base.new.rich_cms_tag @key
              end
              assert_raise NotImplementedError do
                ::ActionView::Base.new.rich_cms_tag "some_class", @key
              end
            end
          end

          context "with CmsContent defined" do
            setup do
              class CmsContent
                include Rich::Cms::Content
                storage :memory
              end
              Rich::Cms::Content.classes = [CmsContent]
            end

            should "fetch a CmsContent entry when only the key is passed" do
              content = CmsContent.new :key => @key
              content.expects :to_tag
              Rich::Cms::Content.expects(:fetch).with(CmsContent.css_class, @key).returns content
              ::ActionView::Base.new.rich_cms_tag @key
            end

            should "fetch a CmsContent entry when passed a non-matching CSS class and warn about it" do
              content = CmsContent.new :key => @key
              content.expects :to_tag
              ::ActionView::Base.any_instance.expects(:warn)
              Rich::Cms::Content             .expects(:fetch).with("bogus_css_class"   , @key).raises  Rich::Cms::Content::CssClassNotMatchedError
              Rich::Cms::Content             .expects(:fetch).with(CmsContent.css_class, @key).returns content
              ::ActionView::Base.new.rich_cms_tag "bogus_css_class", @key
            end

            context "and with MoreContent defined" do
              setup do
                class MoreContent
                  include Rich::Cms::Content
                  storage :memory
                end
                Rich::Cms::Content.classes = [CmsContent, MoreContent]
              end

              should "raise an error when only the key is passed" do
                assert_raise ArgumentError do
                  ::ActionView::Base.new.rich_cms_tag @key
                end
              end

              should "raise an error when having passed a non-matched CSS class" do
                assert_raise Rich::Cms::Content::CssClassNotMatchedError do
                  ::ActionView::Base.new.rich_cms_tag "bogus_css_class", @key
                end
              end

              should "fetch content as expected when passing valid arguments" do
                content = CmsContent.new :key => @key
                content.expects :to_tag
                Rich::Cms::Content.expects(:fetch).with(CmsContent .css_class, @key).returns content
                ::ActionView::Base.new.rich_cms_tag     CmsContent .css_class, @key

                more_content = MoreContent.new :key => @key
                more_content.expects :to_tag
                Rich::Cms::Content.expects(:fetch).with(MoreContent.css_class, @key).returns more_content
                ::ActionView::Base.new.rich_cms_tag     MoreContent.css_class, @key

                more_content = MoreContent.new(:key => @key)
                more_content.expects(:to_tag).with(:tag => :p)
                Rich::Cms::Content.expects(:fetch).with(MoreContent.css_class, @key).returns more_content
                ::ActionView::Base.new.rich_cms_tag     MoreContent.css_class, @key, :tag => :p
              end
            end
          end
        end

      end
    end
  end
end