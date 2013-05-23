$(document).ready(function() {

  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });

  $('#indicator_profile_2').dataTable({
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
  

});
