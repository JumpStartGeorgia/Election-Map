var asdf;
function build_popup_title(json){
  var html = "";
asdf = json;
  for(var index=0;index<json.length;index++){
    if (json[index].hasOwnProperty("shape_values"))
    {
console.log('creating title');
      // determine which title to use
      html += "<h3 class='map_popup_title1'>" + json[index].shape_values.title_location + "</h3>";

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
console.log('creating footer');
      html += "<div class='map_popup_footer'>" + json[index].footnote.indicator_name + "</div>";
      break;
    }
  }
  return html;
}

function build_popup_table_summary_data(json){
  html = "";

  for(var i=0;i<json.length;i++){
    html += "<tr>";

    html += "<td class='map_popup_table_cell1' style='background-color: " + json[i].color + "'>&nbsp;</td>";

    html += "<td class='map_popup_table_cell2'>" + json[i].indicator_name + "</td>";

    html += "<td class='map_popup_table_cell3'>" + json[i].formatted_value+(json[i].number_format === null ? '' : json[i].number_format) + "</td>";

    html += "<td class='map_popup_table_cell4'>";
    if (!isNaN(json[i].value)){
      html += "<div style='width: " + Number(json[i].value) + "%;'>&nbsp;</div>";
    }
    html += "</td>";

    html += "</tr>";
  }

  return html;
}

function build_popup_table_data_item(json){
  html = "";

    html += "<tr>";

    html += "<td class='map_popup_table_cell1'></td>";

    html += "<td class='map_popup_table_cell2'>" + json.indicator_name + "</td>";

    html += "<td class='map_popup_table_cell3'>" + json.formatted_value+(json.number_format === null ? '' : json.number_format) + "</td>";

    html += "<td class='map_popup_table_cell4'></td>";

    html += "</tr>";

  return html;
}

function build_popup_table_top(){
  return "<table class='table table-striped'><tbody>";
}


function build_popup_table(json){
  var html = "";
  var started_table = false;

  for(var index=0;index<json.length;index++){
    if (json[index].hasOwnProperty("summary_data"))
    {
      if (!started_table){
        html += build_popup_table_top();
        started_table = true;
      }
      html += build_popup_table_summary_data(json[index].summary_data.data);
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

  return html;
}

function build_popup(json){
  var html = "";

  // build the titles
  html += build_popup_title(json);

  // build the table
  html += build_popup_table(json);

  // build the footnote
  html += build_popup_footer(json);

  return html;
}
