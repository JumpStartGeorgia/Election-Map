$(document).ready(function(){

	if(gon.live_event_with_no_data){
    $('#counter').countdown({
        startTime: gon.live_event_time_to_data,
        image: "/assets/digits.png"
    });
		// update the wrapper id tag so that the map background image shows
		$('#wrapper').attr('id', 'wrapper_error');
  }
});
