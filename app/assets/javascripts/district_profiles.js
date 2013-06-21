var district_profile_data;
var number_events;

window.hs = [];
function get_h (i)
{
  hs.push($('#district_profile .tab-pane.active .profile_item > div.active div.district_header').height());
  if (i <= 50)
  {
    setTimeout(get_h, 5, +i + 1);
  }
  else
  {
    console.log(hs);
  }
}
get_h (0);


// re-assign height of summary/detail chart for those events showing
function adjust_district_profile_height(){
  var header_height = [];
  var summary_height = [];
  var detail_height = [];

  ////// header
  // get the heights of each header
  $('#district_profile .tab-pane.active .profile_item > div.active div.district_header').each(function(){
    $(this).height('auto');
    header_height.push($(this).height());
  });
  // update heights to max height of visible detail charts
  $('#district_profile .tab-pane.active .profile_item > div.active div.district_header').each(function() { $(this).height(Math.max.apply(Math, header_height)); });

  ////// summary
  // get the heights of each visible summary chart
  $('#district_profile .tab-pane.active .profile_item > div.active div.district_summary_chart').each(function(){
    $(this).height('auto');
    summary_height.push($(this).height());
  });
  // update heights to max height of visible detail charts
  $('#district_profile .tab-pane.active .profile_item > div.active div.district_summary_chart').each(function() { $(this).height(Math.max.apply(Math, summary_height)); });

  ////// detail
  // get the heights of each visible detail chart
  $('#district_profile .tab-pane.active .profile_item > div.active div.district_detail_chart').each(function(){
    $(this).height('auto');
    detail_height.push($(this).height());
  });
  // update heights to max height of visible detail charts
  $('#district_profile .tab-pane.active .profile_item div.active div.district_detail_chart').each(function() { $(this).height(Math.max.apply(Math, detail_height)); });
}


function build_district_profile_table(json_data){
  if (json_data != undefined){
    // holds rows that will be used to create table
    var rows = [];
    // holds list of unique indicators
    // the index of the indicator + 1 = the array of values for that indicator in rows
    var indicators = []; 
    // holds list of events ids so can assign to table cells
    var event_ids = new Array(json_data.length);
    var row, ind, ind_index, footnote;

    // get event ids
    for (var i=0;i<json_data.length;i++){
      event_ids[i] = json_data[i].event.id;      
    }

    // create the header row
    row = new Array(json_data.length+1);
    rows.push(row);
    row[0] = gon.profile_table_indicator_header;
    for (var i=0;i<json_data.length;i++){
      row[i+1] = json_data[i].event.name;      
    }
    
    // add data rows
    // format: [ [ind, event 1 name, event 2 name, etc], [ind 1, event 1 value, event 2, value, etc ], [ind 2, event 1 value, event 2, value, etc ], etc. ]
    // for each event
    for (var i=0;i<json_data.length;i++){
      if (json_data[i].data !== null && json_data[i].data.length > 0){
        // for each data item/summary
        for (var j=0;j<json_data[i].data.length;j++){
          if (json_data[i].data[j].hasOwnProperty("summary_data")){
            for (var k=0;k<json_data[i].data[j].summary_data.data.length;k++){
              ind = json_data[i].data[j].summary_data.data[k];

              // see if this is a new indicator 
              ind_index = indicators.indexOf(ind.indicator_name)
              if (ind_index == -1){
                // add the new indicator to the list
                indicators.push(ind.indicator_name);
                ind_index = indicators.length-1;            
                // create a new row for this indicator
                row = new Array(json_data.length+1);
                rows.push(row);
                row[0] = ind.indicator_name;
              }

              // add value
              rows[ind_index+1][i+1] = ind.formatted_value+(ind.number_format === null ? '' : ind.number_format);
            }
          } else if (json_data[i].data[j].hasOwnProperty("data_item")){
            ind = json_data[i].data[j].data_item;
            // see if this is a new indicator 
            ind_index = indicators.indexOf(ind.indicator_name)
            if (ind_index == -1){
              // add the new indicator to the list
              indicators.push(ind.indicator_name);
              ind_index = indicators.length-1;            
              // create a new row for this indicator
              row = new Array(json_data.length+1);
              rows.push(row);
              row[0] = ind.indicator_name;
            }

            // add value
            rows[ind_index+1][i+1] = ind.formatted_value+(ind.number_format === null ? '' : ind.number_format);

          } else if (json_data[i].data[j].hasOwnProperty("footnote") && footnote == undefined){
            footnote = json_data[i].data[j].footnote.indicator_name;
          }
        }
      }
    }  
    // now build table using rows array
    if (rows.length > 1){
      var html = "";

      html += "<table class='table table-striped table-bordered'>";

      // add header
      html += "<thead>";
      html += "<tr>";

      for (var j=0;j<rows[0].length;j++){
        html += "<th";
        // add event id
        if (j == 0){
          html += " data-id='" + datatable_first_column_value + "'"
        } else {
          html += " data-id='" + event_ids[j-1] + "'"
        }
        html += ">";

        if (rows[0][j] !== undefined){
          html += rows[0][j];
        }
        html += "</th>";
      }
      html += "</tr>";
      html += "</thead>";

      // add rows
      html += "<tbody>";
      for (var i=1;i<rows.length;i++){
        html += "<tr>";

        for (var j=0;j<rows[i].length;j++){
          html += "<td";
          // add event id
          if (j == 0){
            html += " data-id='" + datatable_first_column_value + "'"
          } else {
            html += " data-id='" + event_ids[j-1] + "'"
          }
          html += ">";

          if (rows[i][j] !== undefined){
            html += rows[i][j];
          }
          html += "</td>";
        }

        html += "</tr>";
      }

      if (footnote !== undefined){
        var colspan = 4;
        if (rows[0].length < 4){
          colspan = rows[0].length;
        }
        html += "<tfoot><tr><td colspan='" + colspan + "'>" + footnote + "</td></tr></tfoot>";
      }

      html += "</tbody></table>";
      
      // create table
      $('.tab-pane.active .district_table').html(html);


      // show the columns for the events that are selected
      // - first col should always be shown
      $('#district_profile .tab-pane.active .district_table_container .district_table table th[data-id="' + datatable_first_column_value + '"]').addClass('active');
      $('#district_profile .tab-pane.active .district_table_container .district_table table td[data-id="' + datatable_first_column_value + '"]').addClass('active');
      // event columns
      $('#district_profile .tab-pane.active .district_table_container .event_filter select.event_filter_select option:selected').each(function(){
        $('#district_profile .tab-pane.active .district_table_container .district_table table th[data-id="' + $(this).val() + '"]').addClass('active');
        $('#district_profile .tab-pane.active .district_table_container .district_table table td[data-id="' + $(this).val() + '"]').addClass('active');
      });

      // update colspan if the table has a footer
      var tfoot = $('#district_profile .tab-pane.active .district_table_container .district_table table tfoot tr td');
      if (tfoot !== undefined){
        tfoot.attr('colspan', $('#district_profile .tab-pane.active .district_table_container .event_filter input[name="event_filter_checkboxes"]:checked').length+1);
      }

      // build col sorting array so formatted numbers are sorted properly
      col_sort = new Array(rows[0].length);
      for(var i=0;i<col_sort.length;i++){
        if (i==0){
          col_sort[i] = null
        }else{
          col_sort[i] = { "sType": "formatted-num" }
        }
      }

      // create file name for downloads
      var file_name = $('h1').html();
      file_name += " - ";
      file_name += $('ul.nav-tabs li.active a').html();

      // add datatable fn
      $('#district_profile .tab-pane.active .district_table table').dataTable({
        "sDom": "<'row-fluid'<'span6'f><'span6'T>r>t",    
        "bLengthChange": false,
        "bJQueryUI": false,
        "bProcessing": true,
        "bStateSave": true,
        "bAutoWidth": false,
        "oLanguage": {
          "sUrl": gon.datatable_i18n_url
        },
        "aoColumns": col_sort,
        "iDisplayLength" : rows.length,
        "oTableTools": {
			    "aButtons": [
            {
              "sExtends": "csv",
              "sTitle": file_name + " - csv"
            },
            {
              "sExtends": "xls",
              "sTitle": file_name + " - xls"
            }
			    ]
		    }
      });
    } else {

    }
  } else {


  }
}
function build_summary_district_profile_summary_charts(ths, summary_colors, summary_data){
  if (ths != undefined && summary_colors != undefined && summary_colors.length > 1 && summary_data != undefined && summary_data.length > 1){
    // reset height
    ths.height('auto');

    // add the rest values
    var sum = 0;
    for (var i=0; i<summary_data.length;i++){
      sum += summary_data[i][1];
    }
    summary_colors.push("#c9c9c9");
    summary_data.push([gon.summary_chart_rest, 100-sum]);
    ths.highcharts({
      chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        height: 250 + 18*summary_colors.length
      },
      colors: summary_colors,
      title: {
          text: null
      },
      credits: {
        enabled: false
      },
      tooltip: {
      	percentageDecimals: 2,
        formatter: function() {
            return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage, 2) + '%';
        }
      },
      plotOptions: {
          pie: {
            dataLabels: {
                enabled: false
            },
            showInLegend: true
          }
      },
      legend: {
        labelFormatter: function() {
          return this.name + ' (' +  Highcharts.numberFormat(this.y, 2) + '%)';
        },
        layout: 'vertical',
        itemMarginTop: 2,
        itemMarginBottom: 2
      },
      series: [{
        type: 'pie',
        name: 'vote share',
        data: summary_data
      }],
      lang: {
        downloadPNG: gon.highcharts_downloadPNG,
        downloadJPEG: gon.highcharts_downloadJPEG,
        downloadPDF: gon.highcharts_downloadPDF,
        downloadSVG: gon.highcharts_downloadSVG,
        printChart: gon.highcharts_printChart
      }
    });
  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_summary_district_profile_detail_charts(ths, data){
  if (ths != undefined && data != undefined && data.length > 0 && data[0] !== null){
    // reset height
    ths.height('auto');

    // create the table
    ths.html(build_popup(data));

  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }

}


function build_summary_district_profile_charts(){
  $('#district_profile .tab-pane.active .district_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var summary_headers = [];
    var summary_data = [];
    var summary_colors = [];
    var detail_headers = [];
    var detail_data = [];
    var ind;
    for (var i=0;i<district_profile_data.length;i++){
      if (district_profile_data[i].event.id.toString() == $(this).data('id')){
        if (district_profile_data[i].data == null){
          detail_data.push(null);  
        } else {
          for (var j=0;j<district_profile_data[i].data.length;j++){
            if (district_profile_data[i].data[j].hasOwnProperty("summary_data")){
              for (var k=0;k<district_profile_data[i].data[j].summary_data.data.length;k++){
                ind = district_profile_data[i].data[j].summary_data.data[k];
                if (Number(ind.value) >= 3){
                    summary_data.push([ind.indicator_name_abbrv, Number(ind.value)]);
                    summary_colors.push(ind.color);
                }
              }
              break;
            }
          }
          detail_data = district_profile_data[i].data;
        }
        break;
      }
    }  

    build_summary_district_profile_summary_charts($(this), summary_colors, summary_data);
    var ths_detail = $('#district_profile .tab-pane.active .district_detail_chart[data-id="' + event_id.toString() + '"]')
    build_summary_district_profile_detail_charts(ths_detail, detail_data);
  });
}


function build_item_district_profile_summary_charts(ths, indicator_data){
  if (ths != undefined && indicator_data != undefined){
    // reset height
    ths.height('auto');

    var value = indicator_data.formatted_value;
    if (indicator_data.number_format != null && indicator_data.number_format.length > 0){
      value += indicator_data.number_format;
    }
    ths.html("<table class='other_district_table table table-striped table-bordered'><tbody><tr><td>" + indicator_data.indicator_name + "</td><td>" + value + "</td></tr></tbody></table>");
  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}


function build_item_district_profile_detail_charts(ths, data){
  if (ths != undefined && data != undefined && data.length > 0 && data[0] !== null){
    // reset height
    ths.height('auto');

    // create the table
    ths.html(build_popup(data));

    // reset col width
    ths.find('td.map_popup_table_cell2').width('auto');
    ths.find('td.map_popup_table_cell4').width('auto');

  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }

}


function build_item_district_profile_charts(indicator_id){
  $('#district_profile .tab-pane.active .district_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var ind_id = $(this).data('indicator-id');
    if (indicator_id != undefined){
      ind_id = indicator_id;
    }
    var indicator_data, indicator_name;
    var detail_data = [];
    for (var i=0;i<district_profile_data.length;i++){
      if (district_profile_data[i].event.id.toString() == $(this).data('id')){
        if (district_profile_data[i].data == null){
          detail_data.push(null);  
        } else {
          for (var j=0;j<district_profile_data[i].data.length;j++){
            if (district_profile_data[i].data[j].hasOwnProperty("data_item")){
              ind = district_profile_data[i].data[j].data_item;
              if (ind.core_indicator_id != null && ind.core_indicator_id.toString() == ind_id){
                indicator_data = ind;
                indicator_name = ind.indicator_name;
                break;
              }
            }
          }
          detail_data = district_profile_data[i].data;
        }
        break;
      }
    }  

    build_item_district_profile_summary_charts($(this), indicator_data);
    var ths_detail = $('#district_profile .tab-pane.active .district_detail_chart[data-id="' + event_id.toString() + '"]')
    build_item_district_profile_detail_charts(ths_detail, detail_data);

  });
}



function get_district_event_type_data(ths_event_type, is_summary, indicator_id){
  if (ths_event_type == undefined){
    // it was not passed in so get active event type
    ths_event_type = $('#district_profile .nav-tabs li.active a');
  }
  if (ths_event_type != undefined){
    var url;
    var ind_id = ths_event_type.data('indicator-id');
    if (indicator_id != undefined){
      ind_id = indicator_id;
    }
    var summary = ths_event_type.data('summary');
    if (is_summary != undefined){
      summary = is_summary;
    }

    if (summary == true){
      var url = gon.json_district_event_type_summary_data_url.replace(gon.placeholder_event_type, ths_event_type.data('id')).replace(gon.placeholder_indicator, ind_id);
    } else {
      var url = gon.json_district_event_type_data_url.replace(gon.placeholder_event_type, ths_event_type.data('id')).replace(gon.placeholder_core_indicator, ind_id);
    }

    $('#district_profile .tab-content .tab-pane.active .profile_loading').fadeIn();

    $.ajax({
      type: "GET",
      url: url,
      dataType:"json",
      timeout: 3000,
      error: function(data) {
        console.log('error');
      },
      success: function(data) {
        district_profile_data = data;
        if (summary){
          // there are charts, so show chart container
          $('#district_profile .tab-pane.active .chart_container').show(300, adjust_district_profile_height);
          build_summary_district_profile_charts();
        } else {
          // build_item_district_profile_charts(ind_id);
          // no charts, so hide chart container
          $('#district_profile .tab-pane.active .chart_container').hide(300);
        }
        build_district_profile_table(data);

        $('#district_profile .tab-content .tab-pane.active .profile_loading').fadeOut();
      }
    });
  }
}

$(document).ready(function() {

  if (gon.district_profile){

    $(window).bind('load', get_district_event_type_data());
    $(window).resize(function(){
      adjust_district_profile_height()
    });

    // apply chosen jquery to filters
    $('select[id^="event_filter_"]').each(function(){
      $(this).chosen({width: "100%"});
    });
    $('select[id^="indicator_filter_"]').each(function(){
      $(this).chosen({width: $(this).innerWidth().toString() + "px"});
    });

    // when switch event types, get data for the new events
    $('#district_profile .nav-tabs li a').click(function(){
      // if charts do not already exist, load them
      if ($('#district_profile .tab-content #tab' + $(this).data('id') + ' .district_summary_chart:first').html().length == 0){
        get_district_event_type_data($(this));
      } else {
        // make sure the loading style is not showing
        $('#district_profile .tab-content #tab' + $(this).data('id') + ' .profile_loading').hide();
      }
    });

    // when indicator filter selected, update the charts
    $('#district_profile .tab-pane.active select.indicator_filter_select').live('change', function(){
  //    $('#district_profile .tab-content .tab-pane.active .highcharts-container').fadeOut(300, function(){
  //      $(this).empty();
        var selected_index = $(this).prop("selectedIndex");
        // have to do children.children because using optgroups
        var selected_option = $(this).children().children()[selected_index];
        var id = $(selected_option).val();
        var summary = false;
        // if this is the summary option, get the indicator type id
        if (id == "0"){
          summary = true;
          id = $(selected_option).data('id');
        }

        // make sure all select filters have this item selected
        $('#district_profile .tab-pane.active select.indicator_filter_select option[value="' + $(this).val() + '"]').prop("selected", true);
        $('#district_profile .tab-pane.active select.indicator_filter_select option[value="' + $(this).val() + '"]').trigger("liszt:updated");

        // reload data
        get_district_event_type_data($('#district_profile .nav-tabs li.active a'), summary, id);
  //    });
    });

    // when event filter changes, update what events to show
    $('#district_profile .tab-pane.active .event_filter select').live('change', function(){
      // loop through each option in this select and show/hide as appropriate
      var event_id;
      $(this).children().each(function(){
        event_id = $(this).val();
        if ($(this).prop("selected") == true){
          // show this event
          $('#district_profile .tab-pane.active .profile_item > div[data-id="' + event_id + '"]').addClass('active');

          // show this column in datatable
          $('#district_profile .tab-pane.active .district_table_container .district_table table th[data-id="' + event_id + '"]').addClass('active');
          $('#district_profile .tab-pane.active .district_table_container .district_table table td[data-id="' + event_id + '"]').addClass('active');

          // update colspan if the table has a footer
          var tfoot = $('#district_profile .tab-pane.active .district_table_container .district_table table tfoot tr td');
          if (tfoot !== undefined){
            tfoot.attr('colspan', Number(tfoot.attr('colspan'))+1);
          }

          // make sure all checkboxes with this id are not checked
          $('#district_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').prop("selected", true);
          $('#district_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').trigger("liszt:updated");
        }else{
          // hide this event
          $('#district_profile .tab-pane.active .profile_item > div[data-id="' + event_id + '"]').removeClass('active');

          // hide this column in datatable
          $('#district_profile .tab-pane.active .district_table_container .district_table table th[data-id="' + event_id + '"]').removeClass('active');
          $('#district_profile .tab-pane.active .district_table_container .district_table table td[data-id="' + event_id + '"]').removeClass('active');

          // update colspan if the table has a footer
          var tfoot = $('#district_profile .tab-pane.active .district_table_container .district_table table tfoot tr td');
          if (tfoot !== undefined){
            tfoot.attr('colspan', Number(tfoot.attr('colspan'))-1);
          }

          // make sure all checkboxes with this id are not checked
          $('#district_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').prop("selected", false);
          $('#district_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').trigger("liszt:updated");
        }
      });

      // adjust the height of the blocks
      adjust_district_profile_height();

      // re-assign the no-left-margin class to every third item that is showing
      $('#district_profile .tab-pane.active .profile_item > div.active').removeClass('no-left-margin');
      $('#district_profile .tab-pane.active .profile_item > div.active').each(function(index){
        if (index%3 == 0){
          $(this).addClass('no-left-margin');
        }
      });
    });
  }
});


