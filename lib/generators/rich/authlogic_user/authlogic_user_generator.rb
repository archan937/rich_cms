require "generators/rich_cms"

module Rich
  module Generators

    class AuthlogicUserGenerator < ::RichCms::Generators::Base

      include Rails::Generators::Migration
      include RichCms::Generators::Migration

      desc         "Creates Authlogic model and migration and also registers authenticated model to Rich-CMS."
      argument     :model_name, :type => :string , :default => "user"
      class_option :migrate   , :type => :boolean, :default => false, :aliases => "-m", :desc => "Run 'rake db:migrate' after generating model and migration"

      def register_authentication
        filename = "config/initializers/enrichments.rb"
        line     = "\nRich::Cms::Engine.authenticate(:authlogic, {:class_name => \"#{model_class_name}\", :identifier => :email})"

        create_file filename unless File.exists?(filename)
        return if File.open(filename).readlines.collect(&:strip).include? line.strip

        File.open(filename, "a+") do |file|
          file << line
        end
      end

      def generate_model
        template "model.rb", "app/models/#{model_file_name}.rb"
      end

      def generate_session
        template "session.rb", "app/models/#{model_file_name}_session.rb"
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