$(document).ready(function () {
  $("#ddlSearchMilkType").select2();
  GetMaster("ddlSearchMilkType", "Select Milk Type", "GetMilkType", "", "");

  $("#ddlSearchMPPIType").select2();
  GetMaster("ddlSearchMPPIType", "Select MPPI Type", "GetMPPIType", "", "");

  // GetMaster("ddlSearchBranch", "All Branches", "GetBranch", "", "");
});

// Get all the MCC Commission data entries and display it in the table on the MCC Commission page
function GetSearchList(e) {
  var MPPIName = "%" + $("#txtSearchMPPIName").val() + "%";
  var MilkType_Id = "%" + $("#ddlSearchMilkType").val() + "%";
  var MPPIType_Id = $("#ddlSearchMPPIType").val();

  var IsValid = 1;
  if (MPPIType_Id == "" || MPPIType_Id == undefined || MPPIType_Id == null) {
    IsValid = 0;
    $("#ddlSearchMPPIType").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    // ShowEntryError("Invalid Input(s). Can't be saved.");
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    $("#btn_Search").prop("disabled", true);
    var APIEndPoint = "GetMCCCommission";
    var Method_Name = "Get";
    var url = "/Rate/MCCCommission";
    var reqdata = {
      method_name: Method_Name,
      mppi_name: MPPIName,
      milktype_id: MilkType_Id,
      mppitype_id: MPPIType_Id,
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
          } else if (value.is_active == 1) {
            Active_Status = "Active";
          }
          if (value.is_lived == 0) {
            Active_Status = "Draft";
          }
          TableHTML += "<tr>";
          TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
          TableHTML += "<td>" + value.mppi_name + "</td>";
          TableHTML += "<td>" + value.milktype_name + "</td>";
          // TableHTML += "<td>" + value.milkstatus_name + "</td>";
          TableHTML += "<td>" + value.uom_name + "</td>";
          // TableHTML += "<td>" + value.collectionshift_name + "</td>";
          // TableHTML += "<td>" + value.mcctype_name + "</td>";
          // TableHTML += "<td>" + value.mccworktype_name + "</td>";
          TableHTML += "<td>" + Active_Status + "</td>";
          TableHTML +=
            '<td class="text-right" style="width: 100px; padding: 8px 5px 8px 5px;">';
          if (EditFlag == 1) {
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
              value.mppi_id +
              "', false);\">";
            TableHTML += '<i class="fa fa-pencil"></i>';
            TableHTML += "</a>";
          }
          // if (Active_Status == "Active") {
          //   TableHTML +=
          //     '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="AssignMCC" onclick="ShowEditEntry(\'' +
          //     value.mppi_id +
          //     "', true);\">";
          //   TableHTML += '<i class="fa fa-sitemap"></i>';
          //   TableHTML += "</a>";
          // }
          if (Active_Status == "Draft") {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntry(\'' +
              value.mppi_id +
              "');\">";
            TableHTML += '<i class="fa fa-trash"></i>';
            TableHTML += "</a>";
          }
          TableHTML += "</td>";
          TableHTML += "</tr>";
        });
        ClearDataTable("tableSearch");
        $("#tableData").html(TableHTML);
        SetDataTable("tableSearch", [5], "MCC Commission");
      },
      error: function (result) {
        Show_Error_Toastr(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
    $("#btn_Search").prop("disabled", false);
    return;
  }
}

// Initialize Data like dropdowns and enable user to add new data
function ShowAddEntry() {
  ShowContentDiv("Rate", "MCCCommissionAdd", "", function () {
    // // console.log(1);
    // Initialization Code
    $("#ddlEntryMilkType").select2();
    $("#ddlEntryMilkStatus").select2();
    $("#ddlEntryBaseUnit").select2();
    // $("#ddlEntryMilkCollectionShift").select2();
    // $("#ddlEntryMCCType").select2();
    // $("#ddlEntryMCCWorkType").select2();
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", "", "");
    GetMaster(
      "ddlEntryMilkStatus",
      "Select Milk Status",
      "GetMilkStatus",
      "C016001",
      ""
    );
    GetMaster("ddlEntryBaseUnit", "Select Base Unit", "GetUOM", "C019001", "");
    // GetMaster(
    //   "ddlEntryMilkCollectionShift",
    //   "Select Shift",
    //   "GetMilkCollectionShift",
    //   "",
    //   ""
    // );
    // GetMaster("ddlEntryMCCType", "Select MCC Type", "GetMCCType", "", "");
    // GetMaster(
    //   "ddlEntryMCCWorkType",
    //   "Select MCC Work Type",
    //   "GetMCCWorkType",
    //   "",
    //   ""
    // );

    $("#divTabs").hide();
    $("#divMCC").hide();
    $("#divFooterDelete").hide();

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

// To edit, Set values of all the input fields
function ShowEditEntry(MPPI_Id, is_mcc) {
  ShowContentDiv("Rate", "MCCCommissionEdit", "", function () {
    // Initialization Code
    $("#ddlEntryMilkType").select2();
    $("#ddlEntryMilkStatus").select2();
    $("#ddlEntryBaseUnit").select2();
    // $("#ddlEntryMilkCollectionShift").select2();
    $("#ddlEntryMCCType").select2();
    $("#ddlEntryMCCWorkType").select2();

    $("#modelEntryMCCCommission").on("hidden.bs.modal", function (e) {
      $("#txtEntryMinimumQuantity").val("");
      $("#txtEntryMaximumQuantity").val("");
      $("#txtEntryBaseRate").val("");
      $("#txtEntryMinimumFat").val("");
      $("#txtEntryMaximumFat").val("");
      $("#txtEntryMinimumSNF").val("");
      $("#txtEntryMaximumFat").val("");
      $("#txtEntryMinimumProtein").val("");
      $("#txtEntryMaximumProtein").val("");
      $("#txtEntryMinimumAsh").val("");
      $("#txtEntryMaximumAsh").val("");
      // $("#txtEntryServiceCharge").val("");
      // $("#txtEntryApplicableFromDateTime").val("");
    });

    // // console.log(1);
    $("#selectAll").change(function () {
      $(".select-item").prop("checked", $(this).prop("checked"));
    });

    $(document).on("change", ".select-item", function () {
      // console.log(2);
      if (!$(this).prop("checked")) {
        $("#selectAll").prop("checked", false);
      }

      // Check if all .select-item checkboxes are checked
      var allChecked =
        $(".select-item:checked").length === $(".select-item").length;

      // If all checkboxes are checked, set #selectAll to be checked
      $("#selectAll").prop("checked", allChecked);
    });

    $("#lblEntryId").html(MPPI_Id);
    $("#lblAction").html("Edit");

    var APIEndPoint = "GetMCCCommission";
    var Method_Name = "Get_One";
    var url = "/Rate/MCCCommission";
    var reqdata = {
      method_name: Method_Name,
      mppi_id: MPPI_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        // Fill data in input fields

        if (res[0].is_lived == 1) {
          $("#chkEntryLiveStatus").prop({ checked: true, disabled: true });
          /*   $("#ddlEntryMilkType").prop("disabled", "true");
                              $("#ddlEntryMilkStatus").prop("disabled", "true");
                              $("#ddlEntryBaseUnit").prop("disabled", "true");
                              $("#ddlEntryMilkCollectionShift").prop("disabled", "true");
                              */

          $("#ddlEntryMilkType").prop("disabled", "true");
          $("#ddlEntryMilkStatus").prop("disabled", "true");
          $("#ddlEntryBaseUnit").prop("disabled", "true");
          $("#btnAddMPPIItem").hide();
        } else {
          $("#chkEntryLiveStatus").prop({ checked: false, disabled: false });

          $("#ddlEntryMilkType").prop("disabled", "false");
          $("#ddlEntryMilkStatus").prop("disabled", "false");
          $("#ddlEntryBaseUnit").prop("disabled", "false");
          $("#btnAddMPPIItem").show();
        }

        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }
        $("#txtEntryMPPIName").val(res[0].mppi_name);

        GetMaster(
          "ddlEntryMilkType",
          "Select Milk Type",
          "GetMilkType",
          res[0].milktype_id,
          ""
        );
        GetMaster(
          "ddlEntryMilkStatus",
          "Select Milk Status",
          "GetMilkStatus",
          res[0].milkstatus_id,
          ""
        );
        GetMaster(
          "ddlEntryBaseUnit",
          "Select Base Unit",
          "GetUOM",
          res[0].uom_id,
          ""
        );

        // GetMaster(
        //   "ddlEntryMilkCollectionShift",
        //   "Select Shift",
        //   "GetMilkCollectionShift",
        //   res[0].collectionshift_id,
        //   ""
        // );
        // GetMaster(
        //   "ddlEntryMCCType",
        //   "Select MCC Type",
        //   "GetMCCType",
        //   res[0].mcctype_id,
        //   ""
        // );
        // GetMaster(
        //   "ddlEntryMCCWorkType",
        //   "Select MCC Work Type",
        //   "GetMCCWorkType",
        //   res[0].mccworktype_id,
        //   ""
        // );
        // if (is_mcc) {
        //   // assign mcc
        //   $("#divMCC").show();
        //   $("#divTabs").hide();
        //   GetMCCEntryList();
        //   // MCCType_Id = res[0].mcctype_id;
        //   // MCCWorkType_Id = res[0].mccworktype_id;
        // } else {
        // show edit tabs
        $("#divTabs").show();
        $("#divMCC").hide();
        $("#divFooterDelete").show();
        GetMCCCommissionTable();

        // }
      },
      error: function (result) {
        Show_Error_Toastr(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  });
}

// Get all MCC Commission Item entries
function GetMCCCommissionTable() {
  $("#divTabs").show();
  ClearDataTable("tableMCCCommissionList");
  var Method_Name = "Get";
  var APIEndPoint = "GetMCCCommissionItem";
  var url = "/Rate/MCCCommissionItem";
  var MPPI_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    mppi_id: MPPI_Id,
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
      var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());
      var Row_No = 0;
      var Is_Lived = 0;
      if ($("#chkEntryLiveStatus").prop("checked")) {
        Is_Lived = 1;
      }
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.minimumquantity + "</td>";
        TableHTML += "<td>" + value.maximumquantity + "</td>";
        TableHTML += "<td>" + value.baserate + "</td>";
        // TableHTML += "<td>" + value.basefat + "</td>";
        // TableHTML += "<td>" + value.basesnf + "</td>";
        TableHTML += "<td>" + value.minimumfat + "</td>";
        TableHTML += "<td>" + value.maximumfat + "</td>";
        TableHTML += "<td>" + value.minimumsnf + "</td>";
        TableHTML += "<td>" + value.maximumsnf + "</td>";

        TableHTML += "<td>" + value.minimumprotein + "</td>";
        TableHTML += "<td>" + value.maximumprotein + "</td>";
        TableHTML += "<td>" + value.minimumash + "</td>";
        TableHTML += "<td>" + value.maximumash + "</td>";

        // TableHTML += "<td>" + value.servicecharge + "</td>";
        // TableHTML += "<td>" + value.applicable_date + "</td>";
        if (Is_Lived == 1) {
          TableHTML += "<td></td>";
        } else {
          TableHTML +=
            "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
          if (value.is_locked == 0) {
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalMCCCommission(\'Edit\',\'' +
              value.entry_id +
              "');\">";
            TableHTML += '<i class="fa fa-pencil"></i>';
            TableHTML += "</a>";
          }
          if (value.is_locked == 0) {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryItem(\'' +
              value.entry_id +
              "');\">";
            TableHTML += '<i class="fa fa-trash"></i>';
            TableHTML += "</a>";
          }
          TableHTML += "</td>";
        }
        TableHTML += "</tr>";
      });

      $("#tableEntryMCCCommission").html(TableHTML);
      SetDataTable("tableMCCCommissionList", [12], "MCC Commission List");
    },
    error: function () {
      ShowEntryError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

// Create & Update MCC Commission Item entry
function SaveMCCCommissionItem() {
  // Validation
  var MinimumQuantity = $("#txtEntryMinimumQuantity").val().trim();
  var MaximumQuantity = $("#txtEntryMaximumQuantity").val().trim();
  var BaseRate = $("#txtEntryBaseRate").val().trim();
  // var BaseFat = $("#txtEntryBaseFat").val().trim();
  // var BaseSNF = $("#txtEntryBaseSNF").val().trim();
  var MinimumFat = $("#txtEntryMinimumFat").val().trim();
  var MaximumFat = $("#txtEntryMaximumFat").val().trim();
  var MinimumSNF = $("#txtEntryMinimumSNF").val().trim();
  var MaximumSNF = $("#txtEntryMaximumSNF").val().trim();

  var MinimumProtein = $("#txtEntryMinimumProtein").val().trim();
  var MaximumProtein = $("#txtEntryMaximumProtein").val().trim();
  var MinimumAsh = $("#txtEntryMinimumAsh").val().trim();
  var MaximumAsh = $("#txtEntryMaximumAsh").val().trim();
  var MPPIType_Id = $("#ddlSearchMPPIType").val();

  // var SNFIncentive = $("#txtEntrySNFIncentive").val().trim();
  // var FatIncentive = $("#txtEntryFatIncentive").val().trim();
  // var SNFDeduction = $("#txtEntrySNFDeduction").val().trim();
  // var FatDeduction = $("#txtEntryFatDeduction").val();
  // var ServiceCharge = $("#txtEntryServiceCharge").val().trim();
  // var ApplicableDate = $("#txtEntryApplicableFromDateTime").val();
  var MPPI_Id = $("#lblEntryId").html();
  Version_No = $("#lblEntryVersionNo").val();
  var IsValid = 1;
  if (
    MinimumQuantity == "" ||
    isNaN(MinimumQuantity) ||
    MinimumQuantity == undefined ||
    MinimumQuantity == null
    // Is_Positive_Number_Greater_Than_Zero(MinimumQuantity) == false
  ) {
    IsValid = 0;
    $("#txtEntryMinimumQuantity").addClass("is-invalid state-invalid");
  }
  if (
    MaximumQuantity == "" ||
    isNaN(MaximumQuantity) ||
    MaximumQuantity == undefined ||
    MaximumQuantity == null
    // Is_Positive_Number_Greater_Than_Zero(MaximumQuantity) == false
  ) {
    IsValid = 0;
    $("#txtEntryMaximumQuantity").addClass("is-invalid state-invalid");
  }
  if (BaseRate == "" || Is_Valid_Float_Zero(BaseRate) == false) {
    IsValid = 0;
    $("#txtEntryBaseRate").addClass("is-invalid state-invalid");
  }
  // if (BaseFat == "" || Is_Positive_Number_Greater_Than_Zero(BaseFat) == false) {
  //   IsValid = 0;
  //   $("#txtEntryBaseFat").addClass("is-invalid state-invalid");
  // }
  // if (BaseSNF == "" || Is_Positive_Number_Greater_Than_Zero(BaseSNF) == false) {
  //   IsValid = 0;
  //   $("#txtEntryBaseSNF").addClass("is-invalid state-invalid");
  // }
  if (MPPIType_Id == "C047001" || MPPIType_Id == "C047009") {
    if (
      MinimumFat == "" ||
      isNaN(MinimumFat) ||
      MinimumFat == undefined ||
      MinimumFat == null
      // Is_Positive_Number_Greater_Than_Zero(MinimumFat) == false
    ) {
      IsValid = 0;
      $("#txtEntryMinimumFat").addClass("is-invalid state-invalid");
    }
    if (
      MaximumFat == "" ||
      isNaN(MaximumFat) ||
      MaximumFat == undefined ||
      MaximumFat == null
      // Is_Positive_Number_Greater_Than_Zero(MaximumFat) == false
    ) {
      IsValid = 0;
      $("#txtEntryMaximumFat").addClass("is-invalid state-invalid");
    }
    if (
      MinimumSNF == "" ||
      isNaN(MinimumSNF) ||
      MinimumSNF == undefined ||
      MinimumSNF == null
      // Is_Positive_Number_Greater_Than_Zero(MinimumSNF) == false
    ) {
      IsValid = 0;
      $("#txtEntryMinimumSNF").addClass("is-invalid state-invalid");
    }
    if (
      MaximumSNF == "" ||
      isNaN(MaximumSNF) ||
      MaximumSNF == undefined ||
      MaximumSNF == null
      // Is_Positive_Number_Greater_Than_Zero(MaximumSNF) == false
    ) {
      IsValid = 0;
      $("#txtEntryMaximumSNF").addClass("is-invalid state-invalid");
    }
  }

  if (MPPIType_Id == "C047006") {
    if (
      MinimumProtein == "" ||
      isNaN(MinimumProtein) ||
      MinimumProtein == undefined ||
      MinimumProtein == null
      // Is_Positive_Number_Greater_Than_Zero(MinimumProtein) == false
    ) {
      IsValid = 0;
      $("#txtEntryMinimumProtein").addClass("is-invalid state-invalid");
    }
    if (
      MaximumProtein == "" ||
      // Is_Positive_Number_Greater_Than_Zero(MaximumProtein) == false
      isNaN(MaximumProtein) ||
      MaximumProtein == undefined ||
      MaximumProtein == null
    ) {
      IsValid = 0;
      $("#txtEntryMaximumProtein").addClass("is-invalid state-invalid");
    }
  }

  if (MPPIType_Id == "C047007") {
    if (
      MinimumAsh == "" ||
      isNaN(MinimumAsh) ||
      MinimumAsh == undefined ||
      MinimumAsh == null
    ) {
      IsValid = 0;
      $("#txtEntryMinimumAsh").addClass("is-invalid state-invalid");
    }
    if (
      MaximumAsh == "" ||
      // Is_Positive_Number_Greater_Than_Zero(MaximumAsh) == false
      isNaN(MaximumAsh) ||
      MaximumAsh == undefined ||
      MaximumAsh == null
    ) {
      IsValid = 0;
      $("#txtEntryMaximumAsh").addClass("is-invalid state-invalid");
    }
  }

  // if (
  //   SNFIncentive == ""
  //   // ||
  //   // Is_Positive_Number_Greater_Than_Zero(SNFIncentive) == false
  // ) {
  //   IsValid = 0;
  //   $("#txtEntrySNFIncentive").addClass("is-invalid state-invalid");
  // }
  // if (
  //   FatIncentive == ""
  //   // ||
  //   // Is_Positive_Number_Greater_Than_Zero(FatIncentive) == false
  // ) {
  //   IsValid = 0;
  //   $("#txtEntryFatIncentive").addClass("is-invalid state-invalid");
  // }
  // if (
  //   SNFDeduction == "" ||
  //   Is_Positive_Number_Greater_Than_Zero(SNFDeduction) == false
  // ) {
  //   IsValid = 0;
  //   $("#txtEntrySNFDeduction").addClass("is-invalid state-invalid");
  // }
  // if (
  //   FatDeduction == "" ||
  //   Is_Positive_Number_Greater_Than_Zero(FatDeduction) == false
  // ) {
  //   IsValid = 0;
  //   $("#txtEntryFatDeduction").addClass("is-invalid state-invalid");
  // }
  // if (
  //   ServiceCharge == "" ||
  //   Is_Positive_Number_Greater_Than_Zero(ServiceCharge) == false
  // ) {
  //   IsValid = 0;
  //   $("#txtEntryServiceCharge").addClass("is-invalid state-invalid");
  // }
  // if (ApplicableDate == "") {
  //   IsValid = 0;
  //   $("#txtEntryApplicableFromDateTime").addClass("is-invalid state-invalid");
  // }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btnSaveItem").prop("disabled", true);
    var APIEndPoint = "SaveMCCCommissionItem";
    var Method_Name = "Create";
    var Entry_Id = "";
    var Action_Name = $("#lblActionMCCCommission").html();

    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblEntryIdMCCCommission").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MCCCommissionItem";
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      mppi_id: MPPI_Id,
      minimumquantity: MinimumQuantity,
      maximumquantity: MaximumQuantity,
      baserate: BaseRate,
      // applicable_date: ApplicableDate,
      // basefat: BaseFat,
      // basesnf: BaseSNF,
      minimumfat: MinimumFat,
      maximumfat: MaximumFat,
      minimumsnf: MinimumSNF,
      maximumsnf: MaximumSNF,
      // servicecharge: ServiceCharge,
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      // snf_incentive: SNFIncentive,
      // fat_incentive: FatIncentive,
      // snf_deduction: SNFDeduction,
      // fat_deduction: FatDeduction,

      minimumprotein: MinimumProtein,
      maximumprotein: MaximumProtein,
      minimumash: MinimumAsh,
      maximumash: MaximumAsh,
      // servicecharge: Servic
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
          $("#lblActionMCCCommission").html("Edit");
          $("#lblEntryIdMCCCommission").html(result[0].result_extra_key);
          Show_Success_Toastr("MCC Commission details saved successfully");
          // ResetInputFields();
          GetMCCCommissionTable();
        } else {
          Hide_Loader();
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : MCC Commission details not saved");
      },
    });
    $("#modelEntryMCCCommission").modal("hide");
    $("#btnSaveItem").prop("disabled", false);
  }
}

// Show MCC Entry partial View --> Not used anymore
//function ShowMCCEntry(MPPI_Id) {
//    ShowContentDiv('Rate', 'MCCCommissionMCCEntry', '', function () {

//        $("#ddlEntryMilkTypeMCC").select2();
//        $("#ddlEntryMilkStatusMCC").select2();
//        $("#ddlEntryBaseUnitMCC").select2();
//        $("#ddlEntryMCCTypeMCC").select2();
//        $("#ddlEntryMCCWorkTypeMCC").select2();
//        $("#lblEntryIdMCC").html(MPPI_Id);
//        $("#lblActionMCC").html("");

//        GetMaster("ddlEntryMilkTypeMCC", "Select Milk Type", "GetMilkType", "", "");
//        GetMaster("ddlEntryMilkStatusMCC", "Select Milk Status", "GetMilkStatus", "", "");
//        GetMaster("ddlEntryBaseUnitMCC", "Select Base Unit", "GetUOM", "", "");
//        GetMaster("ddlEntryMCCTypeMCC", "Select MCC Type", "GetMCCType", "", "");
//        GetMaster("ddlEntryMCCWorkTypeMCC", "Select MCC Work Type", "GetMCCWorkType", "", "");

//        // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
//    });
//}

// Close the Entry page

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

// Save MCC Commission new entry and Update MCC Commission entry
function SaveEntry() {
  // Data Validation
  var MPPIName = $("#txtEntryMPPIName").val().trim();
  $("#txtEntryMPPIName").val(MPPIName);

  var MilkType_Id = $("#ddlEntryMilkType").val();
  var MilkStatus_Id = $("#ddlEntryMilkStatus").val();
  var BaseUnit_Id = $("#ddlEntryBaseUnit").val();
  var MPPIType_Id = $("#ddlSearchMPPIType").val();
  // var CollectionShift_Id = $("#ddlEntryMilkCollectionShift").val();
  // MCCType_Id = $("#ddlEntryMCCType").val();
  // MCCWorkType_Id = $("#ddlEntryMCCWorkType").val();

  var IsValid = 1;

  if (MPPIName == "") {
    IsValid = 0;
    $("#txtEntryMPPIName").addClass("is-invalid state-invalid");
  }
  if (MilkType_Id == "") {
    IsValid = 0;
    $("#ddlEntryMilkType").addClass("is-invalid state-invalid");
  }
  if (MilkStatus_Id == "") {
    IsValid = 0;
    $("#ddlEntryMilkStatus").addClass("is-invalid state-invalid");
  }
  if (BaseUnit_Id == "") {
    IsValid = 0;
    $("#ddlEntryBaseUnit").addClass("is-invalid state-invalid");
  }
  // if (CollectionShift_Id == "") {
  //   IsValid = 0;
  //   $("#ddlEntryMilkCollectionShift").addClass("is-invalid state-invalid");
  // }
  // if (MCCType_Id == "") {
  //   IsValid = 0;
  //   $("#ddlEntryMCCType").addClass("is-invalid state-invalid");
  // }
  // if (MCCWorkType_Id == "") {
  //   IsValid = 0;
  //   $("#ddlEntryMCCWorkType").addClass("is-invalid state-invalid");
  // }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Create";
    var MPPI_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      MPPI_Id = $("#lblEntryId").html();
    }
    var Is_Lived = 0;
    if ($("#chkEntryLiveStatus").prop("checked")) {
      Is_Lived = 1;
    }
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var APIEndPoint = "SaveMCCCommission";
    var url = "/Rate/MCCCommission";
    var reqdata = {
      is_lived: Is_Lived,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      mppi_id: MPPI_Id,
      mppi_name: MPPIName,
      milktype_id: MilkType_Id,
      milkstatus_id: MilkStatus_Id,
      uom_id: BaseUnit_Id,
      // mcctype_id: MCCType_Id,
      // mccworktype_id: MCCWorkType_Id,
      // collectionshift_id: CollectionShift_Id,
      is_lived: Is_Lived,
      api_end_point: APIEndPoint,
      mppitype_id: MPPIType_Id,
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
          Hide_Loader();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          ShowEntrySuccess("MCC Commission details saved successfully");
          if (Is_Lived == 1) {
            $("#chkEntryLiveStatus").prop({ checked: true, disabled: true });
            /*$("#ddlentrymilktype").prop("disabled", "true");
                                    $("#ddlentrymilkstatus").prop("disabled", "true");
                                    $("#ddlentryuom").prop("disabled", "true");
                                    $("#ddlentrymilkcollectionshift").prop("disabled", "true");
                                    */
          }
          if ($("#divMCC").is(":hidden")) {
            $("#divTabs").show();
          }
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : MCC Commission details not saved");
      },
    });
    $("#btn_Save").prop("disabled", false);
  }
  return;
}

// Show message before deleting MCC Commission entry
function ShowDeleteEntry(MPPI_Id) {
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
        SaveDeleteEntry(MPPI_Id);
      }
    }
  );
}

// Delete MCC Commission entry
function SaveDeleteEntry(MPPI_Id) {
  // Write code to delete
  if (MPPI_Id == "") {
    MPPI_Id = $("#lblEntryId").html();
  }

  var APIEndPoint = "SaveMCCCommission";
  var url = "/Rate/MCCCommission";
  var reqdata = {
    method_name: "Delete",
    mppi_id: MPPI_Id,
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
        Show_Success_Toastr("MCC Commission details deleted successfully");
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : MCC Commission details not deleted");
    },
  });
}

// Open modal to add and edit MCC Commission Item data
function OpenModalMCCCommission(action, entry_id) {
  $("#txtEntryMinimumQuantity").val("");
  $("#txtEntryMaximumQuantity").val("");
  $("#txtEntryBaseRate").val("");
  $("#txtEntryMinimumFat").val("");
  $("#txtEntryMaximumFat").val("");
  $("#txtEntryMinimumSNF").val("");
  $("#txtEntryMaximumFat").val("");
  $("#txtEntryMinimumProtein").val("");
  $("#txtEntryMaximumProtein").val("");
  $("#txtEntryMinimumAsh").val("");
  $("#txtEntryMaximumAsh").val("");
  var MPPIType_Id = $("#ddlSearchMPPIType").val();

  if (MPPIType_Id == "C047001" || MPPIType_Id == "C047009") {
    $("#divEntryMinimumFat").show();
    $("#divEntryMaximumFat").show();
    $("#divEntryMinimumSNF").show();
    $("#divEntryMaximumSNF").show();

    $("#divEntryMinimumProtein").hide();
    $("#divEntryMaximumProtein").hide();
    $("#divEntryMinimumAsh").hide();
    $("#divEntryMaximumAsh").hide();
  } else if (MPPIType_Id == "C047006") {
    $("#divEntryMinimumFat").hide();
    $("#divEntryMaximumFat").hide();
    $("#divEntryMinimumSNF").hide();
    $("#divEntryMaximumSNF").hide();

    $("#divEntryMinimumProtein").show();
    $("#divEntryMaximumProtein").show();
    $("#divEntryMinimumAsh").hide();
    $("#divEntryMaximumAsh").hide();
  } else if (MPPIType_Id == "C047007") {
    $("#divEntryMinimumFat").hide();
    $("#divEntryMaximumFat").hide();
    $("#divEntryMinimumSNF").hide();
    $("#divEntryMaximumSNF").hide();

    $("#divEntryMinimumProtein").hide();
    $("#divEntryMaximumProtein").hide();
    $("#divEntryMinimumAsh").show();
    $("#divEntryMaximumAsh").show();
  }

  $("#modelEntryMCCCommission")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblActionMCCCommission").html(action);

  if (action == "Add") {
    // set date calander and restrict past values
    // SetDate("txtEntryApplicableFromDateTime", true);
    $("#txtEntryApplicableFromDateTime").prop("disabled", false);
    $("#AddEditMCCCommission").text("Add MCC Commission");
    $("#lblEntryVersionNo").html("");
    $("#lblEntryIdMCCCommission").html("");
  } else if (action == "Edit") {
    $("#AddEditMCCCommission").text("Edit MCC Commission");
    var APIEndPoint = "GetMCCCommissionItem";
    var url = "/Rate/MCCCommissionItem";
    var Method_Name = "Get_One";
    var Entry_Id = entry_id;
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        $("#txtEntryMinimumQuantity").val(res[0].minimumquantity);
        $("#txtEntryMaximumQuantity").val(res[0].maximumquantity);
        $("#txtEntryBaseRate").val(res[0].baserate);
        // $("#txtEntryBaseFat").val(res[0].basefat);
        // $("#txtEntryBaseSNF").val(res[0].basesnf);
        $("#txtEntryMinimumFat").val(res[0].minimumfat);
        $("#txtEntryMaximumFat").val(res[0].maximumfat);
        $("#txtEntryMaximumSNF").val(res[0].maximumsnf);
        $("#txtEntryMinimumSNF").val(res[0].minimumsnf);
        // $("#txtEntrySNFIncentive").val(res[0].snf_incentive);
        // $("#txtEntryFatIncentive").val(res[0].fat_incentive);
        // $("#txtEntrySNFDeduction").val(res[0].snf_deduction);
        // $("#txtEntryFatDeduction").val(res[0].fat_deduction);
        // $("#txtEntryServiceCharge").val(res[0].servicecharge);
        // $("#txtEntryApplicableFromDateTime").val(res[0].applicable_date);

        $("#txtEntryMinimumProtein").val(res[0].minimumprotein);
        $("#txtEntryMaximumProtein").val(res[0].maximumprotein);
        $("#txtEntryMinimumAsh").val(res[0].minimumash);
        $("#txtEntryMaximumAsh").val(res[0].maximumash);

        $("#txtEntryApplicableFromDateTime").prop("disabled", true);
        $("#lblEntryIdMCCCommission").html(entry_id);
      },
      error: function () {
        ShowItemError(
          "Error in fetching details from server.",
          res[0].result_description
        );
      },
    });
  }
}

// Reset values on hiding the modal
$("#modelEntryMCCCommission").on("hidden.bs.modal", function (e) {
  $("#lblActionMCCCommission").html("");
  $("#AddEditMCCCommission").text("");
  // ResetInputFields();
});

// Open Assign MCC modal to add new entries and assign MCC
// function OpenModalMCC(action, version_no, set_date) {
//   // ResetInputFields();
//   // ClearDataTable("tableEntryModelMCC");
//   $("#lblAssignMCCVersion").html(version_no);
//   $("#modelEntryMCCCommissionMCC")
//     .modal({
//       backdrop: "static",
//     })
//     .modal("show");
//   var MPPI_Id = $("#lblEntryId").html();
//   $("#lblActionMCCCommissionMCC").html(action);
//   $("#txtEntryApplicableDateMCC").val("");

//   SetDate("txtEntryApplicableDateMCC", false);

//   //var MCCType_Id = $("#ddlEntryMCCType").val();
//   //var MCCWorkType_Id = $("#ddlEntryMCCWorkType").val();

//   if (action == "Add") {
//     $("#AddEditMCCCommissionMCC").text("Assign MCC");
//     $("#lblActionMCCCommissionMCC").html(action);
//     $("#txtEntryApplicableDateMCC").prop("disabled", false);
//     // Get vales for the MCC input table (MCC_CODE, MCC_NAME)
//     ClearDataTable("tableAssignMCCEntryModal");
//     var APIEndPoint = "GetMCCCommissionMCC";
//     var Method_Name = "Get_MCC";
//     var url = "/Rate/MCCCommissionMCC";
//     var reqdata = {
//       method_name: Method_Name,
//       api_end_point: APIEndPoint,
//       mcctype_id: MCCType_Id,
//       mccworktype_id: MCCWorkType_Id,
//       search_text: "%%",
//     };
//     $.ajax({
//       type: "POST",
//       url: url,
//       contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//       data: reqdata,
//       success: function (result) {
//         var res = JSON.parse(result);

//         // Fill data in table
//         var TableHTML = "";
//         $.each(res, function (data, value) {
//           // TableHTML += "<tr>";
//           // TableHTML += "<td>" + (data + 1) + "</td>";
//           // TableHTML +=
//           //   '<td style="width: 10px; padding: 0px; margin-bottom:0px; text-align:center; margin-left:7px;">';
//           // TableHTML +=
//           //   '<label class="custom-control custom-checkbox" style="padding:0px; margin: 0px;text-align: center;">';
//           // TableHTML +=
//           //   '<input type="checkbox" class="custom-control-input" value="' +
//           //   value.mcc_id +
//           //   '"';
//           // TableHTML +=
//           //   'style="vertical-align:sub; text-align: center; margin:auto; padding: auto;">';
//           // TableHTML +=
//           //   '<span class="custom-control-label text-dark"></span></label></td>';
//           // TableHTML +=
//           //   '<td style="width: 100px; padding: 2px; margin-bottom:0px;">' +
//           //   value.mcc_code +
//           //   "</td>";
//           // TableHTML +=
//           //   '<td style="padding: 2px; margin-bottom:0px;">' +
//           //   value.mcc_name +
//           //   "</td>";
//           TableHTML += "<tr>";
//           TableHTML += '<td style="width: 20px;">';
//           TableHTML += '<label class="custom-control custom-checkbox ">';
//           TableHTML +=
//             '<input type="checkbox" class="custom-control-input" value="' +
//             value.mcc_id +
//             '"';
//           TableHTML += 'style="vertical-align:sub; text-align: center;">';
//           TableHTML +=
//             '<span class="custom-control-label text-dark"></span></label></td>';
//           TableHTML += "<td>" + value.mcc_code + "</td>";
//           TableHTML += "<td>" + value.mcc_name + "</td>";
//           TableHTML += "<td>" + value.taluka_name + "</td>";
//           TableHTML += "<td>" + value.village_name + "</td>";
//           TableHTML += "<td hidden></td>";
//           //TableHTML += '<td style="padding: 2px; margin-bottom:0px;" hidden></td>';
//         });

//         $("#tableEntryModelMCC").html(TableHTML);
//         SetDataTable("tableAssignMCCEntryModal", [5], "MCC Commission MCC");
//         $("#divAssignedMCCFooter").show();
//         $("#thAssignedMCCCheckbox").show();
//       },
//       error: function (result) {
//         ShowItemError(
//           "Error in fetching details from server.",
//           result[0].result_description
//         );
//       },
//     });
//   }
//   // Open Modal in Edit mode, set all values
//   else if (action == "Edit" || action == "View") {
//     $("#lblActionMCCCommissionMCC").html(action);
//     $("#lblAssignMCCVersion").html(version_no);

//     $("#AddEditMCCCommissionMCC").text("View Assigned MCC");

//     $("#txtEntryApplicableDateMCC").val(set_date);
//     $("#txtEntryApplicableDateMCC").prop("disabled", false);

//     var disabled = "";
//     if (action == "View") {
//       disabled = "disabled";
//     }

//     ClearDataTable("tableAssignMCCEntryModal");

//     var APIEndPoint = "GetMCCCommissionMCC";
//     var Method_Name = "Get_One";
//     var url = "/Rate/MCCCommissionMCC";
//     var reqdata = {
//       method_name: Method_Name,
//       mppi_id: MPPI_Id,
//       version_no: version_no,
//       api_end_point: APIEndPoint,
//       mcctype_id: MCCType_Id,
//       mccworktype_id: MCCWorkType_Id,
//       search_text: "%%",
//     };
//     // console.log(reqdata);
//     $.ajax({
//       type: "POST",
//       url: url,
//       contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//       data: reqdata,
//       success: function (result) {
//         var res = JSON.parse(result);
//         // console.log(res);
//         // Fill data in table
//         var TableHTML = "";
//         var RowNum = 0;
//         $.each(res, function (data, value) {
//           var checked = "";
//           if (value.is_locked == 1) {
//             checked = "checked";
//           }
//           if (value.is_locked == 0 && action == "View") {
//             // don't print and jump to next value
//             return true;
//           }
//           // RowNum += 1;
//           // TableHTML += "<tr>";

//           // TableHTML += "<td>" + RowNum + "</td>";
//           // TableHTML +=
//           //   '<td style="width: 10px; padding: 0px 0px 0px 5px; margin-bottom:0px; text-align:center; margin-left:7px;">';
//           // TableHTML +=
//           //   '<label class="custom-control custom-checkbox" style="padding:0px; margin: 0px;text-align: center;">';
//           // TableHTML +=
//           //   '<input type="checkbox" class="custom-control-input" value="' +
//           //   value.mcc_id +
//           //   '"';
//           // TableHTML +=
//           //   'style="vertical-align:sub; text-align: center; margin:0px;" ' +
//           //   checked +
//           //   " " +
//           //   disabled +
//           //   ">";
//           // TableHTML +=
//           //   '<span class="custom-control-label text-dark"></span></label></td>';
//           // TableHTML += "<td>" + value.mcc_code + "</td>";
//           // TableHTML += "<td>" + value.mcc_name + "</td>";
//           // data;
//           TableHTML += "<tr>";

//           TableHTML += '<td style="width: 20px;" hidden>';
//           TableHTML += '<label class="custom-control custom-checkbox ">';

//           TableHTML +=
//             '<input type="checkbox" class="custom-control-input" value="' +
//             value.mcc_id +
//             '"';
//           TableHTML +=
//             'style="vertical-align:sub; text-align: center;" checked disabled>';

//           TableHTML +=
//             '<span class="custom-control-label text-dark"></span></label></td>';
//           TableHTML += "<td>" + value.mcc_code + "</td>";
//           TableHTML += "<td>" + value.mcc_name + "</td>";
//           TableHTML += "<td>" + value.taluka_name + "</td>";
//           TableHTML += "<td>" + value.village_name + "</td>";
//           TableHTML += "<td hidden></td>";
//           TableHTML += "</tr>";
//         });

//         $("#tableEntryModelMCC").html(TableHTML);
//         SetDataTable("tableAssignMCCEntryModal", [5], "MCC Commission");
//         $("#divAssignedMCCFooter").hide();
//         $("#thAssignedMCCCheckbox").hide();
//       },
//       error: function (result) {
//         Show_Error_Toastr(
//           "Error in fetching details from server.",
//           result[0].result_description
//         );
//       },
//     });
//   }
// }

function OpenModalMCC(action, version_no, set_date) {
  // ResetInputFields();
  // ClearDataTable("tableEntryModelMCC");
  // $('#tableAssignMCCEntryModal').empty();
  $("#selectAll").prop("checked", false);
  $("#modelEntryMCCCommissionMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  var MPPI_Id = $("#lblEntryId").html();

  ClearDataTable("tableAssignMCCEntryModal");

  $("#lblAssignMCCVersion").html(version_no);
  $("#lblActionMCCCommissionMCC").html(action);
  $("#txtEntryApplicableDateMCC").val("");
  var MilkType_Id = $("#ddlEntryMilkType").val();
  var CollectionShift_Id = $("#ddlEntryMilkCollectionShift").val();

  if (action == "Add") {
    $("#divSearchField").show();

    $("#AddEditAssignMCC").text("Assign MCC");
    $("#lblActionMCCCommissionMCC").html(action);
    $("#txtEntryApplicableDateMCC").prop("disabled", false);
    // $("#txtEntryToDateTimeMCC").prop("disabled", false);
    // ClearDataTable("tableAssignMCCEntryModal");
    // TODO:
    // 1. Get vales for the MCC input table (MCC_CODE, MCC_NAME)

    var SearchText = "%%";
    var APIEndPoint = "GetMCCCommissionMCC";
    var Method_Name = "Get_MCC";
    var url = "/Rate/MCCCommissionMCC";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      mcctype_id: MCCType_Id,
      mccworktype_id: MCCWorkType_Id,
      search_text: SearchText,
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
        // ClearDataTable("tableAssignMCCEntryModal");
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += '<td style="width: 20px;">';
          TableHTML += '<label class="custom-control custom-checkbox ">';
          TableHTML +=
            '<input type="checkbox" class="custom-control-input  select-item " value="' +
            value.mcc_id +
            '"';
          TableHTML += 'style="vertical-align:sub; text-align: center;">';
          TableHTML +=
            '<span class="custom-control-label text-dark"></span></label></td>';
          TableHTML += "<td>" + value.mcc_code + "</td>";
          TableHTML += "<td>" + value.mcc_name + "</td>";
          TableHTML += "<td>" + value.taluka_name + "</td>";
          TableHTML += "<td>" + value.village_name + "</td>";
          TableHTML += "<td hidden></td>";
        });

        $("#tableEntryModelMCC").html(TableHTML);
        //SetDataTable("tableAssignMCCEntryModal", [6], "Milk");
        // SetDataTable("tableAssignMCCEntryModal", [5], "MilkMCCRate");
        $("#divAssignedMCCFooter").show();
        $("#thAssignedMCCCheckbox").show();
      },
      error: function (result) {
        ShowItemError(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  } else if (action == "Edit") {
    $("#divSearchField").show();

    // Edit
    $("#lblActionMCCCommissionMCC").html(action);
    $("#lblAssignMCCVersion").html(version_no);

    $("#AddEditAssignMCC").text("Edit Assigned MCC");
    // $("#txtEntryApplicableDateMCC").prop("disabled", true);
    $("#txtEntryApplicableDateMCC").val(set_date);
    // ClearDataTable("tableAssignMCCEntry");

    var SearchText = "%" + $("#txtSearchMCCSearchText").val() + "%";
    var APIEndPoint = "GetMCCCommissionMCC";
    var Method_Name = "Get_One";
    var url = "/Rate/MCCCommissionMCC";
    var reqdata = {
      method_name: Method_Name,
      mppi_id: MPPI_Id,
      version_no: version_no,
      api_end_point: APIEndPoint,
      mcctype_id: MCCType_Id,
      mccworktype_id: MCCWorkType_Id,
      search_text: SearchText,
    };
    // console.log(reqdata);
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        // // console.log(1);
        var allLocked = res.every(function (value) {
          return value.is_locked === 1;
        });
        // Fill data in table
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";

          TableHTML += '<td style="width: 20px;">';
          TableHTML += '<label class="custom-control custom-checkbox ">';

          if (value.is_locked == 1) {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input  select-item " value="' +
              value.mcc_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" checked>';
          } else {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input  select-item " value="' +
              value.mcc_id +
              '"';
            TableHTML += 'style="vertical-align:sub; text-align: center;">';
          }

          TableHTML +=
            '<span class="custom-control-label text-dark"></span></label></td>';
          TableHTML += "<td>" + value.mcc_code + "</td>";
          TableHTML += "<td>" + value.mcc_name + "</td>";
          TableHTML += "<td>" + value.taluka_name + "</td>";
          TableHTML += "<td>" + value.village_name + "</td>";
          TableHTML += "<td hidden></td>";
        });

        $("#tableEntryModelMCC").html(TableHTML);
        // // console.log("1");

        if (allLocked) {
          $("#selectAll").prop("checked", true);
        } else {
          $("#selectAll").prop("checked", false);
        }
        // SetDataTable("tableAssignMCCEntryModal", [5], "Milk MCC");

        //show save button footer & th
        $("#divAssignedMCCFooter").show();
        $("#thAssignedMCCCheckbox").show();
      },
      error: function (result) {
        ShowItemError(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  } else if (action == "View") {
    $("#divSearchField").hide();
    // View
    $("#lblActionMCCCommissionMCC").html(action);
    $("#lblAssignMCCVersion").html(version_no);

    $("#AddEditAssignMCC").text("View Assigned MCC");
    $("#txtEntryApplicableDateMCC").prop("disabled", true);
    $("#txtEntryApplicableDateMCC").val(set_date);
    ClearDataTable("tableAssignMCCEntryModal");

    var APIEndPoint = "GetMCCCommissionMCC";
    var Method_Name = "Get_View";
    var url = "/Rate/MCCCommissionMCC";
    var reqdata = {
      method_name: Method_Name,
      mppi_id: MPPI_Id,
      version_no: version_no,
      api_end_point: APIEndPoint,
      mcctype_id: MCCType_Id,
      mccworktype_id: MCCWorkType_Id,
      search_text: SearchText,
    };
    // // console.log(reqdata);
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        // Fill data in table
        var TableHTML = "";
        $.each(res, function (data, value) {
          if (value.is_locked == 1) {
            TableHTML += "<tr>";

            TableHTML += '<td style="width: 20px;" hidden>';
            TableHTML += '<label class="custom-control custom-checkbox ">';

            TableHTML +=
              '<input type="checkbox" class="custom-control-input  select-item " value="' +
              value.mcc_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" checked disabled>';

            TableHTML +=
              '<span class="custom-control-label text-dark"></span></label></td>';
            TableHTML += "<td>" + value.mcc_code + "</td>";
            TableHTML += "<td>" + value.mcc_name + "</td>";
            TableHTML += "<td>" + value.taluka_name + "</td>";
            TableHTML += "<td>" + value.village_name + "</td>";
            TableHTML += "<td hidden></td>";
            TableHTML += "</tr>";
          }
        });

        $("#tableEntryModelMCC").html(TableHTML);
        // SetDataTable("tableAssignMCCEntryModal", [5], "Milk MCC");
        //hide save button footer & th
        $("#divAssignedMCCFooter").hide();
        $("#thAssignedMCCCheckbox").hide();
      },
      error: function (result) {
        ShowItemError(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  }
}

$("#modelEntryMCCCommissionMCC").on("hidden.bs.modal", function (e) {
  $("#lblActionMCCCommissionMCC").html("");
  $("#AddEditMCCCommissionMCC").text("");
  $("#txtSearchMCCSearchText").val("");

  // ResetInputFields();
});

// Delete MCC Commision Item
function SaveDeleteEntryItem(Entry_Id) {
  var APIEndPoint = "SaveMCCCommissionItem";
  var url = "/Rate/MCCCommissionItem";
  var MPPI_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: "Delete",
    entry_id: Entry_Id,
    mppi_id: MPPI_Id,
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
        ShowItemSuccess("MCC Commission Item details deleted successfully");
        GetMCCCommissionTable();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : MCC Commission Item details not deleted");
    },
  });
}

// Display MCC Commission Assigned MCC entries in a table
function GetMCCEntryList() {
  ClearDataTable("tableMCCEntryList");
  var Method_Name = "Get";
  var APIEndPoint = "GetMCCCommissionMCC";
  var url = "/Rate/MCCCommissionMCC ";
  var MPPI_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    mppi_id: MPPI_Id,
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
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 80px; padding: 8px 5px 8px 5px;">';
        // if not locked, then allow editing nd deleting
        if (value.is_locked != 1) {
          if (EditFlag == 1) {
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalMCC(\'Edit\', \'' +
              value.version_no +
              "', '" +
              value.set_date +
              "')\">";
            TableHTML += '<i class="fa fa-pencil"></i>';
            TableHTML += "</a>";
          }
          if (DeleteFlag == 1) {
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryMCC(\'' +
              value.version_no +
              "')\">";
            TableHTML += '<i class="fa fa-trash"></i>';
            TableHTML += "</a>";
          }
        }
        // if locked, only allow viewing
        else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="OpenModalMCC(\'View\', \'' +
            value.version_no +
            "', '" +
            value.set_date +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntryMCC").html(TableHTML);
      SetDataTable("tableMCCEntryList", [2], "MCC Commission Assigned MCC");
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

// Save MCC Commission Item MCC
function SaveMCCCommissionMCC() {
  // Validation
  Applicable_Date = $("#txtEntryApplicableDateMCC").val();

  var MPPI_Id = $("#lblEntryId").html();
  var Version_No = "";

  var selectedCheckboxes = $("#tableAssignMCCEntryModal").find(
    "tbody input[type='checkbox']:checked"
  );
  var MCC_Id = [];

  selectedCheckboxes.each(function () {
    var checkboxId = $(this).val();
    MCC_Id.push(checkboxId);
  });

  var IsValid = 1;
  if (Applicable_Date == "") {
    IsValid = 0;
    $("#txtEntryApplicableDateMCC").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btnSaveMCC").prop("disabled", true);
    var APIEndPoint = "SaveMCCCommissionMCC";
    var Method_Name = "Create";
    var Action_Name = $("#lblActionMCCCommissionMCC").html();

    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Version_No = $("#lblAssignMCCVersion").html();
    }

    var url = "/Rate/MCCCommissionMCC";
    var reqdata = {
      method_name: Method_Name,
      applicable_date: Applicable_Date,
      version_no: Version_No,
      mppi_id: MPPI_Id,
      mcc_id: MCC_Id.join(","),
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
          Hide_Loader();
          $("#modelEntryMCCCommissionMCC").modal("hide");
          ShowItemSuccess("MCC Commission MCC details saved successfully");
          GetMCCEntryList();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : MCC Commission Assigned MCC details not saved");
      },
    });
    $("#modelEntryAssignMCC").modal("hide");
  }
  $("#btnSaveMCC").prop("disabled", false);
}

function SaveDeleteEntryMCC(Version_No) {
  var APIEndPoint = "SaveMCCCommissionMCC";
  var url = "/Rate/MCCCommissionMCC";
  var MPPI_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: "Delete",
    version_no: Version_No,
    mppi_id: MPPI_Id,
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
        ShowItemSuccess(
          "MCC Commission Assigned MCC details deleted successfully"
        );
        GetMCCEntryList();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : MCC Commission Item details not deleted");
    },
  });
}

// Reset Input fields
// function ResetInputFields() {
//   // $(".modal input, .modal select").val("");
//   $("#txtEntryApplicableFromDateTime").prop("disabled", false);
// }

// function SetDate(ddl_id, is_item) {
//   // Setting Date Text Box value depending on the provided date from database

//   var Method_Name = "Get_Date";
//   var MPPI_Id = $("#lblEntryId").html();

//   // if MCC
//   var APIEndPoint = "GetMCCCommissionMCC";
//   var url = "/Rate/MCCCommissionMCC ";

//   // if Item
//   if (is_item) {
//     APIEndPoint = "GetMCCCommissionItem";
//     url = "/Rate/MCCCommissionItem";
//   }

//   var reqdata = {
//     method_name: Method_Name,
//     api_end_point: APIEndPoint,
//     mppi_id: MPPI_Id,
//   };
//   $.ajax({
//     type: "POST",
//     url: url,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata,
//     success: function (result) {
//       var res = JSON.parse(result);
//       // latest_date = new Date(res[0].applicable_date);
//       // var date = new Date(Date.now()).toISOString(); //.slice(0, 10);
//       // if (latest_date > date) {
//       //   date = latest_date;
//       // }

//       var date;
//       if (res.length === 0) {
//         date = new Date(Date.now());
//       } else {
//         var latest_date = new Date(res[0].applicable_date);
//         date = new Date(Date.now()); //.toISOString().slice(0, 16);
//         if (latest_date > date) {
//           date = latest_date;
//         }
//       }

//       var offset = date.getTimezoneOffset();
//       date.setMinutes(date.getMinutes() - offset);
//       var newdate = date.toISOString().slice(0, 16);

//       $("#" + ddl_id).attr("min", newdate);
//       $("#" + ddl_id).val(newdate);

//       /*
//             next_date = new Date(date);
//             next_date.setDate(next_date.getDate() + 1);
//             newdate = next_date.toISOString().slice(0, 16);
//             */
//       // var offset = date.getTimezoneOffset();
//       // date.setMinutes(date.getMinutes() - offset);
//       // var newdate = date.toISOString().slice(0, 16);

//       // $("#" + ddl_id).attr("min", newdate);
//       // $("#" + ddl_id).val(newdate);
//     },
//     error: function () {},
//   });
// }

function GetMCCforMCCCommission() {
  $("#btn_Search_MCC").prop("disabled", true);
  var SearchText = "%" + $("#txtSearchMCCSearchText").val() + "%";
  if (SearchText == "") {
    return;
  }
  var MPPI_Id = $("#lblEntryId").html();
  var version_no = $("#lblAssignMCCVersion").html();
  var Action = $("#lblActionMCCCommissionMCC").html();
  var Method_Name = "Get_MCC";

  if (Action == "Edit" || Action == "View") {
    Method_Name = "Get_One";
  }
  /*if (Action == "View") {
          Method_Name = 'Get_View';
      }*/

  ClearDataTable("tableAssignMCCEntryModal");

  var APIEndPoint = "GetMCCCommissionMCC";
  var url = "/Rate/MCCCommissionMCC";
  var reqdata = {
    method_name: Method_Name,
    mppi_id: MPPI_Id,
    version_no: version_no,
    api_end_point: APIEndPoint,
    mcctype_id: MCCType_Id,
    mccworktype_id: MCCWorkType_Id,
    search_text: SearchText,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var disabled = "";
      if (Action == "View") {
        disabled = "disabled";
      }

      // Fill data in table
      var TableHTML = "";
      $.each(res, function (data, value) {
        // checked = "";
        // if (value.is_locked == 1) {
        //   checked = "checked";
        // }
        // TableHTML += "<tr>";
        // TableHTML += "<td>" + (data + 1) + "</td>";
        // TableHTML += '<td style="padding: 2px; margin-bottom:0px;">';
        // TableHTML +=
        //   '<label class="custom-control custom-checkbox" style="margin-bottom: 0px;">';
        // TableHTML +=
        //   '<input type="checkbox" class="custom-control-input" value="' +
        //   value.mcc_id +
        //   '"';
        // TableHTML +=
        //   'style="vertical-align:sub; text-align: center; margin:0px;" ' +
        //   checked +
        //   " " +
        //   disabled +
        //   ">";
        // TableHTML +=
        //   '<span class="custom-control-label text-dark"></span></label></td>';
        // TableHTML += "<td>" + value.mcc_code + "</td>";
        // TableHTML += "<td>" + value.mcc_name + "</td>";
        //TableHTML += "<td hidden></td>";

        TableHTML += "<tr>";

        TableHTML += '<td style="width: 20px;">';
        TableHTML += '<label class="custom-control custom-checkbox ">';

        if (value.is_locked == 1) {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input" value="' +
            value.mcc_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;" checked >';
        } else {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input" value="' +
            value.mcc_id +
            '"';
          TableHTML += 'style="vertical-align:sub; text-align: center;">';
        }

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td hidden></td>";
      });

      $("#tableEntryModelMCC").html(TableHTML);
      // SetDataTable("tableAssignMCCEntryModal", [5], "MCC Commission");
      $("#divAssignedMCCFooter").show();
      $("#thAssignedMCCCheckbox").show();
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description
      );
    },
  });
  $("#btn_Search_MCC").prop("disabled", false);
}

function ShowMPPIRateMCCView() {
  ShowContentDiv("Rate", "MCCCommissionAssignMCCEntry", "", function () {
    $("#ddlViewType").select2();
    GetMaster("ddlViewType", "Select Type", "GetMCCType", "", "");

    // Get the current date and time in the format expected by datetime-local input
    function getCurrentDateTime() {
      const now = new Date();
      const year = now.getFullYear();
      const month = (now.getMonth() + 1).toString().padStart(2, "0");
      const day = now.getDate().toString().padStart(2, "0");
      const hours = now.getHours().toString().padStart(2, "0");
      const minutes = now.getMinutes().toString().padStart(2, "0");

      return `${year}-${month}-${day}T${hours}:${minutes}`;
    }

    // Set the current date and time in the input field
    $(document).ready(function () {
      // Assuming you want to set the current date and time when the page loads
      $("#txtMCCViewDate").val(getCurrentDateTime());
    });

    $("#modelEntryMCCCommissionAssignMCC").on("hidden.bs.modal", function (e) {
      GetMMPIAssignMPPI_MCC();
      $("#ddlEntryMPPITypeAssignMCC").val("");
      $("#ddlEntryMPPI").val("");
      ClearDataTable("tableAssignAssignMCCEntryModal");
    });
  });
}

function GetMPPIRateChartMCCView() {
  var MCCType = $("#ddlViewType").val();
  // var Search_Period = $("#txtMCCViewDate").val();
  var IsValid = 1;
  if (MCCType == "" || MCCType == null || MCCType == undefined) {
    $("#ddlViewType").addClass("is-invalid state-invalid");
    IsValid = 0;
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }
  $("#modelEntryMCCCommissionAssignMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  ClearDataTable("tableAssignAssignMCCEntryModal");

  $("#ddlEntryMPPITypeAssignMCC").select2();
  $("#ddlEntryMPPI").select2();

  GetMaster(
    "ddlEntryMPPITypeAssignMCC",
    "Select MPPI Type",
    "GetMPPIType",
    "",
    ""
  );

  // $("#ddlEntryMPPITypeAssignMCC").on("change", function () {
  //   // Call the ClearInvalidState function on change
  //   // ClearInvalidState(this);

  //   var MPPIType_Id = $("#ddlEntryMPPITypeAssignMCC").val();
  //   if (MPPIType_Id == "" || MPPIType_Id == null || MPPIType_Id == undefined) {
  //     // return;
  //     $("#ddlEntryMPPI").val("");
  //   } else {
  //     GetMaster("ddlEntryMPPI", "Select MPPI", "GetMPPI", "", MPPIType_Id);
  //   }
  // });
  // GetMaster("ddlEntryMPPI", "Select MPPI", "GetMPPI", "", "");
  // GetMMPIAssignMCC();
}

function GetMMPIName() {
  $("#ddlEntryMPPI")
    .empty()
    .append($("<option></option>").val("").html("Select MPPI"));
  var MPPIType_Id = $("#ddlEntryMPPITypeAssignMCC").val();
  GetMaster("ddlEntryMPPI", "Select MPPI", "GetMPPI", "", MPPIType_Id);
}

function GetMMPIAssignMCC(e) {
  ClearDataTable("tableAssignAssignMCCEntryModal");
  var MPPI_Id = "";
  var url = "/Rate/MCCCommissionMCC";

  var APIEndPoint = "GetMCCCommissionMCC";
  var Method_Name = "Get_AssignMCC";
  var MCCType = $("#ddlViewType").val();
  // var Search_Period = $("#txtMCCViewDate").val();
  MPPI_Id = $("#ddlEntryMPPI").val();

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcctype_id: MCCType,
    mppi_id: MPPI_Id,
    // applicable_date: Search_Period,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
        // Show_Error_Toastr("Data not found.");
        return;
      }
      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;

      $.each(res, function (data, value) {
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        if (value.is_mcc == 1) {
          TableHTML +=
            "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Added"><i class="fa fa-check"></i></a>';

          TableHTML += "</td>";
        } else {
          TableHTML +=
            "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Data" onclick=\'SaveEntryMMPIAssignMCC("' +
            value.mcc_id +
            '");\'><i class="fa fa-save"></i></a>';

          TableHTML += "</td>";
        }

        TableHTML += "</tr>";
      });

      $("#tableEntryModelAssignMCC").html(TableHTML);

      SetDataTable("tableAssignAssignMCCEntryModal", [5], "AssignMCC");
      // $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      // $("#btn_Search").prop("disabled", false);
    },
  });
  return;
}

function GetMMPIAssignMPPI_MCC(e) {
  var MCCType = $("#ddlViewType").val();
  var Search_Period = $("#txtMCCViewDate").val();
  var IsValid = 1;
  if (MCCType == "" || MCCType == null || MCCType == undefined) {
    $("#ddlViewType").addClass("is-invalid state-invalid");
    IsValid = 0;
  }

  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    $("#txtMCCViewDate").addClass("is-invalid state-invalid");
    IsValid = 0;
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  ClearDataTable("tableAssignMCCEntryList");
  var url = "/Rate/MCCCommissionMCC";

  var APIEndPoint = "GetMCCCommissionMCC";
  var Method_Name = "GetAssignMCC";
  var MCCType = $("#ddlViewType").val();
  var Search_Period = $("#txtMCCViewDate").val();

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcctype_id: MCCType,
    applicable_date: Search_Period,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;

      $.each(res, function (data, value) {
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.mppi_name + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML += "<td hidden></td>";

        TableHTML += "</tr>";
      });

      $("#tableEntryAssignMCC").html(TableHTML);

      SetDataTable("tableAssignMCCEntryList", [4], "AssignMCC");
      // $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      // $("#btn_Search").prop("disabled", false);
    },
  });
  return;
}

function SaveEntryMMPIAssignMCC(mcc_id) {
  // Validation code
  var MCCType = $("#ddlViewType").val();
  var Search_Period = $("#txtEntryApplicableDateAssignMCC").val();
  var MPPI_Id = $("#ddlEntryMPPI").val();
  var IsValid = 1;

  if (MCCType == "" || MCCType == null || MCCType == undefined) {
    IsValid = 0;
    $("#ddlViewType").addClass("is-invalid state-invalid");
  }

  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    IsValid = 0;
    $("#txtEntryApplicableDateAssignMCC").addClass("is-invalid state-invalid");
  }

  if (MPPI_Id == "" || MPPI_Id == null || MPPI_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMPPI").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }
  var url = "/Rate/MCCCommissionMCC";

  var APIEndPoint = "SaveMCCCommissionMCC";
  var Method_Name = "Create_MCC";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcctype_id: MCCType,
    mppi_id: MPPI_Id,
    applicable_date: Search_Period,
    mcc_id: mcc_id,
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
        // Hide_Loader();
        ShowEntrySuccess("MCC details saved successfully");
        Show_Success_Toastr("MCC details saved successfully");
        // $("#lblEntryId").html(result[0].result_extra_key);
        // $("#lblAction").html("Edit");

        // GetMMPIAssignMPPI_MCC();
        // $("#divFooterDelete").show();
        GetMMPIAssignMCC();
      } else {
        // Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        ShowEntryError("Error : " + result[0].result_description);
        // $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      // Hide_Loader();
      Show_Error_Toastr("Error : MCC details not saved");
      // $("#btn_Save").prop("disabled", false);
    },
  });
}
