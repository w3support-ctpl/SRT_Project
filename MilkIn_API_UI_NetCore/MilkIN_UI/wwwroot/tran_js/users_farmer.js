$(document).ready(function () {
  $("#ddlSearchMCCName").select2();

  GetMaster("ddlSearchMCCName", "Select MCC Name", "GetMCC", "", "");

  //SetDataTable("tableSearch", [6], "Farmer");
  ClearInputFieldError();
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");

  // Get data from database and show in table
  var url = "/Users/Farmer";

  var APIEndPoint = "GetFarmer";
  var Method_Name = "Get";
  var Search_Text = $("#txtSearchText").val();
  var MCC_Id = $("#ddlSearchMCCName").val();

  $("#btn_Search").prop("disabled", true);

  var reqdata = {
    method_name: Method_Name,
    search_text: "%" + Search_Text + "%",
    mcc_id: "%" + MCC_Id + "%",
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result); //.responseData);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }

      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.mcc_farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";

        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td>" + value.address_text + "</td>";
        TableHTML += "<td>" + value.pincode + "</td>";
        TableHTML += "<td>" + value.pan_no + "</td>";
        TableHTML += "<td>" + value.aadhar_no + "</td>";
        TableHTML += "<td>" + value.bank_name + "</td>";
        TableHTML += "<td>" + value.account_name + "</td>";
        TableHTML += "<td>" + value.account_no + "</td>";
        TableHTML += "<td>" + value.ifsc_code + "</td>";
        TableHTML += "<td>" + value.nominee_name + "</td>";
        TableHTML += "<td>" + value.nomineerelation_name + "</td>";
        TableHTML += "<td>" + value.nominee_mobile_no + "</td>";
        TableHTML += "<td>" + value.nominee_aadhar_no + "</td>";
        TableHTML += "<td>" + value.gov_farmer_id + "</td>";
        TableHTML += "<td>" + value.gov_farmer_name + "</td>";

        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.farmer_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      // ControlName, HideSortColArray, ExportFileName, HideColumnArray, ExportColumnsArray
      SetDataTable_Master(
        "tableSearch",
        [24],
        "FarmerMaster",
        [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23],
        [
          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
          20, 21, 22, 23,
        ]
      );
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      $("#btn_Search").prop("disabled", false);
    },
  });
}

function ShowAddEntry() {
  $("#btn_Add").prop("disabled", true);
  ShowContentDiv("Users", "FarmerAdd", "", function () {
    // Initialization Code
    $("#ddlEntryAgent").select2();
    $("#ddlEntryMCCName").select2();
    $("#ddlEntryWithholdingTaxType").select2();
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();
    $("#ddlEntryNomineeRelation").select2();
    $("#divFooterDelete").hide();
    $("#ddlEntryMCCName").prop({ disabled: false });

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    DisableFutureDates("txtEntryBirthDate");

    // to clear input field errors whenever user pastes any text in the input fields
    ClearInputFieldError();

    GetMaster("ddlEntryAgent", "Select Agent", "GetAgent", "", "");
    GetMaster("ddlEntryMCCName", "Select MCC Name", "GetMCC", "", "");
    GetMaster(
      "ddlEntryWithholdingTaxType",
      "Select Withholding Tax Type",
      "GetWithholdingTaxType",
      "C048001",
      ""
    );
    GetMaster("ddlEntryState", "Select State", "GetState", "", "");
    GetMaster("ddlEntryBankName", "Select Bank Name", "GetBank", "", "");
    GetMaster(
      "ddlEntryNomineeRelation",
      "Select Nominee Relation",
      "GetNomineeRelation",
      "",
      ""
    );
  });
  $("#btn_Add").prop("disabled", false);
  return;
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

function ShowEditEntry(Farmer_Id) {
  ShowContentDiv("Users", "FarmerEdit", "", function () {
    // Initialization Code
    $("#ddlEntryAgent").select2();
    $("#ddlEntryMCCName").select2();
    $("#ddlEntryWithholdingTaxType").select2();
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();
    $("#ddlEntryNomineeRelation").select2();
    $("#ddlEntryMCCName").prop({ disabled: true });
    $("#btn_Save").prop("disabled", false);
    $("#lblEntryId").html(Farmer_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();

    DisableFutureDates("txtEntryBirthDate");

    ClearInputFieldError();

    var APIEndPoint = "GetFarmer";
    var url = "/Users/Farmer";
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

        $("#txtEntryMCCFarmerCode").val(res[0].mcc_farmer_code);
        $("#txtEntryFarmerCode").val(res[0].farmer_code);
        $("#txtEntryFarmerName").val(res[0].farmer_name);
        $("#txtEntryBirthDate").val(res[0].birth_date);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        $("#txtEntryEmailID").val(res[0].email_id);
        GetMaster(
          "ddlEntryAgent",
          "Select Agent",
          "GetAgent",
          res[0].agent_id,
          ""
        );
        GetMaster(
          "ddlEntryMCCName",
          "Select MCC Name",
          "GetMCC",
          res[0].mcc_id,
          ""
        );

        GetMaster(
          "ddlEntryWithholdingTaxType",
          "Select Withholding Tax Type",
          "GetWithholdingTaxType",
          res[0].withholdingtaxtype_id,
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
        $("#txtEntryGovFarmerId").val(res[0].gov_farmer_id);
        $("#txtEntryGovFarmerName").val(res[0].gov_farmer_name);
        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Farmer details not found");
      },
    });
  });
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function SaveEntry() {
  //$(":input").val().trim();

  // Validation code
  var MCC_Farmer_Code = $("#txtEntryMCCFarmerCode").val().trim();
  var Farmer_Code = $("#txtEntryFarmerCode").val().trim();
  var Farmer_Name = $("#txtEntryFarmerName").val().trim();
  var Birth_Date = $("#txtEntryBirthDate").val();
  var Mobile_No = $("#txtEntryMobileNo").val().trim();
  var Email_Id = $("#txtEntryEmailID").val().trim();
  var Agent_Id = $("#ddlEntryAgent").val();
  var MCC_Id = $("#ddlEntryMCCName").val();
  var WithholdingTaxType_Id = $("#ddlEntryWithholdingTaxType").val();
  var Pan_No = $("#txtEntryPanNo").val().trim();
  var Aadhar_No = $("#txtEntryAadharNo").val().trim();
  var AlternateMobile_No = $("#txtEntryAlternateMobileNo").val().trim();
  var Cow_Count = $("#txtEntryCowCount").val().trim();
  var Buffalo_Count = $("#txtEntryBuffaloCount").val().trim();
  var Calf_Count = $("#txtEntryCalfCount").val().trim();
  var Milk_Capacity = $("#txtEntryMilkCapacity").val().trim();
  var State_Id = $("#ddlEntryState").val();
  var District_Id = $("#ddlEntryDistrict").val();
  var Taluka_Id = $("#ddlEntryTaluka").val();
  var Village_Id = $("#ddlEntryVillage").val();
  var Address_Text = $("#txtEntryAddress").val().trim();
  var Bank_Id = $("#ddlEntryBankName").val();
  var Branch_Id = $("#ddlEntryBranchName").val();
  var Account_Name = $("#txtEntryAccountName").val().trim();
  var Account_No = $("#txtEntryAccountNo").val().trim().trim();
  var Nominee_Name = $("#txtEntryNomineeName").val().trim();
  var Nominee_Relation = $("#ddlEntryNomineeRelation").val();
  var NomineeMobile_No = $("#txtEntryNomineeMobileNo").val().trim();
  var NomineeAadhar_No = $("#txtEntryNomineeAadharNo").val().trim();

  var GovFarmerId = $("#txtEntryGovFarmerId").val();
  var GovFarmerName = $("#txtEntryGovFarmerName").val();

  var IsValid = 1;

  if (
    MCC_Farmer_Code == "" ||
    MCC_Farmer_Code == null ||
    MCC_Farmer_Code == undefined ||
    Is_Positive_Integer(MCC_Farmer_Code) == false
  ) {
    IsValid = 0;
    $("#txtEntryMCCFarmerCode").addClass("is-invalid state-invalid");
  }
  if (
    Farmer_Name == "" ||
    Farmer_Name == null ||
    Farmer_Name == undefined ||
    Is_Valid_Name(Farmer_Name) == false
  ) {
    IsValid = 0;
    $("#txtEntryFarmerName").addClass("is-invalid state-invalid");
  }

  if (Birth_Date == "" || Birth_Date == null || Birth_Date == undefined) {
    IsValid = 0;
    $("#txtEntryBirthDate").addClass("is-invalid state-invalid");
  }

  if (
    Mobile_No == "" ||
    Mobile_No == null ||
    Mobile_No == undefined ||
    Is_Valid_MobileNo(Mobile_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
  }

  if (Email_Id != "") {
    if (
      Email_Id == null ||
      Email_Id == undefined ||
      Is_Valid_Email(Email_Id) == false
    ) {
      IsValid = 0;
      $("#txtEntryEmailID").addClass("is-invalid state-invalid");
    }
  }

  if (MCC_Id == "" || MCC_Id == null || MCC_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMCCName").addClass("is-invalid state-invalid");
  }

  if (
    WithholdingTaxType_Id == "" ||
    WithholdingTaxType_Id == null ||
    WithholdingTaxType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryWithholdingTaxType").addClass("is-invalid state-invalid");
  }

  if (
    Pan_No == "" ||
    Pan_No == null ||
    Pan_No == undefined ||
    Is_Valid_PanNO(Pan_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryPanNo").addClass("is-invalid state-invalid");
  }
  if (
    Aadhar_No == "" ||
    Aadhar_No == null ||
    Aadhar_No == undefined ||
    Is_Valid_AadharNo(Aadhar_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryAadharNo").addClass("is-invalid state-invalid");
  }

  if (AlternateMobile_No != "") {
    if (
      AlternateMobile_No == null ||
      AlternateMobile_No == undefined ||
      Is_Valid_MobileNo(AlternateMobile_No) == false
    ) {
      IsValid = 0;
      $("#txtEntryAlternateMobileNo").addClass("is-invalid state-invalid");
    }
  }

  if (
    Cow_Count == "" ||
    Cow_Count == null ||
    Cow_Count == undefined ||
    Is_Positive_Integer(Cow_Count) == false
  ) {
    IsValid = 0;
    $("#txtEntryCowCount").addClass("is-invalid state-invalid");
  }

  if (
    Buffalo_Count == "" ||
    Buffalo_Count == null ||
    Buffalo_Count == undefined ||
    Is_Positive_Integer(Buffalo_Count) == false
  ) {
    IsValid = 0;
    $("#txtEntryBuffaloCount").addClass("is-invalid state-invalid");
  }

  if (
    Calf_Count == "" ||
    Calf_Count == null ||
    Calf_Count == undefined ||
    Is_Positive_Integer(Calf_Count) == false
  ) {
    IsValid = 0;
    $("#txtEntryCalfCount").addClass("is-invalid state-invalid");
  }

  if (
    Milk_Capacity == "" ||
    Milk_Capacity == null ||
    Milk_Capacity == undefined ||
    Is_Positive_Number_Greater_Than_Zero(Milk_Capacity) == false
  ) {
    IsValid = 0;
    $("#txtEntryMilkCapacity").addClass("is-invalid state-invalid");
  }

  if (State_Id == "" || State_Id == null || State_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryState").addClass("is-invalid state-invalid");
  }

  if (District_Id == "" || District_Id == null || District_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryDistrict").addClass("is-invalid state-invalid");
  }

  if (Taluka_Id == "" || Taluka_Id == null || Taluka_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryTaluka").addClass("is-invalid state-invalid");
  }

  if (Village_Id == "" || Village_Id == null || Village_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryVillage").addClass("is-invalid state-invalid");
  }

  if (Bank_Id == "" || Bank_Id == null || Bank_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryBankName").addClass("is-invalid state-invalid");
  }

  if (Branch_Id == "" || Branch_Id == null || Branch_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryBranchName").addClass("is-invalid state-invalid");
  }

  if (
    Account_Name == "" ||
    Account_Name == null ||
    Account_Name == undefined ||
    Is_Valid_Name(Account_Name) == false
  ) {
    IsValid = 0;
    $("#txtEntryAccountName").addClass("is-invalid state-invalid");
  }

  if (
    Account_No == "" ||
    Account_No == null ||
    Account_No == undefined ||
    Is_Positive_Integer(Account_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryAccountNo").addClass("is-invalid state-invalid");
  }

  if (Nominee_Name != "") {
    if (
      Nominee_Name == null ||
      Nominee_Name == undefined ||
      Is_Valid_Name(Nominee_Name) == false
    ) {
      IsValid = 0;
      $("#txtEntryNomineeName").addClass("is-invalid state-invalid");
    }
  }

  if (NomineeMobile_No != "") {
    if (
      NomineeMobile_No == null ||
      NomineeMobile_No == undefined ||
      Is_Valid_MobileNo(NomineeMobile_No) == false
    ) {
      IsValid = 0;
      $("#txtEntryNomineeMobileNo").addClass("is-invalid state-invalid");
    }
  }

  if (NomineeAadhar_No != "") {
    if (
      NomineeAadhar_No == null ||
      NomineeAadhar_No == undefined ||
      Is_Valid_AadharNo(NomineeAadhar_No) == false
    ) {
      IsValid = 0;
      $("#txtEntryNomineeAadharNo").addClass("is-invalid state-invalid");
    }
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }
  // Start Saving
  Show_Loader();
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveFarmer";
  var Method_Name = "Create";
  var Farmer_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Farmer_Id = $("#lblEntryId").html();
  }

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  var url = "/Users/Farmer";
  var reqdata = {
    mcc_farmer_code: MCC_Farmer_Code,
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    farmer_code: Farmer_Code,
    farmer_id: Farmer_Id,
    farmer_name: Farmer_Name,
    birth_date: Birth_Date,
    mobile_no: Mobile_No,
    email_id: Email_Id,
    agent_id: Agent_Id,
    mcc_id: MCC_Id,
    withholdingtaxtype_id: WithholdingTaxType_Id,
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
    is_active: Is_Active,
    is_deleted: Is_Deleted,
    gov_farmer_id: GovFarmerId,
    gov_farmer_name: GovFarmerName,
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
        Hide_Loader();
        if (result[0].result_id == 1 || result[0].result_id == 3) {
          Show_Success_Toastr("Farmer details saved successfully");
        }
        if (result[0].result_id == 2) {
          Show_Error_Toastr("Error : " + result[0].result_description);
          ShowEntryError("Error : " + result[0].result_description);
        }

        ShowEditEntry(result[0].result_extra_key);
        $("#lblEntryId").html(result[0].result_extra_key);
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Farmer details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
}

function ShowDeleteEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, delete it!",
    },
    function (result) {
      if (result == true) {
        SaveDeleteEntry();
      }
    }
  );
}

function SaveDeleteEntry() {
  // Write code to delete
  var Farmer_Id = $("#lblEntryId").html();

  var Is_Deleted = 1;

  var APIEndPoint = "SaveFarmer";
  var url = "/Users/Farmer";
  var reqdata = {
    farmer_id: Farmer_Id,
    is_deleted: Is_Deleted,
    method_name: "Delete",
    api_end_point: APIEndPoint,
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
        ShowEntrySuccess("Farmer details deleted successfully");

        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer details not deleted");
    },
  });
}
