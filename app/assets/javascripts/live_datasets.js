$(document).ready(function(){

	if(gon.edit_live_dataset){
		// load the date pickers
		$('#live_data_set_timestamp').datetimepicker({
				dateFormat: 'dd.mm.yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});

		if (gon.timestamp !== undefined &&
				gon.timestamp.length > 0)
		{
			$('#live_data_set_timestamp').datepicker("setDate", new Date(gon.timestamp));
		}
  }

	if(gon.load_data_live_dataset){
		// load the date pickers
		$('#timestamp').datetimepicker({
				dateFormat: 'dd.mm.yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});
  }
});
