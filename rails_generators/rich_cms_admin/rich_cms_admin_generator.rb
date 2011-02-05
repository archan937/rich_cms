require File.expand_path("../lib/devise/route_devise.rb", __FILE__)

class RichCmsAdminGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    @name = @args.first || "user"
  end

  def manifest
    unless defined?(Devise)    || options[:logic].to_s.underscore != "devise"
      puts <<-WARNING.gsub(/^ {9}/, "")
        Don't forget to install Devise 1.0.9!
      WARNING
    end
    unless defined?(Authlogic) || options[:logic].to_s.underscore != "authlogic"
      puts <<-WARNING.gsub(/^ {9}/, "")
        Don't forget to install Authlogic 2.1.6!
      WARNING
    end
    record do |m|
      send :"generate_#{options[:logic].underscore}_assets", m if options[:logic]
    end
  end

  def after_generate
    filename = destination_path("config/initializers/enrichments.rb")
    line     = "Rich::Cms::Auth.setup do |config|"

    File.open(filename, "a+") do |file|
      file << "#{line}\n"
      file << "  config.logic = :#{options[:logic].underscore}\n"
      file << "  config.klass = \"#{model_class_name}\"\n"
      file << "end"
    end unless File.open(filename).readlines.collect(&:strip).include? line.strip

    system "rake db:migrate" if options[:migrate]
  end

  # //////////////////////////////////
  # // Helper methods
  # //////////////////////////////////

  def model_file_name
    @name.underscore
  end

  def model_class_name
    @name.classify
  end

  def table_name
    model_file_name.gsub("/", "_").pluralize
  end

  def migration_file_name
    "create_#{table_name}"
  end

  def migration_class_name
    migration_file_name.camelize
  end

protected

  def banner
    <<-BANNER.gsub(/^ {7}/, "")
Creates Devise / Authlogic model and configures your Rails application for Rich-CMS authentication.

USAGE: #{$0} #{spec.name} [model_name]
    BANNER
  end

  def add_options!(opt)
    opt.separator ""
    opt.separator "Options:"
    opt.on("-d", "--devise"   , "Use Devise as authentication logic (this is default)."      ) { options[:logic  ] = "Devise"    }
    opt.on("-a", "--authlogic", "Use Authlogic as authentication logic."                     ) { options[:logic  ] = "Authlogic" }
    opt.on("-m", "--migrate"  , "Run 'rake db:migrate' after generating model and migration.") { options[:migrate] = true        }
  end

private

  def generate_devise_assets(m)
    if defined?(Devise)
      m.directory          "config/initializers"
      m.directory          "config/locales"
      m.template           "devise/devise.rb", "config/initializers/devise.rb"
      m.file               "devise/en.yml"   , "config/locales/devise.en.yml"
      m.readme             "devise/README"
    end

    m.directory          "app/models"
    m.template           "devise/model.rb"    , "app/models/#{model_file_name}.rb"
    m.migration_template "devise/migration.rb", "db/migrate", :migration_file_name => "devise_#{migration_file_name}"
    m.route_devise       table_name
  end

  def generate_authlogic_assets(m)
    m.directory          "app/models"
    m.template           "authlogic/model.rb"    , "app/models/#{model_file_name}.rb"
    m.template           "authlogic/session.rb"  , "app/models/#{model_file_name}_session.rb"
    m.template           "authlogic/config.rb"   , "config/initializers/enrichments.rb", {:collision => :skip}
    m.migration_template "authlogic/migration.rb", "db/migrate", :migration_file_name => migration_file_name
  end

end