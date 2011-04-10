require "rubygems"
require "gem_suit"

class SuitApplication < GemSuit::Application

  def description
    case logic
    when :none
      "Non authenticated"
    when :devise
      "Devise"
    when :authlogic
      "Authlogic"
    end
  end

  def prepare
    case logic
    when :none
      generate_cms_content
    when :devise
      generate_cms_admin
      correct_user_fixtures
      correct_devise_config
      generate_cms_content
    when :authlogic
      generate_cms_admin
      correct_user_fixtures
      generate_cms_content
    end
    skip :require, "test/suit_application/rich/i18n_forgery.rb"
  end

  def restore_files
    delete  "config/locales/devise.en.yml"
    delete  "db/migrate/*.rb"
    delete  "test/fixtures/cms_contents.yml"
    delete  "test/fixtures/devise_users.yml"
    delete  "test/unit/cms_content_test.rb"
    delete  "test/unit/devise_user_test.rb"
    restore "test/fixtures/**/rails-*.yml.#{STASHED_EXT}"
  end

  def stash_files
    delete "db/migrate/*.rb"
    stash  "app/models/*.rb"
    stash  "config/initializers/devise.rb"
    stash  "config/initializers/enrichments.rb"
    stash  "test/fixtures/**/rails-*.yml"
  end

  def locals_for_template(path)
    case path
    when "Gemfile"
      auth_gem = case logic
                 when :devise
                   v = rails_version == 2 ? "1.0.9" : "~> 1.1.5"
                   "gem \"devise\", \"#{v}\""
                 when :authlogic
                   "gem \"authlogic\""
                 end
      {:authentication_gem => auth_gem}
    when "config/initializers/enrichments.rb"
      klass = "#{logic.to_s.capitalize}User" if [:devise, :authlogic].include? logic
      {:logic => logic, :klass => klass}
    when "db/schema.rb"
      schema = File.read(File.expand_path("../suit_application/active_record_schema", __FILE__)) if config[:moneta] == "active_record"
      {:schema => schema}
    end
  end

private

  def logic
    config[:logic] || :devise
  end

  def generate_cms_admin
    return unless [:devise, :authlogic].include? logic

    klass  = "#{logic.to_s.capitalize}User"
    option = {:devise => "-d", :authlogic => "-a"}[logic]

    generate generator_for(:admin), klass, option
  end

  def correct_user_fixtures
    if File.exists? expand_path(path = "test/fixtures/#{logic}_users/rails-#{rails_version}.yml.#{STASHED_EXT}")
      copy path, "test/fixtures/#{logic}_users.yml"
    end
  end

  def correct_devise_config
    return unless logic == :devise

    case rails_version
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
    generate generator_for(:content), "CmsContent"
  end

  def generator_for(type)
    case rails_version
    when 2
      "rich_cms_#{type}"
    when 3
      "rich:cms_#{type}"
    end
  end

end