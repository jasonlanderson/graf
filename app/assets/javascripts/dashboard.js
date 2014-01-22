ANALYTICS_TABLE_OPTIONS = {
    "sScrollY": "350px",
    //"sScrollX": "800px",
    "bPaginate": false,
    "bAutoWidth" : true,
    "bFilter": true,
    "aaSorting": [[ 1, "desc" ]]
  };

PIE_OPTIONS = {
  series: {
    pie: {
      show: true,
      radius: 1,
      label: {
        show: true,
        radius: 2/3,
        formatter: function(label, series){
          return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">'+label+'<br/>'+Math.round(series.percent)+'%</div>';
        },
        threshold: 0.04
      }      
    }
  },
  legend: {
    labelBoxBorderColor: "none",
    backgroundOpacity: 0.5
  }
};
PIE_OPTIONS.colors = CHART_COLORS;

LINE_OPTIONS = {
  series: {
    lines: {
      show: true
    },
    points: {
      show: true
    }
  },
  xaxis: {
    //tickDecimals: 0, 
    mode: "time",
    minTickSize: [1, "month"],
    //min: (new Date("2010/01/01")).getTime(),
    //max: (new Date("2014/01/02")).getTime()
  },
  legend: {
    position: "nw"
  },
  yaxis: {
    minTickSize: 5
  }
};
LINE_OPTIONS.colors = CHART_COLORS;

function apiAJAX(data, format, responseType, callback){
  data.format = format
  $.ajax({
      url: "api",
      data: data,
      method: 'POST',
      dataType: responseType,
      success: callback
  });
}

function parsePieToBar(data) {
  points = [];
  ticks = [];
  for (i = 0 ; i < data.length ; i++) {
     points.push(Array(i, data[i].data));
     ticks.push(Array(i, data[i].label));
  }

  data = [{
    data: points,
    minTickSize: 1,
    bars: { 
      show: true,
      align: 'center'
    }         
  }];

  options = {
    xaxis: {
      tickDecimals: 0,
      labelAngle: 90,
      ticks: ticks
    }
  };
  options.colors = CHART_COLORS;
  return {data: data, options: options};
}
