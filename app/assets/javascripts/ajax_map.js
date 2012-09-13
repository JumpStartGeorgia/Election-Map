$(function(){
   var indicators = $("#indicator_menu_scale .indicator_links a");
   
   
   function indicator_click()
   {
        var id = $(this).attr('href').split('/')[11],
            query = update_query_parameter(gon.indicator_menu_data_path, 'indicator_id', 'indicator', id),
            ths = $(this);       
        $.get(query, function(data){   
          json_data = data;
          bindDataToShapes(window.ajax_layer.features);         
          window.ajax_layer.redraw();
          var all_lis = ths.parent().parent().find('a');
          all_lis.each(function(index, value){
            $(value).attr('class', 'not_active');
          });
          ths.attr('class', 'active');
        });
        return false;
   }
   
   indicators.click(indicator_click);
   
});
