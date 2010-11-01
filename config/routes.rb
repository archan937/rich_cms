Rails.application.routes.draw do

  namespace 'rich' do
    %w(login logout update).each do |action|
      match "/cms/#{action}" => "cms##{action}"
    end
    match '/cms' => 'cms#display', :display => true
    match '/cms/hide' => 'cms#display', :display => false
    match '/cms/position' => 'cms#position'
  end

end

