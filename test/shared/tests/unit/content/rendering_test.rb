require File.expand_path("../../../test_helper.rb", __FILE__)
require "hpricot"

module Content
  class RenderingTest < ActiveSupport::TestCase

    context "A Rich-CMS content class" do
      context "using the memory store engine" do

        setup do
          class Foo
            include Rich::Cms::Content
            storage :memory
            configure :as => :html
          end
          class Bar
            include Rich::Cms::Content
            storage   :memory
            configure ".bar_content", :tag => :h1
          end
          forge_rich_i18n

          @javascript_hashes = ActiveSupport::OrderedHash.new
          @javascript_hashes[Bar        ] = %Q({identifier: ["data-key"], value: "data-value"})
          @javascript_hashes[Foo        ] = %Q({identifier: ["data-key"], value: "data-value"})
          @javascript_hashes[Translation] = %Q({identifier: ["data-key", "data-locale"], value: "data-value", beforeEdit: Rich.I18n.beforeEdit, afterUpdate: Rich.I18n.afterUpdate})
        end

        should "be configurable" do
          assert_equal ".rcms_foo"    , Foo.css_selector
          assert_equal ".bar_content" , Bar.css_selector
          assert_equal({:as  => :html}, Foo.config)
          assert_equal({:tag => :h1  }, Bar.config)
        end

        should "return the expected javascript hash (per CMS content class)" do
          assert_equal @javascript_hashes[Foo        ], Foo.to_javascript_hash
          assert_equal @javascript_hashes[Bar        ], Bar.to_javascript_hash
          assert_equal @javascript_hashes[Translation], Translation.to_javascript_hash
        end

        should "return the expected CSS selector" do
          assert_equal ".bar_content"     , Bar.css_selector
          assert_equal ".rcms_foo"        , Foo.css_selector
          assert_equal ".rcms_translation", Translation.css_selector
        end

        should "return the expected javascript hash (for all CMS content classes)" do
          expected = @javascript_hashes.collect{|klass, value| "#{klass.css_selector}: #{value}"}.join ", "
          assert_equal "{#{expected}}", Rich::Cms::Content.javascript_hash
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