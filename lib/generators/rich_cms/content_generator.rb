require 'rails/generators/base'
require 'rails/generators/migration'

module RichCms
  module Generators
    class ContentGenerator < Rails::Generators::Base

      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      argument :model_name, :type => :string, :default => 'cms_content'

      desc "Generates the necessary migration"

      def self.next_migration_number(path)
        Time.zone.now.utc.to_s(:number)
      end

      def create_content
        migration_template 'migration.rb', 'db/migrate/create_cms_contents'
      end

      protected

      def migration_class_name
        model_name.classify
      end

      def table_name
        model_name.underscore.gsub("/", "_").pluralize
      end

    end
  end
end

