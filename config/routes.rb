if Rails::VERSION::MAJOR >= 3

  Rails.application.routes.draw do
    scope :module => "rich" do
      %w(login logout update).each do |action|
        match "/cms/#{action}" => "cms##{action}", :as => "rich_cms_#{action}"
      end
      match "/cms/"         => "cms#display", :as => "rich_cms"     , :display => true
      match "/cms/hide"     => "cms#display", :as => "rich_cms_hide", :display => false
      match "/cms/position" => "cms#position"
    end
  end

else

  # TODO: add routes the right way as this is evil
  class << ActionController::Routing::Routes;self;end.class_eval do
    define_method :clear!, lambda {}
  end
  # END

  ActionController::Routing::Routes.draw do |map|
    map.namespace :rich, :path_prefix => "" do |rich|
      %w(login logout update).each do |action|
        rich.send "cms_#{action}", "cms/#{action}", :controller => "cms", :action => action
      end
      rich.cms      "cms"         , :controller => "cms", :action => "display", :display => true
      rich.cms_hide "cms/hide"    , :controller => "cms", :action => "display", :display => false
      rich.connect  "cms/position", :controller => "cms", :action => "position"
    end
  end

end