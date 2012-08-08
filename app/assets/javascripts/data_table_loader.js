var f_style_backup,
container = $('#data-table-container');


function load_data_table ()
{
  $('head').append('<link href="/assets/data_table/style.css" media="screen" rel="stylesheet" type="text/css" />');

  $.get(gon.data_table_path, function (data)
  {
    container.html(data);
    container.slideDown();
  });

  //$('body').append('<script src="/assets/data_table.js" type="text/javascript"></script>');
}



function highlight_shape ()
{
  if (typeof gon.dt_common_name == 'undefined')
  {
    return;
  }
  var features = map.layers[2].features;
  for (i = 0, num = features.length; i < num; i ++)
  {
    if (gon.dt_common_name == features[i].data.common_name)
    {
      f = features[i];      
      
      // backup feature styles
      f_style_backup = f.style;

      f.style = new OpenLayers.Style();
      f.style.fillColor = "#4A6884";//"#5c81a3";
      f.style.strokeColor = "#000000";
      f.style.strokeWidth = .5;
      f.style.fillOpacity = 1;
      f.layer.redraw();

      return f;
    }
  }
}
