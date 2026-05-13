$(document).ready(function () {
  GetDashboard_Collection();
});

function GetDashboard_Collection() {
  var APIEndPoint = "GetAdminDashboard";
  var Method_Name = "Get_Collection";
  var url = "/Home/GetDashboard";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      if (res.length > 0) {
        $("#lblRMRDMorningTotal").html(
          parseFloat(res[0].collection_rmrdmorning).toFixed(0) + " Ltr"
        );
        $("#lblRMRDEveningTotal").html(
          parseFloat(res[0].collection_rmrdevening).toFixed(0) + " Ltr"
        );
        $("#lblBMCTotal").html(
          parseFloat(res[0].collection_bmc).toFixed(0) + " Ltr"
        );
        $("#lblCollectionTotal").html(
          parseFloat(res[0].collection_total).toFixed(0) + " Ltr"
        );

        var collection_rmrdmorning = res[0].collection_rmrdmorning;
        var collection_rmrdevening = res[0].collection_rmrdevening;
        var collection_bmc = res[0].collection_bmc;
        var collection_total = res[0].collection_total;

        var grn_rmrdmorning = res[0].grn_rmrdmorning;
        var grn_rmrdevening = res[0].grn_rmrdevening;
        var grn_bmc = res[0].grn_bmc;
        var grn_total = res[0].grn_total;

        var pending_rmrdmorning = parseFloat(
          collection_rmrdmorning - grn_rmrdmorning
        ).toFixed(0);
        var grnpercent_rmrdmorning = parseInt(
          (100 * grn_rmrdmorning) / collection_rmrdmorning
        );
        $("#lblGRNPendingRMRDMorning").html(pending_rmrdmorning);
        $("#pbarRMRDMorning").addClass("w-" + grnpercent_rmrdmorning);

        var pending_rmrdevening = parseFloat(
          collection_rmrdevening - grn_rmrdevening
        ).toFixed(0);
        var grnpercent_rmrdevening = parseInt(
          (100 * grn_rmrdevening) / collection_rmrdevening
        );
        $("#lblGRNPendingRMRDEvening").html(pending_rmrdevening);
        $("#pbarRMRDEvening").addClass("w-" + grnpercent_rmrdevening);

        var pending_bmc = parseFloat(collection_bmc - grn_bmc).toFixed(0);
        var grnpercent_bmc = parseInt((100 * grn_bmc) / collection_bmc);
        $("#lblGRNPendingBMC").html(pending_bmc);
        $("#pbarBMC").addClass("w-" + grnpercent_bmc);

        var pending_total = parseFloat(collection_total - grn_total).toFixed(0);
        var grnpercent_total = parseInt((100 * grn_total) / collection_total);
        $("#lblGRNPendingTotal").html(pending_total);
        $("#pbarTotal").addClass("w-" + grnpercent_total);
        // GetRateDashboard_Collection();
        GetRateDashboard_Collection_MCC();
        GetMCCBlockedDashboard_Collection();
        GetPaymentPending();
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function GetMCCBlockedDashboard_Collection() {
  ClearDataTable("tableSearchBlock");
  var APIEndPoint = "GetAdminDashboard";
  var Method_Name = "Blocked_MCC";
  var url = "/Home/GetDashboard";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var TableHTML = "";
      var Row_No = 0;
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.date + "</td>";
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mcctype_name + "</td>";
        TableHTML += "<td>" + value.mccworktype_name + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });

      $("#tableDataBlock").html(TableHTML);

      SetDataTable("tableSearchBlock", [6], "BlockedMCC");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SaveEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, you may update it",
    },
    function (result) {
      if (result == true) {
        Show_Loader();
        var APIEndPoint = "SaveRate";
        var Method_Name = "Update";
        var MCC_Id = $("#lblActionMCC_Id").html();
        var Date = $("#lblActionDate").html();

        var url = "/Home/GetDashboard";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          date: Date,
        };
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
              Hide_Loader();
              $("#modalEntry").modal("hide");
              Show_Success_Toastr("Rate Missing details saved successfully");
              GetRateDashboard_Collection_MCC();
            } else {
              Hide_Loader();
              $("#modalEntry").modal("hide");
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Hide_Loader();
            $("#modalEntry").modal("hide");
            Show_Error_Toastr("Error : Rate Missing details not saved");
          },
        });
      }
    }
  );
}

function GetRateDashboard_Collection_MCC() {
  var APIEndPoint = "GetAdminDashboard";
  var Method_Name = "Rate_Change_All";
  var url = "/Home/GetDashboard";
  $("#rateMismatch").html("");
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var DataHTML = "";
      var classList = ["primary", "info", "danger", "warning", "secondary"];

      if (res.length > 0) {
        $.each(res, function (index, value) {
          var randomClass =
            classList[Math.floor(Math.random() * classList.length)];
          DataHTML += `
            <div>
              <div class="list d-flex align-items-center mb-4">
                <div class="w-4 h-4 bg-${randomClass} mr-4"></div>
                <div class="wrapper w-90 ml-3">
                  <p class="mb-0"><b>${value.mcc_name}</b></p>
                  <div class="d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center">
                      <p class="mb-0">${value.date}</p>
                    </div> 
                    <a href="javascript:void(0)" class="ml-auto btn btn-outline-${randomClass} btn-sm" onclick="OpenMissingMCCList('${value.mcc_id}', '${value.created_on}');">view</a>
                  </div>
                </div>
              </div>
            </div>
          `;
        });
      } else {
        DataHTML = "<p></p>";
      }

      $("#rateMismatch").html(DataHTML);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}

function OpenMissingMCCList(mcc_id, created_on) {
  $("#lblActionMCC_Id").html("");
  $("#lblActionDate").html("");
  ClearDataTable("tableEntryModal");
  $("#modalEntry")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblActionMCC_Id").html(mcc_id);
  $("#lblActionDate").html(created_on);
  var APIEndPoint = "GetAdminDashboard";
  var Method_Name = "Rate_Change_MCC";
  var url = "/Home/GetDashboard";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: mcc_id,
    date: created_on,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var TableHTML = "";
      var Row_No = 0;
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";

        TableHTML += "<td>" + value.quantity_ltr + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td>" + value.old_rate + "</td>";
        TableHTML += "<td>" + value.old_amount + "</td>";
        TableHTML += "<td>" + value.new_rate + "</td>";
        TableHTML += "<td>" + value.new_amount + "</td>";
        TableHTML += "<td>" + value.diff_amount + "</td>";

        TableHTML += "<td>" + value.collectionshift_name + "</td>";

        TableHTML += "<td hidden>" + value.collection_id + "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntryModalData").html(TableHTML);

      SetDataTable("tableEntryModal", [10], "RateChange");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function GetPaymentPending() {
  var APIEndPoint = "GetAdminDashboard";
  var Method_Name = "Payment_Pending";
  var url = "/Home/GetDashboard";
  $("#paymentPending").html("");
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var DataHTML = "";
      var classList = ["primary", "info", "danger", "warning", "secondary"];

      if (res.length > 0) {
        $.each(res, function (index, value) {
          var randomClass =
            classList[Math.floor(Math.random() * classList.length)];
          DataHTML += `
            <div>
              <div class="list d-flex align-items-center mb-4">
                <div class="w-4 h-4 bg-${randomClass} mr-4"></div>
                <div class="wrapper w-90 ml-3">
                  <p class="mb-0">User Type : <b>${value.user_type}</b></p>
                  <p class="mb-0"><b>${value.name}</b></p>
                  <div class="d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center">
                      <p class="mb-0">${value.date}</p>
                    </div> 
                    <a href="javascript:void(0)" class="ml-auto btn btn-outline-${randomClass} btn-sm" onclick="OpenPaymentPendingList('${value.id}', '${value.created_on}', '${value.user_type}');">view</a>
                  </div>
                </div>
              </div>
            </div>
          `;
        });
      } else {
        DataHTML = "<p></p>";
      }

      $("#paymentPending").html(DataHTML);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}

function OpenPaymentPendingList(mcc_id, created_on, user_type) {
  // console.log(mcc_id, created_on, user_type);
  // $("#lblActionMCC_Id").html("");
  $("#ViewPending").html("");
  ClearDataTable("tableEntryModalPending");
  $("#modalEntryPending")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#ViewPending").html(user_type + " Payment");
  // $("#lblActionDate").html(created_on);
  var APIEndPoint = "GetAdminDashboard";
  var Method_Name = "GetPaymentPending";
  var url = "/Home/GetDashboard";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: mcc_id,
    date: created_on,
    user_type: user_type,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var TableHTML = "";
      var Row_No = 0;
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.date + "</td>";
        TableHTML += "<td>" + value.code + "</td>";
        TableHTML += "<td>" + value.name + "</td>";
        TableHTML += "<td>" + value.mustercycle + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryModalDataPending").html(TableHTML);
      SetDataTable("tableEntryModalPending", [6], "PaymentPending");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}
