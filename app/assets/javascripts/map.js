if (gon.openlayers){
	// Define global variables which can be used in all functions
	var map, vector_parent, vector_child, vector_live_data, json_data;
	var vector_parent_loaded = false;
	var vector_child_loaded = false;
	var scale_nodata = [];
	var color_nodata = gon.no_data_color;
	scale_nodata['name'] = gon.no_data_text;
	scale_nodata['color'] = color_nodata;
	var opacity = "0.6";
	var map_opacity = "0.7";
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

	// gon.indicator_number_format will not exist for the summary view
	// so have to create local variable to store value;
	var number_format = "";

	OpenLayers.ImgPath = gon.openlayers_img_path;


	// Function called from body tag
	function map_init(){
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
//		map_layer = new OpenLayers.Layer.OSM("baseMap", gon.tile_url, {isBaseLayer: true, opacity: map_opacity, tileOptions: {crossOriginKeyword: null} });
		map_layer = new OpenLayers.Layer.XYZ("baseMap", gon.tile_url, {isBaseLayer: true, opacity: map_opacity, tileOptions: {crossOriginKeyword: null} });

		vector_parent = new OpenLayers.Layer.Vector("Base Layer", {styleMap: vectorBaseStyle});

		vector_child = new OpenLayers.Layer.Vector("Child Layer");

		map.addLayers([map_layer, vector_parent, vector_child]);
//		vector_live_data = new OpenLayers.Layer.Vector("Live Data Layer", {styleMap: build_live_data_shape_completed_styles()});
//		map.addLayers([map_layer, vector_parent, vector_live_data, vector_child]);

/*
		// set the z-index of the layers
		map_layer.setZIndex(100);
		vector_parent.setZIndex(200);
		vector_child.setZIndex(300);
		vector_live_data.setZIndex(800);
*/

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

	function set_map_extent() {
		if (vecotr_parent_bounds !== undefined){
		  map.zoomToExtent(vecotr_parent_bounds);
		  winW = window_width();
			if (winW > map_width_indicators_fall){
				// the indicator window is on top of the map if width > 600
				// so adjust the map to account for the indicator window
				//180 for 1345 screen width
				map.moveByPx(winW / 7.472, 0);
			}
		}
	}

	// load the features and set the bound
	// after protocol has read in json
  var vecotr_parent_bounds;
	function load_vector_parent(resp){
		if (resp.success()){
			var features = resp.features;
		  var bounds;
			if(features) {
		    if(features.constructor != Array) {
		        features = [features];
		    }
		    for(var i=0; i<features.length; ++i) {
		      if (!vecotr_parent_bounds) {
		          vecotr_parent_bounds = features[i].geometry.getBounds();
		      } else {
		          vecotr_parent_bounds.extend(features[i].geometry.getBounds());
		      }
		    }
		    vector_parent.addFeatures(features);

				// set the map extent based on the vector parent bounds
				set_map_extent();

				// indicate that the parent layer has loaded
				$("div#map").trigger("parent_layer_loaded");
		  } else {
        console.log('vector_parent - no features found');
		  }
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

				}
			}
		}
		return features;
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
			$('#map-loading').fadeOut(1000);
//			$('#map-loading').fadeOut(1000, function (){ $(this).remove(); });
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

	// create a point at the center of each shape
	// that will be filled with the pattern external graphic if the rules
	// are satisfied
	function build_live_data_points(features) {
		var point_features = [];

		for (var i=0;i<features.length;i++){
			point_features.push(new OpenLayers.Feature.Vector(
				features[i].geometry.getCentroid(),
				{precincts_completed_precent: features[i].attributes.precincts_completed_precent}
			));
		}
		if (point_features.length > 0){
			vector_live_data.addFeatures(point_features);
		}
	}

	// go through each feature and get unique indicator names and their colors
	function populate_summary_data(){
		if (gon.view_type == gon.summary_view_type_name) {
			gon.indicator_scale_colors = [color_nodata];
			gon.indicator_scales = [scale_nodata];

		  var names = [gon.indicator_scales[0].name];
		  for (var i=0; i<vector_child.features.length; i++)
		  {
		    // see if name has already been saved
		    if (names.indexOf(vector_child.features[i].attributes.value) == -1){
		      // save name and color
		      gon.indicator_scale_colors[gon.indicator_scales.length] = vector_child.features[i].attributes.color;
		      gon.indicator_scales[gon.indicator_scales.length] = {"name":vector_child.features[i].attributes.value};
		      // record the name so can easily test for new unique name in if statement above
		      names[gon.indicator_scales.length] = vector_child.features[i].attributes.value;
		    }

				// see if the number format has already been saved
				if (number_format.length == 0 && vector_child.features[i].attributes.number_format != null){
					number_format = vector_child.features[i].attributes.number_format;
				}
		  }

		  // add style map
		  vector_child.styleMap = build_indicator_scale_styles();
			vector_child.redraw();
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

		  return new OpenLayers.StyleMap({'default': theme, 'select': {'fillOpacity': 0.9, 'strokeColor': '#000','strokeWidth': 2}});
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

	// build the styles and rules for live data
	// that will highlight the shapes that have incomplete precincts
	function build_live_data_shape_completed_styles() {
		var rule;
		var theme = new OpenLayers.Style({
        pointRadius: 0,
				strokeWidth: 2,
				strokeColor: '#000'
		});
//		var style = {pointRadius: 8, externalGraphic: "/assets/pattern.png"};
		var style = {pointRadius: 3, fill: false};

	  rule = new OpenLayers.Rule({
		name: "precincts not completed",
		filter: new OpenLayers.Filter.Logical({
		      type: OpenLayers.Filter.Logical.AND,
		      filters: [
		          new OpenLayers.Filter.Comparison({
		              type: OpenLayers.Filter.Comparison.LESS_THAN,
		              property: "precincts_completed_precent",
		              value: 100
		          }),
		          new OpenLayers.Filter.Comparison({
									// using > instead of >= because >= will include null values and don't want
									type: OpenLayers.Filter.Comparison.GREATER_THAN,
		              property: "precincts_completed_precent",
		              value: 0
		          })
		      ]
		      }),
					symbolizer: {pointRadius: 3, fill: false}
	  });

	  rule1 = new OpenLayers.Rule({
		name: "precincts not completed",
  	filter: new OpenLayers.Filter.Comparison({
      type: OpenLayers.Filter.Comparison.EQUAL_TO,
      property: "precincts_completed_precent",
      value: 100 }),
			symbolizer: {pointRadius: 3, fillColor: '#000000'}
	  });

		theme.addRules([rule, rule1]);
	  return new OpenLayers.StyleMap({'default':theme});
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


	/*  Feature popup functions  */
	// Remove feature popups
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
	var popup;
	function makeFeaturePopup(feature_data, stright, close_button, close_button_func, disable_move)
	{
		if (typeof(stright) === "undefined")
		  stright = false;
		if (stright && $(".olPopupCloseBox:first").length !== 0)
		  return ;

      // remove all popups
			removeFeaturePopups();
  	  map.events.un({'mousemove': updatePopUpPosition});

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
		//new OpenLayers.LonLat(max_Y_lon, max_Y),
		feature_center,
//		new OpenLayers.LonLat(min_X+x/100*50, min_Y+y/100*70),
		null,
		$("#popup_svg").html(),
		null,
		true);
      popup.autoSize = true;

			// always have the popup above the mouse
      popup.calculateRelativePosition = function(){
         return "tr";
      };

	   map.addPopup(popup);

     // pass in center of feature as starting point
	   PopupIndicatorCheckPosition(map.getViewPortPxFromLonLat(feature_center));

		// when mouse moves, also move the popup
		if (typeof(disable_move) === "undefined"){
  		map.events.register('mousemove', map, updatePopUpPosition);
    } else {
    	map.events.un({'mousemove': updatePopUpPosition});
    }

    // close button
		if (close_button)
		{
		  var popup_close = $(".olPopupCloseBox:first");
		  popup_close.css({
		    "width": "30px",
		    "height": "30px",
		    "background-image": "url('/assets/popup-close.png')",
		    "background-position": "right top",
				"background-repeat": "no-repeat",
		    "cursor": "pointer"
		  }).click(close_button_func);
		}
	}

  // generate the popup for the selected feature
  function create_popup(feature){
console.log('creating popup');
    $('#map_popup_container').fadeOut(100);
    $('#map_popup_container').empty();

    $('#map_popup_container').html(build_popup(getShapeData(feature)));
    $('#map_popup_container').fadeIn(100);
  }

	// show the popups
	function hover_handler (feature)
	{
		// Create the popup
//		makeFeaturePopup(feature);
    create_popup(feature);
	}

	// hide the popups
	function mouseout_handler (feature)
	{
//		removeFeaturePopups();
    $('#map_popup_container').fadeOut(100);
    $('#map_popup_container').empty();
	}


	// load the hidden form with the values so the export link works
	function load_hidden_form()
	{
    // update gon variables needed for svg export
    gon.indicator_name = json_data['indicator']['name'];
    gon.indicator_name_abbrv = json_data['indicator']['name_abbrv'];
    gon.indicator_description = json_data['indicator']['description'];
    gon.view_type = json_data['view_type'];
    gon.map_title = $(document).attr('title');


		if (gon.indicator_name || (gon.view_type == gon.summary_view_type_name)){
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
				$("#hidden_form_indicator_name").val(gon.indicator_name);
				$("#hidden_form_indicator_name_abbrv").val(gon.indicator_name_abbrv);
				$("#hidden_form_indicator_description").val(gon.indicator_description);
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

	// check for live data updates every 1 minute
	if (gon.data_type == gon.data_type_live){
		// on page load if there is a dataset that is newer than this one, show message
		if (gon.data_set_id_most_recent !== null &&
				parseInt(gon.data_set_id_most_recent) > parseInt(gon.data_set_id)) {

			// update the url
			$("#new_data_available a:first").attr('href',update_query_parameter($("#new_data_available a:first").attr('href'), "data_set_id", "data_set", gon.data_set_id_most_recent));
			// show the message
			$('#new_data_available').slideDown(500);
		}

		setInterval(function() {
			$.getJSON(
				'/' + I18n.locale + '/json/current_data_set/event/' + gon.event_id + '/data_type/' + gon.data_type + '.json',
				function(response) {
					// if the response value is > current data set id,
					// show msg that new data is available
					if (response !== null && response > parseInt(gon.data_set_id)){
						// update the url
						$("#new_data_available a:first").attr('href',update_query_parameter($("#new_data_available a:first").attr('href'), "data_set_id", "data_set", response));
						// show the message
						$('#new_data_available').slideDown(500);
					} else {
						$('#new_data_available').slideUp(500);
					}
				}
			);
		}, 1000 * 60 * 1);
	}


}
