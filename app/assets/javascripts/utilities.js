// add/update the query paramter with the provided name and value
function update_query_parameter(url, name, name2, value){
	// get the current url
	var index = url.indexOf(name + "=");
	var index2 = url.indexOf("/" + name2 + "/");
	if (index > 0){
		// found 'name=', now need to replace the value
		var name_length = name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			url = url.slice(0, index+name_length) + value + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			url = url.slice(0, index+name_length) + value;
		}
	}else if (index2 > 0) {
		// found '/name/', now need to replace the value
		var name_length = name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			url = url.slice(0, index2+name_length) + value + url.slice(indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			url = url.slice(0, index2+name_length) + value + url.slice(indexAfter2);
		}else {
			// no more parameters after this one
			url = url.slice(0, index2+name_length) + value;
		}
	}else {
		// not in query string yet, add it
		// if this is the first query string, add the ?, otherwise add &
		url += url.indexOf("?") > 0 ? "&" : "?"
		url += name + "=" + value;
	}
	return url;
}

// get the query paramter with the provided name
// - name is the long name of the parameter (e.g., event_id)
// - name2 is the abbreviated name that shows in the pretty url (e.g., event)
function get_query_parameter(url, name, name2){
	var value;
	var index = url.indexOf(name + "=");
	var index2 = url.indexOf("/" + name2 + "/");
	if (index > 0){
		// found 'name=', now need to replace the value
		var name_length = name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			value = url.slice(index+name_length, indexAfter);
		}else {
			// no more parameters after this one
			value = url.slice(index+name_length, url.length);
		}
	}else if (index2 > 0) {
		// found '/name/', now need to replace the value
		var name_length = name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			value = url.slice(index2+name_length, indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			value = url.slice(index2+name_length, indexAfter2);
		}else {
			// no more parameters after this one
			value = url.slice(index2+name_length, url.length);
		}
	}
	return value;
}

function full_height (element)
{
  if (element.length == 0)
  {
    return 0;
  }
  var values =
  [
    element.height(),
    element.css('margin-top'),
    element.css('margin-bottom'),
    element.css('padding-top'),
    element.css('padding-bottom'),
    element.css('border-top-width'),
    element.css('border-bottom-width')
  ],
  h = 0;
  for (i in values)
  {
    h += parseInt(values[i]);
  }
  return h;
}


function window_width ()
{
  var winW;
  if (document.body && document.body.offsetWidth)
  {
    winW = document.body.offsetWidth;
  }
  else if (document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.offsetWidth)
  {
    winW = document.documentElement.offsetWidth;
  }
  else if (window.innerWidth)
  {
    winW = window.innerWidth;
  }
  return winW;
}
