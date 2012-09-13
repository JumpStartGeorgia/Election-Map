var the_indicators = new Object;
the_indicators.status = 'show';

function indicators_toggle()
{
//    $('div#indicator_menu_tabs').slideToggle(200);
//	$('div#indicator_menu_scale .toggle').slideToggle(300);
console.log("ind toggle called - ind status = " + the_indicators.status);
	if (the_indicators.status === 'show') {
console.log("hiding");
		the_indicators.hide();
	}
	else{
console.log("showing");
		the_indicators.show();
	}
}


the_indicators.show = function()
{
	$('div#indicator_menu_scale .toggle')
	   .slideDown(300);
	the_indicators.status = 'show';
};

the_indicators.hide = function()
{
   $('div#indicator_menu_scale .toggle')
		.slideUp(300);
	the_indicators.status = 'hide';
};

$(document).ready(function ()
{
	if (gon.indicator_menu_scale)
	{
		$('div#indicator_menu_tabs').tabs();
//  $('h3#indicator_menu_header').click(function ()
//  {

		$('div#indicator_menu_scale .toggler').click(/*function(){
		   if ($('div#indicator_menu_scale .toggle').height() > 40)
		   {
		      the_indicators.hide();
		   }
		   else
		   {
   		   the_indicators.show();
		   }
		}*/indicators_toggle);
	}
});
