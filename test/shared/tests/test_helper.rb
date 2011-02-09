ENV["RAILS_ENV"] = "test"

require File.expand_path("../../shared/support/dummy_app.rb", __FILE__)

DummyApp.restore_all
DummyApp.prepare_database

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "#{"rails/" if Rails::VERSION::MAJOR >= 3}test_help"

Dir[File.expand_path("../../shared/support/**/*.rb", __FILE__)].each do |file|
  require file
end

# if Rails 3
# require File.expand_path("../../../lib/rich_cms", __FILE__)
# include Rich::Cms

puts "\nRunning Rails #{Rails::VERSION::STRING}\n\n"