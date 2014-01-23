REPORT_TABLE_OPTIONS = {
  "sScrollY": "350px",
  //"sScrollX": "800px",
  "bPaginate": false,
  "bAutoWidth" : true,
  "bFilter": true,
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