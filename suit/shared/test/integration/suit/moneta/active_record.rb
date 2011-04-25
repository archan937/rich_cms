require File.expand_path("../../../../suit_application.rb", __FILE__)

SuitApplication.test :logic => :none, :moneta => :active_record

module Suit
  module Moneta
    class ActiveRecordTest < GemSuit::IntegrationTest

      context "Rich-CMS without authentication" do
        context "using the ActiveRecord store engine" do
          setup do
            Object.send :remove_const, :CmsContent
            Rich::Cms::Content.classes.clear
            class CmsContent
              include Rich::Cms::Content
              storage :active_record, :table_name => "cms_contents"
            end
            visit "/cms/logout"
          end

          teardown do
            SuitApplication.restore_all
          end

          should "behave as expected" do
            visit "/"
            assert page.has_no_css? "div#rich_cms_dock"
            assert_equal "< header >" , find(".left h1.rcms_content" ).text
            assert_equal "< content >", find(".left div.rcms_content").text

            visit "/cms"
            assert page.has_css? "div#rich_cms_dock"
            assert page.has_content? "Mark content"

            mark_content
            assert page.has_css? ".rcms_content.marked"

            visit "/cms"
            mark_content

            edit_content "header"
            assert_equal "rcms_content", find("#raccoon_tip input[name='content_item[__css_class__]']").value
            assert_equal ""            , find("#raccoon_tip input[name='content_item[store_value]']"  ).value

            fill_in_and_submit "#raccoon_tip", {:"content_item[store_value]" => "Try out Rich-CMS!"}, "Save"
            assert_equal "Try out Rich-CMS!" , find(".left h1.rcms_content" ).text
            assert_equal "< content >"       , find(".left div.rcms_content").text

            edit_content "content"
            assert_equal "rcms_content", find("#raccoon_tip input[name='content_item[__css_class__]']" ).value
            assert_equal ""            , find("#raccoon_tip textarea[name='content_item[store_value]']").value

            fill_in_and_submit "#raccoon_tip", {:"content_item[store_value]" => "<p>Lorem ipsum dolor sit amet.</p>"}, "Save"
            assert_equal "Try out Rich-CMS!"          , find(".left h1.rcms_content"   ).text
            assert_equal "Lorem ipsum dolor sit amet.", find(".left div.rcms_content p").text

            hide_dock
            assert page.has_no_css? "div#rich_cms_dock"
            assert page.has_css? ".rcms_content"
          end
        end
      end

    end
  end
end