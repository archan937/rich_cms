Rich::Cms::Auth.setup do |config|
<% if logic && klass %>
  config.logic = <%= logic %>
  config.klass = <%= klass %>
<% end %>
end