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

});
