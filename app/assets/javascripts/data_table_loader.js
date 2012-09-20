var f_style_backup;

function reset_data_table ()
{
  // reset the data table to the loading state
  $('#data-table-container #loading_image').delay(500).css('display', 'block');
  $('#data-table-container #blur_table_image').delay(500).css('display', 'block');
  $('#dt_ajax_replace').delay(500).empty();
}
function load_data_table ()
{
  // get the data and load it
  $.get(gon.data_table_path, function (data)
  {
    $('#data-table-container').css({height: 'auto'});
    $('#loading_image').hide();
    $('#blur_table_image').hide();
    $('#dt_ajax_replace').html(data);
    dt.clean();
    dt.init();
  });
}


var current_highlighted_feature;
function highlight_shape ()
{
  if (typeof gon.dt_highlight_shape == 'undefined')
  {
    return;
  }
  var features = map.layers[2].features;
  for (i = 0, num = features.length; i < num; i ++)
  {
    if (gon.dt_highlight_shape == features[i].data.common_name)
    {
      current_highlighted_feature = features[i];

      // backup feature styles
      f_style_backup = current_highlighted_feature.style;

      current_highlighted_feature.style = new OpenLayers.Style();
      current_highlighted_feature.style.fillColor = "#4A6884";//"#5c81a3";
      current_highlighted_feature.style.strokeColor = "#000000";
      current_highlighted_feature.style.strokeWidth = 2;
      current_highlighted_feature.style.fillOpacity = 1;
      current_highlighted_feature.layer.redraw();

      return current_highlighted_feature;
    }
  }
}
