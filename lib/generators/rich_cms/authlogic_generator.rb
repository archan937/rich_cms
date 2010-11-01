require 'rails/generators/base'
require 'rails/generators/migration'

module RichCms
  module Generators
    class AuthlogicGenerator < Rails::Generators::Base

      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      argument :model_name, :type => :string, :default => 'user'

      def after_generate
        File.open("config/initializers/enrichments.rb", "a+") do |file|
          file << "\nRich::Cms::Engine.authenticate(:authlogic, {:class_name => \"#{model_class_name}\", :identifier => :email})"
        end
      end

      desc "Generates the necessary authlogic files"

      def self.next_migration_number(path)
        Time.zone.now.utc.to_s(:number)
      end

      def create_authlogic
        migration_template 'authlogic_migration.rb', "db/migrate/create_#{table_name}"
      end

      def generate_model
        template 'authlogic_model.rb', "app/models/#{model_file_name}.rb"
        # check if exists
      end

      def generate_session
        template 'authlogic_session.rb', "app/models/#{model_file_name}_session.rb"
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

