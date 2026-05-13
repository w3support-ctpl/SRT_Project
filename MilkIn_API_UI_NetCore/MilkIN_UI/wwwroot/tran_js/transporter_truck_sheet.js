$(document).ready(function () {
  vehicleType = "";
  vehicheType_Id = "";
  VehicleType = $("#lblVehicleType").html();
  if (VehicleType == "Truck") {
    vehicleType = "truck";
    vehicheType_Id = "C020001";
  }
  if (VehicleType == "Tanker") {
    vehicleType = "tanker";
    vehicheType_Id = "C020002";
  }
  $("#ddlSearchRoute").select2();
  GetMaster(
    "ddlSearchRoute",
    "Select Route",
    "GetRouteLive",
    "",
    vehicheType_Id
  );
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var APIEndPoint = "GetVehicleSheet";
  var Route_Id = $("#ddlSearchRoute").val();
  if (Route_Id == "") {
    $("#ddlSearchRoute").addClass("is-invalid state-invalid");
    return;
  }
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Transporter/VehicleSheet";
  var reqdata = {
    method_name: Method_Name,
    route_id: Route_Id,
    vehicle_type: VehicleType,
    api_end_point: APIEndPoint,
    vehicletype: vehicleType,
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
      var DeleteFlag = 1;

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
        TableHTML += "<td>" + value.entry_id + "</td>";
        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.driver_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.vehicletype_name + "</td>";
        TableHTML += "<td>" + value.from_date + "</td>";
        TableHTML += "<td>" + value.to_date + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.entry_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [9], "Truck Sheet");
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
  if ($("#ddlSearchRoute").val() == "") {
    $("#ddlSearchRoute").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Please select Route");
    return;
  }
  ShowContentDiv("Transporter", "VehicleSheetAdd", "", function () {
    // Initialization Code
    $("#ddlEntryVehicleNo").select2();
    $("#ddlEntryDriver").select2();
    $("#ddlEntryRouteChemist").select2();

    $("#txtEntryStartDate").attr("min", new Date().toDateInputValue());
    $("#txtEntryEndDate").attr("min", $("#txtEntryStartDate").val());

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();

    // Setting Values of Dropdowns
    GetMaster("ddlEntryDriver", "Select Driver Name", "GetDriver", "", "");
    GetMaster(
      "ddlEntryRouteChemist",
      "Select Route Chemist",
      "GetRouteChemist",
      "",
      ""
    );

    if (VehicleType == "Truck") {
      // Set Vehicle Dropdown values based on Vehicle type.
      GetMaster(
        "ddlEntryVehicleNo",
        "Select Vehicle No",
        "GetTruckVehicle",
        "",
        ""
      );
      // Hide input fields based on Vehicle Type
      $("#divRouteChemist").hide();
      $("#divEndDate").show();
    } else {
      // Set Vehicle Dropdown values based on Vehicle type.
      GetMaster(
        "ddlEntryVehicleNo",
        "Select Vehicle No",
        "GetTankerVehicle",
        "",
        ""
      );
      // Hide input fields based on Vehicle Type
      $("#divRouteChemist").show();
      $("#divEndDate").hide();
    }
  });
}

function ShowEditEntry(Entry_Id) {
  ShowContentDiv("Transporter", "VehicleSheetEdit", "", function () {
    // Initialization Code
    $("#ddlEntryVehicleNo").select2();
    $("#ddlEntryDriver").select2();
    $("#ddlEntryRouteChemist").select2();

    $("#txtEntryStartDate").attr("min", new Date().toDateInputValue());
    $("#txtEntryEndDate").attr("min", $("#txtEntryStartDate").val());

    $("#lblEntryId").html(Entry_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();

    var APIEndPoint = "GetVehicleSheet";
    var Method_Name = "Get_One";
    var url = "/Transporter/VehicleSheet";
    var SessionRoleId = $("#lblSessionRoleId").html();
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      api_end_point: APIEndPoint,
      vehicletype: vehicleType,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        if (res[0].is_locked == "1") {
          if (SessionRoleId == "MU001") {
            $("#btn_MasterSave").show();
          } else {
            $("#btn_MasterSave").hide();
          }

          $("#btn_Save").hide();
          $("#divFooterDelete").hide();
          $("#chkEntryStatus").prop("disabled", true);
        } else {
          $("#btn_MasterSave").hide();
          $("#btn_Save").show();
          $("#divFooterDelete").show();
          $("#chkEntryStatus").prop("disabled", false);
        }

        GetMaster(
          "ddlEntryDriver",
          "Select Driver Name",
          "GetDriver",
          res[0].driver_id,
          ""
        );
        GetMaster(
          "ddlEntryRoute",
          "Select Route Name",
          "GetRoute",
          res[0].route_id,
          ""
        );
        $("#txtEntryStartDate").val(res[0].from_date);
        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }

        if (VehicleType == "Truck") {
          // Set Vehicle Dropdown values based on Vehicle type.
          GetMaster(
            "ddlEntryVehicleNo",
            "Select Vehicle No",
            "GetTruckVehicle",
            res[0].vehicle_id,
            ""
          );
          $("#txtEntryEndDate").val(res[0].to_date);
          // Hide input fields based on Vehicle Type
          $("#divRouteChemist").hide();
          $("#divEndDate").show();
        } else {
          // Set Vehicle Dropdown values based on Vehicle type.
          GetMaster(
            "ddlEntryVehicleNo",
            "Select Vehicle No",
            "GetTankerVehicle",
            res[0].vehicle_id,
            ""
          );
          GetMaster(
            "ddlEntryRouteChemist",
            "Select Route Chemist",
            "GetRouteChemist",
            res[0].chemist_id,
            ""
          );
          // Hide input fields based on Vehicle Type
          $("#divRouteChemist").show();
          $("#divEndDate").hide();
        }
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
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
  var Route_Id = $("#ddlSearchRoute").val();
  var VehicleType_Id = $("#ddlEntryVehicle").val();
  var VehicleNo_Id = $("#ddlEntryVehicleNo").val();
  var Driver_Id = $("#ddlEntryDriver").val();
  var RouteChemist_Id = $("#ddlEntryRouteChemist").val();
  var StartDate = $("#txtEntryStartDate").val();
  if (VehicleType == "Truck") {
    var RouteChemist_Id = "";
    var EndDate = $("#txtEntryEndDate").val();
    if (EndDate == "" || EndDate == null || EndDate == undefined) {
      IsValid = 0;
      $("#txtEntryEndDate").addClass("is-invalid state-invalid");
    }
  } else {
    var RouteChemist_Id = $("#ddlEntryRouteChemist").val();
    if (
      RouteChemist_Id == "" ||
      RouteChemist_Id == null ||
      RouteChemist_Id == undefined
    ) {
      IsValid = 0;
      $("#ddlEntryRouteChemist").addClass("is-invalid state-invalid");
    }
    var EndDate = StartDate;
  }

  var IsValid = 1;

  if (VehicleNo_Id == "" || VehicleNo_Id == null || VehicleNo_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryVehicleNo").addClass("is-invalid state-invalid");
  }
  if (Driver_Id == "" || Driver_Id == null || Driver_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryDriver").addClass("is-invalid state-invalid");
  }

  if (StartDate == "" || StartDate == null || StartDate == undefined) {
    IsValid = 0;
    $("#txtEntryStartDate").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveVehicleSheet";
    var Method_Name = "Create";
    var Entry_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblEntryId").html();
    }
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Transporter/VehicleSheet";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      route_id: Route_Id,
      vehicletype_id: VehicleType_Id,
      vehicle_no_id: VehicleNo_Id,
      driver_id: Driver_Id,
      chemist_id: RouteChemist_Id,
      from_date: StartDate,
      to_date: EndDate,
      entry_id: Entry_Id,
      vehicletype: vehicleType,
    };
    // console.log(reqdata);
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
          Hide_Loader();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          ShowEntrySuccess(VehicleType + " Sheet details saved successfully");
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : " + VehicleType + " Sheet details not saved");
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
  var APIEndPoint = "SaveVehicleSheet";
  var Entry_Id = $("#lblEntryId").html();
  var Method_Name = "Delete";
  // In success do following things
  var url = "/Transporter/VehicleSheet";
  var reqdata = {
    entry_id: Entry_Id,
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    vehicletype: vehicleType,
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
          VehicleType + " Sheet details deleted successfully"
        );
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error : " + VehicleType + " Sheet details not deleted"
      );
    },
  });
}

Date.prototype.toDateInputValue = function () {
  var local = new Date(this);
  local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
  return local.toJSON().slice(0, 10);
};

function SetEndDateRange() {
  $("#txtEntryEndDate").attr("min", $("#txtEntryStartDate").val());
}

function SetDate() {
  Route_Id = $("#ddlSearchRoute").val();

  if (Route_Id == "") {
    $("#divSearchStartDate").hide();
    $("#divSearchEndDate").hide();
    $("#txtSearchStartDate").val("");
    $("#txtSearchEndDate").val("");
    return;
  }
  var APIEndPoint = "GetVehicleSheet";
  var Method_Name = "Get_Route";
  var url = "/Transporter/VehicleSheet";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    route_id: Route_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      $("#divSearchStartDate").show();
      $("#divSearchEndDate").show();
      $("#txtSearchStartDate").val(result[0].start_date);
      $("#txtSearchEndDate").val(result[0].end_date);
    },
    error: function () {
      Show_Error_Toastr(
        "Error : " + VehicleType + " Sheet details not deleted"
      );
    },
  });
}

function SaveMasterEntry() {
  // Validation code
  var Route_Id = $("#ddlSearchRoute").val();
  var VehicleType_Id = $("#ddlEntryVehicle").val();
  var VehicleNo_Id = $("#ddlEntryVehicleNo").val();
  var Driver_Id = $("#ddlEntryDriver").val();
  var RouteChemist_Id = $("#ddlEntryRouteChemist").val();
  var StartDate = $("#txtEntryStartDate").val();
  if (VehicleType == "Truck") {
    var RouteChemist_Id = "";
    var EndDate = $("#txtEntryEndDate").val();
    if (EndDate == "" || EndDate == null || EndDate == undefined) {
      IsValid = 0;
      $("#txtEntryEndDate").addClass("is-invalid state-invalid");
    }
  } else {
    var RouteChemist_Id = $("#ddlEntryRouteChemist").val();
    if (
      RouteChemist_Id == "" ||
      RouteChemist_Id == null ||
      RouteChemist_Id == undefined
    ) {
      IsValid = 0;
      $("#ddlEntryRouteChemist").addClass("is-invalid state-invalid");
    }
    var EndDate = StartDate;
  }

  var IsValid = 1;

  if (VehicleNo_Id == "" || VehicleNo_Id == null || VehicleNo_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryVehicleNo").addClass("is-invalid state-invalid");
  }
  if (Driver_Id == "" || Driver_Id == null || Driver_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryDriver").addClass("is-invalid state-invalid");
  }

  if (StartDate == "" || StartDate == null || StartDate == undefined) {
    IsValid = 0;
    $("#txtEntryStartDate").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveVehicleSheet";
    var Method_Name = "UpdateAll";
    var Entry_Id = $("#lblEntryId").html();

    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Transporter/VehicleSheet";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      route_id: Route_Id,
      vehicletype_id: VehicleType_Id,
      vehicle_no_id: VehicleNo_Id,
      driver_id: Driver_Id,
      chemist_id: RouteChemist_Id,
      from_date: StartDate,
      to_date: EndDate,
      entry_id: Entry_Id,
      vehicletype: vehicleType,
    };
    // console.log(reqdata);
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
          Hide_Loader();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          ShowEntrySuccess(VehicleType + " Sheet details saved successfully");
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : " + VehicleType + " Sheet details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}
