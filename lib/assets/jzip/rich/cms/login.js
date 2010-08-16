
Rich.Cms.Login = (function() {
  var login_panel = "#rich_cms_bar .panel .login";
  
  return {
    init: function() {
      $("#rich_cms_bar .menu a.login").bind("click", function() {
        $(login_panel).show();
      });
    }
  };
}());
