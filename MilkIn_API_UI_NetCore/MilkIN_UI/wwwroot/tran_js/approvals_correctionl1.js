$(document).ready(function () {
  $("#ddlSearchApprovalStatus").select2();
  GetMaster(
    "ddlSearchApprovalStatus",
    "Select Approval Status",
    "GetApprovedStatus",
    0,
    ""
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
          picker.endDate.format("MM/DD/YYYY")
      );
    }
  );

  $('input[name="datefilter"]').on(
    "cancel.daterangepicker",
    function (ev, picker) {
      $(this).val("");
    }
  );
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var APIEndPoint = "GetCorrectionL1";
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

  var Method_Name = "GetL1";
  var url = "/Approvals/CorrectionL1";
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
        if (value.is_approved_l1 == 1) {
          ApprovalStatus = "Approved";
        } else if (value.is_approved_l1 == 0) {
          ApprovalStatus = "Pending";
        } else {
          ApprovalStatus = "Rejected";
        }
        EditFlag = value.is_approved_l1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.created_on + "</td>";
        TableHTML += "<td>" + value.agent_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + ApprovalStatus + "</td>";

        TableHTML += "<td>" + value.approved_on_l1 + "</td>";

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
      SetDataTable("tableSearch", [9], "Correction Requests");
      $("#btn_Search").prop("disabled", false);
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function ShowApproveEntry(Correction_Request_Id) {
  ShowContentDiv("Approvals", "CorrectionL1Edit", "", function () {
    // Initialization Code

    $("#lblEntryId").html(Correction_Request_Id);
    $("#lblAction").html("Edit");

    $("#ddlEntryApprovalStatus").select2();
    $("#btn_Save").hide();

    $("#ddlEntryApprovalStatus").on("change", function () {
      var selectedValue = $(this).val();
      var selectedWord = $(this).children("option:selected").text();

      if (selectedValue != "") {
        if (!(selectedValue == 1)) {
          swal({
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "question",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, " + selectedWord + " it!",
          });
        }
        if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
          $("#btn_Save").show();
        } else {
          $("#btn_Save").hide();
        }
      }
    });

    var APIEndPoint = "GetCorrectionL1";
    var url = "/Approvals/CorrectionL1";
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
          res[0].is_approved_l1,
          ""
        );
        Agent_Id = res[0].agent_id;
        // Other Details
        $("#txtEntryRequestDate").val(res[0].created_on);
        $("#txtEntryAgentName").val(res[0].agent_name);
        $("#txtEntryAgentMobileNo").val(res[0].mobile_no);
        $("#txtEntryMCCName").val(res[0].mcc_name);
        $("#txtEntryFarmerName").val(res[0].farmer_name);

        // Requested Details
        $("#txtEntryRequestedMilkQuantity").val(res[0].request_quantity_ltr);
        $("#txtEntryRequestedSNF").val(res[0].request_snf);
        $("#txtEntryRequestedFAT").val(res[0].request_fat);
        $("#txtEntryRemarks").val(res[0].request_remark);

        // Recorded Details
        $("#txtEntryRecordedMilkQuantity").val(res[0].current_quantity_ltr);
        $("#txtEntryRecordedSNF").val(res[0].current_snf);
        $("#txtEntryRecordedFAT").val(res[0].current_fat);
        $("#txtEntryCollectionShift").val(res[0].collectionshift_name);
      },
      error: function () {
        Show_Error_Toastr("Error : Correction Request details not found");
      },
    });
  });
}

function ViewApproveEntry(Correction_Request_Id) {
  ShowContentDiv("Approvals", "CorrectionL1Edit", "", function () {
    // Initialization Code

    $("#lblEntryId").html(Correction_Request_Id);
    $("#lblAction").html("Edit");

    $("#ddlEntryApprovalStatus").select2();
    $("#btn_Save").hide();

    $("#ddlEntryApprovalStatus").on("change", function () {
      var selectedValue = $(this).val();
      var selectedWord = $(this).children("option:selected").text();

      if (selectedValue != "") {
        if (!(selectedValue == 1)) {
          swal({
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "question",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, " + selectedWord + " it!",
          });
        }
        if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
          $("#btn_Save").show();
        } else {
          $("#btn_Save").hide();
        }
      }
    });

    var APIEndPoint = "GetCorrectionL1";
    var url = "/Approvals/CorrectionL1";
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
        $("#ddlEntryApprovalStatus").prop("disabled", true);
        GetMaster(
          "ddlEntryApprovalStatus",
          "Select Approval Status",
          "GetApprovedStatus",
          res[0].is_approved_l1,
          ""
        );
        Agent_Id = res[0].agent_id;
        // Other Details
        $("#txtEntryRequestDate").val(res[0].created_on);
        $("#txtEntryRemark").prop("disabled", true);
        $("#txtEntryRemark").val(res[0].approved_remark_l1);
        $("#txtEntryAgentName").val(res[0].agent_name);
        $("#txtEntryAgentMobileNo").val(res[0].mobile_no);
        $("#txtEntryMCCName").val(res[0].mcc_name);
        $("#txtEntryFarmerName").val(res[0].farmer_name);

        // Requested Details
        $("#txtEntryRequestedMilkQuantity").val(res[0].request_quantity_ltr);
        $("#txtEntryRequestedSNF").val(res[0].request_snf);
        $("#txtEntryRequestedFAT").val(res[0].request_fat);
        $("#txtEntryRemarks").val(res[0].request_remark);

        // Recorded Details
        $("#txtEntryRecordedMilkQuantity").val(res[0].current_quantity_ltr);
        $("#txtEntryRecordedSNF").val(res[0].current_snf);
        $("#txtEntryRecordedFAT").val(res[0].current_fat);
        $("#txtEntryCollectionShift").val(res[0].collectionshift_name);
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

function SaveEntry() {
  // Validation code
  var ApprovalStatus_Id = $("#ddlEntryApprovalStatus").val();
  var ApprovedRemarks = $("#txtEntryRemark").val();

  var IsValid = 1;

  if (ApprovalStatus_Id == "") {
    IsValid = 0;
    $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
  }
  if (ApprovedRemarks == "") {
    IsValid = 0;
    $("#txtEntryRemark").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveCorrectionL1";
    var Method_Name = "Update_L1";
    var Correction_Request_Id = $("#lblEntryId").html();
    var Action_Name = $("#lblAction").html();
    var url = "/Approvals/CorrectionL1";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      approved_remarks: ApprovedRemarks,
      agent_id: Agent_Id,
      correction_request_id: Correction_Request_Id,
      approvalstatus_id: ApprovalStatus_Id,
    };

    //Save
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          // Show Success Message
          $("#btn_Save").prop("disabled", false);
          Show_Success_Toastr(
            "Correction Request " + result[0].result_description
          );
          CloseEntry();
        } else {
          Show_Success_Toastr("Error: " + result[0].result_description);
        }
      },
      error: function () {
        ShowEntryError("Error : Correction Request details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}
