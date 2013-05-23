var indicator_profile_data;

function build_indicator_profile_summary_charts(){
  $('.tab-pane.active .indicator_summary_chart').each(function(){
    var event_id = $(this).data('id');
    var indicator_data;
    for (var i=0;i<indicator_profile_data.length;i++){
      if (indicator_profile_data[i].event.id.toString() == $(this).data('id')){
        for (var j=0;j<indicator_profile_data[i].data.length;j++){
          if (indicator_profile_data[i].data[j].core_indicator_id.toString() == gon.indicator_profile.id.toString()){
            indicator_data = indicator_profile_data[i].data[j];
            break;
          }
        }
        break;
      }
    }  

    if (indicator_data != undefined){
      $(this).highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: gon.summary_chart_title + ": " + indicator_data.rank
        },
        tooltip: {
	        enabled: false
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    color: '#000000',
                    connectorColor: '#000000',
                  	percentageDecimals: 1,
                    formatter: function() {
                        return '<b>'+ this.point.name +'</b>: '+ Highcharts.numberFormat(this.percentage, 1) + '%';
                    }
                }
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
  });
}

function build_indicator_profile_detail_charts(){

}

function build_indicator_profile_charts(){
  build_indicator_profile_summary_charts();
  build_indicator_profile_detail_charts();
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
