
Rich.Cms.Menu = (function() {
  var login_panel = "#rich_cms_panel .login";
      
  var bind = function() {
    $("#rich_cms_menu a.login").bind("click", function() {
      $(login_panel).show();
    });
    $("#rich_cms_menu a.mark" ).bind("click", Rich.Cms.Editor.mark);
  };
  
  return {
    init: function() {
      bind();
    }
  };
}());
