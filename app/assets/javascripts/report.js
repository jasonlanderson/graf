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