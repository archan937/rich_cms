
Rich.Cms.Editor = (function() {
  var content_class    = "rich_cms_content",
      mark_class       = "marked",
      edit_panel       = "#rich_cms_panel .edit",
      editable_content = {},
      content_items    = "";
  
  var bind = function() {
    $(edit_panel + " a.close").bind("click", function() {
      $(edit_panel).hide();
    });
    $("." + content_class + "." + mark_class).live("click", editHandler);
  };
  
  var bindSeatHolders = function() {
    $(content_items + "." + mark_class + ".sh_hint").bind("focus", editHandler);
  };
  
  var editHandler = function(event) {
    edit($(this));
    event.preventDefault();
  };
  
  var register = function(hash) {
    $.extend(editable_content, hash);
    content_items = $.keys(editable_content).join(",");
  };
  
  var mark = function(event) {
    $(content_items).addClass(content_class).toggleClass(mark_class);
    
    var markedContentItems = $(content_items + "." + mark_class);
    if (markedContentItems.length) {
      $.each(markedContentItems, function() {
        var item = $(this);
        if (item.parent().is("p") && item.parent().children().length == 1) {
          item.addClass("block");
        }
      });
      bindSeatHolders();
    } else {
      $(content_items + ".block").removeClass("block");
      $(edit_panel).hide();
    }
    
    event.preventDefault();
  };
  
  var edit = function(content_item) {
    var label    = $("#rich_cms_dock .edit form fieldset.inputs");
    
    var text     = content_item.is("textarea") || content_item.hasClass("block");
    var attrs    = content_item.get(0).attributes;

    var match    = $.grep($.makeArray(editable_content), function(hash) {
                     return content_item.is($.keys(hash)[0]);
                   })[0];
    var selector = $.keys(match)[0];
    var specs    = $.values(match)[0];
    
    label.html($.map(specs.keys, function(key) { return content_item.attr(key); }).join(", "));
    
    inputs.find(":input").remove();
    inputs.append("<input name='content_item[__selector__]' type='hidden' value='" + selector + "'/>");
    
    $.each(attrs, function(index, attribute) {
      var attr = attribute.name;
      
      if (attr.match(/^data-/)) {
        var name  = "content_item[" + attr.replace(/^data-/, "") + "]";
        var value =  content_item.attr(attr);
        
        if (attr == specs.value) {
          if (text) {
            inputs.append("<textarea name='" + name + "'>" + value + "</textarea>");
          } else {
            inputs.append("<input    name='" + name + "' type='text'   value='" + value + "'/>");
          }
        } else {
            inputs.append("<input    name='" + name + "' type='hidden' value='" + value + "'/>");
        }
      }
    });
    
    if (specs.beforeEdit) {
      var identifier = $.map(specs.keys, function(key) { return "[" + key + "=" + content_item.attr(key) + "]"; }).join("");
      specs.beforeEdit.apply(null, [inputs, selector, specs, identifier]);
    }
    
    $(edit_panel).show();
  };
  
  var afterUpdate = function(form, response) {
    var selector   = response["__selector__"];
    var specs      = editable_content[selector];
    var identifier = $.map(specs.keys, function(key) { return "[" + key + "=" + response["__identifier__"][key.replace(/^data-/, "")] + "]"; }).join("");
    
    var defaultFunction = function(form, response, selector, specs, identifier) {
      $(identifier).html(response[specs.value.replace(/^data-/, "")]);
      if (typeof(SeatHolder) != "undefined") {
        SeatHolder.rebind();
      }
    };
    
    (specs.afterUpdate || defaultFunction).apply(null, [form, response, selector, specs, identifier]);
  };
  
  return {
    init: function() {
      bind();
      $.registerAjaxFormHandler({
        "rich_cms_content": afterUpdate
      });
    },
    register: register,
    mark:     mark
  };
}());
