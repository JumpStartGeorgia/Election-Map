$(function(){
   var indicators = $("#indicator_menu_scale .indicator_links a"),
       new_url;
   
   
   function indicator_click(ths, link, id)
   {
        $("#map-loading").fadeIn(300);
        // reset the data table so the loading wheel appears
        reset_data_table();

        var query;
                           
         if (link.search('summary') !== -1)
         {
            query = update_query_parameter(gon.indicator_menu_data_path_summary, 'indicator_type_id', 'indicator_type', id);
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', "null"); 
            new_url = update_query_parameter(link, 'indicator_type_id', 'indicator_type', id);
         }
         else
         {
            query = update_query_parameter(gon.indicator_menu_data_path, 'indicator_id', 'indicator', id);      
            gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', id); 
            new_url = update_query_parameter(link, 'indicator_id', 'indicator', id);
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
   
   indicators.click(function(){
      var link = $(this).attr('href'),
          id = link.split('/')[11];
      indicator_click($(this), link, id);
   });
   
   var facebook = $("a[title=facebook]"),
       twitter = $("a[title=twitter]");   
   facebook.click(function(){
      var facebookWindow = window.open("http://www.facebook.com/share.php?u=" + new_url, "FaceBook", "location=no, menubar=no, width=500, height=500, scrollbars=no");
      facebookWindow.moveTo($(window).width()/2-200, $(window).height()/2-100);
      return false;
   });
   twitter.click(function(){
      var twitterWindow = window.open("https://twitter.com/share", "Twitter", "location=no, menubar=no, width=500, height=550, scrollbars=no");
      twitterWindow.moveTo($(window).width()/2-200, $(window).height()/2-100);
      return false;
   });

   var data_table = $("table#data-table");
   function data_table_link_click()
   {  
      var link = $(this).attr('href'),
          link_arr = link.split('/'),
          id = link_arr[11],
          shape = link_arr[link_arr.length-1];

      indicator_click($(this), link_arr.pop().pop().join(''), id);
      gon.dt_highlight_shape = shape;
      highlight_shape();
      return false;
   }
   data_table.live({
      'DOMNodeInserted': function()
      {
         var data_table_links = $(this).children("tbody").find("a");
         if (data_table_links.length > 0)
         {
            data_table_links.each(function(){
               $(this).click(data_table_link_click);
            });
         }
      }
   });
   
});
