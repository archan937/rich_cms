if (typeof(Rich) == "undefined") {

  Rich = (function() {
    var initModules = function() {
      $.each($.modules(Rich), function(i, module) {
        initSubModules(module);
      });
    };
  
    var initSubModules = function(mod) {
      if (mod.init) {
        mod.init();
      }
      $.each($.modules(mod), function(i, m) {
        initSubModules(m);
      });
    };
	
    return {
      init: function() {
        initModules();
      }
    };
  }());

  $(Rich.init);

}