$(document).ready(function() {
	if (gon.load_js_event_custom_view_form) {
    // if the event id and shape type id exist, pre_load the shape_type list
    if (gon.event_id){
			if (gon.shape_type_id) {
				load_custom_shape_types(gon.event_id, "event_custom_view_shape_type_id", gon.shape_type_id);
			}
			if (gon.descendant_shape_type_id){
				load_custom_shape_types(gon.event_id, "event_custom_view_descendant_shape_type_id", gon.descendant_shape_type_id);
			}
    }

    // when event is selected, get the shape types for that event
		$('select#event_custom_view_event_id').change(function(){
			load_custom_shape_types($(this).find('option:selected').val(), "event_custom_view_shape_type_id");
			load_custom_shape_types($(this).find('option:selected').val(), "event_custom_view_descendant_shape_type_id");
		});

	}
});

function load_custom_shape_types(event_id, input_id, shape_type_id){
	$.getJSON(
		'/' + I18n.locale + '/shape_types/event/' + event_id + '.json',
		function(response) {
			var options = '';
		  for (var i = 0; i < response.length; i++) {
		    options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
	    }
  	  $('select#' + input_id).html(options);	
  	  if (shape_type_id){
  		  $('select#' + input_id).val(shape_type_id);
  	  }
	  }
	);  
}
