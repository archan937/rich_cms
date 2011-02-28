require "bundler"
Bundler::GemHelper.install_tasks

require "rake"
require "rake/testtask"
require "rake/rdoctask"
require "test/setup"
require "test/integrator"

desc "Default: run unit tests."
task :default => :test

task :test do
  Rake::Task["test:all"].execute
end

task :restore do
  Rake::Task["restore:all"].execute
end

task :stash do
  Rake::Task["stash:all"].execute
end

namespace :test do
  desc "Set up the rich_cms test suite (this includes creating the MySQL test database, running bundle install)."
  task :setup do
    TestSetup.run
  end
  desc "Test the rich_cms unit and integration tests in Rails 2 and 3."
  task :all do
    system "rake test:rails-2"
    system "rake test:rails-3"
    system "rake test:integration"
  end
  desc "Run all unit tests without any of the dummy Rails apps."
  Rake::TestTask.new(:"unit") do |t|
    t.libs    << "lib"
    t.libs    << "test"
    t.pattern  = "test/shared/tests/unit/**/*_test.rb"
    t.verbose  = true
  end
  desc "Test the rich_cms unit tests in Rails 2."
  Rake::TestTask.new(:"rails-2") do |t|
    t.libs    << "lib"
    t.libs    << "test"
    t.pattern  = "test/rails-2/dummy/test/unit/**/*_test.rb"
    t.verbose  = true
  end
  desc "Test the rich_cms unit tests in Rails 3."
  Rake::TestTask.new(:"rails-3") do |t|
    t.libs    << "lib"
    t.libs    << "test"
    t.pattern  = "test/rails-3/dummy/test/unit/**/*_test.rb"
    t.verbose  = true
  end
  desc "Run all integration tests (non-authenticated, with Devise, with Authlogic) in Rails 2 and 3."
  task :integration do
    Integrator.run do |test|
      test.all
    end
  end
  namespace :integration do
    desc "Run all integration tests (non-authenticated, with Devise, with Authlogic) in Rails 2."
    task :"rails-2" do
      Integrator.run do |test|
        test.rails 2
      end
    end
    desc "Run all integration tests (non-authenticated, with Devise, with Authlogic) in Rails 3."
    task :"rails-3" do
      Integrator.run do |test|
        test.rails 3
      end
    end
  end
end

namespace :restore do
  desc "Restore the Rails 2 and 3 dummy apps."
  task :all do
    system "rake restore:rails-2"
    system "rake restore:rails-3"
  end
  desc "Restore the Rails 2 dummy app."
  task :"rails-2" do
    require "test/rails-2/dummy/test/support/dummy_app.rb"
    DummyApp.restore_all
  end
  desc "Restore the Rails 3 dummy app."
  task :"rails-3" do
    require "test/rails-3/dummy/test/support/dummy_app.rb"
    DummyApp.restore_all
  end
end

namespace :stash do
  desc "Stash the Rails 2 and 3 dummy apps."
  task :all do
    system "rake stash:rails-2"
    system "rake stash:rails-3"
  end
  desc "Stash the Rails 2 dummy app."
  task :"rails-2" do
    require "test/rails-2/dummy/test/support/dummy_app.rb"
    DummyApp.stash_all
  end
  desc "Stash the Rails 3 dummy app."
  task :"rails-3" do
    require "test/rails-3/dummy/test/support/dummy_app.rb"
    DummyApp.stash_all
  end
end

desc "Generate documentation for the Rich-CMS."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "Rich-CMS"
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.rdoc_files.include "README"
  rdoc.rdoc_files.include "MIT-LICENSE"
  rdoc.rdoc_files.include "lib/**/*.rb"
end