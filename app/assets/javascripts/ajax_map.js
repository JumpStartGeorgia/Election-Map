$(function(){
   var new_url, highlighted_shape;


	// highlight the indicator menu link to match the data that is being loaded
	function highlight_indicator(ths)
	{
		var indicators = $("#indicator_menu_tabs > div > .menu_list").find("li"),
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

   function indicator_click(ths, link, id, datai)
   {
			// create the new url for the data json, data table json, and the page url
		  var query;
		   if (link.search('summary') !== -1)
		   {
		      query = update_query_parameter(gon.indicator_menu_data_path_summary, 'indicator_type_id', 'indicator_type', id);
//		      gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', "null");
		      new_url = update_query_parameter(link, 'indicator_type_id', 'indicator_type', id);
		   }
		   else
		   {
		      query = update_query_parameter(gon.indicator_menu_data_path, 'indicator_id', 'indicator', id);
//		      gon.data_table_path = update_query_parameter(gon.data_table_path, 'indicator_id', 'indicator', id);
		      new_url = update_query_parameter(link, 'indicator_id', 'indicator', id);
		   }

			// show loading wheel
			$("#map-loading").fadeIn(300);

			// scroll to the top
			$('html,body').animate({
				scrollTop: 0
				},
				500
			);


			// reset the data table so the loading wheel appears
//		  reset_data_table();

			// reset popups
			map.controls[1].activate();
			$.each(map.popups, function(index, value){
				map.removePopup(map.popups[index]);
			});
			// if shape is highlighted, turn it off
			unhighlight_shape(current_highlighted_feature, false);



			// get the data json and process it
			$.get(query, function(data){
				// save the data to a global variable for later user
				json_data = data;

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

				// update the shapes with the new values/colors
				bindDataToShapes(vector_child.features);

				// create the scales and legend
				create_scales_legend();

				// highlight the link that was clicked on
				highlight_indicator(ths);

				// indicate that the child layer has loaded
				// - do not wait for the datatable to be loaded
				$("div#map").trigger("child_layer_loaded");

				// load the table of data below the map
//        load_data_table();

				// highlight the correct column in the data table
				if (datai !== undefined && datai !== null){
					// get datai of current selected column
					current_datai = $('#dt_dd_switcher').children('option:selected').data('i');
					if (current_datai != datai) {
						// remove current selection
						$('#dt_dd_switcher option[selected=selected]').attr("selected", null);
						// select new column
						$('#dt_dd_switcher option[data-i=' + datai + ']').attr("selected", "selected");
						// update data table highlighting
						dt.highlight();
					}
				}

			});
   }

	// add click functions to all indicator menu items
	var jq_indicators = $("#indicator_menu_scale .indicator_links a")
	jq_indicators.click(function(){
		var link = $(this).attr('href'),
				title = $(this).attr('title')
		    id = link.split('/')[11];
		// reset highlight since indicator clicks do not have highlight
		gon.dt_highlight_shape = null;

		// get the data-i of the th tag that has the same text as the link's title
		var table_headers = $('#data-table tr th')
		var datai = null;
		// if the title does not exist, use the link text
		if (title == undefined || title == null){
			title = $(this).text().trim();
		}
		for (var i=0;i<table_headers.length;i++){
			if (title.trim().indexOf(table_headers[i].innerText.trim()) != -1) {
				datai = $(table_headers[i]).attr('data-i');
				break;
			}
		}

		// load the new data
		indicator_click($(this), link, id, datai);
		return false;
	});


	// click function for links in data table
	function data_table_link_click()
	 {
    var ths = $(this);
		var link = ths.attr('href'),
				link_arr = link.split('/'),
				id = link_arr[11];
		// save the shape to highlight
		gon.dt_highlight_shape = decodeURIComponent(link_arr[link_arr.length-1]);

		// get the data-i of the td tag that has the link that was just clicked
		var datai = ths.parent().data('i');

		// load the new data
		indicator_click(ths, link, id, datai);

		return false;
	}


	// add click functions to all links in data table
	var jq_data_table = $("table#data-table");
	jq_data_table.live({
    'DOMNodeInserted': function()
    {
     var data_table_links = $(this).children("tbody:first").find("a").click(data_table_link_click);
    }
   });


	// create popup window for social links
	var facebook = $("a[title=facebook]"),
		 twitter = $("a[title=twitter]");
	facebook.click(function(){
		var facebookWindow = window.open("http://www.facebook.com/share.php?u=" + window.location.href, "FaceBook", "location=no, menubar=no, width=500, height=500, scrollbars=no");
		facebookWindow.moveTo($(window).width()/2-200, $(window).height()/2-100);
		return false;
	});
	twitter.click(function(){
		var twitterWindow = window.open("https://twitter.com/share", "Twitter", "location=no, menubar=no, width=500, height=550, scrollbars=no");
		twitterWindow.moveTo($(window).width()/2-200, $(window).height()/2-100);
		return false;
	});



});
