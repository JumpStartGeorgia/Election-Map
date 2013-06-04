var district_profile_data;
var summary_height = [];
var detail_height = [];
var number_events;

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
              summary_headers.push(district_profile_data[i].data[j].indicator_name);
              summary_data.push({y: Number(district_profile_data[i].data[j].value), color: district_profile_data[i].data[j].color});  
            }
            detail_headers.push(district_profile_data[i].data[j].indicator_name);  
            detail_data.push({y: Number(district_profile_data[i].data[j].value), color: district_profile_data[i].data[j].color});  
          }
        }
        break;
      }
    }  

    build_result_district_profile_summary_charts($(this), summary_headers, summary_data);
    var ths_detail = $('#district_profile .tab-pane.active .district_detail_chart[data-id="' + event_id.toString() + '"]')
    build_result_district_profile_detail_charts(ths_detail, detail_headers, detail_data);

  });
}



function get_district_event_type_data(event_type_id, shape_type_id){
  if (event_type_id == undefined){
    // it was not passed in so get active event type
    event_type_id = $('#district_profile .nav-tabs li.active a').data('id');
  }
  if (event_type_id != undefined){
    var url = gon.json_district_event_type_data_url.replace(gon.placeholder_event_type, event_type_id.toString());

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
//        if (gon.district_profile.type_id == 2){
          build_results_district_profile_charts();
//        } else if (gon.district_profile.type_id == 1){
//          build_other_district_profile_charts();
//        }
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

    get_district_event_type_data($(this).data('id'));
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


