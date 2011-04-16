$.extend({
  modules: function(object) {
    var array = [];
    $.each(object, function(property, names_only) {
      if (property.match(/^[ABCDEFGHIJKLMNOPQRSTUVWXYZ][abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ]+$/)) {
        array.push(names_only === true ? property : object[property]);
      }
    });
    return array;
  },
  initModules: function(namespace) {
    $(function() {
      $.each($.modules(namespace), function(i, module) {
        if (module.init) {
          module.init();
        }
        $.initModules(module);
      });
    });
  }
});