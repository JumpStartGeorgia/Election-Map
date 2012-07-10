$(function ()
{

  $('#data-table-container .arrows > div').click(function ()
  {
    if (gon.dt.p >= gon.dt.all)
    {
      return;
    }
    var direction = $(this).data('direction');
    var p = $('#data-table');

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
      if (direction == 'left')
      {
        nexti = (+ visi == 1) ? gon.dt.g : + visi - 1;
      }
      else if (direction == 'right')
      {
        nexti = (+ visi == gon.dt.g) ? 1 : + visi + 1;
      }
      visible.addClass('hidden');
      hidden.filter('.cg' + nexti).removeClass('hidden');
      break;
    }
  });

});
