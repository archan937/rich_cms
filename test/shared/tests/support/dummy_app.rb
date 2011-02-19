STDOUT.sync = true

require "fileutils"

module DummyApp
  extend self

  def setup(description, logic = nil, &block)
    log "\n".ljust 145, "="
    log "Setting up test environment for Rails #{major_rails_version} - #{description}\n"
    log "\n".rjust 145, "="

    @logic = logic
    restore_all
    stash_all
    yield self if block_given?
    prepare_database
    @prepared = true

    log "\n".rjust 145, "="
    log "Environment for Rails #{major_rails_version} - #{description} is ready for testing"
    log "=" .ljust 145, "="

    run
  end

  def prepare_database
    return if @db_prepared
    if @ran_generator
      stash   "db/schema.rb", :schema
      execute "rake db:test:purge"
      execute "RAILS_ENV=test rake db:migrate"
    else
      execute "rake db:test:load"
    end
    @db_prepared = true
  end

  def restore_all(force = nil)
    if @prepared
      unless force
        log "Cannot (non-forced) restore files after having prepared the dummy app" unless force.nil?
        return
      end
    end

    delete  "config/locales/devise.en.yml"
    delete  "db/migrate/*.rb"
    delete  "test/fixtures/cms_contents.yml"
    delete  "test/fixtures/devise_users.yml"
    delete  "test/unit/cms_content_test.rb"
    delete  "test/unit/devise_user_test.rb"
    restore "app/models/*.rb.#{STASHED_EXT}"
    restore "test/fixtures/**/rails-*.yml.#{STASHED_EXT}"
    restore "**/*.#{STASHED_EXT}"
  end

  def stash_all
    stash  "Gemfile", :gemfile
    stash  "Gemfile.lock"
    stash  "app/models/*.rb"
    stash  "config/initializers/devise.rb"
    stash  "config/initializers/enrichments.rb"
    stash  "config/database.yml", :database
    stash  "config/routes.rb", :routes
    delete "db/migrate/*.rb"
    stash  "test/fixtures/**/rails-*.yml"
  end

  def generate_cms_admin
    logic_option = {:devise => "d", :authlogic => "a"}[@logic]

    if logic_option
      klass = "#{@logic.to_s.capitalize}User"

      execute case major_rails_version
              when 2
                "script/generate rich_cms_admin #{klass} -#{logic_option}"
              when 3
                "rails g rich:cms_admin #{klass} -b -#{logic_option}"
              end
    end

    @ran_generator = true
  end

  def correct_users_fixtures
    if File.exists? expand_path(path = "test/fixtures/#{@logic}_users/rails-#{major_rails_version}.yml.#{STASHED_EXT}")
      copy path, "test/fixtures/#{@logic}_users.yml"
    end
  end

  def correct_authentication_assets
    return unless @logic == :devise

    case major_rails_version
    when 2
      restore "config/initializers/devise.rb"
    when 3
      devise_config = expand_path("config/initializers/devise.rb")
      lines         = File.open(devise_config).readlines
      pepper        = "b57fdc3ba6288df70ca46cf2f7a6c168408e2fd602a185deda0340db3f1b4427d7c02e94880ec3786a26c248ff40b12f4e39d3315bb7ddf5541b9efb27ecd8f7"

      log :correcting, devise_config
      File.open(devise_config, "w") do |file|
        lines.each do |line|
          file << line.gsub(/(config\.pepper = ").*(")/, "config.pepper = \"#{pepper}\"")
        end
      end
    end
  end

  def generate_cms_content
    klass = "CmsContent"

    execute case major_rails_version
            when 2
              "script/generate rich_cms_content #{klass}"
            when 3
              "rails g rich:cms_content #{klass}"
            end

    @ran_generator = true
  end

private

  STASHED_EXT = "stashed"

  def run
    ENV["RAILS_ENV"] = "test"

    require File.expand_path("../../../config/environment.rb", __FILE__)
    require "#{"rails/" if Rails::VERSION::MAJOR >= 3}test_help"

    Dir[File.expand_path("../**/*.rb", __FILE__)].each do |file|
      require file
    end

    puts "\nRunning Rails #{Rails::VERSION::STRING}\n\n"
  end

  def root_dir
    @root_dir ||= File.expand_path("../../../../dummy/", __FILE__)
  end

  def major_rails_version
    @major_rails_version ||= root_dir.match(/\/rails-(\d)\//)[1].to_i
  end

  def expand_path(path)
    path.match(root_dir) ?
      path :
      File.expand_path(path, root_dir)
  end

  def target(file)
    file.gsub /\.#{STASHED_EXT}$/, ""
  end

  def stashed(file)
    file.match(/\.#{STASHED_EXT}$/) ?
      file :
      "#{file}.#{STASHED_EXT}"
  end

  def restore(string)
    Dir[expand_path(string)].each do |file|
      if File.exists?(stashed(file))
        delete target(file)
        log :restoring, stashed(file)
        File.rename stashed(file), target(file)
      end
    end
  end

  def stash(string, replacement = nil)
    Dir[expand_path(string)].each do |file|
      unless File.exists?(stashed(file))
        log :stashing, target(file)
        File.rename target(file), stashed(file)
        write(file, replacement)
      end
    end
  end

  def delete(string)
    Dir[expand_path(string)].each do |file|
      log :deleting, file
      File.delete file
    end

    dirname = expand_path File.dirname(string)

    return unless File.exists?(dirname)
    Dir.glob("#{dirname}/*", File::FNM_DOTMATCH) do |file|
      return unless %w(. ..).include? File.basename(file)
    end

    log :deleting, dirname
    Dir.delete dirname
  end

  def write(file, replacement)
    content = case replacement
              when :gemfile
                auth_gem = case @logic
                           when :devise
                             'gem "devise", "1.0.9"'
                           when :authlogic
                             'gem "authlogic"'
                           end if major_rails_version == 2
                <<-CONTENT.gsub(/^ {18}/, "")
                  source "http://rubygems.org"

                  gem "rails", "#{{2 => "2.3.11", 3 => "3.0.4"}[major_rails_version]}"
                  gem "mysql2"
                  #{auth_gem}
                  gem "rich_cms", :path => File.expand_path("../../../..", __FILE__)

                  gem "shoulda"
                  gem "mocha"
                  gem "capybara"
                  gem "launchy"
                  gem "hpricot"
                CONTENT
              when :schema
                <<-CONTENT.gsub(/^ {18}/, "")
                  ActiveRecord::Schema.define(:version => 19820801180828) do
                  end
                CONTENT
              when :database
                <<-CONTENT.gsub(/^ {18}/, "")
                  development:
                    adapter: sqlite3
                    database: db/development.sqlite3
                    pool: 5
                    timeout: 5000
                  test:
                    adapter: mysql2
                    database: rich_cms_test
                    username: root
                    password: service
                    host: 127.0.0.1
                CONTENT
              when :routes
                case major_rails_version
                when 2
                  <<-CONTENT.gsub(/^ {20}/, "")
                    ActionController::Routing::Routes.draw do |map|
                      map.root :controller => "application"
                      map.connect ':controller/:action/:id'
                      map.connect ':controller/:action/:id.:format'
                    end
                  CONTENT
                when 3
                  <<-CONTENT.gsub(/^ {20}/, "")
                    Dummy::Application.routes.draw do
                      root :to => "application#index"
                    end
                  CONTENT
                end
              end

    if content
      log :writing, file
      File.open target(file), "w" do |file|
        file << content
      end
    end
  end

  def copy(source, destination)
    log :copying, "#{source} -> #{destination}"
    FileUtils.cp expand_path(source), expand_path(destination)
  end

  def execute(command)
    return if command.to_s.gsub(/\s/, "").size == 0
    log :executing, command
    `cd #{root_dir} && #{command}`
  end

  def log(action, string = nil)
    output = [string || action]
    output.unshift action.to_s.capitalize.ljust(10, " ") unless string.nil?
    puts output.join("  ")
  end

end