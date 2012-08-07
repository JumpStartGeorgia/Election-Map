$(document).ready(function() {
	if (gon.load_js_event_indicator_relationship_form) {
    // when the remove button is clicked, remove the content in that block
		$('button.remove').click(function(){
      $('div#' + this.id).fadeTo('slow', 0).slideUp(function(){
        jQuery(this).empty();
	    });
		});

		// add a new indicator type block
		$('button#add_indicator_type_block').click(function(){
			$.get("/" + I18n.locale + "/event_indicator_relationships/render_js_blocks/" + $('input#event_id').val() + "/indicator_type_block/" + $('input#counter').val(),
				function(data) {
				  $('input#counter').val(parseInt($('input#counter').val())+1);
				  $('div#relationships').append(data.html);
				}
			);
		});
		// add a new indicator block
		$('button#add_indicator_block').click(function(){
			$.get("/" + I18n.locale + "/event_indicator_relationships/render_js_blocks/" + $('input#event_id').val() + "/indicator_block/" + $('input#counter').val(),
				function(data) {
				  $('input#counter').val(parseInt($('input#counter').val())+1);
				  $('div#relationships').append(data.html);
				}
			);
		});
	}
});
