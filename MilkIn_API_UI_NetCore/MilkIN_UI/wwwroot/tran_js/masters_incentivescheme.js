$(document).ready(function () {
  $("#ddlSearchIncentiveType").select2();
  GetMaster(
    "ddlSearchIncentiveType",
    "Select Incentive Type",
    "GetIncentiveType",
    "",
    ""
  );

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

  // Get data from database and show in table

  // Validate Data
  var APIEndPoint = "GetIncentiveScheme";
  var IncentiveType_Id = "%" + $("#ddlSearchIncentiveType").val() + "%";
  var Duration = $("#txtSearchDuration").val();
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Masters/IncentiveScheme";
  var reqdata = {
    method_name: Method_Name,
    incentivetype_id: IncentiveType_Id,
    duration: Duration,
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
        TableHTML += "<td>" + value.scheme_name + "</td>";
        TableHTML += "<td>" + value.incentivetype_name + "</td>";
        TableHTML += "<td>" + value.from_date + "</td>";
        TableHTML += "<td>" + value.to_date + "</td>";
        TableHTML += "<td>" + value.incentivefrequency_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.incentivescheme_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="AssignMCC" onclick="ShowAssignEntry(\'' +
            value.incentivescheme_id +
            "')\">";
          TableHTML += '<i class="fa fa-sitemap"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [7], "Incentive Scheme");
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
  ShowContentDiv("Masters", "IncentiveSchemeAdd", "", function () {
    // Initialization Code
    $("#divTabsMCCView").hide();
    $("#ddlEntryIncentiveType").select2();
    $("#ddlEntryFrequency").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divFooterDelete").hide();
    //$('#txtEntryDuration').val('')

    GetMaster(
      "ddlEntryIncentiveType",
      "Select Incentive Type",
      "GetIncentiveType",
      "",
      ""
    );
    GetMaster("ddlEntryFrequency", "Select Frequency", "GetFrequency", "", "");

    SetCriteriaLabel("");
  });
}

function ShowEditEntry(IncentiveScheme_Id) {
  ShowContentDiv("Masters", "IncentiveSchemeEdit", "", function () {
    // Initialization Code
    $("#divTabsMCCView").hide();
    $("#ddlEntryIncentiveType").select2();
    $("#ddlEntryFrequency").select2();

    $("#lblEntryId").html(IncentiveScheme_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();

    var APIEndPoint = "GetIncentiveScheme";
    var Method_Name = "Get_One";
    var url = "/Masters/IncentiveScheme";
    var reqdata = {
      method_name: Method_Name,
      incentivescheme_id: IncentiveScheme_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        $("#btn_Save").show();

        // $("#ddlEntryIncentiveType").prop("disabled", "false");
        // $("#ddlEntryFrequency").prop("disabled", "false");
        // $("#txtEntrySchemeName").prop("disabled", "false");
        // $("#txtEntryApplicableFrom").prop("disabled", "false");
        // $("#txtEntryApplicableTo").prop("disabled", "false");
        // $("#txtEntryCriteria").prop("disabled", "false");
        // $("#txtEntryDescription").prop("disabled", "false");

        $("#divForFarmer").show();
        $("#divForAgent").show();

        $("#divOtherDetails").show();
        $("#divOtherDetailsRow").show();

        $("#divFooterDelete").show();

        GetMaster(
          "ddlEntryIncentiveType",
          "Select Incentive Type",
          "GetIncentiveType",
          res[0].incentivetype_id,
          ""
        );
        GetMaster(
          "ddlEntryFrequency",
          "Select Frequency",
          "GetFrequency",
          res[0].incentivefrequency_id,
          ""
        );

        $("#txtEntrySchemeName").val(res[0].scheme_name);
        $("#txtEntryApplicableFrom").val(res[0].from_date);
        $("#txtEntryApplicableTo").val(res[0].to_date);
        $("#txtEntryCriteria").val(res[0].criteria);
        $("#txtEntryDescription").val(res[0].scheme_description);
        SetCriteriaLabel(res[0].incentivetype_id);
        if (res[0].is_for_farmer == 1) {
          $("#chkForFarmer").prop("checked", true);
        } else {
          $("#chkForFarmer").prop("checked", false);
        }
        if (res[0].is_for_agent == 1) {
          $("#chkForAgent").prop("checked", true);
        } else {
          $("#chkForAgent").prop("checked", false);
        }
        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
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
  var SchemeName = $("#txtEntrySchemeName").val().trim();
  var IncentiveType_Id = $("#ddlEntryIncentiveType").val();
  var ApplicableFrom = $("#txtEntryApplicableFrom").val();
  var ApplicableTo = $("#txtEntryApplicableTo").val();
  var Frequency_id = $("#ddlEntryFrequency").val();
  var Criteria = $("#txtEntryCriteria").val().trim();
  var Description = $("#txtEntryDescription").val().trim();
  var ForFarmer = 0;
  if ($("#chkForFarmer").prop("checked")) {
    ForFarmer = 1;
  }
  var ForAgent = 0;
  if ($("#chkForAgent").prop("checked")) {
    ForAgent = 1;
  }

  var IsValid = 1;

  if (
    SchemeName == "" ||
    SchemeName == null ||
    SchemeName == undefined ||
    Is_Valid_Name(SchemeName) == false
  ) {
    IsValid = 0;
    $("#txtEntrySchemeName").addClass("is-invalid state-invalid");
  }
  if (
    IncentiveType_Id == "" ||
    IncentiveType_Id == null ||
    IncentiveType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryIncentiveType").addClass("is-invalid state-invalid");
  }
  if (
    Criteria == "" ||
    Criteria == null ||
    Criteria == undefined ||
    // Is_Valid_NumberCheck(Criteria) == false ||
    Is_Valid_Float(Criteria) == false
  ) {
    IsValid = 0;
    $("#txtEntryCriteria").addClass("is-invalid state-invalid");
  }
  if (
    ApplicableFrom == "" ||
    ApplicableFrom == null ||
    ApplicableFrom == undefined
  ) {
    IsValid = 0;
    $("#txtEntryApplicableFrom").addClass("is-invalid state-invalid");
  }
  if (ApplicableTo == "" || ApplicableTo == null || ApplicableTo == undefined) {
    IsValid = 0;
    $("#txtEntryApplicableTo").addClass("is-invalid state-invalid");
  }
  if (Frequency_id == "" || Frequency_id == null || Frequency_id == undefined) {
    IsValid = 0;
    $("#ddlEntryFrequency").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);

    var APIEndPoint = "SaveIncentiveScheme";
    var Method_Name = "Create";
    var IncentiveScheme_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      IncentiveScheme_Id = $("#lblEntryId").html();
    }
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Masters/IncentiveScheme";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      incentivescheme_id: IncentiveScheme_Id,

      scheme_name: SchemeName,
      incentivetype_id: IncentiveType_Id,
      from_date: ApplicableFrom,
      to_date: ApplicableTo,
      incentivefrequency_id: Frequency_id,
      criteria: Criteria,

      scheme_description: Description,
      is_for_farmer: ForFarmer,
      is_for_agent: ForAgent,
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
          Hide_Loader();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          ShowEntrySuccess("Incentive Scheme details saved successfully");
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : Incentive Scheme details not saved");
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
  var APIEndPoint = "SaveIncentiveScheme";
  var IncentiveScheme_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  var Method_Name = "Delete";
  // In success do following things
  var url = "/Masters/IncentiveScheme";
  var reqdata = {
    incentivescheme_id: IncentiveScheme_Id,
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
        Show_Success_Toastr("Incentive Scheme details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Incentive Scheme details not deleted");
    },
  });
}

function SetCriteriaLabel(IncentiveType_Id) {
  if (IncentiveType_Id == "") {
    IncentiveType_Id = $("#ddlEntryIncentiveType").val();
  }
  if (IncentiveType_Id == "") {
    $("#lblEntryCriteria").html("Criteria <span class='text-red'>*</span>");
  }
  //Quantity
  else if (IncentiveType_Id == "C025002") {
    $("#lblEntryCriteria").html(
      "Criteria In Liters <span class='text-red'>*</span>"
    );
  }
  // Quality
  else {
    $("#lblEntryCriteria").html("Criteria TS <span class='text-red'>*</span>");
  }
}

function ShowAssignEntry(IncentiveScheme_Id) {
  ShowContentDiv("Masters", "IncentiveSchemeEdit", "", function () {
    // Initialization Code
    $("#divTabsMCCView").show();
    $("#ddlEntryIncentiveType").select2();
    $("#ddlEntryFrequency").select2();

    $("#lblEntryId").html(IncentiveScheme_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();
    GetSearchMCCList();
    var APIEndPoint = "GetIncentiveScheme";
    var Method_Name = "Get_One";
    var url = "/Masters/IncentiveScheme";
    var reqdata = {
      method_name: Method_Name,
      incentivescheme_id: IncentiveScheme_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        $("#btn_Save").hide();

        $("#ddlEntryIncentiveType").prop("disabled", "true");
        $("#ddlEntryFrequency").prop("disabled", "true");
        $("#txtEntrySchemeName").prop("disabled", "true");
        $("#txtEntryApplicableFrom").prop("disabled", "true");
        $("#txtEntryApplicableTo").prop("disabled", "true");
        $("#txtEntryCriteria").prop("disabled", "true");
        $("#txtEntryDescription").prop("disabled", "true");
        $("#chkEntryStatus").prop("disabled", "true");
        $("#divForFarmer").hide();
        $("#divForAgent").hide();

        $("#divOtherDetails").hide();
        $("#divOtherDetailsRow").hide();
        $("#divFooterDelete").hide();

        GetMaster(
          "ddlEntryIncentiveType",
          "Select Incentive Type",
          "GetIncentiveType",
          res[0].incentivetype_id,
          ""
        );
        GetMaster(
          "ddlEntryFrequency",
          "Select Frequency",
          "GetFrequency",
          res[0].incentivefrequency_id,
          ""
        );

        $("#txtEntrySchemeName").val(res[0].scheme_name);
        $("#txtEntryApplicableFrom").val(res[0].from_date);
        $("#txtEntryApplicableTo").val(res[0].to_date);
        $("#txtEntryCriteria").val(res[0].criteria);
        $("#txtEntryDescription").val(res[0].scheme_description);
        SetCriteriaLabel(res[0].incentivetype_id);
        if (res[0].is_for_farmer == 1) {
          $("#chkForFarmer").prop("checked", true);
        } else {
          $("#chkForFarmer").prop("checked", false);
        }
        if (res[0].is_for_agent == 1) {
          $("#chkForAgent").prop("checked", true);
        } else {
          $("#chkForAgent").prop("checked", false);
        }
        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }

        
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

function OpenModalAssignMCC() {
  $("#modelEntryMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#ddlEntryMCCName").select2();
  $("#btn_Save_Item").prop("disabled", false);

  GetMaster("ddlEntryMCCName", "Select MCC Name", "GetMCC", "", "");
}

function GetSearchMCCList() {
  ClearDataTable("tableAssignMCCEntryList");

  // Get data from database and show in table
  var url = "/Masters/IncentiveScheme";

  var APIEndPoint = "GetIncentiveSchemeMCC";
  var Method_Name = "Get";
  var IncentiveScheme_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    incentivescheme_id: IncentiveScheme_Id,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result); //.responseData);
      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;

      $.each(res, function (data, value) {
        var Active_Status;
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";

        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowDeleteEntry(\'' +
          value.entry_id +
          "')\">";
        TableHTML += '<i class="fa fa-trash"></i>';
        TableHTML += "</a>";
        TableHTML += "<td hidden></td>";

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntryAssignMCC").html(TableHTML);
      SetDataTable("tableAssignMCCEntryList", [4], "Incentive Scheme");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}

function SaveMCCItemEntry() {
  var MCC_Id = $("#ddlEntryMCCName").val();

  if (MCC_Id == "" || MCC_Id == null || MCC_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMCCName").addClass("is-invalid state-invalid");
  } else {
    Show_Loader();
    $("#btn_Save_Item").prop("disabled", true);
    var url = "/Masters/IncentiveScheme";

    var APIEndPoint = "SaveIncentiveSchemeMCC";
    var Method_Name = "Create";
    var IncentiveScheme_Id = $("#lblEntryId").html();
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      incentivescheme_id: IncentiveScheme_Id,
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
          // Show Success Message
          GetSearchMCCList();
          Hide_Loader();
          $("#modelEntryMCC").modal("hide");
          ShowEntrySuccess("Incentive Scheme MCC saved successfully");
        } else {
          Hide_Loader();
          $("#modelEntryMCC").modal("hide");
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save_Item").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        $("#modelEntryMCC").modal("hide");
        ShowEntryError("Error : Incentive Scheme MCC not saved");
        $("#btn_Save_Item").prop("disabled", false);
      },
    });
  }
  return;
}

function ShowDeleteEntry(Entry_id) {
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
        var url = "/Masters/IncentiveScheme";

        var APIEndPoint = "SaveIncentiveSchemeMCC";
        var Method_Name = "Delete";
        var IncentiveScheme_Id = $("#lblEntryId").html();
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          incentivescheme_id: IncentiveScheme_Id,
          entry_id: Entry_id,
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
              GetSearchMCCList();
              ShowEntrySuccess("Incentive Scheme MCC delete successfully");
            } else {
              ShowEntryError("Error : " + result[0].result_description);
            }
          },
          error: function () {
            ShowEntryError("Error : Incentive Scheme MCC not delete");
          },
        });
      }
    }
  );
}
