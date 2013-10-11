var json_data_has_summary = false;
var popup_table_row_highlight;

function build_popup_title(json){
  var html = "";

  for(var index=0;index<json.length;index++){
    if (json[index].hasOwnProperty("shape_values"))
    {
      // determine which title to use
      if (json[index].shape_values.title_location !== null){
        html += "<h3 class='map_popup_title1'>" + json[index].shape_values.title_location + "</h3>";
      }

	    if (json[index].shape_values.title_precincts_completed !== null){
        html += "<h4 class='map_popup_title_precincts'>" + json[index].shape_values.title_precincts_completed + "</h4>";
      }

      if (json[index].shape_values.value == gon.no_data_text){
        html += "<div class='map_popup_no_data'>" + gon.no_data_text + "</div>";
      }

      break;
    }
  }
  return html;
}

function build_popup_footer(json){
  var html = "";

  for(var index=0;index<json.length;index++){
    if (json[index].hasOwnProperty("footnote"))
    {
      html += "<div class='map_popup_footer'>" + json[index].footnote.indicator_name + "</div>";
      break;
    }
  }
  return html;
}

function build_popup_table_summary_data(json){
  html = "";

  if (json.visible){
    for(var i=0;i<json.data.length;i++){
      html += "<tr>";

      html += "<td class='map_popup_table_cell1' style='background-color: " + json.data[i].color + "'>&nbsp;</td>";

      html += "<td class='map_popup_table_cell2 ";

      if (popup_table_row_highlight !== null && json.data[i].indicator_name == popup_table_row_highlight){
        html += "highlight";
      }
      html += "'>" + json.data[i].indicator_name + "</td>";

      html += "<td class='map_popup_table_cell3 "; 
      if (popup_table_row_highlight !== null && json.data[i].indicator_name == popup_table_row_highlight){
        html += "highlight";
      }
      html += "'>" + json.data[i].formatted_value+(json.data[i].number_format === null ? '' : json.data[i].number_format) + "</td>";

      html += "<td class='map_popup_table_cell4'>";
      if (!isNaN(json.data[i].value)){
        html += "<div style='width: " + Number(json.data[i].value) + "%; background-color: " + json.data[i].color + ";'>&nbsp;</div>";
      }
      html += "</td>";

      html += "</tr>";
    }
  }
  return html;
}

function build_popup_table_data_item(json){
  html = "";

    if (json.visible){

      html += "<tr>";

      html += "<td class='map_popup_table_cell1'></td>";

      html += "<td class='map_popup_table_cell2 ";
      if (popup_table_row_highlight !== null && json.indicator_name == popup_table_row_highlight){
        html += "highlight";
      }
      html += "'>" + json.indicator_name + "</td>";

      html += "<td class='map_popup_table_cell3 ";
      if (popup_table_row_highlight !== null && json.indicator_name == popup_table_row_highlight){
        html += "highlight";
      }
      html += "'>" + json.formatted_value+(json.number_format === null ? '' : json.number_format) + "</td>";

      html += "<td class='map_popup_table_cell4'></td>";

      html += "</tr>";

    }
    
  return html;
}

function build_popup_table_top(){
  return "<table class='table table-striped'><tbody>";
}


function build_popup_table(json){
  var html = "";
  var started_table = false;
  var has_summary = false;

  for(var index=0;index<json.length;index++){
    if (json[index].hasOwnProperty("summary_data"))
    {
      if (!started_table){
        html += build_popup_table_top();
        started_table = true;
      }
      html += build_popup_table_summary_data(json[index].summary_data);
      has_summary = true;
    }
    else if (json[index].hasOwnProperty("data_item"))
    {
      if (!started_table){
        html += build_popup_table_top();
        started_table = true;
      }
      html += build_popup_table_data_item(json[index].data_item);
    }
  }

  if (html.length > 0){
    html += "</tbody></table>";
  }

  json_data_has_summary = has_summary;

  return html;
}

function build_popup(json){
  var html = "";

  if (json == undefined){
    console.log("no json data for popup!");
  } else {
    // build the titles
    html += build_popup_title(json);

    // build the table
    html += build_popup_table(json);

    // build the footnote
    html += build_popup_footer(json);
  }

  return html;
}


// if the shape does not have data, show no data message
function build_popup_no_data(title){
  var html = "";

  if (title !== null){
    html += "<h3 class='map_popup_title1'>" + title + "</h3>";
  }

  html += "<div class='map_popup_no_data'>" + gon.no_data_text + "</div>";

  return html;
}

function unhighlight_shape(feature, redraw_layer)
{
	if (feature !== undefined && f_style_backup !== undefined){
		feature.style = f_style_backup;
		if (redraw_layer !== undefined && redraw_layer) {
			feature.layer.redraw();
		}
	}
}

function close_popup(feature){
  map.controls[1].activate();
  removeFeaturePopups();
  unhighlight_shape(feature, true);
}

function mapFreeze(feature)
{
  map.controls[1].deactivate();
  highlight_shape_popup(feature, true, true, function(){
    close_popup(feature);
  }, true);
}


