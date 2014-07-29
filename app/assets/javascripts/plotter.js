// Have Sprockets pull the flot javascript files into this one during asset compilation
//= require ./flot/jquery.flot.js

// Plot functions for judge grade distribution overlaid on the normal

function gauss(u,s,x) {
  var e = 2.71828;
  var pi = 3.14159;
  var exp = - ((x - u) * (x - u)) / (2 * s * s);
  var e_exp = Math.pow(e, exp);
  var one_over_sig_pi = 1 / (s * Math.sqrt(2 * pi));
  return one_over_sig_pi * e_exp;
}

function normModel(u,s,total) {
  var normCurve = [];
  for (var i = 0; i < 10.0; i += 0.1) {
     normCurve.push([i, gauss(u,s,i) * total/2.0]);
  }
  return normCurve;
}

function normBars(u,s,total) {
  var normCurve = [];
  var sum = 0;
  for (var i = 0; i <= 10.0; i += 0.5) {
     var y = gauss(u,s,i) * total/2.0;
     normCurve.push([i, y]);
     sum += y;
  }
  return normCurve;
}

function showHistogram(target, data) {
  var total = 0;
  var count = 0;
  for (var i = 0; i < data.length; ++i) {
    if (data[i][0] != 0) {
      total += data[i][1] * data[i][0];
      count += data[i][1];
    }
  }
  var mean = total / count;
  var stddev = 0;
  for (var i = 0; i < data.length; ++i) {
    if (data[i][0] != 0) {
      delta = data[i][0] - mean;
      stddev += data[i][1] * delta * delta;
    }
  }
  stddev = Math.sqrt(stddev / count);
  $.plot(target, 
        [
          { data:normModel(mean, stddev, count),
            lines: { show:true }
          },
          { data:normBars(mean, stddev, count), 
            bars: { show:true, 
                    barWidth:0.5, 
                    align:"center",
                    fillColor: { colors: [ { opacity: 0.3 }, { opacity: 0.1 } ] }
                  } 
          },
          { data:data, 
            bars: { show:true, 
                    barWidth:0.5, 
                    align:"center" 
                  } 
          }
        ] );
  // console.log("mean: " + mean + ", stddev: " + stddev + ", count: " + count);
}

