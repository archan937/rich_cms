# module DummyApp
#   extend self
#
#   def stash
#     puts "Stashing ..."
#
#     stash_file
#     root_dir do |files|
#       File.mv files["Gemfile"], files["Gemfile"] + ".stash"
#     end
#   end
#
#   def restore
#     puts "Restoring..."
#     Dir[File.join(root_dir, "**/*.stash")].each do |file|
#       File.mv file, file.gsub(".stash", "")
#     end
#   end
#
# private
#
#   def root_dir
#     @root_dir ||= File.expand_path("../../../../dummy/", __FILE__)
#     yield self
#   end
#
#   def [](path)
#     File.expand_path "../#{path}", root_dir
#   end
#
# end
#
# DummyApp.restore
# DummyApp.stash

require File.expand_path("../../../../test_helper.rb", __FILE__)