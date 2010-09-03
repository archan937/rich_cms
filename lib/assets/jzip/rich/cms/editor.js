
Rich.Cms.Editor = (function() {
  var content_class = "rich_cms_content", mark_class = "marked", edit_panel = "#rich_cms_panel",
      editable_content = {}, content_items = "";
  
  var register = function(hash) {
    $.extend(editable_content, hash);
    content_items = $.keys(editable_content).join(",");
  };
  
  var bind = function() {
    $("#rich_cms_panel .edit a.close").bind("click", function(event) {
      event.preventDefault();
      RaccoonTip.close();
    });
    
    RaccoonTip.register("." + content_class + "." + mark_class, "#rich_cms_panel", {beforeShow: edit, afterHide : function(content) { content.hide(); }});
    bindSeatHolders();
    
    $.registerAjaxFormHandler({
      "rich_cms_content": afterUpdate
    });
  };
  
  var bindSeatHolders = function() {
    RaccoonTip.register("." + content_class + "." + mark_class + ".sh_hint", "#rich_cms_panel", {event: "focus", beforeShow: edit, afterHide : function(content) { content.hide(); }});
  };
  
  var mark = function(event) {
    event.preventDefault();
    
    $(content_items).addClass(content_class).toggleClass(mark_class);
    
    var markedContentItems = $(content_items + "." + mark_class);
    if (markedContentItems.length) {
      $.each(markedContentItems, function() {
        var item = $(this);
        if (item.find("p").length || item.html().length > 50) {
          item.addClass("block");
        }
      });
      bindSeatHolders();
    } else {
      $(content_items + ".block").removeClass("block");
      $(edit_panel).hide();
    }
  };
  
  var edit = function() {
    var content_item = $(this).closest(".rich_cms_content");
    var label        = $("#rich_cms_panel .edit form fieldset.inputs label");
    var inputs       = $("#rich_cms_panel .edit form fieldset.inputs");
                     
    var text         = content_item.is("textarea") || content_item.hasClass("block");
    var attrs        = content_item.get(0).attributes;
    
    var selector     = $.grep($.keys(editable_content), function(s) {
                         return content_item.is(s);
                       })[0];
    var specs        = editable_content[selector];
    
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
    },
    register: register,
    mark:     mark
  };
}());
