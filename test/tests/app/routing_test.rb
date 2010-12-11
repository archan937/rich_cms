require File.expand_path("../../../test_helper.rb", __FILE__)

module App
  class RoutingTest < ActionController::TestCase

    %w(login logout update).each do |action|
      test "rich_#{action}" do
        assert_routing     "/cms/#{action}", :controller => "rich/cms", :action => action
        assert_named_route "/cms/#{action}", :"rich_cms_#{action}"
      end
    end

    test "rich_cms" do
      assert_routing     "/cms", :controller => "rich/cms", :action => "display", :display => true
      assert_named_route "/cms", :rich_cms
    end

    test "rich_cms_hide" do
      assert_routing     "/cms/hide", :controller => "rich/cms", :action => "display", :display => false
      assert_named_route "/cms/hide", :rich_cms_hide
    end

    test "cms/position" do
      assert_routing "/cms/position", :controller => "rich/cms", :action => "position"
    end

  end
end