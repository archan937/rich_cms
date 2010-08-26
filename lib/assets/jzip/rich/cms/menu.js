
Rich.Cms.Menu = (function() {
  var bind = function() {
    $("#rich_cms_menu a.mark").bind("click", Rich.Cms.Editor.mark);
  };
  
  var register = function() {
    RaccoonTip.register("#rich_cms_menu a.login", "#rich_cms_panel", 
                        {beforeShow: function(target) { target.show(); },
                         afterHide : function(target) { target.hide(); }});
  };
  
  return {
    init: function() {
      bind();
      register();
    }
  };
}());
