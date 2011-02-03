require "rake"
require "rake/testtask"
require "rake/rdoctask"

begin
  require "jeweler"
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "rich_cms"
    gemspec.summary     = "Enrichments (e9s) module for a pluggable CMS frontend"
    gemspec.description = "Rich-CMS is a module of E9s (http://github.com/archan937/e9s) which provides a frontend for your CMS content. You can use this gem to manage CMS content or translations (in an internationalized application). The installation and setup process is very easily done. You will have to register content at the Rich-CMS engine and also you will have to specify the authentication mechanism. Both are one-liners."
    gemspec.email       = "paul.engel@holder.nl"
    gemspec.homepage    = "http://codehero.es/rails_gems_plugins/rich_cms"
    gemspec.author      = "Paul Engel"

    gemspec.add_dependency "haml", "~> 3.0.25"
    gemspec.add_dependency "jzip", "~> 1.0.11"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc "Default: run unit tests."
task :default => :test

task :test do
  Rake::Task["test:all"].execute
end

namespace :test do
  desc "Test the rich_cms plugin in Rails 2 and 3."
  task :all do
    system "rake test:rails-2"
    system "rake test:rails-3"
  end
  desc "Test the rich_cms plugin in Rails 2."
  Rake::TestTask.new(:"rails-2") do |t|
    t.libs    << "lib"
    t.libs    << "test"
    t.pattern  = "test/rails-2/{,/*/**}/*_test.rb"
    t.verbose  = true
  end
  desc "Test the rich_cms plugin in Rails 3."
  Rake::TestTask.new(:"rails-3") do |t|
    t.libs    << "lib"
    t.libs    << "test"
    t.pattern  = "test/rails-3/{,/*/**}/*_test.rb"
    t.verbose  = true
  end
end

desc "Generate documentation for the rich_cms plugin."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "Rich-CMS"
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.rdoc_files.include "README"
  rdoc.rdoc_files.include "MIT-LICENSE"
  rdoc.rdoc_files.include "lib/**/*.rb"
end