//= require i18n
//= require i18n/translations
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require twitter/bootstrap
//= require fancybox

//= require vendor_map
//= require jquery.tablesorter.min
//= require data_table_loader
//= require data_table
//= require d3.v2.min
//= require jquery.slimscroll

//= require data
//= require event_custom_views
//= require event_indicator_relationships
//= require event_menu
//= require events
//= require indicator_menu_scale
//= require map_popup_svg
//= require messages
//= require news
//= require shapes

//= require map.export

//= require ajax_map

// set focus to first text box on page
$(document).ready(function(){
  $("input:visible:first").focus();

	// to load pop-up window for export help
  $("a.fancybox").fancybox();


  var fade_after = 10,
  navbar = $('.navbar.navbar-fixed-top');
  $(window).scroll(function ()
  {
    var y = window.scrollY;
    if (y > fade_after)
    {
      navbar.animate({opacity: .93}, 'fast');
    }
    else
    {
      navbar.animate({opacity: 1}, 'fast');
    }
  });

});


function full_height (element)
{
  if (element.length == 0)
  {
    return 0;
  }
  var values =
  [
    element.height(),
    element.css('margin-top'),
    element.css('margin-bottom'),
    element.css('padding-top'),
    element.css('padding-bottom'),
    element.css('border-top-width'),
    element.css('border-bottom-width')
  ],
  h = 0;
  for (i in values)
  {
    h += parseInt(values[i]);
  }
  return h;
}

function window_width ()
{
  var winW;
  if (document.body && document.body.offsetWidth)
  {
    winW = document.body.offsetWidth;
  }
  else if (document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.offsetWidth)
  {
    winW = document.documentElement.offsetWidth;
  }
  else if (window.innerWidth)
  {
    winW = window.innerWidth;
  }
  return winW;
}


if (gon.openlayers){

  function pan_click_handler ()
  {
    var d,
    math = Math;
    switch (this.className)
    {
      case 'north':
        d = [0, -1];
        break;
      case 'west':
        d = [-1, 0];
        break;
      case 'east':
        d = [1, 0];
        break;
      case 'south':
        d = [0, 1];
        break;
    }
    for (i = 1; i <= 50; i ++)
    {
      setTimeout(function (k)
      {
        k1 = math.pow(51 - k, 5) / .5e+8;
        map.moveByPx(d[0] * k1, d[1] * k1);
        if (k == 50)
        {
          map.layers[2].redraw();
        }
      }, i * 20, i);
    }
  }


	// Define global variables which can be used in all functions
	var map, vector_parent, vector_child, json_data;
	var vector_parent_loaded = false;
	var vector_child_loaded = false;
	var scale_nodata = [];
	var color_nodata = gon.no_data_color;
	scale_nodata['name'] = gon.no_data_text;
	scale_nodata['color'] = color_nodata;
	var opacity = "0.6";
	var map_opacity = "0.9";
	var minZoom = 7;
	var map_width_indicators_fall = 667;


	// define number formatting for data values
	var numFormat = new NumberFormat();
	numFormat.setInputDecimal(I18n.t("number.format.separator"));
	numFormat.setSeparators(true, I18n.t("number.format.delimiter"));
	numFormat.setPlaces(I18n.t("number.format.precision"), false);

	// World Geodetic System 1984 projection
	var WGS84 = new OpenLayers.Projection("EPSG:4326");
	// WGS84 Google Mercator projection
	var WGS84_google_mercator = new OpenLayers.Projection("EPSG:900913");
/*
	// gon.indicator_number_format will not exist for the summary view
	// so have to create local variable to store value;
	var number_format = "";
*/
	OpenLayers.ImgPath = gon.openlayers_img_path;


	// Function called from body tag
	function map_init(){
/*
		// add no data to scales
		if (json_data["indicator"]["scale_colors"] && json_data["indicator"]["scales"]){
			json_data["indicator"]["scale_colors"].splice(0,0,color_nodata);
			json_data["indicator"]["scales"].splice(0,0,scale_nodata);
		}

		// if gon.indicator_number_format has a value, save it
		if (gon.indicator_number_format){
			number_format = gon.indicator_number_format;
		}
*/
		var options = {
		  projection: WGS84_google_mercator,
		  displayProjection: WGS84,
		  units: 'm',
		  maxResolution: 156543.0339,
		  maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34),
        restrictedExtent: new OpenLayers.Bounds(4225848.9623142, 4905270.1993499, 5870773.8107822, 5683093.3990715),
//	  restrictedExtent: new OpenLayers.Bounds(4277826.1415408, 4844120.5767302, 5378519.3486942, 5577916.0481658),
		  theme: null,
		  controls: []
		};

		var vectorBaseStyle = new OpenLayers.StyleMap({
		    "default": new OpenLayers.Style({
		        fillColor: "#bfbe8d",
		        strokeColor: "#444444",
		        strokeWidth: 3,
		        fillOpacity: 0.1
		    })
		});


    /* ADJUSTING MAP HEIGHT */
    var minHeight = 500,//full_height($('#indicator_menu_scale')),
    offsetTop = $('#map-container').offset().top,
    workHeight = $(window).innerHeight(),
    footnoteHeight = full_height($('#footnote')),
    marginBottom = 10,
    mapHeight = workHeight - offsetTop - footnoteHeight - marginBottom;
    if (mapHeight < minHeight)
    {
      mapHeight = minHeight;
    }
    $('#map').css('height', mapHeight);


		map = new OpenLayers.Map('map', options);

		map.addControl(new OpenLayers.Control.Navigation({zoomWheelEnabled: false}));
 /*
		map.addControl(new OpenLayers.Control.PanZoom(), new OpenLayers.Pixel(5, 25));
 */

    $('#map-container .controls .pan a').click(pan_click_handler);

		map.events.register('zoomend', this, function(){
		  var zoomLevel = map.zoom;
			// if the window width is small enough so that that indicators have fallen below the map,
			// the country view of the map is to wide for the default minZoom
			if (window_width() < map_width_indicators_fall)
				minZoom = 6;
		  if (zoomLevel < minZoom)
		    map.zoomTo(minZoom);
		});

		// include tileOptions to avoid getting cross-origin image load errors
		map_layer = new OpenLayers.Layer.OSM("baseMap", gon.tile_url, {isBaseLayer: true, opacity: map_opacity, tileOptions: {crossOriginKeyword: null} });

		vector_parent = new OpenLayers.Layer.Vector("Base Layer", {styleMap: vectorBaseStyle});

		vector_child = new OpenLayers.Layer.Vector("Child Layer");

		map.addLayers([map_layer, vector_parent, vector_child]);


		// load the base layer
		var prot = new OpenLayers.Protocol.HTTP({
			url: gon.shape_path,
			format: new OpenLayers.Format.GeoJSON({
		    'internalProjection': map.baseLayer.projection,
		    'externalProjection': WGS84_google_mercator
			})
		});

		var strat = [new OpenLayers.Strategy.Fixed()];
		vector_parent.protocol = prot;
		vector_parent.strategies = strat;

		// create event to load the features and set the bound
		// after protocol has read in json
		prot.read({
				callback: load_vector_parent
		});

		// load the child layer
		var prot2 = new OpenLayers.Protocol.HTTP({
			url: gon.children_shapes_path,
			format: new OpenLayers.Format.GeoJSON({
		    'internalProjection': map.baseLayer.projection,
		    'externalProjection': WGS84_google_mercator
			})
		});


		vector_child.protocol = prot2;
		vector_child.strategies = strat;

		// create event to load the features and set the bound
		// after protocol has read in json
		window.ajax_prot = prot2;
		window.ajax_layer = vector_child;
		prot2.read({
				callback: load_vector_child
		});


		// Selection
		var select_child = new OpenLayers.Control.SelectFeature(vector_child, {
		  hover: true,
		  onSelect: hover_handler,
			onUnselect: mouseout_handler,
			clickFeature: click_handler
		});

		map.addControls([select_child]);

		select_child.activate();

	}

	// load the features and set the bound
	// after protocol has read in json
	function load_vector_parent(resp){
		if (resp.success()){
			var features = resp.features;
		  var bounds;
			if(features) {
		    if(features.constructor != Array) {
		        features = [features];
		    }
		    for(var i=0; i<features.length; ++i) {
		      if (!bounds) {
		          bounds = features[i].geometry.getBounds();
		      } else {
		          bounds.extend(features[i].geometry.getBounds());
		      }
		    }
		    vector_parent.addFeatures(features);

     /*
		    var shapeWidth = bounds.right - bounds.left;
		    var worldWidth = map.maxExtent.right - map.maxExtent.left;
		    console.log(map.maxExtent.right, map.maxExtent.left);
		    console.log(bounds.right, bounds.left);
		    var increaseK = 1 + shapeWidth / worldWidth * 50;
		    console.log(increaseK);
		    if (increaseK > 1.1)
		    {
		      increaseK = 1.1;
		    }
		    else if (increaseK < 1.03)
		    {
		      increaseK = 1.03;
		    }
		    console.log(increaseK);
		    bounds.right = bounds.right * increaseK;
		  //map.restrictedExtent.right = map.restrictedExtent.right * increaseK;
		 */
		    map.zoomToExtent(bounds);
		    winW = window_width();
				if (winW > map_width_indicators_fall){
					// the indicator window is on top of the map if width > 600
					// so adjust the map to account for the indicator window
				  //180 for 1345 screen width
				  map.moveByPx(winW / 7.472, 0);
				}


				// indicate that the parent layer has loaded
				$("div#map").trigger("parent_layer_loaded");
		  } else {
        console.log('vector_parent - no features found');
		  }
		}
	}

	function recursiveSearch(niddle, array)
	{
		var i = 0;

		while (i < array.length)
		{
			console.log(i);
			console.log(array[i]);

			if (array[i] instanceof Array ||
				array[i] instanceof Object)
			{
				recursiveSearch(niddle, array[i]);
			}
			else if (typeof array[i] === typeof niddle && array[i] === niddle)
			{
				return array.color;
			}

			i++;
		}
	}



	// pull the data value and color from the data json and put into the feature
	// - also take the feature title_location and push into the data json
	function bindDataToShapes(features)
	{
		for (var i in features)
		{
			var feature = features[i];
			for (var j in json_data["shape_data"])
			{
				var json_shape_data = json_data["shape_data"][j][0].shape_values;
				if (feature.data.id === json_shape_data.shape_id)
				{
					// put the color and value into the feature
					feature.data.color = json_shape_data.color;
					feature.attributes.color = json_shape_data.color;
					feature.data.value = json_shape_data.value;
					feature.attributes.value = json_shape_data.value;

					// move the title_location into the data json
					json_shape_data.title_location = feature.attributes.title_location;

					// if this is summary set indicator description from gon variable
      		if (json_data["view_type"] == gon.summary_view_type_name) {
      		  json_data["indicator"]["description"] = gon.summary_indicator_description
    		  }
				}
			}
		}
		return features;
	}

  // create the scales and legend
  function create_scales_legend(){
    // empty existing legend content
    $("#indicator_description").empty();
    $("#legend").empty();

		// if this is summary view, create the scales
		create_summary_scales();
	  // add style map
	  vector_child.styleMap = build_indicator_scale_styles();
		vector_child.redraw();
		// now that the child vector is loaded, lets show the legend
		draw_legend();
		// now load the values for the hidden form
		load_hidden_form();
  }

	// load the features for the children into the vector_child layer
	function load_vector_child(resp){
		if (resp.success()){
			// get the event data for these shapes
			$.get(gon.data_path, function(data) {
		    // save the data to a global variable for later user
				json_data = data;
				// add the features to the vector layer
				vector_child.addFeatures(bindDataToShapes(resp.features));

		    // create the scales and legend
		    create_scales_legend();

				// indicate that the child layer has loaded
				// - do not wait for the datatable to be loaded
				$("div#map").trigger("child_layer_loaded");

				// load the table of data below the map
        load_data_table();
			});
		} else {
		  console.log('vector_child - no features found');
		}
	}

	// record that the parent vector layer was loaded
	$("div#map").bind("parent_layer_loaded", function(event){
		vector_parent_loaded = true;
		after_vector_layers_loaded();
	});

	// record that the child vector layer was loaded
	$("div#map").bind("child_layer_loaded", function(event){
		vector_child_loaded = true;
		after_vector_layers_loaded();
	});

	// run code after the parent and child vector layers are loaded
	function after_vector_layers_loaded(){
		if (vector_parent_loaded && vector_child_loaded) {
			$('#map-loading').fadeOut(100);
			// if gon.dt_highlight_shape exists, highlight the shape and turn on the popup
			if (gon.dt_highlight_shape)
			{
		    if (typeof highlight_shape == 'function')
		    {
			    var f = highlight_shape();
				  if (f !== undefined && f !== false && f != null)
				  {
		    		mapFreeze(f);
		    	}
		    }
		    else
		    {
		      console.log('highlight_shape function not found, check the script that loads it');
		    }
			}
		}
	}

	// go through each feature and get unique indicator names and their colors
	function create_summary_scales(){
		if (json_data["view_type"] == gon.summary_view_type_name) {

      // create unique names array, starting with the no_data item which is first
		  var names = [json_data["indicator"]["scales"][0].name];

		  for (var i=0; i<vector_child.features.length; i++)
		  {
		    // see if name has already been saved
		    if (names.indexOf(vector_child.features[i].attributes.value) == -1){
		      // save name and color
		      json_data["indicator"]["scale_colors"][json_data["indicator"]["scales"].length] = vector_child.features[i].attributes.color;
		      json_data["indicator"]["scales"][json_data["indicator"]["scales"].length] = {"name":vector_child.features[i].attributes.value};
		      // record the name so can easily test for new unique name in if statement above
		      names[json_data["indicator"]["scales"].length] = vector_child.features[i].attributes.value;
		    }

				// see if the number format has already been saved
				if (json_data["indicator"]["number_format"] != null && vector_child.features[i].attributes.number_format != null){
					json_data["indicator"]["number_format"] = vector_child.features[i].attributes.number_format;
				}
		  }
		}
	}

	// Legend
	function draw_legend()
	{
		var legend = $('#legend');

		if (json_data["view_type"] == gon.summary_view_type_name) {
		  // create legend
		  for (var i=0; i<json_data["indicator"]["scales"].length; i++)
		  {
		    legend.append('<li><span style="background-color: ' + json_data["indicator"]["scale_colors"][i] + '; opacity: ' + opacity + '; filter:alpha(opacity=' + (parseFloat(opacity)*100) + ');"></span> ' + json_data["indicator"]["scales"][i].name + '</li>');
			}
		} else  if (json_data["indicator"]["scales"] && json_data["indicator"]["scales"].length > 0 && json_data["indicator"]["scale_colors"] && json_data["indicator"]["scale_colors"].length > 0){
			var color = "";
			for (var i=0; i<json_data["indicator"]["scales"].length; i++){
				// if the scale has a color, use it, otherwise use app color
				if (json_data["indicator"]["scales"][i].color && json_data["indicator"]["scales"][i].color.length > 0){
					color = json_data["indicator"]["scales"][i].color;
				} else {
					color = json_data["indicator"]["scale_colors"][i];
				}

		    legend.append('<li><span style="background-color: ' + color + '; opacity: ' + opacity + '; filter:alpha(opacity=' + (parseFloat(opacity)*100) + ');"></span> ' + format_number(json_data["indicator"]["scales"][i].name) + '</li>');
			}
		} else {
			// no legend
			legend.innerHTML = "";
		}

    // show the indicator descritpion if provided
		if (json_data["indicator"]["description"]) {
			$('#indicator_description').append(json_data["indicator"]["description"]);
			$('#indicator_description').slideDown(500);
		} else {
			$('#indicator_description').innerHTML = "";
			$('#indicator_description').hide(0);
		}

		$('#legend_container').slideDown(500);
	}

	// build the color mapping for the indicators
	function build_indicator_scale_styles() {
		var rules = [];
		var theme = new OpenLayers.Style({
		    fillColor: "#cfce9d",
		    strokeColor: "#444444",
		    strokeWidth: 1,
		    cursor: "pointer",
		    fillOpacity: opacity
		});
		if (json_data["indicator"]["scales"] && json_data["indicator"]["scales"].length > 0 && json_data["indicator"]["scale_colors"] && json_data["indicator"]["scale_colors"].length > 0){

			// look at each scale and create the builder
			for (var i=0; i<json_data["indicator"]["scales"].length; i++){
				var isFirst = i==1 ? true : false // remember if this is the first record (we want i=1 cause i=0 is no data)
				var name = json_data["indicator"]["scales"][i].name;
				var color = "";
				// if the scale has a color, use it, otherwise use app color
				if (json_data["indicator"]["scales"][i].color && json_data["indicator"]["scales"][i].color.length > 0){
					color = json_data["indicator"]["scales"][i].color;
				} else {
					color = json_data["indicator"]["scale_colors"][i];
				}

				// look in the name for >, <, or -
				// - if find => create appropriate comparison filter
				// - else use ==
				var indexG = name.indexOf(">");
				var indexL = name.indexOf("<");
				var indexB = name.indexOf("-");
				if (indexG >= 0) {
					// set to >
					if (indexG == 0){
						rules.push(build_rule(color, OpenLayers.Filter.Comparison.GREATER_THAN, name.slice(1)));
					}
					else if (indexG == name.length-1) {
						rules.push(build_rule(color, OpenLayers.Filter.Comparison.GREATER_THAN, name.slice(0, indexG-1)));
					}
					else {
						// > is in middle of string.  can not handle
					}
				} else if (indexL >= 0) {
					// set to <
					if (indexL == 0){
						rules.push(build_rule(color, OpenLayers.Filter.Comparison.LESS_THAN, name.slice(1)));
					}
					else if (indexL == name.length-1) {
						rules.push(build_rule(color, OpenLayers.Filter.Comparison.LESS_THAN, name.slice(0, indexL-1)));
					}
					else {
						// > is in middle of string.  can not handle
					}
				} else if (indexB >= 0) {
					// set to between
					rules.push(build_rule(color, OpenLayers.Filter.Comparison.BETWEEN, name.slice(0, indexB), name.slice(indexB+1), isFirst));
				} else {
					// set to '='
					rules.push(build_rule(color, OpenLayers.Filter.Comparison.EQUAL_TO, name));
				}
			}

		  theme.addRules(rules);
		}

		  return new OpenLayers.StyleMap({'default':theme, 'select': {'fillOpacity': 0.9, 'strokeColor': '#000','strokeWidth': 2}});
	}

	function build_rule(color, type, value1, value2, isFirst){
		if (value1 && parseInt(value1)) {
			  value1 = parseInt(value1);
		}
		if (value2 && parseInt(value2)) {
			  value2 = parseInt(value2);
		}

		if (type == OpenLayers.Filter.Comparison.BETWEEN && value1 && value2){
			  return new OpenLayers.Rule({
				name: "between " + value1 + " and " + value2,
				filter: new OpenLayers.Filter.Logical({
				      type: OpenLayers.Filter.Logical.AND,
				      filters: [
				          new OpenLayers.Filter.Comparison({
				              type: OpenLayers.Filter.Comparison.LESS_THAN_OR_EQUAL_TO,
				              property: "value",
				              value: value2
				          }),
				          new OpenLayers.Filter.Comparison({
				              // if this is the first scale item, use >= to make sure the bottom value is included in the range
							type: isFirst == true ? OpenLayers.Filter.Comparison.GREATER_THAN_OR_EQUAL_TO : OpenLayers.Filter.Comparison.GREATER_THAN,
				              property: "value",
				              value: value1
				          })
				      ]
				      }),
			      symbolizer: {"Polygon": {'fillColor': color, 'fillOpacity': opacity}}
			  });
		} else if (type && value1){
			  return new OpenLayers.Rule({
				name: type + " " + value1,
			    	filter: new OpenLayers.Filter.Comparison({
				      type: type,
				      property: "value",
				      value: value1 }),
			      symbolizer: {"Polygon": {'fillColor': color, 'fillOpacity': opacity}}
			  });
		}
	}




	function click_handler (feature)
	{
		// if the feature has children, continue
		if (feature.attributes.has_children == true){
			// add/update the shape_id parameter
			var url = update_query_parameter(window.location.href, "shape_id", "shape", feature.attributes.id);

			// add/update the shape_type_id parameter
			url = update_query_parameter(url, "shape_type_id", "shape_type", feature.attributes.shape_type_id);

			// add/update the event_id parameter
			// - when switching between event types, the event id is not set in the url
			//   so it needs to be added
			url = update_query_parameter(url, "event_id", "event", gon.event_id);

			// add/update the parameter to indicate that the shape type is changing
			url = update_query_parameter(url, "change_shape_type", "change_shape", true);

			// update the parameter to indicate that the parent shape is clickable
			// clicking on the map should reset this value for it should only be true
			// when clicking on the menu navigation
			url = update_query_parameter(url, "parent_shape_clickable", "parent_clickable", false);

			// load the url
			window.location.href = url;
		}
	}

	// add/update the query paramter with the provided name and value
	// - name is the long name of the parameter (e.g., event_id)
	// - name2 is the abbreviated name that shows in the pretty url (e.g., event)
	function update_query_parameter(url, name, name2, value){
		// get the current url
		var index = url.indexOf(name + "=");
		var index2 = url.indexOf("/" + name2 + "/");
		if (index > 0){
			// found 'name=', now need to replace the value
			var name_length = name.length+1; // use +1 to account for the '='
			var indexAfter = url.indexOf("&", index+name_length);
			if (indexAfter > 0){
				// there is another paramter after this one
				url = url.slice(0, index+name_length) + value + url.slice(indexAfter);
			}else {
				// no more parameters after this one
				url = url.slice(0, index+name_length) + value;
			}
		}else if (index2 > 0) {
			// found '/name/', now need to replace the value
			var name_length = name2.length+2; // use +1 to account for the '/' at the beginning and end
			var indexAfter = url.indexOf("/", index2+name_length);
			if (indexAfter > 0){
				// there is another paramter after this one
				url = url.slice(0, index2+name_length) + value + url.slice(indexAfter);
			}else {
				// no more parameters after this one
				url = url.slice(0, index2+name_length) + value;
			}
		}else {
			// not in query string yet, add it
			// if this is the first query string, add the ?, otherwise add &
			url += url.indexOf("?") > 0 ? "&" : "?"
			url += name + "=" + value;
		}
		return url;
	}

	/*  Feature popup functions  */

	// Rmove feature popups
	function removeFeaturePopups()
	{
		$(".olPopup").each(function(){
		    $(this).remove();
		});

	}

	var max_X, max_X_lat, max_Y, max_Y_lon, min_X, min_X_lat, min_Y, min_Y_lon;

   function getLimits(feature_vertices)
   {
      max_X = 0;
      max_Y = 0;
      min_X = 99999999;
      min_Y = 99999999;

      for (var i=0;i<feature_vertices.length;i++)
      {
         if (feature_vertices[i].x > max_X)
         {
            max_X = feature_vertices[i].x;
            max_X_lat = feature_vertices[i].y;
         }

         if (feature_vertices[i].y > max_Y)
         {
            max_Y = feature_vertices[i].y;
            max_Y_lon = feature_vertices[i].x;
         }

         if (feature_vertices[i].x < min_X)
         {
            min_X = feature_vertices[i].x;
            min_X_lat = feature_vertices[i].y;
         }

         if (feature_vertices[i].y < min_Y)
         {
            min_Y = feature_vertices[i].y;
            min_Y_lon = feature_vertices[i].x;
         }
      }
   }


   function getShapeData(feature_data)
   {
      for(var i in json_data["shape_data"])
      {
         if (feature_data.data.id === json_data["shape_data"][i][0].shape_values.shape_id)
         {
            return json_data["shape_data"][i];
         }
      }
   }

	// Create the popup for the feature
	function makeFeaturePopup(feature_data, stright, close_button, close_button_func)
	{

		var popup;

		if (typeof(stright) === "undefined")
		  stright = false;
		if (stright && $(".olPopupCloseBox:first").length !== 0)
		  return ;

      // remove all popups
		removeFeaturePopups();


      // create popup

      var feature = feature_data,
          feature_vertices = feature.geometry.getVertices(),
          feature_center = feature_data.geometry.bounds.getCenterLonLat();


      getLimits(feature_vertices);

      var y = max_Y-min_Y;
      var x = max_X-min_X;


	   $("#popup_svg").empty();
	   var data = getShapeData(feature_data);
      new MapPopup().processJSON(document.getElementById("popup_svg"), data, {
                limit: 5
      });
      popup = new OpenLayers.Popup.FramedCloud("Feature Popup",
		new OpenLayers.LonLat(min_X+x/100*50, min_Y+y/100*70),
		null,
		$("#popup_svg").html(),
		null,
		true);
      popup.autoSize = true;

      popup.calculateRelativePosition = function(){
         return "tr";
      };
	   map.addPopup(popup);


	   function PopupIndicatorCheckPosition()
	   {
	      var map = $("#map"),
	          popup = $(".olPopup:first"),
	          indicators = $("#indicator_menu_scale"),
	          indicators_toggle = $("#indicator_menu_scale .toggle");
	      if (parseInt(popup.css('left')) + parseInt(popup.width()) +
	          parseInt(indicators.width()) + parseInt(indicators.css('right')) > map.width() && indicators_toggle.css('display') === "block")
	      {
	         the_indicators.hide();
	      }
	      else if (parseInt(popup.css('left')) + parseInt(popup.width()) +
	          parseInt(indicators.width()) + parseInt(indicators.css('right')) <= map.width() && indicators_toggle.css('display') === "none")
	      {
	         the_indicators.show();
	      }

	   }

	   PopupIndicatorCheckPosition();


      // close button
		if (close_button)
		{
		  var popup_close = $(".olPopupCloseBox:first");
		  popup_close.css({
		    "width": "30px",
		    "height": "30px",
		    "background-image": "url('/assets/fancybox.png')",
		    "background-position": "right top",
		    "cursor": "pointer"
		  }).click(close_button_func);
		}




	}

	// show the popups
	function hover_handler (feature)
	{
		// Create the popup
		makeFeaturePopup(feature);
	}

	// hide the popups
	function mouseout_handler (feature)
	{
		removeFeaturePopups();
	}


	// load the hidden form with the values so the export link works
	function load_hidden_form()
	{
		if (json_data["indicator"]["name"] || (json_data["view_type"] == gon.summary_view_type_name)){
			// update the url for the download data link
			$("#export-data-xls").attr('href',update_query_parameter($("#export-data-xls").attr('href'), "event_name", "event_name", gon.event_name));
			$("#export-data-xls").attr('href',update_query_parameter($("#export-data-xls").attr('href'), "map_title", "map_title", gon.map_title));
			$("#export-data-csv").attr('href',update_query_parameter($("#export-data-csv").attr('href'), "event_name", "event_name", gon.event_name));
			$("#export-data-csv").attr('href',update_query_parameter($("#export-data-csv").attr('href'), "map_title", "map_title", gon.map_title));

			$("#export-map").click(function(){
				// get the indicator names and colors
				var scales = [];
				var colors = [];
				for (i=0; i<json_data["indicator"]["scales"].length; i++){
					scales[i] = format_number(json_data["indicator"]["scales"][i].name);
					if (json_data["indicator"]["scales"][i].color && json_data["indicator"]["scales"][i].color.length > 0){
						colors[i] = json_data["indicator"]["scales"][i].color;
					} else {
						colors[i] = json_data["indicator"]["scale_colors"][i];
					}
				}

				$("#hidden_form_parent_layer").val($("#map").find("svg:eq(0)").parent().html());
				$("#hidden_form_child_layer").val($("#map").find("svg:eq(1)").parent().html());
		    $("#hidden_form_map_title").val(gon.map_title);
				$("#hidden_form_indicator_name").val(json_data["indicator"]["name"]);
				$("#hidden_form_indicator_name_abbrv").val(json_data["indicator"]["name_abbrv"]);
			  $("#hidden_form_indicator_description").val(json_data["indicator"]["description"]);
				$("#hidden_form_event_name").val(gon.event_name);
				$("#hidden_form_scales").val(scales.join("||"));
				$("#hidden_form_colors").val(colors.join("||"));
				$("#hidden_form_datetime").val((new Date()).getTime());
				$("#hidden_form_opacity").val(opacity);


				// submit the hidden form
				$('#hidden_form').submit();
			});

			// show the export links
			$('#export').slideDown(500);

		} else {
			// hide the export links
			$('#export').hide(0);
		}
	}

	function format_number(value){
		var x = "";
		// look in the name for >, <, or -
		var indexG = value.indexOf(">");
		var indexL = value.indexOf("<");
		var indexB = value.indexOf("-");
		if (indexG >= 0) {
			if (indexG == 0){
				x += value.slice(0, 1);
				x += format_number2(value.slice(1));
			}
			else if (indexG == value.length-1) {
				x += format_number2(value.slice(0, indexG-1));
				x += value.slice(indexG-1, 1);
			}
			else {
				// > is in middle of string.  can not handle
			}
		} else if (indexL >= 0) {
			if (indexL == 0){
				x += value.slice(0, 1);
				x += format_number2(value.slice(1));
			}
			else if (indexL == value.length-1) {
				x += format_number2(value.slice(0, indexL-1));
				x += value.slice(indexL-1, indexL);
			}
			else {
				// > is in middle of string.  can not handle
			}
		} else if (indexB >= 0) {
			x += format_number2(value.slice(0, indexB));
			x += value.slice(indexB,indexB+1);
			x += format_number2(value.slice(indexB+1));
		} else {
			x += format_number2(value);
		}
		return x;
	}

	// format the number to look pretty
	function format_number2(value) {
		if (isNaN(value)){
			return value;
		} else {
			numFormat.setNumber(value);
			return numFormat.toFormatted();
		}
	}
}
