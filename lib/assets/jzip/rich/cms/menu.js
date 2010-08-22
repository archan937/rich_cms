
Rich.Cms.Menu = (function() {
  var bind = function() {
    bindLogin();
    bindMark();
  };
  
  var bindLogin = function() {
    $("#rich_cms_menu a.login").click(function() {
      Rich.Cms.Qtip.show($(this), "#rich_cms_panel .login");
    });
  };
  
  var bindMark = function() {
    $("#rich_cms_menu a.mark" ).bind("click", Rich.Cms.Editor.mark);
  };
  
  return {
    init: function() {
      bind();
    }
  };
}());
