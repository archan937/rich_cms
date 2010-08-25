
RaccoonTip = (function() {
  var html = '<div id="raccoon_tip" class="rt_top_left" style="display: none"><div class="rt_arrow"></div><div class="rt_content"></div></div>';
  var css  = '<style type="text/css" media="screen">#raccoon_tip{padding:14px;position:absolute;z-index:9999}#raccoon_tip .rt_arrow{width:14px;height:14px;background:#f9e98e;position:absolute}#raccoon_tip.rt_top_left .rt_arrow{top:0;left:24px}#raccoon_tip .rt_content{padding:6px 12px 8px 12px;color:#a27d35;text-shadow:none;background:#fbf7aa;border-width:10px;border-style:solid;border-color:#f9e98e;*border-width:7px;border-radius:10px;-moz-border-radius:10px;-webkit-border-radius:10px}</style>';
  
  var register = function(target, content) {
    $(target).click(function() {
      display(target, content);
    });
  };
  
  var display = function(target, content) {
    prepare();
    setContent(content);
    position(target);
    show();
  };
  
  var prepare = function() {
    if (!$("#raccoon_tip").length) {
      if (!$("head").length) {
        $(document.body).before("<head></head>");
      }
      $(css).prependTo("head");
      $(html).appendTo("body");
    } else {
      $("#raccoon_tip").hide();
      if ($("#raccoon_tip").data("marker")) {
        $("#raccoon_tip").data("marker").before($("#raccoon_tip .rt_content").children()).remove();
      }
    }
  };
  
  var setContent = function(reference) {
    var content = $(reference), marker = null;
    if (content.context) {
      marker = $("<span class=\".rt_marker\"></span>");
      content.before(marker);
    }
    content.appendTo("#raccoon_tip .rt_content").show();
    $("#raccoon_tip").data("marker", marker);
  };
  
  var position = function(reference) {
    var target = $(reference);
    $("#raccoon_tip").css({top: target.offset().top + target.outerHeight() + 3, left: target.offset().left - 8});
  };
  
  var show = function() {
    $("#raccoon_tip").show("slide");
  };
  
  return {
    register: register
  };
}());
