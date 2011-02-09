STDOUT.sync = true

module Integrator
  extend self

  def run(&block)
    Tester.new.execute &block
  end

private

  MAJOR_RAILS_VERSIONS = [2, 3]
  DESCRIPTION_MATCH    = /^Setting up test environment for (.*)$/
  TIME_MATCH           = /^Finished in (.*)\.$/
  SUMMARY_MATCH        = /^(\d+) (\w+), (\d+) (\w+), (\d+) (\w+), (\d+) (\w+)$/

  class Tester
    def initialize
      @output = []
    end

    def execute(&block)
      @start = Time.now
      yield self
      @end   = Time.now
      summarize
    end

    def test_all
      MAJOR_RAILS_VERSIONS.each{|version| test_rails version}
    end
    alias_method :all, :test_all

    def test_rails(major_version)
      %w(non_authenticated authenticated/devise_test authenticated/authlogic).each do |file|
        run "ruby test/rails-#{major_version}/dummy/test/integration/#{file}.rb"
      end
    end
    alias_method :rails, :test_rails

    def run(command)
      IO.popen(command) do |io|
        until io.eof?
          puts (@output << io.gets).last
        end
      end
    end

    def summarize
      integration_tests = @output.inject([]) do |tests, line|
        if line.match(DESCRIPTION_MATCH)
          tests << {:description => $1.gsub(DESCRIPTION_MATCH, "")}
        end
        if line.match(TIME_MATCH)
          tests.last[:time] = $1
        end
        if line.match(SUMMARY_MATCH)
          tests.last[:summary ] = line
          tests.last[$2.to_sym] = $1
          tests.last[$4.to_sym] = $3
          tests.last[$6.to_sym] = $5
          tests.last[$8.to_sym] = $7
        end
        tests
      end

      return if integration_tests.size == 0

      keys     = [:time, :tests, :assertions, :failures, :errors]
      failures = integration_tests.inject(0) do |count, test|
                   count += 1 if test[:failures].to_i + test[:errors].to_i > 0
                   count
                 end

      puts "\n"
      puts "".ljust(70, "=")
      puts "Integration tests (#{failures} failures in #{@end - @start} seconds)"
      integration_tests.each do |test|
        puts ""             .ljust(70, "-")
        puts "  Description".ljust(16, ".") + ": #{test[:description]}"
        puts "  Duration"   .ljust(16, ".") + ": #{test[:time]       }"
        puts "  Summary"    .ljust(16, ".") + ": #{test[:summary]    }"
      end
      puts "".ljust(70, "=")
      puts "\n"
    end
  end

end