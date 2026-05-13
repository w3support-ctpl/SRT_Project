$(document).ready(function () {
  $("#ddlSearchStatus").select2();
  GetMaster("ddlSearchStatus", "Select Status", "GetStatus", "", "");
  $("#ddlSearchMilkCollectionShift").select2();
  GetMaster(
    "ddlSearchMilkCollectionShift",
    "Select Milk Collection Shift",
    "GetMilkCollectionShiftAll",
    "",
    ""
  );
});

// Get list of all the Routes
function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var APIEndPoint = "GetRoute";
  var RouteName = "%" + $("#txtSearchRouteName").val() + "%";
  var RouteCode = "%" + $("#ddlSearchMilkCollectionShift").val() + "%";
  var Status_Id = "%" + $("#ddlSearchStatus").val() + "%";
  $("#btn_Search").prop("disabled", true);

  var Method_Name = "Get";
  var url = "/Transporter/Route";
  var reqdata = {
    method_name: Method_Name,
    route_name: RouteName,
    route_code: RouteCode,
    route_status_id: Status_Id,
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
        TableHTML += "<td>" + value.route_code + "</td>";
        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.vehicletype_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 80px; padding: 8px 5px 8px 5px;">';
        if (EditFlag == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.route_id +
            "', 'Edit');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        // Copy
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Copy" onclick="ShowEditEntry(\'' +
          value.route_id +
          "', 'Copy');\">";
        TableHTML += '<i class="fa fa-copy"></i>';
        TableHTML += "</a>";

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [6], "Route");
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

// Show new form to add data
function ShowAddEntry() {
  ShowContentDiv("Transporter", "RouteAdd", "", function () {
    // Initialization Code
    $("#ddlEntryMilkCollectionShift").select2();
    $("#ddlEntryVehicleType").select2();
    // $("#ddlEntryFrequency").select2();
    $("#ddlEntryMCCName").select2();
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divEntryRouteItemTable").hide();

    $("#divFooterDelete").show();

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");

    // Route Entry
    GetMaster(
      "ddlEntryMilkCollectionShift",
      "Select Milk Collection Shift",
      "GetMilkCollectionShiftAll",
      "",
      ""
    );
    GetMaster(
      "ddlEntryVehicleType",
      "Select Vehicle Type",
      "GetVehicleType",
      "",
      ""
    );
    /*GetMaster(
            "ddlEntryFrequency",
            "Select Frequency",
            "GetRouteFrequency",
            "",
            ""
        );*/
  });
}

//Show form to edit data
function ShowEditEntry(Route_Id, Action) {
  ShowContentDiv("Transporter", "RouteEdit", "", function () {
    // Initialization Code
    $("#ddlEntryMilkCollectionShift").select2();
    $("#ddlEntryVehicleType").select2();
    $("#ddlEntryFrequency").select2();
    $("#ddlEntryMCCName").select2();
    if (Action == "Edit") {
      $("#lblEntryId").html(Route_Id);
      $("#lblAction").html("Edit");
    } else if (Action == "Copy") {
      $("#lblEntryId").html(Route_Id);
      $("#lblAction").html("Copy");
      $("#divEntryRouteItemTable").hide();
    }

    $("#divFooterDelete").show();

    // Taking values from DB
    var APIEndPoint = "GetRoute";
    var Method_Name = "Get_One";
    var url = "/Transporter/Route";
    var reqdata = {
      method_name: Method_Name,
      route_id: Route_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        // if Locked then user can't delete or change it's active status.
        if (res[0].is_locked == 1) {
          // $("#chkEntryStatus").prop({ checked: true, disabled: true });
          $("#divFooterDelete").hide();
        } else {
          $("#chkEntryStatus").prop({ checked: false, disabled: false });
          $("#divFooterDelete").show();
        }
        // CheckLive status and disabel input fields if it is live
        if (res[0].is_lived == 1) {
          $("#chkEntryLiveStatus").prop({ checked: true, disabled: true });
          $("#txtEntryRouteCode").prop("disabled", true);
          $("#txtEntryRouteName").prop("disabled", true);
          $("#ddlEntryMilkCollectionShift").prop("disabled", true);
          $("#ddlEntryVehicleType").prop("disabled", true);
          $("#txtEntryStartDate").prop("disabled", true);
          // $("#txtEntryFreightFixCost").prop("disabled", "true");
          // $("#ddlEntryFrequency").prop("disabled", "true");
          // $("#txtDuration").prop("disabled", "true");
          // $("#txtFuelRequired").prop("disabled", "true");
        } else {
          $("#chkEntryLiveStatus").prop({ checked: false, disabled: false });
        }
        // Check Active status
        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }

        // Fill data in input fields
        $("#txtEntryRouteCode").val(res[0].route_code);
        $("#txtEntryRouteName").val(res[0].route_name);
        $("#txtEntryTotalDistance").val(res[0].total_distance);
        GetMaster(
          "ddlEntryMilkCollectionShift",
          "Select Milk Collection Shift",
          "GetMilkCollectionShiftAll",
          res[0].collectionshift_id,
          ""
        );
        GetMaster(
          "ddlEntryVehicleType",
          "Select Vehicle Type",
          "GetVehicleType",
          res[0].vehicletype_id,
          ""
        );
        $("#txtEntryFreightFixCost").val(res[0].freight_fix_cost);
        /*GetMaster(
                    "ddlEntryFrequency",
                    "Select Frequency",
                    "GetRouteFrequency",
                    res[0].frequency_id,
                    ""
                );*/
        $("#txtDuration").val(res[0].duration);
        $("#txtFuelRequired").val(res[0].fuel_required);
        $("#txtEntryStartTime").val(res[0].start_time);
        $("#txtEntryEndTime").val(res[0].end_time);
        $("#txtEntryStartDate").val(res[0].start_date);
        $("#txtEntryEndDate").val(res[0].end_date);
        if (Action == "Edit") {
          ShowRouteItemTable(Route_Id);
          SetMCCDropdown();
        }
      },
      error: function (result) {
        Show_Error_Toastr(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });

    // Route Entry

    //GetMaster("ddlEntryMCCName", "Select MCC", "GetMCC", "", "");
  });
}

// Close entry page and open search page
function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

// Save and Update Route Entry
function SaveEntry() {
  // Validation code
  var RouteCode = $("#txtEntryRouteCode").val().trim();
  var RouteName = $("#txtEntryRouteName").val().trim();
  var MilkCollectionShift_Id = $("#ddlEntryMilkCollectionShift").val();
  var VehicleType_Id = $("#ddlEntryVehicleType").val();
  var FreightFixCost = $("#txtEntryFreightFixCost").val().trim();
  // var Frequency_Id = $("#ddlEntryFrequency").val().join();
  var PBDuration = $("#txtDuration").val().trim();
  var PBFuelRequired = $("#txtFuelRequired").val().trim();
  var StartTime = $("#txtEntryStartTime").val();
  var EndTime = $("#txtEntryEndTime").val();
  var StartDate = $("#txtEntryStartDate").val();
  var EndDate = $("#txtEntryEndDate").val();
  var TotalDistance = $("#txtEntryTotalDistance").val();

  var IsValid = 1;

  if (RouteCode == "" || RouteCode == null || RouteCode == undefined) {
    IsValid = 0;
    $("#txtEntryRouteCode").addClass("is-invalid state-invalid");
  }
  if (RouteName == "" || RouteName == null || RouteName == undefined) {
    IsValid = 0;
    $("#txtEntryRouteName").addClass("is-invalid state-invalid");
  }
  if (
    MilkCollectionShift_Id == "" ||
    MilkCollectionShift_Id == null ||
    MilkCollectionShift_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryMilkCollectionShift").addClass("is-invalid state-invalid");
  }
  if (
    VehicleType_Id == "" ||
    VehicleType_Id == null ||
    VehicleType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryVehicleType").addClass("is-invalid state-invalid");
  }
  /*if (Frequency_Id == "" || Frequency_Id == null || Frequency_Id == undefined) {
        IsValid = 0;
        $("#ddlEntryFrequency").addClass("is-invalid state-invalid");
    }*/
  if (StartTime == "" || StartTime == null || StartTime == undefined) {
    IsValid = 0;
    $("#txtEntryStartTime").addClass("is-invalid state-invalid");
  }
  if (EndTime == "" || EndTime == null || EndTime == undefined) {
    IsValid = 0;
    $("#txtEntryEndTime").addClass("is-invalid state-invalid");
  }
  if (StartDate == "" || StartDate == null || StartDate == undefined) {
    IsValid = 0;
    $("#txtEntryStartDate").addClass("is-invalid state-invalid");
  }
  if (EndDate == "" || EndDate == null || EndDate == undefined) {
    IsValid = 0;
    $("#txtEntryEndDate").addClass("is-invalid state-invalid");
  }
  if (
    TotalDistance == "" ||
    TotalDistance == null ||
    TotalDistance == undefined ||
    Is_Valid_Float(TotalDistance) == false ||
    Is_Valid_NumberCheck(TotalDistance) == false
  ) {
    IsValid = 0;
    $("#txtEntryTotalDistance").addClass("is-invalid state-invalid");
  }
  if (FreightFixCost != "") {
    if (
      FreightFixCost == null ||
      FreightFixCost == undefined ||
      //   Is_Positive_Integer(FreightFixCost) == false ||
      // Is_Valid_NumberCheck(FreightFixCost) == false ||
      Is_Valid_Float(FreightFixCost) == false
    ) {
      IsValid = 0;
      $("#txtEntryFreightFixCost").addClass("is-invalid state-invalid");
    }
  }
  if (PBDuration != "") {
    if (
      PBDuration == null ||
      PBDuration == undefined ||
      //   Is_Positive_Integer(PBDuration) == false ||
      // Is_Valid_NumberCheck(PBDuration) == false ||
      Is_Valid_Float(PBDuration) == false
    ) {
      IsValid = 0;
      $("#txtDuration").addClass("is-invalid state-invalid");
    }
  }
  if (PBFuelRequired != "") {
    if (
      PBFuelRequired == null ||
      PBFuelRequired == undefined ||
      //   Is_Positive_Integer(PBFuelRequired) == false ||
      // Is_Valid_NumberCheck(PBFuelRequired) == false ||
      Is_Valid_Float(PBFuelRequired) == false
    ) {
      IsValid = 0;
      $("#txtFuelRequired").addClass("is-invalid state-invalid");
    }
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    Show_Loader();
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveRoute";
    var Method_Name = "Create";
    var Route_Id = "";
    var Action_Name = $("#lblAction").html();
    // console.log(Action_Name);
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Route_Id = $("#lblEntryId").html();
    }
    if (Action_Name == "Copy") {
      Method_Name = "Copy";
      Route_Id = $("#lblEntryId").html();
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
    var url = "/Transporter/Route";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      is_lived: Is_Lived,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      route_id: Route_Id,
      total_distance: TotalDistance,
      route_code: RouteCode,
      route_name: RouteName,
      collectionshift_id: MilkCollectionShift_Id,
      vehicletype_id: VehicleType_Id,
      freight_fix_cost: FreightFixCost,
      // frequency_id: Frequency_Id,
      duration: PBDuration,
      fuel_required: PBFuelRequired,
      start_time: StartTime,
      end_time: EndTime,
      start_date: StartDate,
      end_date: EndDate,
    };

    // // console.log(reqdata);

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
          ShowRouteItemAddEntry();
          $("#lblEntryId").html(result[0].result_extra_key);

          $("#divFooterDelete").show();

          if (Is_Lived == 1) {
            $("#txtEntryRouteCode").prop("disabled", "true");
            $("#txtEntryRouteName").prop("disabled", "true");
            $("#ddlEntryMilkCollectionShift").prop("disabled", "true");
            $("#ddlEntryVehicleType").prop("disabled", "true");
            $("#txtEntryStartDate").prop("disabled", true);
            // $("#txtEntryFreightFixCost").prop("disabled", "true");
            // $("#ddlEntryFrequency").prop("disabled", "true");
            // $("#txtDuration").prop("disabled", "true");
            // $("#txtFuelRequired").prop("disabled", "true");
          }
          if (Method_Name == "Create" || Method_Name == "Update") {
            ShowEditEntry(result[0].result_extra_key, "Edit");
            $("#lblAction").html("Edit");
          }
          if (Action_Name == "Copy") {
            ShowEditEntry(result[0].result_extra_key, "Copy");
            $("#lblAction").html("Copy");
          }
          ShowEntrySuccess("Route details saved successfully");

          Show_Success_Toastr("Route details saved successfully");
          Hide_Loader();
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : Route details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}

// Show form to add Route Item
function ShowRouteItemAddEntry() {
  $("#divEntryRouteItemTable").show();
  $("#lblRouteItemStageNo").html("");
  $("#lblRouteItemAction").html("Add");
  SetMCCDropdown();
}

// Show form to edit Route Item
function ShowRouteItemEditEntry(StageNo) {
  $("#lblRouteItemStageNo").html(StageNo);
  $("#lblRouteItemAction").html("Edit");
  OpenModal("Edit");
  var APIEndPoint = "GetRouteItem";
  Route_Id = $("#lblEntryId").html();
  Method_Name = "Get_One";
  var url = "/Transporter/RouteItem";
  var reqdata = {
    method_name: Method_Name,
    route_id: Route_Id,
    stage_no: StageNo,
    api_end_point: APIEndPoint,
  };

  //Get Individual Route Item
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // MCC for Vehice Type as Truck
      if ($("#ddlEntryVehicleType").val() == "C020001") {
        GetMaster(
          "ddlEntryMCCName",
          "Select MCC",
          "GetCanMCC",
          res[0].mcc_id,
          ""
        );
      }
      // MCC for Vehice Type as Tanker
      if ($("#ddlEntryVehicleType").val() == "C020002") {
        GetMaster(
          "ddlEntryMCCName",
          "Select MCC",
          "GetBMCMCC",
          res[0].mcc_id,
          ""
        );
      }
      $("#txtEntryDistanceInKm").val(res[0].distance);
      $("#txtEntryArrivalTime").val(res[0].arrival_time);
      $("#txtEntryDepartureTime").val(res[0].departure_time);
      $("#modelEntryRoute")
        .modal({
          backdrop: "static",
        })
        .modal("show");
    },
    error: function () {
      $("#modelEntryRoute").modal("hide");
      ShowItemError("Error : Route Item details not saved");
      $("#btn_Save_Item").prop("disabled", false);
    },
  });
}

// Save Route Item Entry
function SaveRouteItemEntry() {
  // Validation
  MCC_Id = $("#ddlEntryMCCName").val();
  Distance = $("#txtEntryDistanceInKm").val();
  ArrivalTime = $("#txtEntryArrivalTime").val();
  DepartureTime = $("#txtEntryDepartureTime").val();
  Route_Id = $("#lblEntryId").html();
  var IsValid = 1;

  if (MCC_Id == "" || MCC_Id == null || MCC_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMCCName").addClass("is-invalid state-invalid");
  }
  if (
    Distance == "" ||
    Distance == null ||
    Distance == undefined ||
    Is_Valid_Float(Distance) == false ||
    // Is_Positive_Integer(Distance) == false ||
    Is_Valid_NumberCheck(Distance) == false
  ) {
    IsValid = 0;
    $("#txtEntryDistanceInKm").addClass("is-invalid state-invalid");
  }
  if (ArrivalTime == "" || ArrivalTime == null || ArrivalTime == undefined) {
    IsValid = 0;
    $("#txtEntryArrivalTime").addClass("is-invalid state-invalid");
  }
  if (
    DepartureTime == "" ||
    DepartureTime == null ||
    DepartureTime == undefined
  ) {
    IsValid = 0;
    $("#txtEntryDepartureTime").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    Show_Loader();
    // Start Saving
    $("#btn_Save_Item").prop("disabled", true);
    var APIEndPoint = "SaveRouteItem";
    var Method_Name = "Create";
    var StageNo = 0;
    var Action_Name = $("#lblRouteItemAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      StageNo = $("#lblRouteItemStageNo").html();
    }
    var url = "/Transporter/RouteItem";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      route_id: Route_Id,
      stage_no: StageNo,
      mcc_id: MCC_Id,
      distance: Distance,
      arrival_time: ArrivalTime,
      departure_time: DepartureTime,
    };

    //Save Route Item
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          $("#modelEntryRoute").modal("hide");
          ShowItemSuccess("Route Item details saved successfully");
          Show_Success_Toastr("Route Item details saved successfully");

          $("#btn_Save_Item").prop("disabled", false);
          ShowRouteItemTable(Route_Id);
          ResetRouteItemForm();
          Hide_Loader();
          //GetSearchList();
        } else {
          Hide_Loader();
          $("#modelEntryRoute").modal("hide");
          ShowItemError("Error : " + result[0].result_description);
          $("#btn_Save_Item").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        $("#modelEntryRoute").modal("hide");
        ShowItemError("Error : Route Item details not saved");
        $("#btn_Save_Item").prop("disabled", false);
      },
    });
  }
}

// Get a list of all the information of a route
function ShowRouteItemTable(Route_Id) {
  ClearDataTable("tablerouteitems");
  var APIEndPoint = "GetRouteItem";
  var Method_Name = "Get";
  var url = "/Transporter/RouteItem";
  var reqdata = {
    method_name: Method_Name,
    route_id: Route_Id,
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
      var Row_No = 0;

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1;
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.stage_no + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.distance + "</td>";
        TableHTML += "<td>" + value.arrival_times + "</td>";
        TableHTML += "<td>" + value.departure_times + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 160px; padding: 5px 3px 5px 3px;">';

        /*TableHTML +=
                            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Up" onclick="MoveItemUp(\'' +
                            value.stage_no +
                            "')\">";
                        TableHTML += '<i class="fa fa-arrow-circle-o-up"></i>';
                        TableHTML += "</a>";
        
                        TableHTML +=
                            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Down" onclick="MoveItemDown(\'' +
                            value.stage_no +
                            "')\">";
                        TableHTML += '<i class="fa fa-arrow-circle-o-down"></i>';
                        TableHTML += "</a>";
                        */

        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowRouteItemEditEntry(\'' +
          value.stage_no +
          "')\">";
        TableHTML += '<i class="fa fa-pencil"></i>';
        TableHTML += "</a>";

        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryRouteItem(\'' +
          value.stage_no +
          "')\">";
        TableHTML += '<i class="fa fa-trash"></i>';
        TableHTML += "</a>";

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntry").html(TableHTML);
      SetDataTable("tablerouteitems", [6], "Route Item");
      $("#btn_Save_Item").prop("disabled", false);
      $("#modelEntryRoute").modal("hide");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Save_Item").prop("disabled", false);
    },
  });

  return;
}

// Warning to ask if user really wants to delete a Route Entry
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
  var APIEndPoint = "SaveRoute";
  var Route_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  // In success do following things
  var url = "/Transporter/Route";
  var reqdata = {
    route_id: Route_Id,
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
        Show_Success_Toastr("Route details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Route details not deleted");
    },
  });
}

function SaveDeleteEntryRouteItem(StageNo) {
  // Write code to delete
  var APIEndPoint = "SaveRouteItem";
  var Route_Id = $("#lblEntryId").html();
  var url = "/Transporter/RouteItem";
  var reqdata = {
    stage_no: StageNo,
    method_name: "Delete",
    route_id: Route_Id,
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
        ShowItemSuccess("Route Item details deleted successfully");
        ShowRouteItemTable(Route_Id);
        //GetSearchList();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : Route Item details not deleted");
    },
  });
}

function OpenModal(action) {
  $("#modelEntryRoute")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblActionRouteItem").html(action);
  SetMCCDropdown();
  if (action == "Add") {
    $("#AddEditRouteItem").text("Add Route Item Details");
  }
  if (action == "Edit") {
    $("#AddEditRouteItem").text("Edit Rout Item Details");
  }
}

$("#modelEntryRoute").on("hidden.bs.modal", function (e) {
  ResetRouteItemForm();
  $("#lblActionRouteItem").html("");
  $("#AddEditRouteItem").text("");
});

function AddEditEntry() {
  var Action = $("#lblAction").html();
}

function SetMCCDropdown() {
  // MCC for Vehice Type as Truck
  if ($("#ddlEntryVehicleType").val() == "C020001") {
    GetMaster("ddlEntryMCCName", "Select MCC", "GetCanMCC", "", "");
  }
  // MCC for Vehice Type as Tanker
  if ($("#ddlEntryVehicleType").val() == "C020002") {
    GetMaster("ddlEntryMCCName", "Select MCC", "GetBMCMCC", "", "");
  }
}

function ResetRouteItemForm() {
  $(".modal input").val("");
  //    $(".modal select").val('');
}
