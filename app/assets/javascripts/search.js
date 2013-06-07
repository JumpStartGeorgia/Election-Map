


$(document).ready(function(){

  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });

  // to be able to sort the jquery datatable build in the function below
  $.extend( $.fn.dataTableExt.oSort, {
	  "formatted-num-pre": function ( a ) {
		  a = (a === "-" || a === "") ? 0 : a.replace( /[^\d\-\.%]/g, "" );
		  return parseFloat( a );
	  },

	  "formatted-num-asc": function ( a, b ) {
		  return a - b;
	  },

	  "formatted-num-desc": function ( a, b ) {
		  return b - a;
	  }
  } );

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
  
  $('#district_profiles table').dataTable({
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

  $('#core-indicator-text').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bStateSave": true,
    "bAutoWidth": true,
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 0 ] }
    ],
    "aaSorting": [[1, 'asc']],
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 20,
    "aLengthMenu": [[20, 40, 60, 80], [20, 40, 60, 80]]
  });

  $('#users-datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "bStateSave": true,
    "sAjaxSource": $('#users-datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aaSorting": [[2, 'desc']]
  });


});


