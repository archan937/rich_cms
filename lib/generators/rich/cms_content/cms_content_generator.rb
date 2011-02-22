require "generators/rich_cms"

module Rich
  module Generators

    class CmsContentGenerator < ::RichCms::Generators::Base

      include Rails::Generators::Migration
      include RichCms::Generators::Migration

      desc         "Creates Rich-CMS content model and migration and also registers content to Rich-CMS."
      argument     :model_name, :type => :string , :default => "cms_content"
      class_option :migrate   , :type => :boolean, :default => false, :aliases => "-m", :desc => "Run 'rake db:migrate' after generating model and migration"

      def generate_model
        template "model.rb", "app/models/#{model_file_name}.rb"
      end

      def generate_migration
        migration_template "migration.rb", "db/migrate/create_#{table_name}"
      end

      def migrate
        rake "db:migrate" if options[:migrate]
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