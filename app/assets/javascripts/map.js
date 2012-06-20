//= require i18n
//= require i18n/translations
//= require jquery
//= require jquery_ujs
//= require openlayers
//= require fancybox
//= require vendor_map

window.onload = map_init;

// Define global variables which can be used in all functions
var map, vector_base, vector_child;
var scale_nodata = [];
var color_nodata = gon.no_data_color;
scale_nodata['name'] = gon.no_data_text;
scale_nodata['color'] = color_nodata;
var opacity = "1.0";

// define number formatting for data values
var numFormat = new NumberFormat();
numFormat.setInputDecimal(I18n.t("number.format.separator"));
numFormat.setSeparators(true, I18n.t("number.format.delimiter"));
numFormat.setPlaces(I18n.t("number.format.precision"), false);

// World Geodetic System 1984 projection
var WGS84 = new OpenLayers.Projection("EPSG:4326");
// WGS84 Google Mercator projection
var WGS84_google_mercator = new OpenLayers.Projection("EPSG:900913");

// Function called from body tag
function map_init(){
	// add no data to scales
	if (gon.indicator_scale_colors && gon.indicator_scales){
		gon.indicator_scale_colors.splice(0,0,color_nodata);
		gon.indicator_scales.splice(0,0,scale_nodata);
	} 

	var options = {
    projection: WGS84_google_mercator,
    displayProjection: WGS84,
    units: 'm',
    maxResolution: 156543.0339,
    maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34),
    theme: null,
    controls: []  // Remove all controls
  };

	var vectorBaseStyle = new OpenLayers.StyleMap({
      "default": new OpenLayers.Style({
          fillColor: "#bfbe8d",
          strokeColor: "#777777",
          strokeWidth: 1,
          fillOpacity: opacity
      })
  });

  map = new OpenLayers.Map('map', options);

//	map_layer = new OpenLayers.Layer.OSM("baseMap", gon.tile_url, {isBaseLayer: true});

  vector_base = new OpenLayers.Layer.Vector("Base Layer", {isBaseLayer: true, styleMap: vectorBaseStyle});
//  vector_base = new OpenLayers.Layer.Vector("Base Layer", {styleMap: vectorBaseStyle});

  vector_child = new OpenLayers.Layer.Vector("Child Layer");

  map.addLayers([vector_base, vector_child]);
//  map.addLayers([map_layer, vector_base, vector_child]);

	// load the base layer
	var prot = new OpenLayers.Protocol.HTTP({
		url: gon.shape_path,
		format: new OpenLayers.Format.GeoJSON({
      'internalProjection': map.baseLayer.projection,
      'externalProjection': WGS84_google_mercator
		})
	});

	var strat = [new OpenLayers.Strategy.Fixed()];
	vector_base.protocol = prot;
	vector_base.strategies = strat;

	// create event to load the features and set the bound
	// after protocol has read in json
	prot.read({
			callback: load_vector_base
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
function load_vector_base(resp){
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
      vector_base.addFeatures(features);
      map.zoomToExtent(bounds);
    } else {
console.log('vector_base - no features found');
    }
	}
}

// load the features for the children into the vector_child layer
function load_vector_child(resp){
	if (resp.success()){
    vector_child.addFeatures(resp.features);
    // if this is summary view, populate gon.indicator_scales and colors with names from json file
    populate_summary_data();
    // add style map
    vector_child.styleMap = build_indicator_scale_styles();
		// now that the child vector is loaded, lets show the legend
    draw_legend();
		// now load the values for the hidden form
		load_hidden_form();
  } else {
console.log('vector_child - no features found');
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
    }
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
      legend.append('<li><span style="background-color: ' + gon.indicator_scale_colors[i] + ';"></span> ' + gon.indicator_scales[i].name + '</li>');
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

      legend.append('<li><span style="background-color: ' + color + ';"></span> ' + format_number(gon.indicator_scales[i].name) + '</li>');
		} 
	} else {
		// no legend
		legend.innerHTML = "";
	}

	// show the indicator descritpion if provided
	if (gon.indicator_description) {
		$('#indicator-description').append(gon.indicator_description);
	  $('#indicator-description').show(500);
	} else {
		$('#indicator-description').innerHTML = "";
	  $('#indicator-description').hide(0);
	}

  $('#legend-container').show(500);
}

// build the color mapping for the indicators
function build_indicator_scale_styles() {
	var rules = [];
  var theme = new OpenLayers.Style({
      fillColor: "#cfce9d",
      strokeColor: "#777777",
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

    return new OpenLayers.StyleMap({'default':theme, 'select': {'strokeColor': '#5c81a3', 'fillColor': '#5c81a3', 'fillOpacity': opacity, 'strokeWidth': 2}});
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
	if (feature.attributes.has_children == "true"){
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
	var index2 = url.indexOf(name2 + "/");
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
		// found 'name/', now need to replace the value
		var name_length = name2.length+1; // use +1 to account for the '='
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

// show the map box
function hover_handler (feature)
{
  if (gon.view_type == gon.summary_view_type_name){
  	populate_map_box(feature.attributes.common_name, feature.attributes.value + ":", 
  		feature.attributes.data_value, gon.indicator_number_format);
  } else if (gon.indicator_scale_colors && gon.indicator_scales){
  	populate_map_box(feature.attributes.common_name, gon.indicator_name_abbrv + ":", 
  		feature.attributes.value, gon.indicator_number_format);
  } 
}

// hide the map box
function mouseout_handler (feature)
{
	$('#map-box').hide(0);
}

function populate_map_box(title, indicator, value, number_format)
{
		var box = $('#map-box');
    if (title)
    {
        box.children('h1').text(title);
    }
    if (indicator && value)
    {
        box.children('#map-box-content').children('#map-box-indicator').text(indicator);
				// make the number pretty
				var x = format_number(value);
				// if the value is a number, apply the number_format
				if (!isNaN(x) && number_format){
					x += number_format;
				}
        box.children('#map-box-content').children('#map-box-value').text(x);
    }
    if (title || (indicator && value))
    {
        box.show(0);
    }
}

// load the hidden form with the values so the export link works
function load_hidden_form()
{
	if (gon.indicator_name){
		// update the url for the download data link
		$("#export-data").attr('href',update_query_parameter($("#export-data").attr('href'), "event_name", "event_name", gon.event_name));
		$("#export-data").attr('href',update_query_parameter($("#export-data").attr('href'), "map_title", "map_title", gon.map_title));

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


			// submit the hidden form
			$('#hidden_form').submit();
		});

		// show the export links
		$('#export').show(500);

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

$(document).ready(function() {
	// to load pop-up window for export help
  $("a.fancybox").fancybox();
});
