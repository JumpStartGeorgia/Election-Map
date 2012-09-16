$(function(){
   var indicators = $("#indicator_menu_scale .indicator_links a");
   
   
   function indicator_click()
   {
        $("#map-loading").fadeIn(100);
        // reset the data table so the loading wheel appears
        reset_data_table();

        var link = $(this).attr('href'),
            id = $(this).attr('href').split('/')[11],
            ths = $(this);               
         if (link.search('summary') !== -1)
         {
            query = update_query_parameter(gon.indicator_menu_data_path_summary, 'indicator_type_id', 'indicator_type', id);
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', "null"); 
         }
         else
         {
            query = update_query_parameter(gon.indicator_menu_data_path, 'indicator_id', 'indicator', id);      
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', id); 
         }         

        $.get(query, function(data){   
          // save the data to a global variable for later user
          json_data = data;
  		    // update the shapes with the new values/colors
          bindDataToShapes(vector_child.features);         
          // create the scales and legend
          create_scales_legend();

          // highlight the link that was clicked on
          var all_lis = ths.parent().parent().find('a');
          all_lis.each(function(index, value){
            $(value).attr('class', 'not_active');
          });
          ths.attr('class', 'active');
      	 
      	 
          $("#map-loading").fadeOut(100);
          
          // update the data table
          load_data_table();
        });

        return false;
   }
   
   indicators.click(indicator_click);
   
});
