ActionController::Routing::Routes.draw do |map|

  map.namespace :rich, :path_prefix => "" do |rich|
    
    rich.cms_root "cms", :controller => "cms", :action => "show"
    %w(hide login logout update).each do |action|
      rich.send "cms_#{action}", "cms/#{action}", :controller => "cms", :action => action
    end
    
  end

end