class RichCmsContentGenerator < Rails::Generator::Base
  def initialize(runtime_args, runtime_options = {})
    super
    @name = @args.first || "cms_content"
  end

  def manifest
    record do |m|
      m.directory                          "app/models"
      m.template               "model.rb", "app/models/#{model_file_name}.rb"
      m.migration_template "migration.rb", "db/migrate", :migration_file_name => migration_file_name
    end
    
    # destination_path("db/migrate/[0-9]+_#{migration_file_name}.rb").migrate if options[:m] || options[:migrate]
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

  # def add_options!(opt)
  #   opt.separator ""
  #   opt.separator "Options:"
  #   opt.on("-m", "--migrate", "Run 'rake db:migrate' after generating model and migration."){|v| options[:haml] = v }
  # end

  def banner
    <<-EOS
Creates Rich-CMS content model and migration.

USAGE: #{$0} #{spec.name} [model_name]
EOS
  end

end