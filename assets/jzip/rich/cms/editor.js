
Rich.Cms.Editor = (function() {
  var edit_panel       = "#rich_cms_bar .panel .edit",
      editable_class   = "rich_cms_content",
      mark_class       = "marked",
      editable_content = {},
      editables        = "";
  
  var register = function(hash) {
    $.extend(editable_content, hash);
    editables = $.keys(editable_content).join(",");
  };
  
  var editHandler = function(event) {
    edit($(this));
    event.preventDefault();
  };
  
  var bind = function() {    
    $("." + editable_class + "." + mark_class).live("click", editHandler                         );
    $("#rich_cms_bar .menu a.mark"           ).bind("click", mark                                );
    $(edit_panel + " a.close"                ).bind("click", function() { $(edit_panel).hide(); });
  };
  
  var bindSeatHolders = function() {
    $(editables + "." + mark_class + ".sh_hint").bind("focus", editHandler);
  };
  
  var mark = function(event) {
    $(editables).addClass(editable_class).toggleClass(mark_class);
    
    var markedEditables = $(editables + "." + mark_class);
    if (markedEditables.length) {
      $.each(markedEditables, function() {
        var editable = $(this);
        if (editable.parent().is("p") && editable.parent().children().length == 1) {
          editable.addClass("block");
        }
      });
      bindSeatHolders();
    } else {
      $(editables + ".block").removeClass("block");
      $(edit_panel).hide();
    }
    
    event.preventDefault();
  };
  
  var edit = function(editable) {
    var label  = $("#rich_cms_bar .edit label");
    var inputs = $("#rich_cms_bar .edit form fieldset.inputs");
    var text   = editable.is("textarea") || editable.hasClass("block");
    var attrs  = editable.get(0).attributes;

    var match    = $.grep($.makeArray(editable_content), function(hash) {
                     return editable.is($.keys(hash)[0]);
                   })[0];
    var selector = $.keys(match)[0];
    var specs    = $.values(match)[0];
    
    label.html(specs.value.replace(/^data-/, ""));
    inputs.find(":input").remove();
    inputs.append("<input name='editable_content[__selector__]' type='hidden' value='" + selector + "'/>");
    
    $.each(attrs, function(index, attribute) {
      var attr = attribute.name;
      
      if (attr.match(/^data-/)) {
        var name  = "editable_content[" + attr.replace(/^data-/, "") + "]";
        var value = editable.attr(attr);
        
        if (attr == specs.value) {
          if (text) {
            inputs.append("<textarea name='" + name + "'>" + value + "</textarea>");
          } else {
            inputs.append("<input name='" + name + "' type='text' value='" + value + "'/>");
          }
        } else {
          inputs.append("<input name='" + name + "' type='hidden' value='" + value + "'/>");
        }
      }
    });
    
    $(edit_panel).show();
  };
  
  var afterUpdate = function(form, response) {
    var specs = editable_content[response["__selector__"]];

    var defaultFunction = function(form, response) {
      $("[" + specs.key + "=" + response[specs.key.replace(/^data-/, "")] + "]").html(response[specs.value.replace(/^data-/, "")]);
      if (typeof(SeatHolder) != "undefined") {
        SeatHolder.rebind();
      }
    };
    
    (specs.afterUpdate || defaultFunction).apply(null, [form, response]);
  };
  
  return {
    init: function() {
      bind();
      $.registerAjaxFormHandler({
        "rich_cms_editable": afterUpdate
      });
    },
    register: register
  };
}());
