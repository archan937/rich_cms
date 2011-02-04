module DummyApp
  extend self

  def stash_all
    stash "Gemfile", :gemfile
    stash "Gemfile.lock"
    stash "app/models/*.rb"
    stash "config/initializers/enrichments.rb"
    stash "config/routes.rb", :routes
    stash "db/migrate/*.rb"
    puts "\n"
  end

  def restore_all
    restore "app/models/*.#{STASHED_EXT}"
    restore "**/*.#{STASHED_EXT}"
    puts "\n"
  end

  def rails_generate(logic = nil)
    stash_all
    return
    generate_cms_admin logic
    generate_cms_content
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
      delete target(file)
      if File.exists?(stashed(file))
        puts "Restoring #{stashed(file).inspect}"
        File.rename stashed(file), target(file)
      end
    end
  end

  def delete(string)
    Dir[expand_path(string)].each do |file|
      if File.exists?(file)
        puts "Deleting #{file.inspect}"
        File.delete file
      end
    end
  end

  def replace(file, replacement)
    content = case replacement
              when :gemfile
                <<-CONTENT.gsub(/^ {18}/, '')
                  source "http://rubygems.org"

                  gem "rails", "#{{2 => "2.3.10", 3 => "3.0.3"}[major_rails_version]}"
                  gem "mysql2"

                  gem "authlogic"
                  gem "devise", "~> #{{2 => "1.0.8", 3 => "1.1.5"}[major_rails_version]}"
                  gem "rich_cms", :path => File.join(File.dirname(__FILE__), "..", "..", "..")

                  gem "database_cleaner"
                  gem "shoulda"
                  gem "mocha"
                  gem "capybara"
                  gem "launchy"
                CONTENT
              when :routes
                case major_rails_version
                when 2
                  <<-CONTENT.gsub(/^ {20}/, '')
                    ActionController::Routing::Routes.draw do |map|
                      map.root :controller => "application"
                      map.connect ':controller/:action/:id'
                      map.connect ':controller/:action/:id.:format'
                    end
                  CONTENT
                when 3
                  <<-CONTENT.gsub(/^ {20}/, '')
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

  def generate_cms_admin(logic)
    option = {:devise => "d", :authlogic => "a"}[logic]

    if option
      puts "Generating #{logic.to_s.classify}User"
      case major_rails_version
      when 2
        `cd #{root_dir} && script/generate rich_cms_admin #{logic.to_s.classify}User -#{option}`
      when 3
        `cd #{root_dir} && rails g rich:cms_admin #{logic.to_s.classify}User -#{option}`
      end
    end
  end

  def generate_cms_content
    puts "Generating CmsContent"
    case major_rails_version
    when 2
      `cd #{root_dir} && script/generate rich_cms_content CmsContent -m`
    when 3
      `cd #{root_dir} && rails g rich:cms_content CmsContent -m`
    end
  end

end

DummyApp.restore_all