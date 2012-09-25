/*  Declaring class  */
function MapPopup() {
  var self = this;
  this.svg = null;
  this.svgElements = new Array();
  this.title = null;
  this.y_s = 20; // padding on the y axis
  this.max_value_width = 0;
  this.max_ind_width = 0;
  this.max = 100;
  this.dist = 25;
  this.i = 0;
	this.item_spacing = 10;

  this.svgElementsIndex = function(){
    index = 0;
    if (self.svgElements.length > 0) {
      index = self.svgElements.length-1;
    }
    // console.log("svgElements index = " + index);
    if (self.svgElements[index] === undefined)
      self.svgElements[index] = {};
    // console.log("svgElements[index] = " + self.svgElements[index]);
    return index;
  }

  this.computeWindowWidth = function(id_el, json, options)
  {
    var max_width = 0;
  /*
    old computations for widths
    title
    window.maxSVGWidth = 30+(ths.title.location.length>th_title.length ? ths.title.location.length : th_title.length)*5+50;
    summary data
    window.maxSVGWidth = 30+ths.max_ind_width*7+80+ths.max/100*json.data[0].value+10;
    data item
    window.maxSVGWidth = (30+ths.max_ind_width*7+10)+(ths.max_value_width.toString().length*7+50);
    no data
    window.maxSVGWidth = 30+ths.max_ind_width*7+10+gon.no_data_text.length*7+50;

  */
    for(i=0;i<json.length;i++){
      if (json[i].hasOwnProperty("title"))
      {
        var title = typeof json[i].title.title_abbrv !== "undefined" &&
          json[i].title.title_abbrv instanceof String &&
          json[i].title.title_abbrv.length > 0 ? json[i].title.title_abbrv : json[i].title.title;
				var title_title_width = get_text_width(title, "15px");
				var title_loc_width = get_text_width(json[i].title.location, "15px");
				var title_precincts_width = get_text_width(json[i].precincts_completed, "13px");
// console.log("title title width = " + title_title_width);
// console.log("title location width = " + title_loc_width);
				var max_width = Math.max(title_title_width, title_loc_width, title_precincts_width)
				var title_width = self.item_spacing*6+(max_width);
// console.log("title width = " + title_width);
        if (title_width > max_width)
          max_width = title_width;
      }
      else if (json[i].hasOwnProperty("summary_data"))
      {
        var max_text_width = 0;
        var max_value_width = 0;
				for(var j=0;j<json[i].summary_data.length;j++) {
					var value = json[i].summary_data[j];
					var text_width = get_text_width(value.indicator_name);
          if( text_width > max_text_width)
            max_text_width = text_width;
					var value_width = get_text_width(value.number_format === null ?
							value.formatted_value : value.formatted_value + value.number_format)
          if( value_width > max_value_width)
            max_value_width = value_width;
        }
// console.log("summary max text width = " + max_text_width +	"; max value width = " + max_value_width + "; first data value = " + json[i].summary_data[0].value);
				if (isNaN(json[i].summary_data[0].value))
					var summary_width = self.item_spacing*3+max_text_width+self.item_spacing+max_value_width+self.item_spacing*3;
				else
					var summary_width = self.item_spacing*3+max_text_width+self.item_spacing+max_value_width+self.item_spacing+self.max/100*json[i].summary_data[0].value+self.item_spacing*2;

        // console.log("summary width = " + summary_width);
        if (summary_width > max_width)
          max_width = summary_width;
        if (max_text_width > self.max_ind_width)
          self.max_ind_width = max_text_width;
        if (max_value_width > self.max_value_width)
          self.max_value_width = max_value_width;
      }
      else if (json[i].hasOwnProperty("data_item"))
      {
        var max_text_width = get_text_width(json[i].data_item.indicator_name);
        var max_value_width = get_text_width(json[i].data_item.number_format === null ?
					json[i].data_item.formatted_value : json[i].data_item.formatted_value + " " + json[i].data_item.number_format);
        var item_width = self.item_spacing*3+max_text_width+self.item_spacing+max_value_width+self.item_spacing*3;
        // console.log("item width = " + item_width);
        if (item_width > max_width)
          max_width = item_width;
        if (max_text_width > self.max_ind_width)
          self.max_ind_width = max_text_width;
        if (max_value_width > self.max_value_width)
          self.max_value_width = max_value_width;
      }
      else if (json[i].hasOwnProperty("footnote"))
      {
        var max_text_width = get_text_width(json[i].footnote.indicator_name, "10px");
        var footnote_width = self.item_spacing*3+max_text_width+self.item_spacing*3;
        // console.log("footnote width = " + footnote_width);
        if (footnote_width > max_width)
          max_width = footnote_width;
      }
    };
    window.maxSVGWidth = max_width;
    // console.log("self.max_ind_width = " + self.max_ind_width + "; self.max_value_width = " + self.max_value_width);
  }

  this.processTitle = function(id_el, json, options)
  {
    // determine which title to use
    var title = typeof json.title_abbrv !== "undefined" &&
      json.title_abbrv instanceof String &&
      json.title_abbrv.length > 0 ? json.title_abbrv : json.title;

    // add the titles to the svg
    if (typeof window.maxSVGWidth !== "undefined")
    {
      this.SVGElement("text", {
        "x": (window.maxSVGWidth/2),
        "y": 20,
        "style": "font-size:15px;text-anchor:middle;"
      }).text(json.location);

      this.SVGElement("text", {
        "x": (window.maxSVGWidth/2),
        "y": 40,
        "style": "font-size:15px;text-anchor:middle;"
      }).text(title);

			if (json.precincts_completed !== null){
		    this.SVGElement("rect", {
		      "x": 10,
		      "y": 45,
		      "width": window.maxSVGWidth-10,
		      "height": 20,
		      "style": "fill: rgba(51, 51, 51, 0.8);"
		    }).text(json.precincts_completed);
		    this.SVGElement("text", {
		      "x": (window.maxSVGWidth/2),
		      "y": 60,
		      "style": "fill: #fff; font-size:15px;text-anchor:middle;"
		    }).text(json.precincts_completed);
			}
    }

		if (json.precincts_completed === null){
		  // make height at least 50 so title will show
		  window.maxSVGHeight = 50;
		  // make y padding equal to min height
		  self.y_s = 50;
		} else {
		  // make height at least 70 so title will show
		  window.maxSVGHeight = 70;
		  // make y padding equal to min height
		  self.y_s = 70;
		}
  }

  this.processSummaryData = function(id_el, json, options)
  {
		// if a limit was passed in, use it
    json = json.slice(0, options.limit !== undefined ? options.limit : json.length);
		// create the svg for each summary data item
    for(var i=0;i<json.length;i++){
      // create horizontal bars
      // - first is for item color
      this.SVGElement("rect", {
        "x": self.item_spacing,
        "y": self.y_s+i*self.dist,
        "width": 10,
        "height": 10,
        "style": "fill:"+json[i].color
      });

			if (!isNaN(json[i].value)){
		    // - second is for bar chart
		    this.SVGElement("rect", {
		      "x": self.item_spacing*3+self.max_ind_width+self.item_spacing+self.max_value_width+self.item_spacing,
		      "y": self.y_s+i*self.dist,
		      "width": self.max/100*json[i].value,
		      "height": 10,
		      "style": "fill:#5c81a3"
		    });
			}

      // make separator line
      this.SVGElement("line", {
        "x1": self.item_spacing,
        "y1": self.y_s+self.i*self.dist+15,
        "x2": window.maxSVGWidth-10,
        "y2": self.y_s+self.i*self.dist+15,
        "style": "stroke-width:1px;stroke:#CCC"
      });

      // write out name
      this.SVGElement("text", {
        "x": self.item_spacing*3,
        "y": self.y_s+10+self.i*self.dist,
        "style": "font-size:12px;",
        "class": "title"
      }).text(json[i].indicator_name);
      // write out value
      this.SVGElement("text", {
        "x": self.item_spacing*3+self.max_ind_width+self.item_spacing,
        "y": self.y_s+10+self.i*self.dist,
        "style": "font-size:12px;"
      }).text(json[i].formatted_value+(json[i].number_format === null ? "" : json[i].number_format));

      self.i++;

      window.maxSVGHeight = self.y_s+10+self.i*self.dist+10;
    }
  }

  this.processDataItem = function(id_el, json, options)
  {
    // make separator line
    this.SVGElement("line", {
      "x1": self.item_spacing,
      "y1": self.y_s+self.i*self.dist+15,
      "x2": window.maxSVGWidth-10,
      "y2": self.y_s+self.i*self.dist+15,
      "style": "stroke-width:1px;stroke:#CCC"
    });

    // write out name
    this.SVGElement("text", {
      "x": self.item_spacing*3,
      "y": self.y_s+10+self.i*self.dist,
      "style": "font-size:12px;",
      "class": "title"
    }).text(json.indicator_name);
    // write out value
    this.SVGElement("text", {
      "x": self.item_spacing*3+self.max_ind_width+self.item_spacing,
      "y": self.y_s+10+self.i*self.dist,
      "style": "font-size:12px;"
    }).text(json.formatted_value+(json.number_format === null ? "" : json.number_format));

    self.i++;

    window.maxSVGHeight = self.y_s+10+self.i*self.dist+10;
  }

  this.processFootnote = function(id_el, json, options)
  {
    // write out name
    this.SVGElement("text", {
      "x": self.item_spacing*3,
      "y": self.y_s+10*2+self.i*self.dist,
      "style": "font-size:11px;",
      "class": "title"
    }).text(json.indicator_name);

    self.i++;

    window.maxSVGHeight = self.y_s+10+self.i*self.dist+10;
  }
}


/*  Class function  */
MapPopup.prototype.processJSON = function(id_el, json, options)
{
  if (json instanceof Array && json.length>0)
  {
    // determine overall window width
// console.log("compute width");
    this.computeWindowWidth(id_el, json, options);
// console.log("computed window width = " + window.maxSVGWidth);

    // create svg element
    var d3elmapsvg = d3.select(id_el)
                     .append("svg")
                     .attr("xmlns", "http://www.w3.org/2000/svg")
                     .attr("class", "elmapsvg")
										 .attr("width", "100%")
										 .attr("height", "100%")
										 .attr("id", "svg");
    this.svg = d3elmapsvg;

    // process each data type in json
    for(var index=0;index<json.length;index++){
      if (json[index].hasOwnProperty("title"))
      {
// console.log("loading title");
        this.processTitle(id_el, json[index].title, options);
      }
      else if (json[index].hasOwnProperty("summary_data"))
      {
// console.log("loading summary data");
        this.processSummaryData(id_el, json[index].summary_data, options);
      }
      else if (json[index].hasOwnProperty("data_item"))
      {
// console.log("loading data item");
        this.processDataItem(id_el, json[index].data_item, options);
      }
      else if (json[index].hasOwnProperty("footnote"))
      {
// console.log("loading footnote");
        this.processFootnote(id_el, json[index].footnote, options);
      }
    }
    d3.select("#svg").attr("width", window.maxSVGWidth).attr("height", window.maxSVGHeight);
  }
};

MapPopup.prototype.SVGElement = function(elname, attributes)
{
  var ret_svg = this.svg.append(elname);
  for(var key in attributes){
     ret_svg.attr(key, attributes[key]);
  };
  return ret_svg;
};


// get the pixel width of text
// by placing the text in a span tag
// and getting the span tag's width
function get_text_width(string, font_size){
	// if no font_size provided, use defautl of 12px
	if (typeof font_size == 'undefined' ) font_size = '12px';
	$("span#hidden_span_width").text(string);
	$("span#hidden_span_width").css("font-size", font_size);
	return $("span#hidden_span_width").width();
}


function PopupIndicatorCheckPosition(mouse_location)
{
	var popup_left = 0;
  var map = $("#map"),
      popup = $(".olPopup:first"),
      indicators = $("#indicator_menu_scale"),
      indicators_toggle = indicators.children('.toggle:first');

	// if the mouse position was not provided, use the popup left as default
	if (typeof(mouse_location) === "undefined") {
		popup_left = popup.css('left');
	} else {
		popup_left = mouse_location.x;
	}

  if (parseInt(popup_left) + parseInt(popup.width()) +
      parseInt(indicators.width()) + parseInt(indicators.css('right')) > map.width() && indicators_toggle.css('display') === 'block')
  {
     the_indicators.hide();
  }
  else if (parseInt(popup_left) + parseInt(popup.width()) +
      parseInt(indicators.width()) + parseInt(indicators.css('right')) <= map.width() && indicators_toggle.css('display') === 'none')
  {
     the_indicators.show();
  }
}

function updatePopUpPosition(e) {
if (typeof(popup) !== "undefined" && popup.visible()) {
	var mapPntPx = map.events.getMousePosition(e);
	// keep the bottom of the tip just a few pixels above the mouse
	if (popup.relativePosition.indexOf('t') > -1 ){
	  mapPntPx = mapPntPx.add(0, -5);
	}	else {
	  mapPntPx = mapPntPx.add(0, 20);
	}

  popup.lonlat = map.getLonLatFromViewPortPx(mapPntPx);
  popup.updatePosition();
  PopupIndicatorCheckPosition(mapPntPx);
}
}

function unhighlight_shape(feature)
{
  feature.style = f_style_backup;
  feature.layer.redraw();
}

function mapFreeze(feature)
{
  map.controls[1].deactivate();
  makeFeaturePopup(feature, true, true, function(){
    map.controls[1].activate();
		map.events.register('mousemove', map, updatePopUpPosition);
    unhighlight_shape(feature);
  });
	map.events.un({'mousemove': updatePopUpPosition});
}



$(document).mouseover(function(e){
  window.mouse = {
    X: e.pageX,
    Y: e.pageY
  };
});
