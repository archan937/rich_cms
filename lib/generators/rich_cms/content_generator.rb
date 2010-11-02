require 'rails/generators/base'
require 'rails/generators/migration'

module RichCms
  module Generators
    class ContentGenerator < Rails::Generators::Base

      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      argument :model_name, :type => :string, :default => 'cms_content'

      def after_generate
        File.open("config/initializers/enrichments.rb", "a+") do |file|
          file << "\nRich::Cms::Engine.register(\".#{model_file_name}\", {:class_name => \"#{model_class_name}\"})"
        end
      end

      desc "Generates the necessary migration"

      def self.next_migration_number(path)
        Time.zone.now.utc.to_s(:number)
      end

      def create_content
        migration_template 'content_migration.rb', "db/migrate/create_#{table_name}"
      end

      def generate_model
        invoke "active_record:model", [model_file_name], :migration => false
      end

      protected

      def model_file_name
        model_name.underscore
      end

      def model_class_name
        model_name.classify
      end

      def migration_class_name
        migration_file_name.pluralize.camelize
      end

      def table_name
        model_file_name.underscore.gsub("/", "_").pluralize
      end

    end
  end
end

