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
//= require fancybox
//= require data
//= require event_types
//= require events
//= require indicator_scales
//= require indicators
//= require pages
//= require shape_types
//= require shapes

// set focus to first text box on page
$(document).ready(function(){
  $("input:visible:first").focus();
});

$(function ()
{

  $('#data-table-container .arrows > div').click(function ()
  {
    var direction = $(this).data('direction');
    var to_show = to_hide = $();
    var p = $('#data-table');

    hidden = p.find('th.hidden, td.hidden');
    visible = p.find('th:not(.hidden):not(.cg0), td:not(.hidden):not(.cg0)');

    classes = visible.get(0).getAttribute('class').split(' ');
    for (i in classes)
    {
      if (classes[i].substring(0, 2) != 'cg')
      {
        continue;
      }
      visi = classes[i].substring(2);
      if (direction == 'left')
      {
        nexti = (+ visi == 1) ? gon.dt_all_cols : + visi - 1;
      }
      else if (direction == 'right')
      {
        nexti = (+ visi == gon.dt_all_cols) ? 1 : + visi + 1;
      }
      visible.addClass('hidden');
      hidden.filter('.cg' + nexti).removeClass('hidden');
      break;
    }
  });

});
