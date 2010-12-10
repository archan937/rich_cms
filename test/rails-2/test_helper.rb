ENV["RAILS_ENV"] = "test"

`cd #{File.expand_path("../dummy", __FILE__)} && rake db:test:load`

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "test_help"

require File.expand_path("../../integration_test_helper", __FILE__)
require File.expand_path("../pending"                   , __FILE__)

puts "\nRunning Rails #{Rails::VERSION::STRING}\n\n"