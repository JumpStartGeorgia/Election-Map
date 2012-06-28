$(document).ready(function() {
	if (gon.load_js_shape_delete) {
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
	}
});


