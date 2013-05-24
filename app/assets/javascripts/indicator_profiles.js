var indicator_profile_data;

function build_indicator_profile_summary_charts(ths, indicator_data){
  if (ths != undefined && indicator_data != undefined){
    ths.highcharts({
      chart: {
          plotBackgroundColor: null,
          plotBorderWidth: null,
          plotShadow: false
      },
      colors: [indicator_data.color, "#2884C3"],
      title: {
          text: gon.summary_chart_title + ": " + indicator_data.rank
      },
      credits: {
        enabled: false
      },
      tooltip: {
//  	    pointFormat: '<b>{point.percentage}%</b>',
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
  }
}

function build_indicator_profile_detail_charts(ths, indicator_name, headers, data){
  if (ths != undefined && headers != undefined && headers.length > 0 && data != undefined && data.length > 0){
    ths.highcharts({
      chart: {
          type: 'bar'
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
        for (var j=0;j<indicator_profile_data[i].data.length;j++){
          if (indicator_profile_data[i].data[j].core_indicator_id.toString() == gon.indicator_profile.id.toString()){
            indicator_data = indicator_profile_data[i].data[j];
            indicator_name = indicator_profile_data[i].data[j].indicator_name;
          }
          detail_headers.push(indicator_profile_data[i].data[j].indicator_name);  
          detail_data.push({y: Number(indicator_profile_data[i].data[j].value), color: indicator_profile_data[i].data[j].color});  
        }
        break;
      }
    }  
    if (indicator_data != undefined){
console.log(detail_data);
      build_indicator_profile_summary_charts($(this), indicator_data);
      var ths_detail = $('.tab-pane.active .indicator_detail_chart[data-id="' + event_id.toString() + '"]')
      build_indicator_profile_detail_charts(ths_detail, indicator_name, detail_headers, detail_data);
    }
  });
}

function get_ind_event_type_data(event_type_id){
  if (event_type_id == undefined){
    // it was not passed in so get active event type
    event_type_id = $('#indicator_profile .nav-tabs li.active a').data('id');
  }
  if (event_type_id != undefined){
    var url = gon.indicator_event_type_data_url.replace(gon.placeholder_core_indicator, gon.indicator_profile.id).replace(gon.placeholder_event_type, event_type_id.toString());
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

  $('#indicator_profile_1 table').dataTable({
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
  
  $('#indicator_profile_2 table').dataTable({
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
  

  // when indicator type is selected, show appropriate datatable
  $('.indicator_profile_type_selection_item').click(function(){
    var ths = $(this);
    // if the item that was clicked is for the table that is already showing, do nothing
    var active_table = $('div[id^="indicator_profile_"].active');
    if (active_table == undefined || $(this).data('id') != active_table.data('id')){
      // find the table to make active
      var new_table = $('div[id^="indicator_profile_"][data-id="' + $(this).data('id') + '"]');

      if (new_table != undefined){
        active_table.fadeOut(300, function(){
          active_table.removeClass('active');
          new_table.fadeIn(300);
          new_table.addClass('active');
          $('.indicator_profile_type_selection_item').removeClass('active');
          ths.addClass('active');
        });
      }      
    }
  });

  $(window).bind('load', get_ind_event_type_data());

  // when switch event types, get data for the new events
  $('#indicator_profile .nav-tabs li a').click(function(){
    get_ind_event_type_data($(this).data('id'));
  });

});
