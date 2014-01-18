
//
// Data Table Functions
//

function makeAsDataTableOnLoad(tableHandleIdStr) {
  $(document).ready( function () {
    makeAsDataTable(tableHandleIdStr)
  } );
}

function makeAsDataTable(tableHandleIdStr) {
  $(tableHandleIdStr).dataTable({
    "sScrollY": "350px", "sScrollX": "800px",
    "bPaginate": true,
    "bSort": false,
    "bAutoWidth" : true,
    "bFilter": true
  } );
}