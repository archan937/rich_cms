ENV["RAILS_ENV"] = "test"

`cd #{File.expand_path("../dummy", __FILE__)} && rake db:test:load`

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"

require File.expand_path("../../integration_test_helper" , __FILE__)
require File.expand_path("../../../lib/rich_cms"         , __FILE__)
include Rich::Cms

puts "\nRunning Rails #{Rails::VERSION::STRING}\n\n"