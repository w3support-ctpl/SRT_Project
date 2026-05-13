var successfulCallbacks = 0;
$(document).ready(function () {
  $("#ddlSearchTripDocumentStatus").select2();
  GetMaster(
    "ddlSearchTripDocumentStatus",
    "Select Trip Document",
    "GetTripDocumentStatus",
    "",
    ""
  );
  // SetDataTable("tableSearchCreated", [9], "Trip");
  //SetDataTable("tableSearchPending", [9], "Trip");

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
  //ClearDataTable("tableSearchPending");
  // Get data from database and show in table
  var SessionRoleId = $("#lblSessionRoleId").html();
  var APIEndPoint = "GetTripDocument";
  var TripStatus_Id = "%" + $("#ddlSearchTripDocumentStatus").val() + "%";
  var Duration = $("#txtSearchDuration").val();
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Collection/TripDocument";
  var reqdata = {
    method_name: Method_Name,
    tripdocumentstatus_id: TripStatus_Id,
    date: Duration,
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
        // return;
      }

      // Fill data in table
      var TableHTML = "";
      //var Row_No = 0;

      var EditFlag = 0; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Status;
        //Row_No = Row_No + 1;
        if (value.is_tripdocument_locked == 0) {
          Status = "Pending";
          EditFlag = value.is_tripdocument_locked;
        } else {
          Status = "Confirmed";
          EditFlag = value.is_tripdocument_locked;
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.tripdocument_id + "</td>";
        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.driver_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.duration + "</td>";
        TableHTML += "<td>" + value.finaldistance + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
            value.tripdocument_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowViewEntry(\'View\',\'' +
            value.tripdocument_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
          if (SessionRoleId == "MU001") {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ShowReverseEntry(\'' +
              value.tripdocument_id +
              "');\">";
            TableHTML += '<i class="fa fa-backward"></i>';
            TableHTML += "</a>";
          }
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      ClearDataTable("tableSearchCreated");
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearchCreated", [9], "Trip Document");
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

function ShowEditEntry(Action, TripDocument_Id) {
  ShowContentDiv("Collection", "TripEdit", "", function () {
    var number = "0";
    var totalCallbacks = 1;
    // $("#divEntryFinalDistance").hide();
    $("#lblEntryId").html(TripDocument_Id);
    $("#lblAction").html(Action);

    var APIEndPoint = "GetTripDocument";
    var Method_Name = "Get_One";
    var url = "/Collection/TripDocument";
    var reqdata = {
      method_name: Method_Name,
      tripdocument_Id: TripDocument_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        $("#txtEntryAmount").val(0);
        if (res[0].freightratetype_id == "C029001") {
          // $("#divEntryFinalDistance").hide();
          $("#txtEntryAmount").val(res[0].rate);
        }
        if (res[0].freightratetype_id == "C029002") {
          // $("#divEntryFinalDistance").show();
          $("#txtEntryAmount").val("");
        }
        if (res[0].freightratetype_id == "C029003") {
          // $("#divEntryFinalDistance").hide();
          var sum = res[0].liters * res[0].rate;
          $("#txtEntryAmount").val(sum.toFixed(2));
          // $("#txtEntryAmount").val(res[0].rate);
        }

        $("#txtEntryTripNo").val(res[0].tripdocument_id);
        $("#txtEntryVehicleNo").val(res[0].vehicle_no);
        $("#txtEntryRouteName").val(res[0].route_name);
        $("#txtEntryDriverName").val(res[0].driver_name);
        $("#txtEntryShift").val(res[0].collectionshift_name);
        $("#txtEntryDuration").val(res[0].duration);
        $("#txtEntryDistanceAsPerDriverApp").val(res[0].disatance_driver);
        $("#txtEntryDistanceAsPerFleetX").val(res[0].disatance_fleetx);
        $("#txtEntryRate").val(res[0].rate);

        $("#txtEntryDieselBaseRate").val(res[0].dieselbaserate);

        $("#txtEntryCurrentDieselRate").val(res[0].currentdieselrate);
        // $("#txtEntryQuantityInWeight").val(res[0].weight);
        $("#txtEntryQuantityInLitres").val(res[0].liters);

        FreightRateType_Id = res[0].freightratetype_id;

        if (Action == "Edit") {
          // enable final distance textbox
          $("#txtEntryFinalDistance").prop("disabled", false);

          if (
            res[0].liters == "" ||
            res[0].liters == null ||
            res[0].liters == undefined
          ) {
            number = "1";
            // $("#btn_Litres").show();
            // $("#btn_Save").hide();
          } else {
            number = "2";
            // $("#btn_Litres").hide();
            // $("#btn_Save").show();
          }

          GetMasterCallback(
            "ddlEntryRateType",
            "Select Freight Rate Type",
            "GetFreightRateType",
            res[0].freightratetype_id,
            "",
            function (success) {
              if (success) {
                successfulCallbacks++;
                checkCallbacks(number, totalCallbacks);
              }
            }
          );

          // show save button
        } else if (Action == "View") {
          $("#txtEntryRateType").val(res[0].freightratetype_name);
          GetMaster(
            "ddlEntryRateType",
            "Select Freight Rate Type",
            "GetFreightRateType",
            res[0].freightratetype_id,
            ""
          );

          // disable final distance textbox
          $("#txtEntryFinalDistance").prop("disabled", true);
          $("#txtEntryFinalDistance").val(res[0].finaldistance);

          // hide save button
          $("#btn_Save").hide();
          $("#btn_Litres").hide();

          // assign amount
          $("#txtEntryAmount").val(res[0].tripamount);
        }
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}
function ShowViewEntry(Action, TripDocument_Id) {
  ShowContentDiv("Collection", "TripEdit", "", function () {
    $("#lblEntryId").html(TripDocument_Id);
    $("#lblAction").html(Action);
    // $("#divEntryFinalDistance").hide();
    var APIEndPoint = "GetTripDocument";
    var Method_Name = "Get_View";
    var url = "/Collection/TripDocument";
    var reqdata = {
      method_name: Method_Name,
      tripdocument_Id: TripDocument_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        if (res[0].freightratetype_id == "C029001") {
          // $("#divEntryFinalDistance").hide();
        }
        if (res[0].freightratetype_id == "C029002") {
          // $("#divEntryFinalDistance").show();
        }
        if (res[0].freightratetype_id == "C029003") {
          // $("#divEntryFinalDistance").hide();
        }

        $("#txtEntryTripNo").val(res[0].tripdocument_id);
        $("#txtEntryVehicleNo").val(res[0].vehicle_no);
        $("#txtEntryRouteName").val(res[0].route_name);
        $("#txtEntryDriverName").val(res[0].driver_name);
        $("#txtEntryShift").val(res[0].collectionshift_name);
        $("#txtEntryDuration").val(res[0].duration);
        $("#txtEntryDistanceAsPerDriverApp").val(res[0].disatance_driver);
        $("#txtEntryDistanceAsPerFleetX").val(res[0].disatance_fleetx);
        $("#txtEntryRate").val(res[0].rate);

        $("#txtEntryDieselBaseRate").val(res[0].dieselbaserate);
        // $("#txtEntryRateType").val(res[0].freightratetype_name);
        GetMaster(
          "ddlEntryRateType",
          "Select Freight Rate Type",
          "GetFreightRateType",
          res[0].freightratetype_id,
          ""
        );
        $("#txtEntryCurrentDieselRate").val(res[0].currentdieselrate);
        // $("#txtEntryQuantityInWeight").val(res[0].weight);
        $("#txtEntryQuantityInLitres").val(res[0].liters);
        // disable final distance textbox
        $("#txtEntryFinalDistance").prop("disabled", true);
        $("#txtEntryFinalDistance").val(res[0].finaldistance);

        $("#txtEntryFleetXId").prop("disabled", true);
        $("#txtEntryFleetXId").val(res[0].fleetx_id);
        $("#btn_View").prop("disabled", true);

        // hide save button
        $("#btn_Save").hide();

        // assign amount

        $("#txtEntryAmount").val(res[0].tripamount);
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
  successfulCallbacks = 0;
}

function SaveEntry() {
  var FinalDistance = $("#txtEntryFinalDistance").val();
  var Rate = $("#txtEntryRate").val();

  var FreightRateType_Id = $("#ddlEntryRateType").val();
  var DieselBaseRate = $("#txtEntryDieselBaseRate").val();
  var CurrentDieselRate = $("#txtEntryCurrentDieselRate").val();
  // var Weight = $("#txtEntryQuantityInWeight").val();
  var Litres = $("#txtEntryQuantityInLitres").val();
  var FleetX_Id = $("#txtEntryFleetXId").val();

  var DistanceAsPerDriverApp = $("#txtEntryDistanceAsPerDriverApp").val();
  var DistanceAsPerFleetX = $("#txtEntryDistanceAsPerFleetX").val();

  var IsValid = 1;
  var Amount = $("#txtEntryAmount").val();
  if (FinalDistance == "") {
    //invalid
    $("#txtEntryFinalDistance").addClass("is-invalid state-invalid");
    return;
  }
  if (
    FreightRateType_Id == "" ||
    FreightRateType_Id == null ||
    FreightRateType_Id == undefined
  ) {
    //invalid
    $("#ddlEntryRateType").addClass("is-invalid state-invalid");
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }
  if (FreightRateType_Id == "C029002" && FinalDistance < 100) {
    //invalid
    $("#txtEntryFinalDistance").addClass("is-invalid state-invalid");
    ShowEntryError("Final distance should not be less than 100 KM");
    return;
  }
  if (FreightRateType_Id == "C029003") {
    //invalid
    if (Litres == "" || Litres == undefined || Litres == null) {
      ShowEntryError("Quantity is not maintained in the milk receipt.");
      return;
    }
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveTripDocument";
    var Method_Name = "Create";
    var TripDocument_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      TripDocument_Id = $("#lblEntryId").html();
    }
    var Is_Active = 1;

    var Is_Deleted = 0;
    var url = "/Collection/TripDocument";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      tripdocument_id: TripDocument_Id,
      rate: Rate,
      finaldistance: FinalDistance,
      freightratetype_id: FreightRateType_Id,
      tripamount: Amount,

      dieselbaserate: DieselBaseRate,
      currentdieselrate: CurrentDieselRate,
      // weight: Weight,
      liters: Litres,
      fleetx_id: FleetX_Id,
      disatance_driver: DistanceAsPerDriverApp,
      disatance_fleetx: DistanceAsPerFleetX,
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
          $("#lblAction").html("View");
          $("#txtEntryFinalDistance").prop("disabled", true);
          $("#btn_Save").hide();
          ShowEntrySuccess("Trip Document details saved successfully");
          ShowViewEntry("View", result[0].result_extra_key);
        } else {
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Trip Document details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  // var Amount = parseInt(FinalDistance) * parseInt(Rate);
}

// $("#txtEntryFinalDistance").on("keyup", function () {
//   // Your onchange code here

//   $("#txtEntryAmount").val(finalDistanceValue + rate);
// });

function GetAmount() {
  var finalDistanceValue = parseFloat($("#txtEntryFinalDistance").val());
  var rate = parseFloat($("#txtEntryRate").val());

  var rateType = $("#ddlEntryRateType").val();

  // if (rateType == "C029001") {
  // } else
  if (rateType == "C029002") {
    if (!isNaN(finalDistanceValue) && !isNaN(rate)) {
      var sum = finalDistanceValue * rate;
      $("#txtEntryAmount").val(sum.toFixed(2)); // Ensures that the result is displayed with 2 decimal places.
    } else {
      $("#txtEntryAmount").val(0); // Handle the case where the input values are not valid numbers.
    }
  }
  // else if (rateType == "C029003") {
  // }
}

/*
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
    var Trip_Id = $("#lblEntryId").html();
    // In success do following things
    Show_Success_Toastr("Trip entry blocked successfully");
    CloseEntry();
    GetSearchList();
}
*/

function GetFleetXDistance() {
  var FleetX_Id = $("#txtEntryFleetXId").val();
  $("#txtEntryDistanceAsPerFleetX").val("");
  //   // console.log(FleetX_Id);
  var IsValid = 1;

  if (FleetX_Id == "" || FleetX_Id == null || FleetX_Id == undefined) {
    IsValid = 0;
    $("#txtEntryFleetXId").addClass("is-invalid state-invalid");
  }
  // }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    var APIEndPoint = "GetFleetXIdData";
    var url = "/Collection/TripDocument";
    var Method_Name = "GetFleetXIdData";
    var reqdata = {
      api_end_point: APIEndPoint,
      fleetx_id: FleetX_Id,
      method_name: Method_Name,
    };

    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          $("#txtEntryDistanceAsPerFleetX").val(result[0].result_description);
        }
        if (result[0].result_id == -1) {
          ShowEntryError("Error : Please Check Your FleetX Id");
        }
      },
      error: function () {
        ShowEntryError("Error : FleetXId Data Not Found");
      },
    });
  }
}

function SaveLitres() {
  var APIEndPoint = "SaveTripDocument";
  var Method_Name = "Update_Liters";
  var TripDocument_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update_Liters";
    TripDocument_Id = $("#lblEntryId").html();
  }
  var Is_Active = 1;

  var Is_Deleted = 0;
  var url = "/Collection/TripDocument";
  var reqdata = {
    is_active: Is_Active,
    is_deleted: Is_Deleted,
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    tripdocument_id: TripDocument_Id,
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
        $("#lblAction").html("Edit");
        ShowEntrySuccess("Litres saved successfully");
        ShowEditEntry("Edit", result[0].result_extra_key);
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Litres not saved");
    },
  });
}

function checkCallbacks(number, totalCallbacks) {
  if (successfulCallbacks === totalCallbacks && number === "1") {
    $("#btn_Litres").show();
    $("#btn_Save").hide();
  } else if (successfulCallbacks === totalCallbacks && number === "2") {
    $("#btn_Litres").hide();
    $("#btn_Save").show();
  }
}

function ShowReverseEntry(TripDocument_Id) {
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
        var APIEndPoint = "SaveTripDocument";
        var url = "/Collection/TripDocument";
        var Is_Active = 1;

        var Is_Deleted = 0;
        var reqdata = {
          is_active: Is_Active,
          is_deleted: Is_Deleted,
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          tripdocument_id: TripDocument_Id,
        };
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (result) {
            Show_Success_Toastr("Reverse Trip Document");
            GetSearchList();
          },
          error: function () {
            Show_Error_Toastr("Error : Trip Document details not Reverse");
          },
        });
      }
    }
  );
}
