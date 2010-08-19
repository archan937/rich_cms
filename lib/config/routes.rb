# Redefine clear! method to do nothing (usually it erases the routes)
class << ActionController::Routing::Routes;self;end.class_eval do
  define_method :clear!, lambda {}
end

ActionController::Routing::Routes.draw do |map|

  map.namespace :rich, :path_prefix => "" do |rich|
    
    %w(login logout update).each do |action|
      rich.send "cms_#{action}", "cms/#{action}", :controller => "cms", :action => action
    end
    
    rich.connect  "cms"           , :controller => "cms", :action => "display"                     , :display => true
    rich.connect  "cms_menu"      , :controller => "cms", :action => "display", :element => "menu" , :display => true
    rich.connect  "cms_panel"     , :controller => "cms", :action => "display", :element => "panel", :display => true
    rich.cms_hide "cms/hide"      , :controller => "cms", :action => "display"                     , :display => false
    rich.connect  "cms_menu/hide" , :controller => "cms", :action => "display", :element => "menu" , :display => false
    rich.connect  "cms_panel/hide", :controller => "cms", :action => "display", :element => "panel", :display => false
    
  end

end