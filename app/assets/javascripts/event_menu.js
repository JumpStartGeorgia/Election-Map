$(document).ready(function () {
	$('div#events_menu_tabs').tabs();
	$('div#events_menu_tabs').hide();
	$('h3#events_menu_header').click(function () {
		$('div#events_menu_tabs').slideToggle(200);
	});
});
