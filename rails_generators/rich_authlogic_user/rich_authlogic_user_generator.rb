class RichAuthlogicUserGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    @name = @args.first || "user"
  end

  def manifest
    record do |m|
      m.directory                          "app/models"
      m.template               "model.rb", "app/models/#{model_file_name}.rb"
      m.template             "session.rb", "app/models/#{model_file_name}_session.rb"
      m.template              "config.rb", "config/initializers/enrichments.rb", {:collision => :skip}
      m.migration_template "migration.rb", "db/migrate", :migration_file_name => migration_file_name
    end
  end

  def after_generate
    File.open(destination_path("config/initializers/enrichments.rb"), "a+") do |file|
      file << "\nRich::Cms::Engine.authenticate(:authlogic, {:class_name => \"#{model_class_name}\", :identifier => :email})"
    end

    system "rake db:migrate" if options[:migrate]
  end

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

  def add_options!(opt)
    opt.separator ""
    opt.separator "Options:"
    opt.on("-m", "--migrate", "Run 'rake db:migrate' after generating model and migration.") { options[:migrate] = true }
  end

  def banner
    <<-EOS
Creates Authlogic model and migration and also registers authenticated model to Rich-CMS.

USAGE: #{$0} #{spec.name} [model_name]
EOS
  end

end
