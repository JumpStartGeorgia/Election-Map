$(document).ready(function(){

	if(gon.live_event_with_no_data){
    $('#counter').countdown({
        startTime: gon.live_event_time_to_data,
        image: "/assets/digits.png"
    });
		// update the wrapper id tag so that the map background image shows
		$('#wrapper').attr('id', 'wrapper_error');


		// check for live data updates every 1 minute
		var event_id = get_query_parameter(window.location.href, 'event_id', 'event');
		var data_type = get_query_parameter(window.location.href, 'data_type', 'data_type');
		if (event_id && data_type){
			setInterval(function() {
				$.getJSON(
					'/' + I18n.locale + '/json/current_data_set/event/' + event_id + '/data_type/' + data_type + '.json',
					function(response) {
						// if the response value has id, then reload page so data shows
						if (response !== null){
							window.location.reload(true);
						}
					}
				);
			}, 1000 * 60 * 1);
	  }
  }
});
