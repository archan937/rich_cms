# TODO: Fix Authlogic where it saves records with save(false). Use save(:validation => false) instead. Search for /save.*\(false\)/

module ActionController
  class IntegrationTest

  protected

    def login
      visit "/cms"
      page.execute_script("$('div#rich_cms_dock a.login').click()")
      within("fieldset.inputs") do
        fill_in "Email"   , :with => "paul.engel@holder.nl"
        fill_in "Password", :with => "testrichcms"
      end
      click_button "Login"
    end

    def mark_content
      page.execute_script "$('div#rich_cms_dock a.mark').click()"
    end

    def edit_content(key)
      page.execute_script "$('.cms_content.marked[data-key=" + key + "]').click()"
    end

  end
end