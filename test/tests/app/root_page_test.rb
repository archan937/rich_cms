require File.expand_path("../../../test_helper.rb", __FILE__)

module App
  class RootPageTest < ActionController::IntegrationTest

    context "The root page" do
      should "render as expected" do
        visit "/"
        assert page.has_no_selector? "div#rich_cms_dock"

        visit "/cms"
        assert page.has_selector? "div#rich_cms_dock"

        page.execute_script("$('div#rich_cms_dock a.login').click()")
        within("fieldset.inputs") do
          fill_in "Email"   , :with => "paul.engel@holder.nl"
          fill_in "Password", :with => "test"
        end
        click_button("Login")
      end
    end

  end
end