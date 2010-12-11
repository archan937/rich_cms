ENV["RAILS_ENV"] = "test"

`cd #{File.expand_path("../dummy", __FILE__)} && rake db:test:load`

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"

Dir[File.expand_path("../../support/**/*.rb", __FILE__)].each do |file|
  require file
end
require File.expand_path("../../../lib/rich_cms", __FILE__)
include Rich::Cms

puts "\nRunning Rails #{Rails::VERSION::STRING}\n\n"