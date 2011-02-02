require File.expand_path("../../../test_helper.rb", __FILE__)

module App
  class IntegrationTest < ActionController::IntegrationTest
    context "Rich-CMS" do

      setup do
        @scenario = proc {
          if Rich::Cms::Auth.enabled?
            visit "/"
            assert page.has_no_css? "div#rich_cms_dock"
            assert page.has_no_css? ".cms_content"
            assert_equal "header"   , find(".left h1" ).text
            assert_equal "paragraph", find(".left div").text
          end

          visit "/cms"

          if Rich::Cms::Auth.enabled?
            assert page.has_css? "div#rich_cms_dock"
            assert page.has_no_css? ".cms_content"

            visit "/cms/hide"
            assert page.has_no_css? "div#rich_cms_dock"
            assert page.has_no_css? ".cms_content"
            login
          end

          assert page.has_css? "div#rich_cms_dock"
          assert page.has_content? "Mark content"
          assert_equal "< header >"   , find(".left h1.cms_content" ).text
          assert_equal "< paragraph >", find(".left div.cms_content").text

          mark_content
          assert page.has_css? ".cms_content.marked"

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

          visit "/cms"
          assert page.has_css? "div#rich_cms_dock"
          assert page.has_css? ".cms_content"

          if Rich::Cms::Auth.enabled?
            logout
            assert page.has_no_css? "div#rich_cms_dock"
            assert page.has_no_css? ".cms_content"
            assert_equal "Try out Rich-CMS!"          , find(".left h1"   ).text
            assert_equal "Lorem ipsum dolor sit amet.", find(".left div p").text
          end
        }
      end

      teardown do
        CmsContent.destroy_all
      end

      should "behave as expected" do
        @scenario.call
      end

      AUTHS.each do |lib|
        context "using #{lib}" do
          fixtures :"auth_#{lib}_users"

          setup do
            Rich::Cms::Auth.setup do |config|
              config.logic      = lib.downcase.to_sym
              config.klass      = "Auth#{lib.classify}User"
              config.identifier = :email
            end
          end

          should "behave as expected" do
            @scenario.call
          end
        end
      end

    end
  end
end