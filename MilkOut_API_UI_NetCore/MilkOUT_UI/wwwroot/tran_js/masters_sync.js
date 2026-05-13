function DownloadDealer() {
  var APIEndPoint = "GetDealerMaster";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };

  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      if ((res_output[0].result_id = 1)) {
        Show_Success_Toastr("Dealer Get Successfully");
      }

      GetSearchList();

      if (res_output.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }

      // extract values and create an html string to assign to html table
    },
    error: function () {
      // Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

function DownloadDealerRoute() {
  var APIEndPoint = "GetDownloadRoute";
  var url = "/Masters/MasterSync";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };

  Show_Loader();

  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/json",
    data: JSON.stringify(reqdata),
    success: function (result) {
      Hide_Loader();

      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      console.log(res_output);

      if (res_output.length > 0) {
        if ((res_output[0].result_id = 1)) {
          Show_Success_Toastr("Download Successfully");
        }
      }
    },
    error: function () {
      Hide_Loader();
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

function DownloadUOM() {
  var apiendpoint = "SaveMasterProductUOM";
  var Method_Name = "GetCode";
  var url = "/Masters/ProductUOM";

  //var Method_Name = "Get";
  //var apiendpoint = "GetOneDebitMemoRequest";
  //var url = "/DebitMemoRequest/GetDebitMemoRequest";
  Show_Loader();
  var reqdata = {
    method_name: Method_Name,
    xml_data: "n",
    api_end_point: apiendpoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      Hide_Loader();
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}

function DownloadProduct() {
  // Get data from database and show in table
  var APIEndPoint = "SaveSAPMasterProduct";
  var Method_Name = "Create";
  var url = "/Masters/Product";
  Show_Loader();
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    product_id: "",
    product_photo: "",
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      //   var result = JSON.parse(result);
      Hide_Loader();
      // if (result[0].result_id == 1) {
      //   Show_Success_Toastr("Product Get successfully");
      //   GetSearchList();
      // } else {
      //     Show_Error_Toastr("Error : " + result[0].result_description);
      // }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function DownloadPaymentTerm() {
  var APIEndPoint = "GetPaymentTerm";
  var url = "/Masters/MasterSync";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };

  //Show_Loader();

  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/json",
    data: JSON.stringify(reqdata),
    success: function (result) {
      Hide_Loader();

      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      console.log(res_output);

      if (res_output.length > 0) {
        if ((res_output[0].result_id = 1)) {
          Show_Success_Toastr("Download Successfully");
        }
      }
    },
    error: function () {
      Hide_Loader();
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}


function DownloadGetNotificationCode() {
  var APIEndPoint = "GetNotificationCode";
  var url = "/Masters/MasterSync";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };

  //Show_Loader();

  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/json",
    data: JSON.stringify(reqdata),
    success: function (result) {
      Hide_Loader();

      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      console.log(res_output);

      if (res_output.length > 0) {
        if ((res_output[0].result_id = 1)) {
          Show_Success_Toastr("Download Successfully");
        }
      }
    },
    error: function () {
      Hide_Loader();
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}


function DownloadDealerCrateLimit() {
  var APIEndPoint = "GetDealerCrateLimit";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };

  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      // debugger;
      console.log(result);
      
      var res = JSON.parse(result);
      console.log(res);
      // var res_output = JSON.parse(res);

      if ((res[0].result_id = 1)) {
        Show_Success_Toastr("Dealer Get Successfully");
      }

      GetSearchList();

      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }

      // extract values and create an html string to assign to html table
    },
    error: function () {
      // Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}