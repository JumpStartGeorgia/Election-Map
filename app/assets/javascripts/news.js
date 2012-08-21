$(document).ready(function(){

	if(gon.edit_news){
		// load the date pickers
		$('#news_date_posted').datepicker({
				dateFormat: 'dd.mm.yy',
		});

		if (gon.date_posted !== undefined &&
				gon.date_posted.length > 0)
		{
			$("#news_date_posted").datepicker("setDate", new Date(gon.date_posted));
		}

		// if the news type is data archive when the page loads, show data archive section
		toggle_news_data_archive('news_news_type');

		// if news type switches to data archive, show data archive section
		$('#news_news_type').change(function () {
			toggle_news_data_archive(this.id);
		});

	}
});

// if the news type is data archive, show data archive section
function toggle_news_data_archive(news_type_id) {
	if ($('#' + news_type_id).find('option:selected').val() == gon.data_archive){
		// show data archive section
		$('#news_data_archive_folder_input').show(300);
	} else {
		// hide data archive section
		$('#news_data_archive_folder_input').hide(300);
		$('#news_data_archive_folder').val([]);
	}

}
