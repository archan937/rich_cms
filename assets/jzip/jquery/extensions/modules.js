
$.extend({
  modules: function(object) {
    var array = [];
    $.each(object, function(property, names_only) {
      if (property.match(/^[ABCDEFGHIJKLMNOPQRSTUVWXYZ][abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ]+$/)) {
        array.push(names_only === true ? property : object[property]);
      }
    });
    return array;
  }
});