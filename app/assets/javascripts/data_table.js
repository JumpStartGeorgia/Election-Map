$(function ()
{
  var p = $('#data-table'),
  dd_switcher = $('#dt_dd_switcher');

  $('#data-table-container .arrows > div').click(function ()
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
    nexti = (direction == 'left') ? ((+ visi == 1) ? gon.dt.g : + visi - 1) : ((+ visi == gon.dt.g) ? 1 : + visi + 1);
    visible.addClass('hidden');
    hidden.filter('.cg' + nexti).removeClass('hidden');
  /*
    dd_switcher.val(nexti);
  */
  });

  function highlight ()
  {
    if (gon.dt.p >= gon.dt.all)
    {
      return;
    }
    var nexti = dd_switcher.val(),
    datai = dd_switcher.children('option:selected').data('i'),
    s = p.find('th:not(cg0)[data-i="' + datai + '"], td:not(cg0)[data-i="' + datai + '"]');
    p.find('th.highlighted, td.highlighted').removeClass('highlighted');
    s.addClass('highlighted');

    hidden = p.find('th.cg' + nexti + ', td.cg' + nexti);
    visible = p.find('th:not(.cg0), td:not(.cg0)');

    visible.addClass('hidden');
    hidden.removeClass('hidden');
  }

  dd_switcher.ready(highlight);
  dd_switcher.change(highlight);

});






