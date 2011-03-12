require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"
require "rake/rdoctask"

desc "Default: run unit tests."
task :default => :test

desc "Run GemSuit unit tests in both dummy apps."
task :test do
  system "suit test unit:all"
end

desc "Generate documentation for the Rich-CMS."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "Rich-CMS"
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.rdoc_files.include "README.textile"
  rdoc.rdoc_files.include "MIT-LICENSE"
  rdoc.rdoc_files.include "lib/**/*.rb"
end