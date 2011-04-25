require File.expand_path("../../../../suit_application.rb", __FILE__)

SuitApplication.test :logic => :none, :require => :i18n_forgery

module Suit
  module Rich
    class I18nForgeryTest < GemSuit::IntegrationTest

      context "Rich-CMS without authentication" do
        context "using Rich-I18n forgery" do
          setup do
            visit "/cms/logout"
          end

          teardown do
            SuitApplication.restore_all
          end

          should "behave as expected" do
            visit "/"
            assert page.has_no_css? "div#rich_cms_dock"
            assert_equal "< header >" , find(".left h1.i18n" ).text
            assert_equal "< content >", find(".left div.i18n").text

            visit "/cms"
            assert page.has_css? "div#rich_cms_dock"
            assert page.has_content? "Mark content"

            mark_content
            assert page.has_css? ".rcms_content.marked"
            assert page.has_css? ".i18n.marked"

            visit "/cms"
            mark_content

            edit_translation "header"
            assert_equal "i18n", find("#raccoon_tip input[name='content_item[__css_class__]']").value
            assert_equal ""    , find("#raccoon_tip input[name='content_item[store_value]']"  ).value

            fill_in_and_submit "#raccoon_tip", {:"content_item[store_value]" => "Try out Rich-CMS!"}, "Save"
            assert_equal "Try out Rich-CMS!" , find(".left h1.i18n" ).text
            assert_equal "< content >"       , find(".left div.i18n").text

            edit_translation "content"
            assert_equal "i18n", find("#raccoon_tip input[name='content_item[__css_class__]']" ).value
            assert_equal ""    , find("#raccoon_tip textarea[name='content_item[store_value]']").value

            fill_in_and_submit "#raccoon_tip", {:"content_item[store_value]" => "<p>Lorem ipsum dolor sit amet.</p>"}, "Save"
            assert_equal "Try out Rich-CMS!"          , find(".left h1.i18n"   ).text
            assert_equal "Lorem ipsum dolor sit amet.", find(".left div.i18n p").text

            hide_dock
            assert page.has_no_css? "div#rich_cms_dock"
            assert page.has_css? ".rcms_content"
            assert page.has_css? ".i18n"
          end
        end
      end

    end
  end
end