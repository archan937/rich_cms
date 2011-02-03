require "generators/rich_cms"

module Rich
  module Generators

    class CmsAdminGenerator < ::RichCms::Generators::Base

      include Rails::Generators::Migration
      include RichCms::Generators::Migration

      desc         "Creates Devisie / Authlogic model and configures your Rails application for Rich-CMS authentication."
      argument     :model_name, :type => :string , :default => "user"
      class_option :bundle    , :type => :string , :default => false   , :aliases => "-b", :desc => "Add Devise or Authlogic to Gemfile and run 'bundle install'"
      class_option :logic     , :type => :string , :default => "Devise", :aliases => "-l", :desc => "Specify which authentication logic is requested (either 'Devise' or 'Authlogic')"
      class_option :migrate   , :type => :boolean, :default => false   , :aliases => "-m", :desc => "Run 'rake db:migrate' after generating model and migration"

      def register_authentication
        filename = "config/initializers/enrichments.rb"
        line     = "Rich::Cms::Auth.setup do |config|"

        create_file filename unless File.exists?(filename)
        return if File.open(filename).readlines.collect(&:strip).include? line.strip

        File.open(filename, "a+") do |file|
          file << line
          file << "  config.logic = :#{options[:logic].underscore}"
          file << "  config.klass = \"#{model_class_name}\""
          file << "end"
        end
      end

      def generate_authenticated_model
        if options[:bundle]
          gem options[:logic].underscore, {"devise" => "~> 1.1.5", "authlogic" => "~> 2.1.6"}[options[:logic].underscore]
          run "bundle install"
        end
        send :"generate_#{options[:logic].underscore}_assets"
      end

      def migrate
        rake "db:migrate" if options[:migrate]
      end

    protected

      def generate_devise_assets
        generate "devise", model_class_name
      end

      def generate_authlogic_assets
        template           "authlogic/model.rb"    , "app/models/#{model_file_name}.rb"
        template           "authlogic/session.rb"  , "app/models/#{model_file_name}_session.rb"
        migration_template "authlogic/migration.rb", "db/migrate/create_#{table_name}"
      end

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