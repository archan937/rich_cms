require File.expand_path("../../test_helper.rb", __FILE__)

class ContentTest < ActiveSupport::TestCase

  context "A Rich-CMS content class" do
    should "require the moneta store lib on setup" do
      assert_nothing_raised LoadError do
        class ContentMemory
          include Rich::Cms::Content
          setup :memory
        end
      end
      assert_raise LoadError do
        class ContentFoo
          include Rich::Cms::Content
          setup :foo
        end
      end
    end

    context "using on the memory cache engine" do
      setup do
        class Content
          include Rich::Cms::Content
          setup :memory
        end
        Content.clear
      end

      should "have Moneta::Memory as cache" do
        assert Content.send(:cache).is_a?(Moneta::Memory)
      end

      should "be able to read / write values" do
        key, value = :some_key, "foobar"
        Content[key] = value
        assert_equal Content[key], value
      end

      context "when having created an instance" do
        setup do
          @content = Content.new
        end

        should "respond to all excepted methods" do
          assert @content.respond_to?(:default_value)
          assert @content.respond_to?(:to_tag)
        end
      end
    end
  end

end