module Test
  module Unit
    class TestCase
      @@pending_cases = []
      @@at_exit = false

      # The pending method lets you define a block of test code that is currently "pending"
      # functionality.
      #
      # You can use it two ways.  One is simply put a string as the parameter:
      #
      #   def test_web_service_integration
      #     pending "This is not done yet..."
      #   end
      #
      # This will output a "P" in the test output alerting there is pending functionality.
      #
      # You can also supply a block of code:
      #
      #   def test_new_helpers
      #     pending "New helpers for database display" do
      #       output = render_record(User.first)
      #       assert_equal "Jerry User (jerry@users.com)", output
      #     end
      #   end
      #
      # If the block doesn't fail, then the test will flunk with output like:
      #
      #   <New helpers for database display> did not fail.
      #
      # If the test fails (i.e., the functionality isn't implemented), then it will
      # not fail the surrounding test.
      #
      def pending(description = "", &block)
        if block_given?
          failed = false

          begin
            block.call
          rescue
            failed = true
          end

          flunk("<#{description}> did not fail.") unless failed
        end

        caller[0] =~ (/(.*):(.*):in `(.*)'/)
        @@pending_cases << "#{$3} at #{$1}, line #{$2}"
        print "P"

        @@at_exit ||= begin
          at_exit do
            puts "\nPending Cases:"
            @@pending_cases.each do |test_case|
              puts test_case
            end
          end
        end
      end

      # This method will define a test method using the description as the test name
      # ("pending function" => "test_pending_function")
      #
      # Instead of doing this:
      #
      # def test_function_is_pending
      #   pending "this test is pending"
      # end
      #
      # You can just do this:
      #
      # pending "function is pending"
      #
      # This method can be called with a block passed, the same as the instance method
      #
      def self.pending(description, &block)
        test_name = "test_#{description.gsub(/\s+/,'_')}".to_sym
        defined = instance_method(test_name) rescue false
        raise "#{test_name} is already defined in #{self}" if defined
        define_method(test_name) do
          pending(description) {self.instance_eval(&block)}
        end
      end
    end
  end
end