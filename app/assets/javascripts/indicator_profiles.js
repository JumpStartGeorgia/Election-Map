var indicator_profile_data;
var summary_height = [];
var detail_height = [];
var number_events;

function build_result_indicator_profile_summary_charts(ths, indicator_data){
  if (ths != undefined && indicator_data != undefined){
    // reset height
    ths.height('auto');

    ths.highcharts({
      chart: {
          plotBackgroundColor: null,
          plotBorderWidth: null,
          plotShadow: false,
          height: 250,
          events: {
            load: function(event) {
              // save the height and after all details loaded, reset height for all detail chart containers
              // so floating wraps nicely
              summary_height.push(this.options.chart.height);
              if (summary_height.length == $('.tab-pane.active .profile_item .indicator_summary_chart').length){
                $(".tab-pane.active .profile_item .indicator_summary_chart").each(function() { $(this).height(Math.max.apply(Math, summary_height)); });
              }
            }
          } 

      },
      colors: [indicator_data.color, "#6f6f6f"],
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
        }
      },
      series: [{
        type: 'pie',
        name: 'vote share',
        data: [
            [indicator_data.indicator_name_abbrv, Number(indicator_data.value)],
            [gon.summary_chart_rest, 100 - Number(indicator_data.value)]
        ]
      }]
    });
  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_result_indicator_profile_detail_charts(ths, indicator_name, headers, data){
  if (ths != undefined && indicator_name != undefined && headers != undefined && headers.length > 0 && data != undefined && data.length > 0){
    // reset height
    ths.height('auto');

    var chart_height = 400;
    chart_height = 60 * data.length;
    ths.highcharts({
      chart: {
          type: 'bar',
          spacingRight: 20, 
          height: chart_height,
          events: {
            load: function(event) {
              // save the height and after all details loaded, reset height for all detail chart containers
              // so floating wraps nicely
              detail_height.push(this.options.chart.height);
              if (detail_height.length == $('.tab-pane.active .profile_item .indicator_detail_chart').length){
                $(".tab-pane.active .profile_item .indicator_detail_chart").each(function() { $(this).height(Math.max.apply(Math, detail_height)); });
              }
            }
          } 
      },
      title: {
          text: null
      },
      xAxis: {
          categories: headers,
          title: {
              text: null
          },
          labels: {
              overflow: 'justify',
              formatter: function() {
                  if (this.value == indicator_name){
                    return '<b>' + this.value + '</b>';
                  } else {
                    return this.value;
                  }
              }
          }
      },
      yAxis: {
          min: 0,
          title: {
              text: null
          },  
          gridLineWidth: 0,
          labels: {
              enabled: false
          }
      },
      tooltip: {
          enabled: false
      },
      legend: {
        enabled: false
      },
      plotOptions: {
          bar: {
              dataLabels: {
                  enabled: true,
                	percentageDecimals: 2,
                  formatter: function() {
                    if (this.x == indicator_name){
                      return '<b>' + Highcharts.numberFormat(this.y, 2) + '%</b>';
                    } else {
                      return Highcharts.numberFormat(this.y, 2) + '%';
                    }
                  }
              }
          }
      },
      credits: {
          enabled: false
      },
      series: [{
        data: data
      }]
    });
  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_results_indicator_profile_charts(){
  $('.tab-pane.active .indicator_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var indicator_data, indicator_name;
    var detail_headers = [];
    var detail_data = [];
    for (var i=0;i<indicator_profile_data.length;i++){
      if (indicator_profile_data[i].event.id.toString() == $(this).data('id')){
        if (indicator_profile_data[i].data == null){
          detail_headers.push(null);  
          detail_data.push(null);  
        } else {
          for (var j=0;j<indicator_profile_data[i].data.length;j++){
            if (indicator_profile_data[i].data[j].core_indicator_id.toString() == gon.indicator_profile.id.toString() || 
                  (gon.indicator_profile.child_ids.length > 0 && gon.indicator_profile.child_ids.indexOf(indicator_profile_data[i].data[j].core_indicator_id) > -1)){
              indicator_data = indicator_profile_data[i].data[j];
              indicator_name = indicator_profile_data[i].data[j].indicator_name;
            }
            detail_headers.push(indicator_profile_data[i].data[j].indicator_name);  
            detail_data.push({y: Number(indicator_profile_data[i].data[j].value), color: indicator_profile_data[i].data[j].color});  
          }
        }
        break;
      }
    }  

    build_result_indicator_profile_summary_charts($(this), indicator_data);
    var ths_detail = $('.tab-pane.active .indicator_detail_chart[data-id="' + event_id.toString() + '"]')
    build_result_indicator_profile_detail_charts(ths_detail, indicator_name, detail_headers, detail_data);

  });
}


function build_other_indicator_profile_summary_charts(ths, indicator_data){
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

function build_other_indicator_profile_detail_charts(ths, indicator_name, data){
  if (ths != undefined && indicator_name != undefined && data != undefined && data.length > 0){
    // reset height
    ths.height('auto');

    var value;    
    var table = "<table class='other_indicator_table table table-striped table-bordered'><tbody>";
    for (var i=0; i<data.length; i++){
      value = data[i].value;
      if (data[i].number_format != null && data[i].number_format.length > 0){
        value += data[i].number_format;
      }
      table += "<tr><td>" + data[i].name + "</td><td>" + value + "</td></tr>";
    }
    table += "</tbody></table>"
    ths.html(table);
  } else if (ths != undefined) {
    // reset height
    ths.height('auto');

    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
  detail_height.push(ths.height());
  if (detail_height.length == $('.tab-pane.active .profile_item .indicator_detail_chart').length){
    $(".tab-pane.active .profile_item .indicator_detail_chart").each(function() { $(this).height(Math.max.apply(Math, detail_height)); });
  }

}

function build_other_indicator_profile_charts(){
  $('.tab-pane.active .indicator_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var indicator_data, indicator_name;
    var detail_data = [];
    for (var i=0;i<indicator_profile_data.length;i++){
      if (indicator_profile_data[i].event.id.toString() == $(this).data('id')){
        if (indicator_profile_data[i].data == null){
          detail_data.push(null);  
        } else {
          for (var j=0;j<indicator_profile_data[i].data.length;j++){
            if (indicator_profile_data[i].data[j].core_indicator_id.toString() == gon.indicator_profile.id.toString() || 
                  (gon.indicator_profile.child_ids.length > 0 && gon.indicator_profile.child_ids.indexOf(indicator_profile_data[i].data[j].core_indicator_id) > -1)){
              indicator_data = indicator_profile_data[i].data[j];
              indicator_name = indicator_profile_data[i].data[j].indicator_name;
            }
            detail_data.push({name: indicator_profile_data[i].data[j].indicator_name, 
                  value: indicator_profile_data[i].data[j].formatted_value, 
                  number_format: indicator_profile_data[i].data[j].number_format});  
          }
        }
        break;
      }
    }  

    build_other_indicator_profile_summary_charts($(this), indicator_data);
    var ths_detail = $('.tab-pane.active .indicator_detail_chart[data-id="' + event_id.toString() + '"]')
    build_other_indicator_profile_detail_charts(ths_detail, indicator_name, detail_data);

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
          build_results_indicator_profile_charts();
        } else if (gon.indicator_profile.type_id == 1){
          build_other_indicator_profile_charts();
        }
      }
    });
  }
}

$(document).ready(function() {

  $(window).bind('load', get_ind_event_type_data());

  // when switch event types, get data for the new events
  $('#indicator_profile .nav-tabs li a').click(function(){
    // reset height array so the new charts can be resized correctly
    summary_height = []; 
    detail_height = [];

    // if charts do not already exist, load them
    if ($('#indicator_profile .tab-content #tab' + $(this).data('id') + ' .indicator_summary_chart:first').html().length == 0){
      get_ind_event_type_data($(this).data('id'));
    }
  });

  // when district filter selected, update the charts
  $('#indicator_profile .tab-pane.active select.district_filter_select').live('change', function(){
//    $('#indicator_profile .tab-content .tab-pane.active .highcharts-container').fadeOut(300, function(){
//      $(this).empty();
//        var selected_option = $("#indicator_profile .tab-pane.active select.district_filter_select option:selected");
        var selected_index = $(this).prop("selectedIndex");
        var selected_option = $(this).children()[selected_index];
        get_ind_event_type_data($(this).data('id'), $(selected_option).data('shape-type-id'), $(selected_option).data('id'), $(selected_option).text());
//    });
  });


  // when event filter changes, update what events to show
  $('#indicator_profile .tab-pane.active #event_filter input[name="event_filter_checkboxes"]').live('change', function(){
    var event_id = $(this).val();
    if ($(this).attr("checked") == undefined){
      // hide this event
      $('#indicator_profile .tab-pane.active .profile_item div[data-id="' + event_id + '"]').removeClass('active');
    }else{
      // show this event
      $('#indicator_profile .tab-pane.active .profile_item div[data-id="' + event_id + '"]').addClass('active');
    }
  });
});


