
Rich.Cms = {};

(function requireMissingLibs() {
  var id = "rc_dummy_script";
  document.write('<script id="' + id + '"></script>');

  var dummy_script = document.getElementById(id);
  var element = dummy_script.previousSibling;
  while (element && (element.tagName.toLowerCase() != "script" || element.getAttribute("src").indexOf("rich_cms") == -1)) {
    element = element.previousSibling;
  }
  dummy_script.parentNode.removeChild(dummy_script);
  
  var libs_file = ["core", "widget", "mouse", "draggable"][$.inArray("undefined", [typeof($.ui), typeof($.widget), typeof(($.ui || {}).mouse), typeof(($.ui || {}).draggable)])];

  if (libs_file) {
    var src = element.getAttribute("src").replace(/(development\/)?(\w+)(\-min)?\.js.*$/, "jquery/ui/rich_cms/" + libs_file + ".js");
    document.write('<script src="' + src + '" type="text/javascript"></script>');
  }
}());
