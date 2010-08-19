
$.extend({
  ie:  jQuery.browser.msie,
  ie6: jQuery.browser.msie    && parseInt(jQuery.browser.version, 10) == 6,
  ie7: jQuery.browser.msie    && parseInt(jQuery.browser.version, 10) == 7,
  ie8: jQuery.browser.msie    && parseInt(jQuery.browser.version, 10) == 8,
  ff2: jQuery.browser.mozilla && parseFloat(jQuery.browser.version) < 1.9
});
