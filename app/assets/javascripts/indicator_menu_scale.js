function indicators_toggle()
{
//    $('div#indicator_menu_tabs').slideToggle(200);
	$('div#indicator_menu_scale .toggle').slideToggle(300);
}      

var the_indicators = new Object;

the_indicators.show = function()
{
      
	$('div#indicator_menu_scale .toggle')
	   .css('display', 'block')
	   .animate({	   
         height: 252
      }, 300);
};

the_indicators.hide = function()
{
   $('div#indicator_menu_scale .toggle').animate({
	   height: 0
	}, 300, function(){
      $(this).css('display', 'none');	
   });
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
