$.extend({
  keys: function(object) {
    var result = [];
    for (var key in object) {
      if (object.hasOwnProperty(key)) {
        result.push(key);
      }
    }
    return result;
  },
  values: function(object) {
    var result = [];
    $.each($.keys(object), function(i, key) {
      result.push(object[key]);
    });
    return result;
  }
});

$(function() {
  if ($.fn.jquery >= "1.5") {
    var TYPE    = "RICH_CMS",
        reg_exp = /\[([^\]]*)=([^\]]*[\:\;][^\]]*)\]/,
        fescape = function(all, num) {
          return "\\" + (num - 0 + 1);
        },
        find = function(match, context) {
          var elements = context.getElementsByTagName("*"), ret = [];
          for (var i = 0; i < elements.length; i++) {
            var element = elements[i];
            if (element.getAttribute(match[1]) == match[2]) {
              ret.push(element);
            }
          }
          return ret.length === 0 ? null : ret;
        };

    $.expr.order.unshift(TYPE);
    $.expr.match    [TYPE] = new RegExp(reg_exp.source + (/(?![^\[]*\])(?![^\(]*\))/.source));
    $.expr.leftMatch[TYPE] = new RegExp(/(^(?:.|\r|\n)*?)/ .source + $.expr.match[TYPE].source.replace(/\\(\d+)/g, fescape));
    $.expr.find     [TYPE] = find;
  }
});