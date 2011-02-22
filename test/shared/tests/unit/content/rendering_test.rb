require File.expand_path("../../../test_helper.rb", __FILE__)
require "hpricot"

module Content
  class RenderingTest < ActiveSupport::TestCase

    context "A Rich-CMS content class" do
      context "using the memory store engine" do

        setup do
          class Content
            include Rich::Cms::Content
            storage :memory
          end

          Content.send(:content_store).clear

          @key, @value = "header", "Welcome to Rich-CMS"
          @content     = Content.new(:key => @key, :value => @value).save_and_return
        end

        should "return the expected CSS selector" do
          class Foo
            include Rich::Cms::Content
            storage :memory
          end
          class Bar
            include Rich::Cms::Content
            storage      :memory
            css_selector "#foo .bar"
          end

          assert_equal ".rcms_content", Content.css_selector
          assert_equal ".rcms_foo"    , Foo.css_selector
          assert_equal "#foo .bar"    , Bar.css_selector
        end

        should "be configurable" do
          class Foo
            include Rich::Cms::Content
            storage :memory
            configure ".foo_content", :as => :html
          end
          class Bar
            include Rich::Cms::Content
            storage   :memory
            configure :tag => :h1
          end

          assert_equal ".foo_content" , Foo.css_selector
          assert_equal ".rcms_bar"    , Bar.css_selector
          assert_equal({:as  => :html}, Foo.config)
          assert_equal({:tag => :h1  }, Bar.config)
        end

        context "when no login required" do
          should "render meta data" do
            # assert
          end
        end

        context "when requiring a logged in admin" do
          setup do
            class User
              def can_edit?(content)
                true
              end
            end
            # Auth.expects(:login_required?).at_least_once.returns(true)
          end

          should "not render meta data when not being logged in" do
            class Content
              include Rich::Cms::Content
              storage :memory
            end
            # assert
          end

          should "render meta data when allowed" do
            # Auth.expects(:admin).at_least_once.returns(User.new)
            # assert
          end

          should "not render meta data when restricted" do
            # Auth.expects(:admin).at_least_once.returns(user = User.new)
            # user.stubs(:can_edit?).returns(false)
            # assert
          end
        end

      end
    end

  end
end