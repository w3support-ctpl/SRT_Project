$(document).ready(function () {
  $("#txtSearchPeriod").daterangepicker();

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
  $("#btn_Search").prop("disabled", true);
  var url = "/Rate/FatSNFRatio";
  var Search_Period = $("#txtSearchPeriod").val();
  var Method_Name = "Get";
  var APIEndPoint = "GetFatSNFRatio";
  var reqdata = {
    ratio_date: Search_Period,
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

      var EditFlag = true; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        //Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.ratio_date + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += '<td class="text-right" style="width: 40px;">';

        if (value.is_locked == "0") {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.ratio_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == "1") {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.ratio_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [4], "Fat SNF Ratio");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      $("#btn_Search").prop("disabled", false);
    },
  });
}

// Get data from database and show in table

function ShowAddEntry() {
  ShowContentDiv("Rate", "FatSNFRatioAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divFooterActions").hide();
    //To restrict past date
    SetDate();

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function ShowEditEntry(Ratio_id) {
  ShowContentDiv("Rate", "FatSNFRatioEdit", "", function () {
    // Initialization Code
    $("#lblEntryId").html(Ratio_id);
    $("#lblAction").html("Edit");
    $("#divFooterActions").show();

    SetDate();

    var APIEndPoint = "GetFatSNFRatio";
    var url = "/Rate/FatSNFRatio";
    var Method_Name = "Get_One";
    var reqdata = {
      ratio_Id: Ratio_id,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result);

        if (res[0].is_locked == "1") {
          $("#divFooterActions").hide();
          $("#txtEntryDate").prop("disabled", "true");
          $("#txtEntryFatSNFRatioFat").prop("disabled", "true");
          $("#txtEntryFatSNFRatioSNF").prop("disabled", "true");
          $("#txtEntryOverheadAmount").prop("disabled", "true");
        }
        if (res[0].is_active == "0") {
          $("#divFooterActions").show();
          $("#txtEntryDate").prop("disabled", "true");
          $("#txtEntryFatSNFRatioFat").prop("disabled", "false");
          $("#txtEntryFatSNFRatioSNF").prop("disabled", "false");
          $("#txtEntryOverheadAmount").prop("disabled", "false");
        }
        $("#txtEntryDate").val(res[0].ratio_date);
        $("#txtEntryFatSNFRatioSNF").val(res[0].snf);
        $("#txtEntryFatSNFRatioFat").val(res[0].fat);
        $("#txtEntryOverheadAmount").val(res[0].overhead);
        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }
      },
      error: function () {
        ShowEntryError("Error : Fat SNF Ratio details not found");
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
  var RatioDate = $("#txtEntryDate").val();
  var SNF = $("#txtEntryFatSNFRatioSNF").val().trim();
  var Fat = $("#txtEntryFatSNFRatioFat").val().trim();
  var OverheadAmount = $("#txtEntryOverheadAmount").val().trim();
  var IsValid = 1;

  if (RatioDate == "" || RatioDate == null || RatioDate == undefined) {
    IsValid = 0;
    $("#txtEntryDate").addClass("is-invalid state-invalid");
  }

  if (
    SNF == "" ||
    SNF == null ||
    SNF == undefined ||
    Is_Positive_Number_Greater_Than_Zero(SNF) == false ||
    Is_Valid_Float(SNF) == false
  ) {
    IsValid = 0;
    $("#txtEntryFatSNFRatioSNF").addClass("is-invalid state-invalid");
  }

  if (
    Fat == "" ||
    Fat == null ||
    Fat == undefined ||
    Is_Positive_Number_Greater_Than_Zero(Fat) == false ||
    Is_Valid_Float(Fat) == false
  ) {
    IsValid = 0;
    $("#txtEntryFatSNFRatioFat").addClass("is-invalid state-invalid");
  }

  if (
    OverheadAmount == "" ||
    OverheadAmount == null ||
    OverheadAmount == undefined ||
    Is_Positive_Number_Greater_Than_Zero(OverheadAmount) == false ||
    Is_Valid_Float(OverheadAmount) == false
  ) {
    IsValid = 0;
    $("#txtEntryOverheadAmount").addClass("is-invalid state-invalid");
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
  var APIEndPoint = "SaveFatSNFRatio";
  var Ratio_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Ratio_Id = $("#lblEntryId").html();
  }
  var Is_Active = 0;
  if ($("#chkEntryStatus").prop("checked")) {
    Is_Active = 1;
  }
  var Is_Deleted = 0;

  var url = "/Rate/FatSNFRatio";
  var reqdata = {
    ratio_id: Ratio_Id,
    ratio_date: RatioDate,
    snf: SNF,
    fat: Fat,
    is_active: Is_Active,
    is_deleted: Is_Deleted,
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    overhead: OverheadAmount,
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
        ShowEntrySuccess("Fat SNF Ratio details saved successfully!");
        $("#lblEntryId").html(result[0].result_extra_key);
        $("#lblAction").html("Edit");
        $("#divFooterActions").show();
        // CloseEntry();
        ShowEditEntry(result[0].result_extra_key)
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      ShowEntryError("Error : Fat SNF Ratio details not saved");
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
  var Ratio_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveFatSNFRatio";
  var url = "/Rate/FatSNFRatio";
  var reqdata = {
    ratio_id: Ratio_Id,
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
        ShowEntrySuccess("Fat SNF Ratio details deleted successfully");

        CloseEntry();
        //GetSearchList();
      } else {
        ShowEntryError("Error : " + result[0].result_Description);
      }
    },
    error: function () {
      ShowEntryError("Error : Fat SNF Ratio details not deleted");
    },
  });
}

function CalculateSNF() {
  if ($("#txtEntryFatSNFRatioFat").val() == "") {
    var Fat = 0;
  } else {
    var Fat = parseFloat($("#txtEntryFatSNFRatioFat").val());
  }
  var SNF = 100.0 - Fat;
  $("#txtEntryFatSNFRatioSNF").val(SNF.toPrecision(4));
  return;
}

// function checkAndCalculateSNF(input) {
//   var inputValue = parseFloat(input.value);

//   if (isNaN(inputValue)) {
//       // Handle non-numeric input
//       $("#txtEntryFatSNFRatioFat").addClass("is-invalid state-invalid");
//       return;
//   }

//   if (inputValue <= 100) {
//       // Continue with the calculation or any other action
//       CalculateSNF();
//   } else {
//       // Stop typing if value exceeds 100
//       input.value = input.value.slice(0, -1);
//   }
// }
function checkAndCalculateSNF(input) {
  $("#txtEntryFatSNFRatioFat").removeClass("is-invalid state-invalid");
  $("#txtEntryFatSNFRatioSNF").removeClass("is-invalid state-invalid");

  var inputValue = input.value.trim(); // Trim whitespaces

  // Check if the input is a valid positive number
  if (
    /^\d*\.?\d+$/.test(inputValue) &&
    parseFloat(inputValue) >= 0 &&
    inputValue <= 100
  ) {
    $("#txtEntryFatSNFRatioFat").removeClass("is-invalid state-invalid");
    CalculateSNF();
  } else {
    // Add invalid class and prevent further typing
    // $("#txtEntryFatSNFRatioFat").addClass("is-invalid state-invalid");
    input.value = inputValue.slice(0, -1);
    CalculateSNF();
  }
}

function SetDate() {
  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/FatSNFRatio";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetFatSNFRatio";
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
      // latest_date = res[0].ratio_date;
      // var date = new Date().toISOString().slice(0, 10);
      // if (latest_date > date) {
      //   date = latest_date;
      // }
      var date;
      if (res.length === 0) {
        date = new Date().toISOString().slice(0, 10);
      } else {
        latest_date = res[0].ratio_date;
        date = new Date().toISOString().slice(0, 10);
        if (latest_date > date) {
          date = latest_date;
        }
      }
      /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

      // next_date = new Date(date);
      // newdate = next_date.toISOString().slice(0, 10);

      // $("#txtEntryDate").attr("min", newdate);
      // $("#txtEntryDate").val(newdate);
      // var offset = date.getTimezoneOffset();
      // date.setMinutes(date.getMinutes() - offset);
      // var newdate = date.toISOString().slice(0, 16);

      $("#txtEntryDate").attr("min", date);
      $("#txtEntryDate").val(date);
    },
    error: function () {},
  });
}

function ClearInvalidStateFATSNF(e) {
  $("#" + e.id).removeClass("is-invalid state-invalid");

  $("#txtEntryFatSNFRatioSNF").removeClass("is-invalid state-invalid");
}
