//= require i18n
//= require i18n/translations
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require twitter/bootstrap
//= require fancybox

//= require utilities

//= require vendor_map
//= require jquery.tablesorter.min
//= require data_table_loader
//= require d3.v2.min
//= require jquery.slimscroll

//= require data
//= require event_custom_views
//= require event_indicator_relationships
//= require event_menu
//= require events
//= require indicator_menu_scale
//= require data_sets
//= require menu_live_events
//= require map_popup_svg
//= require messages
//= require news
//= require shapes
//= require countdown
//= require map.export
//= require map


$(document).ready(function(){
// set focus to first text box on page
  $(":input:visible:first").focus();

	// to load pop-up window for export help
  $("a.fancybox").fancybox();

	// if scrolling make navbar see through
  var fade_after = 10,
  navbar = $('.navbar.navbar-fixed-top');
  $(window).scroll(function ()
  {
    var y = window.scrollY;
    if (y > fade_after)
    {
      navbar.animate({opacity: .93}, 'fast');
    }
    else
    {
      navbar.animate({opacity: 1}, 'fast');
    }
  });

});
