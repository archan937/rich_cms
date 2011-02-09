require File.expand_path("../../test_helper.rb", __FILE__)

class RoutingTest < ActionController::TestCase

  test "rich_cms" do
    assert_routing     "/cms", :controller => "rich/cms", :action => "display", :display => true
    assert_named_route "/cms", :rich_cms
  end

  test "rich_cms_hide" do
    assert_routing     "/cms/hide", :controller => "rich/cms", :action => "display", :display => false
    assert_named_route "/cms/hide", :rich_cms_hide
  end

  %w(login logout).each do |action|
    test "rich_cms_#{action}" do
      assert_routing     "/cms/#{action}", :controller => "rich/cms_sessions", :action => action
      assert_named_route "/cms/#{action}", :"rich_cms_#{action}"
    end
  end

  %w(position update).each do |action|
    test "rich_cms_#{action}" do
      assert_routing     "/cms/#{action}", :controller => "rich/cms", :action => action
      assert_named_route "/cms/#{action}", :"rich_cms_#{action}"
    end
  end

end