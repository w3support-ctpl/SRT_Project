$(document).ready(function () {
  $("#ddlSearchApprovalStatus").select2();
  GetMaster(
    "ddlSearchApprovalStatus",
    "Select Approval Status",
    "GetApprovedStatus",
    0,
    "",
  );
  //SetDataTable("tableSearch", [6], "Correction Request");

  $('input[name="datefilter"]').daterangepicker({
    locale: {
      cancelLabel: "Clear",
    },
    startDate: moment().subtract(30, "days"), // Set the startDate to 30 days ago
    endDate: moment(), // Set the endDate to the current date
    ranges: {
      Today: [moment(), moment()],
      Yesterday: [moment().subtract(1, "days"), moment().subtract(1, "days")],
      "Last 7 Days": [moment().subtract(6, "days"), moment()],
      "Last 30 Days": [moment().subtract(29, "days"), moment()],
      "This Month": [moment().startOf("month"), moment().endOf("month")],
      "Last Month": [
        moment().subtract(1, "month").startOf("month"),
        moment().subtract(1, "month").endOf("month"),
      ],
    },
  });

  $('input[name="datefilter"]').on(
    "apply.daterangepicker",
    function (ev, picker) {
      $(this).val(
        picker.startDate.format("MM/DD/YYYY") +
          " - " +
          picker.endDate.format("MM/DD/YYYY"),
      );
    },
  );

  $('input[name="datefilter"]').on(
    "cancel.daterangepicker",
    function (ev, picker) {
      $(this).val("");
    },
  );
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var APIEndPoint = "GetCorrectionL2";
  var RequestPeriod = $("#txtSearchRequestPeriod").val();
  var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

  if (
    ApprovalStatus_Id == "" ||
    ApprovalStatus_Id == null ||
    ApprovalStatus_Id == undefined
  ) {
    ApprovalStatus_Id = 0;
  }

  $("#btn_Search").prop("disabled", true);

  var Method_Name = "GetL2";
  var url = "/Approvals/CorrectionL2";
  var reqdata = {
    method_name: Method_Name,
    date: RequestPeriod,
    approvalstatus_id: ApprovalStatus_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // show message if there is no data to show
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }

      // Fill data in table
      var TableHTML = "";

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      $.each(res, function (data, value) {
        var ApprovalStatus = "";
        if (value.is_approved_l2 == 1) {
          ApprovalStatus = "Approved";
        } else if (value.is_approved_l2 == 0) {
          ApprovalStatus = "Pending";
        } else {
          ApprovalStatus = "Rejected";
        }
        EditFlag = value.is_approved_l2;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.created_on + "</td>";
        TableHTML += "<td>" + value.agent_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + ApprovalStatus + "</td>";
        TableHTML += "<td>" + value.approved_on_l2;
        +"</td>";
        TableHTML +=
          '<td class="text-right" style="width: 80px; padding: 8px 5px 8px 5px;">';
        // for Pending Requests
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Open" onclick="ShowApproveEntry(\'' +
            value.correction_request_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Open" onclick="ViewApproveEntry(\'' +
            value.correction_request_id +
            "');\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [8], "Correction Requests");
      $("#btn_Search").prop("disabled", false);
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description,
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function ShowApproveEntry(Correction_Request_Id) {
  ShowContentDiv("Approvals", "CorrectionL2Edit", "", function () {
    $("#btnSave").show();
    // Initialization Code

    $("#lblEntryId").html(Correction_Request_Id);
    $("#lblAction").html("Edit");

    $("#ddlEntryApprovalStatus").select2();
    $("#btn_Save").hide();

    $("#ddlEntryApprovalStatus").on("change", function () {
      var selectedValue = $(this).val();
      var selectedWord = $(this).children("option:selected").text();

      if (selectedValue != "") {
        // if (!(selectedValue == 1)) {
        //   swal({
        //     title: "Are you sure?",
        //     text: "You won't be able to revert this!",
        //     icon: "question",
        //     type: "warning",
        //     showCancelButton: true,
        //     confirmButtonText: "Yes, " + selectedWord + " it!",
        //   });
        // }
        if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
          $("#btn_Save").show();
        } else {
          $("#btn_Save").hide();
        }
      }
    });

    var APIEndPoint = "GetCorrectionL2";
    var url = "/Approvals/CorrectionL2";
    var reqdata = {
      correction_request_id: Correction_Request_Id,
      method_name: "Get_One",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        GetMaster(
          "ddlEntryApprovalStatus",
          "Select Approval Status",
          "GetApprovedStatus",
          res[0].is_approved_l2,
          "",
        );
        Agent_Id = res[0].agent_id;
        // Other Details
        $("#txtEntryRequestDate").val(res[0].created_on);
        $("#txtEntryAgentName").val(res[0].agent_name);
        $("#txtEntryAgentMobileNo").val(res[0].mobile_no);
        $("#txtEntryMCCName").val(res[0].mcc_name);

        // Requested Details
        $("#txtEntryRequestedMilkQuantity").val(res[0].request_quantity_ltr);
        $("#txtEntryRequestedSNF").val(res[0].request_snf);
        $("#txtEntryRequestedFAT").val(res[0].request_fat);
        $("#txtEntryRemarks").val(res[0].request_remark);

        // Recorded Details
        $("#txtEntryRecordedMilkQuantity").val(res[0].current_quantity_ltr);
        $("#txtEntryRecordedSNF").val(res[0].current_snf);
        $("#txtEntryRecordedFAT").val(res[0].current_fat);
        $("#txtEntryFarmerName").val(res[0].farmer_name);
        $("#txtEntryCollectionShift").val(res[0].collectionshift_name);
      },
      error: function () {
        Show_Error_Toastr("Error : Correction Request details not found");
      },
    });
  });
}

function ViewApproveEntry(Correction_Request_Id) {
  ShowContentDiv("Approvals", "CorrectionL2Edit", "", function () {
    $("#btnSave").hide();
    // Initialization Code

    $("#lblEntryId").html(Correction_Request_Id);
    $("#lblAction").html("Edit");

    $("#ddlEntryApprovalStatus").select2();
    $("#btn_Save").hide();

    $("#ddlEntryApprovalStatus").on("change", function () {
      var selectedValue = $(this).val();
      var selectedWord = $(this).children("option:selected").text();

      if (selectedValue != "") {
        // if (!(selectedValue == 1)) {
        //   swal({
        //     title: "Are you sure?",
        //     text: "You won't be able to revert this!",
        //     icon: "question",
        //     type: "warning",
        //     showCancelButton: true,
        //     confirmButtonText: "Yes, " + selectedWord + " it!",
        //   });
        // }
        if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
          $("#btn_Save").show();
        } else {
          $("#btn_Save").hide();
        }
      }
    });

    var APIEndPoint = "GetCorrectionL2";
    var url = "/Approvals/CorrectionL2";
    var reqdata = {
      correction_request_id: Correction_Request_Id,
      method_name: "Get_One",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        GetMaster(
          "ddlEntryApprovalStatus",
          "Select Approval Status",
          "GetApprovedStatus",
          res[0].is_approved_l2,
          "",
        );
        $("#ddlEntryApprovalStatus").prop("disabled", true);
        Agent_Id = res[0].agent_id;
        // Other Details
        $("#txtEntryRequestDate").val(res[0].created_on);
        $("#txtEntryRemark").val(res[0].approved_remark_l2);
        $("#txtEntryRemarksApproveReject1").val(res[0].approved_remark_l1);
        $("#txtEntryRemark").prop("disabled", true);
        $("#txtEntryAgentName").val(res[0].agent_name);
        $("#txtEntryAgentMobileNo").val(res[0].mobile_no);
        $("#txtEntryMCCName").val(res[0].mcc_name);

        // Requested Details
        $("#txtEntryRequestedMilkQuantity").val(res[0].request_quantity_ltr);
        $("#txtEntryRequestedSNF").val(res[0].request_snf);
        $("#txtEntryRequestedFAT").val(res[0].request_fat);
        $("#txtEntryRemarks").val(res[0].request_remark);

        // Recorded Details
        $("#txtEntryRecordedMilkQuantity").val(res[0].current_quantity_ltr);
        $("#txtEntryRecordedSNF").val(res[0].current_snf);
        $("#txtEntryRecordedFAT").val(res[0].current_fat);
        $("#txtEntryFarmerName").val(res[0].farmer_name);
        $("#txtEntryCollectionShift").val(res[0].collectionshift_name);

        $("#txtEntryApprovedMilkQuantity").val(res[0].approved_quantity_ltr);
        $("#txtEntryApprovedFAT").val(res[0].approved_fat);
        $("#txtEntryApprovedSNF").val(res[0].approved_snf);

        $("#txtEntryApprovedMilkQuantity").prop("disabled", true);
        $("#txtEntryApprovedFAT").prop("disabled", true);
        $("#txtEntryApprovedSNF").prop("disabled", true);
      },
      error: function () {
        Show_Error_Toastr("Error : Correction Request details not found");
      },
    });
  });
}
function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

// function SaveEntry() {
//   // Validation code
//   var ApprovalStatus_Id = $("#ddlEntryApprovalStatus").val();
//   var ApprovedRemarks = $("#txtEntryRemark").val();

//   var ApprovalQuantity = $("#txtEntryApprovedMilkQuantity").val();
//   var ApprovedSNF = $("#txtEntryApprovedSNF").val();
//   var ApprovedFAT = $("#txtEntryApprovedFAT").val();

//   var IsValid = 1;
// // debugger;
//   if (ApprovalStatus_Id == "") {
//     IsValid = 0;
//     $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
//   }
//   if (ApprovedRemarks == "") {
//     IsValid = 0;
//     $("#txtEntryRemark").addClass("is-invalid state-invalid");
//   }
//   if (ApprovalStatus_Id == "1") {
//     if (
//       isNaN(ApprovalQuantity) ||
//       ApprovalQuantity == null ||
//       ApprovalQuantity == undefined ||
//       ApprovalQuantity == ""
//     ) {
//       IsValid = 0;
//       $("#txtEntryApprovedMilkQuantity").addClass("is-invalid state-invalid");
//     }
//     if (
//         isNaN(ApprovedSNF) ||
//         ApprovedSNF == null ||
//         ApprovedSNF == undefined ||
//         ApprovedSNF == ""
//       ) {
//         IsValid = 0;
//         $("#txtEntryApprovedSNF").addClass("is-invalid state-invalid");
//       }
//       if (
//         isNaN(ApprovedFAT) ||
//         ApprovedFAT == null ||
//         ApprovedFAT == undefined ||
//         ApprovedFAT == ""
//       ) {
//         IsValid = 0;
//         $("#txtEntryApprovedFAT").addClass("is-invalid state-invalid");
//       }
//   }
//   if (IsValid == 0) {
//     ShowEntryError("Invalid Input(s). Can't be saved.");
//     return;
//   } else {
//     // Start Saving
//     $("#btn_Save").prop("disabled", true);
//     var APIEndPoint = "SaveCorrectionL2";
//     var Method_Name = "Update_L2";
//     var Correction_Request_Id = $("#lblEntryId").html();
//     var Action_Name = $("#lblAction").html();
//     var url = "/Approvals/CorrectionL2";
//     var reqdata = {
//       method_name: Method_Name,
//       api_end_point: APIEndPoint,
//       approved_remarks: ApprovedRemarks,
//       agent_id: Agent_Id,
//       correction_request_id: Correction_Request_Id,
//       approvalstatus_id: ApprovalStatus_Id,

//       approved_quantity_ltr: ApprovalQuantity,
//       approved_fat: ApprovedFAT,
//       approved_snf: ApprovedSNF,
//     };

//     //Save
//     $.ajax({
//       type: "POST",
//       url: url,
//       contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//       data: reqdata,
//       success: function (res) {
//         var result = JSON.parse(res);
//         if (result[0].result_id == 1) {
//           // Show Success Message
//           $("#btn_Save").prop("disabled", false);
//           Show_Success_Toastr(
//             "Correction Request " + result[0].result_description
//           );
//           CloseEntry();
//         } else {
//           Show_Success_Toastr("Error: " + result[0].result_description);
//         }
//       },
//       error: function () {
//         ShowEntryError("Error : Correction Request details not saved");
//         $("#btn_Save").prop("disabled", false);
//       },
//     });
//   }
//   return;
// }

function SaveEntry() {
  var APIEndPoint_2 = "GetCorrectionL2";
  var Method_Name_2 = "Lock";
  var url_2 = "/Approvals/CorrectionL2";
  var Correction_Request_Id_2 = $("#lblEntryId").html();

  var reqdata_2 = {
    method_name: Method_Name_2,
    api_end_point: APIEndPoint_2,
    correction_request_id: Correction_Request_Id_2,
  };

  $.ajax({
    type: "POST",
    url: url_2,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata_2,
    success: function (result) {
      var res = JSON.parse(result);

      var flags = res[0].is_locked;

      if (flags == "1") {
        var errorMsg =
          "Payment processing already completed for this period.  This correction request can't be approved.";
        ShowEntryError(errorMsg);

        return;
      } else {
        swal(
          {
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "question",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, generate it!",
          },
          function (result) {
            if (result == true) {
              // Stop the function
              var ApprovalStatus_Id = $("#ddlEntryApprovalStatus").val();
              var ApprovedRemarks = $("#txtEntryRemark").val();

              var ApprovalQuantity = $("#txtEntryApprovedMilkQuantity").val();
              var ApprovedSNF = $("#txtEntryApprovedSNF").val();
              var ApprovedFAT = $("#txtEntryApprovedFAT").val();

              var IsValid = 1;
              // debugger;
              if (ApprovalStatus_Id == "") {
                IsValid = 0;
                $("#ddlEntryApprovalStatus").addClass(
                  "is-invalid state-invalid",
                );
              }
              if (ApprovedRemarks == "") {
                IsValid = 0;
                $("#txtEntryRemark").addClass("is-invalid state-invalid");
              }
              if (ApprovalStatus_Id == "1") {
                if (
                  isNaN(ApprovalQuantity) ||
                  ApprovalQuantity == null ||
                  ApprovalQuantity == undefined ||
                  ApprovalQuantity == ""
                ) {
                  IsValid = 0;
                  $("#txtEntryApprovedMilkQuantity").addClass(
                    "is-invalid state-invalid",
                  );
                }
                if (
                  isNaN(ApprovedSNF) ||
                  ApprovedSNF == null ||
                  ApprovedSNF == undefined ||
                  ApprovedSNF == ""
                ) {
                  IsValid = 0;
                  $("#txtEntryApprovedSNF").addClass(
                    "is-invalid state-invalid",
                  );
                }
                if (
                  isNaN(ApprovedFAT) ||
                  ApprovedFAT == null ||
                  ApprovedFAT == undefined ||
                  ApprovedFAT == ""
                ) {
                  IsValid = 0;
                  $("#txtEntryApprovedFAT").addClass(
                    "is-invalid state-invalid",
                  );
                }
              }
              if (IsValid == 0) {
                ShowEntryError("Invalid Input(s). Can't be saved.");
                return;
              } else {
                // Start Saving
                $("#btn_Save").prop("disabled", true);
                var APIEndPoint = "SaveCorrectionL2";
                var Method_Name = "Update_L2";
                var Correction_Request_Id = $("#lblEntryId").html();
                var Action_Name = $("#lblAction").html();
                var url = "/Approvals/CorrectionL2";
                var reqdata = {
                  method_name: Method_Name,
                  api_end_point: APIEndPoint,
                  approved_remarks: ApprovedRemarks,
                  agent_id: Agent_Id,
                  correction_request_id: Correction_Request_Id,
                  approvalstatus_id: ApprovalStatus_Id,

                  approved_quantity_ltr: ApprovalQuantity,
                  approved_fat: ApprovedFAT,
                  approved_snf: ApprovedSNF,
                };

                //Save
                $.ajax({
                  type: "POST",
                  url: url,
                  contentType:
                    "application/x-www-form-urlencoded; charset=UTF-8",
                  data: reqdata,
                  success: function (res) {
                    var result = JSON.parse(res);
                    // if (result[0].result_id == 1) {
                    //   // Show Success Message
                    //   $("#btn_Save").prop("disabled", false);
                    //   Show_Success_Toastr(
                    //     "Correction Request " + result[0].result_description
                    //   );
                    //   CloseEntry();
                    // } else {
                    //   Show_Success_Toastr(
                    //     "Error: " + result[0].result_description
                    //   );
                    // }

                    if (result[0].result_id == -1 || result[0].result_id == 0) {
                      Show_Success_Toastr(
                        "Error: " + result[0].result_description,
                      );
                    } else if (result[0].result_id == 1) {
                      // Show Success Message
                      $("#btn_Save").prop("disabled", false);
                      Show_Success_Toastr(
                        "Correction Request " + result[0].result_description,
                      );
                      CloseEntry();
                    } else {
                      // Show Success Message
                      $("#btn_Save").prop("disabled", false);
                      Show_Success_Toastr("Correction Request Approved");
                      CloseEntry();
                    }
                  },
                  error: function () {
                    ShowEntryError(
                      "Error : Correction Request details not saved",
                    );
                    $("#btn_Save").prop("disabled", false);
                  },
                });
              }
            }
          },
        );
      }
    },
    error: function () {
      ShowEntryError("Error occurred during validation.");
    },
  });
}
