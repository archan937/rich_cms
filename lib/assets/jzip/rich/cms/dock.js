
Rich.Cms.Dock = (function() {
  var bind = function() {
    $("#rich_cms_dock").draggable({
      helper: "clone",
      handle: "#rich_cms_menu li:first",
      drag: function(event, ui) {
        var x = ui.position.left + (ui.helper.width()  / 2);
        var y = ui.position.top  + (ui.helper.height() / 2);
        
        var x_div = $(window).width()  / 3;
        var y_div = $(window).height() / 2;
        
        if (x < x_div) {
          $("#rich_cms_dock")   .addClass("left").removeClass("middle").removeClass("right");
        } else if (x > (x_div * 2)) {
          $("#rich_cms_dock").removeClass("left").removeClass("middle")   .addClass("right");
        } else {
          $("#rich_cms_dock").removeClass("left").   addClass("middle").removeClass("right");
        }
        
        if (y < y_div) {
          $("#rich_cms_dock")   .addClass("top").removeClass("bottom");
        } else {
          $("#rich_cms_dock").removeClass("top").addClass("bottom");
        }
      }
    });
  };
  
  return {
    init: function() {
      bind();
    }
  };
}());
