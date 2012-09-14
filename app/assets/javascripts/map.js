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
//= require d3.v2.min
//= require jquery.slimscroll

//= require data
//= require event_custom_views
//= require event_indicator_relationships
//= require event_menu
//= require events
//= require indicator_menu_scale
//= require live_datasets
//= require menu_live_events
//= require map_popup_svg
//= require messages
//= require news
//= require shapes

//= require map.export


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
	var map, vector_parent, vector_child;
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

	// gon.indicator_number_format will not exist for the summary view
	// so have to create local variable to store value;
	var number_format = "";

	OpenLayers.ImgPath = gon.openlayers_img_path;


	// Function called from body tag
	function map_init(){
		// add no data to scales
		if (gon.indicator_scale_colors && gon.indicator_scales){
			gon.indicator_scale_colors.splice(0,0,color_nodata);
			gon.indicator_scales.splice(0,0,scale_nodata);
		}

		// if gon.indicator_number_format has a value, save it
		if (gon.indicator_number_format){
			number_format = gon.indicator_number_format;
		}

		var options = {
		  projection: WGS84_google_mercator,
		  displayProjection: WGS84,
		  units: 'm',
		  maxResolution: 156543.0339,
		  maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34),
//		  restrictedExtent: new OpenLayers.Bounds(4277826.1415408, 4844120.5767302, 5378519.3486942 * 1.1, 5577916.0481658),
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

		vector_child = new OpenLayers.Layer.Vector("Child Layer", {styleMap: build_indicator_scale_styles()});

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

	// load the features for the children into the vector_child layer
	function load_vector_child(resp){
		if (resp.success()){
		  vector_child.addFeatures(resp.features);
		  // if this is summary view, populate gon.indicator_scales and colors with names from json file
		  populate_summary_data();
			// now that the child vector is loaded, lets show the legend
		  draw_legend();
			// now load the values for the hidden form
			load_hidden_form();

			// indicate that the child layer has loaded
			// - do not wait for the datatable to be loaded
			$("div#map").trigger("child_layer_loaded");

			// load the table of data below the map
      load_data_table();

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
			// if gon.dt_highlight_shape exists, highlight the shape and turn on the popup
			$('#map-loading').fadeOut(1000, function (){ $(this).remove(); });
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
	//    vector_child.styleMap = null;
		  vector_child.styleMap = build_indicator_scale_styles();
			vector_child.redraw();
		}
	}

	// Legend
	function draw_legend()
	{
		var legend = $('#legend');

		if (gon.view_type == gon.summary_view_type_name) {
		  // create legend
		  for (var i=0; i<gon.indicator_scales.length; i++)
		  {
		    legend.append('<li><span style="background-color: ' + gon.indicator_scale_colors[i] + '; opacity: ' + opacity + '; filter:alpha(opacity=' + (parseFloat(opacity)*100) + ');"></span> ' + gon.indicator_scales[i].name + '</li>');
			}
		} else  if (gon.indicator_scales && gon.indicator_scales.length > 0 && gon.indicator_scale_colors && gon.indicator_scale_colors.length > 0){
			var color = "";
			for (var i=0; i<gon.indicator_scales.length; i++){
				// if the scale has a color, use it, otherwise use app color
				if (gon.indicator_scales[i].color && gon.indicator_scales[i].color.length > 0){
					color = gon.indicator_scales[i].color;
				} else {
					color = gon.indicator_scale_colors[i];
				}

		    legend.append('<li><span style="background-color: ' + color + '; opacity: ' + opacity + '; filter:alpha(opacity=' + (parseFloat(opacity)*100) + ');"></span> ' + format_number(gon.indicator_scales[i].name) + '</li>');
			}
		} else {
			// no legend
			legend.innerHTML = "";
		}

		// show the indicator descritpion if provided
		if (gon.indicator_description) {
			$('#indicator_description').append(gon.indicator_description);
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
		if (gon.indicator_scales && gon.indicator_scales.length > 0 && gon.indicator_scale_colors && gon.indicator_scale_colors.length > 0){

			// look at each scale and create the builder
			for (var i=0; i<gon.indicator_scales.length; i++){
				var isFirst = i==1 ? true : false // remember if this is the first record (we want i=1 cause i=0 is no data)
				var name = gon.indicator_scales[i].name;
				var color = "";
				// if the scale has a color, use it, otherwise use app color
				if (gon.indicator_scales[i].color && gon.indicator_scales[i].color.length > 0){
					color = gon.indicator_scales[i].color;
				} else {
					color = gon.indicator_scale_colors[i];
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

	// Create the popup for the feature
	function makeFeaturePopup(feature_data, stright, close_button, close_button_func)
	{
		if (typeof(stright) === "undefined")
		  stright = false;

		if (stright && $(".olPopupCloseBox:first").length !== 0)
		  return ;

		removeFeaturePopups();

		var popup = new OpenLayers.Popup("Feature Popup",
			feature_data.geometry.bounds.getCenterLonLat(),
			new OpenLayers.Size(400, 300),
			"",
			true);
		//popup.panMapIfOutOfView = true;
		map.addPopup(popup);

		if (close_button){
		  var popup_close = $(".olPopupCloseBox:first");
		  popup_close.css({
		    "width": "30px",
		    "height": "30px",
		    "background-image": "url('/assets/fancybox.png')",
		    "background-position": "right top",
		    "cursor": "pointer"
		  }).click(close_button_func);
		}


		// Popup coordination
		var jq_popup = $(".olPopup:first"),
		    jq_popup_content = $(".olPopupContent:first"),
		    jq_map = $("#map"),
		    jq_ol_container = jq_map.find("div:first").find("div:first"),
		    jq_popup_offset = {
		      top: function(use_def){
		       return mouse.Y-jq_map.offset().top-jq_popup.height()-10+parseInt(jq_ol_container.css('top'))*(-1);
		      },
		      left: function(use_def){
		        return mouse.X-jq_map.offset().left-jq_popup.width()/2+parseInt(jq_ol_container.css('left'))*(-1);
		      }
		    };

		/*jq_popup.css({
		  left: jq_popup_offset.left(true),
		  top: jq_popup_offset.top(true),
		  width: 0,
		  height: 0
		});*/
		if (feature_data.attributes.results.length > 0)
		{
		  new MapPopup().processJSON(document.getElementsByClassName("olPopupContent")[0], feature_data.attributes.results, {
		    limit: 5
		  });

		  jq_popup_content.css({
		    width: window.maxSVGWidth,
		    height: window.maxSVGHeight
		  });

		  jq_popup.css({
		    width: window.maxSVGWidth,
		    height: window.maxSVGHeight
		  });

		  if (!stright)
		  {
		    jq_popup.css({
		      left: jq_popup_offset.left(false),
		      top: jq_popup_offset.top(false)
		    });
		  }

		  jq_popup.css((function(){
		    // initialize nesecary variables
		    var pos = {},
		        position_left = parseInt(jq_popup.css('left')),
		        position_top = parseInt(jq_popup.css('top')),
		        popup_width = parseInt(jq_popup.width()),
		        popup_height = parseInt(jq_popup.height()),
		        parent_width = parseInt(jq_map.width()),
		        parent_height = parseInt(jq_map.height()),
		        ol_container_left = parseInt(jq_ol_container.css('left'))*(-1),
		        ol_container_top = parseInt(jq_ol_container.css('top'))*(-1);

		    // calculate positions
		      if (position_left+popup_width > parent_width)
		        position_left -= (position_left+popup_width-parent_width)+ol_container_left;

		      if (position_left < 0)
		        position_left += position_left*(-1)+ol_container_left;

		      if (position_top+popup_height > parent_height)
		        position_top -= (position_top+popup_height-parent_height)+ol_container_top;

		      if (position_top < 0)
		        position_top += position_top*(-1)+ol_container_top;

		    // set final positions
		      pos.left = position_left;
		      pos.top = position_top;

		    return pos;
		  }).apply());
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
				for (i=0; i<gon.indicator_scales.length; i++){
					scales[i] = format_number(gon.indicator_scales[i].name);
					if (gon.indicator_scales[i].color && gon.indicator_scales[i].color.length > 0){
						colors[i] = gon.indicator_scales[i].color;
					} else {
						colors[i] = gon.indicator_scale_colors[i];
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
}
