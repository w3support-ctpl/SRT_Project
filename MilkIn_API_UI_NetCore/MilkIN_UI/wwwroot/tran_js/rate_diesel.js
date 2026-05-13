$(document).ready(function () {
  //SetDataTable("tableSearch", [3], "Diesel");
  // $("#txtSearchPeriod").daterangepicker();
  //SetDateRangePicker("txtSearchPeriod");

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
  ClearDataTable("tableSearch");

  var url = "/Rate/Diesel";
  var Search_Period = $("#txtSearchPeriod").val();
  var Method_Name = "Get";
  var APIEndPoint = "GetDiesel";
  var reqdata = {
    date: Search_Period,
    method_name: Method_Name,
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
        EditFlag = value.is_locked;
        var Active_Status;
        //Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.dieselrate_date + "</td>";
        TableHTML += "<td>" + value.dieselrate + "</td>";
        TableHTML += '<td class="text-right" style="width: 40px;">';

        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick=\'ShowEditEntry("' +
            value.dieselrate_id +
            '", "Edit")\'>';
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (EditFlag == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick=\'ShowEditEntry("' +
            value.dieselrate_id +
            '", "View")\'>';
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [3], "Diesel");
      //$("#btn_Search").prop('disabled', false);
    },
    error: function () {
      // $("#btn_Search").prop('disabled', false);
    },
  });
}

// Get data from database and show in table

function ShowAddEntry() {
  ShowContentDiv("Rate", "DieselAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divFooterActions").hide();
    SetDate();

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function ShowEditEntry(dieselrate_id, Action) {
  ShowContentDiv("Rate", "DieselEdit", "", function () {
    $("#lblEntryId").html(dieselrate_id);

    if (Action == "View") {
      $("#lblAction").html("View");
      $("#divFooterActions").hide();
      $("#btn_Save").prop("hidden", true);

      //$("#txtEntryDate").prop("disabled", true);
      $("#txtEntryDieselRate").prop("disabled", true);
      $("#chkEntryStatus").prop("disabled", true);
    } else {
      $("#lblAction").html("Edit");
      $("#divFooterActions").show();
      $("#btn_Save").prop("hidden", false);

      //$("#txtEntryDate").prop("disabled", false);
      $("#txtEntryDieselRate").prop("disabled", false);

      $("#chkEntryStatus").prop("disabled", false);
    }

    SetDate();
    $("#txtEntryDate").prop("disabled", true);

    var APIEndPoint = "GetDiesel";
    var url = "/Rate/Diesel";
    var Method_Name = "Get_One";
    var reqdata = {
      DieselRate_Id: dieselrate_id,
      Method_Name: Method_Name,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result);
        $("#txtEntryDate").val(res[0].dieselrate_date);
        $("#txtEntryDieselRate").val(res[0].dieselrate);
        $("#chkEntryStatus").prop("checked", res[0].is_active);
        /*
                if (res[0].is_active == "0") {
                    $("#chkEntryStatus").prop("checked",false);
                } else {
                    $("#chkEntryStatus").prop("checked", true);
                }*/
      },
      error: function () {
        ShowEntryError("Error : Diesel details not found");
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
  var DieselRate_Date = $("#txtEntryDate").val();
  var DieselRate = $("#txtEntryDieselRate").val();
  var IsValid = 1;

  if (
    DieselRate_Date == "" ||
    DieselRate_Date == null ||
    DieselRate_Date == undefined
  ) {
    IsValid = 0;
    $("#txtEntryDate").addClass("is-invalid state-invalid");
  }

  if (
    DieselRate == "" ||
    DieselRate == null ||
    DieselRate == undefined ||
    Is_Positive_Number_Greater_Than_Zero(DieselRate) == false ||
    Is_Valid_Float(DieselRate) == false
  ) {
    IsValid = 0;
    $("#txtEntryDieselRate").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  Show_Loader();
  $("#btn_Save").prop("disabled", true);

  // Save
  var Method_Name = "Create";
  var APIEndPoint = "SaveDiesel";
  var DieselRate_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    DieselRate_Id = $("#lblEntryId").html();
  }
  var DieselRate_Date = $("#txtEntryDate").val();
  var DieselRate = $("#txtEntryDieselRate").val();
  var Is_Active = 0;
  if ($("#chkEntryStatus").prop("checked")) {
    Is_Active = 1;
  }
  var Is_Deleted = 0;

  var url = "/Rate/Diesel";
  var reqdata = {
    dieselrate_id: DieselRate_Id,
    dieselrate_date: DieselRate_Date,
    dieselrate: DieselRate,
    is_active: Is_Active,
    is_deleted: Is_Deleted,
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
      if (result[0].result_id == 1) {
        // Show Success Message
        Hide_Loader();
        ShowEntrySuccess("Diesel details saved successfully!");
        $("#lblEntryId").html(result[0].result_extra_key);
        // $("#lblAction").html("Edit");
        // $("#divFooterActions").show();
        ShowEditEntry(result[0].result_extra_key, "Edit");
        //GetSearchList();
        CloseEntry();
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      ShowEntryError("Error : Diesel details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
}

function ShowDeleteEntry() {
  // Initialization Code
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
  var DieselRate_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  var APIEndPoint = "SaveDiesel";
  var url = "/Rate/Diesel";
  var reqdata = {
    dieselrate_id: DieselRate_Id,
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
        ShowEntrySuccess("Diesel details deleted successfully");

        CloseEntry();
        //GetSearchList();
      } else {
        ShowEntryError("Error : " + result[0].result_Description);
      }
    },
    error: function () {
      ShowEntryError("Error : Diesel details not deleted");
    },
  });
}

function SetDate() {
  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/Diesel";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetDiesel";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // latest_date = res[0].dieselrate_date;
      // var date = new Date().toISOString().slice(0, 10);
      // if (latest_date > date) {
      //   date = latest_date;
      // }

      var date;
      if (res.length === 0) {
        date = new Date().toISOString().slice(0, 10);
      } else {
        latest_date = res[0].dieselrate_date;
        var date = new Date().toISOString().slice(0, 10);
        if (latest_date > date) {
          date = latest_date;
        }
      }

      $("#txtEntryDate").attr("min", date);
      $("#txtEntryDate").val(date);
    },
    error: function () {},
  });
}
