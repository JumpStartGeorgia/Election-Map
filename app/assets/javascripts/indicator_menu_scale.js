$(document).ready(function () {
	if (gon.indicator_menu_scale){
		$('div#indicator_menu_tabs').tabs();
		$('h3#indicator_menu_header').click(function () {
			$('div#indicator_menu_tabs').slideToggle(200);
		});
	}
});
