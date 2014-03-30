REPORT_TABLE_OPTIONS = {
  "sScrollY": "350px",
  //"sScrollX": "800px",
  "bPaginate": false,
  "bAutoWidth" : true,
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
    url: "report_data",
    data: data,
    method: 'POST',
    dataType: responseType,
    success: callback
  });
}

function setupReportReady() {
  // Load local values 
  loadLocalStorage();
  
  // Run the filter update on load to get the data      
  filterUpdateReport();

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

function guardedFilterUpdateReport() {
  if(autoUpdateOnFilterChange) {
    filterUpdateReport();
  }
}

function filterUpdateReport() {
  values = createSearchCriteriaJSON()
  localStorage.setItem('vals', JSON.stringify(values));

  data = {
    report: 'prs',
    searchCriteria: values
    // Add summary
  }

  // Make API calls to update the data
  reportAJAX(data, 'text', updateReportTableCallback);

  data = {
    report: 'summary',
    searchCriteria: values
    // TODO?: Add summary
  }

  // Make API calls to update the data
  reportAJAX(data, 'text', updateSummaryTableCallback);
}

function updateReportTableCallback(result){
  $("#table_container").empty();
  $("#table_container").html(result);
  $("#report_table").dataTable(REPORT_TABLE_OPTIONS);
}

function updateSummaryTableCallback(result){
  $("#table_summary_container").empty();
  $("#table_summary_container").html(result);
  $("#summary_report_table").dataTable(MIN_TABLE_OPTIONS);
  
  // Couldn't get working with regular tables, uncomment below to see example 
  //$("#summary_report_table").empty();
  //$("#summary_report_table").html(result);
}