$(function(){
   var indicators = $("#indicator_menu_scale .indicator_links a");
   
   
   function indicator_click()
   {
        $("#map-loading").fadeIn(1000);
        var link = $(this).attr('href'),
            id = $(this).attr('href').split('/')[11],
            ths = $(this);               
         if (link.search('summary') !== -1)
         {
            query = update_query_parameter(gon.indicator_menu_data_path_summary, 'indicator_id', 'indicator', id);
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', id); 
         }
         else
         {
            query = update_query_parameter(gon.indicator_menu_data_path, 'indicator_id', 'indicator', id);      
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', id); 
         }         
         
        $.get(query, function(data){   
          json_data = data;
          bindDataToShapes(window.ajax_layer.features);         
          window.ajax_layer.redraw();
          var all_lis = ths.parent().parent().find('a');
          all_lis.each(function(index, value){
            $(value).attr('class', 'not_active');
          });
          ths.attr('class', 'active');
          
          $("#indicator_description").empty();
          $("#legend").empty();
          // if this is summary view, create the scales
		    create_summary_scales();
		    // now that the child vector is loaded, lets show the legend		    
		    draw_legend();
 		    // now load the values for the hidden form
      	 load_hidden_form();
          $("#map-loading").fadeOut(1000);
        });
        $('#data-table-container').empty().html('<div class="loading"></div><img src="/assets/table-blur.jpg" width="100%"/>');        
        load_data_table();
        return false;
   }
   
   indicators.click(indicator_click);
   
});
