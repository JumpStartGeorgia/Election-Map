$(document).ready(function() {
	if (gon.load_js_data_delete) {
		$('select#event_id').change(function(){
			var event_id = $(this).find('option:selected').val();
			$.getJSON(
				'/' + I18n.locale + '/shape_types/event/' + event_id + '.json',
				function(response) {
					var options = '';
				  for (var i = 0; i < response.length; i++) {
				    options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
				  }
				  $("select#shape_type_id").html(options);				}
				);
		});

		$('select#shape_type_id').change(function(){
			var event_id = $('select#event_id').find('option:selected').val();
			var shape_type_id = $(this).find('option:selected').val();
			$.getJSON(
				'/' + I18n.locale + '/indicators/event/' + event_id + '/shape_type/' + shape_type_id + '.json',
				function(response) {
					var options = '';
				  for (var i = 0; i < response.length; i++) {
				    options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
				  }
				  $("select#shape_type_id").html(options);				}
				);
		});
	}
});


