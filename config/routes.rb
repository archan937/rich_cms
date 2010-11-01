Rails.application.routes.draw do

  # rich_cms_login  /cms/login                         {:controller=>"rich/cms", :action=>"login"}
  scope :module => 'rich' do
    %w(login logout update).each do |action|
      match "/cms/#{action}" => "cms##{action}", :as => "rich_cms_#{action}"
    end
    match '/cms/' => 'cms#display', :as => 'rich_cms', :display => true
    match '/cms/hide' => 'cms#display', :as => 'rich_cms_hide', :display => false
    match '/cms/position' => 'cms#position', :as => 'rich_cms_position'
  end

end

