$(document).ready(function () {
  GetMaster("ddlSearchBranch", "All Branches", "GetBranch", "", "");
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var TransporterName = "%" + $("#txtSearchTransporterName").val() + "%";
  $("#btn_Search").prop("disabled", true);
  var APIEndPoint = "GetTransporter";
  var Method_Name = "Get";
  var url = "/Masters/Transporter";
  var reqdata = {
    method_name: Method_Name,
    transporter_name: TransporterName,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      // Fill data in table
      var TableHTML = "";
      //var Row_No = 0;

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        //Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.transporter_code + "</td>";
        TableHTML += "<td>" + value.transporter_name + "</td>";
        TableHTML += "<td>" + value.contactperson_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";

        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td>" + value.bank_name + "</td>";
        TableHTML += "<td>" + value.account_name + "</td>";
        TableHTML += "<td>" + value.account_no + "</td>";
        TableHTML += "<td>" + value.ifsc_code + "</td>";
        TableHTML += "<td>" + value.company_pan_no + "</td>";
        TableHTML += "<td>" + value.fssai_license_no + "</td>";
        TableHTML += "<td>" + value.licensevalidity_on + "</td>";

        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.transporter_id +
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
        [16],
        "TransporterMaster",
        [6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
      );
      $("#btn_Search").prop("disabled", false);
    },
    error: function (res) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function ShowAddEntry() {
  ShowContentDiv("Masters", "TransporterAdd", "", function () {
    // Initialization Code
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#ddlEntryWithholdingTaxType").select2();

    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();
    $("#txtEntryIFSCCode").prop("disabled", "true");

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");

    // Address Section
    GetMaster("ddlEntryState", "Select State", "GetState", "", "");

    // Bank Details
    GetMaster("ddlEntryBankName", "Select Bank Name", "GetBank", "", "");

    GetMaster(
      "ddlEntryWithholdingTaxType",
      "Select Withholding Tax Type",
      "GetWithholdingTaxType",
      "C048001",
      ""
    );
  });
}

function ShowEditEntry(Transporter_Id) {
  ShowContentDiv("Masters", "TransporterEdit", "", function () {
    // Initialization Code
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#ddlEntryWithholdingTaxType").select2();

    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();

    $("#lblEntryId").html(Transporter_Id);
    $("#lblAction").html("Edit");

    $("#txtEntryIFSCCode").prop("disabled", "true");

    var APIEndPoint = "GetTransporter";
    var Method_Name = "Get_One";
    var url = "/Masters/Transporter";
    var reqdata = {
      method_name: Method_Name,
      transporter_id: Transporter_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res[0].is_locked == 1) {
          $("#chkEntryStatus").prop({ checked: true, disabled: true });
          $("#divFooterDelete").hide();
        } else {
          $("#chkEntryStatus").prop({ checked: false, disabled: false });
          $("#divFooterDelete").show();
        }

        $("#txtEntryTransporterCode").val(res[0].transporter_code);
        $("#txtEntryTransporterName").val(res[0].transporter_name);
        $("#txtEntryContactPerson").val(res[0].contactperson_name);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        $("#txtEntryAddress").val(res[0].address_text);
        $("#txtEntryAccountName").val(res[0].account_name);
        $("#txtEntryAccountNo").val(res[0].account_no);
        $("#txtEntryIFSCCode").text(res[0].ifsc_code);
        $("#txtEntryCompanyPanNo").val(res[0].company_pan_no);
        $("#txtEntryFSSAILicenseNo").val(res[0].fssai_license_no);
        $("#txtEntryLicenseValidity").val(res[0].licensevalidity_on);

        // Address Section
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

        GetMaster(
          "ddlEntryWithholdingTaxType",
          "Select Withholding Tax Type",
          "GetWithholdingTaxType",
          res[0].withholdingtaxtype_id,
          ""
        );

        // Bank Details
        GetMaster(
          "ddlEntryBankName",
          "Select Bank Name",
          "GetBank",
          res[0].bank_id,
          ""
        );
        GetMaster(
          "ddlEntryBranchName",
          "Select Branch Name",
          "GetBranch",
          res[0].branch_id,
          res[0].bank_id
        );

        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
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
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var TransporterName = $("#txtEntryTransporterName").val().trim();
  var TransporterCode = $("#txtEntryTransporterCode").val();
  var ContactPerson = $("#txtEntryContactPerson").val().trim();
  var MobileNo = $("#txtEntryMobileNo").val().trim();

  var State_Id = $("#ddlEntryState").val();
  var District_Id = $("#ddlEntryDistrict").val();
  var Taluka_Id = $("#ddlEntryTaluka").val();
  var Village_Id = $("#ddlEntryVillage").val();
  var WithholdingTaxType_Id = $("#ddlEntryWithholdingTaxType").val();

  var AddressText = $("#txtEntryAddress").val();

  var Bank_Id = $("#ddlEntryBankName").val();
  var Branch_Id = $("#ddlEntryBranchName").val();
  var AccountName = $("#txtEntryAccountName").val().trim();
  var AccountNo = $("#txtEntryAccountNo").val().trim();
  var IFSCCode = $("#txtEntryIFSCCode").text();

  var CompanyPANNo = $("#txtEntryCompanyPanNo").val().trim();
  var FSSAILicenseNo = $("#txtEntryFSSAILicenseNo").val().trim();
  var LicenseValidity = $("#txtEntryLicenseValidity").val();

  var IsValid = 1;

  /*if (TransporterCode == "") {
          ShowEntryError("Enter Transporter Code");
      }*/
  if (
    TransporterName == "" ||
    TransporterName == null ||
    TransporterName == undefined ||
    Is_Valid_Name(TransporterName) == false
  ) {
    IsValid = 0;
    $("#txtEntryTransporterName").addClass("is-invalid state-invalid");
  }
  if (
    ContactPerson == "" ||
    ContactPerson == null ||
    ContactPerson == undefined ||
    Is_Valid_Name(ContactPerson) == false
  ) {
    IsValid = 0;
    $("#txtEntryContactPerson").addClass("is-invalid state-invalid");
  }
  if (MobileNo != "") {
    if (
      MobileNo == null ||
      MobileNo == undefined ||
      Is_Valid_MobileNo(MobileNo) == false
    ) {
      IsValid = 0;
      $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
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
  if (State_Id == "" || State_Id == null || State_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryState").addClass("is-invalid state-invalid");
  }
  if (District_Id == "" || State_Id == null || State_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryDistrict").addClass("is-invalid state-invalid");
  }
  if (Taluka_Id == "" || State_Id == null || State_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryTaluka").addClass("is-invalid state-invalid");
  }
  if (Village_Id == "" || State_Id == null || State_Id == undefined) {
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
    AccountName == "" ||
    AccountName == null ||
    AccountName == undefined ||
    Is_Valid_Name(AccountName) == false
  ) {
    IsValid = 0;
    $("#txtEntryAccountName").addClass("is-invalid state-invalid");
  }
  if (
    AccountNo == "" ||
    AccountNo == null ||
    AccountNo == undefined ||
    Is_Positive_Integer(AccountNo) == false
  ) {
    IsValid = 0;
    $("#txtEntryAccountNo").addClass("is-invalid state-invalid");
  }
  if (
    LicenseValidity == "" ||
    LicenseValidity == null ||
    LicenseValidity == undefined
  ) {
    IsValid = 0;
    $("#txtEntryLicenseValidity").addClass("is-invalid state-invalid");
  }
  // mandatory
  // if (Is_Valid_IFSCNO(IFSCCode) == false) {
  //   IsValid = 0;
  //   $("#txtEntryIFSCCode").addClass("is-invalid state-invalid");
  // }
  // mandatory
  if (
    CompanyPANNo == "" ||
    CompanyPANNo == null ||
    CompanyPANNo == undefined ||
    Is_Valid_PanNO(CompanyPANNo) == false
  ) {
    IsValid = 0;
    $("#txtEntryCompanyPanNo").addClass("is-invalid state-invalid");
  }
  // not mandatory

  // non mandatory
  if (
    FSSAILicenseNo == "" ||
    FSSAILicenseNo == null ||
    FSSAILicenseNo == undefined ||
    Is_Valid_FSSAINO(FSSAILicenseNo) == false
  ) {
    IsValid = 0;
    $("#txtEntryFSSAILicenseNo").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    Show_Loader();
    var APIEndPoint = "SaveTransporter";
    var Method_Name = "Create";
    var Transporter_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Transporter_Id = $("#lblEntryId").html();
    }
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Masters/Transporter";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      transporter_id: Transporter_Id,

      transporter_code: TransporterCode,
      transporter_name: TransporterName,
      contactperson_name: ContactPerson,
      mobile_no: MobileNo,

      state_id: State_Id,
      district_id: District_Id,
      taluka_id: Taluka_Id,
      village_id: Village_Id,
      address_text: AddressText,

      bank_id: Bank_Id,
      branch_id: Branch_Id,
      account_name: AccountName,
      account_no: AccountNo,
      ifsc_code: IFSCCode,

      company_pan_no: CompanyPANNo,
      fssai_license_no: FSSAILicenseNo,
      licensevalidity_on: LicenseValidity,
      withholdingtaxtype_id: WithholdingTaxType_Id,
    };

    //Save
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1 || result[0].result_id == 2) {
          // Show Success Message
          //GetSearchList();
          Hide_Loader();
          if (result[0].result_id == 1) {
            Show_Success_Toastr("Transporter details saved successfully");
          }
          if (result[0].result_id == 2) {
            Show_Error_Toastr("Error : " + result[0].result_description);
            ShowEntryError("Error : " + result[0].result_description);
          }

          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          // ShowEntrySuccess("Transporter details saved successfully");
          ShowEditEntry(result[0].result_extra_key);
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : Transporter details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
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
  var APIEndPoint = "SaveTransporter";
  var Transporter_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  // In success do following things
  var url = "/Masters/Transporter";
  var reqdata = {
    transporter_id: Transporter_Id,
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
        Show_Success_Toastr("Transporter details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Transporter details not deleted");
    },
  });
}
