$(function(){
   var map_export = $("#export"),
       export_map_svg = $("#export-map, #export-data-xls, #export-data-csv, #export .fancybox"),
       display_export = function()
       {
         export_map_svg.css('display', 'block');
       },
       export_click = function()
       {
         var min_width = 94, max_width = 227;
         if (parseInt(map_export.css('width')) < max_width-1)
         {
            map_export.animate({
               width: max_width
            }, 250, display_export);
         }
         else
         {
            export_map_svg.css('display', 'none');
            map_export.animate({
               width: min_width
            }, 250);
         }
       };

   $("#export p:first").bind({
      click: export_click
   });

});
