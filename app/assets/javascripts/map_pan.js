 var math = Math;

 function animate (opts)
 {
   var start = new Date();

   var id = setInterval(function ()
   {

     var timePassed = new Date() - start;
     var progress   = timePassed / opts.duration;

     (progress > 1) && (progress = 1);

     var delta = opts.delta(progress);
     opts.step(delta);

     (progress == 1) && (clearInterval(id));

   }, opts.delay || 10);
 };

 function delta (progress)
 {
   return math.pow(1 - progress, 5);
 }

 function movemap (element, duration, direction)
 {
   var to = 20,
   redrawed = false;

   animate (
   {

     delay   : 10,
     duration: duration,
     delta   : delta,
     step    : function (delta)
     {
     //element.style.left = to * + delta + 'px';
       var k = delta * to;
       element.moveByPx(direction[0] * k, direction[1] * k);

       if (delta < .01 && redrawed == false)
       {
         element.layers[2].redraw();
         redrawed = true;
       }
     }

   });

 }
