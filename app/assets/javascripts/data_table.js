var f, f_style_backup;
$(function ()
{
  var p = $('#data-table'),
  dd_switcher = $('#dt_dd_switcher'),
  left_arrow_overlay = $('#data-table-container .arrow-container-left .overlay'),
  right_arrow_overlay = $('#data-table-container .arrow-container-right .overlay'),
  left_arrow_overlay_visible = false,
  right_arrow_overlay_visible = false;

  p.tablesorter();
    

  $('#data-table-container .arrows .arrow').click(function ()
  {
    if (gon.dt.p >= gon.dt.all)
    {
      return;
    }
    var direction = $(this).data('direction');

    hidden = p.find('th.hidden, td.hidden');
    visible = p.find('th:not(.hidden):not(.cg0), td:not(.hidden):not(.cg0)');

    classes = visible.get(0).getAttribute('class').split(' ');
    for (i in classes)
    {
      if (classes[i].substring(0, 2) != 'cg')
      {
        continue;
      }
      visi = classes[i].substring(2);
      break;
    }
    //nexti = (direction == 'left') ? ((+ visi == 1) ? gon.dt.g : + visi - 1) : ((+ visi == gon.dt.g) ? 1 : + visi + 1);
    if (direction == 'left')
    {
      if (+ visi == 1)
      {
        //nexti = gon.dt.g;
        return false;
      }
      nexti = + visi - 1;
    }
    else if (direction == 'right')
    {
      if (+ visi == gon.dt.g)
      {
        //nexti = 1;
        return false;
      }
      nexti = + visi + 1;
    }
    else
    {
      return false;
    }

    disable_arrows(nexti);

    visible.addClass('hidden');
    hidden.filter('.cg' + nexti).removeClass('hidden');
  });

  function highlight ()
  {
  /*
    if (gon.dt.p >= gon.dt.all)
    {
      return;
    }
  */
    var nexti = dd_switcher.val();
    if (empty(nexti))
    {
      disable_arrows(1);
      return;
    }

    disable_arrows(nexti);

    var datai = dd_switcher.children('option:selected').data('i');
    if (empty(datai))
    {
      return;
    }
    var s = p.find('th:not(cg0)[data-i="' + datai + '"], td:not(cg0)[data-i="' + datai + '"]');
    p.find('th.highlighted, td.highlighted').removeClass('highlighted');
    s.addClass('highlighted');

    hidden = p.find('th.cg' + nexti + ', td.cg' + nexti);
    visible = p.find('th:not(.cg0), td:not(.cg0)');

    visible.addClass('hidden');
    hidden.removeClass('hidden');
  }


  function disable_arrows (nexti)
  {
    if (nexti == 1)
    {
      left_arrow_overlay.show(0);
      left_arrow_overlay_visible = true;
    }
    else if (nexti == gon.dt.g)
    {
      right_arrow_overlay.show(0);
      right_arrow_overlay_visible = true;
    }
    if (nexti < gon.dt.g && right_arrow_overlay_visible)
    {
      right_arrow_overlay.hide(0);
      right_arrow_overlay_visible = false;
    }
    else if (nexti > 1 && left_arrow_overlay_visible)
    {
      left_arrow_overlay.hide(0);
      left_arrow_overlay_visible = false;
    }
  }

  dd_switcher.ready(highlight);
  dd_switcher.change(highlight);





});

function empty(variable)
{
  return (variable == null || variable == undefined || typeof variable == 'undefined' || variable == '');
}

function highlight_shape ()
{
  var features = map.layers[2].features;
  for (i = 0, num = features.length; i < num; i ++)
  {
    if (gon.dt.common_name == features[i].data.common_name)
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




