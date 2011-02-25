
Rich.Cms.Editor = (function() {
  var content_class        = "rich_cms_content", mark_class = "marked", edit_panel = "#rich_cms_panel",
      editable_content     = {}, content_items = "",
      cleditor_images_path = "/images/rich/cms/cleditor",
      cleditor_css         = '<style>.cleditorMain {border:1px solid #999; padding:0 1px 1px; background-color:white} .cleditorMain iframe {border:none; margin:0; padding:0} .cleditorMain textarea {border:none; margin:0; padding:0; overflow-y:scroll; font:10pt Arial,Verdana; resize:none; outline:none /* webkit grip focus */} .cleditorToolbar {background: url("' + cleditor_images_path + '/toolbar.gif") repeat} .cleditorGroup {float:left; height:26px} .cleditorButton {float:left; width:24px; height:24px; margin:1px 0 1px 0; background: url("' + cleditor_images_path + '/buttons.gif")} .cleditorDisabled {opacity:0.3; filter:alpha(opacity=30)} .cleditorDivider {float:left; width:1px; height:23px; margin:1px 0 1px 0; background:#CCC} .cleditorPopup {border:solid 1px #999; background-color:white; position:absolute; font:10pt Arial,Verdana; cursor:default; z-index:10000} .cleditorList div {padding:2px 4px 2px 4px} .cleditorList p, .cleditorList h1, .cleditorList h2, .cleditorList h3, .cleditorList h4, .cleditorList h5, .cleditorList h6, .cleditorList font {padding:0; margin:0; background-color:Transparent} .cleditorColor {width:150px; padding:1px 0 0 1px} .cleditorColor div {float:left; width:14px; height:14px; margin:0 1px 1px 0} .cleditorPrompt {background-color:#F6F7F9; padding:4px; font-size:8.5pt} .cleditorPrompt input, .cleditorPrompt textarea {font:8.5pt Arial,Verdana;} .cleditorMsg {background-color:#FDFCEE; width:150px; padding:4px; font-size:8.5pt}</style>';

  var register = function(hash) {
    $.extend(editable_content, hash);
    content_items = $.keys(editable_content).join(",");
  };

  var bind = function() {
    $("#rich_cms_panel .edit form fieldset.inputs div.keys a.toggler").live("click", function(event) {
      event.preventDefault();
      var toggler = $(event.target);
      toggler.hide().closest(".keys").find("select[name=" + toggler.attr("data-name") + "]").show();
    });

    $("#rich_cms_panel .edit a.close").bind("click", function(event) {
      event.preventDefault();
      RaccoonTip.close();
    });

    RaccoonTip.register("." + content_class + "." + mark_class, "#rich_cms_panel", {
                          beforeShow: edit,
                          canHide: function() { return !$("#cleditor_input").length; },
                          afterHide: function(content) { content.hide(); }
                        });

    bindSeatHolders();
    injectCleditorCss();

    $.registerAjaxFormHandler({
      "rich_cms_content": afterUpdate
    });
  };

  var bindSeatHolders = function() {
    RaccoonTip.register("." + content_class + "." + mark_class + ".sh_hint", "#rich_cms_panel", {event: "focus", beforeShow: edit, afterHide : function(content) { content.hide(); }});
  };

  var injectCleditorCss = function() {
    if (!$("head").length) {
      $(document.body).before("<head></head>");
    }
    $(cleditor_css).prependTo("head");
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

    if (typeof(SeatHolder) != "undefined") {
      SeatHolder.react(!markedContentItems.length);
    }
  };

  var edit = function() {
    var content_item = $(this).closest(".rich_cms_content");
    var keys         = $("#rich_cms_panel .edit form fieldset.inputs div.keys");
    var inputs       = $("#rich_cms_panel .edit form fieldset.inputs");

    var attrs        = content_item.get(0).attributes;
    var selector     = $.grep($.keys(editable_content), function(s) {
                         return content_item.is(s);
                       })[0];
    var specs        = editable_content[selector];

    keys.find("select,a,span").remove();
    inputs.find(":input,div.cleditorMain").remove();
    inputs.append("<input name='content_item[__selector__]' type='hidden' value='" + selector + "'/>");

    $.each(attrs, function(index, attribute) {
      var attr = attribute.name;

      if (attr.match(/^data-/)) {
        var name  = "content_item[" + attr.replace(/^data-/, "") + "]";
        var value =  content_item.attr(attr);

        if (attr == specs.value) {
          var editable_input_type = content_item.attr("data-editable_input_type") || (content_item.is("textarea") || content_item.hasClass("block") ? "text" : "string");

          switch (editable_input_type) {
            case "string":
              inputs.append("<input name='" + name + "' type='text' value='" + value + "'/>"); break;
            case "text":
              inputs.append("<textarea name='" + name + "'>" + value + "</textarea>"); break;
            case "html":
              inputs.append("<textarea id='cleditor_input' name='" + name + "' style='width: 500px; height: 300px'>" + value + "</textarea>"); break;
          }
        } else if (specs.keys.indexOf(attr) != -1) {
          var available_keys = $.map(value.split(","), function(key) { return $.trim(key); });
          var default_key    = available_keys[0];

          if (specs.keys.length > 1 && keys.find("select").length > 0) {
            keys.append("<span>, <span>");
          }

          keys.append(available_keys.length == 1 ?
                        "<span>" + default_key + "<span>" :
                        "<a href='#' class='toggler' data-attr='" + attr + "' data-name='" + name + "'>" + default_key + "</a>");
          keys.append("<select name='" + name + "' style='display: none'>" +
                         $.map(available_keys, function(key) { return "<option value='" + key + "'>" + key + "</option>"; }).join("") +
                      "</select>");
        } else {
          inputs.append("<input name='" + name + "' type='hidden' value='" + value + "'/>");
        }
      }
    });

    $("#rich_cms_panel .edit form fieldset.inputs div.keys select").bind("blur", function(event) {
      var select  = $(event.target);
      var toggler = select.hide().closest(".keys").find(".toggler[data-name=" + select.attr("name") + "]").html(select.val()).show();
      var values  = [select.val()];

      $.map(select.find("option"), function(option) {
        var value = $(option).val();
        if (value != values[0]) {
          values.push(value);
        }
      });

      content_item.attr(toggler.attr("data-attr"), values.join(", "));
    });

    if (specs.beforeEdit) {
      var identifier = $.map(specs.keys, function(key) { return "[" + key + "=" + content_item.attr(key) + "]"; }).join("");
      specs.beforeEdit.apply(null, [inputs, selector, specs, identifier]);
    }

    $(edit_panel).show();

    setTimeout(function() {
      if ($("#cleditor_input").length) {
        $("#cleditor_input").data("cleditor", $("#cleditor_input").cleditor({
          width : 500,
          height: 300
        })[0].focus());
      }
    }, 250);
  };

  var afterUpdate = function(form, response) {
    var selector   = response["__selector__"];
    var specs      = editable_content[selector];
    var identifier = $.map(specs.keys, function(key) { return "[" + key + "^=" + response["__identifier__"][key.replace(/^data-/, "")] + "]"; }).join("");

    var defaultFunction = function(form, response, selector, specs, identifier) {
      var value = response[specs.value.replace(/^data-/, "")];
      $(identifier).html(value).attr(specs.value, value);
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
