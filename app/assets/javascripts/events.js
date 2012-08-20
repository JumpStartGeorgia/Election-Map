$(document).ready(function(){

	if(gon.edit_event){
		// load the date pickers
		$('#event_event_date').datepicker({
				dateFormat: 'dd.mm.yy',
		});

		if (gon.event_date !== undefined &&
				gon.event_date.length > 0)
		{
			$("#event_event_date").datepicker("setDate", new Date(gon.event_date));
		}
	}
});
