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

// Function called from body tag
function map_init(){

	// add no data to scales
	if (gon.indicator_scale_colors && gon.indicator_scales){
		gon.indicator_scale_colors.splice(0,0,color_nodata);
		gon.indicator_scales.splice(0,0,scale_nodata);
	}

	var options = {
		theme: null,
        controls: []  // Remove all controls
  };

	var baseStyle = new OpenLayers.StyleMap({
      "default": new OpenLayers.Style({
          fillColor: "#bfbe8d",
          strokeColor: "#777777",
          strokeWidth: 1
      })
  });

  map = new OpenLayers.Map('map', options);

  vector_base = new OpenLayers.Layer.Vector("Base Layer", {isBaseLayer: true, styleMap: baseStyle});

  vector_child = new OpenLayers.Layer.Vector("Child Layer", {styleMap: build_indicator_scale_styles()});

  map.addLayers([vector_base, vector_child]);

	// load the base layer
	var prot = new OpenLayers.Protocol.HTTP({
		url: gon.shape_path,
		format: new OpenLayers.Format.GeoJSON({
      'internalProjection': map.baseLayer.projection,
      'externalProjection': new OpenLayers.Projection('EPSG:900913')
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
      'externalProjection': new OpenLayers.Projection('EPSG:900913')
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
		// now that the child vector is loaded, lets show the legend
    draw_legend();
		// now load the values for the hidden form
		load_hidden_form();
  } else {
console.log('vector_child - no features found');
  }
}

// Legend
function draw_legend()
{
  var legend = $('#legend');
	if (gon.indicator_scales && gon.indicator_scales.length > 0 && gon.indicator_scale_colors && gon.indicator_scale_colors.length > 0){
		var color = "";
		for (var i=0; i<gon.indicator_scales.length; i++){
			// if the scale has a color, use it, otherwise use app color
			if (gon.indicator_scales[i].color && gon.indicator_scales[i].color.length > 0){
				color = gon.indicator_scales[i].color;
			} else {
				color = gon.indicator_scale_colors[i];
			}
      legend.append('<li><span style="background: ' + color + '"></span> ' + gon.indicator_scales[i].name + '</li>');
		}
	} else {
		// no legend
		legend.innerHTML = "";
	}

	// show the indicator descritpion if provided
	if (gon.indicator_description) {
		$('#indicator-description').append(gon.indicator_description);
	  $('#indicator-description').show(0);
	} else {
		$('#indicator-description').innerHTML = "";
	  $('#indicator-description').hide(0);
	}

  $('#legend-container').show(0);
}

// build the color mapping for the indicators
function build_indicator_scale_styles() {
	var rules = [];
  var theme = new OpenLayers.Style({
      fillColor: "#cfce9d",
      strokeColor: "#777777",
      strokeWidth: 1
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

    return new OpenLayers.StyleMap({'default':theme, 'select': {'strokeColor': '#0000ff', 'fillColor': '#0000ff', 'strokeWidth': 2}});
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
	        symbolizer: {"Polygon": {'fillColor': color, 'fillOpacity': 1}}
	    });
	} else if (type && value1){
	    return new OpenLayers.Rule({
			name: type + " " + value1,
	      	filter: new OpenLayers.Filter.Comparison({
		        type: type,
		        property: "value",
		        value: value1 }),
	        symbolizer: {"Polygon": {'fillColor': color, 'fillOpacity': 1}}
	    });
	}
}

function click_handler (feature)
{
	// if the feature has children, continue
	if (feature.attributes.has_children == "true"){
		// add/update the shape_id parameter
		var url = update_query_parameter(window.location.href, "shape_id", feature.attributes.id);

		// add/update the shape_type_id parameter
		url = update_query_parameter(url, "shape_type_id", feature.attributes.shape_type_id);

		// add/update the parameter to indicate that the shape type is changing
		url = update_query_parameter(url, "change_shape_type", true);

		// load the url
		window.location.href = url;
	}
}

// add/update the query paramter with the provided name and value
function update_query_parameter(url, name, value){
	// get the current url
	var index = url.indexOf(name + "=");
	var name_length = name.length+1; // use +1 to account for the '='
	if (index > 0){
		// found it, now need to replace the value
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			url = url.slice(0, index+name_length) + value + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			url = url.slice(0, index+name_length) + value;
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
	populate_map_box(feature.attributes.common_name, gon.indicator_name_abbrv + ":", 
		feature.attributes.value, gon.indicator_number_format);
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
        box.children('#map-box-content').children('#map-box-value').text(value + number_format);
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
		$("#export-link").click(function(){
			// get the indicator names and colors
			var scales = [];
			var colors = [];
			for (i=0; i<gon.indicator_scales.length; i++){
				scales[i] = gon.indicator_scales[i].name;
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

		// show the export link
		$('#map-export').show(0);

	} else {
		// hide the export link
		$('#map-export').hide(0);
	}
}

$(document).ready(function() {
	// to load pop-up window for export help
  $("a.fancybox").fancybox();
});
