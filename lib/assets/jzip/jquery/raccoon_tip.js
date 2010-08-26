
RaccoonTip = (function() {
  var html = '<div id="raccoon_tip" class="rt_top_left" style="display: none"><div class="rt_arrow"><canvas></canvas></div><div class="rt_content"></div></div>';
  var css  = '<style type="text/css" media="screen">#raccoon_tip{padding:14px;position:absolute;z-index:9999}#raccoon_tip .rt_arrow{width:14px;height:14px;position:absolute}#raccoon_tip.rt_top_left .rt_arrow{top:0;left:24px}#raccoon_tip .rt_content{padding:6px 12px 8px 12px;overflow:hidden;background:#fbf7aa;border-width:10px;border-style:solid;border-color:#f9e98e;*border-width:7px;border-radius:10px;-moz-border-radius:10px;-webkit-border-radius:10px}#raccoon_tip .rt_content,#raccoon_tip .rt_content a{color:#a27d35;text-shadow:none}#raccoon_tip .rt_content a{outline:0}</style>';
  
  var default_options = {event: "click", duration: "fast", position: ["top", "middle"], beforeShow: function() {}, afterHide: function() {}}, opts = null;
  var displaying = false, mouseover = false;
  
  var register = function(target, content, options) {
    $(target).live((options || {}).event || "click", function(event) {
      event.preventDefault();
      display(event.target, content, options);
    });
  };
  
  var display = function(target, content, options) {
    displaying = true;
    setup();
    deriveOptions(target, content, options);
    setContent();
    position();
    drawTip();
    show();
    displaying = false;
  };
  
  var close = function() {
    hide();
  };
  
  var setup = function() {
    if (!$("#raccoon_tip").length) {
      $("body").mouseup(function(event) {
        if (!displaying && !mouseover) {
          hide();
        }
      });
      if (!$("head").length) {
        $(document.body).before("<head></head>");
      }
      $(css).prependTo("head");
      $(html).appendTo("body").mouseenter(function() { mouseover = true; }).mouseleave(function() { mouseover = false; });
    } else {
      hide();
    }
  };
  
  var deriveOptions = function(__target__, __content__, options) {
    opts = $.extend({}, default_options, options, {target: $(__target__), content: $(__content__)});
  };
  
  var setContent = function() {
    var marker = null;
    if (opts.content.context) {
      marker = $("<span class=\".rt_marker\"></span>");
      opts.content.before(marker);
    }
    opts.content.appendTo("#raccoon_tip .rt_content");
    $("#raccoon_tip").data("rt_marker", marker);
  };
  
  var position = function() {
    $("#raccoon_tip").css({top: opts.target.offset().top + opts.target.outerHeight() + 4, left: opts.target.offset().left - 8});
  };
  
  var drawTip = function() {
    if ($("<canvas>").get(0).getContext) {
      var arrow = $("#raccoon_tip .rt_arrow"), length = 14;
      var context = arrow.find("canvas").attr("width", length).attr("height", length).get(0).getContext("2d");
    
      context.beginPath();
      context.moveTo(     0,      0);
      context.lineTo(     0, length);
      context.lineTo(length, length);
    
      context.fillStyle = "#F9E98E";
      context.fill();
    }
  };
  
  var show = function() {
    opts.beforeShow.apply(opts.target, [opts.content]);
    $("#raccoon_tip").data("rt_options", opts).show(opts.duration);
  };
  
  var hide = function() {
    var options = $("#raccoon_tip").data("rt_options");
    $("#raccoon_tip").hide(0);
    options.afterHide.apply(options.target, [options.content]);
    if ($("#raccoon_tip").data("rt_marker")) {
      $("#raccoon_tip").data("rt_marker").before($("#raccoon_tip .rt_content").children()).remove();
    }
  };
  
  return {
    register: register,
    display : display,
    close   : close
  };
}());
