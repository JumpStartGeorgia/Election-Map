$(function(){
   var indicators = $("#indicator_menu_scale .indicator_links a");
   
   
   function indicator_click()
   {
        $("#map-loading").fadeIn(300);
        // reset the data table so the loading wheel appears
        reset_data_table();

        var link = $(this).attr('href'),
            id = $(this).attr('href').split('/')[11],
            ths = $(this),
            query,new_url;
                           
         if (link.search('summary') !== -1)
         {
            query = update_query_parameter(gon.indicator_menu_data_path_summary, 'indicator_type_id', 'indicator_type', id);
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', "null"); 
            new_url = update_query_parameter(window.location.href, 'indicator_type_id', 'indicator_type', id);
         }
         else
         {
            query = update_query_parameter(gon.indicator_menu_data_path, 'indicator_id', 'indicator', id);      
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', id); 
            new_url = update_query_parameter(window.location.href, 'indicator_id', 'indicator', id);
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
          
          // update page title
          var seperator = ' > ';
          var new_title = '';
          var old_title_ary = document.title.split(seperator);
          for(var i=0; i<old_title_ary.length;i++){
           if (i==1)
            new_title += json_data["indicator"]["name_abbrv"];
           else
            new_title += old_title_ary[i];
  
            if (i < old_title_ary.length-1)
              new_title += seperator;
          }
          document.title = new_title;
      	 
      	 // update url
      	 history.pushState(null, new_title, new_url);
      	 
          $("#map-loading").fadeOut(100);
          
          // update the data table
          load_data_table();
        });

        return false;
   }
   
   indicators.click(indicator_click);
   
});
