$(document).ready(function() {
	if (gon.load_js_data_delete) {
    // if the event id and shape type id exist, pre_load the shape_type list
    if (gon.event_id){
			load_shape_types(gon.event_id, gon.shape_type_id);
    }

    // when event is selected, get the shape types for that event
		$('select#event_id').change(function(){
			load_shape_types($(this).find('option:selected').val());
		});

		$('select#shape_type_id').change(function(){
			load_indicators($('select#event_id').find('option:selected').val(), $(this).find('option:selected').val());
		});

    // when the button is clicked, save the text of the selected items
		$('input#submit').click(function(){
      $('input#event_name').val($('select#event_id').find('option:selected').text());
      $('input#shape_type_name').val($('select#shape_type_id').find('option:selected').text());
      $('input#indicator_name').val($('select#indicator_id').find('option:selected').text());
		});
		

	}
});

function load_indicators(event_id, shape_type_id, indicator_id){
	$.getJSON(
		'/' + I18n.locale + '/indicators/event/' + event_id + '/shape_type/' + shape_type_id + '.json',
		function(response) {
			var options = '<option value="0"></option>';
		  for (var i = 0; i < response.length; i++) {
		    options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
	    }
		  $("select#indicator_id").html(options);				
  	  if (indicator_id){
  		  $('select#indicator_id').val(indicator_id);
  	  }
	  }
	);  
}

