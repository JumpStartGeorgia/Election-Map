$(document).ready(function(){

	if(gon.edit_dataset){
		// load the date pickers
		$('#data_set_timestamp').datetimepicker({
				dateFormat: 'dd.mm.yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});

		if (gon.timestamp !== undefined &&
				gon.timestamp.length > 0)
		{
			$('#data_set_timestamp').datepicker("setDate", new Date(gon.timestamp));
		}
  }

	if(gon.load_data_dataset){
		// load the date pickers
		$('#timestamp').datetimepicker({
				dateFormat: 'dd.mm.yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});

		// if the form is loading with data, make sure the correct fields are showing
		if ($('input:radio[name=data_type]:checked').val() === $('#data_type_official').val()) {
			show_official_data_type_fields();
		} else if ($('input:radio[name=data_type]:checked').val() === $('#data_type_live').val()) {
			show_live_data_type_fields();
		}



		$('#data_type_official').change(function() {
			show_official_data_type_fields();
		});

		$('#data_type_live').change(function() {
			show_live_data_type_fields();
		});
  }
});

function show_live_data_type_fields() {
	$('#hidden_fields_live').show();
	$('#hidden_fields_official').hide();
	$('#hidden_fields_common').show();
	$('#hidden_button').show();
}

function show_official_data_type_fields() {
	$('#hidden_fields_live').hide();
	$('#hidden_fields_official').show();
	$('#hidden_fields_common').show();
	$('#hidden_button').show();
}
