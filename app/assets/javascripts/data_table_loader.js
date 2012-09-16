var f_style_backup;

function reset_data_table ()
{
  // reset the data table to the loading state
  $('#data-table-container #loading_image').css('display', 'block');
  $('#data-table-container #blur_table_image').css('display', 'block');
  $('#data-table-container #data-table').empty();    
}
function load_data_table ()
{
  // get the data and load it
  $.get(gon.data_table_path, function (data)
  {
    $('#data-table-container').css({height: 'auto'});
    $('#data-table-container #loading_image').css('display', 'none');
    $('#data-table-container #blur_table_image').css('display', 'none');
    $('#data-table-container #data-table').append(data);    
  });
}



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
      f = features[i];

      // backup feature styles
      f_style_backup = f.style;

      f.style = new OpenLayers.Style();
      f.style.fillColor = "#4A6884";//"#5c81a3";
      f.style.strokeColor = "#000000";
      f.style.strokeWidth = 2;
      f.style.fillOpacity = 1;
      f.layer.redraw();

      return f;
    }
  }
}
