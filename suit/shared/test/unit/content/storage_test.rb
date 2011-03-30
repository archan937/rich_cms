require File.expand_path("../../../test_helper.rb", __FILE__)

module Content
  class StorageTest < ActiveSupport::TestCase

    context "A Rich-CMS content class" do
      should "require the moneta store lib on setup" do
        assert_nothing_raised LoadError do
          class ContentWithInMemoryStorage
            include Rich::Cms::Content
            storage :memory
          end
        end
        assert_raise LoadError do
          class ContentWithFooStorage
            include Rich::Cms::Content
            storage :foo
          end
        end
      end

      context "using the memory store engine" do
        context "as default content" do
          setup do
            class Content
              include Rich::Cms::Content
              storage :memory
            end

            Content.send(:content_store).clear

            @key, @value = "header", "Welcome to Rich-CMS"
          end

          should "have Moneta::Memory as store" do
            assert Content.send(:content_store).is_a?(Moneta::Memory)
          end

          should "be able to read / write values" do
            content = Content.new(@key)
            content.value = @value
            content.save

            assert_equal @value, Content.find(@key).value
          end

          context "when having passed alternatives for finding content" do
            setup do
              Content.send(:content_store).clear
              @args = ["label.(registration_form).User.email_address", "label.User.email_address", "label.email_address", "email_address"]
            end

            should "not raise an error" do
              assert_nothing_raised do
                Content.find *@args
              end
            end

            should "return nil when not having matched any of the passed identifiers" do
              assert_nil Content.find(*@args)
            end

            should "return the first matching content" do
              Content.new(:key => "email_address", :value => "E-mailadres").save
              assert_equal Content.find("email_address"), Content.find(*@args)

              Content.new(:key => "label.email_address", :value => "Uw e-mailadres").save
              assert_equal Content.find("label.email_address"), Content.find(*@args)
            end

            should "return a new instance when having found none of the passed identifiers and having passed a default" do
              assert_equal Content.new(:key => "label.email_address"),
                           Content.find("label.(registration_form).User.email_address", "label.User.email_address", {"label.email_address" => :is_default}, "email_address")
            end
          end

          context "when having created an instance" do
            setup do
              @content = Content.new :key => @key, :value => @value
            end

            should "return the expected default value" do
              assert_equal "header"  , Content.new(:key => "header"            ).send(:default_value)
              assert_equal "header"  , Content.new(:key => "home.index.header" ).send(:default_value)
              assert_equal "about me", Content.new(:key => "about_me"          ).send(:default_value)
              assert_equal "save as" , Content.new(:key => "attachment.save_as").send(:default_value)
            end

            should "memoize the default value" do
              content = Content.new :key => "header"
              content.expects(:default_value).once.returns("header")
              content.value
              content.value
            end

            context "when having called save_and_return" do
              should "be able to save and return itself when successful" do
                content = Content.new(:key => @key, :value => @value).save_and_return
                assert content
              end

              should "return nil when trying to save itself but failing" do
                Content.any_instance.expects(:editable?).returns(false)
                content = Content.new(:key => @key, :value => @value).save_and_return
                assert_nil content
              end
            end

            context "when no login required" do
              should "be able to be saved and destroyed" do
                assert @content.save
                assert_equal(@value, Content.find(@key).value)
                assert @content.destroy
              end
            end

            context "when requiring a logged in admin" do
              setup do
                class User
                  def can_edit?(content)
                    true
                  end
                end
                Rich::Cms::Auth.expects(:login_required?).at_least_once.returns(true)
              end

              should "not be able to be saved and destroyed when not being logged in" do
                assert !@content.save
                assert_nil Content.find(@key)
                assert !@content.destroy
              end

              should "be able to be saved and destroyed when allowed" do
                Rich::Cms::Auth.expects(:admin).at_least_once.returns(User.new)

                assert @content.save
                assert_equal(@value, Content.find(@key).value)
                assert @content.destroy
              end

              should "not be able to be saved and destroyed when restricted" do
                Rich::Cms::Auth.expects(:admin).at_least_once.returns(user = User.new)
                user.stubs(:can_edit?).returns(false)

                assert !@content.save
                assert_nil Content.find(@key)
                assert !@content.destroy
              end
            end
          end
        end

        context "as content with a combined identifier (e.g. Translation)" do
          setup do
            forge_rich_i18n
          end

          should "return the expected default value" do
            delimiter = Translation.delimiter
            assert_equal "header"  , Translation.new("nl#{delimiter}header"            ).send(:default_value)
            assert_equal "header"  , Translation.new("nl#{delimiter}home.index.header" ).send(:default_value)
            assert_equal "about me", Translation.new("nl#{delimiter}about_me"          ).send(:default_value)
            assert_equal "save as" , Translation.new("nl#{delimiter}attachment.save_as").send(:default_value)
          end

          should "be able to read / write values" do
            key, value = "header", "Welcome to Rich-CMS"

            translation = Translation.new key
            translation.value = value
            assert translation.save

            assert_equal value, Translation.find(key).value
            assert translation.destroy
          end
        end
      end
    end

  end
end