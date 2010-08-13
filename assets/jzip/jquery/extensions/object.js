
$.extend({
  keys: function(object) {
    var result = [];
    for (var key in object) {
      result.push(key);
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
