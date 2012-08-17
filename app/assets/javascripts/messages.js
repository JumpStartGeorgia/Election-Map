$('form#new_message a#submit').click(function() {
  $('form#new_message').submit();
});

$('form#new_message a#reset').click(function() {
	$('form#new_message')[0].reset();
});
