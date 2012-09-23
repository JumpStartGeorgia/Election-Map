$(document).ready(function () {
	$('div#events_menu_tabs').tabs();
	$('div#events_menu_tabs').hide();

	$('#navmenu').click(function () {

	   if ($('div#events_menu_tabs').css('display') === "block")
	   {
	      $(document).unbind('click');
	      $('div#events_menu_tabs').slideToggle(200);
	   }
	   else
	   {
		   $('div#events_menu_tabs').slideToggle(200, function(){

            $(document).click(function(){
               $('div#events_menu_tabs').slideToggle(200);
               $(document).unbind('click');
            });

		   });
		}

	});

	// tipsy tooltips
	$('#events_menu_tabs .ui-tabs-panel .menu_list ul.menu_item li a').tipsy({
		gravity: 'w'
	});

	$('#events_menu_tabs .ui-tabs-panel .menu_list ul.menu_item li.event_name span').tipsy({
		gravity: 'w'
	});

});
