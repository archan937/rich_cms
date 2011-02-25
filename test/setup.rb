STDOUT.sync = true

module TestSetup
  extend self

  def run
    bundle_install_rails 3
    bundle_install_rails 2
    ask_mysql_password
    create_test_database
    print_final_word
  end

private

  def root_dir
    @root_dir ||= File.expand_path("../..", __FILE__)
  end

  def bundle_install_rails(version)
    cmd = "cd #{root_dir}/test/rails-#{version}/dummy && bundle install"
    guts "Running 'bundle install' for the Rails #{version} dummy app (this can take several minutes)"
    puts cmd
    `#{cmd}`
  end

  def ask_mysql_password
    guts "Setting up the MySQL test database"
    puts "To be able to run integration tests (with Capybara in Firefox) we need to store your MySQL password in a git-ignored file (test/shared/mysql)"
    puts "Please provide the password of your MySQL root user: (press Enter when blank)"

    begin
      system "stty -echo"
      password = STDIN.gets.strip
    ensure
      system "stty echo"
    end

    file = File.expand_path("test/shared/mysql", root_dir)
    if password.length == 0
      File.delete file if File.exists? file
    else
      File.open(file, "w"){|f| f << password}
      puts "\n"
    end
  end

  def create_test_database
    guts "Creating the test database"
    puts "cd #{root_dir}/test/rails-3/dummy && RAILS_ENV=test rake db:create"

    require File.expand_path("test/rails-3/dummy/test/support/dummy_app.rb", root_dir)
    DummyApp.create_test_database
  end

  def print_final_word
    guts "Create your Firefox 'capybara' profile if you haven't done it yet"
    puts "Run the following in your console to start the profile manager and create the 'capybara' profile:"
    yuts "[Mac]   $ /Applications/Firefox.app/Contents/MacOS/firefox-bin -profilemanager"
    yuts "[Linux] $ cd <appdir> && ./firefox -profilemanager"

    guts "Done setting up the Rich-CMS test suite! ^^"
  end

  def guts(text)
    puts "\e[1m\e[32m#{text}\e[0m"
  end

  def yuts(text)
    puts "\e[1m\e[33m#{text}\e[0m"
  end

end