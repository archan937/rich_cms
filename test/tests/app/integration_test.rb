require File.expand_path("../../../test_helper.rb", __FILE__)

module App
  class IntegrationTest < ActionController::IntegrationTest
    fixtures :authlogic_users
    fixtures :devise_users

    context "Rich-CMS" do
      setup do
        @scenario = proc {
          visit "/"
          assert page.has_no_css? "div#rich_cms_dock"
          assert page.has_no_css? ".cms_content"

          visit "/cms"
          assert page.has_css? "div#rich_cms_dock"
          assert page.has_no_css? ".cms_content"

          visit "/cms/hide"
          assert page.has_no_css? "div#rich_cms_dock"
          assert page.has_no_css? ".cms_content"

          login
          assert page.has_css? "div#rich_cms_dock"
          assert page.has_content? "Mark content"

          mark_content
          assert page.has_css? ".cms_content.marked"

          edit_content "header"
          assert page.has_css? "#raccoon_tip"
        }
      end

      %w(Authlogic).each do |lib|
        context "using #{lib}" do
          setup do
            Rich::Cms::Engine.authenticate lib.downcase.to_sym, {:class_name => "#{lib}::User", :identifier => :email}
          end

          should "behave as expected" do
            @scenario.call
          end
        end
      end
    end

  end
end