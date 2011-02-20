require File.expand_path("../../../test_helper.rb", __FILE__)

module Content
  class BaseTest < ActiveSupport::TestCase

    context "A Rich-CMS content class" do

      setup do
        class Content
          include Rich::Cms::Content
          storage :memory
        end
      end

      should "keep track of it's attr_accessors" do
        assert [:key, :value], Content.send(:attr_accessors)
      end

      should "not raise an error when passing a valid hash or not passing anything on initialization" do
        assert_nothing_raised do
          Content.new
          Content.new :key => "foo"
          Content.new :key => "foo", :value => "bar"
        end
      end

      should "raise an error when passing an invalid hash on initialization" do
        assert_raise ArgumentError do
          Content.new :foo => "bar"
        end
      end

      context "when having created an instance" do
        setup do
          @content = Content.new :key => "hello", :value => "hallo"
        end

        context "when no login required" do
          should "be editable when no login required which is default" do
            assert @content.editable?
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

          should "not be editable when not being logged in" do
            assert !@content.editable?
          end

          should "be editable when allowed" do
            Auth.expects(:admin).at_least_once.returns(User.new)
            assert @content.editable?
          end

          should "not be editable when restricted" do
            Auth.expects(:admin).at_least_once.returns(user = User.new)
            user.stubs(:can_edit?).returns(false)
            assert !@content.editable?
          end
        end
      end

    end

  end
end