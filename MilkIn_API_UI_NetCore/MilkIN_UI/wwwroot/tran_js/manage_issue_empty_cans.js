$(document).ready(function () {
  $("#ddlSearchTruck").select2();

  GetMaster("ddlSearchTruck", "Select Truck", "GetTruckVehicle", "", "");
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

function GetSearchList() {
  ClearDataTable("tableSearch");
  var APIEndPoint = "GetIssueEmptyCans";
  var Method_Name = "GetCans";
  var url = "/Manage/IssueEmptyCans";
  var Search_Truck_Id = "%" + $("#ddlSearchTruck").val() + "%";
  var Search_Date = $("#txtSearchDeliveryPeriod").val();

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_id: Search_Truck_Id,
    issuestocks_date: Search_Date,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var EditFlag = 1;
      var TableHTML = "";

      $.each(res, function (data, value) {
        EditFlag = value.is_driveraccepted;
        var Active_Status;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.vehicle_number + "</td>";
        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        //TableHTML += "<td>" + value.mcc_name + "</td>";
        //TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML += "<td class='text-right'>";
        // EditFlag = value.is_locked;
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick=\'ShowEditEntry("Edit", "' +
            value.issuestocks_id +
            '","' +
            value.issuedate +
            '","' +
            value.route_id +
            '","' +
            value.collectionshift_id +
            '","' +
            value.collectionshift_name +
            '","' +
            value.vehicle_id +
            '","' +
            value.vehicle_no +
            "\")'>";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick=\'ShowEditEntry("View", "' +
            value.issuestocks_id +
            '","' +
            value.issuedate +
            '","' +
            value.route_id +
            '","' +
            value.collectionshift_id +
            '","' +
            value.collectionshift_name +
            '","' +
            value.vehicle_id +
            '","' +
            value.vehicle_no +
            "\")'>";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [5], "Issue Empty Cans");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching Issue Empty Cans details.");
    },
  });
  //$("#btn_Search").prop('disabled', false);
}

function ShowAddEntry() {
  ShowContentDiv("Manage", "IssueEmptyCansAdd", "", function () {
    // Initialization Code

    $("#divFooterActions").hide();
    $("#divissueemptycans").hide();

    $("#txtEntryDate").val(new Date().toDateInputValue());
    $("#ddlEntryVehicleNo").select2();
    $("#ddlEntryShift").select2();
    $("#ddlEntryRoute").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $('[data-toggle="popover"]').popover();

    //enable all input fields
    $("#ddlEntryRoute").prop("disabled", false);
    $("#ddlEntryVehicleNo").prop("disabled", false);
    $("#ddlEntryShift").prop("disabled", false);
    //$("#txtEntryShift").prop("disabled", true);
    //$("#txtEntryVehicleNo").prop("disabled", true);

    GetMaster("ddlEntryVehicleNo", "Select Truck", "GetVehicle", "", "");
    GetMaster(
      "ddlEntryShift",
      "Select Shift",
      "GetMilkCollectionShift",
      "",
      ""
    );
    GetMaster(
      "ddlEntryRoute",
      "Select Route",
      "GetIssueEmptyCansRoute",
      "",
      ""
    );
  });
}

function ShowEditEntry(
  Action,
  IssueEmptyCan_Id,
  IssueDate,
  Route_Id,
  CollectionShift_Id,
  CollectionShift_Name,
  Vehicle_Id,
  Vehicle_No
) {
  ShowContentDiv("Manage", "IssueEmptyCansEdit", "", function () {
    // Initialization Code
    $("#ddlEntryVehicleNo").select2();
    $("#ddlEntryShift").select2();
    $("#ddlEntryRoute").select2();

    $("#lblEntryId").html(IssueEmptyCan_Id);
    $("#lblAction").html("Edit");

    $("#divissueemptycans").show();

    $('[data-toggle="popover"]').popover();

    // Assisng values to input fields
    $("#txtEntryDate").val(IssueDate);
    GetMaster(
      "ddlEntryRoute",
      "Select Route",
      "GetIssueEmptyCansRoute",
      Route_Id,
      ""
    );
    GetMaster(
      "ddlEntryVehicleNo",
      "Select Truck",
      "GetVehicle",
      Vehicle_Id,
      ""
    );
    GetMaster(
      "ddlEntryShift",
      "Select Shift",
      "GetMilkCollectionShift",
      CollectionShift_Id,
      ""
    );

    $("#txtEntryShift").val(CollectionShift_Name);
    $("#txtEntryVehicleNo").val(Vehicle_No);

    //disable all input fields
    $("#ddlEntryRoute").prop("disabled", true);
    $("#ddlEntryVehicleNo").prop("disabled", true);
    $("#ddlEntryShift").prop("disabled", true);
    //$("#txtEntryShift").prop("disabled", true);
    //$("#txtEntryVehicleNo").prop("disabled", true);

    var APIEndPoint = "GetIssueEmptyCans";
    var Method_Name = "Get_One";
    var disabled = "";
    $("#btn_Save").prop("hidden", false);
    $("#divFooterDelete").prop("hidden", false);
    if (Action == "View") {
      disabled = "disabled";
      $("#btn_Save").prop("hidden", true);
      $("#divFooterDelete").prop("hidden", true);
    }
    var url = "/Manage/IssueEmptyCans";
    var reqdata = {
      method_name: Method_Name,
      issuestocks_id: IssueEmptyCan_Id,
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
        ClearDataTable("tableEntryIssueEmptyCans");
        var TableHTML = "";
        RowNo = 0;

        // console.log(res);
        $.each(res, function (data, value) {
          /*if ((data == 0) || ((data) % 4) == 0) {*/
          // console.log(data);
          RowNo += 1;
          TableHTML += "<tr>";
          TableHTML += "<td style = 'width: 20px'>" + RowNo + "</td>";
          TableHTML += "<td hidden>" + value.mcc_id + "</td>";
          TableHTML += "<td>" + value.mcc_name + "</td>";
          /*  }*/

          TableHTML += "<td>" + '<div class="form-group">';
          TableHTML += "<span hidden>" + value.material_id + "</span>";
          TableHTML +=
            '<input type="number" id="txtmaterial' +
            data +
            '" class="form-control" ';
          TableHTML +=
            'maxlength="30" autocomplete="off" value="' + value.quantity + '" ';
          TableHTML += disabled + " >";
          TableHTML += "</div></td>";

          TableHTML += "<td hidden></td>";
          TableHTML += "<td hidden></td>";
          TableHTML += "<td hidden></td>";

          //if (((data + 1) % 4) == 0) {
          TableHTML += "<td hidden></td>";
          TableHTML += "</tr>";

          $("#tableDataIssueEmptyCans").append(TableHTML);
          // console.log("sss");
          TableHTML = "";
          //}
          CalculateTotalCans(data);
        });
        SetDataTable("tableEntryIssueEmptyCans", [5], "Issue Empty Cans");
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

// Calculate total number of cans to be issued to each MCC
function CalculateTotalCans(RowNo) {
  var TotalCans = 0;
  TotalCans += parseInt($("#txtplasticcanswithlid" + RowNo).val());
  TotalCans += parseInt($("#txtplasticcanswithoutlid" + RowNo).val());
  TotalCans += parseInt($("#txtaluminiumcanswithlid" + RowNo).val());
  TotalCans += parseInt($("#txtaluminiumcanswithoutlid" + RowNo).val());
  $("#txttotalcans" + RowNo).val(TotalCans);
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function SaveEntry() {
  // Validation code
  var IssueDate = $("#txtEntryDate").val();
  var Route_Id = $("#ddlEntryRoute").val();
  var CollectionShift_Id = $("#ddlEntryShift").val();
  var Vehicle_Id = $("#ddlEntryVehicleNo").val();
  var CollectionShift_Name = $("#txtEntryShift").val();
  var Vehicle_No = $("#txtEntryVehicleNo").val();

  var IsValid = 1;

  if (IssueDate == "") {
    IsValid = 0;
    $("#txtEntryDate").addClass("is-invalid state-invalid");
  }
  if (Route_Id == "") {
    IsValid = 0;
    $("#ddlEntryRoute").addClass("is-invalid state-invalid");
  }
  if (CollectionShift_Id == "") {
    IsValid = 0;
    $("#ddlEntryShift").addClass("is-invalid state-invalid");
  }
  if (Vehicle_Id == "") {
    IsValid = 0;
    $("#ddlEntryVehicleNo").addClass("is-invalid state-invalid");
  }
  if (CollectionShift_Name == "") {
    IsValid = 0;
    $("#txtEntryShift").addClass("is-invalid state-invalid");
  }
  if (Vehicle_No == "") {
    IsValid = 0;
    $("#txtEntryVehicleNo").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveIssueEmptyCans";
    var Method_Name = "Create";
    var IssueEmptyCan_Id = "";
    var Action_Name = $("#lblAction").html();
    var xmlData = "";
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      IssueEmptyCan_Id = $("#lblEntryId").html();

      // Getting Table values and converting it to XML

      xmlData += "<D>";

      $("#tableEntryIssueEmptyCans tbody tr").each(function () {
        xmlData +=
          "<R><ProfileId>" + $(this).find("td:eq(1)").text() + "</ProfileId>";
        xmlData +=
          "<MaterialId>" +
          $(this).find("td:eq(3) span").text() +
          "</MaterialId>";
        xmlData += "<MCC>" + $(this).find("td:eq(1)").text() + "</MCC>";
        xmlData += "<ProfileType>MCC</ProfileType>";
        xmlData +=
          "<MaterialQty>" +
          $(this).find("td:eq(3) input").val() +
          "</MaterialQty></R>";

        // xmlData +=
        //   "<R><ProfileId>" + $(this).find("td:eq(1)").text() + "</ProfileId>";
        // xmlData +=
        //   "<MaterialId>" +
        //   $(this).find("td:eq(4) span").text() +
        //   "</MaterialId>";
        // xmlData += "<MCC>" + $(this).find("td:eq(1)").text() + "</MCC>";
        // xmlData += "<ProfileType>MCC</ProfileType>";
        // xmlData +=
        //   "<MaterialQty>" +
        //   $(this).find("td:eq(4) input").val() +
        //   "</MaterialQty></R>";

        // xmlData +=
        //   "<R><ProfileId>" + $(this).find("td:eq(1)").text() + "</ProfileId>";
        // xmlData +=
        //   "<MaterialId>" +
        //   $(this).find("td:eq(5) span").text() +
        //   "</MaterialId>";
        // xmlData += "<MCC>" + $(this).find("td:eq(1)").text() + "</MCC>";
        // xmlData += "<ProfileType>MCC</ProfileType>";
        // xmlData +=
        //   "<MaterialQty>" +
        //   $(this).find("td:eq(5) input").val() +
        //   "</MaterialQty></R>";

        // xmlData +=
        //   "<R><ProfileId>" + $(this).find("td:eq(1)").text() + "</ProfileId>";
        // xmlData +=
        //   "<MaterialId>" +
        //   $(this).find("td:eq(6) span").text() +
        //   "</MaterialId>";
        // xmlData += "<MCC>" + $(this).find("td:eq(1)").text() + "</MCC>";
        // xmlData += "<ProfileType>MCC</ProfileType>";
        // xmlData +=
        //   "<MaterialQty>" +
        //   $(this).find("td:eq(6) input").val() +
        //   "</MaterialQty></R>";
      });
      xmlData += "</D>";
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Manage/IssueEmptyCans";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      issuestocks_id: IssueEmptyCan_Id,
      route_id: Route_Id,
      collectionshift_id: CollectionShift_Id,
      vehicle_id: Vehicle_Id,
      issuestocks_date: IssueDate,
      xmldata: xmlData,
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
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          ShowEntrySuccess("Issue Empty Cans saved successfully");
          ShowEditEntry(
            "Edit",
            result[0].result_extra_key,
            IssueDate,
            Route_Id,
            CollectionShift_Id,
            CollectionShift_Name,
            Vehicle_Id,
            Vehicle_No
          );
        } else {
          ShowEntryError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Issue Empty Cans details not saved");
      },
    });
    $("#btn_Save").prop("disabled", false);
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
  var IssueEmptyCan_Id = $("#lblEntryId").html();

  var APIEndPoint = "SaveIssueEmptyCans";
  var url = "/Manage/IssueEmptyCans";
  var reqdata = {
    method_name: "Delete",
    api_end_point: APIEndPoint,
    issuestocks_id: IssueEmptyCan_Id,
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
        Show_Success_Toastr("Issue Empty Cans details deleted successfully");
        CloseEntry();
      } else {
        ShowEntrySuccess("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : Issue Empty Cans details not deleted");
    },
  });
}

function SetShift() {
  var Route_Id = $("#ddlEntryRoute").val();
  $("#ddlEntryShift")
    .empty()
    .append($("<option></option>").val("").html("Select Shift"));
  var APIEndPoint = "GetIssueEmptyCans";
  var url = "/Manage/IssueEmptyCans";
  var reqdata = {
    method_name: "Get_CollectionShift",
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
      $("#txtEntryShift").val(result[0].collectionshift_name);

      $.each(result, function (data, value) {
        $("#ddlEntryShift").append(
          $("<option></option>")
            .val(value.collectionshift_id)
            .html(value.collectionshift_name)
        );
      });
      $("#ddlEntryShift").val(result[0].collectionshift_id);
      SetVehicle(result[0].collectionshift_id);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching data");
    },
  });
}
function SetVehicle(CollectionShift_Id) {
  var Route_Id = $("#ddlEntryRoute").val();
  //var CollectionShift_Id = $("#ddlEntryShift").val();
  $("#ddlEntryVehicleNo")
    .empty()
    .append($("<option></option>").val("").html("Select Vehicle No"));
  var APIEndPoint = "GetIssueEmptyCans";
  var url = "/Manage/IssueEmptyCans";
  var reqdata = {
    method_name: "Get_Vehicle",
    route_id: Route_Id,
    collectionshift_id: CollectionShift_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      $("#txtEntryVehicleNo").val(result[0].vehicle_no);
      $.each(result, function (data, value) {
        $("#ddlEntryVehicleNo").append(
          $("<option></option>").val(value.vehicle_id).html(value.vehicle_no)
        );
      });

      // Default Value
      $("#ddlEntryVehicleNo").val(result[0].vehicle_id);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching data");
    },
  });
}

Date.prototype.toDateInputValue = function () {
  var local = new Date(this);
  local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
  return local.toJSON().slice(0, 10);
};
