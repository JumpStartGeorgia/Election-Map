$(document).ready(function(){

	if(gon.edit_menu_live_event){
    var startDate = $('#menu_live_event_menu_start_date');
    var endDate = $('#menu_live_event_menu_end_date');
    var availableTime = $('#menu_live_event_data_available_at');

		// load the date pickers
		startDate.datepicker({
				dateFormat: 'dd.mm.yy',
        onClose: function(dateText, inst) {
        		if (endDate.val() != '') {
        			var testStartDate = startDate.datetimepicker('getDate');
        			var testEndDate = endDate.datetimepicker('getDate');
        			if (testStartDate > testEndDate)
        				endDate.datetimepicker('setDate', testStartDate);
        		}
        		else {
        			endDate.val(dateText);
        		}
        	},
        	onSelect: function (selectedDateTime){
        		endDate.datetimepicker('option', 'minDate', startDate.datetimepicker('getDate') );
        	}
		});

		if (gon.menu_start_date !== undefined &&
				gon.menu_start_date.length > 0)
		{
			startDate.datepicker("setDate", new Date(gon.menu_start_date));
		}


		// load the date pickers
		endDate.datepicker({
				dateFormat: 'dd.mm.yy',
      	onClose: function(dateText, inst) {
      		if (startDate.val() != '') {
      			var testStartDate = startDate.datetimepicker('getDate');
      			var testEndDate = endDate.datetimepicker('getDate');
      			if (testStartDate > testEndDate)
      				startDate.datetimepicker('setDate', testEndDate);
      		}
      		else {
      			startDate.val(dateText);
      		}
      	},
      	onSelect: function (selectedDateTime){
      		startDate.datetimepicker('option', 'maxDate', endDate.datetimepicker('getDate') );
      	}
		});

		if (gon.menu_end_date !== undefined &&
				gon.menu_end_date.length > 0)
		{
			endDate.datepicker("setDate", new Date(gon.menu_end_date));
		}

		$(availableTime).datetimepicker({
				dateFormat: 'dd.mm.yy',
				timeFormat: 'hh:mm',
				separator: ' '
		});

		if (gon.data_available_at !== undefined &&
				gon.data_available_at.length > 0)
		{
			$(availableTime).datepicker("setDate", new Date(gon.data_available_at));
		}

	}


});
