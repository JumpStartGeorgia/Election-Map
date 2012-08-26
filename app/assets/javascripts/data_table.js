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

/*
		$.tablesorter.addWidget({
			// take from http://tablesorter.com/docs/example-widgets.html
			// give the widget an id
			id: "repeatHeaders",
			// format is called when the on init and when a sorting has finished
			format: function(table) {
console.log "formatting repeat headers";
				// cache and collect all TH headers
				if(!this.headers) {
					var h = this.headers = [];
					$("thead th",table).each(function() {
					  h.push(
				      "" + $(this).text() + ""
					  );
					});
console.log "headers = " + headers;
				}

				// remove appended headers by classname.
				$("tr.repated-header",table).remove();

				// loop all tr elements and insert a copy of the "headers"
				for(var i=0; i < table.tBodies[0].rows.length; i++) {
					// insert a copy of the table head every 8th row
					if((i%8) == 7) {
					  $("tbody tr:eq(" + i + ")",table).before(
				      $("").html(this.headers.join(""))
					  );
					}
				}
			}
		});
*/
    dt.ph.tablesorter({
			// default sort = first column asc
			sortList: [[0,0]],
      // some columns have ',' (e.g., 1,250) or '-' (e.g., 6-8) and
			// this is causing the column to be sorted by string instead of number.
			// this will remove those so the sorting is done properly
      textExtraction: function(node) {
        return node.childNodes[1].innerHTML.replace(",","").replace("-","");
      }/*,
			widgets: ['zebra']*/
    });

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
    if (gon.dt.p >= gon.dt.all)
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

    dt.disable_arrows(nexti);

    visible.addClass('hidden');
    hidden.filter('.cg' + nexti).removeClass('hidden');
  },


  highlight: function ()
  {
  /*
    if (gon.dt.p >= gon.dt.all)
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

    if (nexti == gon.dt.g)
    {
      dt.right_arrow_overlay.show(0);
      dt.right_arrow_overlay_visible = true;
    }
    else if (nexti < gon.dt.g && dt.right_arrow_overlay_visible)
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
