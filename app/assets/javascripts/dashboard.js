//
// General dashboard Functions
//
function dashboardAJAX(loaderID, widgetID, data, format, responseType, callback){
  data.format = format
  data.timeframe = $("#dashboard_timeframe").val()
  console.log(data)
  $.ajax({
      beforeSend: function() {
        $(loaderID).show();
        $(widgetID).hide();
      },
      url: "analytics_data",
      data: data,
      method: 'POST',
      dataType: responseType,
      complete: function(){
    	$(loaderID).hide();
        $(widgetID).show();
        
      },
      success: callback,
      error: function(XMLHttpRequest, textStatus, errorThrown) { 
        alert("Status: " + textStatus); alert("Error: " + errorThrown); 
    }       
  });
}

function setDashboardVisibility(element_id){

  setSelectedPageButtonStyle(0);
  if ($("#dashboard_view_type").val() == "line") {
    //document.getElementById(element_id).style.visibility = 'visible' ;
    $("#" + element_id).multiselect('enable')
  }
  else {
    //document.getElementById(element_id).style.visibility = 'hidden' ;  
    $("#" + element_id).multiselect('disable')
  }
}

function setTimeFrame(){
  if ( $("#dashboard_timeframe").val() == "month" ) {
      LINE_OPTIONS.xaxis.minTickSize = [1, "month"] ; 
  } 
  else if ( $("#dashboard_timeframe").val() == "quarter" ) {
      LINE_OPTIONS.xaxis.minTickSize = [1, "quarter"] ; 
  } 
  else if ( $("#dashboard_timeframe").val() == "year" ) {
      LINE_OPTIONS.xaxis.minTickSize = [1, "year"] ; 
  }
  refreshDashboardChartData();
}


function setupDashboardReady() {
  // Setup Controls

  $("#dashboard_timeframe").multiselect(SINGLE_SELECT_OPTIONS);
  $("#dashboard_rollup").multiselect(SINGLE_SELECT_OPTIONS);
  $("#metric_filter").multiselect(SINGLE_SELECT_OPTIONS);
  $("#dashboard_view_type").multiselect(SINGLE_SELECT_OPTIONS);

  $("#metric_filter").change(function () {
    metricChanged();
  });

  setDashboardVisibility('dashboard_timeframe'); // TODO, Shouldn't have to run this twice
  
  $("#dashboard_view_type").change(function () {
    refreshDashboardChartData();
    setDashboardVisibility('dashboard_timeframe');
  });

  $("#dashboard_rollup").change(function () {
    refreshDashboardChartData();
  });

  $("#dashboard_timeframe").change(function() {
    setTimeFrame();
    refreshDashboardChartData();
  });

  // Load local storage
  loadFiltersFromLocalStorage();

  // Make restrictions
  restrictFilters();
  restrictGroupBys();
  restrictDashboardChartViews();

  // Load initial data
  refreshDashboardData();

  // TODO: Put in its own function
  var previousPoint = null;

  bindToNode("#dashboard_metric_chart_companies");
  bindToNode("#dashboard_metric_chart_modules");
  bindToNode("#dashboard_metric_chart_engineers");

}

function dashboardFilterChanged() {
  storeFiltersToLocalStorage();

  refreshDashboardData();
}

function metricChanged() {
  // Make restrictions
  restrictFilters();
  restrictGroupBys();
  restrictDashboardChartViews();
  storeFiltersToLocalStorage();
  refreshDashboardData();
}

function refreshDashboardData() {
  refreshDashboardChartData();
  refreshDashboardTableData();
}

function refreshDashboardChartData() {
  if (!allowDataRefresh) {
    return;
  }
  var metricValue =  $("#metric_filter").val();
  // Update Chart
  var companyData = {
		    metric: metricValue,
		    groupBy: 'company',
		    rollupCount: 15,
		    searchCriteria: createSearchCriteriaJSON()
		  };
  var moduleData = {
		    metric: metricValue,
		    groupBy: 'repo',
		    rollupCount: 15,
		    searchCriteria: createSearchCriteriaJSON()
		  };
  var engineerData = {
		    metric: metricValue,
		    groupBy: 'user_name',
		    rollupCount: 15,
		    searchCriteria: createSearchCriteriaJSON()
		  };
  
  dashboardAJAX(
		  '#dashboard_table_container_companies_loader', 
		  "#dashboard_metric_chart_companies",
		  companyData,
		  'pie', 
		  'json', 
		  updateDashboardCompaniesChartCallback);
  dashboardAJAX(
		  '#dashboard_table_container_modules_loader', 
		  "#dashboard_metric_chart_modules",
		  moduleData, 
		  'pie', 
		  'json', 
		  updateDashboardModulesChartCallback);
  dashboardAJAX(
		  '#dashboard_table_container_engineers_loader', 
		  "#dashboard_metric_chart_engineers",
		  engineerData, 
		  'pie', 
		  'json', 
		  updateDashboardEngineersChartCallback);
  
  // Update the titles
  //$("#dashboard_chart_title").html($("#metric_filter option:selected").text() +  " Grouped By " + $("#group_by_filter option:selected").text());
}

function refreshDashboardTableData() {
  if (!allowDataRefresh) {
    return;
  }

  // $("#dashboard_table_title").html($("#metric_filter option:selected").text() +  " Grouped By " + $("#group_by_filter option:selected").text());
  
  var metricValue =  $("#metric_filter").val();
  // Update Chart
  var companiesData = {
		    metric: metricValue,
		    groupBy: 'company',
		    searchCriteria: createSearchCriteriaJSON()
		  };
  var modulesData = {
		    metric: metricValue,
		    groupBy: 'repo',
		    searchCriteria: createSearchCriteriaJSON()
		  };
  var engineersData = {
		    metric: metricValue,
		    groupBy: 'user_name',
		    searchCriteria: createSearchCriteriaJSON()
		  };
  
  dashboardAJAX(
		  '#dashboard_table_container_companies_loader',
		  '#dashboard_table_container_companies',
		  companiesData,
		  'table', 
		  'text', 
		  updateDashboardCompaniesTableCallback);
  dashboardAJAX(
		  '#dashboard_table_container_modules_loader', 
		  '#dashboard_table_container_modules',
		  modulesData, 
		  'table', 
		  'text', 
		  updateDashboardModulesTableCallback);
  dashboardAJAX(
		  '#dashboard_table_container_engineers_loader',
		  '#dashboard_table_container_engineers',
		  engineersData, 
		  'table', 
		  'text', 
		  updateDashboardEngineersTableCallback);
}

function restrictGroupBys() {

  // re-enabling data refreshing
  allowDataRefresh = true;
}



//
// Data Table
//
function updateDashboardCompaniesTableCallback(result) {
	common_populateTable('#dashboard_table_container_companies', "dashboard_table_companies", DASHBOARD_TABLE_OPTIONS, result);
}
function updateDashboardModulesTableCallback(result) {
	common_populateTable('#dashboard_table_container_modules', "dashboard_table_modules", DASHBOARD_TABLE_OPTIONS, result);
}
function updateDashboardEngineersTableCallback(result) {
	common_populateTable('#dashboard_table_container_engineers', "dashboard_table_engineers", DASHBOARD_TABLE_OPTIONS, result);
}



DASHBOARD_TABLE_OPTIONS = {
  "sScrollY": "100%",
  "sScrollX": "448px",
  "sXInner": "448px",
  "bPaginate": true,
  "bAutoWidth" : true,
  "bFilter": true,
  "bSort" : false,
  "columns":  [ 
         { "width": "232px" },
         { "width": "156px" }
      ],
  "lengthMenu": [[5, 10, 25, 50, -1], [5, 10, 25, 50, "All"]]
  //"aaSorting": [[ 1, "desc" ]]
};



//
// Charts
//
function restrictDashboardChartViews() {
  // allowDataRefresh param false to prevent any data refreshes from happening until done
  allowDataRefresh = false;
  
  var curMetric = METRICS.metrics[$("#metric_filter").val()];

  // Set the view to the first value in the list so that it is valid
  $("#dashboard_view_type").val(curMetric.view_as[0]);

  $(function() {
    $("#dashboard_view_type option").each(function(i){
      var indexOf = curMetric.view_as.indexOf($(this).val());
      if (indexOf >= 0) {
        enableDashboardChartView($(this).val());
      }
      else {
        disableDashboardChartView($(this).val());
      }
    });
  });

  $("#dashboard_view_type").multiselect('refresh');

  // re-enabling data refreshing
  allowDataRefresh = true;

}

function disableDashboardChartView(viewName) {
    $("#dashboard_view_type option[value=" + viewName + "]").attr('disabled','disabled');
}

function enableDashboardChartView(viewName) {
    $("#dashboard_view_type option[value=" + viewName + "]").removeAttr('disabled');
}

function updateDashboardCompaniesChartCallback(result) {
	updateChart("#dashboard_metric_chart_companies", 'pie', DASHBOARD_PIE_OPTIONS, result);
}
function updateDashboardModulesChartCallback(result) {
	updateChart("#dashboard_metric_chart_modules", 'pie', DASHBOARD_PIE_OPTIONS, result);
}
function updateDashboardEngineersChartCallback(result) {
	updateChart("#dashboard_metric_chart_engineers", 'pie', DASHBOARD_PIE_OPTIONS, result);
}

function parsePieToBar(data) {
  points = [];
  ticks = [];
  for (i = 0 ; i < data.length ; i++) {
     points.push(Array(data[i].data, i));  //Array(i, data[i].data));
     ticks.push(Array(data[i].label, i)); //Array(i, data[i].label));
  }

  data = [{
    data: points,
    minTickSize: 1,
    bars: { 
      show: true,
      horizontal: true, 
      align: "center" 
    }         
  }];
  ticks.forEach(function(arr) {arr.reverse()});
  //console.log(JSON.stringify(data))
  //console.log(JSON.stringify(ticks))
  options = {
    yaxis: {      
      ticks: ticks
    }
  };
  options.colors = CHART_COLORS;
  return {data: data, options: options};
}

DASHBOARD_PIE_OPTIONS = {
  series: {
    pie: {
      show: true,
      radius: 0.75,
      label: {
        show: true,
        radius: 1/2,
        formatter: function(label, series){
          return '<div style="font-size:10pt;text-align:center;padding:2px;color:white;">'+'<br/>'+Math.round(series.percent)+'%</div>';
        },
        threshold: 0.04
      }      
    }
  },
  legend: {
    labelBoxBorderColor: "none",
    backgroundOpacity: 0.5,
    noColumns: 1
  }
};
DASHBOARD_PIE_OPTIONS.colors = CHART_COLORS;

