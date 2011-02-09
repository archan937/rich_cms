require File.expand_path("../../../test/support/dummy_app.rb", __FILE__)

DummyApp.setup "Non authenticated" do |app|
  app.generate_cms_content
end

module App
  module Integration
    class NonAuthenticatedTest < ActionController::IntegrationTest

      context "Rich-CMS without authentication" do
        setup do
          Rich::Cms::Auth.setup do |config|
            # no authentication
          end
          visit "/cms/logout"
        end

        teardown do
          DummyApp.restore_all true
        end

        should "behave as expected" do
          visit "/"
          assert page.has_no_css? "div#rich_cms_dock"
          assert_equal "< header >"   , find(".left h1.cms_content" ).text
          assert_equal "< paragraph >", find(".left div.cms_content").text

          visit "/cms"
          assert page.has_css? "div#rich_cms_dock"
          assert page.has_content? "Mark content"

          mark_content
          assert page.has_css? ".cms_content.marked"

          visit "/cms"
          mark_content

          edit_content "header"
          assert_equal ".cms_content", find("#raccoon_tip input[name='content_item[__selector__]']").value
          assert_equal ""            , find("#raccoon_tip input[name='content_item[value]']"       ).value

          fill_in_and_submit "#raccoon_tip", {:"content_item[value]" => "Try out Rich-CMS!"}, "Save"
          assert_equal "Try out Rich-CMS!", find(".left h1.cms_content" ).text
          assert_equal "< paragraph >"    , find(".left div.cms_content").text

          edit_content "paragraph"
          assert_equal ".cms_content", find("#raccoon_tip input[name='content_item[__selector__]']").value
          assert_equal ""            , find("#raccoon_tip textarea[name='content_item[value]']"    ).value

          fill_in_and_submit "#raccoon_tip", {:"content_item[value]" => "<p>Lorem ipsum dolor sit amet.</p>"}, "Save"
          assert_equal "Try out Rich-CMS!"          , find(".left h1.cms_content"   ).text
          assert_equal "Lorem ipsum dolor sit amet.", find(".left div.cms_content p").text

          hide_dock
          assert page.has_no_css? "div#rich_cms_dock"
          assert page.has_css? ".cms_content"
        end
      end

    end
  end
end