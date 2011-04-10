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
                ::ActionView::Base.new.rich_cms_tag ".some_class", @key
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
              Rich::Cms::Content.expects(:fetch).with(CmsContent.css_selector, @key).returns CmsContent.new(:key => @key)
              ::ActionView::Base.new.rich_cms_tag @key
            end

            should "fetch a CmsContent entry when passed a non-matching selector and warn about it" do
              ::ActionView::Base.any_instance.expects(:warn)
              Rich::Cms::Content             .expects(:fetch).with(".bogus_selector"      , @key).raises  Rich::Cms::Content::SelectorNotMatchedError
              Rich::Cms::Content             .expects(:fetch).with(CmsContent.css_selector, @key).returns CmsContent.new(:key => @key)
              ::ActionView::Base.new.rich_cms_tag ".bogus_selector", @key
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

              should "raise an error when having passed a non-matched selector" do
                assert_raise Rich::Cms::Content::SelectorNotMatchedError do
                  ::ActionView::Base.new.rich_cms_tag ".bogus_selector", @key
                end
              end

              should "fetch content as expected when passing valid arguments" do
                Rich::Cms::Content.expects(:fetch).with(CmsContent .css_selector, @key).returns CmsContent .new(:key => @key)
                ::ActionView::Base.new.rich_cms_tag     CmsContent .css_selector, @key

                Rich::Cms::Content.expects(:fetch).with(MoreContent.css_selector, @key).returns MoreContent.new(:key => @key)
                ::ActionView::Base.new.rich_cms_tag     MoreContent.css_selector, @key

                more_content = MoreContent.new(:key => @key)
                more_content.expects(:to_tag).with(:tag => :p)
                Rich::Cms::Content.expects(:fetch).with(MoreContent.css_selector, @key).returns more_content
                ::ActionView::Base.new.rich_cms_tag     MoreContent.css_selector, @key, :tag => :p
              end
            end
          end
        end

      end
    end
  end
end