$(document).ready(function () {
  $("#ddlSearchVehicleNo").select2();
  var date = new Date().toISOString().slice(0, 10);
  $("#txtSearchDuration").val(date);

  $("#ddlSearchVehicle").select2();
  GetMaster("ddlSearchVehicle", "Select Vehicle No", "GetVehicleNo", "", "");
  GetSearchList();
  $("#ddlSearchSupplierName").select2();
  GetMaster(
    "ddlSearchSupplierName",
    "Select Supplier Name",
    "GetBulkSupplierMCC",
    "",
    ""
  );

  $("#divddlSearchVehicleNo").hide();
  $("#divtxtSearchVehicleNo").hide();
  $("#divddlSearchSupplierName").hide();

  TruckFirstQty = $("#truckcollectionfirstqty").text().trim();
  TankerFirstQty = $("#tankercollectionfirstqty").text().trim();
});

$("#ddlSearchVehicle").on("change", function () {
  if ($("#ddlSearchVehicle").find(":selected").val() == "") {
    $("#divddlSearchVehicleNo").hide();
    $("#divtxtSearchVehicleNo").hide();
    $("#divddlSearchSupplierName").hide();
  } else if ($("#ddlSearchVehicle").find(":selected").val() == "1") {
    $("#divddlSearchVehicleNo").show();
    $("#divtxtSearchVehicleNo").hide();
    $("#divddlSearchSupplierName").hide();
  } else if ($("#ddlSearchVehicle").find(":selected").val() == "0") {
    $("#divddlSearchVehicleNo").hide();
    $("#divtxtSearchVehicleNo").show();
    $("#divddlSearchSupplierName").show();
  }
});

/*  ----    ----    ----    Get Milk Collection data and assign it to the table on Search Page    ----    ----    ----    ----    */
function GetSearchList() {
  ClearDataTable("tableSearch");
  // Get Milk Collection data from database and show in the table on Search page
  var APIEndPoint = "GetMilkCollection";
  var Search_Period = $("#txtSearchDuration").val();

  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  var SessionRoleId = $("#lblSessionRoleId").html();
  var Method_Name = "Get";
  var url = "/Collection/MilkCollection";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
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
        if (value.is_confirm == 0) {
          Status = "Open";
        } else {
          Status = "Confirmed";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.end_time + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.vehicletype_name + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 160px; padding:8px 5px 8px 5px;'>";
        EditFlag = value.is_locked;
        if (EditFlag == 0) {
          var action = "Edit";
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            //action +
            //"','" +
            value.vehicle_id +
            "', '" +
            value.milkcollectiondairy_id +
            "','" +
            value.tripdocument_id +
            "', '" +
            value.is_confirm +
            "', '" +
            value.is_release +
            "','" +
            value.vehicletype_name +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";

          if (
            value.is_confirm == 0 &&
            value.is_release == 0 &&
            SessionRoleId == "MU001"
          ) {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowDeleteEntry(\'' +
              value.milkcollectiondairy_id +
              "');\">";
            TableHTML += '<i class="fa fa-trash"></i>';
            TableHTML += "</a>";
          }
          if (
            value.is_confirm == 1 &&
            value.is_locked == 0 &&
            SessionRoleId == "MU001"
          ) {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ShowReverseEntry(\'' +
              value.milkcollectiondairy_id +
              "');\">";
            TableHTML += '<i class="fa fa-backward"></i>';
            TableHTML += "</a>";
          }
          if (
            value.vehicletype_name == "Truck" ||
            value.vehicletype_name == "Tanker"
          ) {
            if (value.is_km == "0") {
              TableHTML +=
                '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="KM" onclick="ShowKMEntry(\'' +
                value.milkcollectiondairy_id +
                "','" +
                value.tripdocument_id +
                "');\">";
              TableHTML += '<i class="fa fa-clock-o"></i>';
              TableHTML += "</a>";
            }
          }
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            //action +
            //"','" +
            value.vehicle_id +
            "', '" +
            value.milkcollectiondairy_id +
            "','" +
            value.tripdocument_id +
            "', '" +
            value.is_confirm +
            "', '" +
            value.is_release +
            "','" +
            value.vehicletype_name +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [8], "Milk Collection");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

/*  ----    ----    ----    Open Modal to select Vehicle No    ----    ----    ----    ----    */
function OpenModal() {
  $("#modelEntryVehicle")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  // Set vehicle drop down
  // val = vehicle id
  // name = trip document id
  // html = vehicle no
  $("#ddlSearchVehicleNo")
    .empty()
    .append(
      $("<option></option>").val("").html("Select Vehicle No").attr("name", "")
    );
  var Search_Period = $("#txtSearchDuration").val();

  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  var APIEndPoint = "GetMilkCollection";
  var url = "/Collection/MilkCollection";
  var reqdata = {
    method_name: "Get_Vehicle",
    api_end_point: APIEndPoint,
    //"vehicletype": "truck"
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      $.each(result, function (data, value) {
        $("#ddlSearchVehicleNo").append(
          $("<option></option>")
            .val(
              value.vehicle_id +
                "," +
                value.tripdocument_id +
                "," +
                value.vehicletype_name
            )
            .html(value.vehicle_no)
        );
      });
      $("#ddlSearchVehicleNo").val("");
      $("#txtSearchDuration").removeClass("is-invalid state-invalid");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching data");
    },
  });
}

/*  ----    ----    ----    Operation to perform when modal hides    ----    ----    ----    ----    */
$("#modelEntryVehicle").on("hidden.bs.modal", function (e) {
  $("#ddlSearchVehicle").val("");
  $("#ddlSearchVehicleNo").val("");
  $("#txtSearchVehicleNo").val("");
  $("#ddlSearchSupplierName").val("");
  $("#ddlSearchVehicle").removeClass("is-invalid state-invalid");
  $("#ddlSearchVehicleNo").removeClass("is-invalid state-invalid");
  $("#txtSearchVehicleNo").removeClass("is-invalid state-invalid");
  $("#ddlSearchSupplierName").removeClass("is-invalid state-invalid");
  $("#divddlSearchVehicleNo").hide();
  $("#divtxtSearchVehicleNo").hide();
  $("#divddlSearchSupplierName").hide();
});

function GetEntry(Vehicle_Id, TripDocument_Id, MCC_Id) {
  if (
    (TripDocument_Id == "" ||
      TripDocument_Id == null ||
      TripDocument_Id == undefined) &&
    (MCC_Id != "" || MCC_Id != null || MCC_Id != undefined)
  ) {
    var APIEndPoint = "SaveMilkCollection";
    var Method_Name = "BulkSupplier";
    var url = "/Collection/MilkCollection";
    var Search_Period = $("#txtSearchDuration").val();
    var reqdata = {
      method_name: Method_Name,
      vehicle_id: Vehicle_Id,
      api_end_point: APIEndPoint,
      mcc_id: MCC_Id,
      search_period: Search_Period,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res[0].result_id == 1) {
          ShowContentDiv(
            "Collection",
            "MilkCollectionTankerEntry",
            "",
            ShowAddEditEntry
          );
          // debugger;
          // if (
          //   $("#lbl_Release_BulkSupplier").html() == "" ||
          //   $("#lbl_Release_BulkSupplier").html() == null ||
          //   $("#lbl_Release_BulkSupplier").html() == undefined
          // ) {
          //   // $("#lbl_Release_BulkSupplier").html(1);
          //   $("#lbl_Release_BulkSupplier").html(1);
          // }
          // if (
          //   $("#lbl_Confirm_BulkSupplier").html() == "" ||
          //   $("#lbl_Confirm_BulkSupplier").html() == null ||
          //   $("#lbl_Confirm_BulkSupplier").html() == undefined
          // ) {
          //   // $("#lbl_Confirm_BulkSupplier").html(1);
          //   $("#lbl_Confirm_BulkSupplier").html(1);
          // }
          GetTankerQuantityList();
          GetTankerQualityList();
        } else {
          return;
        }
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  }
  var APIEndPoint = "GetMilkCollection";
  var Search_Period = $("#txtSearchDuration").val();
  var url = "/Collection/MilkCollection";
  var reqdata = {
    method_name: "Get_Entry",
    api_end_point: APIEndPoint,
    vehicle_id: Vehicle_Id,
    tripdocument_id: TripDocument_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result.length > 0) {
        var MilkCollectionDairy_id = result[0].milkcollectiondairy_id;
        var _IsConfirmed = result[0].is_confirm;
        var _IsReleased = result[0].is_release;
        var vehicletypeName = result[0].vehicletype_name;
        if (MilkCollectionDairy_id != "") {
          ShowEditEntry(
            Vehicle_Id,
            MilkCollectionDairy_id,
            TripDocument_Id,
            _IsConfirmed,
            _IsReleased,
            vehicletypeName
          );
          // GetTankerQuantityList();
          // GetTankerQualityList();
        }
      } else {
        // Show Entr pages depending on Vehicle Type
        if (vehicleTypeName == "Truck") {
          ShowContentDiv(
            "Collection",
            "MilkCollectionTruckEntry",
            "",
            ShowAddEditEntry
          );
        } else if (vehicleTypeName == "Tanker") {
          ShowContentDiv(
            "Collection",
            "MilkCollectionTankerEntry",
            "",
            ShowAddEditEntry
          );
          GetTankerQuantityList();
          GetTankerQualityList();
        }
        // else if (vehicleTypeName == "BulkSupplier") {
        //   ShowContentDiv(
        //     "Collection",
        //     "MilkCollectionTankerEntry",
        //     "",
        //     ShowAddEditEntry
        //   );
        //   // GetTankerQuantityList();
        //   // GetTankerQualityList();
        // }
      }
    },
    error: function () {},
  });
}

function ShowAddEntry() {
  // if already present, call ShowEditEntry()

  var ddlVehicleNoType = $("#ddlSearchVehicle").val();
  var ddlVehicleNo = $("#ddlSearchVehicleNo").val();
  var txtVehicleNo = $("#txtSearchVehicleNo").val();
  var ddlSupplierName = $("#ddlSearchSupplierName").val();

  if (
    ddlVehicleNoType == "" ||
    ddlVehicleNoType == undefined ||
    ddlVehicleNoType == null
  ) {
    $("#ddlSearchVehicle").addClass("is-invalid state-invalid");
    return;
  }

  if (ddlVehicleNoType == "1") {
    if (
      ddlVehicleNo == "" ||
      ddlVehicleNo == undefined ||
      ddlVehicleNo == null
    ) {
      $("#ddlSearchVehicleNo").addClass("is-invalid state-invalid");
      return;
    }
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    var temp = $("#ddlSearchVehicleNo").val().split(",");
    // Global Variables - can be used anywhere in the program
    Vehicle_Id = temp[0];
    TripDocument_Id = temp[1];
    vehicleTypeName = temp[2];
    MilkCollectionDairy_Id = "";
    $("#modelEntryVehicle").modal("hide");
    Is_Confirmed = 0;
    Is_Released = 0;
    MCC_Id = "";
    //$("#btn_Confirm_Tanker").prop("hidden", false);
    //$("#btn_Release_Tanker").prop("hidden", false);

    GetEntry(Vehicle_Id, TripDocument_Id, "");
  }
  if (ddlVehicleNoType == "0") {
    var IsValid = 1;
    if (
      txtVehicleNo == "" ||
      txtVehicleNo == undefined ||
      txtVehicleNo == null
    ) {
      IsValid = 0;
      $("#txtSearchVehicleNo").addClass("is-invalid state-invalid");
    }
    if (
      ddlSupplierName == "" ||
      ddlSupplierName == undefined ||
      ddlSupplierName == null
    ) {
      $("#ddlSearchSupplierName").addClass("is-invalid state-invalid");
      IsValid = 0;
    }
    if (IsValid == 0) {
      ShowEntryError("Invalid Input(s). Can't be saved.");
      return;
    }
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    var temp = $("#txtSearchVehicleNo").val();
    // Global Variables - can be used anywhere in the program
    Vehicle_Id = temp;
    TripDocument_Id = "";
    vehicleTypeName = "BulkSupplier";
    MilkCollectionDairy_Id = "";
    MCC_Id = ddlSupplierName;
    $("#modelEntryVehicle").modal("hide");
    Is_Confirmed = 0;
    Is_Released = 0;
    GetEntry(Vehicle_Id, "", MCC_Id);
  }
}

/*  ----    ----    ----    Open Entry page and assign values based on Add/Edit action    ----    ----    ----    ----    */
function ShowEditEntry(
  VehicleId,
  MilkCollectionDairyId,
  TripDocumentId,
  _IsConfirmed,
  _IsReleased,
  vehicletypeName
) {
  vehicleTypeName = vehicletypeName;

  // global variables - can be used throuout the program.
  Vehicle_Id = VehicleId;
  MilkCollectionDairy_Id = MilkCollectionDairyId;
  TripDocument_Id = TripDocumentId;
  Is_Confirmed = _IsConfirmed;
  Is_Released = _IsReleased;

  $("#lblEntryId").html(MilkCollectionDairyId);
  $("#lblAction").html("Edit");
  if (vehicleTypeName == "Tanker" || vehicleTypeName == "BulkSupplier") {
    $("#ddlEntryTankerQuantityCellNo").select2();
    $("#ddlEntryTankerQuantityMilkStatus").select2();
    $("#ddlEntryTankerQuantityMilkType").select2();
    $("#ddlEntryTankerQualityMilkStatus").select2();
    // $("#ddlEntryTankerQualityBatchId").select2();
    $("#ddlEntryTankerQualityCellNo").select2();

    GetMaster(
      "ddlEntryTankerQuantityCellNo",
      "Select Cell No",
      "GetNoOfCellsInTanker",
      "",
      TripDocument_Id
    );

    //alert($("#ddlEntryTankerQuantityCellNo option").length);
    cellsLength = $("#ddlEntryTankerQuantityCellNo option").length;
    GetMaster(
      "ddlEntryTankerQualityCellNo",
      "Select Cell No",
      "GetNoOfCellsInTanker",
      "",
      TripDocument_Id
    );
    GetMaster(
      "ddlEntryTankerQuantityMilkStatus",
      "Select Milk Status",
      "GetMilkStatusGood",
      "",
      ""
    );
    GetMaster(
      "ddlEntryTankerQualityMilkStatus",
      "Select Milk Status",
      "GetMilkStatusGood",
      "",
      ""
    );
    // SetBatchIdDDLTanker(
    //   "ddlEntryTankerQualityBatchId",
    //   MilkCollectionDairyId,
    //   TripDocumentId,
    //   ""
    // );
    GetMaster(
      "ddlEntryTankerQuantityMilkType",
      "Select Milk Type",
      "GetMilkType",
      "",
      ""
    );
  }
  // debugger;
  // show/hide confirm button
  if (Is_Confirmed == 1) {
    //hide confirm button
    $("#lbl_Confirm_BulkSupplier").html(1);
    $("#btn_Confirm_" + vehicleTypeName).prop("hidden", true);
    // $("#btn_Confirm_BulkSupplier").hide();
  }
  if (Is_Confirmed == 0) {
    //show
    $("#lbl_Confirm_BulkSupplier").html(0);
    $("#btn_Confirm_" + vehicleTypeName).prop("hidden", false);
    // $("#btn_Confirm_BulkSupplier").show();
  }
  // // console.log("Is_Confirmed", Is_Confirmed);

  // show/hide released button
  if (Is_Released == 1) {
    //hide
    $("#lbl_Release_BulkSupplier").html(1);
    $("#btn_Release_" + vehicleTypeName).prop("hidden", true);
    // $("#btn_Release_BulkSupplier").show();
  }
  if (Is_Released == 0) {
    //show
    $("#lbl_Release_BulkSupplier").html(0);
    $("#btn_Release_" + vehicleTypeName).prop("hidden", false);
    // $("#btn_Release_BulkSupplier").show();
  }
  // // console.log("Is_Released", Is_Released);
  // Show Entr pages depending on Vehicle Type
  if (vehicleTypeName == "Truck") {
    ShowContentDiv(
      "Collection",
      "MilkCollectionTruckEntry",
      "",
      ShowAddEditEntry
    );
  } else if (vehicleTypeName == "Tanker") {
    ShowContentDiv(
      "Collection",
      "MilkCollectionTankerEntry",
      "",
      ShowAddEditEntry
    );
    GetTankerQuantityList();
    GetTankerQualityList();
  } else if (vehicleTypeName == "BulkSupplier") {
    ShowContentDiv(
      "Collection",
      "MilkCollectionTankerEntry",
      "",
      ShowAddEditEntry
    );
    GetTankerQuantityList();
    GetTankerQualityList();
  }
}
function ShowAddEditEntry() {
  // debugger;

  $("#divEntryTankerRouteName").hide();
  $("#divEntryTankerMCCName").hide();
  $("#divEntryTankerShift").hide();
  var APIEndPoint = "GetMilkCollection";
  var Method_Name = "Get_One";
  var Search_Period = $("#txtSearchDuration").val();
  var url = "/Collection/MilkCollection";
  var reqdata = {
    method_name: Method_Name,
    vehicle_id: Vehicle_Id,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length > 0) {
        VehicleType_Id = res[0].vehicletype_id;
        VehicleTypeName = res[0].vehicletype_name;
        if (VehicleTypeName == "Truck") {
          $("#divEntryTankerRouteName").show();
          $("#divEntryTankerMCCName").hide();
          $("#divEntryTankerShift").show();
          GetTruckMCCList(Vehicle_Id, TripDocument_Id);
        }

        // Tanker
        if (VehicleTypeName == "Tanker") {
          $("#divEntryTankerRouteName").show();
          $("#divEntryTankerMCCName").hide();
          $("#divEntryTankerShift").show();
          // Setting Input Field Values
          $("#txtEntryTankerVehicleNo").val(res[0].vehicle_no);
          $("#txtEntryTankerRouteName").val(res[0].route_name);
          $("#txtEntryTankerShift").val(res[0].collectionshift_name);
          $("#txtEntryTankerTime").val(res[0].end_time);

          if (TankerFirstQty == "1") {
            $("#divTankerQualityList").insertAfter("#divTankerQuantityList");
          } else if (TankerFirstQty == "0") {
            $("#divTankerQuantityList").insertAfter("#divTankerQualityList");
          }
        }
        if (VehicleTypeName == "BulkSupplier") {
          // $("#btn_Release_BulkSupplier").prop("hidden", true);
          // $("#btn_Confirm_BulkSupplier").prop("hidden", true);
          // debugger;

          if (
            $("#lbl_Release_BulkSupplier").html() == "0" ||
            Is_Released == 0
          ) {
            $("#btn_Release_BulkSupplier").prop("hidden", false);
          }
          if (
            $("#lbl_Release_BulkSupplier").html() == "1" ||
            Is_Released == 1
          ) {
            $("#btn_Release_BulkSupplier").prop("hidden", true);
          }
          if (
            $("#lbl_Confirm_BulkSupplier").html() == "0" ||
            Is_Confirmed == 0
          ) {
            $("#btn_Confirm_BulkSupplier").prop("hidden", false);
          }
          if (
            $("#lbl_Confirm_BulkSupplier").html() == "1" ||
            Is_Confirmed == 1
          ) {
            $("#btn_Confirm_BulkSupplier").prop("hidden", true);
          }
          // $("#lbl_Release_BulkSupplier").html(0);
          // $("#lbl_Confirm_BulkSupplier").html(0);
          $("#divEntryTankerRouteName").hide();
          $("#divEntryTankerMCCName").show();
          $("#divEntryTankerShift").hide();
          // Setting Input Field Values
          $("#txtEntryTankerVehicleNo").val(res[0].vehicle_no);
          $("#txtEntryTankerMCCName").val(res[0].mcc_name);
          $("#txtEntryTankerTime").val(res[0].end_time);

          if (TankerFirstQty == "1") {
            $("#divTankerQualityList").insertAfter("#divTankerQuantityList");
          } else if (TankerFirstQty == "0") {
            $("#divTankerQuantityList").insertAfter("#divTankerQualityList");
          }
        }

        // Truck
        else {
          // Setting Input Field Values
          $("#txtEntryTruckVehicleNo").val(res[0].vehicle_no);
          $("#txtEntryTruckRouteName").val(res[0].route_name);
          $("#txtEntryTruckShift").val(res[0].collectionshift_name);
          $("#txtEntryTruckTime").val(res[0].end_time);
        }
      }
      // else {
      //   // console.log("BulkSupplier");
      //   $("#divEntryTankerRouteName").hide();
      //   $("#divEntryTankerMCCName").show();
      //   $("#divEntryTankerShift").hide();
      //   $("#ddlEntryTankerQuantityCellNo").select2();
      //   $("#ddlEntryTankerQualityCellNo").select2();
      //   GetMaster(
      //     "ddlEntryTankerQuantityCellNo",
      //     "Select Cell No",
      //     "GetNoOfCellsInBulkSupplier",
      //     "",
      //     ""
      //   );
      //   GetMaster(
      //     "ddlEntryTankerQualityCellNo",
      //     "Select Cell No",
      //     "GetNoOfCellsInBulkSupplier",
      //     "",
      //     ""
      //   );
      // }
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
  $("#modelEntryVehicle").modal("hide");
}

/*  ----    ----    ----    Get list of MCC for selected Vehicle    ----    ----    ----    ----    */
function GetTruckMCCList(Vehicle_Id, TripDocument_Id) {
  // Get MilkCollection data from database and show in the table on Search page
  var APIEndPoint = "GetMilkCollection";
  var Method_Name = "Get_MCCList";
  var Search_Period = $("#txtSearchDuration").val();
  var url = "/Collection/MilkCollection";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
    vehicle_id: Vehicle_Id,
    search_period: Search_Period,
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
      Is_All_Collected = 1;
      Is_Any_One_Collected = 0;
      $.each(res, function (data, value) {
        var EditFlag = 0;
        var CollectionStatus = "";
        // 0 = not collected = edit
        // 1 = collected = view only
        if (value.is_collected == 0) {
          CollectionStatus = "Not Collected";
          EditFlag = 1;
          Is_All_Collected = 0;
        } else {
          CollectionStatus = "Collected";
          Is_Any_One_Collected = 1;
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        // TableHTML += "<td>" + value.fat + "</td>";
        // TableHTML += "<td>" + value.snf + "</td>";

        TableHTML += "<td>" + CollectionStatus + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == 1) {
          var action = "Edit";
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowTruckMCCEntry(\'' +
            action +
            "','" +
            value.mcc_id +
            "', '" +
            value.mcc_name +
            "','" +
            MilkCollectionDairy_Id +
            "','" +
            value.mcccollectionshift_id +
            "','" +
            value.created_on +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          var action = "View";
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowTruckMCCEntry(\'' +
            action +
            "','" +
            value.mcc_id +
            "', '" +
            value.mcc_name +
            "','" +
            MilkCollectionDairy_Id +
            "','" +
            value.mcccollectionshift_id +
            "','" +
            value.created_on +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableTruckMCCList");
      $("#tableTruckMCCData").html(TableHTML);
      SetDataTable("tableTruckMCCList", [5], "MCC Collection List");
      if (Is_All_Collected == 1 && Is_Confirmed == 1) {
        $("#btn_Confirm_" + vehicleTypeName).prop("hidden", true);
      } else if (Is_All_Collected == 1 && Is_Confirmed == 0) {
        $("#btn_Confirm_" + vehicleTypeName).prop("hidden", false);
      } else {
        // hide confirm
        $("#btn_Confirm_" + vehicleTypeName).prop("hidden", true);
      }

      if (Is_Any_One_Collected == 1 && Is_Released == 1) {
        // show/hide released button
        $("#btn_Release_" + vehicleTypeName).prop("hidden", true);
      } else if (Is_Any_One_Collected == 1 && Is_Released == 0) {
        $("#btn_Release_" + vehicleTypeName).prop("hidden", false);
      } else {
        // hide release
        $("#btn_Release_" + vehicleTypeName).prop("hidden", true);
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

/*  ----    ----    ----    Hide the Entry Page    ----    ----    ----    ----    */
function CloseEntry() {
  HideContentDiv();
  GetSearchList();
  $("#lbl_Release_BulkSupplier").html("");
  $("#lbl_Release_BulkSupplier").html("");
}

/*  ----    ----    ----    Hide the MCC Entry Page and Show Entry Page    ----    ----    ----    ----    */
function CloseTruckMCCEntry() {
  $("#divSearch").hide();
  $("#divMCCEntry").hide();
  $("#divContent").show();
  GetTruckMCCList(Vehicle_Id, TripDocument_Id);
}

/*  ----    ----    ----    Save Confirm for Truck/Tanker Entry    ----    ----    ----    ----    */
function SaveConfirm(Vehicle_Type_For_Buttons) {
  $("#btn_Confirm_" + Vehicle_Type_For_Buttons).prop("hidden", true);
  if (Vehicle_Type_For_Buttons == "BulkSupplier") {
    $("#lbl_Confirm_BulkSupplier").html(1);
  }
  var APIEndPoint = "SaveMilkCollection";
  var Search_Period = $("#txtSearchDuration").val();
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var url = "/Collection/MilkCollection";
  var VehicleType_Id_Confirm = "C020001";
  if (Vehicle_Type_For_Buttons == "Tanker") {
    VehicleType_Id_Confirm = "C020002";
  }
  var reqdata = {
    method_name: "Confirm",
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    tripdocument_id: TripDocument_Id,
    vehicletype_id: VehicleType_Id_Confirm,
    search_period: Search_Period,
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
        Is_Confirmed = 1;
        $("#btn_Confirm_" + Vehicle_Type_For_Buttons).prop("hidden", true);
        /*if (Vehicle_Type_For_Buttons == "Tanker") {
                                            GetTankerQuantityList();
                                            GetTankerQualityList();
                                        }*/
        /*else {
                                            GetTruckQuantityList();
                                            GetTruckQualityList();
                                        }*/

        Show_Success_Toastr("Confirmed successfully");
      } else {
        $("#btn_Confirm_" + Vehicle_Type_For_Buttons).prop("hidden", false);
        ShowEntryError("Error : " + result[0].result_description);
      }
      if (Vehicle_Type_For_Buttons == "Tanker") {
        GetTankerQuantityList();
        GetTankerQualityList();
      }
      if (Vehicle_Type_For_Buttons == "BulkSupplier") {
        GetTankerQuantityList();
        GetTankerQualityList();
      }
    },
    error: function () {
      $("#btn_Confirm_" + Vehicle_Type_For_Buttons).prop("hidden", false);
      Show_Error_Toastr("Error occured while Confirming.");
    },
  });
}

/*  ----    ----    ----    Release vehicle for Truck/Tanker Entry    ----    ----    ----    ----    */

function SaveRelease(Vehicle_Type_For_Buttons) {
  $("#btn_Release_" + Vehicle_Type_For_Buttons).prop("hidden", true);
  if (Vehicle_Type_For_Buttons == "BulkSupplier") {
    $("#lbl_Release_BulkSupplier").html(1);
  }
  var APIEndPoint = "SaveMilkCollection";
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var Search_Period = $("#txtSearchDuration").val();

  var VehicleType_Id_Release = "";
  if (Vehicle_Type_For_Buttons == "Truck") {
    VehicleType_Id_Release = "C020001";
  }

  var url = "/Collection/MilkCollection";
  var reqdata = {
    method_name: "Release",
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    vehicletype_id: VehicleType_Id_Release,
    search_period: Search_Period,
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
        Is_Released = 1;
        $("#btn_Release_" + Vehicle_Type_For_Buttons).prop("hidden", true);
        Show_Success_Toastr(
          Vehicle_Type_For_Buttons + " Released successfully"
        );
      } else {
        $("#btn_Release_" + Vehicle_Type_For_Buttons).prop("hidden", false);
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      $("#btn_Release_" + Vehicle_Type_For_Buttons).prop("hidden", false);
      Show_Error_Toastr("Error");
    },
  });
}

/*  ----    ----    ----    Save Milk Collection - MilkCollection record. Is called from MCC Entry Page    ----    ----    ----    ----    */
function SaveTruckMCCEntry() {
  $("#btn_Save_MCC_Entry").prop("hidden", true);
  var APIEndPoint = "SaveMilkCollection";
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "Create";
  var Action_Name = $("#lblAction").html();
  MilkCollectionDairy_Id = "";
  if (Action_Name == "Edit") {
    //Method_Name = 'Update';
    MilkCollectionDairy_Id = $("#lblEntryId").html();
  }
  var MilkData = "<Milk>";

  $("#tableMCCAgentEntryList tbody tr").each(function () {
    MilkData += "<MilkData>";
    MilkData +=
      "<MilkType_Id>" + $(this).find("td:eq(1)").text() + "</MilkType_Id>";
    MilkData +=
      "<MilkStatus_Id>" + $(this).find("td:eq(2)").text() + "</MilkStatus_Id>";
    MilkData += "</MilkData>";
  });

  MilkData += "</Milk>";

  var url = "/Collection/MilkCollection";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    tripdocument_id: TripDocument_Id,
    mcccollectionshift_id: MCCCollectionShift_Id,
    mcc_id: MCC_Id,
    vehicle_id: Vehicle_Id,
    milkdata: MilkData,
    search_period: Search_Period,
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
        //GetSearchList();
        $("#lblEntryId").html(result[0].result_extra_key);
        MilkCollectionDairy_Id = result[0].result_extra_key;
        $("#lblAction").html("Edit");
        $("#lblMCCEntryAction").html("View");
        $("#btn_Save_MCC_Entry").prop("hidden", true);
        Show_Success_Toastr(
          "MCC Collection - Milk Collection details saved successfully"
        );
        GetTruckQuantityList();
        $("#divTruckQuantityList").show();
        GetTruckQualityList();
        $("#divTruckQualityList").show();
      } else {
        $("#btn_Save_MCC_Entry").prop("hidden", false);
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      $("#btn_Save_MCC_Entry").prop("hidden", false);
      Show_Error_Toastr("Error : Milk Collection details not saved");
    },
  });
}

/*  ----    ----    ----    Openig MCC Entry Page and Assigning Input fields values & Assiging Quantity & Quality Tables    ----    ----    ----    ----    */
function ShowTruckMCCEntry(
  Action,
  mcc_id,
  mcc_name,
  milkcollectiondairy_id,
  mcccollectionshift_id,
  created_on
) {
  // global variables
  MCC_Id = mcc_id;
  MCCCollectionShift_Id = mcccollectionshift_id;
  MCC_Name = mcc_name;
  MilkCollectionDairy_Id = milkcollectiondairy_id;
  CreatedOn = created_on;

  // get _MilkCollectionMCCEntry page html
  $.ajax({
    url: "/Collection/MilkCollectionMCCEntry",
    success: function (result) {
      if (result.trim() != "") {
        // Hiding MilkCollection Entry and Displaying MilkCollection MCC Entry
        $("#divContent").hide();
        $("#divMCCEntry").html(result);
        $("#divMCCEntry").show();

        if (TruckFirstQty == "1") {
          $("#divTruckQualityList").insertAfter("#divTruckQuantityList");
        } else if (TruckFirstQty == "0") {
          $("#divTruckQuantityList").insertAfter("#divTruckQualityList");
        }

        $("#ddlEntryTruckQualityMilkStatus").select2();
        $("#ddlEntryTruckQualityBatchId").select2();
        $("#ddlEntryTruckQuantityMilkStatus").select2();
        $("#ddlEntryTruckQuantityMilkType").select2();
        // $("#ddlEntryTruckQuantityBatchId").select2();
        GetMaster(
          "ddlEntryTruckQualityMilkStatus",
          "Select Milk Status",
          "GetMilkStatusGood",
          "",
          ""
        );
        SetBatchIdDDLTruck(
          "ddlEntryTruckQualityBatchId",
          MilkCollectionDairy_Id,
          TripDocument_Id,
          MCCCollectionShift_Id,
          MCC_Id,
          "",
          "USP_AdminMilkCollectionTruckQuality_Get"
        );
        // SetBatchIdDDLTruck(
        //     "ddlEntryTruckQuantityBatchId",
        //     MilkCollectionDairy_Id,
        //     TripDocument_Id,
        //     MCCCollectionShift_Id,
        //     MCC_Id,
        //     "",
        //     "USP_AdminMilkCollectionTruckQuantity_Get"
        // );
        GetMaster(
          "ddlEntryTruckQuantityMilkStatus",
          "Select Milk Status",
          "GetMilkStatusGood",
          "",
          ""
        );
        GetMaster(
          "ddlEntryTruckQuantityMilkType",
          "Select Milk Type",
          "GetMilkType",
          "",
          ""
        );

        // Setting Input Field values of main section
        $("#txtMCCEntryVehicleNo").val($("#txtEntryTruckVehicleNo").val());
        $("#txtMCCEntryRouteName").val($("#txtEntryTruckRouteName").val());
        $("#txtMCCEntryShift").val($("#txtEntryTruckShift").val());
        $("#txtMCCEntryTime").val($("#txtEntryTruckTime").val());

        $("#txtMCCEntryMCCName").val(MCC_Name);
        $("#txtMCCEntryCollectionDate").val(CreatedOn);

        // Show hide Quantity & Quality section based on action

        // Hide Collect Button if in Edit mode
        // Hide Add button for  VIEW
        if (Action == "View") {
          $("#btn_Save_MCC_Entry").prop("hidden", true);
          $("#lblMCCEntryAction").html("View");
          //$("#btnAddQuantity").hide();
          //$("#btnAddQuality").hide();
          GetTruckQuantityList();
          GetTruckQualityList();
          $("#divTruckQuantityList").show();
          $("#divTruckQualityList").show();
        }
        // Show Add Button for EDIT
        else {
          $("#btn_Save_MCC_Entry").prop("hidden", false);
          $("#lblMCCEntryAction").html("Edit");
          //$("#btnAddQuantity").show();
          //$("#btnAddQuality").show();
          $("#divTruckQuantityList").hide();
          $("#divTruckQualityList").hide();
        }

        // Assign input field values for section - Details Entered by MCC Agent
        var APIEndPoint = "GetMilkCollection";
        var Method_Name = "Get_AgentEntry";
        var url = "/Collection/MilkCollection";
        var Search_Period = $("#txtSearchDuration").val();
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          vehicle_id: Vehicle_Id,
          mcc_id: MCC_Id,
          mcccollectionshift_id: MCCCollectionShift_Id,
          search_period: Search_Period,
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

            $.each(res, function (data, value) {
              TableHTML += "<tr>";
              TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
              TableHTML += "<td hidden>" + value.milktype_id + "</td>";
              TableHTML += "<td hidden>" + value.milkstatus_id + "</td>";
              TableHTML += "<td>" + value.milktype_name + "</td>";
              TableHTML += "<td>" + value.milkstatus_name + "</td>";
              //TableHTML += "<td>" + value.weight + "</td>";
              TableHTML += "<td>" + value.quantity_ltr + "</td>";
              TableHTML += "<td>" + value.fat + "</td>";
              TableHTML += "<td>" + value.snf + "</td>";

              TableHTML += "<td>" + value.cans + "</td>";

              TableHTML += "<td hidden></td>";
              TableHTML += "</tr>";
            });
            ClearDataTable("tableMCCAgentEntryList");
            $("#tableMCCAgentEntryData").html(TableHTML);
            SetDataTable("tableMCCAgentEntryList", [9], "MCC Collection List");
          },
          error: function (result) {
            Show_Error_Toastr("Error in fetching details from server.");
          },
        });
      }
    },
    error: function (result) {
      if (result.status == "401") {
        Show_Error_Toastr("You are not authorized to perform this transaction");
      }
    },
  });
}

function SetBatchIdDDLTruck(
  ddl_Id,
  MilkCollectionDairy_Id,
  TripDocument_Id,
  MCCCollectionShift_Id,
  MCC_Id,
  Value,
  Stored_Procedure
) {
  $("#" + ddl_Id)
    .empty()
    .append(
      $("<option></option>").val("").html("Select Batch No").attr("name", "")
    );
  var APIEndPoint = "GetMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var Stored_Procedure = Stored_Procedure;
  var Search_Period = $("#txtSearchDuration").val();
  var reqdata = {
    method_name: "Get_BatchId",
    api_end_point: APIEndPoint,
    stored_procedure: Stored_Procedure,
    mcc_id: MCC_Id,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    mcccollectionshift_id: MCCCollectionShift_Id,
    tripdocument_id: TripDocument_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      $.each(result, function (data, value) {
        $("#" + ddl_Id).append(
          $("<option></option>").val(value.batch_id).html(value.batch_id)
        );
      });
      $("#" + ddl_Id).val(Value);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching data");
    },
  });
}

/*  ----    ----    ----    Open Modal for Truck Quantity of Milk at Dairy    ----    ----    ----    ----    */
function OpenTruckQuantityModal(action, id) {
  ResetInputFields();
  $("#divTruckReasons").hide();
  $("#modelEntryTruckQuantityMilkCollection")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblActionTruckQuantity").html(action);
  $("#lblTruckQuantityId").html(id);

  if (action == "Add") {
    $("#AddEditTruckQuantityMilkCollection").text("Add Quantity Details");
    $("#ddlEntryTruckQuantityMilkStatus").prop("disabled", false);
    GetMaster(
      "ddlEntryTruckQuantityMilkStatus",
      "Select Milk Status",
      "GetMilkStatusGood",
      "",
      ""
    );
    GetMaster(
      "ddlEntryTruckQuantityMilkType",
      "Select Milk Type",
      "GetMilkType",
      "",
      ""
    );

    // SetBatchIdDDLTruck(
    //     "ddlEntryTruckQuantityBatchId",
    //     MilkCollectionDairy_Id,
    //     TripDocument_Id,
    //     MCCCollectionShift_Id,
    //     MCC_Id,
    //     "",
    //     "USP_AdminMilkCollectionTruckQuantity_Get"
    // );

    var SessionRoleId = $("#lblSessionRoleId").html();
    if (SessionRoleId == "MU001" || SessionRoleId == "MU01241000008") {
      $("#txtEntryTruckQuantityWeight").prop("disabled", false);
    } else {
      $("#txtEntryTruckQuantityWeight").prop("disabled", true);
    }
  } else if (action == "Edit") {
    $("#AddEditTruckQuantityMilkCollection").text("Edit Quantity Details");
  }
  // if (TruckFirstQty == "1") {
  //     $("#ddlEntryTruckQuantityBatchIdCheck").hide();
  // } else if (TruckFirstQty == "0") {
  //     $("#txtEntryTruckQuantityCansCheck").hide();
  // }
}

/*  ----    ----    ----    Resetting Modal Input Fields on Modal Close/Hide    ----    ----    ----    ----    */
$("#modelEntryTruckQuantityMilkCollection").on("hidden.bs.modal", function (e) {
  $("#lblActionTruckQuantity").html("");
  $("#lblTruckQuantityId").html("");
  $("#AddEditTruckQuantityMilkCollection").text("");
  $("#txtEntryTruckReasons").val("");
  ResetInputFields();
});

/*  ----    ----    ----    Open modal to enter Quality of Milk at Dairy    ----    ----    ----    ----    */
function OpenTruckQualityModal(action, id) {
  ResetInputFields();
  $("#modelEntryTruckQualityMilkCollection")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblActionTruckQuality").html(action);
  $("#lblTruckQualityId").html(id);
  if (action == "Add") {
    GetMaster(
      "ddlEntryTruckQualityMilkStatus",
      "Select Milk Status",
      "GetMilkStatusGood",
      "",
      ""
    );
    // SetBatchIdDDLTruck(
    //     "ddlEntryTruckQualityBatchId",
    //     MilkCollectionDairy_Id,
    //     TripDocument_Id,
    //     MCCCollectionShift_Id,
    //     MCC_Id,
    //     "",
    //     "USP_AdminMilkCollectionTruckQuality_Get"
    // );
    $("#AddEditTruckQualityMilkCollection").text("Add Quality Details");
  } else if (action == "Edit") {
    $("#AddEditTruckQualityMilkCollection").text("Edit Quality Details");
  }

  // if (TruckFirstQty == "1") {
  //     $("#txtEntryTruckQualityCansCheck").hide();
  // } else if (TruckFirstQty == "0") {
  //     $("#ddlEntryTruckQualityBatchIdCheck").hide();
  // }
}

/*  ----    ----    ----    Resetting Modal Input Fields on Modal Close/Hide    ----    ----    ----    ----    */
$("#modelEntryTruckQualityMilkCollection").on("hidden.bs.modal", function (e) {
  $("#lblActionTruckQuality").html("");
  $("#AddEditTruckQualityMilkCollection").text("");
  ResetInputFields();
});

/*  ----    ----    ----    Save Truck Quantity at Dairy    ----    ----    ----    ----    */
function SaveTruckQuantity() {
  var QuantityMilkType_Id = $("#ddlEntryTruckQuantityMilkType").val();
  var QuantityMilkStatus_Id = $("#ddlEntryTruckQuantityMilkStatus").val();
  var QuantityWeight = $("#txtEntryTruckQuantityWeight").val();
  var Reasons = $("#txtEntryTruckReasons").val();

  // var QuantityBatch_Id = $("#ddlEntryTruckQuantityBatchId").val();
  var QuantityCans = $("#txtEntryTruckQuantityCans").val();

  var IsValid = 1;

  // if (QuantityBatch_Id == "" && TruckFirstQty == "0") {
  //     IsValid = 0;
  //     $("#ddlEntryTruckQuantityBatchId").addClass("is-invalid state-invalid");
  // }

  if (QuantityMilkType_Id == "") {
    IsValid = 0;
    $("#ddlEntryTruckQuantityMilkType").addClass("is-invalid state-invalid");
  }
  if (QuantityMilkStatus_Id == "") {
    IsValid = 0;
    $("#ddlEntryTruckQuantityMilkStatus").addClass("is-invalid state-invalid");
  }
  if (QuantityWeight == "") {
    IsValid = 0;
    $("#txtEntryTruckQuantityWeight").addClass("is-invalid state-invalid");
  }

  if (QuantityCans == "" && TruckFirstQty == "1") {
    IsValid = 0;
    $("#txtEntryTruckQuantityCans").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    Show_Loader();
    // Start Saving
    $("#btnTruckQuantitySave").prop("disabled", true);
    var APIEndPoint = "SaveMilkCollectionQuantity";
    var Method_Name = "Create";
    var MilkCollectionDairy_Id = $("#lblEntryId").html();
    var Entry_Id = "";
    var Action_Name = $("#lblActionTruckQuantity").html();
    var Search_Period = $("#txtSearchDuration").val();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblTruckQuantityId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Collection/MilkCollectionQuantity";
    var StoredProcedure = "USP_AdminMilkCollectionTruckQuantity_Set";

    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      milkcollectiondairy_id: MilkCollectionDairy_Id,
      entry_id: Entry_Id,
      milkstatus_id: QuantityMilkStatus_Id,
      milktype_id: QuantityMilkType_Id,
      weight: QuantityWeight,
      cans: QuantityCans,
      tripdocument_id: TripDocument_Id,
      mcc_id: MCC_Id,
      mcccollectionshift_id: MCCCollectionShift_Id,
      stored_procedure: StoredProcedure,
      reasons: Reasons,
      search_period: Search_Period,
      // batch_id: QuantityBatch_Id,
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
          MCCCollectionShift_Id = result[0].result_description;
          $("#lblTruckQuantityId").html(result[0].result_extra_key);
          $("#lblActionTruckQuantity").html("Edit");
          $("#modelEntryTruckQuantityMilkCollection").modal("hide");
          GetTruckQuantityList();
          GetTruckQualityList();
          ResetInputFields();

          Hide_Loader();
          Show_Success_Toastr("Quantity details saved successfully");
        } else {
          $("#modelEntryTruckQuantityMilkCollection").modal("hide");
          Hide_Loader();
          Show_Error_Toastr("Error : " + result[0].result_description);
          ResetInputFields();
        }
      },
      error: function (res) {
        Hide_Loader();
        $("#modelEntryTruckQuantityMilkCollection").modal("hide");
        Show_Error_Toastr("Error : Quantity details not saved");
      },
    });
    $("#btnTruckQuantitySave").prop("disabled", false);
  }
  return;
}

/*  ----    ----    ----    Save Truck Quality at Dairy    ----    ----    ----    ----    */
function SaveTruckQuality() {
  var QualitySampleNo = $("#txtEntryTruckQualitySampleNo").val();
  var QualityMilkStatus_Id = "C016001"; //$("#ddlEntryTruckQualityMilkStatus").val();
  var QualitySNF = $("#txtEntryTruckQualitySNF").val();
  var QualityFat = $("#txtEntryTruckQualityFat").val();

  // var QualityBatch_Id = $("#ddlEntryTruckQualityBatchId").val();
  // var QualityCans = $("#txtEntryTruckQualityCans").val();

  var IsValid = 1;

  // if (QualityBatch_Id == "" && TruckFirstQty == "1") {
  //     IsValid = 0;
  //     $("#ddlEntryTruckQualityBatchId").addClass("is-invalid state-invalid");
  // }
  if (QualityMilkStatus_Id == "") {
    IsValid = 0;
    $("#ddlEntryTruckQualityMilkStatus").addClass("is-invalid state-invalid");
  }

  if (QualitySampleNo == "") {
    IsValid = 0;
    $("#txtEntryTruckQualitySampleNo").addClass("is-invalid state-invalid");
  }
  // if (QualitySNF == "") {
  //   IsValid = 0;
  //   $("#txtEntryTruckQualitySNF").addClass("is-invalid state-invalid");
  // }
  // if (QualityFat == "") {
  //   IsValid = 0;
  //   $("#txtEntryTruckQualityFat").addClass("is-invalid state-invalid");
  // }
  // if (QualityCans == "" && TruckFirstQty == "0") {
  //     IsValid = 0;
  //     $("#txtEntryTruckQualityCans").addClass("is-invalid state-invalid");
  // }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btnTruckQualitySave").prop("disabled", true);
    var APIEndPoint = "SaveMilkCollectionQuality";
    var Method_Name = "Create";
    var MilkCollectionDairy_Id = $("#lblEntryId").html();
    var Entry_Id = "";
    var Action_Name = $("#lblActionTruckQuality").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblTruckQualityId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var Search_Period = $("#txtSearchDuration").val();
    var url = "/Collection/MilkCollectionQuality";
    var StoredProcedure = "USP_AdminMilkCollectionTruckQuality_Set";

    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      milkcollectiondairy_id: MilkCollectionDairy_Id,
      entry_id: Entry_Id,
      milkstatus_id: QualityMilkStatus_Id,
      // batch_id: QualityBatch_Id,
      sample_no: QualitySampleNo,
      snf: QualitySNF,
      fat: QualityFat,
      tripdocument_id: TripDocument_Id,
      mcc_id: MCC_Id,
      mcccollectionshift_id: MCCCollectionShift_Id,
      stored_procedure: StoredProcedure,
      search_period: Search_Period,
      // cans: QualityCans,
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
          $("#lblTruckQualityId").html(result[0].result_extra_key);
          $("#lblActionTruckQuality").html("Edit");
          $("#modelEntryTruckQualityMilkCollection").modal("hide");
          GetTruckQualityList();
          Show_Success_Toastr("Quality details saved successfully");
          $("#btnTruckQualitySave").prop("disabled", false);
        } else {
          $("#btnTruckQualitySave").prop("disabled", false);
          $("#modelEntryTruckQualityMilkCollection").modal("hide");
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        $("#btnTruckQualitySave").prop("disabled", false);
        $("#modelEntryTruckQualityMilkCollection").modal("hide");
        Show_Error_Toastr("Error : Quality details not saved");
      },
    });
  }
  return;
}

/*  ----    ----    ----    Set and Display Truck Quantity Table    ----    ----    ----    ----    */
function GetTruckQuantityList() {
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkCollectionQuantity";
  var url = "/Collection/MilkCollectionQuantity";
  var StoredProcedure = "USP_AdminMilkCollectionTruckQuantity_Get";

  var MilkCollectionDairy_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    mcccollectionshift_id: MCCCollectionShift_Id,
    mcc_id: MCC_Id,
    tripdocument_id: TripDocument_Id,
    stored_procedure: StoredProcedure,
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
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = true; // IsDelAllowed($("#lblAS").html());
      $("#btnTruckAddQuantity").show();
      $("#btnTruckRefresh").show();

      if (Is_Confirmed == 1) {
        EditFlag = false;
        DeleteFlag = false;
        $("#btnTruckAddQuantity").hide();
        $("#btnTruckRefresh").hide();
      }
      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        // TableHTML += "<td>" + value.batch_id + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.cans + "</td>";
        TableHTML += "<td>" + value.start_time + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
        if (EditFlag) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowTruckQuantityEditEntry(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag) {
          // TableHTML +=
          //   '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveTruckQuantityDeleteEntry(\'' +
          //   value.entry_id +
          //   "');\">";
          // TableHTML += '<i class="fa fa-trash"></i>';
          // TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableTruckMilkQuantityList");
      $("#tableTruckEntryQuantity").html(TableHTML);
      SetDataTable("tableTruckMilkQuantityList", [7], "Milk Quantity at Dairy");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

/*  ----    ----    ----    Set and Display Milk Quality Table    ----    ----    ----    ----    */
function GetTruckQualityList() {
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var StoredProcedure = "USP_AdminMilkCollectionTruckQuality_Get";
  var Search_Period = $("#txtSearchDuration").val();
  var MilkCollectionDairy_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    mcccollectionshift_id: MCCCollectionShift_Id,
    mcc_id: MCC_Id,
    tripdocument_id: TripDocument_Id,
    stored_procedure: StoredProcedure,
    search_period: Search_Period,
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
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = true; // IsDelAllowed($("#lblAS").html());
      $("#btnTruckAddQuality").show();

      if (Is_Confirmed == 1) {
        EditFlag = false;
        DeleteFlag = false;
        $("#btnTruckAddQuality").hide();
      }

      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        // TableHTML += "<td>" + value.batch_id + "</td>";
        TableHTML += "<td>" + value.sample_no + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td hidden></td>";
        // TableHTML +=
        //   "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
        // if (EditFlag) {
        //   // TableHTML +=
        //   //   '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowTruckQualityEditEntry(\'' +
        //   //   value.entry_id +
        //   //   "');\">";
        //   // TableHTML += '<i class="fa fa-pencil"></i>';
        //   // TableHTML += "</a>";
        // }
        // if (DeleteFlag) {
        //   // TableHTML +=
        //   //   '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveTruckQualityDeleteEntry(\'' +
        //   //   value.entry_id +
        //   //   "');\">";
        //   // TableHTML += '<i class="fa fa-trash"></i>';
        //   // TableHTML += "</a>";
        // }
        // TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableTruckMilkQualityList");
      $("#tableTruckEntryQuality").html(TableHTML);
      SetDataTable("tableTruckMilkQualityList", [5], "Milk Quality at Dairy");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

/*  ----    ----    ----    Set input fields to Edit Truck Quantity at dairy    ----    ----    ----    ----    */
function ShowTruckQuantityEditEntry(Entry_Id) {
  $("#divTruckReasons").hide();
  $("#lblTruckQuantityId").html(Entry_Id);
  var Method_Name = "Get_One";
  var APIEndPoint = "GetMilkCollectionQuantity";
  var url = "/Collection/MilkCollectionQuantity";
  var StoredProcedure = "USP_AdminMilkCollectionTruckQuantity_Get";

  var reqdata = {
    method_name: Method_Name,
    entry_id: Entry_Id,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    stored_procedure: StoredProcedure,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      OpenTruckQuantityModal("Edit", res[0].entry_id);

      $("#lblTruckQuantityId").html(res[0].entry_id);
      $("#txtEntryTruckReasons").val(res[0].reasons);
      GetMaster(
        "ddlEntryTruckQuantityMilkStatus",
        "Select Milk Status",
        "GetMilkStatusGood",
        res[0].milkstatus_id,
        ""
      );
      $("#ddlEntryTruckQuantityMilkStatus").prop("disabled", true);
      GetMaster(
        "ddlEntryTruckQuantityMilkType",
        "Select Milk Type",
        "GetMilkType",
        res[0].milktype_id,
        ""
      );

      // SetBatchIdDDLTruck(
      //     "ddlEntryTruckQuantityBatchId",
      //     MilkCollectionDairy_Id,
      //     TripDocument_Id,
      //     MCCCollectionShift_Id,
      //     MCC_Id,
      //     res[0].batch_id,
      //     "USP_AdminMilkCollectionTruckQuantity_Get"
      // );
      $("#txtEntryTruckQuantityWeight").val(res[0].weight);
      $("#txtEntryTruckQuantityCans").val(res[0].cans);
      // onChangeMilkType('Truck');

      if (res[0].milkstatus_id != "C016001") {
        $("#divTruckReasons").show();
      } else {
        $("#divTruckReasons").hide();
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

/*  ----    ----    ----    Delete Record for Milk Quantity at Dairy    ----    ----    ----    ----    */
function SaveTruckQuantityDeleteEntry(Entry_Id) {
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveMilkCollectionQuantity";
  var url = "/Collection/MilkCollectionQuantity";
  var StoredProcedure = "USP_AdminMilkCollectionTruckQuantity_Set";
  var Search_Period = $("#txtSearchDuration").val();
  var reqdata = {
    method_name: "Delete",
    entry_id: Entry_Id,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    stored_procedure: StoredProcedure,
    search_period: Search_Period,
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
        Show_Success_Toastr("Quantity details deleted successfully");
        GetTruckQuantityList(MilkCollectionDairy_Id);
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Quantity details not deleted");
    },
  });
}

/*  ----    ----    ----    Set input fields to Edit Truck Quantity at dairy    ----    ----    ----    ----    */
function ShowTruckQualityEditEntry(Entry_Id) {
  $("#lblTruckQualityId").html(Entry_Id);
  var Method_Name = "Get_One";
  var APIEndPoint = "GetMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var StoredProcedure = "USP_AdminMilkCollectionTruckQuality_Get";
  var Search_Period = $("#txtSearchDuration").val();
  var reqdata = {
    method_name: Method_Name,
    entry_id: Entry_Id,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    stored_procedure: StoredProcedure,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      OpenTruckQualityModal("Edit", res[0].entry_id);
      $("#lblTruckQualityId").html(res[0].entry_id);
      GetMaster(
        "ddlEntryTruckQualityMilkStatus",
        "Select Milk Status",
        "GetMilkStatusGood",
        res[0].milkstatus_id,
        ""
      );
      // SetBatchIdDDLTruck(
      //     "ddlEntryTruckQualityBatchId",
      //     MilkCollectionDairy_Id,
      //     TripDocument_Id,
      //     MCCCollectionShift_Id,
      //     MCC_Id,
      //     res[0].batch_id,
      //     "USP_AdminMilkCollectionTruckQuality_Get"
      // );
      $("#txtEntryTruckQualitySampleNo").val(res[0].sample_no);
      $("#txtEntryTruckQualitySNF").val(res[0].snf);
      $("#txtEntryTruckQualityFat").val(res[0].fat);
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

/*  ----    ----    ----    Delete Record for Truck Quality at Dairy    ----    ----    ----    ----    */
function SaveTruckQualityDeleteEntry(Entry_Id) {
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var Search_Period = $("#txtSearchDuration").val();
  var StoredProcedure = "USP_AdminMilkCollectionTruckQuality_Set";
  var reqdata = {
    method_name: "Delete",
    entry_id: Entry_Id,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    stored_procedure: StoredProcedure,
    search_period: Search_Period,
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
        Show_Success_Toastr("Quality details deleted successfully");
        GetTruckQualityList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Quality details not deleted");
    },
  });
}

/*
 *------------------------------------------------------------------------------------------------------------------------------------
 *
 *
 * --------     ----------      ----------       T A N K E R       -----------     --------------      -------------     -------------       -------
 *
 *
 * ------------------------------------------------------------------------------------------------------------------------------------
 */

/*  ----    ----    ----    Open Modal for Tanker Quantity of Milk at Dairy    ----    ----    ----    ----    */
function OpenTankerQuantityModal(action, id) {
  var TankerQualityListMilkStatus = $("#lblTankerQualityListMilkStatus").html();

  var TankerQualityListCell = $("#lblTankerQualityListCell").html();
  var lblsetTankerQualityListCell = $("#lblsetTankerQualityListCell").html();

  if (lblsetTankerQualityListCell == TankerQualityListCell) {
    if (
      TankerQualityListMilkStatus == "" ||
      TankerQualityListMilkStatus == null ||
      TankerQualityListMilkStatus == undefined
    ) {
      Show_Error_Toastr(
        "Please enter Quality Details for Cell No " + TankerQualityListCell
      );
      return;
    }
  }

  ResetInputFields();
  $("#modelEntryTankerQuantityMilkCollection")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#divTankerReasons").hide();
  $("#lblActionTankerQuantity").html(action);
  $("#lblTankerQuantityId").html(id);

  $("#ddlEntryTankerQuantityCellNo").select2();
  $("#ddlEntryTankerQuantityMilkStatus").select2();
  $("#ddlEntryTankerQuantityMilkType").select2();
  // $("#ddlEntryTankerQuantityBatchId").select2();
  $("#txtEntryTankerQuantityGrossWeight").prop("disabled", true);
  // $("#txtEntryTankerQuantityGrossWeight").val(0);
  $("#btnTankerQuantityGrossWeight").prop("disabled", true);
  $("#txtEntryTankerQuantityTareWeight").prop("disabled", true);
  // $("#txtEntryTankerQuantityTareWeight").val(0);
  $("#btnTankerQuantityTareWeight").prop("disabled", true);
  $("#ddlEntryTankerQuantityCellNo").prop("disabled", true);
  if (action == "Add") {
    $("#txtEntryTankerQuantityGrossWeight").val("");
    $("#txtEntryTankerQuantityTareWeight").val("");
    $("#ddlEntryTankerQuantityCellNo").prop("disabled", false);
    var tareWeightValue = $("#lblTankerAddQuantity").html();

    if (tareWeightValue == "Not Set") {
      $("#txtEntryTankerQuantityGrossWeight").val(0);
      var SessionRoleId = $("#lblSessionRoleId").html();
      if (SessionRoleId == "MU001" || SessionRoleId == "MU01241000008") {
        $("#txtEntryTankerQuantityGrossWeight").prop("disabled", false);
      } else {
        $("#txtEntryTankerQuantityGrossWeight").prop("disabled", true);
      }

      // $("#txtEntryTankerQuantityGrossWeight").prop("disabled", false);
      $("#btnTankerQuantityGrossWeight").prop("disabled", false);
      $("#txtEntryTankerQuantityTareWeight").prop("disabled", true);
      $("#btnTankerQuantityTareWeight").prop("disabled", true);
    } else {
      $("#txtEntryTankerQuantityGrossWeight").val(tareWeightValue);
      $("#txtEntryTankerQuantityGrossWeight").prop("disabled", true);
      $("#btnTankerQuantityGrossWeight").prop("disabled", true);
      $("#txtEntryTankerQuantityTareWeight").prop("disabled", true);
      $("#btnTankerQuantityTareWeight").prop("disabled", true);
    }

    $("#AddEditTankerQuantityMilkCollection").text("Add Quantity Details");

    GetMaster(
      "ddlEntryTankerQuantityMilkStatus",
      "Select Milk Status",
      "GetMilkStatusGood",
      "",
      ""
    );
    GetMaster(
      "ddlEntryTankerQuantityMilkType",
      "Select Milk Type",
      "GetMilkType",
      "",
      ""
    );
    GetMaster(
      "ddlEntryTankerQuantityCellNo",
      "Select Cell No",
      "GetNoOfCellsInTanker",
      "",
      TripDocument_Id
    );
    //alert($("#ddlEntryTankerQuantityCellNo option").length);
    cellsLength = $("#ddlEntryTankerQuantityCellNo option").length;
  } else if (action == "Edit") {
    $("#AddEditTankerQuantityMilkCollection").text("Edit Quantity Details");
    $("#txtEntryTankerQuantityGrossWeight").prop("disabled", true);
    $("#btnTankerQuantityGrossWeight").prop("disabled", true);
    var SessionRoleId = $("#lblSessionRoleId").html();
    if (SessionRoleId == "MU001" || SessionRoleId == "MU01241000008") {
      $("#txtEntryTankerQuantityTareWeight").prop("disabled", false);
    } else {
      $("#txtEntryTankerQuantityTareWeight").prop("disabled", true);
    }
    // $("#txtEntryTankerQuantityTareWeight").prop("disabled", false);
    $("#btnTankerQuantityTareWeight").prop("disabled", false);
    $("#ddlEntryTankerQuantityCellNo").prop("disabled", true);
  }
}

/*  ----    ----    ----    Resetting Modal Input Fields on Modal Close/Hide    ----    ----    ----    ----    */
$("#modelEntryTankerQuantityMilkCollection").on(
  "hidden.bs.modal",
  function (e) {
    $("#lblActionTankerQuantity").html("");
    $("#AddEditTankerQuantityMilkCollection").text("");
    $("#txtEntryTankerReasons").val("");
    ResetInputFields();
  }
);

/*  ----    ----    ----    Open modal to enter Quality of Milk at Dairy    ----    ----    ----    ----    */
function OpenTankerQualityModal(action, id) {
  ResetInputFields();
  $("#modelEntryTankerQualityMilkCollection")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblActionTankerQuality").html(action);
  $("#lblTankerQualityId").html(id);

  $("#ddlEntryTankerQualityMilkStatus").select2();
  // $("#ddlEntryTankerQualityBatchId").select2();
  $("#ddlEntryTankerQualityCellNo").select2();

  if (action == "Add") {
    GetMaster(
      "ddlEntryTankerQualityMilkStatus",
      "Select Milk Status",
      "GetMilkStatusGood",
      "",
      ""
    );
    // SetBatchIdDDLTanker(
    //   "ddlEntryTankerQualityBatchId",
    //   MilkCollectionDairy_Id,
    //   TripDocument_Id,
    //   ""
    // );
    GetMaster(
      "ddlEntryTankerQualityCellNo",
      "Select Cell No",
      "GetNoOfCellsInTanker",
      "",
      TripDocument_Id
    );
    $("#AddEditTankerQualityMilkCollection").text("Add Quality Details");
  } else if (action == "Edit") {
    $("#AddEditTankerQualityMilkCollection").text("Edit Quality Details");
  }
}

/*  ----    ----    ----    Resetting Modal Input Fields on Modal Close/Hide    ----    ----    ----    ----    */
$("#modelEntryTankerQualityMilkCollection").on("hidden.bs.modal", function (e) {
  $("#lblActionTankerQuality").html("");
  $("#AddEditTankerQualityMilkCollection").text("");
  ResetInputFields();
});

/*  ----    ----    ----    Save Tanker Quantity at Dairy    ----    ----    ----    ----    */
function SaveTankerQuantity() {
  var QuantityMilkType_Id = $("#ddlEntryTankerQuantityMilkType").val();
  var QuantityMilkStatus_Id = $("#ddlEntryTankerQuantityMilkStatus").val();
  var QuantityGrossWeight = $("#txtEntryTankerQuantityGrossWeight").val();
  var QuantityTareWeight = $("#txtEntryTankerQuantityTareWeight").val();
  // var QuantityWeight = $("#txtEntryTankerQuantityWeight").val();
  var QuantityCellNo_Id = $("#ddlEntryTankerQuantityCellNo").val();

  var Reasons = $("#txtEntryTankerReasons").val();

  var IsValid = 1;

  if (QuantityMilkType_Id == "") {
    IsValid = 0;
    $("#ddlEntryTankerQuantityMilkType").addClass("is-invalid state-invalid");
  }
  if (QuantityMilkStatus_Id == "") {
    IsValid = 0;
    $("#ddlEntryTankerQuantityMilkStatus").addClass("is-invalid state-invalid");
  }

  if (QuantityCellNo_Id == "") {
    IsValid = 0;
    $("#ddlEntryTankerQuantityCellNo").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving

    var APIEndPoint = "SaveMilkCollectionQuantity";
    var Method_Name = "Create";
    var MilkCollectionDairy_Id = $("#lblEntryId").html();
    var Entry_Id = "";
    var Action_Name = $("#lblActionTankerQuantity").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblTankerQuantityId").html();
    }

    if (
      (QuantityGrossWeight == "" ||
        QuantityGrossWeight == 0 ||
        QuantityGrossWeight == undefined ||
        QuantityGrossWeight == null) &&
      Method_Name == "Create"
    ) {
      IsValid = 0;
      $("#txtEntryTankerQuantityGrossWeight").addClass(
        "is-invalid state-invalid"
      );
    }

    if (
      (QuantityTareWeight == "" ||
        QuantityTareWeight == 0 ||
        QuantityTareWeight == undefined ||
        QuantityTareWeight == null) &&
      Method_Name == "Update"
    ) {
      IsValid = 0;
      $("#txtEntryTankerQuantityTareWeight").addClass(
        "is-invalid state-invalid"
      );
    }
    if (IsValid == 0) {
      Show_Error_Toastr("Invalid Input(s). Can't be saved.");
      return;
    }
    var QuantityWeight = QuantityGrossWeight - QuantityTareWeight;

    if (Method_Name == "Create") {
      if (
        QuantityTareWeight == "" ||
        QuantityTareWeight == null ||
        QuantityTareWeight == undefined
      ) {
        QuantityTareWeight = 0;
      }
    }
    Show_Loader();
    $("#btnTankerQuantitySave").prop("disabled", true);
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Collection/MilkCollectionQuantity";
    var StoredProcedure = "USP_AdminMilkCollectionTankerQuantity_Set";
    var Search_Period = $("#txtSearchDuration").val();
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      milkcollectiondairy_id: MilkCollectionDairy_Id,
      entry_id: Entry_Id,
      milkstatus_id: QuantityMilkStatus_Id,
      milktype_id: QuantityMilkType_Id,
      weight: QuantityWeight,
      cellno: QuantityCellNo_Id,
      tripdocument_id: TripDocument_Id,
      stored_procedure: StoredProcedure,
      vehicle_id: Vehicle_Id,
      gross_weight: QuantityGrossWeight,
      tare_weight: QuantityTareWeight,
      reasons: Reasons,
      search_period: Search_Period,
    };

    // return;

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
          // Show Success Message
          //$("#lblTankerQuantityId").html(result[0].result_extra_key);
          $("#lblActionTankerQuantity").html("Edit");
          $("#modelEntryTankerQuantityMilkCollection").modal("hide");
          //$("#lblEntryId").html(result[0].milkcollectiondairy_id);
          $("#lblEntryId").html(result[0].result_extra_key);

          $("#lblAction").html("Edit");
          ResetInputFields();
          Show_Success_Toastr("Quantity details saved successfully");
          $("#lbl_Release_BulkSupplier").html(0);
          $("#lbl_Confirm_BulkSupplier").html(0);
          GetTankerQuantityList();
          GetTankerQualityList();
          // if (VehicleTypeName == "BulkSupplier") {
          //   if (
          //     $("#lbl_Release_BulkSupplier").html() == "0" ||
          //     Is_Released == 0
          //   ) {
          //     $("#btn_Release_BulkSupplier").prop("hidden", false);
          //   }
          //   if (
          //     $("#lbl_Release_BulkSupplier").html() == "1" ||
          //     Is_Released == 1
          //   ) {
          //     $("#btn_Release_BulkSupplier").prop("hidden", true);
          //   }
          //   if (
          //     $("#lbl_Confirm_BulkSupplier").html() == "0" ||
          //     Is_Confirmed == 0
          //   ) {
          //     $("#btn_Confirm_BulkSupplier").prop("hidden", false);
          //   }
          //   if (
          //     $("#lbl_Confirm_BulkSupplier").html() == "1" ||
          //     Is_Confirmed == 1
          //   ) {
          //     $("#btn_Confirm_BulkSupplier").prop("hidden", true);
          //   }
          // }

          // // console.log(VehicleTypeName);

          // if (VehicleTypeName == "BulkSupplier") {
          //   $("#btn_Confirm_Tanker").prop("hidden", false);
          //   $("#btn_Release_Tanker").prop("hidden", false);
          // }
        } else {
          Hide_Loader();
          $("#modelEntryTankerQuantityMilkCollection").modal("hide");
          Show_Error_Toastr("Error : " + result[0].result_description);
          ResetInputFields();
        }
      },
      error: function (res) {
        Hide_Loader();
        $("#modelEntryTankerQuantityMilkCollection").modal("hide");
        Show_Error_Toastr("Error : Quantity details not saved");
      },
    });
    $("#btnTankerQuantitySave").prop("disabled", false);
  }
  return;
}

/*  ----    ----    ----    Save Tanker Quality at Dairy    ----    ----    ----    ----    */
function SaveTankerQuality() {
  var QualitySampleNo = $("#txtEntryTankerQualitySampleNo").val();
  var QualityMilkStatus_Id = "C016001"; // $("#ddlEntryTankerQualityMilkStatus").val();
  // var QualityBatch_Id = $("#ddlEntryTankerQualityBatchId").val();
  var QualitySNF = $("#txtEntryTankerQualitySNF").val();
  var QualityFat = $("#txtEntryTankerQualityFat").val();
  var QuantityCellNo_Id = $("#ddlEntryTankerQualityCellNo").val();

  var IsValid = 1;
  if (QualityMilkStatus_Id == "") {
    IsValid = 0;
    $("#ddlEntryTankerQualityMilkStatus").addClass("is-invalid state-invalid");
  }
  // if (QualityBatch_Id == "") {
  //   IsValid = 0;
  //   $("#ddlEntryTankerQualityBatchId").addClass("is-invalid state-invalid");
  // }
  if (QualitySampleNo == "") {
    IsValid = 0;
    $("#txtEntryTankerQualitySampleNo").addClass("is-invalid state-invalid");
  }
  // if (QualitySNF == "") {
  //   IsValid = 0;
  //   $("#txtEntryTankerQualitySNF").addClass("is-invalid state-invalid");
  // }
  // if (QualityFat == "") {
  //   IsValid = 0;
  //   $("#txtEntryTankerQualityFat").addClass("is-invalid state-invalid");
  // }

  if (QuantityCellNo_Id == "") {
    IsValid = 0;
    $("#ddlEntryTankerQualityCellNo").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btnTankerQualitySave").prop("disabled", true);
    var APIEndPoint = "SaveMilkCollectionQuality";
    var Method_Name = "Create";
    var MilkCollectionDairy_Id = $("#lblEntryId").html();
    var Entry_Id = "";
    var Search_Period = $("#txtSearchDuration").val();
    var Action_Name = $("#lblActionTankerQuality").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblTankerQualityId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Collection/MilkCollectionQuality";
    var StoredProcedure = "USP_AdminMilkCollectionTankerQuality_Set";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      milkcollectiondairy_id: MilkCollectionDairy_Id,
      entry_id: Entry_Id,
      milkstatus_id: QualityMilkStatus_Id,
      sample_no: QualitySampleNo,
      snf: QualitySNF,
      fat: QualityFat,
      cellno: QuantityCellNo_Id,
      tripdocument_id: TripDocument_Id,
      stored_procedure: StoredProcedure,
      vehicle_id: Vehicle_Id,
      search_period: Search_Period,
      // batch_id: QualityBatch_Id,
    };
    // // console.log(reqdata);
    // return;
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
          $("#lblTankerQualityId").html(result[0].result_extra_key);
          $("#lblActionTankerQuality").html("Edit");
          $("#modelEntryTankerQualityMilkCollection").modal("hide");
          $("#lblEntryId").html(result[0].milkcollectiondairy_id);
          $("#lblAction").html("Edit");
          GetTankerQualityList();
          Show_Success_Toastr("Quality details saved successfully");
          $("#btnTankerQualitySave").prop("disabled", false);
          // if (VehicleTypeName == "BulkSupplier") {
          //   $("#btn_Confirm_Tanker").prop("hidden", false);
          //   $("#btn_Release_Tanker").prop("hidden", false);
          // }
          if (VehicleTypeName == "BulkSupplier") {
            $("#btn_Release_BulkSupplier").prop("hidden", false);
            $("#btn_Confirm_BulkSupplier").prop("hidden", false);
          }
        } else {
          $("#btnTankerQualitySave").prop("disabled", false);
          $("#modelEntryTankerQualityMilkCollection").modal("hide");
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        $("#btnTankerQualitySave").prop("disabled", false);
        $("#modelEntryTankerQualityMilkCollection").modal("hide");
        Show_Error_Toastr("Error : Quality details not saved");
      },
    });
  }
  return;
}

function SaveTankerSupervisorQuantity() {
  // var QualitySampleNo = $("#txtEntryTankerQualitySampleNo").val();
  // var QualityMilkStatus_Id = "C016001"; // $("#ddlEntryTankerQualityMilkStatus").val();
  // var QualityBatch_Id = $("#ddlEntryTankerQualityBatchId").val();
  // var QualitySNF = $("#txtEntryTankerQualitySNF").val();
  // var Qualit/yFat = $("#txtEntryTankerQualityFat").val();
  var QuantityCellNo_Id = $("#lblTankerSupervisorQuantityCell").html();
  var SupervisorLoss = $("#lblTankerSupervisorQuantityLoss").html();
  var AdjustedLoss = $("#lblTankerAdjustedQuantityLoss").val();
  var Entry_Id = $("#lblTankerSupervisorQuantityId").html();
  var MilkCollectionDairy_Id = $("#lblEntryId").html();
  var Method_Name = "Supervisor";
  var APIEndPoint = "SaveMilkCollectionQuantity";
  var Is_Active = 1;
  var Is_Deleted = 0;
  var SupervisorDetails = "";

  // SupervisorDetails = "<Supervisor>";
  // $("#tableEntryTankerSupervisorMilkQuantityList tbody tr").each(function () {
  // SupervisorDetails += "<SupervisorItem>";
  // SupervisorDetails +=
  //   "<MCC_Id>" + $(this).find("td:eq(1)").text() + "</MCC_Id>";
  // SupervisorDetails +=
  //   "<MCCCollectionShift_Id>" +
  //   $(this).find("td:eq(2)").text() +
  //   "</MCCCollectionShift_Id>";
  // SupervisorDetails +=
  //   "<Weight>" + $(this).find("td:eq(3)").text() + "</Weight>";
  // SupervisorDetails +=
  //   "<Liters>" + $(this).find("td:eq(5)").text() + "</Liters>";
  // SupervisorDetails +=
  //   "<Loss>" + $(this).find("td:eq(6) input").val() + "</Loss>";
  // SupervisorDetails +=
  //   "<Adjusted_Liters>" +
  //   $(this).find("td:eq(7)").text() +
  //   "</Adjusted_Liters>";
  // SupervisorDetails += "</SupervisorItem>";
  // });
  // SupervisorDetails += "</Supervisor>";

  SupervisorDetails = "<Supervisor>";
  $("#tableEntryTankerSupervisorMilkQuantityList tbody tr").each(function () {
    var weight = $(this).find("td:eq(3)").text().trim();
    var liters = $(this).find("td:eq(5)").text().trim();
    var loss = $(this).find("td:eq(6) input").val().trim();
    var adjustedLiters = $(this).find("td:eq(7)").text().trim();

    // Check if any of the required fields are blank, undefined, or null
    if (
      // weight !== ""
      weight != "" &&
      weight != undefined &&
      weight != null &&
      // liters !== ""
      liters != "" &&
      liters != undefined &&
      liters != null &&
      // loss !== "" &&
      loss != "" &&
      loss != undefined &&
      loss != null &&
      // adjustedLiters !== "" &&
      adjustedLiters != "" &&
      adjustedLiters != undefined &&
      adjustedLiters != null
    ) {
      SupervisorDetails += "<SupervisorItem>";
      SupervisorDetails +=
        "<MCC_Id>" + $(this).find("td:eq(1)").text() + "</MCC_Id>";
      SupervisorDetails +=
        "<MCCCollectionShift_Id>" +
        $(this).find("td:eq(2)").text() +
        "</MCCCollectionShift_Id>";
      SupervisorDetails += "<Weight>" + weight + "</Weight>";
      SupervisorDetails += "<Liters>" + liters + "</Liters>";
      SupervisorDetails += "<Loss>" + loss + "</Loss>";
      SupervisorDetails +=
        "<Adjusted_Liters>" + adjustedLiters + "</Adjusted_Liters>";
      SupervisorDetails += "</SupervisorItem>";
    }
  });
  SupervisorDetails += "</Supervisor>";

  var IsValid = 1;
  if (SupervisorLoss != AdjustedLoss) {
    IsValid = 0;
    $("#lblTankerAdjustedQuantityLoss").attr(
      "style",
      "color: #ff4f57 !important;"
    );
    // $("#lblTankerAdjustedQuantityLoss").addClass(
    //   "badge badge-badge badge-danger"
    // );
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Total Loss Entry should match with Cell Loss Entry");
    return;
  } else {
    // Start Saving
    $("#btnTankerSupervisorQuantitySave").prop("disabled", true);
    var url = "/Collection/MilkCollectionQuantity";
    var Search_Period = $("#txtSearchDuration").val();
    var StoredProcedure = "USP_AdminMilkCollectionTankerQuantity_Set";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      milkcollectiondairy_id: MilkCollectionDairy_Id,
      entry_id: Entry_Id,
      cellno: QuantityCellNo_Id,
      tripdocument_id: TripDocument_Id,
      stored_procedure: StoredProcedure,
      supervisordata: SupervisorDetails,
      search_period: Search_Period,
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
          $("#modelEntryTankerSupervisorQuantityMilkCollection").modal("hide");
          Show_Success_Toastr("Quality details saved successfully");
          $("#btnTankerSupervisorQuantitySave").prop("disabled", false);
        } else {
          $("#btnTankerSupervisorQuantitySave").prop("disabled", false);
          $("#modelEntryTankerSupervisorQuantityMilkCollection").modal("hide");
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        $("#btnTankerSupervisorQuantitySave").prop("disabled", false);
        $("#modelEntryTankerSupervisorQuantityMilkCollection").modal("hide");
        Show_Error_Toastr("Error : Quality details not saved");
      },
    });
  }
  return;
}
/*  ----    ----    ----    Set and Display Tanker Quantity Table    ----    ----    ----    ----    */
function GetTankerQuantityList() {
  $("#lblTankerAddQuantity").html("");
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkCollectionQuantity";
  var url = "/Collection/MilkCollectionQuantity";
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuantity_Get";
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      if (res.length > 0) {
        var lastItem = res[res.length - 1];
        var tareWeightValue = lastItem.tare_weight;
        $("#lblTankerAddQuantity").html(tareWeightValue);
      } else {
        $("#lblTankerAddQuantity").html("Not Set");
      }
      // Fill data in table
      var TableHTML = "";
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = true; // IsDelAllowed($("#lblAS").html());
      $("#btnTankerAddQuantity").show();
      $("#btnTankerRefresh").show();

      if (Is_Confirmed == 1) {
        EditFlag = false;
        DeleteFlag = false;
        $("#btnTankerAddQuantity").hide();
        $("#btnTankerRefresh").hide();
      }
      //alert($("#ddlEntryTankerQuantityCellNo option").length);
      GetMasterCallback(
        "ddlEntryTankerQuantityCellNo",
        "Select Cell No",
        "GetNoOfCellsInTanker",
        "",
        TripDocument_Id,
        function (resp_data) {
          if (resp_data)
            cellsLength = $("#ddlEntryTankerQuantityCellNo option").length;

          var cells_in_ddl = [];
          var cells_in_table = [];
          $("#ddlEntryTankerQuantityCellNo option").each(function () {
            if ($(this).val() != "" && $(this).val() != null) {
              cells_in_ddl.push($(this).val());
            }
          });

          /*
                    for (var k = 1; k < cellsLength; k++) {
                    cells.push(k);
                  }*/
          $.each(res, function (data, value) {
            // pushing only distinct values in the array to later compare with original cell values
            if (cells_in_table.indexOf(value.cellno) < 0) {
              cells_in_table.push(value.cellno);
            }
            TableHTML += "<tr>";
            TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
            // TableHTML += "<td>" + value.batch_id + "</td>";
            TableHTML += "<td>" + value.cellno + "</td>";
            TableHTML += "<td>" + value.milktype_name + "</td>";
            TableHTML += "<td>" + value.milkstatus_name + "</td>";
            TableHTML += "<td>" + value.weight + "</td>";
            TableHTML += "<td>" + value.liters + "</td>";

            // if (value.loss > 0) {
            //   TableHTML +=
            //     "<td><span class='badge badge-badge badge-danger'>" +
            //     value.loss +
            //     "</span></td>";
            // } else {
            //   TableHTML += "<td>" + value.loss + "</td>";
            // }

            TableHTML += "<td><span>" + value.start_time + "</span></td>";
            TableHTML +=
              "<td class='text-right' style='width: 135px; padding:8px 5px 8px 5px;'>";

            if (EditFlag) {
              // if (value.loss > 0) {
              //   TableHTML +=
              //     '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Adjust" onclick="ShowTankerSupervisorQuantityEntry(\'' +
              //     value.entry_id +
              //     "','" +
              //     value.cellno +
              //     "','" +
              //     value.loss +
              //     "');\">";
              //   TableHTML += '<i class="fa fa-cogs"></i>';
              //   TableHTML += "</a> |";
              // }
              TableHTML +=
                '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowTankerQuantityEditEntry(\'' +
                value.entry_id +
                "');\">";
              TableHTML += '<i class="fa fa-pencil"></i>';
              TableHTML += "</a>";
            }
            if (DeleteFlag) {
              // TableHTML +=
              //   '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveTankerQuantityDeleteEntry(\'' +
              //   value.entry_id +
              //   "');\">";
              // TableHTML += '<i class="fa fa-trash"></i>';
              // TableHTML += "</a>";
            }

            TableHTML += "</td>";
            TableHTML += "</tr>";
            /*
                        if (cells.length > 0) {
                            for (var i = 1; i <= cellsLength; i++) {
                                if (value.cellno == i) {
                                    if (cells.indexOf(i) >= 0) {
                                        cells.splice(cells.indexOf(i), 1);
                                    }
                                }
                            }
                        }*/
          });
          ClearDataTable("tableTankerMilkQuantityList");
          $("#tableTankerEntryQuantity").html(TableHTML);
          SetDataTable(
            "tableTankerMilkQuantityList",
            [7],
            "Milk Quantity at Dairy"
          );

          var are_cells_equal = true;
          // check if both arrays are equal in length
          if (cells_in_ddl.length == cells_in_table.length) {
            // check if both arrays are equal
            $.each(cells_in_table, function (key, value) {
              var index = cells_in_ddl.indexOf(value);
              if (index < 0) {
                are_cells_equal = false;
                // to break out of loop
                return false;
              }
            });
          } else {
            are_cells_equal = false;
          }
          // debugger;
          // debugger;
          if (vehicleTypeName == "Tanker") {
            if (Is_Confirmed == 0 && are_cells_equal == true) {
              //show confirm button
              $("#btn_Confirm_Tanker").prop("hidden", false);
              $("#btnTankerAddQuantity").show();
              $("#btnTankerRefresh").show();
            } else {
              // hide confirm button
              $("#btn_Confirm_Tanker").prop("hidden", true);
              //$("#btnTankerAddQuantity").hide();
            }
            if (Is_Confirmed == 1) {
              $("#btn_Confirm_Tanker").prop("hidden", true);
              $("#btnTankerAddQuantity").hide();
              $("#btnTankerRefresh").hide();
            }

            if (Is_Released == 0 && are_cells_equal == true) {
              $("#btn_Release_Tanker").prop("hidden", false);
            } else {
              $("#btn_Release_Tanker").prop("hidden", true);
            }
            if (Is_Released == 1) {
              $("#btn_Release_Tanker").prop("hidden", true);
            }
          } else {
            $("#btn_Confirm_Tanker").prop("hidden", true);
            $("#btn_Release_Tanker").prop("hidden", true);
          }
          if (vehicleTypeName == "BulkSupplier") {
            // debugger;
            if (res.length > 0) {
              if (
                $("#lbl_Release_BulkSupplier").html() == "" ||
                $("#lbl_Release_BulkSupplier").html() == null ||
                $("#lbl_Release_BulkSupplier").html() == undefined
              ) {
                $("#lbl_Release_BulkSupplier").html(0);
              }
              if (
                $("#lbl_Release_BulkSupplier").html() == "0" ||
                Is_Released == 0
              ) {
                $("#btn_Release_BulkSupplier").prop("hidden", false);
              }
              if (
                $("#lbl_Release_BulkSupplier").html() == "1" ||
                Is_Released == 1
              ) {
                $("#btn_Release_BulkSupplier").prop("hidden", true);
              }
              if (
                $("#lbl_Confirm_BulkSupplier").html() == "" ||
                $("#lbl_Confirm_BulkSupplier").html() == null ||
                $("#lbl_Confirm_BulkSupplier").html() == undefined
              ) {
                $("#lbl_Confirm_BulkSupplier").html(0);
              }
              if (
                $("#lbl_Confirm_BulkSupplier").html() == "0" ||
                Is_Confirmed == 0
              ) {
                $("#btn_Confirm_BulkSupplier").prop("hidden", false);
              }
              if (
                $("#lbl_Confirm_BulkSupplier").html() == "1" ||
                Is_Confirmed == 1
              ) {
                $("#btn_Confirm_BulkSupplier").prop("hidden", true);
              }
            } else {
              $("#btn_Release_BulkSupplier").prop("hidden", true);
              $("#btn_Confirm_BulkSupplier").prop("hidden", true);
            }
          } else {
            $("#btn_Release_BulkSupplier").prop("hidden", true);
            $("#btn_Confirm_BulkSupplier").prop("hidden", true);
          }
          /*
                    if (Is_Confirmed == 0 && cells.length == 0) {
                        //show confirm button
                        $("#btn_Confirm_Tanker").prop("hidden", false);
                        $("#btnTankerAddQuantity").show();
                    } else {
                        // hide confirm button
                        $("#btn_Confirm_Tanker").prop("hidden", true);
                        //$("#btnTankerAddQuantity").hide();
                    }
                    if (Is_Confirmed == 1) {
                        $("#btn_Confirm_Tanker").prop("hidden", true);
                        $("#btnTankerAddQuantity").hide();
                    }

                    if (Is_Released == 0 && cells.length == 0) {
                        $("#btn_Release_Tanker").prop("hidden", false);
                    } else {
                        $("#btn_Release_Tanker").prop("hidden", true);
                    }*/
        }
      );
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

/*  ----    ----    ----    Set and Display Tanker Quality Table    ----    ----    ----    ----    */
function GetTankerQualityList() {
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuality_Get";
  var Search_Period = $("#txtSearchDuration").val();
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
    search_period: Search_Period,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      if (res.length > 0) {
        var lastItem = res[res.length - 1];
        var milkstatus_id = lastItem.milkstatus_id;
        $("#lblTankerQualityListMilkStatus").html(milkstatus_id);
        var cellno = lastItem.cellno;
        $("#lblTankerQualityListCell").html(cellno);
      } else {
        $("#lblTankerQualityListMilkStatus").html(0);
      }

      // Fill data in table
      var TableHTML = "";
      var EditFlag = true;
      var DeleteFlag = true;
      $("#btnTankerAddQuality").show();

      if (Is_Confirmed == 1) {
        EditFlag = false;
        DeleteFlag = false;
        $("#btnTankerAddQuality").hide();
      }

      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.cellno + "</td>";
        TableHTML += "<td>" + value.sample_no + "</td>";
        if (
          value.milkstatus_id == "C016001" &&
          value.milkstatus_id != "" &&
          value.milkstatus_id != null &&
          value.milkstatus_id != undefined
        ) {
          TableHTML +=
            "<td><span class='badge badge-badge badge-success'>" +
            value.milkstatus_name +
            "</span></td>";
        }
        if (
          value.milkstatus_id != "C016001" &&
          value.milkstatus_id != "" &&
          value.milkstatus_id != null &&
          value.milkstatus_id != undefined
        ) {
          TableHTML +=
            "<td><span class='badge badge-badge badge-danger'>" +
            value.milkstatus_name +
            "</span></td>";
        }
        if (
          value.milkstatus_id == "" ||
          value.milkstatus_id == null ||
          value.milkstatus_id == undefined
        ) {
          TableHTML += "<td>" + value.milkstatus_name + "</td>";
        }

        // TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableTankerMilkQualityList");
      $("#tableTankerEntryQuality").html(TableHTML);
      SetDataTable("tableTankerMilkQualityList", [6], "Milk Quality at Dairy");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

/*  ----    ----    ----    Set input fields to Edit Tanker Quantity at dairy    ----    ----    ----    ----    */
function ShowTankerQuantityEditEntry(Entry_Id) {
  $("#lblTankerQuantityId").html(Entry_Id);
  $("#divTankerReasons").hide();

  var Method_Name = "Get_One";
  var APIEndPoint = "GetMilkCollectionQuantity";
  var url = "/Collection/MilkCollectionQuantity";
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuantity_Get";
  MilkCollectionDairy_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    entry_id: Entry_Id,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      $("#lblTankerQuantityId").html(res[0].entry_id);
      $("#lblsetTankerQualityListCell").html(res[0].cellno);
      GetMaster(
        "ddlEntryTankerQuantityMilkType",
        "Select Milk Type",
        "GetMilkType",
        res[0].milktype_id,
        ""
      );

      var TankerQualityListMilkStatus = $(
        "#lblTankerQualityListMilkStatus"
      ).html();

      var TankerQualityListCell = $("#lblTankerQualityListCell").html();

      // if (TankerQualityListCell == res[0].cellno && TankerQualityListMilkStatus ="") {
      //   $("#txtEntryTankerQuantityGrossWeight").val(res[0].gross_weight);
      //   $("#txtEntryTankerQuantityTareWeight").val(res[0].gross_weight);
      //   GetMaster(
      //     "ddlEntryTankerQuantityMilkStatus",
      //     "Select Milk Status",
      //     "GetMilkStatusGood",
      //     TankerQualityListMilkStatus,
      //     ""
      //   );
      // }else{
      $("#txtEntryTankerQuantityGrossWeight").val(res[0].gross_weight);
      $("#txtEntryTankerQuantityTareWeight").val(res[0].tare_weight);
      GetMaster(
        "ddlEntryTankerQuantityMilkStatus",
        "Select Milk Status",
        "GetMilkStatusGood",
        res[0].milkstatus_id,
        ""
      );
      // }

      $("#txtEntryTankerQuantityWeight").val(res[0].weight);
      $("#txtEntryTankerQuantityCans").val(res[0].cans);
      $("#txtEntryTankerReasons").val(res[0].reasons);
      // onChangeMilkType('Tanker');
      OpenTankerQuantityModal("Edit", res[0].entry_id);
      if (res[0].milkstatus_id != "C016001") {
        $("#divTankerReasons").show();
      } else {
        $("#divTankerReasons").hide();
      }
      GetMaster(
        "ddlEntryTankerQuantityCellNo",
        "Select Cell No",
        "GetNoOfCellsInTanker",
        res[0].cellno,
        TripDocument_Id
      );
      cellsLength = $("#ddlEntryTankerQuantityCellNo option").length;
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function ShowTankerSupervisorQuantityEntry(Entry_Id, Cell_No, Loss) {
  $("#modelEntryTankerSupervisorQuantityMilkCollection")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblTankerAdjustedQuantityLoss").val("");
  $("#lblTankerAdjustedQuantityLoss").attr(
    "style",
    "color: #2e384d !important;"
  );
  // $("#lblTankerAdjustedQuantityLoss").removeClass(
  //   "badge badge-badge badge-danger"
  // );
  $("#lblTankerSupervisorQuantityId").html(Entry_Id);
  $("#lblTankerSupervisorQuantityCell").html(Cell_No);
  $("#lblTankerSupervisorQuantityLoss").html(Loss);
  $("#lblTankerSupervisorQuantityLossSet").val("Cell Loss " + Loss);
  $("#AddEditTankerSupervisorQuantityMilkCollection").text(
    "Edit Chemist Quantity Details"
  );
  var Method_Name = "Get_Supervisor";
  var APIEndPoint = "GetMilkCollectionQuantity";
  var url = "/Collection/MilkCollectionQuantity";
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuantity_Get";
  MilkCollectionDairy_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    entry_id: Entry_Id,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // OpenTankerQuantityModal("Edit", res[0].entry_id);
      $("#lblTankerSupervisorQuantityId").html(res[0].entry_id);
      var TableHTML = "";
      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "<td hidden>" + value.mcccollectionshift_id + "</td>";
        TableHTML += "<td hidden>" + value.weight + "</td>";
        // TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML +=
          "<td id='qty" + value.mcc_id + "'>" + value.liters + "</td>";
        TableHTML +=
          "<td><input type='text' class='form-control' placeholder='0' maxlength='10' onkeypress='return onlyNumberKey(event)' autocomplete='off'";
        TableHTML +=
          "value='' id='loss" +
          value.mcc_id +
          "' onkeyup=\"GetAdjustedQuantity('" +
          value.mcc_id +
          "')\"></td>";
        TableHTML += "<td id='ltr" + value.mcc_id + "'></td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableEntryTankerSupervisorMilkQuantityList");
      $("#tableEntryModelSupervisor").html(TableHTML);
      //   SetDataTable(
      //     "tableEntryTankerSupervisorMilkQuantityList",
      //     [8],
      //     "Milk Quantity at Dairy"
      //   );
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}
function onlyNumberKey(evt) {
  // Only ASCII character in that range allowed
  let ASCIICode = evt.which ? evt.which : evt.keyCode;
  if (ASCIICode == 46) return true;
  if (ASCIICode > 31 && (ASCIICode < 48 || ASCIICode > 57)) return false;
  return true;
}

function GetAdjustedQuantity(mccId) {
  var lossValue = $("#loss" + mccId).val();

  // var regex = /^[0-9]+$/;

  // if (!(regex.test(lossValue))) {
  //   $("#loss" + mccId).val("");
  // }

  if (lossValue < 0) {
    $("#loss" + mccId).val("");
  }

  var originalQuantity = parseFloat($("#qty" + mccId).text());
  var adjustedQuantity = originalQuantity - parseFloat(lossValue);
  // var supervisorLoss =
  //   parseFloat($("#lblTankerAdjustedQuantityLoss").val()) || 0;

  if (isNaN(lossValue) || lossValue === null || lossValue === undefined) {
    $("#ltr" + mccId).text(0);
    supervisorLoss += 0;
  } else if (
    isNaN(adjustedQuantity) ||
    adjustedQuantity === null ||
    adjustedQuantity === undefined
  ) {
    $("#ltr" + mccId).text(0);
    // supervisorLoss += 0;
  } else {
    $("#ltr" + mccId).text(adjustedQuantity.toFixed(3));
  }

  // Calculate total loss
  var totalLoss = 0;
  // Update the total loss in the corresponding input

  $("#tableEntryTankerSupervisorMilkQuantityList tbody tr").each(function () {
    // Get the text content of the 7th column
    var value = $(this).find("td:eq(6) input").val();

    // Convert the value to a numeric format (assuming it represents a number)
    var numericValue = parseFloat(value);

    // Check if the conversion is successful (not NaN)
    if (!isNaN(numericValue)) {
      // Add the numeric value to the totalLoss
      totalLoss += numericValue;
    }
  });

  $("#lblTankerAdjustedQuantityLoss").val(totalLoss.toFixed(3));

  $("#lblTankerAdjustedQuantityLoss").attr(
    "style",
    "color: #2e384d !important;"
  );

  // $("#lblTankerAdjustedQuantityLoss").removeClass(
  //   "badge badge-badge badge-danger"
  // );
}
/*  ----    ----    ----    Delete Record for Milk Quantity at Dairy    ----    ----    ----    ----    */
function SaveTankerQuantityDeleteEntry(Entry_Id) {
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveMilkCollectionQuantity";
  var url = "/Collection/MilkCollectionQuantity";
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuantity_Set";
  var Search_Period = $("#txtSearchDuration").val();
  var reqdata = {
    method_name: "Delete",
    entry_id: Entry_Id,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
    search_period: Search_Period,
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
        Show_Success_Toastr("Quantity details deleted successfully");
        GetTankerQuantityList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Quantity details not deleted");
    },
  });
}

/*  ----    ----    ----    Set input fields to Edit Tanker Quantity at dairy    ----    ----    ----    ----    */
function ShowTankerQualityEditEntry(Entry_Id) {
  $("#lblTankerQualityId").html(Entry_Id);
  var Method_Name = "Get_One";
  var APIEndPoint = "GetMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuality_Get";
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var Search_Period = $("#txtSearchDuration").val();

  var reqdata = {
    method_name: Method_Name,
    entry_id: Entry_Id,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      OpenTankerQualityModal("Edit", res[0].entry_id);
      $("#lblTankerQualityId").html(res[0].entry_id);
      GetMaster(
        "ddlEntryTankerQualityMilkStatus",
        "Select Milk Status",
        "GetMilkStatusGood",
        res[0].milkstatus_id,
        ""
      );
      // SetBatchIdDDLTanker(
      //   "ddlEntryTankerQualityBatchId",
      //   MilkCollectionDairy_Id,
      //   TripDocument_Id,
      //   res[0].batch_id
      // );
      $("#txtEntryTankerQualitySampleNo").val(res[0].sample_no);
      $("#txtEntryTankerQualitySNF").val(res[0].snf);
      $("#txtEntryTankerQualityFat").val(res[0].fat);
      GetMaster(
        "ddlEntryTankerQualityCellNo",
        "Select Cell No",
        "GetNoOfCellsInTanker",
        res[0].cellno,
        TripDocument_Id
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

/*  ----    ----    ----    Delete Record for Tanker Quality at Dairy    ----    ----    ----    ----    */
function SaveTankerQualityDeleteEntry(Entry_Id) {
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var Search_Period = $("#txtSearchDuration").val();
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuality_Set";
  var reqdata = {
    method_name: "Delete",
    entry_id: Entry_Id,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
    search_period: Search_Period,
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
        Show_Success_Toastr("Quality details deleted successfully");
        GetTankerQualityList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Quality details not deleted");
    },
  });
}

/*  ----    ----    ----    Get Table for Tanker Supervisor at Dairy    ----    ----    ----    ----    */

function GetSupervisorList() {
  var Method_Name = "Get_Supervisor";
  var APIEndPoint = "GetMilkCollection";
  var url = "/Collection/MilkCollection";
  var StoredProcedure = "USP_AdminMilkCollection_Get";
  var Search_Period = $("#txtSearchDuration").val();

  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
    vehicle_id: Vehicle_Id,
    search_period: Search_Period,
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

      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liter + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";

        TableHTML += "<td>" + value.cellno + "</td>";
        TableHTML += "<td hidden></td>";
        /*
                                                        TableHTML += "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
                                                        if (EditFlag == 1) {
                                                            TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowTankerQualityEditEntry('" + value.entry_id + "');\">";
                                                            TableHTML += "<i class=\"fa fa-pencil\"></i>";
                                                            TableHTML += "</a>";
                                                        }
                                                        if (DeleteFlag == 1) {
                                                            TableHTML += "| <a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"SaveTankerQualityDeleteEntry('" + value.entry_id + "');\">";
                                                            TableHTML += "<i class=\"fa fa-trash\"></i>";
                                                            TableHTML += "</a>";
                                                        }
                                                        TableHTML += "</td>";
                                                        */
        TableHTML += "</tr>";
      });
      ClearDataTable("tableSupervisorEntryList");
      $("#tableSupervisorEntryData").html(TableHTML);
      SetDataTable("tableSupervisorEntryList", [9], "Milk Quality at Dairy");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

function GetAnalystList() {
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var StoredProcedure = "USP_AdminMilkCollectionTankerQuality_Get";
  var Search_Period = $("#txtSearchDuration").val();
  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
    stored_procedure: StoredProcedure,
    vehicle_id: Vehicle_Id,
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

      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.cellno + "</td>";
        TableHTML += "<td>" + value.sample_no + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
        if (EditFlag == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowTankerQualityEditEntry(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveTankerQualityDeleteEntry(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableTankerMilkQualityList");
      $("#tableTankerEntryQuality").html(TableHTML);
      SetDataTable("tableTankerMilkQualityList", [5], "Milk Quality at Dairy");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

function GetTankerMCCList() {
  var Method_Name = "Get_AgentMCCList";
  var APIEndPoint = "GetMilkCollection";
  var url = "/Collection/MilkCollection";
  var StoredProcedure = "USP_AdminMilkCollection_Get";

  MilkCollectionDairy_Id = $("#lblEntryId").html();
  var Search_Period = $("#txtSearchDuration").val();
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
    vehicle_id: Vehicle_Id,
    search_period: Search_Period,
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

      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liter + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";

        TableHTML += "<td hidden></td>";
        /*
                                                        TableHTML += "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
                                                        if (EditFlag == 1) {
                                                            TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowTankerQualityEditEntry('" + value.entry_id + "');\">";
                                                            TableHTML += "<i class=\"fa fa-pencil\"></i>";
                                                            TableHTML += "</a>";
                                                        }
                                                        if (DeleteFlag == 1) {
                                                            TableHTML += "| <a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"SaveTankerQualityDeleteEntry('" + value.entry_id + "');\">";
                                                            TableHTML += "<i class=\"fa fa-trash\"></i>";
                                                            TableHTML += "</a>";
                                                        }
                                                        TableHTML += "</td>";
                                                        */
        TableHTML += "</tr>";
      });
      ClearDataTable("tableTankerMCCList");
      $("#tableTankerMCCData").html(TableHTML);
      SetDataTable("tableTankerMCCList", [8], "Milk Quality at Dairy");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

/*  ----    ----    ----    Reset all modal input fields    ----    ----    ----    ----    */
function ResetInputFields() {
  $("modal input, select").val("");

  /**-------------TRUCK-------------- */
  // quantity
  // $("#ddlEntryTruckQuantityBatchId").val("");
  $("#ddlEntryTruckQuantityMilkType").val("");
  $("#ddlEntryTruckQuantityMilkStatus").val("");
  $("#txtEntryTruckQuantityWeight").val("");
  $("#txtEntryTruckQuantityCans").val("");
  $("#lblActionTruckQuantity").html("");
  $("#lblTruckQuantityId").html("");

  //quality
  $("#txtEntryTruckQualitySampleNo").val("");
  $("#ddlEntryTruckQualityMilkStatus").val("");
  // $("#ddlEntryTruckQualityBatchId").val("");
  $("#txtEntryTruckQualitySNF").val("");
  $("#txtEntryTruckQualityFat").val("");
  $("#lblActionTruckQuality").html("");
  $("#lblTruckQualityId").html("");

  /**-------------TANKER-------------- */
  // quantity
  $("#ddlEntryTankerQuantityMilkType").val("");
  $("#ddlEntryTankerQuantityMilkStatus").val("");
  $("#txtEntryTankerQuantityWeight").val("");
  $("#txtEntryTankerQuantityCans").val("");
  $("#lblActionTankerQuantity").html("");
  $("#lblTankerQuantityId").html("");

  //quality
  $("#txtEntryTankerQualitySampleNo").val("");
  $("#ddlEntryTankerQualityMilkStatus").val("");
  // $("#ddlEntryTankerQualityBatchId").val("");
  $("#txtEntryTankerQualitySNF").val("");
  $("#txtEntryTankerQualityFat").val("");
  $("#lblActionTankerQuality").html("");
  $("#lblTankerQualityId").html("");
  $("#lblTankerAdjustedQuantityLoss").val("");
}

function SetBatchIdDDLTanker(
  ddl_Id,
  MilkCollectionDairy_Id,
  TripDocument_Id,
  Value
) {
  $("#" + ddl_Id)
    .empty()
    .append(
      $("<option></option>").val("").html("Select Batch No").attr("name", "")
    );
  var APIEndPoint = "GetMilkCollectionQuality";
  var url = "/Collection/MilkCollectionQuality";
  var Stored_Procedure = "USP_AdminMilkCollectionTankerQuality_Get";
  var reqdata = {
    method_name: "Get_BatchId",
    api_end_point: APIEndPoint,
    stored_procedure: Stored_Procedure,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    tripdocument_id: TripDocument_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      $.each(result, function (data, value) {
        $("#" + ddl_Id).append(
          $("<option></option>").val(value.batch_id).html(value.batch_id)
        );
      });
      $("#" + ddl_Id).val(Value);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching data");
    },
  });
}

function GetMachineData(type, Weight) {
  var Method_Name = "";
  if (type == "Truck" && Weight == "Tare") {
    Method_Name = "Machine2";
    $("#txtEntryTruckQuantityWeight").val("");
  }
  // if (type == "Tanker"&& Weight == "") {
  //   Method_Name = "Machine1";
  //   $("#txtEntryTankerQuantityWeight").val("");
  // }
  if (type == "Tanker" && Weight == "Gross") {
    Method_Name = "Machine1";
    $("#txtEntryTankerQuantityGrossWeight").removeClass(
      "is-invalid state-invalid"
    );
    $("#txtEntryTankerQuantityGrossWeight").val("");
  }
  if (type == "Tanker" && Weight == "Tare") {
    Method_Name = "Machine1";
    $("#txtEntryTankerQuantityTareWeight").removeClass(
      "is-invalid state-invalid"
    );
    $("#txtEntryTankerQuantityTareWeight").val("");
  }
  var url = "/Collection/MilkCollectionQuantity";
  var APIEndPoint = "GetMachineData";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (type == "Truck") {
        $("#txtEntryTruckQuantityWeight").val(result[0].machine_data);
      }
      // if (type == "Tanker" && Weight == "") {
      //   $("#txtEntryTankerQuantityWeight").val(result[0].machine_data);
      // }
      if (type == "Tanker" && Weight == "Gross") {
        // Method_Name = "Machine1";
        $("#txtEntryTankerQuantityGrossWeight").val(result[0].machine_data);
      }
      if (type == "Tanker" && Weight == "Tare") {
        // Method_Name = "Machine1";
        $("#txtEntryTankerQuantityTareWeight").val(result[0].machine_data);
      }
    },
    error: function (res) {
      Show_Error_Toastr("Error : Machine details not found");
    },
  });
}

function onChangeMilkType(type) {
  $("#divTankerReasons").hide();
  $("#divTruckReasons").hide();

  if (type == "Tanker") {
    QuantityMilkStatus_Id = $("#ddlEntryTankerQuantityMilkStatus").val();
    if (
      QuantityMilkStatus_Id != "C016001" &&
      QuantityMilkStatus_Id != "" &&
      QuantityMilkStatus_Id != null &&
      QuantityMilkStatus_Id != undefined
    ) {
      $("#divTankerReasons").show();
    } else {
      $("#divTankerReasons").hide();
    }
  }
  if (type == "Truck") {
    QuantityMilkStatus_Id = $("#ddlEntryTruckQuantityMilkStatus").val();
    if (
      QuantityMilkStatus_Id != "C016001" &&
      QuantityMilkStatus_Id != "" &&
      QuantityMilkStatus_Id != null &&
      QuantityMilkStatus_Id != undefined
    ) {
      $("#divTruckReasons").show();
    } else {
      $("#divTruckReasons").hide();
    }
  }
  // console.log(QuantityMilkStatus_Id);
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function OpenTankerRefresh() {
  GetTankerQuantityList();
  GetTankerQualityList();
}

function OpenTruckRefresh() {
  GetTruckQuantityList();
  GetTruckQualityList();
}

function ShowDeleteEntry(MilkCollectionDairy_Id) {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, Clear it!",
    },
    function (result) {
      if (result == true) {
        var Method_Name = "Clear";
        var APIEndPoint = "SaveMilkCollection";
        var url = "/Collection/MilkCollection";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          milkcollectiondairy_id: MilkCollectionDairy_Id,
        };
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            GetSearchList();
          },
          error: function () {
            Show_Error_Toastr("Error : Milk Receipt details not Clear");
          },
        });
      }
    }
  );
}

function ShowKMEntry(KMMilkCollectionDairy_id, KMTripDocument_Id) {
  $("#KMMilkCollectionDairy_id").html("");
  $("#KMTripDocument_Id").html("");
  $("#txtEntryOutKM").val("");
  $("#txtEntryINKM").val("");

  $("#modelEntryKM")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#KMMilkCollectionDairy_id").html(KMMilkCollectionDairy_id);
  $("#KMTripDocument_Id").html(KMTripDocument_Id);
}

function ShowAddKMEntry() {
  var APIEndPoint = "SaveTripDocumentKM";
  var Method_Name = "Update";
  var TripDocument_Id = $("#KMTripDocument_Id").html();
  var OutKM = $("#txtEntryOutKM").val();
  var INKM = $("#txtEntryINKM").val();

  var IsValid = 1;
  if (
    OutKM == "" ||
    OutKM == null ||
    OutKM == undefined ||
    isNaN(OutKM) ||
    parseFloat(OutKM) < 0
  ) {
    IsValid = 0;
    $("#txtEntryOutKM").addClass("is-invalid state-invalid");
  }

  if (
    INKM == "" ||
    INKM == null ||
    INKM == undefined ||
    isNaN(INKM) ||
    parseFloat(INKM) < 0
  ) {
    IsValid = 0;
    $("#txtEntryINKM").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    Show_Loader();
    var url = "/Collection/TripDocument";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      tripdocument_id: TripDocument_Id,
      in_km: INKM,
      out_km: OutKM,
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
          $("#modelEntryKM").modal("hide");
          Hide_Loader();
          ShowEntrySuccess("KM saved successfully");

          GetSearchList();
        } else {
          $("#modelEntryKM").modal("hide");
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        $("#modelEntryKM").modal("hide");
        Hide_Loader();
        Show_Error_Toastr("Error : KM not saved");
      },
    });
  }
}

function ShowReverseEntry(MilkCollectionDairy_Id) {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, Reverse it!",
    },
    function (result) {
      if (result == true) {
        var Method_Name = "Reverse";
        var APIEndPoint = "SaveMilkCollection";
        var url = "/Collection/MilkCollection";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          milkcollectiondairy_id: MilkCollectionDairy_Id,
        };
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (result) {
            var res = JSON.parse(result);
            if (res[0].result_id == 1) {
              Show_Success_Toastr(
                "Reverse Milk Receipt Entry and Corresponding Trip Document"
              );
              GetSearchList();
            } else {
              Show_Error_Toastr(
                "Error : Reverse the Corresponding Collection Approval Entry First"
              );
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Milk Receipt details not Reverse");
          },
        });
      }
    }
  );
}
