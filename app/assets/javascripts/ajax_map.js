$(function(){

    // Prepare
    var History = window.History; // Note: We are using a capital H instead of a lower h

    if ( !History.enabled ) {
         // History.js is disabled for this browser.
         // This is because we can optionally choose to support HTML4 browsers or not.
        return false;
    }

    // initialize the first state
    History.replaceState({link:gon.history_url, id:gon.history_id, datai:1, dt_highlight_shape:null}, $(document).attr('title'), $(location).attr('href'))

    var State = History.getState();

    // Log Initial State
//		History.log('initial:', State.data, State.title, State.url);





   var highlighted_shape;

	// highlight the indicator menu link to match the data that is being loaded
	function highlight_indicator(link)
	{
		var indicators = $("#indicator_menu_tabs > div > .menu_list").find("li"),
		    id;

		if (link.search('summary') !== -1) {
			id = get_query_parameter(link, 'indicator_type_id', 'indicator_type');

			indicators.each(function(){
				 ths = $(this).children("a:first");
				 if (id === get_query_parameter(ths.attr('href'), 'indicator_type_id', 'indicator_type'))
				 {
				    ths.removeClass('not_active').addClass('active');
				    var tab_li = $("a[href=#" + $(this).parent().parent().attr("id") + "]:first");
				    tab_li.click();
				 }
				 else
				 {
				    ths.removeClass('active').addClass('not_active');
				 }
			});

		} else {
			id = get_query_parameter(link, 'indicator_id', 'indicator');

			indicators.each(function(){
				 ths = $(this).children("a:first");
				 if (id === get_query_parameter(ths.attr('href'), 'indicator', 'indicator'))
				 {
				    ths.removeClass('not_active').addClass('active');
				    var tab_li = $("a[href=#" + $(this).parent().parent().attr("id") + "]:first");
				    tab_li.click();
				 }
				 else
				 {
				    ths.removeClass('active').addClass('not_active');
				 }
			});
		}
	}

	// update the provided link with the new parameters
	function update_link_parameters(link, id) {
    // update facebook share link, have to test for 1st page for url is different format
    if (link == gon.history_url) {
      $('#facebook_link').attr('href', gon.history_url);
    }else {
      $('#facebook_link').attr('href', $('#facebook_link').data('url') + link);
    }

   if (link.search('summary') !== -1)
   {
			// shape navigation
			// - add ind type id and view type
			$('#shape_layer_navigation ul li.lev-ind a').each(function(index){
				// if the link does not have the indicator type param, switch it in for the indidcator id
				if (get_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type') == undefined){
					$(this).attr('href',
						replace_query_parameter($(this).attr('href'), 'indicator_id', 'indicator', 'indicator_type_id', 'indicator_type', id + '&view_type=' + gon.summary_view_type_name, id + '/view_type/' + gon.summary_view_type_name));
				} else {
					$(this).attr('href',
						update_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type', id));
					$(this).attr('href',
						update_query_parameter($(this).attr('href'), 'view_type', 'view_type', gon.summary_view_type_name));
				}
			});
			// - custom navigation
			$('#shape_layer_navigation ul#custom_shape_nav li.active_shape_nav a').each(function(index){
				// if the link does not have the indicator type param, switch it in for the indidcator id
				if (get_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type') == undefined){
					$(this).attr('href',
						replace_query_parameter($(this).attr('href'), 'indicator_id', 'indicator', 'indicator_type_id', 'indicator_type', id, id));

//					$(this).attr('href',
//						replace_query_parameter($(this).attr('href'), 'indicator_id', 'indicator', 'indicator_type_id', 'indicator_type', id + '&view_type=' + gon.summary_view_type_name, id + '/view_type/' + gon.summary_view_type_name));
				} else {
					$(this).attr('href',
						update_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type', id));
				}
				$(this).attr('href',
					update_query_parameter($(this).attr('href'), 'view_type', 'view_type', gon.summary_view_type_name));
			});

			// custom shape view switcher
			// - add ind type id and view type
			// - switcher might not exist, so see if is there
			// if the link does not have the indicator type param, switch it in for the indidcator id
			if ($('#switch-custom-view').length > 0) {
				if (get_query_parameter($('#switch-custom-view').attr('href'), 'indicator_type_id', 'indicator_type') == undefined){
					$('#switch-custom-view').attr('href',
						replace_query_parameter($('#switch-custom-view').attr('href'), 'indicator_id', 'indicator', 'indicator_type_id', 'indicator_type', id + '&view_type=' + gon.summary_view_type_name, id + '/view_type/' + gon.summary_view_type_name));
				} else {
					$('#switch-custom-view').attr('href',
						update_query_parameter($('#switch-custom-view').attr('href'), 'indicator_type_id', 'indicator_type', id));
					$('#switch-custom-view').attr('href',
						update_query_parameter($('#switch-custom-view').attr('href'), 'view_type', 'view_type', gon.summary_view_type_name));
				}
			}

			// language
			// - add ind type id and view type
			$('a.language_link_switcher').each(function(index){
				if (get_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type') == undefined){
					$(this).attr('href',
						replace_query_parameter($(this).attr('href'), 'indicator_id', 'indicator', 'indicator_type_id', 'indicator_type', id, id));
				} else {
					$(this).attr('href',
						update_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type', id));
				}
				$(this).attr('href',
					update_query_parameter($(this).attr('href'), 'view_type', 'view_type', gon.summary_view_type_name));
			});
   }
   else
   {
			// shape navigation
			// - add ind type id and view type
			$('#shape_layer_navigation ul li.lev-ind a').each(function(index){
				// if the link does not have the indicator param, switch it in for the indidcator type
				if (get_query_parameter($(this).attr('href'), 'indicator_id', 'indicator') == undefined){
					$(this).attr('href',
						replace_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type', 'indicator_id', 'indicator', id, id));
				} else {
					$(this).attr('href',
						update_query_parameter($(this).attr('href'), 'indicator_id', 'indicator', id));
				}
				$(this).attr('href',
					remove_query_parameter($(this).attr('href'), 'view_type', 'view_type'));
			});

			// - custom navigation
			$('#shape_layer_navigation ul#custom_shape_nav li.active_shape_nav a').each(function(index){
				// if the link does not have the indicator param, switch it in for the indidcator type
				if (get_query_parameter($(this).attr('href'), 'indicator_id', 'indicator') == undefined){
					$(this).attr('href',
						replace_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type', 'indicator_id', 'indicator', id, id));
				} else {
					$(this).attr('href',
						update_query_parameter($(this).attr('href'), 'indicator_id', 'indicator', id));
				}
				$(this).attr('href',
					remove_query_parameter($(this).attr('href'), 'view_type', 'view_type'));
			});



			// custom shape view switcher
			// - add ind id and view type
			// - indicator id is id from other shape type - get from data json
			// - switcher might not exist, so see if is there
			if ($('#switch-custom-view').length > 0) {
				// if the link does not have the indicator param, switch it in for the indidcator type
				if (get_query_parameter($('#switch-custom-view').attr('href'), 'indicator_id', 'indicator') == undefined){
					$('#switch-custom-view').attr('href',
						replace_query_parameter($('#switch-custom-view').attr('href'), 'indicator_type_id', 'indicator_type', 'indicator_id', 'indicator', json_data["indicator"]["switcher_indicator_id"], json_data["indicator"]["switcher_indicator_id"]));
				} else {
					$('#switch-custom-view').attr('href',
						update_query_parameter($('#switch-custom-view').attr('href'), 'indicator_id', 'indicator', json_data["indicator"]["switcher_indicator_id"]));
				}
				$('#switch-custom-view').attr('href',
					remove_query_parameter($('#switch-custom-view').attr('href'), 'view_type', 'view_type'));
			}

			// language
			// - add ind id and view type
			$('a.language_link_switcher').each(function(index){
				if (get_query_parameter($(this).attr('href'), 'indicator_id', 'indicator') == undefined){
					$(this).attr('href',
						replace_query_parameter($(this).attr('href'), 'indicator_type_id', 'indicator_type', 'indicator_id', 'indicator', id, id));
				} else {
					$(this).attr('href',
						update_query_parameter($(this).attr('href'), 'indicator_id', 'indicator', id));
				}
				$(this).attr('href',
					remove_query_parameter($(this).attr('href'), 'view_type', 'view_type'));
			});
   }
	}

	// get the new json data and update the appropriate components
   function load_state(link, id, datai)
   {
//console.log("------------------- load state");
			// update the url to get the data
		  var query;
			// json data path
		   if (link.search('summary') !== -1)
		   {
		      query = update_query_parameter(gon.indicator_menu_data_path_summary, 'indicator_type_id', 'indicator_type', id);
		   }
		   else
		   {
		      query = update_query_parameter(gon.indicator_menu_data_path, 'indicator_id', 'indicator', id);
		   }

			// show loading wheel
//console.log("turning on loading wheel");
			$("#map-loading").fadeIn(300);

			// scroll to the top
//console.log("scrolling to top");
			$('html,body').animate({
				scrollTop: 0
				},
				500
			);


			// reset popups
//console.log("removing popups");
      close_popup(current_highlighted_feature);
//      removeFeaturePopups();
//    	map.events.un({'mousemove': updatePopUpPosition});
/*			map.controls[1].activate();
			$.each(map.popups, function(index, value){
				map.removePopup(map.popups[index]);
			});
*/
//console.log("unhighlighting shapes");
			// if shape is highlighted, turn it off
//			unhighlight_shape(current_highlighted_feature, false);

			// reset the map extent based on the vector parent bounds
//console.log("resting map extent");
			set_map_extent();


			// get the data json and process it
			$.get(query, function(data){
				// save the data to a global variable for later use
//console.log("saving data");
				json_data = data;

//console.log("updating urls");
				// update the links
				update_link_parameters(link, id);

//console.log("binding data to shapes");
				// update the shapes with the new values/colors
				bindDataToShapes(vector_child.features);

//console.log("creating scales/legend");
				// create the scales and legend
				create_scales_legend();

//console.log("highlighting link");
				// highlight the link that was clicked on
				highlight_indicator(link);

//console.log("trigger");
				// indicate that the child layer has loaded
				// - do not wait for the datatable to be loaded
				$("div#map").trigger("child_layer_loaded");

//console.log("highlighting column");
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

//console.log("---------- finish");
			});
   }


	// create the state for the link that was just clicked on
	function create_push_state(link, id, datai, sub_title, dt_highlight_shape){
		// create new page title
		var seperator = ' » ';
		var new_title = '';
		var old_title_ary = document.title.split(seperator);
		for(var i=0; i<old_title_ary.length;i++){
		 if (i==1)
			new_title += sub_title;
		 else
			new_title += old_title_ary[i];

			if (i < old_title_ary.length-1)
				new_title += seperator;
		}

		var new_url;
    new_url = link; // no need to change anything since the link coming in already has all the params set.
/*
		if (link.search('summary') !== -1)
		{
//			new_url = update_query_parameter(link, 'indicator_type_id', 'indicator_type', id);
			if (get_query_parameter(link, 'indicator_type_id', 'indicator_type') == undefined){
				new_url =
					replace_query_parameter(link, 'indicator_id', 'indicator', 'indicator_type_id', 'indicator_type', id, id);
			} else {
				new_url =
					update_query_parameter(link, 'indicator_type_id', 'indicator_type', id);
			}
		} else {
//			new_url = update_query_parameter(link, 'indicator_id', 'indicator', id);
			if (get_query_parameter(link, 'indicator_id', 'indicator') == undefined){
				new_url =
					replace_query_parameter(link, 'indicator_type_id', 'indicator_type', 'indicator_id', 'indicator', id, id);
			} else {
				new_url =
					update_query_parameter(link, 'indicator_id', 'indicator', id);
			}
		}
*/

//console.log("old url = " + link);
//console.log("new url = " + new_url);

  History.pushState({link:link, id:id, datai:datai, dt_highlight_shape:dt_highlight_shape},
			new_title, new_url);

	}

	// add click functions to all indicator menu items
	var jq_indicators = $("#indicator_menu_scale .menu_list a.menu_list_link")
	jq_indicators.click(function(){
		var link = $(this).attr('href'),
				title = $(this).attr('title'),
				id;

		if (link.search('summary') !== -1) {
			id = get_query_parameter(link, 'indicator_type_id', 'indicator_type');
		} else {
			id = get_query_parameter(link, 'indicator_id', 'indicator');
		}

		// reset highlight since indicator clicks do not have highlight
		gon.dt_highlight_shape = null;

		// get the data-i of the th tag that has the same text as the link's title
		var table_headers = $('#data-table tr th');
		var datai = null;
		// if the title does not exist, use the link text
		if (title == undefined || title == null){
			title = $(this).text().trim();
		}
		for (var i=0;i<table_headers.length;i++){
			// have to test for header text because ff gets it one way and ie another
			var header_text = table_headers[i].textContent? table_headers[i].textContent : table_headers[i].innerText;
			var index = title.trim().indexOf(header_text.trim());
			if (index != -1) {
				datai = $(table_headers[i]).attr('data-i');
				break;
			}
		}
		// load the new data
		create_push_state(link, id, datai, title, null);
		return false;
	});


	// click function for links in data table
	function data_table_link_click()
	 {
    var ths = $(this);
		var link = ths.attr('href'),
				id;

		if (link.search('summary') !== -1) {
			id = get_query_parameter(link, 'indicator_type_id', 'indicator_type');
		} else {
			id = get_query_parameter(link, 'indicator_id', 'indicator');
		}

		// save the shape to highlight
		var highlight_shape = decodeURIComponent(get_query_parameter(link, 'highlight_shape', 'highlight_shape'));

		// get the data-i of the td tag that has the link that was just clicked
		var datai = ths.parent().data('i');

		// create the new title
		var title = $('#dt_dd_switcher option[data-i=' + datai + ']').text() + ' - ' + highlight_shape

		// load the new data
		create_push_state(link, id, datai, title, highlight_shape);

		return false;
	}


	// add click functions to all links in data table
	var jq_data_table = $("table#data-table");
	window.a_clicks_bound = false;
	jq_data_table.live({
    'DOMNodeInserted': function()
    {
     if (window.a_clicks_bound)
     {
       return;
     }
     $(this).children("tbody:first").find("a").unbind().click(data_table_link_click);
     window.a_clicks_bound = true;
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


    // Bind to StateChange Event
    History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
        var State = History.getState(); // Note: We are using History.getState() instead of event.state
        if ('link' in State.data){
//          History.log(State.data, State.title, State.url);

				  // save the highlight shape variable
				  gon.dt_highlight_shape = State.data.dt_highlight_shape;

				  // load the json and reset the page
				  load_state(State.data.link, State.data.id, State.data.datai);
        } else {
          // ajax link does not exist
        }
    });

});
