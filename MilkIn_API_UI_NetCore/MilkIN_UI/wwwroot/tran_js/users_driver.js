$(document).ready(function () {
  $("#ddlSearchDriverType").select2();

  GetMaster(
    "ddlSearchDriverType",
    "Select Driver Type",
    "GetDriverType",
    "",
    ""
  );

  //SetDataTable("tableSearch", [6], "Driver");
  ClearInputFieldError();
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");

  // Get data from database and show in table
  var url = "/Users/Driver";

  var APIEndPoint = "GetDriver";
  var Method_Name = "Get";
  var DriverType_Id = $("#ddlSearchDriverType").val();
  var Search_Text = $("#txtSearchText").val();

  $("#btn_Search").prop("disabled", true);

  var reqdata = {
    method_name: Method_Name,
    search_text: "%" + Search_Text + "%",
    drivertype_id: "%" + DriverType_Id + "%",
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result); //.responseData);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.driver_code + "</td>";
        TableHTML += "<td>" + value.driver_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.drivertype_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.driver_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Driver");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      $("#btn_Search").prop("disabled", false);
    },
  });
}

function ShowAddEntry() {
  $("#btn_Add").prop("disabled", true);
  ShowContentDiv("Users", "DriverAdd", "", function () {
    // Initialization Code
    $("#ddlEntryDriverType").select2();
    $("#divFooterDelete").hide();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    DisableFutureDates("txtEntryBirthDate");
    // DisableFutureDates("txtEntryJoiningDate");

    ClearInputFieldError();

    GetMaster(
      "ddlEntryDriverType",
      "Select Driver Type",
      "GetDriverType",
      "",
      ""
    );
  });
  $("#btn_Add").prop("disabled", false);
  return;
}

function ShowEditEntry(Driver_Id) {
  ShowContentDiv("Users", "DriverEdit", "", function () {
    // Initialization Code
    $("#ddlEntryDriverType").select2();

    $("#lblEntryId").html(Driver_Id);
    $("#lblAction").html("Edit");

    $("#btn_Save").prop("disabled", false);
    DisableFutureDates("txtEntryBirthDate");
    // DisableFutureDates("txtEntryJoiningDate");

    ClearInputFieldError();

    var APIEndPoint = "GetDriver";
    var url = "/Users/Driver";
    var reqdata = {
      driver_id: Driver_Id,
      method_name: "Get_One",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        $("#txtEntryDriverCode").val(res[0].driver_code);
        $("#txtEntryDriverName").val(res[0].driver_name);
        $("#txtEntryJoiningDate").val(res[0].joining_date);
        $("#txtEntryBirthDate").val(res[0].birth_date);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        GetMaster(
          "ddlEntryDriverType",
          "Select Driver Type",
          "GetDriverType",
          res[0].drivertype_id,
          ""
        );
        $("#txtEntryLicenseNo").val(res[0].drivinglicense_no);
        $("#txtEntryPanNo").val(res[0].pan_no);
        $("#txtEntryAadharNo").val(res[0].aadhar_no);

        if (res[0].is_locked == 1) {
          $("#divFooterDelete").hide();
        } else {
          $("#divFooterDelete").show();
        }

        if (res[0].online_app_flag == "0") {
          document.getElementById("chkOnlineAppFlag").checked = false;
        } else {
          document.getElementById("chkOnlineAppFlag").checked = true;
        }

        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Farmer details not found");
      },
    });
  });
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function SaveEntry() {
  // Validation code
  var Driver_Code = $("#txtEntryDriverCode").val().trim();
  var Driver_Name = $("#txtEntryDriverName").val().trim();
  var Birth_Date = $("#txtEntryBirthDate").val();
  var Mobile_No = $("#txtEntryMobileNo").val().trim();
  var Joining_Date = $("#txtEntryJoiningDate").val();
  var Driver_Type = $("#ddlEntryDriverType").val();
  var License_No = $("#txtEntryLicenseNo").val();
  var Pan_No = $("#txtEntryPanNo").val().trim();
  var Aadhar_No = $("#txtEntryAadharNo").val().trim();
  var IsValid = 1;

  if (
    Driver_Name == "" ||
    Driver_Name == null ||
    Driver_Name == undefined ||
    Is_Valid_Name(Driver_Name) == false
  ) {
    IsValid = 0;
    $("#txtEntryDriverName").addClass("is-invalid state-invalid");
  }

  if (Birth_Date == "" || Birth_Date == null || Birth_Date == undefined) {
    IsValid = 0;
    $("#txtEntryBirthDate").addClass("is-invalid state-invalid");
  }

  if (Joining_Date == "" || Joining_Date == null || Joining_Date == undefined) {
    IsValid = 0;
    $("#txtEntryJoiningDate").addClass("is-invalid state-invalid");
  }

  if (
    Mobile_No == "" ||
    Mobile_No == null ||
    Mobile_No == undefined ||
    Is_Valid_MobileNo(Mobile_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
  }

  if (Driver_Type == "" || Driver_Type == null || Driver_Type == undefined) {
    IsValid = 0;
    $("#ddlEntryDriverType").addClass("is-invalid state-invalid");
  }

  if (
    License_No == "" ||
    License_No == null ||
    License_No == undefined ||
    Is_Valid_Driving_License(License_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryLicenseNo").addClass("is-invalid state-invalid");
  }

  if (
    Pan_No == "" ||
    Pan_No == null ||
    Pan_No == undefined ||
    Is_Valid_PanNO(Pan_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryPanNo").addClass("is-invalid state-invalid");
  }

  if (
    Aadhar_No == "" ||
    Aadhar_No == null ||
    Aadhar_No == undefined ||
    Is_Valid_AadharNo(Aadhar_No) == false
  ) {
    IsValid = 0;
    $("#txtEntryAadharNo").addClass("is-invalid state-invalid");
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
  var Driver_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Driver_Id = $("#lblEntryId").html();
  }

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;
  var OnlineApp_Flag = 0;

  if ($("#chkOnlineAppFlag").prop("checked") == true) {
    OnlineApp_Flag = 1;
  }

  var APIEndPoint = "SaveDriver";
  var url = "/Users/Driver";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    driver_code: Driver_Code,
    driver_id: Driver_Id,
    driver_name: Driver_Name,
    birth_date: Birth_Date,
    mobile_no: Mobile_No,
    joining_date: Joining_Date,
    drivertype_id: Driver_Type,
    license_no: License_No,
    pan_no: Pan_No,
    aadhar_no: Aadhar_No,
    is_active: Is_Active,
    is_deleted: Is_Deleted,
    onlineapp_flag: OnlineApp_Flag,
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
        ShowEntrySuccess("Driver details saved successfully");
        Show_Success_Toastr("Driver details saved successfully");

        $("#lblEntryId").html(result[0].result_extra_key);
        // $("#lblAction").html("Edit");
        // $("#txtEntryDriverCode").val(result[0].result_extra_key);
        // GetSearchList();
        // $("#divFooterDelete").show();
        ShowEditEntry(result[0].result_extra_key);
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Driver details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
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
  var Driver_Id = $("#lblEntryId").html();

  var Is_Deleted = 1;

  var APIEndPoint = "SaveDriver";
  var url = "/Users/Driver";
  var reqdata = {
    driver_id: Driver_Id,
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
        ShowEntrySuccess("Driver details deleted successfully");

        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Driver details not deleted");
    },
  });
}
