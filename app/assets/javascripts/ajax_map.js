$(function(){
   var indicators = $("#indicator_menu_scale .indicator_links a"),
       new_url, highlighted_shape;
   
   
   function indicator_click(ths, link, id, removehighlight)
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
          
          if (removehighlight)
          {
             map.controls[1].activate();
             $.each(map.popups, function(index, value){
                map.removePopup(map.popups[index]);
             });
             unhighlight_shape(highlighted_shape);
          }
          
        });
   }
   
   indicators.click(function(){
      var link = $(this).attr('href'),
          id = link.split('/')[11];
      indicator_click($(this), link, id, true);      
      return false;
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
   
   function highlight_indicator(ths)
   {
      var indicators = $("#indicator_type_1 > .menu_list, #indicator_type_2 > .menu_list").find("li"),
          indicator_id = (function(){
            return ths.attr('href').split('/')[11];    
          }).apply();

      indicators.each(function(){         
         ths = $(this).children("a:first");
         if(parseInt(indicator_id) === parseInt((function(){
            return ths.attr('href').split('/')[11];
         }).apply()))
         {
            $(this).children("a:first").removeClass('not_active').addClass('active');
            var tab_li = $("a[href=#" + $(this).parent().parent().attr("id") + "]:first");
            tab_li.click();
         }
         else
         {
            $(this).children("a:first").removeClass('active').addClass('not_active');
         }
      });
   }
   
   
   function data_table_link_click(ths)
   {  
      var link = ths.attr('href'),
          link_arr = link.split('/'),
          id = link_arr[11],
          shape = link_arr[link_arr.length-1];            
      indicator_click(ths, link, id, false);
      
      gon.dt_highlight_shape = decodeURIComponent(shape);
      mapFreeze((function(){
        var features = map.layers[2].features;
        for (i = 0, num = features.length; i < num; i ++)
        {
          if (gon.dt_highlight_shape == features[i].data.common_name)
          {
            highlighted_shape = features[i];
            return highlighted_shape;
          }         
        }
      }).apply());
      highlight_shape();    
      highlight_indicator(ths);              
   }
   
   data_table.live({
      'DOMNodeInserted': function()
      {
         var data_table_links = $(this).children("tbody:first").find("a");
         if (data_table_links.length > 0)
         {           
            data_table_links.each(function(){
               $(this).click(function(){
                  data_table_link_click($(this));
                  return false;
               });               
            });
         }
      }
   }); 
   
});
