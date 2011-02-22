require File.expand_path("../../test_helper.rb", __FILE__)

class ContentTest < ActiveSupport::TestCase

  context "A Rich-CMS content class" do

    setup do
      forge_rich_i18n
      class Content
        include Rich::Cms::Content
        storage :memory
      end
    end

    should "keep track of it's classes" do
      assert_equal [Content, Translation], Rich::Cms::Content.classes
    end

    should "be able to fetch the correct content item based on passed parameters" do
      Content    .new(:key => "header", :value  => "Welcome to Rich-CMS" ).save
      Translation.new(:key => "hello" , :locale => :nl, :value => "hallo").save

      assert_equal "Welcome to Rich-CMS", Rich::Cms::Content.fetch(".rcms_content"    , :key => "header").value
      assert_equal "hallo"              , Rich::Cms::Content.fetch(".rcms_translation", :key => "hello", :locale => :nl).value
    end

    should "raise an error while passing invalid parameters to fetch CMS content" do
      assert_raise ArgumentError do
        Rich::Cms::Content.fetch(".rcms_content")
      end
      assert_raise ArgumentError do
        Rich::Cms::Content.fetch(:key => "hello", :locale => :nl)
      end
    end

  end

end