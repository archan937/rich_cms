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
      context "as simple Rich-CMS content" do
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
          assert_equal value, Content[key]
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

      context "as Rich-CMS content with an overriden key (e.g. Translation)" do
        setup do
          class I18n
            cattr_accessor :default_locale, :locale
            @@default_locale = :nl
            def self.locale
              @@locale || @@default_locale
            end
            def self.t(key)
              {:nl => {:world => "wereld"}}[locale.to_sym][key.to_sym]
            end
          end
          class Translation
            include Rich::Cms::Content
            setup :memory
          protected
            def self.key_for(key)
              "#{I18n.locale}:#{key}"
            end
          end
          Translation.clear
          @key, @value = "hello", "hallo"
        end

        should "be able to override passed keys" do
          Translation.send(:cache).expects(:[]).with("#{I18n.locale}:#{@key}")
          Translation[@key]
          Translation.send(:cache).expects(:[]=).with("#{I18n.locale}:#{@key}", @value)
          Translation[@key] = @value
        end

        should "be able to read / write values" do
          Translation[@key] = @value
          assert_equal @value, Translation[@key]
        end
      end
    end
  end

end