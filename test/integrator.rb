STDOUT.sync = true

module Integrator
  extend self

  def run(&block)
    tester = Tester.new
    yield tester
    tester.summarize
  end

private

  MAJOR_RAILS_VERSIONS = [2, 3]
  DESCRIPTION_MATCH    = /^Setting up integration test: (.*)$/
  TIME_MATCH           = /^Finished in (.+) seconds\.$/
  SUMMARY_MATCH        = /^(\d+) (\w+), (\d+) (\w+), (\d+) (\w+), (\d+) (\w+)$/

  class Tester
    def initialize
      @output = []
    end

    def test_all
      MAJOR_RAILS_VERSIONS.each{|version| test_rails version}
    end
    alias_method :all, :test_all

    def test_rails(major_version)
      %w(non_authenticated authenticated/devise_test authenticated/authlogic).each do |file|
        run "ruby test/rails-#{major_version}/rich_cms/app/integration/#{file}.rb"
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
          tests << [$1.gsub(DESCRIPTION_MATCH, ""), {}]
        end
        if line.match(TIME_MATCH)
          tests[-1][-1][:time] = $1
        end
        if line.match(SUMMARY_MATCH)
          tests[-1][-1][$2.to_sym] = $1
          tests[-1][-1][$4.to_sym] = $3
          tests[-1][-1][$6.to_sym] = $5
          tests[-1][-1][$8.to_sym] = $7
        end
        tests
      end

      return if integration_tests.size == 0

      keys = [:time, :tests, :assertions, :failures, :errors]

      puts "========================================================="
      puts "\n"
      puts "Integration test results"
      integration_tests.each do |description, stats|
        puts "---------------------------------------------------------"
        puts "  Description".ljust(18, ".") + ": #{description}"
        stats.values_at(*keys).each_with_index do |value, index|
          puts "  #{keys[index].to_s.capitalize}".ljust(18, ".") + ": #{value}"
        end
        puts "\n"
      end
      puts "========================================================="
    end
  end

end