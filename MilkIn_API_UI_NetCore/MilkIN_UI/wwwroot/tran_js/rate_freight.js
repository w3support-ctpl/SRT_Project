$(document).ready(function () {
  $("#ddlSearchVehicleNo").select2();
  $("#ddlEntryRateType").select2();
  GetMaster("ddlSearchVehicleNo", "Select Vehicle No", "GetVehicle", "", "");
  //SetDataTable("tableSearch", [5], "Freight");

  // show/hide Amount Text box
  $("#ddlEntryRateType").on("change", function () {
    if ($("#ddlEntryRateType").find(":selected").val() == "") {
      $("#divEntryAmount").hide();
      $("#divEntryBaseRate").hide();
      $("#divMessage").hide();
    } else if ($("#ddlEntryRateType").find(":selected").val() != "C029001") {
      $("#divEntryAmount").show();
      $("#divEntryBaseRate").show();
      $("#divMessage").hide();
    } else {
      $("#divEntryAmount").hide();
      $("#divEntryBaseRate").show();
      $("#divMessage").show();
    }
  });
});

function GetSearchList() {
  if ($("#ddlSearchVehicleNo").val() == "") {
    $("#ddlSearchVehicleNo").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Please select Vehicle No");
    return;
  }
  var Vehicle_Id = $("#ddlSearchVehicleNo").val();
  $("#btn_Search").prop("disabled", true);
  var APIEndPoint = "GetFreight";
  var Method_Name = "Get";
  var url = "/Rate/Freight";
  var reqdata = {
    method_name: Method_Name,
    vehicle_id: Vehicle_Id,
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
      var EditFlag = 0; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 0;
      $.each(res, function (data, value) {
        EditFlag = DeleteFlag = value.is_locked;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.freightratetype_name + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.baserate + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
        if (value.is_locked == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\'' +
            value.freight_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        } else {
          if (EditFlag == 0) {
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
              value.freight_id +
              "')\">";
            TableHTML += '<i class="fa fa-pencil"></i>';
            TableHTML += "</a>";
          }

          if (DeleteFlag == 0) {
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntry(\'' +
              value.freight_id +
              "')\">";
            TableHTML += '<i class="fa fa-trash"></i>';
            TableHTML += "</a>";
          }
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableSearch");
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [5], "Freight");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  $("#btn_Search").prop("disabled", false);
  return;
}

// Assign values to input fields in the Modal to Edit them
function ShowEditEntry(action, Freight_Id) {
  // Initialization Code

  $("#lblEntryId").html(Freight_Id);
  $("#lblAction").html(action);

  var APIEndPoint = "GetFreight";
  var Method_Name = "Get_One";
  var url = "/Rate/Freight";
  var reqdata = {
    method_name: Method_Name,
    freight_id: Freight_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      GetMaster(
        "ddlEntryRateType",
        "Select Freight Rate Type",
        "GetFreightRateType",
        res[0].freightratetype_id,
        ""
      );
      $("#txtEntryAmount").val(res[0].amount);
      $("#txtEntryApplicableFrom").val(res[0].applicable_date);
      $("#txtEntryBaseRate").val(res[0].baserate);
      $("#lblVersion").html(res[0].version_no);

      if (res[0].freightratetype_id == "C029001") {
        $("#divEntryAmount").hide();
        $("#divEntryBaseRate").hide();
        $("#divMessage").show();
      } else {
        $("#divEntryAmount").show();
        $("#divEntryBaseRate").show();
        $("#divMessage").hide();
      }

      OpenModal(action);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var Vehicle_Id = $("#ddlSearchVehicleNo").val();
  var RateType_Id = $("#ddlEntryRateType").val();
  var Amount = $("#txtEntryAmount").val();
  var Applicable_Date = $("#txtEntryApplicableFrom").val();
  var BaseRate = $("#txtEntryBaseRate").val();
  var IsValid = 1;

  if (RateType_Id == "" || RateType_Id == null || RateType_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryRateType").addClass("is-invalid state-invalid");
  }
  if (RateType_Id != "C029001" && Amount == "") {
    if (
      Amount == null ||
      Amount == undefined ||
      Is_Positive_Number_Greater_Than_Zero(Amount) == false ||
      Is_Valid_Float(Amount) == false
    ) {
      IsValid = 0;
      $("#txtEntryAmount").addClass("is-invalid state-invalid");
    }
  }
  if (
    Applicable_Date == "" ||
    Applicable_Date == null ||
    Applicable_Date == undefined
  ) {
    IsValid = 0;
    $("#txtEntryApplicableFrom").addClass("is-invalid state-invalid");
  }
  // if (RateType_Id != "C029001" && BaseRate == "") {
  if (
    BaseRate == "" ||
    BaseRate == null ||
    BaseRate == undefined ||
    Is_Positive_Number_Greater_Than_Zero(BaseRate) == false ||
    Is_Valid_Float(BaseRate) == false
  ) {
    IsValid = 0;
    $("#txtEntryBaseRate").addClass("is-invalid state-invalid");
  }
  // }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btnSave").prop("disabled", true);
    var APIEndPoint = "SaveFreight";
    var Method_Name = "Create";
    var Freight_Id = 0;
    var Action_Name = $("#lblAction").html();
    var Version_No = 0;
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Freight_Id = $("#lblEntryId").html();
      Version_No = $("#lblVersion").html();
    }
    var url = "/Rate/Freight";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      freight_id: Freight_Id,
      vehicle_id: Vehicle_Id,
      freightratetype_id: RateType_Id,
      amount: Amount,
      applicable_date: Applicable_Date,
      baserate: BaseRate,
      version_no: Version_No,
      is_active: 1,
      is_deleted: 0,
    };

    //Save Freight Details
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          Show_Success_Toastr("Freight details saved successfully");
          GetSearchList();
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : Freight details not saved");
      },
    });
  }
  $("#modelEntryFreight").modal("hide");
  $("#btnSave").prop("disabled", false);
}

function ShowDeleteEntry(Freight_Id) {
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
        SaveDeleteEntry(Freight_Id);
      }
    }
  );
}

function SaveDeleteEntry(Freight_Id) {
  // Write code to delete
  var APIEndPoint = "SaveFreight";
  var url = "/Rate/Freight";
  var reqdata = {
    freight_id: Freight_Id,
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
        Show_Success_Toastr("Freight details deleted successfully");
        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Freight details not deleted");
    },
  });
}

function OpenModal(action) {
  if ($("#ddlSearchVehicleNo").val() == "") {
    $("#ddlSearchVehicleNo").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Please select Vehicle No");
    return;
  }

  // hiding message box
  $("#divMessage").hide();

  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/Freight";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetFreight";
  Vehicle_Id = $("#ddlSearchVehicleNo").val();

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    vehicle_id: Vehicle_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // var latest_date = new Date(res[0].applicable_date);
      // var date = new Date(Date.now()); //.toISOString().slice(0, 16);

      // if (latest_date > date) {
      //   date = latest_date;
      // }

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
      /*
             next_date = new Date(date);
             newdate1 = next_date.toISOString();
             newdate = newdate1.slice(0, 16);
             */

      // var offset = date.getTimezoneOffset();
      // date.setMinutes(date.getMinutes() - offset);
      // var newdate = date.toISOString().slice(0, 16);

      // $("#txtEntryApplicableFrom").attr("min", newdate);
      // $("#txtEntryApplicableFrom").val(newdate);

      var offset = date.getTimezoneOffset();
      date.setMinutes(date.getMinutes() - offset);
      var newdate = date.toISOString().slice(0, 16);

      $("#txtEntryApplicableFrom").attr("min", newdate);
      $("#txtEntryApplicableFrom").val(newdate);
    },
    error: function () {},
  });

  $("#txtEntryAmount").prop("disabled", false);
  $("#txtEntryApplicableFrom").prop("disabled", false);
  $("#txtEntryBaseRate").prop("disabled", false);
  $("#ddlEntryRateType").prop("disabled", false);

  $("#modelEntryFreight")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblActionFreight").html(action);
  if (action == "Add") {
    $("#lblEntryId").html("");
    $("#AddEditFreight").text("Add Entry");
    GetMaster(
      "ddlEntryRateType",
      "Select Freight Rate Type",
      "GetFreightRateType",
      "",
      ""
    );
  } else if (action == "Edit") {
    $("#AddEditFreight").text("Edit Entry");
  } else if (action == "View") {
    $("#txtEntryAmount").prop("disabled", true);
    $("#txtEntryApplicableFrom").prop("disabled", true);
    $("#txtEntryBaseRate").prop("disabled", true);
    $("#ddlEntryRateType").prop("disabled", true);
  }
}

$("#modelEntryFreight").on("hidden.bs.modal", function (e) {
  $("#lblEntryId").html("");
  $("#lblAction").html("");
  $("#AddEditFreight").text("");
  $("#txtEntryAmount").val("");
  $("#txtEntryApplicableFrom").val("");
  $("#txtEntryBaseRate").val("");
  $("#ddlEntryRateType").val("");
  $("#divEntryAmount").hide();
  $("#divEntryBaseRate").hide();
  $("#divMessage").hide();
  GetSearchList();
});
