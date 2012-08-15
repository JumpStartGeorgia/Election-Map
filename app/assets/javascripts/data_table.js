var dt =
{

  init: function ()
  {
    dt.ph = $('#data-table');
    dt.dd_switcher = $('#dt_dd_switcher');
    dt.left_arrow_overlay = $('#data-table-container .arrow-container-left .overlay');
    dt.right_arrow_overlay = $('#data-table-container .arrow-container-right .overlay');
    dt.left_arrow_overlay_visible = false;
    dt.right_arrow_overlay_visible = false;

    dt.ph.tablesorter();

    $('#data-table-container .arrows .arrow').click(dt.arrow_click_handler);

    dt.dd_switcher.ready(dt.highlight);
    dt.dd_switcher.change(dt.highlight);

			// update the url for the download data link
			$("#export-data-xls2").attr('href',update_query_parameter($("#export-data-xls").attr('href'), "event_name", "event_name", gon.event_name));
			$("#export-data-xls2").attr('href',update_query_parameter($("#export-data-xls").attr('href'), "map_title", "map_title", gon.map_title));
			$("#export-data-csv2").attr('href',update_query_parameter($("#export-data-csv").attr('href'), "event_name", "event_name", gon.event_name));
			$("#export-data-csv2").attr('href',update_query_parameter($("#export-data-csv").attr('href'), "map_title", "map_title", gon.map_title));

  },


  arrow_click_handler: function ()
  {
    if (gon.dt_p >= gon.dt_all)
    {
      return;
    }
    var direction = $(this).data('direction');

    hidden = dt.ph.find('th.hidden, td.hidden');
    visible = dt.ph.find('th:not(.hidden):not(.cg0), td:not(.hidden):not(.cg0)');

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
    //nexti = (direction == 'left') ? ((+ visi == 1) ? gon.dt_g : + visi - 1) : ((+ visi == gon.dt_g) ? 1 : + visi + 1);
    if (direction == 'left')
    {
      if (+ visi == 1)
      {
        //nexti = gon.dt_g;
        return false;
      }
      nexti = + visi - 1;
    }
    else if (direction == 'right')
    {
      if (+ visi == gon.dt_g)
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

    dt.disable_arrows(nexti);

    visible.addClass('hidden');
    hidden.filter('.cg' + nexti).removeClass('hidden');
  },


  highlight: function ()
  {
  /*
    if (gon.dt_p >= gon.dt_all)
    {
      return;
    }
  */
    var nexti = dt.dd_switcher.val();
    if (empty(nexti))
    {
      dt.disable_arrows(1);
      return;
    }

    dt.disable_arrows(nexti);

    var datai = dt.dd_switcher.children('option:selected').data('i');
    if (empty(datai))
    {
      return;
    }
    var s = dt.ph.find('th:not(cg0)[data-i="' + datai + '"], td:not(cg0)[data-i="' + datai + '"]');
    dt.ph.find('th.highlighted, td.highlighted').removeClass('highlighted');
    s.addClass('highlighted');

    hidden = dt.ph.find('th.cg' + nexti + ', td.cg' + nexti);
    visible = dt.ph.find('th:not(.cg0), td:not(.cg0)');

    visible.addClass('hidden');
    hidden.removeClass('hidden');
  },


  disable_arrows: function (nexti)
  {
    if (nexti == 1)
    {
      dt.left_arrow_overlay.show(0);
      dt.left_arrow_overlay_visible = true;
    }
    else if (nexti > 1 && dt.left_arrow_overlay_visible)
    {
      dt.left_arrow_overlay.hide(0);
      dt.left_arrow_overlay_visible = false;
    }

    if (nexti == gon.dt_g)
    {
      dt.right_arrow_overlay.show(0);
      dt.right_arrow_overlay_visible = true;
    }
    else if (nexti < gon.dt_g && dt.right_arrow_overlay_visible)
    {
      dt.right_arrow_overlay.hide(0);
      dt.right_arrow_overlay_visible = false;
    }
  }

};




function empty(variable)
{
  return (variable == null || variable == undefined || typeof variable == 'undefined' || variable == '');
}
