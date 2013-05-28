var indicator_profile_data;
var summary_height = [];
var detail_height = [];
var number_events;

function build_indicator_profile_summary_charts(ths, indicator_data){
  if (ths != undefined && indicator_data != undefined){
    ths.highcharts({
      chart: {
          plotBackgroundColor: null,
          plotBorderWidth: null,
          plotShadow: false,
          height: 400,
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
      colors: [indicator_data.color, "#2884C3"],
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
    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_indicator_profile_detail_charts(ths, indicator_name, headers, data){
  if (ths != undefined && indicator_name != undefined && headers != undefined && headers.length > 0 && data != undefined && data.length > 0){
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
    // show no data message
    ths.html("<span class='no_data'>" + gon.chart_no_data + "</span>");
  }
}

function build_indicator_profile_charts(){
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
            if (indicator_profile_data[i].data[j].core_indicator_id.toString() == gon.indicator_profile.id.toString()){
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

    build_indicator_profile_summary_charts($(this), indicator_data);
    var ths_detail = $('.tab-pane.active .indicator_detail_chart[data-id="' + event_id.toString() + '"]')
    build_indicator_profile_detail_charts(ths_detail, indicator_name, detail_headers, detail_data);

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
        build_indicator_profile_charts();
      }
    });
  }
}

$(document).ready(function() {

  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });

  $('#tab1 table').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bStateSave": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 20,
    "aLengthMenu": [[20, 40, 60, 80], [20, 40, 60, 80]]
  });
  
  $('#tab2 table').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bStateSave": true,
    "bAutoWidth": false,
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 20,
    "aLengthMenu": [[20, 40, 60, 80], [20, 40, 60, 80]]
  });
  

  $(window).bind('load', get_ind_event_type_data());

  // when switch event types, get data for the new events
  $('#indicator_profile .nav-tabs li a').click(function(){
    // reset height array so the new charts can be resized correctly
    summary_height = []; 
    detail_height = [];

    get_ind_event_type_data($(this).data('id'));
  });

  // when district filter selected, update the charts
  $('.tab-pane.active select.district_filter_select').change(function(){
//    $('#indicator_profile .tab-content .tab-pane.active .highcharts-container').fadeOut(300, function(){
//      $(this).empty();
      var selected_option = $(".tab-pane.active select.district_filter_select option:selected");
      get_ind_event_type_data($(this).data('id'), $(selected_option).data('shape-type-id'), $(selected_option).data('id'), $(selected_option).text());
//    });
  });


  // when event filter changes, update what events to show
  $('.tab-pane.active #event_filter input[name="event_filter_checkboxes"]').live('change', function(){
    var event_id = $(this).val();
console.log("event_id = " + event_id);
    if ($(this).attr("checked") == undefined){
console.log("hiding");
      // hide this event
      $('.tab-pane.active .profile_item div[data-id="' + event_id + '"]').removeClass('active');
    }else{
console.log("showing");
      // show this event
      $('.tab-pane.active .profile_item div[data-id="' + event_id + '"]').addClass('active');
    }
  });
});


