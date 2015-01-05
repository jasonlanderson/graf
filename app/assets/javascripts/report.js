REPORT_TABLE_OPTIONS = {
  "sScrollY": "100%",
  "sScrollX": "960px",
  "bPaginate": true,
  "bAutoWidth": true,
  "bFilter": true,
  "bSort" : true,
  "columns":  [ 
               { "width":  "48px" },
               { "width":  "76px" },
               { "width": "288px" },
               { "width":  "96px" },
               { "width":  "67px" },
               { "width":  "67px" },
               { "width":  "67px" },
               { "width":  "76px" },
               { "width":  "76px" },
               { "width":  "76px" }
            ],
  //"aaSorting": [[ 0, "asc" ]]
};

MIN_TABLE_OPTIONS = {
  "sScrollY": "100%",
  "sScrollX": "310px",
  "bPaginate": false,
  "bAutoWidth": true,
  "bFilter": false,
  "bSort" : false,
  "columns":  [ 
               { "width": "20%" },
               { "width": "25%" },
               { "width": "25%" },
               { "width": "30%" }
      ],
  "showNEntries" : false,
  "bInfo" : false
  //"aaSorting": [[ 1, "desc" ]]
};

function reportAJAX(data, responseType, callback){
  $.ajax({
    beforeSend: function() {
      $('#report_table_summery_loader').show();
      $('#report_table_loader').show();
      $('#report_table_summary_container').hide();
      $('#report_table_container').hide();
    },
    url: "report_data",
    data: data,
    method: 'POST',
    dataType: responseType,
    complete: function(){
      $('#report_table_summery_loader').hide();
      $('#report_table_summary_container').show();
      $('#report_table_container').show();
    },
    success: callback
  });
}

function setupReportReady() {

  setSelectedPageButtonStyle(2);
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
  $('#report_table_loader').hide();
  $("#report_table_container").empty();
  $("#report_table_container").html(result);
  $("#report_table").dataTable(REPORT_TABLE_OPTIONS);
}

function updateSummaryTableCallback(result){
  $("#report_table_summary_container").empty();
  $("#report_table_summary_container").html(result);
  $("#summary_report_table").dataTable(MIN_TABLE_OPTIONS);
}