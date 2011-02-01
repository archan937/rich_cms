require File.expand_path("../../../../test_helper.rb", __FILE__)

module Activesupport
  module ActiveSupport
    class DependenciesTest < ::ActiveSupport::TestCase

      context "ActiveSupport::Dependencies" do
        should "respond to :autoload_paths" do
          assert ::ActiveSupport::Dependencies.respond_to? :autoload_paths
        end
      end

    end
  end
end