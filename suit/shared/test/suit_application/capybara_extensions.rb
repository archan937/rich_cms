module GemSuit
  class IntegrationTest

    def login
      visit "/cms"
      page.execute_script "$('div#rich_cms_dock a.login').click()"
      fill_in_and_submit "#raccoon_tip", {:Email => "paul.engel@holder.nl", :Password => "testrichcms"}, "Login"
    end

    def logout
      find("#rich_cms_dock").click_link "Logout"
    end

    def hide_dock
      find("#rich_cms_dock").click_link "Hide"
    end

    def close_raccoontip
      find("#raccoontip").click_link "Close"
      assert !find("#raccoon_tip").visible?
    end

    def mark_content
      page.execute_script "$('div#rich_cms_dock a.mark').click()"
    end

    def edit_content(key, css_class = "rcms_content")
      page.execute_script <<-JAVASCRIPT
        $(".#{css_class}.marked[data-store_key=#{key}]").click();
      JAVASCRIPT
      assert find("#raccoon_tip").visible?
    end

    def edit_translation(key)
      edit_content "#{I18n.locale}#{Translation.delimiter}#{key}", Translation.css_class
    end

    def fill_in_and_submit(selector, with, submit)
      within "#{selector} fieldset.inputs" do
        with.each do |key, value|
          begin
            fill_in key.to_s, :with => value
          rescue Selenium::WebDriver::Error::ElementNotDisplayedError
            page.execute_script <<-JAVASCRIPT
              var input = $("#{selector} [name='#{key}']");
              if (input.data("cleditor")) {
                input.val("#{value}");
                input.data("cleditor").updateFrame();
              }
            JAVASCRIPT
          end
        end
      end
      find(selector).find_button(submit).click
      sleep 2
    end

  end
end