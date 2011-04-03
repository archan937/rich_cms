Rich.Cms.Menu = (function() {
  var bind = function() {
    $("#rich_cms_menu a.mark").bind("click", Rich.Cms.Editor.mark);
  };

  var register = function() {
    RaccoonTip.register("#rich_cms_menu a.login", "#rich_cms_panel",
                        {beforeShow: function(content) { content.show(); },
                         afterHide : function(content) { content.hide(); }});
  };

  return {
    init: function() {
      bind();
      register();
    }
  };
}());