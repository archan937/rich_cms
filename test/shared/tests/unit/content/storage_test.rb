require File.expand_path("../../../test_helper.rb"      , __FILE__)

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

          should "return the expected default value" do
            assert "header"  , Content.find("header"            ).send(:default_value)
            assert "header"  , Content.find("home.index.header" ).send(:default_value)
            assert "about me", Content.find("about_me"          ).send(:default_value)
            assert "save as" , Content.find("attachment.save_as").send(:default_value)
          end

          should "be able to read / write values" do
            content = Content.find(@key)
            content.value = @value
            content.save

            assert_equal @value, Content.find(@key).value
          end

          context "when having created an instance" do
            setup do
              @content = Content.new :key => @key, :value => @value
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
                Auth.expects(:login_required?).at_least_once.returns(true)
              end

              should "not be able to be saved and destroyed when not being logged in" do
                assert !@content.save
                assert_equal("header", Content.find(@key).value)
                assert !@content.destroy
              end

              should "be able to be saved and destroyed when allowed" do
                Auth.expects(:admin).at_least_once.returns(User.new)

                assert @content.save
                assert_equal(@value, Content.find(@key).value)
                assert @content.destroy
              end

              should "not be able to be saved and destroyed when restricted" do
                Auth.expects(:admin).at_least_once.returns(user = User.new)
                user.stubs(:can_edit?).returns(false)

                assert !@content.save
                assert_equal("header", Content.find(@key).value)
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
            assert "header"  , Translation.find("nl:header"            ).send(:default_value)
            assert "header"  , Translation.find("nl:home.index.header" ).send(:default_value)
            assert "about me", Translation.find("nl:about_me"          ).send(:default_value)
            assert "save as" , Translation.find("nl:attachment.save_as").send(:default_value)
          end

          should "be able to read / write values" do
            key, value = "header", "Welcome to Rich-CMS"

            translation = Translation.find key
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