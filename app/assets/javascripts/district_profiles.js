var district_profile_data;
var summary_height = [];
var detail_height = [];
var number_events;

function build_result_district_profile_summary_charts(ths, summary_colors, summary_data){
  if (ths != undefined && summary_colors != undefined && summary_colors.length > 1 && summary_data != undefined && summary_data.length > 1){
    // add the rest values
    var sum = 0;
    for (var i=0; i<summary_data.length;i++){
      sum += summary_data[i][1];
    }
    summary_colors.push("#6f6f6f");
    summary_data.push([gon.summary_chart_rest, 100-sum]);
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
              if (summary_height.length == $('.tab-pane.active .profile_item .district_summary_chart').length){
                $(".tab-pane.active .profile_item .district_summary_chart").each(function() { $(this).height(Math.max.apply(Math, summary_height)); });
              }
            }
          } 

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
        }
      },
      series: [{
        type: 'pie',
        name: 'vote share',
        data: summary_data
      }]
    });
  } else if (ths != undefined) {
    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}
/*
function build_result_district_profile_summary_charts(ths, headers, data){
  if (ths != undefined && headers != undefined && headers.length > 0 && data != undefined && data.length > 0){
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
              summary_height.push(this.options.chart.height);
              if (summary_height.length == $('.tab-pane.active .profile_item .district_summary_chart').length){
                $(".tab-pane.active .profile_item .district_summary_chart").each(function() { $(this).height(Math.max.apply(Math, summary_height)); });
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
              overflow: 'justify'
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
                    return Highcharts.numberFormat(this.y, 2) + '%';
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
    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}
*/

function build_result_district_profile_detail_charts(ths, headers, data){
  if (ths != undefined && headers != undefined && headers.length > 0 && data != undefined && data.length > 0){
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
              if (detail_height.length == $('.tab-pane.active .profile_item .district_detail_chart').length){
                $(".tab-pane.active .profile_item .district_detail_chart").each(function() { $(this).height(Math.max.apply(Math, detail_height)); });
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
              overflow: 'justify'
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
                    return Highcharts.numberFormat(this.y, 2) + '%';
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
    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_results_district_profile_charts(){
  $('#district_profile .tab-pane.active .district_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var summary_headers = [];
    var summary_data = [];
    var summary_colors = [];
    var detail_headers = [];
    var detail_data = [];
    for (var i=0;i<district_profile_data.length;i++){
      if (district_profile_data[i].event.id.toString() == $(this).data('id')){
        if (district_profile_data[i].data == null){
          detail_headers.push(null);  
          detail_data.push(null);  
        } else {
          for (var j=0;j<district_profile_data[i].data.length;j++){
            if (Number(district_profile_data[i].data[j].value) >= 5){
//              summary_headers.push(district_profile_data[i].data[j].indicator_name);
//              summary_data.push({y: Number(district_profile_data[i].data[j].value), color: district_profile_data[i].data[j].color});  
                summary_data.push([district_profile_data[i].data[j].indicator_name, Number(district_profile_data[i].data[j].value)]);
                summary_colors.push(district_profile_data[i].data[j].color);
            }
            detail_headers.push(district_profile_data[i].data[j].indicator_name);  
            detail_data.push({y: Number(district_profile_data[i].data[j].value), color: district_profile_data[i].data[j].color});  
          }
        }
        break;
      }
    }  

//    build_result_district_profile_summary_charts($(this), summary_headers, summary_data);
    build_result_district_profile_summary_charts($(this), summary_colors, summary_data);
    var ths_detail = $('#district_profile .tab-pane.active .district_detail_chart[data-id="' + event_id.toString() + '"]')
    build_result_district_profile_detail_charts(ths_detail, detail_headers, detail_data);

  });
}


function build_other_district_profile_summary_charts(ths, indicator_data){
  if (ths != undefined && indicator_data != undefined){
    var value = indicator_data.formatted_value;
    if (indicator_data.number_format != null && indicator_data.number_format.length > 0){
      value += indicator_data.number_format;
    }
    ths.html("<table class='other_district_table table table-striped table-bordered'><tbody><tr><td>" + indicator_data.indicator_name + "</td><td>" + value + "</td></tr></tbody></table>");
  } else if (ths != undefined) {
    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_other_district_profile_detail_charts(ths, indicator_name, data){
  if (ths != undefined && indicator_name != undefined && data != undefined && data.length > 0){
    var value;    
    var table = "<table class='other_district_table table table-striped table-bordered'><tbody>";
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
    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
  detail_height.push(ths.height());
  if (detail_height.length == $('.tab-pane.active .profile_item .district_detail_chart').length){
    $(".tab-pane.active .profile_item .district_detail_chart").each(function() { $(this).height(Math.max.apply(Math, detail_height)); });
  }

}
function build_other_district_profile_charts(){
  $('.tab-pane.active .district_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var ind_id = $(this).data('indicator-id');
    var indicator_data, indicator_name;
    var detail_data = [];
    for (var i=0;i<district_profile_data.length;i++){
      if (district_profile_data[i].event.id.toString() == $(this).data('id')){
        if (district_profile_data[i].data == null){
          detail_data.push(null);  
        } else {
          for (var j=0;j<district_profile_data[i].data.length;j++){
            if (district_profile_data[i].data[j].core_indicator_id.toString() == ind_id){
              indicator_data = district_profile_data[i].data[j];
              indicator_name = district_profile_data[i].data[j].indicator_name;
            }
            detail_data.push({name: district_profile_data[i].data[j].indicator_name, 
                  value: district_profile_data[i].data[j].formatted_value, 
                  number_format: district_profile_data[i].data[j].number_format});  
          }
        }
        break;
      }
    }  

    build_other_district_profile_summary_charts($(this), indicator_data);
    var ths_detail = $('.tab-pane.active .district_detail_chart[data-id="' + event_id.toString() + '"]')
    build_other_district_profile_detail_charts(ths_detail, indicator_name, detail_data);

  });
}



function get_district_event_type_data(ths_event_type){
  if (ths_event_type == undefined){
    // it was not passed in so get active event type
    ths_event_type = $('#district_profile .nav-tabs li.active a');
  }
  if (ths_event_type != undefined){
    var url;
    if (ths_event_type.data('summary') == true){
      var url = gon.json_district_event_type_summary_data_url.replace(gon.placeholder_event_type, ths_event_type.data('id')).replace(gon.placeholder_indicator, ths_event_type.data('indicator-id'));
    } else {
      var url = gon.json_district_event_type_data_url.replace(gon.placeholder_event_type, ths_event_type.data('id')).replace(gon.placeholder_core_indicator, ths_event_type.data('indicator-id'));
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
        district_profile_data = data;
        if (ths_event_type.data('summary') == true){
          build_results_district_profile_charts();
        } else {
          build_other_district_profile_charts();
        }
      }
    });
  }
}
$(document).ready(function() {

  $(window).bind('load', get_district_event_type_data());

  // when switch event types, get data for the new events
  $('#district_profile .nav-tabs li a').click(function(){
    // reset height array so the new charts can be resized correctly
    summary_height = []; 
    detail_height = [];

    get_district_event_type_data($(this));
  });

  // when indicator filter selected, update the charts
  $('#district_profile .tab-pane.active select.indicator_filter_select').live('change', function(){
//    $('#indicator_profile .tab-content .tab-pane.active .highcharts-container').fadeOut(300, function(){
//      $(this).empty();
      var selected_index = $(this).prop("selectedIndex");
      var selected_option = $(this).children()[selected_index];
      get_district_event_type_data($('#district_profile .nav-tabs li.active a'));
//    });
  });

  // when event filter changes, update what events to show
  $('#district_profile .tab-pane.active #event_filter input[name="event_filter_checkboxes"]').live('change', function(){
    var event_id = $(this).val();
    if ($(this).attr("checked") == undefined){
      // hide this event
      $('#district_profile .tab-pane.active .profile_item div[data-id="' + event_id + '"]').removeClass('active');
    }else{
      // show this event
      $('#district_profile .tab-pane.active .profile_item div[data-id="' + event_id + '"]').addClass('active');
    }
  });
});


