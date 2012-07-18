$(document).ready(function() {
	if (gon.load_js_shape_delete) {
    // if the event id and shape type id exist, pre_load the shape_type list
    if (gon.event_id){
			load_shape_types(gon.event_id, gon.shape_type_id);
    }

    // when event is selected, get the shape types for that event
		$('select#event_id').change(function(){
			load_shape_types($(this).find('option:selected').val());
		});

    // when the button is clicked, save the text of the selected items
		$('input#submit').click(function(){
      $('input#event_name').val($('select#event_id').find('option:selected').text());
      $('input#shape_type_name').val($('select#shape_type_id').find('option:selected').text());
		});
		
	}
});

function load_shape_types(event_id, shape_type_id){
	$.getJSON(
		'/' + I18n.locale + '/shape_types/event/' + event_id + '.json',
		function(response) {
			var options = '<option value="0"></option>';
		  for (var i = 0; i < response.length; i++) {
		    options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
	    }
  	  $("select#shape_type_id").html(options);	
  	  if (shape_type_id){
  		  $('select#shape_type_id').val(shape_type_id);
  	  }
	  }
	);  
}
