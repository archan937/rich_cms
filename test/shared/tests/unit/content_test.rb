require File.expand_path("../../test_helper.rb", __FILE__)

class ContentTest < ActiveSupport::TestCase

  context "A Rich-CMS content class" do
    setup do
      @key, @value = "hello", "hallo"
    end

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
          class User
            def can_edit?(content)
              true
            end
          end
          class Content
            include Rich::Cms::Content
            setup :memory
          end
          Content.send(:cache).clear
        end

        should "have Moneta::Memory as cache" do
          assert Content.send(:cache).is_a?(Moneta::Memory)
        end

        should "be able to read / write values" do
          key, value    = :some_key, "foobar"
          content       = Content.find(key)
          content.value = value
          content.save
          assert_equal value, Content.find(key).value
        end

        should "return the correct default value" do
          assert "header"  , Content.find("header").default_value
          assert "header"  , Content.find("home.index.header").default_value
          assert "about me", Content.find("about_me").default_value
          assert "save as" , Content.find("attachment.save_as").default_value
        end

        context "when having created an instance" do
          setup do
            @content = Content.new
          end

          should "respond to all excepted methods" do
            assert @content.respond_to?(:editable?)
            assert @content.respond_to?(:save)
            assert @content.respond_to?(:default_value)
            assert @content.respond_to?(:to_tag)
          end

          context "when requiring a logged in admin" do
            setup do
              Auth.expects(:login_required?).at_least_once.returns(true)
            end

            should "be able to be saved and destroyed" do
              Auth.expects(:admin).at_least_once.returns(User.new)

              @content.key   = @key
              @content.value = @value
              assert @content.save
              assert_equal(@value, Content.find(@key).value)
              assert @content.destroy
            end

            should "be not able to be saved and destroyed when restricted" do
              Auth.expects(:admin).at_least_once.returns(user = User.new)
              user.stubs(:can_edit?).returns(false)

              @content.key   = @key
              @content.value = @value
              assert !@content.save
              assert_equal({}, Content.find(@key).value)
              assert !@content.destroy
            end

            should "be not able to be saved and destroyed when login is required while not being logged in" do
              @content.key   = @key
              @content.value = @value
              assert !@content.save
              assert_equal({}, Content.find(@key).value)
              assert !@content.destroy
            end
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
          Translation.send(:cache).clear
        end

        should "be able to override passed keys" do
          Translation.send(:cache).expects(:[]).with("#{I18n.locale}:#{@key}")
          Translation.send(:cache).expects(:store).with("#{I18n.locale}:#{@key}", @value)

          translation = Translation.find @key
          translation.value = @value
          translation.save
        end

        should "be able to read / write values" do
          translation = Translation.find @key
          translation.value = @value
          translation.save
          assert_equal @value, Translation.find(@key).value
        end
      end
    end
  end

end