# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rich/cms/version"

Gem::Specification.new do |s|
  s.name        = "rich_cms"
  s.version     = Rich::Cms::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paul Engel"]
  s.email       = ["paul.engel@holder.nl"]
  s.homepage    = "http://codehero.es/rails_gems_plugins/rich_cms"
  s.summary     = %q{Enrichments (e9s) module for a pluggable CMS frontend}
  s.description = %q{Rich-CMS is a module of E9s (http://github.com/archan937/e9s) which provides a frontend for your CMS content. You can use this gem to manage CMS content or translations (in an internationalized application). The installation and setup process is very easily done. You will have to register content at the Rich-CMS engine and also you will have to specify the authentication mechanism. Both are one-liners.}

  s.rubyforge_project = "rich_cms"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rich_support", "~> 0.0.1"
  s.add_dependency "jzip"        , "~> 1.0.11"
  s.add_dependency "haml"        , "~> 3.0.25"
  s.add_dependency "moneta"      , "~> 0.6.0"
end