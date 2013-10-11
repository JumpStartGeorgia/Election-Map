    var landing_circle_link_obj = null;

$(document).ready(function() {
  if (gon.langing_page){

    // get the max height for row 3 divs and set all other divs to match
    function adjust_landing_page_heights(){
      var heights = [];
      $('#row2 .row2_links').each(function(){
        heights.push($(this).height());
      });
      
      $('#row2 .row2_links').each(function() { $(this).height(Math.max.apply(Math, heights)); });
    }

    $(window).resize(function(){
      adjust_landing_page_heights();
    });

    adjust_landing_page_heights();
    
    $('a.landing_circle_link').click(function(){
      landing_circle_link_obj = this;
      $.fancybox({
        transitionIn: 'elastic',
        transitionOut: 'elastic',
        type: 'inline',
        href: $(landing_circle_link_obj).attr('href'),
        onStart: function () {
          if ($(landing_circle_link_obj).data('type-id') != undefined){
            $('div#events_menu_tabs .ui-tabs-nav li a[data-type-id="' + $(landing_circle_link_obj).data('type-id') + '"]').click();
          }
          else {
            $('div#events_menu_tabs .ui-tabs-nav li:eq(0) a').click();
          }
        }
      });
    });
  }




  var span = $('#landing_page #live_events_row .item .name h4 > span');
  if (span.length)
  {
    span.css({bottom: '+=' + (span.parent().height() - +span.children().width()) / 2}).removeClass('hidden');
  }
  if ($('html').attr('lang') == 'ka')
  {
    var el = $('#landing_page #live_events_row .header > strong');
    if (el.length)
    {
      el.css('bottom', '+=' + ((el.parent().height() - el.siblings().outerHeight(true) - el.children().width()) / 2)).removeClass('hidden');
    }
  }

});
