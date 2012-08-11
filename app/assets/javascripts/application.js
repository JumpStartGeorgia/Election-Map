// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require i18n
//= require i18n/translations
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require twitter/bootstrap
//= require fancybox

//= require d3.v2.min
//= require jquery.slimscroll

//= require data
//= require event_custom_views
//= require event_indicator_relationships
//= require event_menu
//= require indicator_menu_scale
//= require shapes

//= require map.export

// set focus to first text box on page
$(document).ready(function(){
  $("input:visible:first").focus();
});
