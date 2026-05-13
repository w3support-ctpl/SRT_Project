$(document).ready(function () {
  $("#ddlSearchApprovalStatus").select2();

  GetMaster(
    "ddlSearchApprovalStatus",
    "Select Approval Status",
    "GetApprovedStatus",
    0,
    ""
  );

  //SetDataTable("tableSearch", [6], "FarmerDataCorrection");

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

  // Get data from database and show in table
  $("#tableData").empty();

  var url = "/Approvals/DataCorrection";

  var APIEndPoint = "GetDataCorrection";
  var Method_Name = "Get";
  var Request_Date = $("#txtSearchRequestPeriod").val();
  var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

  var Status_Id = ApprovalStatus_Id;

  /*if (ApprovalStatus_Id == "") {
        Status_Id = "0,1,-1";
    } else {
        Status_Id = ApprovalStatus_Id;
    }*/

  var reqdata = {
    method_name: Method_Name,
    request_date: Request_Date,
    approvalstatus_id: Status_Id,
    api_end_point: APIEndPoint,
    request_for: "Farmer",
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result); //.responseData);

      // Fill data in table
      var TableHTML = "";
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Approved_Status;
        EditFlag = false;
        if (value.is_approved == 1) {
          Approved_Status = "Approved";
        } else if (value.is_approved == 0) {
          Approved_Status = "Pending";
          EditFlag = true;
        } else {
          Approved_Status = "Rejected";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.request_date + "</td>";
        TableHTML += "<td>" + value.request_type + "</td>";
        TableHTML += "<td>" + value.request_for_user_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td>" + Approved_Status + "</td>";

        if (EditFlag == true) {
          TableHTML +=
            "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowApproveEntry(\'Edit\',\'' +
            value.request_id +
            "', '" +
            value.request_type +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
          TableHTML += "</td>";
        } else {
          TableHTML +=
            "<td class='text-right' style='width: 100px; padding:8px 5px 8px 5px;'>";
          TableHTML += "" + value.approved_on + "";
          // View
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowApproveEntry(\'View\',\'' +
            value.request_id +
            "', '" +
            value.request_type +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';

          TableHTML += "</td>";
        }

        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [7], "Farmer Data Correction");
      /*$("#btn_Search").prop('disabled', false);*/
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      /*$("#btn_Search").prop('disabled', false);*/
    },
  });
}

function ShowApproveEntry(Action, Request_Id, _RequestType) {
  ShowContentDiv("Approvals", "FarmerDataCorrectionEdit", "", function () {
    // Initialization Code
    RequestType = _RequestType;

    $("#btn_Save").hide();
    $("#ddlEntryApprovalStatus").select2();

    $("#ddlEntryMCCName").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();
    $("#ddlEntryNomineeRelation").select2();

    $("#ddlNewEntryMCCName").select2();
    $("#ddlNewEntryBankName").select2();
    $("#ddlNewEntryBranchName").select2();
    $("#ddlNewEntryNomineeRelation").select2();

    $("#lblEntryId").html(Request_Id);
    $("#lblAction").html("Edit");

    GetMaster("ddlNewEntryBankName", "Select Bank", "GetBank", "", "");
    GetMaster("ddlNewEntryBranchName", "Select Branch", "GetBranch", "", "");
    GetMaster(
      "ddlNewEntryNomineeRelation",
      "Select Nominee Relation",
      "GetNomineeRelation",
      "",
      ""
    );

    if (Action == "View") {
      $("#ddlEntryApprovalStatus").prop("disabled", true);
      $("#txtEntryRemark").prop("disabled", true);

      $("#ddlNewEntryMCCName").prop("disabled", true);
      $("#ddlNewEntryBankName").prop("disabled", true);
      $("#ddlNewEntryBranchName").prop("disabled", true);
      $("#ddlNewEntryNomineeRelation").prop("disabled", true);

      $("#txtEntryNewMobileNo").prop("disabled", true);

      $("#txtNewEntryAccountName").prop("disabled", true);
      $("#txtNewEntryAccountNo").prop("disabled", true);
      $("#txtNewEntryIFSCCode").prop("disabled", true);

      $("#txtNewEntryNomineeName").prop("disabled", true);
      $("#txtNewEntryNomineeMobileNo").prop("disabled", true);
      $("#txtNewEntryNomineeAadharNo").prop("disabled", true);
    } else if (Action == "Edit") {
      $("#ddlEntryApprovalStatus").prop("disabled", false);
      $("#txtEntryRemark").prop("disabled", false);

      $("#ddlNewEntryMCCName").prop("disabled", false);
      $("#ddlNewEntryBankName").prop("disabled", false);
      $("#ddlNewEntryBranchName").prop("disabled", false);
      $("#ddlNewEntryNomineeRelation").prop("disabled", false);

      $("#txtEntryNewMobileNo").prop("disabled", false);

      $("#txtNewEntryAccountName").prop("disabled", false);
      $("#txtNewEntryAccountNo").prop("disabled", false);
      $("#txtNewEntryIFSCCode").prop("disabled", false);

      $("#txtNewEntryNomineeName").prop("disabled", false);
      $("#txtNewEntryNomineeMobileNo").prop("disabled", false);
      $("#txtNewEntryNomineeAadharNo").prop("disabled", false);
    }

    $("#ddlEntryApprovalStatus").on("change", function () {
      var selectedValue = $(this).val();
      var selectedWord = "Yes, Reject it!";
      if (selectedValue == 0) {
        selectedWord = "Yes, Keep it Pending!";
      }

      if (selectedValue != "") {
        if (!(selectedValue == 1)) {
          swal(
            {
              title: "Are you sure?",
              text: "You won't be able to revert this!",
              icon: "question",
              type: "warning",
              showCancelButton: true,
              confirmButtonText: selectedWord,
            },
            function (result) {
              if (result == true) {
                GetMaster(
                  "ddlEntryApprovalStatus",
                  "Select Approval Status",
                  "GetApprovedStatus",
                  selectedValue,
                  ""
                );
              }
            }
          );
        }
        if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
          $("#btn_Save").show();
        } else {
          $("#btn_Save").hide();
        }
      }
    });

    if (RequestType == "MobileNo") {
      //temp value for now
      $("#divNewMobileNumber").show();
      $("#divBankDetails").hide();
      $("#divNewBankDetails").hide();
      $("#divNomineeDetails").hide();
      $("#divNewNomineeDetails").hide();
    } else if (RequestType == "BankDetails") {
      //temp value for now
      $("#divNewMobileNumber").hide();
      $("#divBankDetails").show();
      $("#divNewBankDetails").show();
      $("#divNomineeDetails").hide();
      $("#divNewNomineeDetails").hide();
    } else if (RequestType == "Nominee") {
      //temp value for now
      $("#divNewMobileNumber").hide();
      $("#divBankDetails").hide();
      $("#divNewBankDetails").hide();
      $("#divNomineeDetails").show();
      $("#divNewNomineeDetails").show();
    }

    var APIEndPoint = "GetDataCorrection";
    var url = "/Approvals/DataCorrection";
    var reqdata = {
      request_id: Request_Id,
      method_name: "Get_One",
      api_end_point: APIEndPoint,
      request_for: "Farmer",
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result); //.responseData);

        Farmer_Id = res[0].request_for_user_id;

        GetMaster(
          "ddlEntryApprovalStatus",
          "Select Approval Status",
          "GetApprovedStatus",
          res[0].is_approved,
          ""
        );
        $("#txtEntryRemark").val(res[0].approval_remarks);
        $("#txtEntryFarmerName").val(res[0].request_for_user_name);
        $("#txtEntryBirthDate").val(res[0].birth_date);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        $("#txtEntryEmailID").val(res[0].email_id);
        GetMaster(
          "ddlEntryMCCName",
          "Select MCC Name",
          "GetMCC",
          res[0].mcc_id,
          ""
        );
        $("#txtEntryPanNo").val(res[0].pan_no);
        $("#txtEntryAadharNo").val(res[0].aadhar_no);
        $("#txtEntryAlternateMobileNo").val(res[0].alternatemobile_no);

        GetMaster(
          "ddlEntryBankName",
          "Select Bank",
          "GetBank",
          res[0].bank_id,
          ""
        );
        GetMaster(
          "ddlEntryBranchName",
          "Select Branch",
          "GetBranch",
          res[0].branch_id,
          res[0].bank_id
        );
        $("#txtEntryAccountName").val(res[0].account_name);
        $("#txtEntryAccountNo").val(res[0].account_no);
        $("#txtEntryIFSCCode").text(res[0].ifsc_code);

        $("#txtEntryNomineeName").val(res[0].nominee_name);
        GetMaster(
          "ddlEntryNomineeRelation",
          "Select Nominee Relation",
          "GetNomineeRelation",
          res[0].nominee_relation,
          ""
        );
        $("#txtEntryNomineeMobileNo").val(res[0].nominee_mobile_no);
        $("#txtEntryNomineeAadharNo").val(res[0].nominee_aadhar_no);

        var reqdata = JSON.parse(res[0].request_data);

        // Assign values to requested data fields

        $("#txtEntryNewMobileNo").val(reqdata.mobile_no);

        GetMaster(
          "ddlNewEntryBankName",
          "Select Bank",
          "GetBank",
          reqdata.bank_id,
          ""
        );
        GetMaster(
          "ddlNewEntryBranchName",
          "Select Branch",
          "GetBranch",
          reqdata.branch_id,
          reqdata.bank_id
        );
        $("#txtNewEntryAccountName").val(reqdata.account_name);
        $("#txtNewEntryAccountNo").val(reqdata.account_no);
        //$("#txtNewEntryIFSCCode").text(reqdata.ifsc_code);
        SetNewIFSCCode(reqdata.branch_id);

        $("#txtNewEntryNomineeName").val(reqdata.nominee_name);
        GetMaster(
          "ddlNewEntryNomineeRelation",
          "Select Nominee Relation",
          "GetNomineeRelation",
          reqdata.nominee_relation,
          ""
        );
        $("#txtNewEntryNomineeMobileNo").val(reqdata.nomineemobile_no);
        $("#txtNewEntryNomineeAadharNo").val(reqdata.nomineeaadhar_no);
      },
      error: function () {
        Show_Error_Toastr("Error : Farmer Data Correction details not found");
      },
    });
  });
}

function GetBranch() {
  $("#txtEntryIFSCCode").text("");
  var Bank_Id = $("#ddlEntryBankName").val();
  GetMaster(
    "ddlEntryBranchName",
    "Select Branch Name",
    "GetBranch",
    "",
    Bank_Id
  );
}

function GetNewBranch() {
  $("#txtNewEntryIFSCCode").text("");
  var Bank_Id = $("#ddlNewEntryBankName").val();
  GetMaster(
    "ddlNewEntryBranchName",
    "Select Branch Name",
    "GetBranch",
    "",
    Bank_Id
  );
}

function SetIFSCCode(Branch_Id) {
  var Bank_Id = $("#ddlEntryBankName").val();
  if (Branch_Id == "") {
    Branch_Id = $("#ddlEntryBranchName").val();
  }
  GetIFSCCode(Bank_Id, Branch_Id, "txtEntryIFSCCode");
}
function SetNewIFSCCode(Branch_Id) {
  var Bank_Id = $("#ddlNewEntryBankName").val();
  if (Branch_Id == "") {
    Branch_Id = $("#ddlNewEntryBranchName").val();
  }
  GetIFSCCode(Bank_Id, Branch_Id, "txtNewEntryIFSCCode");
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function SaveEntry() {
  // Validation code
  var Approval_Status = $("#ddlEntryApprovalStatus").val();
  var Approval_Remarks = $("#txtEntryRemark").val().trim();

  var New_Mobile_No = $("#txtEntryNewMobileNo").val().trim();

  var New_Bank_Id = $("#ddlNewEntryBankName").val();
  var New_Branch_Id = $("#ddlNewEntryBranchName").val();
  var New_Account_Name = $("#txtNewEntryAccountName").val();
  var New_Account_No = $("#txtNewEntryAccountNo").val();
  var New_Nominee_Name = $("#txtNewEntryNomineeName").val();
  var New_Nominee_Relation = $("#ddlNewEntryNomineeRelation").val();
  var New_NomineeMobile_No = $("#txtNewEntryNomineeMobileNo").val();
  var New_NomineeAadhar_No = $("#txtNewEntryNomineeAadharNo").val();

  var IsValid = 1;

  if (Approval_Status == "") {
    IsValid = 0;
    $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
  }

  if (RequestType == "MobileNo") {
    if (New_Mobile_No == "" || Is_Valid_MobileNo(New_Mobile_No) == false) {
      IsValid = 0;
      $("#txtEntryNewMobileNo").addClass("is-invalid state-invalid");
    }
  } else if (RequestType == "BankDetails") {
    if (New_Bank_Id == "") {
      IsValid = 0;
      $("#ddlNewEntryBankName").addClass("is-invalid state-invalid");
    }

    if (New_Branch_Id == "") {
      IsValid = 0;
      $("#ddlNewEntryBranchName").addClass("is-invalid state-invalid");
    }

    if (New_Account_Name == "") {
      IsValid = 0;
      $("#txtNewEntryAccountName").addClass("is-invalid state-invalid");
    }

    if (New_Account_No == "") {
      IsValid = 0;
      $("#txtNewEntryAccountNo").addClass("is-invalid state-invalid");
    }
  } else if (RequestType == "Nominee") {
    if (New_NomineeMobile_No != "") {
      if (Is_Valid_MobileNo(New_NomineeMobile_No) == false) {
        IsValid = 0;
        $("#txtNewEntryNomineeMobileNo").addClass("is-invalid state-invalid");
      }
    }

    if (New_NomineeAadhar_No != "") {
      if (Is_Valid_AadharNo(New_NomineeAadhar_No) == false) {
        IsValid = 0;
        $("#txtNewEntryNomineeAadharNo").addClass("is-invalid state-invalid");
      }
    }
    if (New_Nominee_Relation == "") {
      IsValid = 0;
      $("#ddlNewEntryNomineeRelation").addClass("is-invalid state-invalid");
    }
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveDataCorrection";
  Request_Id = $("#lblEntryId").html();
  Method_Name = "Update";

  var request_data_json = {
    mobile_no: New_Mobile_No,
    bank_id: New_Bank_Id,
    branch_id: New_Branch_Id,
    account_name: New_Account_Name,
    account_no: New_Account_No,
    nominee_name: New_Nominee_Name,
    nominee_relation: New_Nominee_Relation,
    nomineemobile_no: New_NomineeMobile_No,
    nomineeaadhar_no: New_NomineeAadhar_No,
  };

  var request_data_string = "{" + JSON.stringify(request_data_json) + "}";

  var url = "/Approvals/DataCorrection";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    approvalstatus_id: Approval_Status,
    approval_remarks: Approval_Remarks,
    request_id: Request_Id,
    request_type: RequestType,
    request_data: request_data_string,
    request_for_user_id: Farmer_Id,
    request_for: "Farmer",
    mobile_no: New_Mobile_No,

    bank_id: New_Bank_Id,
    branch_id: New_Branch_Id,
    account_name: New_Account_Name,
    account_no: New_Account_No,
    nominee_name: New_Nominee_Name,
    nominee_relation: New_Nominee_Relation,
    nominee_mobile_no: New_NomineeMobile_No,
    nominee_aadhar_no: New_NomineeAadhar_No,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        // Show Success Message
        Show_Success_Toastr(
          "Farmer Data Correction " +
            result[0].result_description +
            " successfully."
        );
        CloseEntry();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
      $("#btn_Save").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Data Correction details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
}
