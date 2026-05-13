$(document).ready(function () {
  $("#ddlSearchVehicleNo").select2();
  var date = new Date().toISOString().slice(0, 10);
  $("#txtSearchDuration").val(date);

  $("#ddlSearchMCCType").select2();
  GetMaster("ddlSearchMCCType", "Select MCC Type", "GetMCCType", "", "");
});

// function GetSearchList(e) {
//     SetDataTable("tableSearch", [10], "Farmer Income");
// }

function GetSearchList() {
  ClearDataTable("tableSearch");
  // Get Milk Collection data from database and show in the table on Search page
  var APIEndPoint = "GetInvoiceFarmerIncome";
  var Search_Period = $("#txtSearchDuration").val();
  var MCCType = $("#ddlSearchMCCType").val();

  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  if (MCCType == "" || MCCType == null || MCCType == undefined) {
    $("#ddlSearchMCCType").addClass("is-invalid state-invalid");
    return;
  }

  var Method_Name = "Get";
  var url = "/invoice/InvoiceFarmerIncome";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    mcctype_id: MCCType,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      // show message if there is no data to show

      // Fill data in table
      var TableHTML = "";
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Status;
        if (value.is_locked == 0) {
          Status = "Open";
        } else {
          Status = "Updated";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML +=
          "<td style='text-align: left;'>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.agent_ltr + "</td>";
        TableHTML += "<td>" + value.agent_fat + "</td>";
        TableHTML += "<td>" + value.agent_snf + "</td>";
        TableHTML += "<td>" + value.dairy_ltr + "</td>";
        TableHTML += "<td>" + value.dairy_fat + "</td>";
        TableHTML += "<td>" + value.dairy_snf + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
        EditFlag = value.is_locked;
        if (EditFlag == 0) {
          var action = "Edit";
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            //action +
            //"','" +
            value.setentry_id +
            "', '" +
            value.milkcollectiondairy_id +
            "', '" +
            value.tripdocument_id +
            "','" +
            value.mcc_id +
            "','" +
            value.collectionshift_id +
            "', '" +
            value.mcccollectionshift_id +
            "', '" +
            value.mcc_name +
            "', '" +
            value.collectionshift_name +
            "','" +
            value.is_locked +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";

          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Gain Loss Approve" onclick="GainLossApproveEntry(\'' +
            //action +
            //"','" +
            value.setentry_id +
            "', '" +
            value.milkcollectiondairy_id +
            "', '" +
            value.tripdocument_id +
            "','" +
            value.mcc_id +
            "','" +
            value.collectionshift_id +
            "', '" +
            value.mcccollectionshift_id +
            "', '" +
            value.mcc_name +
            "', '" +
            value.collectionshift_name +
            "','" +
            value.is_locked +
            "');\">";
          TableHTML += '<i class="fa fa-check-circle"></i>';
          TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'' +
            //action +
            //"','" +
            value.setentry_id +
            "', '" +
            value.milkcollectiondairy_id +
            "', '" +
            value.tripdocument_id +
            "','" +
            value.mcc_id +
            "','" +
            value.collectionshift_id +
            "', '" +
            value.mcccollectionshift_id +
            "', '" +
            value.mcc_name +
            "', '" +
            value.collectionshift_name +
            "','" +
            value.is_locked +
            "');\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";






          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Gain Loss Approve" onclick="GainLossApproveEntry(\'' +
            //action +
            //"','" +
            value.setentry_id +
            "', '" +
            value.milkcollectiondairy_id +
            "', '" +
            value.tripdocument_id +
            "','" +
            value.mcc_id +
            "','" +
            value.collectionshift_id +
            "', '" +
            value.mcccollectionshift_id +
            "', '" +
            value.mcc_name +
            "', '" +
            value.collectionshift_name +
            "','" +
            value.is_locked +
            "');\">";
          TableHTML += '<i class="fa fa-check-circle"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [10], "Farmer Income");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function ShowEditEntry(
  SetEntry_Id,
  MilkCollectionDairyId,
  TripDocumentId,
  MCC_Id,
  CollectionShift_Id,
  MCCCollectionShift_Id,
  MCC_Name,
  CollectionShift_Name,
  Is_Locked
) {
  ShowContentDiv("Invoice", "FarmerIncomeAdd", "", function () {
    $("#txtEntryMCCName").val(MCC_Name);
    $("#txtEntryMilkCollectionShift").val(CollectionShift_Name);

    $("#lblMilkCollectionDairyId").html(MilkCollectionDairyId);
    $("#lblTripDocumentId").html(TripDocumentId);
    $("#lblMCCId").html(MCC_Id);
    $("#lblCollectionShift").html(CollectionShift_Id);
    $("#lblMCCCollectionShiftId").html(MCCCollectionShift_Id);
    $("#lblSetEntryId").html(SetEntry_Id);
    $("#lblIsLocked").html(Is_Locked);

    $("#excelDownload").hide();
    $("#excelUpload").hide();
    $("#openModalFarmer").hide();
    $("#approval").hide();
    $("#approval_auth").hide();

    $("#tabUD").hide();
    // $("#tab2").hide();
    if (Is_Locked == 1) {
      $("#excelDownload").hide();
      $("#excelUpload").hide();
      $("#openModalFarmer").hide();
      $("#approval").hide();
      $("#approval_auth").hide();
      $("#tabUD").hide();
      $("#btn_Reverse").hide();
      $("#btn_Approve").hide();
      $("#btn_GainLossApprove").hide();
      GetReverse(MCCCollectionShift_Id, MCC_Id);
      // $("#tab2").hide();
    } else {
      $("#excelDownload").show();
      $("#excelUpload").show();
      $("#openModalFarmer").show();
      $("#approval").show();
      $("#approval_auth").show();
      $("#tabUD").show();
      $("#btn_Reverse").hide();
      $("#btn_Approve").show();
      $("#btn_GainLossApprove").show();
      // $("#tab2").show();
    }

    GetOriginalFarmerCollectionList();
    GetMCCCollectionList();

    $("#modelEntryFarmerCollection").on("hidden.bs.modal", function (e) {
      $("#txtEntryLiters").val("");
      $("#txtEntryFAT").val("");
      $("#txtEntrySNF").val("");
    });
  });
}

function OpenModalFarmer(action, Entry_Id) {
  $("#modelEntryFarmerCollection").modal("show");
  $("#txtEntryLiters").val("");
  $("#txtEntryFAT").val("");
  $("#txtEntrySNF").val("");

  $("#AddEditFarmerCollection").html("Add Quantity Details");
  // $("#lblActionFarmerChemistCollection").html("Farmer");
  $("#ddlEntryFarmer").select2();
  $("#ddlEntryMilkType").select2();
  $("#ddlEntryMilkStatus").select2();
  var MCC_Id = $("#lblMCCId").html();

  if (action == "Add") {
    $("#AddEditFarmerCollection").html("Add");
    GetMaster("ddlEntryFarmer", "Select Farmer", "GetMCCFarmer", "", MCC_Id);
    GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", "", "");
    GetMaster(
      "ddlEntryMilkStatus",
      "Select Milk Status",
      "GetMilkStatus",
      "C016001",
      ""
    );
  }
  if (action == "Edit") {
    $("#lblActionFarmerCollection").html(Entry_Id);
    $("#AddEditFarmerCollection").html("Edit");
    var MilkCollectionDairyId = $("#lblMilkCollectionDairyId").html();
    var MCCCollectionShiftId = $("#lblMCCCollectionShiftId").html();
    var MCC_Id = $("#lblMCCId").html();
    var Method_Name = "Get_One";

    var APIEndPoint = "GetInvoiceFarmerIncome";
    var url = "/invoice/InvoiceFarmerIncome";
    var reqdata = {
      entry_id: Entry_Id,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      mcc_id: MCC_Id,
      milkcollectiondairy_id: MilkCollectionDairyId,
      mcccollectionshift_id: MCCCollectionShiftId,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result); //.responseData);
        // console.log(res);
        $("#lblActionFarmerCollection").html(res[0].entry_id);

        GetMaster(
          "ddlEntryFarmer",
          "Select Farmer",
          "GetMCCFarmer",
          res[0].farmer_id,
          MCC_Id
        );
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
        $("#txtEntryLiters").val(res[0].liters);
        $("#txtEntryFAT").val(res[0].fat);
        $("#txtEntrySNF").val(res[0].snf);
      },
      error: function () {
        Show_Error_Toastr("Error : User details not found");
      },
    });

    // debugger
  }
}
$("#modelEntryFarmerCollection").on("hidden.bs.modal", function (e) {});

function ExcelUpload() {
  $("#modelEntryExcelUpload").modal("show");
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function GetOriginalFarmerCollectionList() {
  var MilkCollectionDairyId = $("#lblMilkCollectionDairyId").html();
  var TripDocumentId = $("#lblTripDocumentId").html();
  var MCC_Id = $("#lblMCCId").html();
  ClearDataTable("tableOriginalFarmerCollectionList");
  $("#tableOriginalEntryFarmerCollection").empty();
  var APIEndPoint = "GetInvoiceFarmerIncome";
  var Method_Name = "Get_OriginalFarmer";
  var url = "/invoice/InvoiceFarmerIncome";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    milkcollectiondairy_id: MilkCollectionDairyId,
    tripdocument_id: TripDocumentId,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // // console.log(res);
      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "<td hidden>" + value.mcc_farmer_code + "</td>";
        TableHTML += "</tr>";
      });
      $("#tableOriginalEntryFarmerCollection").html(TableHTML);

      SetDataTable(
        "tableOriginalFarmerCollectionList",
        [8],
        "Farmer Milk Collection"
      );
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function GetMCCCollectionList() {
  var MilkCollectionDairyId = $("#lblSetEntryId").html();
  var MCCCollectionShiftId = $("#lblMCCCollectionShiftId").html();
  var MCC_Id = $("#lblMCCId").html();
  ClearDataTable("tableMCCCollectionList");
  $("#tableEntryMCCCollection").empty();
  var APIEndPoint = "GetInvoiceFarmerIncome";
  var Method_Name = "Get_Approval";
  var url = "/invoice/InvoiceFarmerIncome";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    milkcollectiondairy_id: MilkCollectionDairyId,
    mcccollectionshift_id: MCCCollectionShiftId,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      $("#lblDAIRYfatkg").html(res[0].fatkg);
      $("#lblDAIRYsnfkg").html(res[0].snfkg);
      $("#lblMCCfatkg").html(res[1].fatkg);
      $("#lblMCCsnfkg").html(res[1].snfkg);

      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<th>" + value.location + "</th>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td>" + value.fatkg + "</td>";
        TableHTML += "<td>" + value.snfkg + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryMCCCollection").html(TableHTML);

      SetDataTable("tableMCCCollectionList", [8], "MCC Milk Collection");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function GetUpdatedFarmerCollectionList() {
  var MilkCollectionDairyId = $("#lblMilkCollectionDairyId").html();
  var MCCCollectionShiftId = $("#lblMCCCollectionShiftId").html();
  var MCC_Id = $("#lblMCCId").html();
  ClearDataTable("tableUpdatedFarmerCollectionList");
  $("#tableUpdatedEntryFarmerCollection").empty();
  var APIEndPoint = "GetInvoiceFarmerIncome";
  var Method_Name = "Get_UpdatedFarmer";
  var url = "/invoice/InvoiceFarmerIncome";
  var IsLocked = $("#lblIsLocked").html();
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    milkcollectiondairy_id: MilkCollectionDairyId,
    mcccollectionshift_id: MCCCollectionShiftId,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // // console.log(res);
      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        // TableHTML += "<td hidden></td>";
        if (IsLocked == 1) {
          TableHTML += "<td></td>";
        } else {
          TableHTML +=
            "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
          // if (value.is_locked == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalFarmer(\'Edit\',\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
          // }
          // if (value.is_locked == 0) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="DeleteEntryItem(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
          // }
          TableHTML += "</td>";
        }
        TableHTML += "</tr>";
      });
      $("#tableUpdatedEntryFarmerCollection").html(TableHTML);

      SetDataTable(
        "tableUpdatedFarmerCollectionList",
        [8],
        "Farmer Milk Collection"
      );
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SaveFarmerCollectionEntry() {
  var MCC_Id = $("#lblMCCId").html();
  var TripDocument_Id = $("#lblTripDocumentId").html();
  var CollectionShift_Id = $("#lblCollectionShift").html();
  var MCCCollectionShift_Id = $("#lblMCCCollectionShiftId").html();

  var Farmer_Id = $("#ddlEntryFarmer").val().trim();
  var MilkType_Id = $("#ddlEntryMilkType").val().trim();
  var MilkStatus_Id = $("#ddlEntryMilkStatus").val().trim();
  var Weight = $("#txtEntryLiters").val().trim();
  var FAT = $("#txtEntryFAT").val().trim();
  var SNF = $("#txtEntrySNF").val().trim();
  var Search_Period = $("#txtSearchDuration").val();

  var IsValid = 1;

  // var Action = ;
  if (Farmer_Id == "" || Farmer_Id == null || Farmer_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryFarmer").addClass("is-invalid state-invalid");
  }
  if (MilkType_Id == "" || MilkType_Id == null || MilkType_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMilkType").addClass("is-invalid state-invalid");
  }
  if (
    MilkStatus_Id == "" ||
    MilkStatus_Id == null ||
    MilkStatus_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryMilkStatus").addClass("is-invalid state-invalid");
  }
  if (Weight == "" || Weight == null || Weight == undefined) {
    IsValid = 0;
    $("#txtEntryLiters").addClass("is-invalid state-invalid");
  }
  if (FAT == "" || FAT == null || FAT == undefined) {
    IsValid = 0;
    $("#txtEntryFAT").addClass("is-invalid state-invalid");
  }
  if (SNF == "" || SNF == null || SNF == undefined) {
    IsValid = 0;
    $("#txtEntrySNF").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  Show_Loader();

  var Method_Name = "Create";
  var Entry_Id = "";
  var Action_Name = $("#AddEditFarmerCollection").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Entry_Id = $("#lblActionFarmerCollection").html();
  }

  var APIEndPoint = "SaveInvoiceFarmerIncome";
  var url = "/invoice/InvoiceFarmerIncome";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    tripdocument_id: TripDocument_Id,
    mcccollectionshift_id: MCCCollectionShift_Id,
    collectionshift_id: CollectionShift_Id,
    farmer_id: Farmer_Id,
    weight: Weight,
    snf: SNF,
    fat: FAT,
    milktype_id: MilkType_Id,
    milkstatus_id: MilkStatus_Id,
    search_period: Search_Period,
    entry_id: Entry_Id,
  };
  // debugger;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      // // console.log(result);
      if (result[0].result_id == 1) {
        Hide_Loader();
        // Show Success Message
        Show_Success_Toastr(result[0].result_description);

        $("#modelEntryFarmerCollection").modal("hide");
        GetUpdatedFarmerCollectionList();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        // $("#btn_MCCSave").show();
        $("#modelEntryFarmerCollection").modal("hide");
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Farmer details not saved");
      // $("#btn_MCCSave").show();
    },
  });
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function DeleteEntryItem(Entry_Id) {
  var APIEndPoint = "SaveInvoiceFarmerIncome";
  var url = "/invoice/InvoiceFarmerIncome";

  var reqdata = {
    method_name: "Delete",
    entry_id: Entry_Id,
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
        ShowItemSuccess("Farmer details deleted successfully");
        GetUpdatedFarmerCollectionList();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : Farmer details not deleted");
    },
  });
}

function ExcelDownload() {
  var MilkCollectionDairyId = $("#lblMilkCollectionDairyId").html();
  var TripDocumentId = $("#lblTripDocumentId").html();
  var MCC_Id = $("#lblMCCId").html();
  // ClearDataTable("tableOriginalFarmerCollectionList");
  // $("#tableOriginalEntryFarmerCollection").empty();
  var APIEndPoint = "GetInvoiceFarmerIncome";
  var Method_Name = "Get_OriginalFarmer";
  var url = "/invoice/InvoiceFarmerIncome";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    milkcollectiondairy_id: MilkCollectionDairyId,
    tripdocument_id: TripDocumentId,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      // console.log(res);

      downloadCSV(res);
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function convertArrayOfObjectsToCSV(data, shiftValue) {
  var result, ctr, keys, columnDelimiter, lineDelimiter;

  if (data == null || !data.length) {
    return null;
  }

  columnDelimiter = ",";
  lineDelimiter = "\n";

  // Specify the fields and their corresponding headers
  var fields = [
    "milktype_name",
    "shift",
    "mcc_farmer_code",
    "farmer_name",
    "liters",
    "fat",
    "snf",
  ];
  var headers = [
    "Milk Category",
    "Shift",
    "Farmer Code",
    "Farmer Name",
    "Liters",
    "FAT",
    "SNF",
  ];

  result = "";
  result += headers.join(columnDelimiter);
  result += lineDelimiter;

  data.forEach(function (item) {
    ctr = 0;
    fields.forEach(function (field) {
      if (ctr > 0) result += columnDelimiter;

      // Add a condition to set milktype_name as desired
      var value = item[field];
      if (field === "milktype_name") {
        value =
          value === "Cow"
            ? "Cow Milk"
            : value === "Buffalo"
            ? "Buffalo Milk"
            : value;
      } else if (field === "shift") {
        value = shiftValue; // Set the shift value here
      }

      result += value;
      ctr++;
    });
    result += lineDelimiter;
  });

  return result;
}

function downloadCSV(data) {
  var shiftValue = $("#txtEntryMilkCollectionShift").val(); // Get the shift value

  var csv = convertArrayOfObjectsToCSV(data, shiftValue);
  if (csv == null) return;

  var filename = "farmer_data.csv";

  if (!csv.match(/^data:text\/csv/i)) {
    csv = "data:text/csv;charset=utf-8," + csv;
  }
  var data = encodeURI(csv);

  var link = document.createElement("a");
  link.setAttribute("href", data);
  link.setAttribute("download", filename);
  document.body.appendChild(link);

  link.click();
}

function SaveExcelUploadEntry() {
  Show_Loader();
  var file = $("#txtEntryExcelUpload");
  var reqdata = new FormData();
  reqdata.append("FIle", file[0].files[0]);
  reqdata.append("ModuleName", "CategoryMaster");

  var url = "/Transporter/CovertExcelToTable";
  $.ajax({
    url: url,
    type: "POST",
    processData: false,
    contentType: false,
    data: reqdata,
    async: false,
    success: function (response) {
      if (response.status == 200) {
        var res_Json = JSON.parse(response.data);
        // // console.log(res_Json);

        var farmerCollectionData = "<CollectionData>";
        for (var i = 0; i < res_Json.length; i++) {
          var farmerData = res_Json[i];

          if (
            farmerData["Farmer Code"] &&
            farmerData["Milk Category"] &&
            farmerData["Liters"] &&
            farmerData["FAT"] &&
            farmerData["SNF"]
          ) {
            if (
              farmerData["Milk Category"] == "Cow Milk" ||
              farmerData["Milk Category"] == "Buffalo Milk" ||
              farmerData["Milk Category"] == "Cow" ||
              farmerData["Milk Category"] == "Buffalo"
            ) {
              farmerCollectionData += "<Farmer>";
              farmerCollectionData +=
                "<MCC_Farmer_Code>" +
                farmerData["Farmer Code"] +
                "</MCC_Farmer_Code>";
              if (
                farmerData["Milk Category"] === "Cow Milk" ||
                farmerData["Milk Category"] === "Cow"
              ) {
                farmerCollectionData += "<MilkType_Id>C011001</MilkType_Id>";
              } else if (
                farmerData["Milk Category"] === "Buffalo Milk" ||
                farmerData["Milk Category"] === "Buffalo"
              ) {
                farmerCollectionData += "<MilkType_Id>C011002</MilkType_Id>";
              }
              farmerCollectionData += "<MilkStatus_Id>C016001</MilkStatus_Id>";
              farmerCollectionData +=
                "<Liters>" + farmerData["Liters"] + "</Liters>";
              farmerCollectionData += "<Fat>" + farmerData["FAT"] + "</Fat>";
              farmerCollectionData += "<SNF>" + farmerData["SNF"] + "</SNF>";
              farmerCollectionData += "</Farmer>";
            }
          }
        }

        farmerCollectionData += "</CollectionData>";

        // // console.log(farmerCollectionData);
        // return;
        var MCC_Id = $("#lblMCCId").html();
        var TripDocument_Id = $("#lblTripDocumentId").html();
        var CollectionShift_Id = $("#lblCollectionShift").html();
        var MCCCollectionShift_Id = $("#lblMCCCollectionShiftId").html();
        var Search_Period = $("#txtSearchDuration").val();

        var Method_Name = "ExcelUpload";
        var APIEndPoint = "SaveInvoiceFarmerIncome";
        var url_One = "/invoice/InvoiceFarmerIncome";
        var reqdata_one = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          tripdocument_id: TripDocument_Id,
          mcccollectionshift_id: MCCCollectionShift_Id,
          collectionshift_id: CollectionShift_Id,
          collection_data: farmerCollectionData,
          search_period: Search_Period,
        };

        // // console.log(reqdata);

        $.ajax({
          type: "POST",
          url: url_One,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata_one,
          success: function (res) {
            var result = JSON.parse(res);

            // // console.log(result);
            if (result[0].result_id == 1) {
              Hide_Loader();
              // Show Success Message
              Show_Success_Toastr(result[0].result_description);
              $("#modelEntryExcelUpload").modal("hide");
              GetUpdatedFarmerCollectionList();
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Farmer details not saved");
          },
        });
      } else {
        Hide_Loader();
        Show_Error_Toastr(response.data);
      }

      // Hide_Loader();
    },
    error: function (msg) {
      Hide_Loader();
      Show_Error_Toastr(msg);
      // Hide_Loader();
    },
  });
}

$("#modelEntryExcelUpload").on("hidden.bs.modal", function (e) {
  // Clear the file input field
  $("#txtEntryExcelUpload").val("");

  // Optionally, you can also reset the dropify plugin if you are using it
  // $("#txtEntryExcelUpload").dropifyReset();
});

function Approval() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        var DAIRYfatkg = $("#lblDAIRYfatkg").html();
        var DAIRYsnfkg = $("#lblDAIRYsnfkg").html();
        var MCCfatkg = $("#lblMCCfatkg").html();
        var MCCsnfkg = $("#lblMCCsnfkg").html();

        var differencefatkg = DAIRYfatkg - MCCfatkg;
        var differencesnfkg = DAIRYsnfkg - MCCsnfkg;

        if (MCCfatkg == 0) {
          ShowEntryError(
            "Updated details can't be saved as new quantity is zero."
          );
          GetMCCCollectionList();
          return;
        }
        if (MCCsnfkg == 0) {
          ShowEntryError(
            "Updated details can't be saved as new quantity is zero."
          );
          GetMCCCollectionList();
          return;
        }

        if (differencefatkg < 0) {
          // // console.log("1");
          ShowEntryError(
            "Updated details can't be saved as updated KgFAT or KgSNF are more than dairy KgFat or KgSNF"
          );
          GetMCCCollectionList();
          return;
        }

        if (differencesnfkg < 0) {
          // // console.log("1");
          ShowEntryError(
            "Updated details can't be saved as updated KgFAT or KgSNF are more than dairy KgFat or KgSNF"
          );
          GetMCCCollectionList();
          return;
        }
        // debugger;
        Show_Loader();
        var MCC_Id = $("#lblMCCId").html();
        var TripDocument_Id = $("#lblTripDocumentId").html();
        var CollectionShift_Id = $("#lblCollectionShift").html();
        var MCCCollectionShift_Id = $("#lblMCCCollectionShiftId").html();
        var Method_Name = "Delete_FarmerData";
        var MilkCollectionDairyId = $("#lblSetEntryId").html();
        var APIEndPoint = "SavedInvoiceFarmerIncome";
        var url = "/invoice/InvoiceFarmerIncome";

        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          tripdocument_id: TripDocument_Id,
          mcccollectionshift_id: MCCCollectionShift_Id,
          collectionshift_id: CollectionShift_Id,
          milkcollectiondairy_id: MilkCollectionDairyId,
        };

        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);

            // // console.log(result);
            if (result[0].result_id == 1) {
              Hide_Loader();
              // Show Success Message
              Show_Success_Toastr(result[0].result_description);

              // GetMCCCollectionList();

              var set_MCC_Name = $("#txtEntryMCCName").val();
              var set_CollectionShift_Name = $(
                "#txtEntryMilkCollectionShift"
              ).val();

              var set_MilkCollectionDairyId = $(
                "#lblMilkCollectionDairyId"
              ).html();
              var set_TripDocumentId = $("#lblTripDocumentId").html();
              var set_MCC_Id = $("#lblMCCId").html();
              var set_CollectionShift_Id = $("#lblCollectionShift").html();
              var set_MCCCollectionShift_Id = $(
                "#lblMCCCollectionShiftId"
              ).html();
              var set_SetEntry_Id = $("#lblSetEntryId").html();
              ShowEditEntry(
                set_SetEntry_Id,
                set_MilkCollectionDairyId,
                set_TripDocumentId,
                set_MCC_Id,
                set_CollectionShift_Id,
                set_MCCCollectionShift_Id,
                set_MCC_Name,
                set_CollectionShift_Name,
                1
              );
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
              // $("#btn_MCCSave").show();
              // $("#modelEntryFarmerCollection").modal("hide");
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Agent details not saved");
            // $("#btn_MCCSave").show();
          },
        });
      }
      // if (result == false) {
      //   GetMCCCollectionList();
      // }
    }
  );
}

function ApprovalAuth() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        var DAIRYfatkg = $("#lblDAIRYfatkg").html();
        var DAIRYsnfkg = $("#lblDAIRYsnfkg").html();
        var MCCfatkg = $("#lblMCCfatkg").html();
        var MCCsnfkg = $("#lblMCCsnfkg").html();

        var differencefatkg = DAIRYfatkg - MCCfatkg;
        var differencesnfkg = DAIRYsnfkg - MCCsnfkg;

        if (MCCfatkg == 0) {
          ShowEntryError(
            "Updated details can't be saved as new quantity is zero."
          );
          GetMCCCollectionList();
          return;
        }
        if (MCCsnfkg == 0) {
          ShowEntryError(
            "Updated details can't be saved as new quantity is zero."
          );
          GetMCCCollectionList();
          return;
        }

        if (differencefatkg < 0) {
          // // console.log("1");
          ShowEntryError(
            "Updated details can't be saved as updated KgFAT or KgSNF are more than dairy KgFat or KgSNF"
          );
          // GetMCCCollectionList();
          // return;
        }

        if (differencesnfkg < 0) {
          // // console.log("1");
          ShowEntryError(
            "Updated details can't be saved as updated KgFAT or KgSNF are more than dairy KgFat or KgSNF"
          );
          // GetMCCCollectionList();
          // return;
        }
        // debugger;
        Show_Loader();
        var MCC_Id = $("#lblMCCId").html();
        var TripDocument_Id = $("#lblTripDocumentId").html();
        var CollectionShift_Id = $("#lblCollectionShift").html();
        var MCCCollectionShift_Id = $("#lblMCCCollectionShiftId").html();
        var Method_Name = "Delete_FarmerData";
        var MilkCollectionDairyId = $("#lblSetEntryId").html();
        var APIEndPoint = "SavedInvoiceFarmerIncome";
        var url = "/invoice/InvoiceFarmerIncome";

        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          tripdocument_id: TripDocument_Id,
          mcccollectionshift_id: MCCCollectionShift_Id,
          collectionshift_id: CollectionShift_Id,
          milkcollectiondairy_id: MilkCollectionDairyId,
        };

        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);

            // // console.log(result);
            if (result[0].result_id == 1) {
              Hide_Loader();
              // Show Success Message
              Show_Success_Toastr(result[0].result_description);

              // GetMCCCollectionList();

              var set_MCC_Name = $("#txtEntryMCCName").val();
              var set_CollectionShift_Name = $(
                "#txtEntryMilkCollectionShift"
              ).val();

              var set_MilkCollectionDairyId = $(
                "#lblMilkCollectionDairyId"
              ).html();
              var set_TripDocumentId = $("#lblTripDocumentId").html();
              var set_MCC_Id = $("#lblMCCId").html();
              var set_CollectionShift_Id = $("#lblCollectionShift").html();
              var set_MCCCollectionShift_Id = $(
                "#lblMCCCollectionShiftId"
              ).html();
              var set_SetEntry_Id = $("#lblSetEntryId").html();
              ShowEditEntry(
                set_SetEntry_Id,
                set_MilkCollectionDairyId,
                set_TripDocumentId,
                set_MCC_Id,
                set_CollectionShift_Id,
                set_MCCCollectionShift_Id,
                set_MCC_Name,
                set_CollectionShift_Name,
                1
              );
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
              // $("#btn_MCCSave").show();
              // $("#modelEntryFarmerCollection").modal("hide");
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Agent details not saved");
            // $("#btn_MCCSave").show();
          },
        });
      }
      // if (result == false) {
      //   GetMCCCollectionList();
      // }
    }
  );
}
function GetReverse(MCCCollectionShiftId, MCC_Id) {
  var APIEndPoint = "GetInvoiceFarmerIncome";
  var Method_Name = "Get_ReverseIncome";
  var url = "/invoice/InvoiceFarmerIncome";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcccollectionshift_id: MCCCollectionShiftId,
    mcc_id: MCC_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res[0].is_locked == 0) {
        $("#btn_Reverse").show();
        // $("#btn_Approve").hide();
      }
      if (res[0].is_locked == 1) {
        $("#btn_Reverse").hide();
        // $("#btn_Approve").show();
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

function SetReverse() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        Show_Loader();
        //Post it
        var APIEndPoint = "SaveInvoiceFarmerIncome";
        var Method_Name = "Set_ReverseIncome";
        var MilkCollectionDairyId = $("#lblSetEntryId").html();
        var MCC_Id = $("#lblMCCId").html();
        var url = "/invoice/InvoiceFarmerIncome";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          milkcollectiondairy_id: MilkCollectionDairyId,
          mcc_id: MCC_Id,
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
              Hide_Loader();
              Show_Success_Toastr("Farmer Income Reversed Successfully");
              CloseEntry();
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Farmer Income Not Reverse");
          },
        });
      }
    }
  );
}

function SetApprove() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        Show_Loader();
        //Post it
        var APIEndPoint = "SaveInvoiceFarmerIncome";
        var Method_Name = "Set_ApproveIncome";
        var MilkCollectionDairyId = $("#lblSetEntryId").html();
        var MCC_Id = $("#lblMCCId").html();
        var url = "/invoice/InvoiceFarmerIncome";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          milkcollectiondairy_id: MilkCollectionDairyId,
          mcc_id: MCC_Id,
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
              Hide_Loader();
              Show_Success_Toastr("Farmer Income Approved Successfully");
              CloseEntry();
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Farmer Income Not Approve");
          },
        });
      }
    }
  );
}

function SetGainLossApprove() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        Show_Loader();
        //Post it
        var MCC_Id = $("#lblMCCId").html();
        var TripDocument_Id = $("#lblTripDocumentId").html();
        var CollectionShift_Id = $("#lblCollectionShift").html();
        var MCCCollectionShift_Id = $("#lblMCCCollectionShiftId").html();
        var Method_Name = "Delete_FarmerData";
        var MilkCollectionDairyId = $("#lblSetEntryId").html();
        var APIEndPoint = "SavedInvoicedFarmerIncome";
        var url = "/invoice/InvoiceFarmerIncome";

        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          tripdocument_id: TripDocument_Id,
          mcccollectionshift_id: MCCCollectionShift_Id,
          collectionshift_id: CollectionShift_Id,
          milkcollectiondairy_id: MilkCollectionDairyId,
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
              Hide_Loader();
              Show_Success_Toastr("Farmer Income Approved Successfully");
              CloseEntry();
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Farmer Income Not Approve");
          },
        });
      }
    }
  );
}

function GainLossApproveEntry(
  SetEntry_Id,
  MilkCollectionDairyId,
  TripDocumentId,
  MCC_Id,
  CollectionShift_Id,
  MCCCollectionShift_Id,
  MCC_Name,
  CollectionShift_Name,
  Is_Locked
) {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        Show_Loader();
        var Method_Name = "Delete_FarmerData";
        var APIEndPoint = "SavedInvoicedFarmerIncome";
        var url = "/invoice/InvoiceFarmerIncome";

        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          tripdocument_id: TripDocumentId,
          mcccollectionshift_id: MCCCollectionShift_Id,
          collectionshift_id: CollectionShift_Id,
          milkcollectiondairy_id: SetEntry_Id,
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
              Hide_Loader();
              Show_Success_Toastr("Farmer Income Approved Successfully");
              GetSearchList();
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Farmer Income Not Approve");
          },
        });
      }
    }
  );
}
