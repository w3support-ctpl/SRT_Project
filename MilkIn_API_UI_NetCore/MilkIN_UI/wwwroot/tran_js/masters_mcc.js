let ApplicableFromDate = [];

$(document).ready(function () {});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var APIEndPoint = "GetMCC";
  var Search_Text = "%" + $("#txtSearchText").val() + "%";
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Masters/MCC";
  var reqdata = {
    method_name: Method_Name,
    search_text: Search_Text,
    api_end_point: APIEndPoint,
  };

  //Search
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      // Fill data in table
      var TableHTML = "";
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mcccategory_name + "</td>";
        TableHTML += "<td>" + value.mcctype_name + "</td>";
        TableHTML += "<td>" + value.mccworktype_name + "</td>";
        TableHTML += "<td>" + value.agent_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";

        TableHTML += "<td>" + value.plant_code + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.address_text + "</td>";
        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td>" + value.pan_no + "</td>";
        TableHTML += "<td>" + value.aadhar_no + "</td>";
        TableHTML += "<td>" + value.bank_name + "</td>";
        TableHTML += "<td>" + value.account_name + "</td>";
        TableHTML += "<td>" + value.account_no + "</td>";
        TableHTML += "<td>" + value.ifsc_code + "</td>";
        TableHTML += "<td>" + value.fssailicense_no + "</td>";
        TableHTML += "<td>" + value.fssailicensevalidity_on + "</td>";

        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.mcc_id +
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
        [22],
        "MCCMaster",
        [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21],
        [
          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
          20, 21,
        ]
      );
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
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
  ShowContentDiv("Masters", "MCCAdd", "", function () {
    // Initialization Code

    $("#divMilkType").show();
    $("#divCollectionShift").show();
    $("#divAnamat").show();
    $("#divFreight").show();
    $("#divAnamatTDS").show();
    $("#divFreightTDS").show();
    $("#divRebate").show();
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#ddlEntryCategory").select2();
    $("#ddlEntryType").select2();
    $("#ddlEntryAgent").select2();
    $("#ddlEntryMusterType").select2();
    $("#ddlEntryMCCWorkType").select2();
    $("#ddlEntryWithholdingTaxType").select2();
    $("#ddlEntryMilkType").select2();
    $("#ddlEntryPaymentCycle").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();
    $("#ddlEntryPaymentType").select2();
    $("#ddlEntryCollectionShift").select2();
    $("#ddlEntryAnamatTDS").select2();
    $("#ddlEntryFreightTDS").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();
    $("#txtEntryIFSCCode").prop("disabled", "true");

    $("#divMusterType").show();
    $("#divPaymentCycle").show();
    $("#divTabs").hide();

    // Topmost Section
    GetMaster("ddlEntryCategory", "Select Catagory", "GetMCCCategory", "", "");
    GetMaster("ddlEntryType", "Select Type", "GetMCCType", "", "");
    GetMaster("ddlEntryAgent", "Select Agent", "GetAgent", "", "");

    // Address Section
    GetMaster("ddlEntryState", "Select State", "GetState", "", "");

    // Bank Details
    GetMaster("ddlEntryBankName", "Select Bank Name", "GetBank", "", "");

    // Other Details
    GetMaster(
      "ddlEntryMusterType",
      "Select Muster Type",
      "GetMusterType",
      "",
      ""
    );
    GetMaster(
      "ddlEntryMCCWorkType",
      "Select MCC Work Type",
      "GetMCCWorkType",
      "",
      ""
    );
    GetMaster(
      "ddlEntryWithholdingTaxType",
      "Select Withholding Tax Type",
      "GetWithholdingTaxType",
      "C048001",
      ""
    );

    GetMaster(
      "ddlEntryPaymentCycle",
      "Select Payment Cycle",
      "GetPaymentCycle",
      "",
      ""
    );
    GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", "", "");
    GetMaster("ddlEntryAnamatTDS", "Select Anamat TDS", "GetFMStatus", "", "");
    GetMaster(
      "ddlEntryFreightTDS",
      "Select Freight TDS",
      "GetFMStatus",
      "",
      ""
    );
    // GetMaster(
    //   "ddlEntryCollectionShift",
    //   "Select Collection Shift",
    //   "GetMilkCollectionShift",
    //   "",
    //   ""
    // );
    GetMaster(
      "ddlEntryPaymentType",
      "Select Payment Type",
      "GetPaymentType",
      "",
      ""
    );

    $("#ddlEntryMusterType").on("change", function () {
      var m_last3 = $("#ddlEntryMusterType").val().slice(-3);
      // // console.log(m_last3);
      $("#ddlEntryPaymentCycle > option").each(function () {
        // // console.log(this.value.slice(-3));
        if (this.value.slice(-3) < m_last3) {
          $(this).prop("disabled", true);
        } else {
          $(this).prop("disabled", false);
        }
      });
    });
  });
}

function ShowEditEntry(MCC_Id) {
  $("#OpenModalPaymentSettings").hide();
  ShowContentDiv("Masters", "MCCEdit", "", function () {
    // Initialization Code

    //$('#divMilkType').hide();
    //$('#divCollectionShift').hide();

    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#ddlEntryCategory").select2();
    $("#ddlEntryType").select2();
    $("#ddlEntryAgent").select2();
    //$("#ddlEntryMusterType").select2();
    $("#ddlEntryMCCWorkType").select2();
    $("#ddlEntryWithholdingTaxType").select2();
    //$("#ddlEntryMilkType").select2();
    //$("#ddlEntryPaymentCycle").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();
    $("#ddlEntryPaymentType").select2();
    //$("#ddlEntryCollectionShift").select2();

    $("#lblEntryId").html(MCC_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();
    $("#txtEntryIFSCCode").prop("disabled", "true");
    $("#ddlEntryType").prop("disabled", "true");
    $("#ddlEntryMCCWorkType").prop("disabled", "true");
    $("#divPaymentCycle").hide();
    $("#divMusterType").hide();
    $("#divTabs").show();

    var APIEndPoint = "GetMCC";
    var Method_Name = "Get_One";
    var url = "/Masters/MCC";
    var reqdata = {
      method_name: Method_Name,
      mcc_id: MCC_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res[0].is_locked == "1") {
          $("#OpenModalPaymentSettings").show();
        } else {
          $("#OpenModalPaymentSettings").hide();
        }

        $("#txtEntryMCCCode").val(res[0].mcc_code);
        $("#txtEntryMCCName").val(res[0].mcc_name);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        $("#txtEntryAddress").val(res[0].address_text);
        $("#txtEntryAccountName").val(res[0].account_name);
        $("#txtEntryAccountNo").val(res[0].account_no);
        $("#txtEntryIFSCCode").text(res[0].ifsc_code);
        $("#txtEntryFSSAILicenseNo").val(res[0].fssailicense_no);
        $("#txtEntryFSSAILicenseValidity").val(res[0].fssailicensevalidity_on);
        $("#txtEntryLatitude").val(res[0].latitude);
        $("#txtEntryLongitude").val(res[0].longitude);
        $("#txtEntryPanNo").val(res[0].pan_no);
        $("#txtEntryAnamat").val(res[0].anamat);
        $("#txtEntryFreight").val(res[0].freight);
        $("#txtEntryRebate").val(res[0].rebate);

        $("#txtEntryPlantCode").val(res[0].plant_code);
        // $("#txtEntryAadharNo").val(res[0].aadhar_no);

        // Topmost Section
        GetMaster(
          "ddlEntryCategory",
          "Select Catagory",
          "GetMCCCategory",
          res[0].mcccategory_id,
          ""
        );
        GetMaster(
          "ddlEntryType",
          "Select Type",
          "GetMCCType",
          res[0].mcctype_id,
          ""
        );

        $("#lblType").html(res[0].mcctype_id);
        GetMaster(
          "ddlEntryAgent",
          "Select Agent",
          "GetAgent",
          res[0].agent_id,
          ""
        );

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

        // Other Details
        //GetMaster("ddlEntryMusterType", "Select Muster Type", "GetMusterType", res[0].mustertype_id, "");
        GetMaster(
          "ddlEntryMCCWorkType",
          "Select MCC Work Type",
          "GetMCCWorkType",
          res[0].mccworktype_id,
          ""
        );
        //GetMaster("ddlEntryPaymentCycle", "Select Payment Cycle", "GetPaymentCycle", res[0].paymentcycle_id, "");
        GetMaster(
          "ddlEntryPaymentType",
          "Select Payment Type",
          "GetPaymentType",
          res[0].paymenttype_id,
          ""
        );
        GetMaster(
          "ddlEntryWithholdingTaxType",
          "Select Withholding Tax Type",
          "GetWithholdingTaxType",
          res[0].withholdingtaxtype_id,
          ""
        );

        //GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", res[0].milktype_id, "");
        if (
          $("#ddlEntryType").val() == "C014003" ||
          $("#ddlEntryType").val() == "C014001"
        ) {
          $("#ddlEntryMilkType option")
            .filter('[value="C011003"],[value="C011004"]')
            .remove();
        }
        //else {
        //GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", "", "");
        //}

        //GetMaster("ddlEntryCollectionShift", "Select Collection Shift", "GetMilkCollectionShift", res[0].collectionshift_id, "");

        if (res[0].is_manualweight == 1) {
          $("#chkForAllowManualQuantity").prop("checked", true);
        } else {
          $("#chkForAllowManualQuantity").prop("checked", false);
        }

        if (res[0].alternate == 1) {
          $("#chkForAllowAlternateDispatch").prop("checked", true);
        } else {
          $("#chkForAllowAlternateDispatch").prop("checked", false);
        }

        if (res[0].is_manualquality == 1) {
          $("#chkForAllowManualQuality").prop("checked", true);
        } else {
          $("#chkForAllowManualQuality").prop("checked", false);
        }

        if (res[0].is_manualshiftend == 1) {
          $("#chkForAllowManualShiftEnd").prop("checked", true);
        } else {
          $("#chkForAllowManualShiftEnd").prop("checked", false);
        }

        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }

        GetPaymentSettingsList();
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });

    $("#modelEntryPaymentSettings").on("hidden.bs.modal", function (e) {
      ResetInputFields();
      $("#lblActionPaymentSettings").html("");
      $("#lblEntryPaymentSettingsId").text("");
      $("#txtModalEntryAnamat").val("");
      $("#txtModalEntryFreight").val("");
      $("#txtModalEntryRebate").val("");

      $("#ddlModalEntryMilkType").val([]);
      $("#ddlModalEntryCollectionShift").val([]);
    });
  });
}

function SetMilkType() {
  if (
    $("#ddlEntryType").val() == "C014003" ||
    $("#ddlEntryType").val() == "C014001"
  ) {
    $("#ddlEntryMilkType option")
      .filter('[value="C011003"],[value="C011004"]')
      .remove();
  } else {
    GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", "", "");
  }
}

function GetCollectionShift() {
  if (
    $("#ddlEntryType").val() == "C014002" ||
    $("#ddlEntryType").val() == "C014001"
  ) {
    GetMaster(
      "ddlEntryCollectionShift",
      "Select Collection Shift",
      "GetMilkCollectionShiftME",
      "",
      ""
    );
  }
  if ($("#ddlEntryType").val() == "C014003") {
    GetMaster(
      "ddlEntryCollectionShift",
      "Select Collection Shift",
      "GetMilkCollectionShiftAD",
      "",
      ""
    );
  }
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
  // disable invalid values
  // Validation code
  var MCCName = $("#txtEntryMCCName").val().trim();
  var MCCCode = $("#txtEntryMCCCode").val();
  var Category_Id = $("#ddlEntryCategory").val();
  var Type_Id = $("#ddlEntryType").val();
  var Agent_Id = $("#ddlEntryAgent").val();
  var MobileNo = $("#txtEntryMobileNo").val().trim();

  var State_Id = $("#ddlEntryState").val();
  var District_Id = $("#ddlEntryDistrict").val();
  var Taluka_Id = $("#ddlEntryTaluka").val();
  var Village_Id = $("#ddlEntryVillage").val();
  var AddressText = $("#txtEntryAddress").val().trim();

  var Bank_Id = $("#ddlEntryBankName").val();
  var Branch_Id = $("#ddlEntryBranchName").val();
  var AccountName = $("#txtEntryAccountName").val();
  var AccountNo = $("#txtEntryAccountNo").val();
  var IFSCCode = $("#txtEntryIFSCCode").text();

  var MusterType_Id = $("#ddlEntryMusterType").val();
  var MCCWorkType_Id = $("#ddlEntryMCCWorkType").val();
  var WithholdingTaxType_Id = $("#ddlEntryWithholdingTaxType").val();
  var PaymentCycle_Id = $("#ddlEntryPaymentCycle").val();
  var MilkType_Id = $("#ddlEntryMilkType").val().join();
  var CollectionShift_Id = $("#ddlEntryCollectionShift").val().join();
  //return;

  var FSSAILicenseNo = $("#txtEntryFSSAILicenseNo").val().trim();
  var FSSAILicenceValidity = $("#txtEntryFSSAILicenseValidity").val();
  var Latitude = $("#txtEntryLatitude").val().trim();
  var Longitude = $("#txtEntryLongitude").val().trim();
  var PaymentType_Id = $("#ddlEntryPaymentType").val();
  var Action_Name = $("#lblAction").html();
  var Pan_No = $("#txtEntryPanNo").val().trim();

  var Anamat = $("#txtEntryAnamat").val().trim();
  var Freight = $("#txtEntryFreight").val().trim();
  var Anamat_TDS = $("#ddlEntryAnamatTDS").val();
  var Freight_TDS = $("#ddlEntryFreightTDS").val();

  var Rebate = $("#txtEntryRebate").val().trim();
  var Plant_Code = $("#txtEntryPlantCode").val().trim();
  // var Aadhar_No = $("#txtEntryAadharNo").val().trim();
  var IsValid = 1;

  if (
    MCCName == "" ||
    MCCName == null ||
    MCCName == undefined ||
    Is_Valid_Name(MCCName) == false
  ) {
    IsValid = 0;
    $("#txtEntryMCCName").addClass("is-invalid state-invalid");
  }
  if (Category_Id == "" || Category_Id == null || Category_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryCategory").addClass("is-invalid state-invalid");
  }
  if (Type_Id == "" || Type_Id == null || Type_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryType").addClass("is-invalid state-invalid");
  }
  if (Agent_Id == "" || Agent_Id == null || Agent_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryAgent").addClass("is-invalid state-invalid");
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
  if (Pan_No != "") {
    if (
      Pan_No == null ||
      Pan_No == undefined ||
      Is_Valid_PanNO(Pan_No) == false
    ) {
      IsValid = 0;
      $("#txtEntryPanNo").addClass("is-invalid state-invalid");
    }
  }

  // if (Aadhar_No != "") {
  //   if (
  //     Aadhar_No == null ||
  //     Aadhar_No == undefined ||
  //     Is_Valid_AadharNo(Aadhar_No) == false
  //   ) {
  //     IsValid = 0;
  //     $("#txtEntryAadharNo").addClass("is-invalid state-invalid");
  //   }
  // }
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

  // if (AccountName != "") {
  if (
    AccountName == "" ||
    AccountName == null ||
    AccountName == undefined ||
    Is_Valid_Name(AccountName) == false
  ) {
    IsValid = 0;
    $("#txtEntryAccountName").addClass("is-invalid state-invalid");
  }
  // }

  // if (AccountNo != "") {
  if (
    AccountNo == "" ||
    AccountNo == null ||
    AccountNo == undefined ||
    Is_Positive_Integer(AccountNo) == false
  ) {
    IsValid = 0;
    $("#txtEntryAccountNo").addClass("is-invalid state-invalid");
  }
  // }
  if (
    MCCWorkType_Id == "" ||
    MCCWorkType_Id == null ||
    MCCWorkType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryMCCWorkType").addClass("is-invalid state-invalid");
  }

  if (
    WithholdingTaxType_Id == "" ||
    WithholdingTaxType_Id == null ||
    WithholdingTaxType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryWithholdingTaxType").addClass("is-invalid state-invalid");
  }

  if (Action_Name == "Add") {
    if (
      MusterType_Id == "" ||
      MusterType_Id == null ||
      MusterType_Id == undefined
    ) {
      IsValid = 0;
      $("#ddlEntryMusterType").addClass("is-invalid state-invalid");
    }
    if (
      PaymentCycle_Id == "" ||
      PaymentCycle_Id == null ||
      PaymentCycle_Id == undefined
    ) {
      IsValid = 0;
      $("#ddlEntryPaymentCycle").addClass("is-invalid state-invalid");
    }
    if (MilkType_Id == "" || MilkType_Id == null || MilkType_Id == undefined) {
      IsValid = 0;
      $("#ddlEntryMilkType").addClass("is-invalid state-invalid");
    }
    if (
      CollectionShift_Id == "" ||
      CollectionShift_Id == null ||
      CollectionShift_Id == undefined
    ) {
      IsValid = 0;
      $("#ddlEntryCollectionShift").addClass("is-invalid state-invalid");
    }
    if (
      Anamat == "" ||
      Anamat == null ||
      Anamat == undefined ||
      isNaN(Anamat) ||
      parseFloat(Anamat) < 0
    ) {
      IsValid = 0;
      $("#txtEntryAnamat").addClass("is-invalid state-invalid");
    }
    if (
      Freight == "" ||
      Freight == null ||
      Freight == undefined ||
      isNaN(Freight) ||
      parseFloat(Freight) < 0
    ) {
      IsValid = 0;
      $("#txtEntryFreight").addClass("is-invalid state-invalid");
    }
    if (Anamat_TDS == "" || Anamat_TDS == null || Anamat_TDS == undefined) {
      IsValid = 0;
      $("#ddlEntryAnamatTDS").addClass("is-invalid state-invalid");
    }
    if (Freight_TDS == "" || Freight_TDS == null || Freight_TDS == undefined) {
      IsValid = 0;
      $("#ddlEntryFreightTDS").addClass("is-invalid state-invalid");
    }

    if (
      Rebate == "" ||
      Rebate == null ||
      Rebate == undefined ||
      isNaN(Rebate) ||
      parseFloat(Rebate) < 0
    ) {
      IsValid = 0;
      $("#txtEntryRebate").addClass("is-invalid state-invalid");
    }
  }

  if (
    FSSAILicenseNo == "" ||
    FSSAILicenseNo == null ||
    FSSAILicenseNo == undefined ||
    Is_Valid_FSSAINO(FSSAILicenseNo) == false
  ) {
    IsValid = 0;
    $("#txtEntryFSSAILicenseNo").addClass("is-invalid state-invalid");
  }
  if (
    FSSAILicenceValidity == "" ||
    FSSAILicenceValidity == null ||
    FSSAILicenceValidity == undefined
  ) {
    IsValid = 0;
    $("#txtEntryFSSAILicenseValidity").addClass("is-invalid state-invalid");
  }
  if (Latitude == "" || Latitude == null || Latitude == undefined) {
    IsValid = 0;
    $("#txtEntryLatitude").addClass("is-invalid state-invalid");
  }
  if (Longitude == "" || Longitude == null || Longitude == undefined) {
    IsValid = 0;
    $("#txtEntryLongitude").addClass("is-invalid state-invalid");
  }

  if (
    PaymentType_Id == "" ||
    PaymentType_Id == null ||
    PaymentType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryPaymentType").addClass("is-invalid state-invalid");
  }

  MilkType_Id = MilkType_Id.split(",").filter(removeBlankValues).toString();
  CollectionShift_Id = CollectionShift_Id.split(",")
    .filter(removeBlankValues)
    .toString();

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveMCC";
    var Method_Name = "Create";
    var MCC_Id = "";

    var Alternate = 0;
    if ($("#chkForAllowAlternateDispatch").prop("checked")) {
      Alternate = 1;
    }

    var ManualQuantity = 0;
    if ($("#chkForAllowManualQuantity").prop("checked")) {
      ManualQuantity = 1;
    }

    var ManualQuality = 0;
    if ($("#chkForAllowManualQuality").prop("checked")) {
      ManualQuality = 1;
    }

    var ManualShiftEnd = 0;
    if ($("#chkForAllowManualShiftEnd").prop("checked")) {
      ManualShiftEnd = 1;
    }

    if (Action_Name == "Edit") {
      Method_Name = "Update";
      MCC_Id = $("#lblEntryId").html();
    }
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Masters/MCC";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      is_manualweight: ManualQuantity,
      is_manualquality: ManualQuality,
      is_manualshiftend: ManualShiftEnd,
      alternate: Alternate,
      mcc_id: MCC_Id,

      mcc_code: MCCCode,
      mcc_name: MCCName,
      mcccategory_id: Category_Id,
      mcctype_id: Type_Id,
      agent_id: Agent_Id,
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

      mustertype_id: MusterType_Id,
      mccworktype_id: MCCWorkType_Id,
      paymentcycle_id: PaymentCycle_Id,
      milktype_id: MilkType_Id,
      collectionshift_id: CollectionShift_Id,

      fssailicense_no: FSSAILicenseNo,
      fssailicensevalidity_on: FSSAILicenceValidity,
      latitude: Latitude,
      longitude: Longitude,
      paymenttype_id: PaymentType_Id,
      pan_no: Pan_No,
      // aadhar_no: Aadhar_No,
      anamat: Anamat,
      freight: Freight,
      anamat_tds: Anamat_TDS,
      freight_tds: Freight_TDS,
      rebate: Rebate,
      withholdingtaxtype_id: WithholdingTaxType_Id,
      plant_code:Plant_Code
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
          Hide_Loader();

          if (result[0].result_id == 1) {
            Show_Success_Toastr("MCC details saved successfully");
          }
          if (result[0].result_id == 2) {
            Show_Error_Toastr("Error : " + result[0].result_description);
            ShowEntryError("Error : " + result[0].result_description);
          }

          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          ShowEditEntry(result[0].result_extra_key);
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : MCC details not saved");
      },
    });
  }
  $("#btn_Save").prop("disabled", false);
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
  var MCC_Id = $("#lblEntryId").html();
  // In success do following things
  var Is_Deleted = 1;
  var APIEndPoint = "SaveMCC";
  var url = "/Masters/MCC";
  var reqdata = {
    mcc_id: MCC_Id,
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
        Show_Success_Toastr("MCC details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : MCC details not deleted");
    },
  });
}

function removeBlankValues(SelectedValue) {
  return SelectedValue != "";
}

function OpenModalPaymentSettings(action, paymentsetting_id) {
  $("#lblActionPaymentSettings").html(action);
  $("#lblEntryPaymentSettingsId").html(paymentsetting_id);

  $("#modelEntryPaymentSettings")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  //$("#ddlModalEntryMusterType").val("");
  //$("#ddlModalEntryPaymentCycle").val("");
  //$("#ddlModalEntryMilkType").val([]);
  //$("#ddlModalEntryCollectionShift").val([]);
  $("#txtEntryPaymentSettingsFromDate").val("");

  $("#ddlModalEntryMusterType").select2();
  $("#ddlModalEntryPaymentCycle").select2();
  $("#ddlModalEntryMilkType").select2();
  $("#ddlModalEntryAnamatTDS").select2();
  $("#ddlModalEntryFreightTDS").select2();
  $("#ddlModalEntryCollectionShift").select2();
  if (action == "Add") {
    var url_1 = "/Masters/MCC";
    var Method_Name_1 = "Get_Locked";
    var APIEndPoint_1 = "GetMCC";
    var MCC_Id_1 = $("#lblEntryId").html();

    var reqdata_1 = {
      method_name: Method_Name_1,
      api_end_point: APIEndPoint_1,
      mcc_id: MCC_Id_1,
    };
    $.ajax({
      type: "POST",
      url: url_1,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata_1,
      success: function (result) {
        var res = JSON.parse(result);
        if (res[0].is_locked == "1") {
          $("#ddlModalEntryMusterType").prop("disabled", false);
          $("#ddlModalEntryPaymentCycle").prop("disabled", false);
          GetMaster(
            "ddlModalEntryMusterType",
            "Select Muster Type",
            "GetMusterType",
            "",
            ""
          );
          GetMaster(
            "ddlModalEntryPaymentCycle",
            "Select Payment Cycle",
            "GetPaymentCycle",
            "",
            ""
          );
        } else {
          $("#ddlModalEntryMusterType").prop("disabled", true);
          $("#ddlModalEntryPaymentCycle").prop("disabled", true);
          GetMaster(
            "ddlModalEntryMusterType",
            "Select Muster Type",
            "GetMusterType",
            res[0].mustertype_id,
            ""
          );
          GetMaster(
            "ddlModalEntryPaymentCycle",
            "Select Payment Cycle",
            "GetPaymentCycle",
            res[0].paymentcycle_id,
            ""
          );
        }
      },
      error: function () {},
    });

    GetMaster(
      "ddlModalEntryMilkType",
      "Select Milk Type",
      "GetMilkType",
      "",
      ""
    );
    GetMaster(
      "ddlModalEntryAnamatTDS",
      "Select Anamat TDS",
      "GetFMStatus",
      "",
      ""
    );
    GetMaster(
      "ddlModalEntryFreightTDS",
      "Select Freight TDS",
      "GetFMStatus",
      "",
      ""
    );
    // GetMaster(
    //   "ddlModalEntryCollectionShift",
    //   "Select Collection Shift",
    //   "GetMilkCollectionShift",
    //   "",
    //   ""
    // );

    if (
      $("#lblType").html() == "C014002" ||
      $("#lblType").html() == "C014001"
    ) {
      GetMaster(
        "ddlModalEntryCollectionShift",
        "Select Collection Shift",
        "GetMilkCollectionShiftME",
        "",
        ""
      );
    }
    if ($("#lblType").html() == "C014003") {
      GetMaster(
        "ddlModalEntryCollectionShift",
        "Select Collection Shift",
        "GetMilkCollectionShiftAD",
        "",
        ""
      );
    }
  }

  $("#ddlModalEntryMusterType").on("change", function () {
    var m_last3 = $("#ddlModalEntryMusterType").val().slice(-3);
    // // console.log(m_last3);
    $("#ddlModalEntryPaymentCycle > option").each(function () {
      if (this.value.slice(-3) < m_last3) {
        // // console.log(value);
        $(this).prop("disabled", true);
      } else {
        $(this).prop("disabled", false);
      }
    });
  });

  // Setting Date Text Box value depending on the provided date from database

  var url = "/Masters/PaymentSettings";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetPaymentSettings";
  var MCC_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      var date;
      if (res.length === 0) {
        date = new Date(Date.now());
      } else {
        var latest_date = new Date(res[0].applicable_date);
        date = new Date(Date.now()); //.toISOString().slice(0, 16);
        if (latest_date > date) {
          date = latest_date;
        }
      }
      /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

      // next_date = new Date(date);
      // newdate = next_date.toISOString().slice(0, 16);

      var offset = date.getTimezoneOffset();
      date.setMinutes(date.getMinutes() - offset);
      var newdate = date.toISOString().slice(0, 16);

      $("#txtEntryPaymentSettingsFromDate").attr("min", newdate);
      $("#txtEntryPaymentSettingsFromDate").val(newdate);
    },
    error: function () {},
  });
}

function SavePaymentSettingsEntry() {
  // Validation
  var MCC_Id = $("#lblEntryId").html();
  var MusterType_Id = $("#ddlModalEntryMusterType").val();
  var PaymentCycle_Id = $("#ddlModalEntryPaymentCycle").val();
  var MilkType_Id = $("#ddlModalEntryMilkType").val().join();
  var CollectionShift_Id = $("#ddlModalEntryCollectionShift").val().join();
  var ApplicableDate = $("#txtEntryPaymentSettingsFromDate").val();
  var Anamat = $("#txtModalEntryAnamat").val().trim();
  var Freight = $("#txtModalEntryFreight").val().trim();
  var Anamat_TDS = $("#ddlModalEntryAnamatTDS").val();
  var Freight_TDS = $("#ddlModalEntryFreightTDS").val();
  var Rebate = $("#txtModalEntryRebate").val().trim();
  var IsValid = 1;

  MilkType_Id = MilkType_Id.split(",").filter(removeBlankValues).toString();
  CollectionShift_Id = CollectionShift_Id.split(",")
    .filter(removeBlankValues)
    .toString();

  if (MusterType_Id == "") {
    IsValid = 0;
    $("#ddlModalEntryMusterType").addClass("is-invalid state-invalid");
  }
  if (PaymentCycle_Id == "") {
    IsValid = 0;
    $("#ddlModalEntryPaymentCycle").addClass("is-invalid state-invalid");
  }
  if (MilkType_Id == "") {
    IsValid = 0;
    $("#ddlModalEntryMilkType").addClass("is-invalid state-invalid");
  }
  if (CollectionShift_Id == "") {
    IsValid = 0;
    $("#ddlModalEntryCollectionShift").addClass("is-invalid state-invalid");
  }
  if (ApplicableDate == "") {
    IsValid = 0;
    $("#txtEntryPaymentSettingsFromDate").addClass("is-invalid state-invalid");
  }
  if (Anamat == "" || isNaN(Anamat) || parseFloat(Anamat) < 0) {
    IsValid = 0;
    $("#txtModalEntryAnamat").addClass("is-invalid state-invalid");
  }
  if (Freight == "" || isNaN(Freight) || parseFloat(Freight) < 0) {
    IsValid = 0;
    $("#txtModalEntryFreight").addClass("is-invalid state-invalid");
  }
  if (Anamat_TDS == "") {
    IsValid = 0;
    $("#ddlModalEntryAnamatTDS").addClass("is-invalid state-invalid");
  }
  if (Freight_TDS == "") {
    IsValid = 0;
    $("#ddlModalEntryFreightTDS").addClass("is-invalid state-invalid");
  }
  if (Rebate == "" || isNaN(Rebate) || parseFloat(Rebate) < 0) {
    IsValid = 0;
    $("#txtModalEntryRebate").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save_Payment_Settings").prop("disabled", true);
    Show_Loader();
    var APIEndPoint = "SavePaymentSettings";
    var Method_Name = "Create";
    var Version_No = "";
    var Action_Name = $("#lblActionPaymentSettings").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Version_No = $("#lblEntryPaymentSettingsId").html();
    }
    var url = "/Masters/PaymentSettings";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      mcc_id: MCC_Id,
      version_no: Version_No,
      mustertype_id: MusterType_Id,
      paymentcycle_id: PaymentCycle_Id,
      milktype_id: MilkType_Id,
      collectionshift_id: CollectionShift_Id,
      applicable_date: ApplicableDate,
      is_active: 1,
      is_deleted: 0,
      anamat: Anamat,
      freight: Freight,
      anamat_tds: Anamat_TDS,
      freight_tds: Freight_TDS,
      rebate: Rebate,
    };
    // return;

    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          $("#lblEntryPaymentSettingsId").html(result[0].result_extra_key);
          ShowItemSuccess("Payment details saved successfully");
          GetPaymentSettingsList();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        $("#modelEntryPaymentSettings").modal("hide");
        ShowItemError("Error : Payment details not saved");
      },
    });
  }
  $("#modelEntryPaymentSettings").modal("hide");
  $("#btn_Save_Payment_Settings").prop("disabled", false);
}

function GetPaymentSettingsList() {
  var MCC_Id = $("#lblEntryId").html();
  ClearDataTable("tablePaymentSettingsList");
  var APIEndPoint = "GetPaymentSettings";
  var Method_Name = "Get";
  var url = "/Masters/PaymentSettings";
  var reqdata = {
    method_name: Method_Name,
    mcc_id: MCC_Id,
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
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1;
      ApplicableFromDate = [];
      $.each(res, function (data, value) {
        EditFlag = DeleteFlag = value.is_locked;
        ApplicableFromDate.push(value.from_date);
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.mustertype_name + "</td>";
        TableHTML += "<td>" + value.paymentcycle_name + "</td>";
        TableHTML += "<td>" + value.anamat + "</td>";
        TableHTML += "<td>" + value.freight + "</td>";
        TableHTML += "<td>" + value.rebate + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 80px; padding: 8px 5px 8px 5px;">';
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowPaymentSettingsEditEntry(\'' +
            value.version_no +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryPaymentSettings(\'' +
            value.version_no +
            "')\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntryPaymentSettings").html(TableHTML);
      SetDataTable("tablePaymentSettingsList", [9], "Payment Settings");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });

  return;
}

// function ShowPaymentSettingsEditEntry(Version_No) {
//   $("#ddlModalEntryMusterType").prop("disabled", false);
//   $("#ddlModalEntryPaymentCycle").prop("disabled", false);
//   $("#ddlModalEntryMusterType").val("");
//   $("#ddlModalEntryPaymentCycle").val("");
//   // $("#ddlModalEntryMilkType").val([]);
//   // $("#ddlModalEntryCollectionShift").val([]);
//   $("#txtEntryPaymentSettingsFromDate").val("");

//   $("#lblEntryPaymentSettingsId").html(Version_No);
//   $("#lblActionPaymentSettings").html("Edit");
//   OpenModalPaymentSettings("Edit", Version_No);
//   var APIEndPoint = "GetPaymentSettings";
//   MCC_Id = $("#lblEntryId").html();
//   Method_Name = "Get_One";
//   var url = "/Masters/PaymentSettings";
//   var reqdata = {
//     method_name: Method_Name,
//     mcc_id: MCC_Id,
//     version_no: Version_No,
//     api_end_point: APIEndPoint,
//   };

//   $.ajax({
//     type: "POST",
//     url: url,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata,
//     success: function (result) {
//       var res = JSON.parse(result);
//       // console.log(res);
//       // debugger;

//       GetMaster(
//         "ddlModalEntryMusterType",
//         "Select Muster Type",
//         "GetMusterType",
//         res[0].mustertype_id,
//         ""
//       );
//       GetMaster(
//         "ddlModalEntryPaymentCycle",
//         "Select Payment Cycle",
//         "GetPaymentCycle",
//         res[0].paymentcycle_id,
//         ""
//       );
//       GetMaster(
//         "ddlModalEntryMilkType",
//         "Select Milk Type",
//         "GetMilkType",
//         res[0].milktype_id,
//         ""
//       );
//       GetMaster(
//         "ddlModalEntryAnamatTDS",
//         "Select Anamat TDS",
//         "GetFMStatus",
//         res[0].anamat_tds,
//         ""
//       );
//       GetMaster(
//         "ddlModalEntryFreightTDS",
//         "Select Freight TDS",
//         "GetFMStatus",
//         res[0].freight_tds,
//         ""
//       );
//       // GetMaster(
//       //   "ddlModalEntryCollectionShift",
//       //   "Select Collection Shift",
//       //   "GetMilkCollectionShift",
//       //   res[0].collectionshift_id,
//       //   ""
//       // );
//       if (
//         $("#lblType").html() == "C014002" ||
//         $("#lblType").html() == "C014001"
//       ) {
//         GetMaster(
//           "ddlModalEntryCollectionShift",
//           "Select Collection Shift",
//           "GetMilkCollectionShiftME",
//           res[0].collectionshift_id,
//           ""
//         );
//       }
//       if ($("#lblType").html() == "C014003") {
//         GetMaster(
//           "ddlModalEntryCollectionShift",
//           "Select Collection Shift",
//           "GetMilkCollectionShiftAD",
//           res[0].collectionshift_id,
//           ""
//         );
//       }
//       $("#txtModalEntryAnamat").val(res[0].anamat);
//       $("#txtModalEntryFreight").val(res[0].freight);
//       $("#txtModalEntryRebate").val(res[0].rebate);
//       //$("#txtEntryPaymentSettingsFromDate").val("2023-08-25T13:09");
//       $("#txtEntryPaymentSettingsFromDate").val(res[0].applicable_date);
//       $("#modelEntryPaymentSettings")
//         .modal({
//           backdrop: "static",
//         })
//         .modal("show");
//       //ShowItemSuccess("Payment Settings details saved successfully");
//     },
//     error: function () {
//       //$('#modelEntryPaymentSettings').modal('hide');
//       ShowItemError("Error in fetching details from server");
//     },
//   });
//   $("#btn_Save_Payment_Settings").prop("disabled", false);
// }

function ShowPaymentSettingsEditEntry(Version_No) {
  // $("#ddlModalEntryMusterType").prop("disabled", false);
  // $("#ddlModalEntryPaymentCycle").prop("disabled", false);

  var url_1 = "/Masters/MCC";
  var Method_Name_1 = "Get_Locked";
  var APIEndPoint_1 = "GetMCC";
  var MCC_Id_1 = $("#lblEntryId").html();

  var reqdata_1 = {
    method_name: Method_Name_1,
    api_end_point: APIEndPoint_1,
    mcc_id: MCC_Id_1,
  };

  $.ajax({
    type: "POST",
    url: url_1,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata_1,
    success: function (result) {
      var res = JSON.parse(result);
      var isLocked = res[0].is_locked;
      var musterTypeId = res[0].mustertype_id;
      var paymentCycleId = res[0].paymentcycle_id;

      // After successfully retrieving data, initiate the second AJAX call
      $("#ddlModalEntryMusterType").val("");
      $("#ddlModalEntryPaymentCycle").val("");
      // $("#ddlModalEntryMilkType").val([]);
      // $("#ddlModalEntryCollectionShift").val([]);
      $("#txtEntryPaymentSettingsFromDate").val("");

      $("#lblEntryPaymentSettingsId").html(Version_No);
      $("#lblActionPaymentSettings").html("Edit");
      OpenModalPaymentSettings("Edit", Version_No);
      var APIEndPoint = "GetPaymentSettings";
      MCC_Id = $("#lblEntryId").html();
      Method_Name = "Get_One";
      var url = "/Masters/PaymentSettings";
      var reqdata = {
        method_name: Method_Name,
        mcc_id: MCC_Id,
        version_no: Version_No,
        api_end_point: APIEndPoint,
      };

      $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
          var res = JSON.parse(result);
          // Use the values retrieved from the first AJAX call

          if (isLocked == "1") {
            $("#ddlModalEntryMusterType").prop("disabled", false);
            $("#ddlModalEntryPaymentCycle").prop("disabled", false);
            GetMaster(
              "ddlModalEntryMusterType",
              "Select Muster Type",
              "GetMusterType",
              res[0].mustertype_id,
              ""
            );
            GetMaster(
              "ddlModalEntryPaymentCycle",
              "Select Payment Cycle",
              "GetPaymentCycle",
              res[0].paymentcycle_id,
              ""
            );
          } else {
            $("#ddlModalEntryMusterType").prop("disabled", true);
            $("#ddlModalEntryPaymentCycle").prop("disabled", true);
            GetMaster(
              "ddlModalEntryMusterType",
              "Select Muster Type",
              "GetMusterType",
              musterTypeId,
              ""
            );
            GetMaster(
              "ddlModalEntryPaymentCycle",
              "Select Payment Cycle",
              "GetPaymentCycle",
              paymentCycleId,
              ""
            );
          }

          GetMaster(
            "ddlModalEntryMilkType",
            "Select Milk Type",
            "GetMilkType",
            res[0].milktype_id,
            ""
          );
          GetMaster(
            "ddlModalEntryAnamatTDS",
            "Select Anamat TDS",
            "GetFMStatus",
            res[0].anamat_tds,
            ""
          );
          GetMaster(
            "ddlModalEntryFreightTDS",
            "Select Freight TDS",
            "GetFMStatus",
            res[0].freight_tds,
            ""
          );
          // GetMaster(
          //   "ddlModalEntryCollectionShift",
          //   "Select Collection Shift",
          //   "GetMilkCollectionShift",
          //   res[0].collectionshift_id,
          //   ""
          // );
          if (
            $("#lblType").html() == "C014002" ||
            $("#lblType").html() == "C014001"
          ) {
            GetMaster(
              "ddlModalEntryCollectionShift",
              "Select Collection Shift",
              "GetMilkCollectionShiftME",
              res[0].collectionshift_id,
              ""
            );
          }
          if ($("#lblType").html() == "C014003") {
            GetMaster(
              "ddlModalEntryCollectionShift",
              "Select Collection Shift",
              "GetMilkCollectionShiftAD",
              res[0].collectionshift_id,
              ""
            );
          }
          $("#txtModalEntryAnamat").val(res[0].anamat);
          $("#txtModalEntryFreight").val(res[0].freight);
          $("#txtModalEntryRebate").val(res[0].rebate);
          //$("#txtEntryPaymentSettingsFromDate").val("2023-08-25T13:09");
          $("#txtEntryPaymentSettingsFromDate").val(res[0].applicable_date);
          $("#modelEntryPaymentSettings")
            .modal({
              backdrop: "static",
            })
            .modal("show");
          //ShowItemSuccess("Payment Settings details saved successfully");
        },
        error: function () {
          //$('#modelEntryPaymentSettings').modal('hide');
          ShowItemError("Error in fetching details from server");
        },
      });
      $("#btn_Save_Payment_Settings").prop("disabled", false);
    },
    error: function () {
      ShowItemError("Error in fetching locked status");
    },
  });
}

function SaveDeleteEntryPaymentSettings(Version_No) {
  var APIEndPoint = "SavePaymentSettings";
  var MCC_Id = $("#lblEntryId").html();
  var url = "/Masters/PaymentSettings";
  var reqdata = {
    version_no: Version_No,
    method_name: "Delete",
    mcc_id: MCC_Id,
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
        ShowItemSuccess("Payment Settings details deleted successfully");
        GetPaymentSettingsList();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : Payment Settings details not deleted");
    },
  });
}

function ResetInputFields() {
  $(".modal input, select").val("");
}
