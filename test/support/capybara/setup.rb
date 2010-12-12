# http://techiferous.com/2010/04/using-capybara-in-rails-3 FTW!

require "capybara/rails"
require "capybara/envjs"

module ActionController
  class IntegrationTest
    include Capybara
  end
end

[{:firefox => :profile}, {:chrome => :default_profile}].each_with_index do |specs, index|
  browser, profile = specs.keys.first, specs.values.first
  Capybara.register_driver(driver = :"selenium_#{browser}") do |app|
    Capybara::Driver::Selenium.new app, :browser => browser.to_sym, profile => "capybara"
  end
  Capybara.default_driver = driver if index.zero?
end

# Capybara.default_driver = :envjs