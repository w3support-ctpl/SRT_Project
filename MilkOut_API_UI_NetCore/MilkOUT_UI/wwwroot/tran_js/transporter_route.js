$(document).ready(function () {
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

// Get list of all the Routes
function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var RouteName = "%" + $("#txtSearchRouteName").val() + "%";

  var SearchPeriod = $("#txtSearchDate").val();

  var Is_Valid = 1;

  if (SearchPeriod == "") {
    Is_Valid = 0;
    $("#txtSearchDate").addClass("is-invalid state-invalid");
  }
  if (Is_Valid == 0) {
    Show_Error_Toastr(
      "Can't search. Please provide all the required information."
    );
    return;
  }

  // Get data from database and show in table
  var url = "/Transporter/Route";

  var APIEndPoint = "GetRoute";
  var Method_Name = "Get";

  $("#btn_Search").prop("disabled", true);

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    route_name: RouteName,
    search_period: SearchPeriod,
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
      var Active_Status;

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.date + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.route_id +
            "', '" +
            value.route_name +
            "', '" +
            value.vehicle_no +
            "', '" +
            value.is_active +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [4], "Route");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
  return;
}

// Show new form to add data
function ShowAddEntry() {
  ShowContentDiv("Transporter", "RouteAdd", "", function () {
    $("#ddlEntryVehicle").select2();

    GetMaster_fleetx("ddlEntryVehicle", "Select Vehicle", "Get", "", "");

    $("#divFooterDelete").hide();
    $("#divEntryRouteItemTable").hide();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divEntryVehicle").show();

    $("#divEntryVehicleName").hide();
  });
}

function OpenModal(action) {
  $("#modelEntryRoute")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#ddlEntryModelType").select2();
  $("#ddlEntryModelDealer").select2();
  $("#ddlEntryModelRetailer").select2();

  GetMaster("ddlEntryModelType", "Select Type", "GetType", "", "");
  GetMaster("ddlEntryModelDealer", "Select Dealer Name", "GetDealer", "", "");
  GetMaster(
    "ddlEntryModelRetailer",
    "Select Retailer Name",
    "GetRetailer",
    "",
    ""
  );

  $("#lblModelEntryId").html("");
  $("#lblModelAction").html(action);

  $("#btn_Save_Item").prop("disabled", false);
  $("#divEntryModelDealer").hide();
  $("#divEntryModelRetailer").hide();
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function SaveEntry() {
  // Validation code
  var RouteName = $("#txtEntryRouteName").val().trim();

  var IsValid = 1;
  var Action_Name = $("#lblAction").html();

  if (RouteName == "" || RouteName == undefined || RouteName == null) {
    IsValid = 0;
    $("#txtEntryRouteName").addClass("is-invalid state-invalid");
  }
  var Vehicle = "";

  if (Action_Name == "Add") {
    Vehicle = $("#ddlEntryVehicle").val();
  } else if (Action_Name == "Edit") {
    Vehicle = $("#txtEntryVehicleName").val();
  }

  if (Vehicle == "" || Vehicle == undefined || Vehicle == null) {
    IsValid = 0;

    if (Action_Name == "Add") {
      $("#ddlEntryVehicle").addClass("is-invalid state-invalid");
    } else if (Action_Name == "Edit") {
      $("#txtEntryVehicleName").addClass("is-invalid state-invalid");
    }
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveRoute";
  var Method_Name = "Create_h";
  var Route_Id = "";

  if (Action_Name == "Edit") {
    Method_Name = "Update_h";
    Route_Id = $("#lblEntryId").html();
  }

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  var url = "/Transporter/Route";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    route_id: Route_Id,
    route_name: RouteName,
    vehicle_no: Vehicle,
    is_active: Is_Active,
    is_deleted: Is_Deleted,
  };

  console.log(reqdata);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        // Show Success Message
        ShowEntrySuccess("Route details saved successfully");

        $("#lblEntryId").html(result[0].result_extra_key);
        $("#lblAction").html("Edit");
        $("#divFooterDelete").show();
        $("#divEntryRouteItemTable").show();
        ShowEditEntry(
          result[0].result_extra_key,
          RouteName,
          Vehicle,
          Is_Active
        );
      } else {
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      ShowEntryError("Error : Route details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
}

function GetMaster_fleetx(
  ControlName,
  ControlCaption,
  MethodName,
  DefaultValue,
  ParentFieldId
) {
  var JQ_ControlName = "#" + ControlName;
  if (ControlCaption != "") {
    $(JQ_ControlName)
      .empty()
      .append($("<option></option>").val("").html(ControlCaption));
  } else {
    $(JQ_ControlName).empty();
  }

  DefaultValue = DefaultValue + "";
  var APIEndPoint = "GetFleetXDatas";

  var url = "/Transporter/Route";
  var reqdata = {
    method_name: MethodName,
    ParentField_Id: ParentFieldId,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      var result_1 = JSON.parse(result);

      $.each(result_1, function (data, value) {
        $(JQ_ControlName).append(
          $("<option></option>").val(value.item_id).html(value.item_value)
        );
      });

      if (DefaultValue != "" && DefaultValue.charAt(0) == "[") {
        $(JQ_ControlName).val(JSON.parse(DefaultValue)).change(); // Multiselect
      } else if (DefaultValue != "" && DefaultValue.charAt(0) != "[") {
        $(JQ_ControlName).val(DefaultValue); // Single select
      }
    },
    error: function () {
      Show_Error_Toastr("Error in fetching master data");
    },
  });
}

function ShowEditEntry(Route_Id, RouteName, Vehicle, Is_Active) {
  ShowContentDiv("Transporter", "RouteEdit", "", function () {
    // Initialization Code
    $("#ddlEntryUserRole").select2();
    $("#divFooterDelete").show();
    $("#divEntryRouteItemTable").show();
    $("#lblEntryId").html(Route_Id);
    $("#txtEntryRouteName").val(RouteName);
    $("#txtEntryVehicleName").val(Vehicle);
    $("#lblAction").html("Edit");
    $("#btn_Save").prop("disabled", false);

    $("#divEntryVehicle").hide();

    $("#divEntryVehicleName").show();
    if (Is_Active == "1" || Is_Active == 1) {
      $("#chkEntryStatus").prop("checked", true);
    } else {
      $("#chkEntryStatus").prop("checked", false);
    }

    GetSearchItemList(Route_Id);
  });
}

function GetSearchItemList(Route_Id) {
  ClearDataTable("tablerouteitems");
  // Get data from database and show in table
  var url = "/Transporter/Route";

  var APIEndPoint = "GetRoute";
  var Method_Name = "Get_One";

  $("#btn_Search").prop("disabled", true);

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
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.createdby_name + "</td>";
        TableHTML += "<td>" + value.type + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowItemEditEntry(\'' +
            value.entry_id +
            "', '" +
            value.type +
            "', '" +
            value.createdby_id +
            "', '" +
            value.createdby_name +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";

          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowItemDeleteEntry(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntry").html(TableHTML);

      SetDataTable("tablerouteitems", [3], "Route");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
  return;
}

function SaveEntry() {
  // Validation code
  var RouteName = $("#txtEntryRouteName").val().trim();

  var IsValid = 1;
  var Action_Name = $("#lblAction").html();

  if (RouteName == "" || RouteName == undefined || RouteName == null) {
    IsValid = 0;
    $("#txtEntryRouteName").addClass("is-invalid state-invalid");
  }
  var Vehicle = "";

  if (Action_Name == "Add") {
    Vehicle = $("#ddlEntryVehicle").val();
  }
  if (Action_Name == "Edit") {
    Vehicle = $("#txtEntryVehicleName").val();
  }

  if (Vehicle == "" || Vehicle == undefined || Vehicle == null) {
    IsValid = 0;

    if (Action_Name == "Add") {
      $("#ddlEntryVehicle").addClass("is-invalid state-invalid");
    }
    if (Action_Name == "Edit") {
      $("#txtEntryVehicleName").addClass("is-invalid state-invalid");
    }
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  $("#btn_Save").prop("disabled", true);

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  // Save
  var APIEndPoint = "SaveRoute";
  var Method_Name = "Create_h";
  var Route_Id = "";

  if (Action_Name == "Edit") {
    Method_Name = "Update_h";
    Route_Id = $("#lblEntryId").html();
  }

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  var url = "/Transporter/Route";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    route_id: Route_Id,
    route_name: RouteName,
    vehicle_no: Vehicle,
    is_active: Is_Active,
    is_deleted: Is_Deleted,
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
        ShowEntrySuccess("Route details saved successfully");

        $("#lblEntryId").html(result[0].result_extra_key);
        $("#lblAction").html("Edit");
        $("#divFooterDelete").show();
        $("#divEntryRouteItemTable").show();
        ShowEditEntry(
          result[0].result_extra_key,
          RouteName,
          Vehicle,
          Is_Active
        );
      } else {
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      ShowEntryError("Error : Route details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
}

function ChangeType() {
  var type = $("#ddlEntryModelType").val();

  if (type == "Dealer") {
    $("#divEntryModelDealer").show();
    $("#divEntryModelRetailer").hide();
  } else if (type == "Retailer") {
    $("#divEntryModelDealer").hide();
    $("#divEntryModelRetailer").show();
  } else if (type == "" || type == undefined || type == null) {
    $("#divEntryModelDealer").hide();
    $("#divEntryModelRetailer").hide();
  } else {
    $("#divEntryModelDealer").hide();
    $("#divEntryModelRetailer").hide();
  }
}

function SaveRouteItemEntry() {
  var IsValid = 1;
  var Action_Name = $("#lblModelAction").html();
  var Type = $("#ddlEntryModelType").val();
  var User_Id = "";

  if (Type == "" || Type == undefined || Type == null) {
    IsValid = 0;
    $("#ddlEntryModelType").addClass("is-invalid state-invalid");
  }
  if (Type == "Dealer") {
    User_Id = $("#ddlEntryModelDealer").val();
  } else if (Type == "Retailer") {
    User_Id = $("#ddlEntryModelRetailer").val();
  }

  if (User_Id == "" || User_Id == undefined || User_Id == null) {
    IsValid = 0;
    if (Type == "Dealer") {
      $("#ddlEntryModelDealer").addClass("is-invalid state-invalid");
    } else if (Type == "Retailer") {
      $("#ddlEntryModelRetailer").addClass("is-invalid state-invalid");
    }
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  $("#btn_Save_Item").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveRoute";
  var Method_Name = "Create_i";
  var Route_Id = $("#lblEntryId").html();

  var Entry_Id = "";

  if (Action_Name == "Edit") {
    Method_Name = "Update_i";
    Entry_Id = $("#lblModelEntryId").html();
  }

  var url = "/Transporter/Route";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    route_id: Route_Id,
    entry_id: Entry_Id,
    createdby_id: User_Id,
    type: Type,
    is_active: 1,
    is_deleted: 0,
  };

  console.log(reqdata);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        // Show Success Message
        $("#modelEntryRoute").modal("hide");
        ShowEntrySuccess(result[0].result_description);
        Show_Success_Toastr(result[0].result_description);
        GetSearchItemList(Route_Id);
      } else {
        GetSearchItemList(Route_Id);
        ShowEntryError("Error : " + result[0].result_description);
        Show_Error_Toastr("Error : " + result[0].result_description);
        $("#btn_Save_Item").prop("disabled", false);
      }
    },
    error: function () {
      ShowEntryError("Error : Route Item details not saved");
      Show_Error_Toastr("Error : Route Item details not saved");
      $("#btn_Save_Item").prop("disabled", false);
    },
  });
}

function ShowItemEditEntry(entry_id, type, createdby_id, createdby_name) {
  $("#modelEntryRoute")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#ddlEntryModelType").select2();
  $("#ddlEntryModelDealer").select2();
  $("#ddlEntryModelRetailer").select2();

  if (type == "Dealer") {
    $("#divEntryModelDealer").show();
    $("#divEntryModelRetailer").hide();
    GetMaster(
      "ddlEntryModelDealer",
      "Select Dealer Name",
      "GetDealer",
      createdby_id,
      ""
    );
  } else if (type == "Retailer") {
    $("#divEntryModelDealer").hide();
    $("#divEntryModelRetailer").show();
    GetMaster(
      "ddlEntryModelRetailer",
      "Select Retailer Name",
      "GetRetailer",
      createdby_id,
      ""
    );
  } else if (type == "" || type == undefined || type == null) {
    $("#divEntryModelDealer").hide();
    $("#divEntryModelRetailer").hide();
  } else {
    $("#divEntryModelDealer").hide();
    $("#divEntryModelRetailer").hide();
  }

  GetMaster("ddlEntryModelType", "Select Type", "GetType", type, "");

  $("#lblModelEntryId").html(entry_id);
  $("#lblModelAction").html("Edit");

  $("#btn_Save_Item").prop("disabled", false);
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
  var Route_Id = $("#lblEntryId").html();

  var APIEndPoint = "SaveRoute";
  var url = "/Transporter/Route";
  var reqdata = {
    route_id: Route_Id,
    is_active: 0,
    is_deleted: 0,
    method_name: "Delete_h",
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
        ShowEntrySuccess("Route details deleted successfully");

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

function ShowItemDeleteEntry(entry_id) {
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
        SaveItemDeleteEntry(entry_id);
      }
    }
  );
}

function SaveItemDeleteEntry(entry_id) {
  // Write code to delete
  var Route_Id = $("#lblEntryId").html();

  var APIEndPoint = "SaveRoute";
  var url = "/Transporter/Route";
  var reqdata = {
    route_id: Route_Id,
    is_active: 0,
    is_deleted: 0,
    method_name: "Delete_i",
    api_end_point: APIEndPoint,
    entry_id: entry_id,
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
        ShowEntrySuccess("Route Item details deleted successfully");

        GetSearchItemList(Route_Id);
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Route Item details not deleted");
    },
  });
}
