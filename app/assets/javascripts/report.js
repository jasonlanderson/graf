REPORT_TABLE_OPTIONS = {
  "sScrollY": "550px",
  "sScrollX": "960",
  "bPaginate": false,
  "bAutoWidth" : false,
  "bFilter": true,
  //"aaSorting": [[ 1, "desc" ]]
};

MIN_TABLE_OPTIONS = {
  "sScrollY": "50px",
  "sScrollX": "350px",
  "bPaginate": false,
  "bAutoWidth" : false,
  "bFilter": false,
  "bInfo": false,
  //"aaSorting": [[ 1, "desc" ]]
};

function reportAJAX(data, responseType, callback){
  $.ajax({
    beforeSend: function() {
      $('#loader').show();
      $('#table_summary_container').hide();
      $('#table_container').hide();
    },
    url: "report_data",
    data: data,
    method: 'POST',
    dataType: responseType,
    complete: function(){
      $('#loader').hide();
      $('#table_summary_container').show();
      $('#table_container').show();
    },
    success: callback
  });
}

function setupReportReady() {
  // Load local values 
  loadFiltersFromLocalStorage();
  
  // Run the filter update on load to get the data      
  refreshReportData();

  // Setup the CSV download button
  $("#download").click(function () {
    data = {
      report: 'prs',
      file: 'csv',
      searchCriteria: createSearchCriteriaJSON()
    }
    reportAJAX(data, 'text', downloadCSV);
  });
}

function refreshReportData() {
  if (!allowDataRefresh) {
    return;
  }

  data = {
    report: 'prs',
    searchCriteria: createSearchCriteriaJSON()
  }

  // TODO: When adding future metrics, will need to add in the
  // restrict search criteria

  // Make API calls to update the data
  reportAJAX(data, 'text', updateReportTableCallback);

  data = {
    report: 'summary',
    searchCriteria: createSearchCriteriaJSON()
  }

  // Make API calls to update the data
  reportAJAX(data, 'text', updateSummaryTableCallback);
}

function reportFilterChanged() {
  storeFiltersToLocalStorage();

  refreshReportData();
}

function updateReportTableCallback(result){
  $("#table_container").empty();
  $("#table_container").html(result);
  var dt = $("#report_table").dataTable(REPORT_TABLE_OPTIONS);
  dt.fnAdjustColumnSizing();
}

function updateSummaryTableCallback(result){
  $("#table_summary_container").empty();
  $("#table_summary_container").html(result);
  $("#summary_report_table").dataTable(MIN_TABLE_OPTIONS);
  
  // Couldn't get working with regular tables, uncomment below to see example 
  //$("#summary_report_table").empty();
  //$("#summary_report_table").html(result);
}