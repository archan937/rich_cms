
Rich.Cms.Qtip = (function() {
  var opposites = {top: "bottom", bottom: "top", left: "right", right: "left", middle: "middle"};
  
  var show = function(target, content, onRender) {
    $(target).data("qtip", "").qtip({
      style: {
        padding: 10, 
        border: {
          width: 3,
          color: "#F0CF73",
          radius: 7
        },
        name: "cream"
      },
      show: {
        when: false,
        ready: true,
        solo: true,
        effect: {
          type: "slide"
        }
      },
      hide: {
        when: "click",
        effect: {
          type: "slide"
        }
      },
      api: {
        beforeRender: function() {
          this.options.position.corner.target  = "bottomMiddle";
          this.options.position.corner.tooltip = "topMiddle";
          this.options.style.tip.corner        = "topMiddle";
        },
        onRender: function() {
          if (onRender) {
            onRender.apply(null, [this.elements.target]);
          }
          this.updateContent($(content));
        }
      }
    });
  };
  
  var getPosition = function() {
    
  };
  
  return {
    show: show
  };
}());
