module DummyApp
  extend self

  def setup(stash_files = true, &block)
    restore_all
    stash_all if stash_files
    @prepared = true
    yield self if block_given?
    require File.expand_path("../../test_helper.rb", __FILE__)
  end

  def stash_all
    stash  "Gemfile", :gemfile
    stash  "Gemfile.lock"
    stash  "app/models/*.rb"
    stash  "config/initializers/devise.rb"
    stash  "config/initializers/enrichments.rb"
    stash  "config/routes.rb", :routes
    stash  "test/fixtures/*_users.yml"
    delete "db/migrate/*.rb"
  end

  def restore_all(force = nil)
    if @prepared
      unless force
        puts "Cannot (non-forced) restore files after having prepared the dummy app" unless force.nil?
        return
      end
    end

    delete  "config/locales/devise.en.yml"
    delete  "db/migrate/*.rb"
    delete  "test/fixtures/cms_contents.yml"
    delete  "test/unit/*.rb"
    restore "app/models/*.rb.#{STASHED_EXT}"
    restore "**/*.#{STASHED_EXT}"
  end

  def restore_admin_fixtures
    puts "\n"
    restore "test/fixtures/*.yml.#{STASHED_EXT}"
  end

  def generate_cms_admin(logic = :devise)
    logic_option = {:devise => "d", :authlogic => "a"}[logic]

    if logic_option
      klass = "#{logic.to_s.capitalize}User"

      run "Generating #{klass}",
          case major_rails_version
          when 2
            "script/generate rich_cms_admin #{klass} -#{logic_option}"
          when 3
            "rails g rich:cms_admin #{klass} -#{logic_option}"
          end
    end
  end

  def generate_cms_content
    klass = "CmsContent"

    run "Generating #{klass}",
        case major_rails_version
        when 2
          "script/generate rich_cms_content #{klass}"
        when 3
          "rails g rich:cms_content #{klass}"
        end
  end

private

  STASHED_EXT = "stashed"

  def root_dir
    @root_dir ||= File.expand_path("../../dummy/", __FILE__)
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

  def stash(string, replacement = nil)
    Dir[expand_path(string)].each do |file|
      unless File.exists?(stashed(file))
        puts "Stashing  #{target(file).inspect}"
        File.rename target(file), stashed(file)
        replace(file, replacement)
      end
    end
  end

  def restore(string)
    Dir[expand_path(string)].each do |file|
      if File.exists?(stashed(file))
        delete target(file)
        puts "Restoring #{stashed(file).inspect}"
        File.rename stashed(file), target(file)
      end
    end
  end

  def delete(string)
    Dir[expand_path(string)].each do |file|
      puts "Deleting  #{file.inspect}"
      File.delete file
    end

    dirname = expand_path File.dirname(string)

    return unless File.exists?(dirname)
    Dir.glob("#{dirname}/*", File::FNM_DOTMATCH) do |file|
      return unless %w(. ..).include? File.basename(file)
    end

    puts "Deleting  #{dirname.inspect}"
    Dir.delete dirname
  end

  def replace(file, replacement)
    content = case replacement
              when :gemfile
                <<-CONTENT.gsub(/^ {18}/, "")
                  source "http://rubygems.org"

                  gem "rails", "#{{2 => "2.3.10", 3 => "3.0.3"}[major_rails_version]}"
                  gem "mysql2"

                  gem "authlogic"
                  gem "devise", "~> #{{2 => "1.0.9", 3 => "1.1.5"}[major_rails_version]}"
                  gem "rich_cms", :path => File.join(File.dirname(__FILE__), "..", "..", "..")

                  gem "shoulda"
                  gem "mocha"
                  gem "capybara"
                  gem "launchy"
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

    File.open target(file), "w" do |file|
      file << content
    end if content
  end

  def run(description, command)
    return if command.to_s.gsub(/\s/, "").size == 0
    puts "\n#{description}"
    command = "cd #{root_dir} && #{command}"
    puts "#{command}\n"
    `#{command}`
  end

end