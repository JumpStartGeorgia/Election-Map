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

// add/update the query paramter with the provided name and value
function update_query_parameter(url, name, name2, value){
  var new_url;
	// get the current url
	var index = url.indexOf(name + "=");
	var index2 = url.indexOf("/" + name2 + "/");
	if (index > 0){
		// found 'name=', now need to replace the value
		var name_length = name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index+name_length) + value + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index+name_length) + value;
		}
	}else if (index2 > 0) {
		// found '/name/', now need to replace the value
		var name_length = name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+name_length) + value + url.slice(indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+name_length) + value + url.slice(indexAfter2);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index2+name_length) + value;
		}
	}else {
		// not in query string yet, add it
		// if this is the first query string, add the ?, otherwise add &
    new_url = url;
		new_url += new_url.indexOf("?") > 0 ? "&" : "?"
		new_url += name + "=" + value;
	}
	return new_url;
}


// replace the query paramter with the new one that is provided
// - name is the long name of the parameter (e.g., event_id)
// - name2 is the abbreviated name that shows in the pretty url (e.g., event)
function replace_query_parameter(url, old_name, old_name2, new_name, new_name2, value, value2){
  var new_url;
	// get the current url
	var index = url.indexOf(old_name + "=");
	var index2 = url.indexOf("/" + old_name2 + "/");
	if (index > 0){
		// found 'name=', now need to replace the value
		var name_length = old_name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index) + new_name + "=" + value + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index) + new_name + "=" + value;
		}
	}else if (index2 > 0) {
		// found '/name/', now need to replace the value
		var name_length = old_name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+1) + new_name2 + "/" + value2 + url.slice(indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+1) + new_name2 + "/" + value2 + url.slice(indexAfter2);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index2+1) + new_name2 + "/" + value2;
		}
	}else {
		// not in query string yet, add it
		// if this is the first query string, add the ?, otherwise add &
    new_url = url;
		new_url += new_url.indexOf("?") > 0 ? "&" : "?"
		new_url += new_name + "=" + value;
	}
	return new_url;
}

// remove the query paramter with the provided name and value
// - name is the long name of the parameter (e.g., event_id)
// - name2 is the abbreviated name that shows in the pretty url (e.g., event)
function remove_query_parameter(url, name, name2){
  var new_url;
	// get the current url
	var index = url.indexOf(name + "=");
	var index2 = url.indexOf("/" + name2 + "/");
	if (index > 0){
		// found 'name=', now need to remove the parameter and its value
		var name_length = name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index) + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index);
		}
	}else if (index2 > 0) {
		// found '/name/', now need to remove the parameter and its value
		var name_length = name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2) + url.slice(indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2) + url.slice(indexAfter2);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index2);
		}
	}
	return new_url;
}

/*

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
*/
