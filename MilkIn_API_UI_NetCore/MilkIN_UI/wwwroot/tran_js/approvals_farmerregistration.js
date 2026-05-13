$(document).ready(function () {
  $("#ddlSearchApprovalStatus").select2();

  GetMaster(
    "ddlSearchApprovalStatus",
    "Select Approval Status",
    "GetApprovedStatus",
    0,
    ""
  );

  //SetDataTable("tableSearch", [6], "FarmerRegistration");

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

  var url = "/Approvals/FarmerRegistration";

  var APIEndPoint = "GetFarmerRegistration";
  var Method_Name = "Get";
  var Request_Date = $("#txtSearchRequestPeriod").val();
  var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

  var Status_Id = "";

  if (ApprovalStatus_Id == "") {
    Status_Id = "0";
  } else {
    Status_Id = ApprovalStatus_Id;
  }

  var reqdata = {
    method_name: Method_Name,
    request_date: Request_Date,
    approvalstatus_id: Status_Id,
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
        var Approved_Status;
        if (value.is_approved == 1) {
          Approved_Status = "Approved";
        } else if (value.is_approved == 0) {
          Approved_Status = "Pending";
        } else {
          Approved_Status = "Rejected";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.request_date + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td>" + Approved_Status + "</td>";

        if (EditFlag == true) {
          if (value.is_approved != 1 && value.is_approved != -1) {
            TableHTML +=
              "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowApproveEntry(\'' +
              value.farmer_id +
              "')\">";
            TableHTML += '<i class="fa fa-pencil"></i>';
            TableHTML += "</a>";
            TableHTML += "</td>";
          } else {
            TableHTML +=
              "<td class='text-right' style='width: 100px; padding:8px 5px 8px 5px;'>";
            TableHTML += "" + value.approved_on + "";
            TableHTML += "</td>";
          }
        }

        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Farmer Registration");
      /*$("#btn_Search").prop('disabled', false);*/
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      /*$("#btn_Search").prop('disabled', false);*/
    },
  });
}

function ShowApproveEntry(Farmer_Id) {
  ShowContentDiv("Approvals", "FarmerRegistrationAdd", "", function () {
    // Initialization Code
    $("#btn_Save").hide();
    $("#ddlEntryApprovalStatus").select2();

    $("#ddlEntryMCCName").select2();
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();
    $("#ddlEntryNomineeRelation").select2();
    $("#ddlEntryWithholdingTaxType").select2();
    $("#lblEntryId").html(Farmer_Id);
    $("#lblAction").html("Edit");

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

    var APIEndPoint = "GetFarmerRegistration";
    var url = "/Approvals/FarmerRegistration";
    var reqdata = {
      farmer_id: Farmer_Id,
      method_name: "Get_One",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result); //.responseData);

        if (
          res[0].withholdingtaxtype_id == "" ||
          res[0].withholdingtaxtype_id == null ||
          res[0].withholdingtaxtype_id == undefined
        ) {
          GetMaster(
            "ddlEntryWithholdingTaxType",
            "Select Withholding Tax Type",
            "GetWithholdingTaxType",
            "C048001",
            ""
          );
        } else {
          GetMaster(
            "ddlEntryWithholdingTaxType",
            "Select Withholding Tax Type",
            "GetWithholdingTaxType",
            res[0].withholdingtaxtype_id,
            ""
          );
        }
        $("#txtEntryGovFarmerId").val(res[0].gov_farmer_id);
        $("#txtEntryGovFarmerName").val(res[0].gov_farmer_name);
        GetMaster(
          "ddlEntryApprovalStatus",
          "Select Approval Status",
          "GetApprovedStatus",
          res[0].is_approved,
          ""
        );
        $("#txtEntryRemark").val(res[0].approval_remarks);
        $("#txtEntryMCCFarmerCode").val(res[0].mcc_farmer_code);
        $("#txtEntryFarmerName").val(res[0].farmer_name);
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
        $("#txtEntryCowCount").val(res[0].cow_count);
        $("#txtEntryBuffaloCount").val(res[0].buffalo_count);
        $("#txtEntryCalfCount").val(res[0].calf_count);
        $("#txtEntryMilkCapacity").val(res[0].milk_capacity);
        GetMaster(
          "ddlEntryState",
          "Select State",
          "GetState",
          res[0].state_id,
          ""
        );
        GetMaster(
          "ddlEntryDistrict",
          "Select District",
          "GetDistrict",
          res[0].district_id,
          res[0].state_id
        );
        GetMaster(
          "ddlEntryTaluka",
          "Select Taluka",
          "GetTaluka",
          res[0].taluka_id,
          res[0].district_id
        );
        GetMaster(
          "ddlEntryVillage",
          "Select Village",
          "GetVillage",
          res[0].village_id,
          res[0].taluka_id
        );
        $("#txtEntryAddress").val(res[0].address_text);
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
      },
      error: function () {
        Show_Error_Toastr("Error : Farmer Registration details not found");
      },
    });
  });
}

function GetDistrict() {
  //Empty All Childeren/Dependent DDLs
  $("#ddlEntryTaluka")
    .empty()
    .append($("<option></option>").val("").html("Select Taluka"));
  $("#ddlEntryVillage")
    .empty()
    .append($("<option></option>").val("").html("Select Village"));

  var State_Id = $("#ddlEntryState").val();
  GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", "", State_Id);
}

function GetTaluka() {
  // Empty All Children/Dependent DDls
  $("#ddlEntryVillage")
    .empty()
    .append($("<option></option>").val("").html("Select Village"));

  var District_Id = $("#ddlEntryDistrict").val();
  GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", "", District_Id);
}

function GetVillage() {
  var Taluka_Id = $("#ddlEntryTaluka").val();
  GetMaster("ddlEntryVillage", "Select Village", "GetVillage", "", Taluka_Id);
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

function SetIFSCCode() {
  var Bank_Id = $("#ddlEntryBankName").val();
  var Branch_Id = $("#ddlEntryBranchName").val();
  GetIFSCCode(Bank_Id, Branch_Id, "txtEntryIFSCCode");
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function SaveEntry() {
  // Validation code
  var Approval_Status = $("#ddlEntryApprovalStatus").val();
  var Approval_Remarks = $("#txtEntryRemark").val();
  var MCC_Farmer_Code = $("#txtEntryMCCFarmerCode").val().trim();
  var Farmer_Name = $("#txtEntryFarmerName").val();
  var Birth_Date = $("#txtEntryBirthDate").val();
  var Mobile_No = $("#txtEntryMobileNo").val();
  var Email_Id = $("#txtEntryEmailID").val();

  var MCC_Id = $("#ddlEntryMCCName").val();
  var Pan_No = $("#txtEntryPanNo").val();
  var Aadhar_No = $("#txtEntryAadharNo").val();
  var AlternateMobile_No = $("#txtEntryAlternateMobileNo").val();
  var Cow_Count = $("#txtEntryCowCount").val();
  var Buffalo_Count = $("#txtEntryBuffaloCount").val();
  var Calf_Count = $("#txtEntryCalfCount").val();
  var Milk_Capacity = $("#txtEntryMilkCapacity").val();
  var State_Id = $("#ddlEntryState").val();
  var District_Id = $("#ddlEntryDistrict").val();
  var Taluka_Id = $("#ddlEntryTaluka").val();
  var Village_Id = $("#ddlEntryVillage").val();
  var Address_Text = $("#txtEntryAddress").val();
  var Bank_Id = $("#ddlEntryBankName").val();
  var Branch_Id = $("#ddlEntryBranchName").val();
  var Account_Name = $("#txtEntryAccountName").val();
  var Account_No = $("#txtEntryAccountNo").val();
  var Nominee_Name = $("#txtEntryNomineeName").val();
  var Nominee_Relation = $("#ddlEntryNomineeRelation").val();
  var NomineeMobile_No = $("#txtEntryNomineeMobileNo").val();
  var NomineeAadhar_No = $("#txtEntryNomineeAadharNo").val();

  var WithholdingTaxType_Id = $("#ddlEntryWithholdingTaxType").val();
  var GovFarmerId = $("#txtEntryGovFarmerId").val();
  var GovFarmerName = $("#txtEntryGovFarmerName").val();

  var IsValid = 1;

  if (Approval_Status == "") {
    IsValid = 0;
    $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
  }
  if (Approval_Status == 1) {
    if (
      MCC_Farmer_Code == "" ||
      MCC_Farmer_Code == null ||
      MCC_Farmer_Code == undefined ||
      Is_Valid_Float(MCC_Farmer_Code) == false
    ) {
      IsValid = 0;
      $("#txtEntryMCCFarmerCode").addClass("is-invalid state-invalid");
    }
    if (Farmer_Name == "") {
      IsValid = 0;
      $("#txtEntryFarmerName").addClass("is-invalid state-invalid");
    }

    if (Birth_Date == "") {
      IsValid = 0;
      $("#txtEntryBirthDate").addClass("is-invalid state-invalid");
    }

    if (Is_Valid_MobileNo(Mobile_No) == false) {
      IsValid = 0;
      $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
    }

    if (Email_Id != "") {
      if (Is_Valid_Email(Email_Id) == false) {
        IsValid = 0;
        $("#txtEntryEmailID").addClass("is-invalid state-invalid");
      }
    }

    if (MCC_Id == "" || MCC_Id == null || MCC_Id == undefined) {
      IsValid = 0;
      $("#ddlEntryMCCName").addClass("is-invalid state-invalid");
    }

    if (Is_Valid_PanNO(Pan_No) == false) {
      IsValid = 0;
      $("#txtEntryPanNo").addClass("is-invalid state-invalid");
    }

    if (Is_Valid_AadharNo(Aadhar_No) == false) {
      IsValid = 0;
      $("#txtEntryAadharNo").addClass("is-invalid state-invalid");
    }

    if (AlternateMobile_No != "") {
      if (Is_Valid_MobileNo(AlternateMobile_No) == false) {
        IsValid = 0;
        $("#txtEntryAlternateMobileNo").addClass("is-invalid state-invalid");
      }
    }

    if (
      WithholdingTaxType_Id == "" ||
      WithholdingTaxType_Id == null ||
      WithholdingTaxType_Id == undefined
    ) {
      IsValid = 0;
      $("#ddlEntryWithholdingTaxType").addClass("is-invalid state-invalid");
    }
    if (Cow_Count == "") {
      IsValid = 0;
      $("#txtEntryCowCount").addClass("is-invalid state-invalid");
    }

    if (Buffalo_Count == "") {
      IsValid = 0;
      $("#txtEntryBuffaloCount").addClass("is-invalid state-invalid");
    }

    if (Calf_Count == "") {
      IsValid = 0;
      $("#txtEntryCalfCount").addClass("is-invalid state-invalid");
    }

    if (Milk_Capacity == "") {
      IsValid = 0;
      $("#txtEntryMilkCapacity").addClass("is-invalid state-invalid");
    }

    if (State_Id == "") {
      IsValid = 0;
      $("#ddlEntryState").addClass("is-invalid state-invalid");
    }

    if (District_Id == "") {
      IsValid = 0;
      $("#ddlEntryDistrict").addClass("is-invalid state-invalid");
    }

    if (Taluka_Id == "") {
      IsValid = 0;
      $("#ddlEntryTaluka").addClass("is-invalid state-invalid");
    }

    if (Village_Id == "") {
      IsValid = 0;
      $("#ddlEntryVillage").addClass("is-invalid state-invalid");
    }

    if (Bank_Id == "") {
      IsValid = 0;
      $("#ddlEntryBankName").addClass("is-invalid state-invalid");
    }

    if (Branch_Id == "") {
      IsValid = 0;
      $("#ddlEntryBranchName").addClass("is-invalid state-invalid");
    }

    if (Account_Name == "") {
      IsValid = 0;
      $("#txtEntryAccountName").addClass("is-invalid state-invalid");
    }

    if (Account_No == "") {
      IsValid = 0;
      $("#txtEntryAccountNo").addClass("is-invalid state-invalid");
    }

    if (NomineeMobile_No != "") {
      if (Is_Valid_MobileNo(NomineeMobile_No) == false) {
        IsValid = 0;
        $("#txtEntryNomineeMobileNo").addClass("is-invalid state-invalid");
      }
    }

    if (NomineeAadhar_No != "") {
      if (Is_Valid_AadharNo(NomineeAadhar_No) == false) {
        IsValid = 0;
        $("#txtEntryNomineeAadharNo").addClass("is-invalid state-invalid");
      }
    }
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveFarmerRegistration";
  var Method_Name = "Create";
  var Farmer_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Farmer_Id = $("#lblEntryId").html();
  }

  var url = "/Approvals/FarmerRegistration";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    approvalstatus_id: Approval_Status,
    approval_remarks: Approval_Remarks,
    farmer_id: Farmer_Id,
    mcc_farmer_code: MCC_Farmer_Code,
    farmer_name: Farmer_Name,
    birth_date: Birth_Date,
    mobile_no: Mobile_No,
    email_id: Email_Id,
    agent_id: "",
    mcc_id: MCC_Id,
    pan_no: Pan_No,
    aadhar_no: Aadhar_No,
    alternatemobile_no: AlternateMobile_No,
    cow_count: Cow_Count,
    buffalo_count: Buffalo_Count,
    calf_count: Calf_Count,
    milk_capacity: Milk_Capacity,
    state_id: State_Id,
    district_id: District_Id,
    taluka_id: Taluka_Id,
    village_id: Village_Id,
    address_text: Address_Text,
    bank_id: Bank_Id,
    branch_id: Branch_Id,
    account_name: Account_Name,
    account_no: Account_No,
    nominee_name: Nominee_Name,
    nominee_relation: Nominee_Relation,
    nomineemobile_no: NomineeMobile_No,
    nomineeaadhar_no: NomineeAadhar_No,
    gov_farmer_id: GovFarmerId,
    gov_farmer_name: GovFarmerName,
    withholdingtaxtype_id: WithholdingTaxType_Id,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (
        result[0].result_id == 1 ||
        result[0].result_id == 2 ||
        result[0].result_id == 3
      ) {
        // Show Success Message

        if (result[0].result_id == 1 || result[0].result_id == 3) {
          Show_Success_Toastr(
            "Farmer Registration " +
              result[0].result_description +
              " successfully"
          );
        }
        if (result[0].result_id == 2) {
          Show_Error_Toastr("Error : " + result[0].result_description);
          ShowEntryError("Error : " + result[0].result_description);
        }
        CloseEntry();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      ShowEntryError("Error : Farmer Registration details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
  $("#btn_Save").prop("disabled", false);
}
