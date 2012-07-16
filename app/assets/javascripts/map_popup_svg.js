/*  Useful functions  */
this.log=function(a){console.log(a)};Array.prototype.__=function(a){this.push(a)};this.foreach=function(a,b){if(typeof a.length==="number")for(var c=0;c<a.length;c++)b(c,a[c]);else if(typeof a.length==="undefined")for(var c in a)b(c,a[c])};this.extract=function(a){if(typeof a.length==="number")for(var b=0;b<a.length;b++)this[b]=a[b];else if(typeof a.length==="undefined")for(var b in a)this[b]=a[b]};this.ob=function(){this.code};this.ob.prototype.start=function(a){this.code=a.toString().substring(a.toString().search("{")+1,a.toString().search("}"))};this.ob.prototype.flush=function(){eval(this.code)}


/*  Declaring class  */
var className = "elmapsvgpopup";
this[className] = function(){
  var svg;
  this.y_s = 20;
  this.max_value = 0;
  this.max_ind_len = 0;
  this.max = 100;
  this.dist = 25;      
  this.i = 0;
  
};


/*  Class function  */

this[className].prototype.Rect = function(x, y, width, height)
{
  return this.svg.append("rect")
                 .attr("width", width)
                 .attr("height", height)
                 .attr("x", x)
                 .attr("y", y);
};

this[className].prototype.Text = function(x, y, text)
{
  return this.svg.append("text")
                 .attr("x", x)
                 .attr("y", y)
                 .text(text);
};

this[className].prototype.Line = function(x1, y1, x2, y2)
{
  return this.svg.append("line")
                 .attr("x1", x1)
                 .attr("y1", y1)
                 .attr("x2", x2)                 
                 .attr("y2", y2);
};

this[className].prototype.SVGElement = function(elname, attributes)
{
  var ret_svg = this.svg.append(elname);
  foreach(attributes, function(index, value){
     ret_svg.attr(index, value);
  });
  return ret_svg;  
};


this[className].prototype.processTheType = function(id_el, json, options)
{
    if (typeof(this.svg) === "undefined"){
      var d3elmapsvg = d3.select(id_el)
                       .append("svg")
                       .attr("xmlns", "http://www.w3.org/2000/svg")
                       .attr("class", "elmapsvg");   
                       
      this.svg = d3elmapsvg;                       
      
    }
    
    var ths = this;
    
    foreach(json.data, function(index, value){
      if(value.indicator_name_abbrv.length>ths.max_ind_len)      
        ths.max_ind_len = value.indicator_name_abbrv.length;
      if(value.value>ths.max_value)
        ths.max_value = value.value;
    });
    
      
    if (options.type == "summary_data"){
      this.SVGElement("text", {
        "x": (ths.max_ind_len*7-10)/2+10-50,
        "y": 20,
        "style": "font-size:15px;"
      }).text(json.title_location !== undefined ? json.title_location : json.title);
      
      if(json.title_summary !== undefined)
        this.SVGElement("text", {
          "x": (ths.max_ind_len*7-10)/2-json.title_summary.length/2-50,
          "y": 40,
          "style": "font-size:15px;"
        }).text(json.title_summary);    
        ths.y_s = 50;  
    }
        
    
        
        
    var svgElements = new Array;    
    foreach(json.data.slice(0, options.limit !== undefined ? options.limit : json.data.length), function(i, value){ 
      svgElements.__({});
      if (options.type === "summary_data"){
        svgElements[svgElements.length-1]['Rect'] = [{ 
          "x": 10,
          "y": ths.y_s+i*ths.dist,
          "width": 10,
          "height": 10,
          "style": "fill:"+value.color         
        },{
          "x": 30+ths.max_ind_len*7+80,
          "y": ths.y_s+i*ths.dist,
          "width": ths.max/100*value.value,
          "height": 10,
          "style": "fill:#5c81a3"  
        }];
        
        
        
        window.maxSVGWidth = 30+ths.max_ind_len*7+80+ths.max/100*json.data[0].value+10;        
        window.summaryWidthDone = true;
      }               
      else if (value.indicator_name_abbrv !== "არ არის მონაცემი" && typeof window.summaryWidthDone === "undefined")
        window.maxSVGWidth = (30+ths.max_ind_len*7+10)+(ths.max_value.toString().length*7+50);
      else
        window.maxSVGWidth = 30+ths.max_ind_len*7+10+"არ არის მონაცემი".length*7+50;
      
      
      window.makeline = true;
      
      if (window.makeline)  
      {     
        svgElements[svgElements.length-1]['Line'] = {
          "x1": 10,
          "y1": ths.y_s+ths.i*ths.dist+15,
          "x2": window.maxSVGWidth-10,
          "y2": ths.y_s+ths.i*ths.dist+15,
          "style": "stroke-width:1px;stroke:#CCC" 
        };
        
      }
      
      svgElements[svgElements.length-1]['Text'] = [[{
          "x": 30,
          "y": ths.y_s+10+ths.i*ths.dist,
          "style": "font-size:12px;",
          "class": "title",
          "fullText": value.indicator_name
        }, value.indicator_name_abbrv],
        [{
          "x": 30+ths.max_ind_len*7+10,
          "y": ths.y_s+10+ths.i*ths.dist,
          "style": "font-size:12px;"  
        }, value.value+(value.number_format === null ? "" : value.number_format)]];
        
       
        ths.i++;
        
        window.maxSVGHeight = ths.y_s+10+ths.i*ths.dist+10;
    });  
    
    foreach(svgElements, function(index, value){
      foreach(value, function(ind, val){
         if (val instanceof Array)
            foreach(val, function(the_ind, the_val){            
              if (ind.toLowerCase().search("text") !== -1)
                ths.SVGElement(ind.toLowerCase(), the_val[0]).text(the_val[1]);                
              else
                ths.SVGElement(ind.toLowerCase(), the_val);
            });          
         else
          ths.SVGElement(ind.toLowerCase(), val);                  
      });             
    });
    
    
    
};

this[className].prototype.processJSON = function(id_el, json, options)
{ 
  var ths = this;  
  foreach(json, function(index, value){
    
    if (typeof value.summary_data === "object")
    {
      options['type'] = "summary_data"; 
      json = value.summary_data;
    }
    else if (typeof value.data_item === "object")
    {
      options['type'] = "data_item";
      json = {};
      json.data = [{
        indicator_name_abbrv: value.data_item.indicator_name,
        indicator_name: value.data_item.indicator_name,
        number_format: value.data_item.number_format,
        value: value.data_item.value
      }];
    }  
    
    

    ths.processTheType(id_el, json, options);
    
  });
    
  
    
    //var title_texts = document.getElementsByClassName("title");
    //foreach(title_texts, function(index, value){      
    //  svgtipsify(value, 150, 30, "tipsy");      
    //});
    
      
};



$(document).mouseover(function(e){
  window.mouse = {
    X: e.pageX,
    Y: e.pageY
  };
});



