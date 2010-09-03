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
    gemspec.homepage    = "http://github.com/archan937/rich_cms"
    gemspec.author      = "Paul Engel"

    gemspec.add_dependency "jzip", ">= 1.0.9"
    gemspec.add_dependency "haml", ">= 3"
    gemspec.add_dependency "formtastic", "0.9.7"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc "Default: run unit tests."
task :default => :test

desc "Test the rich_cms plugin."
Rake::TestTask.new(:test) do |t|
  t.libs    << "lib"
  t.libs    << "test"
  t.pattern  = "test/**/*_test.rb"
  t.verbose  = true
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
