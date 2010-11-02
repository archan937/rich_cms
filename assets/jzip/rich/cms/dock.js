
Rich.Cms.Dock = (function() {
  var bind = function() {
    if (!$.ie6) {
      makeDraggable();
    }
  };

  var makeDraggable = function() {
    $("#rich_cms_dock").draggable({
      helper: "clone",
      handle: "#rich_cms_menu li:first",
      start: function(event, ui) {
        $("#x1,#x2,#y1,#x,#y").addClass("display");
      },
      drag: function(event, ui) {
        var x     = event.pageX;
        var y     = event.pageY;
        var x_div = $(window).width()  / 3;
        var y_div = $(window).height() / 2;

        $("#x" ).css({left: x        });
        $("#y" ).css({top : y        });
        $("#x1").css({left: x_div    });
        $("#x2").css({left: x_div * 2});
        $("#y1").css({top : y_div    });

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
      },
      stop: function(event, ui) {
        $("#x1,#x2,#y1,#x,#y").removeClass("display");
        $.ajax({
          url: "/cms/position",
          data: {
            position: $.grep(($("#rich_cms_dock").attr("class") || "").split(" "), function(c) {
                        return $.inArray(c, ["top", "bottom", "left", "middle", "right"]);
                      }).join(" ")
          }
        });
      }
    });
  };

  return {
    init: function() {
      bind();
    }
  };
}());
