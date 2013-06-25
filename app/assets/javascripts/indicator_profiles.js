var indicator_profile_data;
var number_events;
var datatable_first_column_value = "-9999";

function show_appropriate_indicator_events(ths){
    var yd = $(ths).next().offset().top - $(window).scrollTop();

    // loop through each option in this select and show/hide as appropriate
    var event_id;
    $(ths).children().each(function(){
      event_id = $(this).val();
      if ($(this).prop("selected") == true){
        // show this event
        $('#indicator_profile .tab-pane.active .profile_item > div[data-id="' + event_id + '"]').addClass('active');

        // show this column in datatable
        $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table th[data-id="' + event_id + '"]').addClass('active');
        $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table td[data-id="' + event_id + '"]').addClass('active');

        // update colspan if the table has a footer
        var tfoot = $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table tfoot tr td');
        if (tfoot !== undefined){
          tfoot.attr('colspan', Number(tfoot.attr('colspan'))+1);
        }

        // make sure all checkboxes with this id are not checked
        $('#indicator_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').prop("selected", true);
        $('#indicator_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').trigger("liszt:updated");
      }else{
        // hide this event
        $('#indicator_profile .tab-pane.active .profile_item > div[data-id="' + event_id + '"]').removeClass('active');

        // hide this column in datatable
        $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table th[data-id="' + event_id + '"]').removeClass('active');
        $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table td[data-id="' + event_id + '"]').removeClass('active');

        // update colspan if the table has a footer
        var tfoot = $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table tfoot tr td');
        if (tfoot !== undefined){
          tfoot.attr('colspan', Number(tfoot.attr('colspan'))-1);
        }

        // make sure all checkboxes with this id are not checked
        $('#indicator_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').prop("selected", false);
        $('#indicator_profile .tab-pane.active select.event_filter_select option[value="' + $(this).val() + '"]').trigger("liszt:updated");
      }
    });

    // adjust the height of the blocks
    adjust_indicator_profile_height();

    // re-assign the no-left-margin class to every third item that is showing
    assign_indicator_no_left_margin_class();

    // reset scroll
    window.scrollTo($(window).scrollLeft(), $(ths).next().offset().top - yd);
}

// re-assign the no-left-margin class to every third item that is showing
function assign_indicator_no_left_margin_class(){
  $('#indicator_profile .tab-pane.active .profile_item > div.active').removeClass('no-left-margin');
  $('#indicator_profile .tab-pane.active .profile_item > div.active').each(function(index){
    if (index%3 == 0){
      $(this).addClass('no-left-margin');
    }
  });
}


// re-assign height of summary/detail chart for those events showing
function adjust_indicator_profile_height(){
  var header_height = [];
  var summary_height = [];
  var detail_height = [];

  ////// header
  // get the heights of each header
  $('#indicator_profile .tab-pane.active .profile_item > div.active div.indicator_header').each(function(){
    $(this).height('auto');
    header_height.push($(this).height());
  });
  // update heights to max height of visible detail charts
  $('#indicator_profile .tab-pane.active .profile_item > div.active div.indicator_header').each(function() { $(this).height(Math.max.apply(Math, header_height)); });

  ////// summary
  // get the heights of each visible summary chart
  $('#indicator_profile .tab-pane.active .profile_item > div.active div.indicator_summary_chart').each(function(){
    $(this).height('auto');
    summary_height.push($(this).height());
  });
  // update heights to max height of visible detail charts
  $('#indicator_profile .tab-pane.active .profile_item > div.active div.indicator_summary_chart').each(function() { $(this).height(Math.max.apply(Math, summary_height)); });

  ////// detail
  // get the heights of each visible detail chart
  $('#indicator_profile .tab-pane.active .profile_item > div.active div.indicator_detail_chart').each(function(){
    $(this).height('auto');
    detail_height.push($(this).height());
  });
  // update heights to max height of visible detail charts
  $('#indicator_profile .tab-pane.active .profile_item > div.active div.indicator_detail_chart').each(function() { $(this).height(Math.max.apply(Math, detail_height)); });
}


function build_indicator_profile_table(json_data){
  if (json_data != undefined && json_data.length > 0){
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
      $('.tab-pane.active .indicator_table').html(html);


      // show the columns for the events that are selected
      // - first col should always be shown
      $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table th[data-id="' + datatable_first_column_value + '"]').addClass('active');
      $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table td[data-id="' + datatable_first_column_value + '"]').addClass('active');
      // event columns
      $('#indicator_profile .tab-pane.active .indicator_table_container .event_filter select.event_filter_select option:selected').each(function(){
        $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table th[data-id="' + $(this).val() + '"]').addClass('active');
        $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table td[data-id="' + $(this).val() + '"]').addClass('active');
      });

      // update colspan if the table has a footer
      var tfoot = $('#indicator_profile .tab-pane.active .indicator_table_container .indicator_table table tfoot tr td');
      if (tfoot !== undefined){
        tfoot.attr('colspan', $('#indicator_profile .tab-pane.active .indicator_table_container .event_filter input[name="event_filter_checkboxes"]:checked').length+1);
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
      $('#indicator_profile .tab-pane.active .indicator_table table').dataTable({
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

function build_summary_indicator_profile_summary_charts(ths, indicator_data){
  if (ths != undefined && indicator_data != undefined){
    // reset height
    ths.height('auto');

    ths.highcharts({
      chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        height: 250+18*3
      },
      colors: [indicator_data.color, "#c9c9c9"],
      title: {
          text: gon.summary_chart_title + ": " + indicator_data.rank
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
        data: [
            [indicator_data.indicator_name_abbrv, Number(indicator_data.value)],
            [gon.summary_chart_rest, 100 - Number(indicator_data.value)]
        ]
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

function build_summary_indicator_profile_detail_charts(ths, indicator_name, data){
  if (ths != undefined && indicator_name != undefined && data != undefined && data.length > 0 && data[0] !== null){
    // reset height
    ths.height('auto');

    // indicate which row to highlight
    popup_table_row_highlight = indicator_name;

    // create the table
    ths.html(build_popup(data));

  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_summary_indicator_profile_charts(){
  $('#indicator_profile .tab-pane.active .indicator_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var indicator_data, indicator_name, ind;
    var detail_headers = [];
    var detail_data = [];
    for (var i=0;i<indicator_profile_data.length;i++){
      if (indicator_profile_data[i].event.id.toString() == $(this).data('id')){
        if (indicator_profile_data[i].data == null){
          detail_data.push(null);  
        } else {
          for (var j=0;j<indicator_profile_data[i].data.length;j++){
            if (indicator_profile_data[i].data[j].hasOwnProperty("summary_data")){
              for (var k=0;k<indicator_profile_data[i].data[j].summary_data.data.length;k++){
                ind = indicator_profile_data[i].data[j].summary_data.data[k];
                if (ind.core_indicator_id.toString() == gon.indicator_profile.id.toString() || 
                      (gon.indicator_profile.child_ids.length > 0 && gon.indicator_profile.child_ids.indexOf(ind.core_indicator_id) > -1)){
                  indicator_data = ind;
                  indicator_name = ind.indicator_name;
                }
              }
              break;
            }
          }
          detail_data = indicator_profile_data[i].data;
        }
        break;
      }
    }  

    build_summary_indicator_profile_summary_charts($(this), indicator_data);
    var ths_detail = $('#indicator_profile .tab-pane.active .indicator_detail_chart[data-id="' + event_id.toString() + '"]')
    build_summary_indicator_profile_detail_charts(ths_detail, indicator_name, detail_data);

  });
}


function build_item_indicator_profile_summary_charts(ths, indicator_data){
  if (ths != undefined && indicator_data != undefined){
    // reset height
    ths.height('auto');

    var value = indicator_data.formatted_value;
    if (indicator_data.number_format != null && indicator_data.number_format.length > 0){
      value += indicator_data.number_format;
    }
    ths.html("<table class='other_indicator_table table table-striped table-bordered'><tbody><tr><td>" + indicator_data.indicator_name + "</td><td>" + value + "</td></tr></tbody></table>");
  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }

}

function build_item_indicator_profile_detail_charts(ths, indicator_name, data){
  if (ths != undefined && indicator_name != undefined && data != undefined && data.length > 0 && data[0] !== null){
    // reset height
    ths.height('auto');

    // indicate which row to highlight
    popup_table_row_highlight = indicator_name;

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

function build_item_indicator_profile_charts(){
  $('#indicator_profile .tab-pane.active .indicator_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var indicator_data, indicator_name;
    var detail_data = [];
    for (var i=0;i<indicator_profile_data.length;i++){
      if (indicator_profile_data[i].event.id.toString() == $(this).data('id')){
        if (indicator_profile_data[i].data == null){
          detail_data.push(null);  
        } else {
          for (var j=0;j<indicator_profile_data[i].data.length;j++){
            if (indicator_profile_data[i].data[j].hasOwnProperty("data_item")){
              ind = indicator_profile_data[i].data[j].data_item;
              if (ind.core_indicator_id.toString() == gon.indicator_profile.id.toString() || 
                    (gon.indicator_profile.child_ids.length > 0 && gon.indicator_profile.child_ids.indexOf(ind.core_indicator_id) > -1)){
                indicator_data = ind;
                indicator_name = ind.indicator_name;
                break;
              }
            }
          }
          detail_data = indicator_profile_data[i].data;
        }
        break;
      }
    }  


    build_item_indicator_profile_summary_charts($(this), indicator_data);
    var ths_detail = $('#indicator_profile .tab-pane.active .indicator_detail_chart[data-id="' + event_id.toString() + '"]')
    build_item_indicator_profile_detail_charts(ths_detail, indicator_name, detail_data);

  });
}


function get_ind_event_type_data(event_type_id, shape_type_id, common_id, common_name){
  if (event_type_id == undefined){
    // it was not passed in so get active event type
    event_type_id = $('#indicator_profile .nav-tabs li.active a').data('id');
  }
  if (event_type_id != undefined){
    var url;
    if (shape_type_id != undefined && common_id != undefined && common_name != undefined){
      url = gon.json_indicator_event_type_data_url_district_filter.replace(gon.placeholder_core_indicator, gon.indicator_profile.id).replace(gon.placeholder_event_type, event_type_id.toString()).replace(gon.placeholder_shape_type_id, shape_type_id.toString()).replace(gon.placeholder_common_id, common_id).replace(gon.placeholder_common_name, common_name);
    }else{
      url = gon.json_indicator_event_type_data_url.replace(gon.placeholder_core_indicator, gon.indicator_profile.id).replace(gon.placeholder_event_type, event_type_id.toString());
    }

    $('#indicator_profile .tab-content .tab-pane.active .profile_loading').fadeIn();

    $.ajax({
      type: "GET",
      url: url,
      dataType:"json",
      timeout: 3000,
      error: function(data) {
        console.log('error');
      },
      success: function(data) {
        indicator_profile_data = data;
        if (gon.indicator_profile.type_id == 2){
          // there are charts, so show chart container
          $('#indicator_profile .tab-pane.active .chart_container').show();
          build_summary_indicator_profile_charts();
        } else {
          // build_item_indicator_profile_charts();
          // no charts, so hide chart container
          $('#indicator_profile .tab-pane.active .chart_container').hide();
        }
        build_indicator_profile_table(data);

        adjust_indicator_profile_height();

        assign_indicator_no_left_margin_class();

        show_appropriate_indicator_events($('#indicator_profile .tab-pane.active .event_filter select:first'));

        $('#indicator_profile .tab-content .tab-pane.active .profile_loading').fadeOut();
      }
    });
  }
}

$(document).ready(function() {

  if (gon.indicator_profile){

    // apply chosen jquery to filters
    $('select[id^="event_filter_"]').each(function(){
      $(this).chosen({width: "100%"});
    });
    $('select[id^="district_filter_"]').each(function(){
      $(this).chosen({width: $(this).innerWidth().toString() + "px"});
    });

    // when switch event types, get data for the new events
    $('#indicator_profile .nav-tabs li a').click(function(){
      // if charts do not already exist, load them
      if ($('#indicator_profile .tab-content #tab' + $(this).data('id') + ' .indicator_summary_chart:first').html().length == 0){
        get_ind_event_type_data($(this).data('id'));
      } else {
        // make sure the loading style is not showing
        $('#indicator_profile .tab-content #tab' + $(this).data('id') + ' .profile_loading').hide();
      }
    });

    // when district filter selected, update the charts
    $('#indicator_profile .tab-pane.active select.district_filter_select').live('change', function(){
      var selected_index = $(this).prop("selectedIndex");
      var selected_option = $(this).children()[selected_index];

      // make sure all select filters have this item selected
      $('#indicator_profile .tab-pane.active select.district_filter_select option[value="' + $(this).val() + '"]').prop("selected", true);
      $('#indicator_profile .tab-pane.active select.district_filter_select option[value="' + $(this).val() + '"]').trigger("liszt:updated");

      // reload the data
      get_ind_event_type_data($(this).data('id'), $(selected_option).data('shape-type-id'), $(selected_option).data('id'), $(selected_option).text());
    });


    // when event filter changes, update what events to show
    $('#indicator_profile .tab-pane.active .event_filter select').live('change', function(){
      show_appropriate_indicator_events(this);
    });

    $(window).load(function(){
      get_ind_event_type_data();
    });
    $(window).resize(function(){
      adjust_indicator_profile_height()
    });

  }
});


