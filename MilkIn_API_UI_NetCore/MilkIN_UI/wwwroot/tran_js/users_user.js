$(document).ready(function () {
  $("#ddlSearchUserRole").select2();

  GetMaster("ddlSearchUserRole", "All", "GetUserRole", "", "");

  // SetDataTable("tableSearch", [6], "User");
  ClearInputFieldError();
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");

  // Get data from database and show in table
  var url = "/Users/User";

  var APIEndPoint = "GetUser";
  var Method_Name = "Get";
  var Role_Id = $("#ddlSearchUserRole").val();
  var OfficeUser_Name = $("#txtSearchUserName").val();

  $("#btn_Search").prop("disabled", true);

  var reqdata = {
    method_name: Method_Name,
    officeuser_name: "%" + OfficeUser_Name + "%",
    role_id: "%" + Role_Id + "%",
    api_end_point: APIEndPoint,
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
        TableHTML += "<td>" + value.user_name + "</td>";
        TableHTML += "<td>" + value.employee_id + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.email_id + "</td>";
        TableHTML += "<td>" + value.role_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.user_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [7], "User");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      $("#btn_Search").prop("disabled", false);
    },
  });
  return;
}

function ShowAddEntry() {
  $("#btn_Add").prop("disabled", true);
  ShowContentDiv("Users", "UserAdd", "", function () {
    // Initialization Code
    $("#ddlEntryUserRole").select2();
    $("#divFooterDelete").hide();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    // DisableFutureDates("txtEntryJoiningDate");
    ClearInputFieldError();

    GetMaster("ddlEntryUserRole", "Select User Role", "GetUserRole", "", "");
  });
  $("#btn_Add").prop("disabled", false);
  return;
}

function ShowEditEntry(User_Id) {
  ShowContentDiv("Users", "UserEdit", "", function () {
    // Initialization Code
    $("#ddlEntryUserRole").select2();

    $("#lblEntryId").html(User_Id);
    $("#lblAction").html("Edit");
    $("#btn_Save").prop("disabled", false);

    // DisableFutureDates("txtEntryJoiningDate");
    ClearInputFieldError();

    var APIEndPoint = "GetUser";
    var url = "/Users/User";
    var reqdata = {
      officeuser_id: User_Id,
      method_name: "Get_One",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result); //.responseData);

        $("#txtEntryEmployeeId").val(res[0].employee_id);
        $("#txtEntryUserName").val(res[0].user_name);
        $("#txtEntryJoiningDate").val(res[0].joining_date);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        GetMaster(
          "ddlEntryUserRole",
          "Select User Role",
          "GetUserRole",
          res[0].role_id,
          ""
        );
        $("#txtEntryEmailID").val(res[0].email_id);
        $("#txtEntryPanNo").val(res[0].pan_no);
        $("#txtEntryAadharNo").val(res[0].aadhar_no);

        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }
      },
      error: function () {
        Show_Error_Toastr("Error : User details not found");
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
  var Employee_Id = $("#txtEntryEmployeeId").val().trim();
  var OfficeUser_Name = $("#txtEntryUserName").val().trim();
  var Joining_Date = $("#txtEntryJoiningDate").val();
  var Mobile_No = $("#txtEntryMobileNo").val().trim();
  var Role_Id = $("#ddlEntryUserRole").val();
  var Email_ID = $("#txtEntryEmailID").val().trim();
  var Pan_No = $("#txtEntryPanNo").val().trim();
  var Aadhar_No = $("#txtEntryAadharNo").val().trim();
  var IsValid = 1;

  if (
    Employee_Id == "" ||
    Employee_Id == null ||
    Employee_Id == undefined ||
    Is_AlphaNumeric(Employee_Id) == false
  ) {
    IsValid = 0;
    $("#txtEntryEmployeeId").addClass("is-invalid state-invalid");
  }

  if (
    OfficeUser_Name == "" ||
    OfficeUser_Name == null ||
    OfficeUser_Name == undefined ||
    Is_Valid_Name(OfficeUser_Name) == false
  ) {
    IsValid = 0;
    $("#txtEntryUserName").addClass("is-invalid state-invalid");
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

  if (Role_Id == "" || Role_Id == null || Role_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryUserRole").addClass("is-invalid state-invalid");
  }

  if (Pan_No != "") {
    if (
      Pan_No == null ||
      Pan_No == undefined ||
      Is_Valid_PanNO(Pan_No) == false
    ) {
      IsValid = 0;
      $("#txtEntryPanNo").addClass("is-invalid state-invalid");
    }
  }

  if (Aadhar_No != "") {
    if (
      Aadhar_No == null ||
      Aadhar_No == undefined ||
      Is_Valid_AadharNo(Aadhar_No) == false
    ) {
      IsValid = 0;
      $("#txtEntryAadharNo").addClass("is-invalid state-invalid");
    }
  }

  if (
    Email_ID == "" ||
    Email_ID == null ||
    Email_ID == undefined ||
    Is_Valid_Email(Email_ID) == false
  ) {
    IsValid = 0;
    $("#txtEntryEmailID").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  Show_Loader();
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveUser";
  var Method_Name = "Create";
  var OfficeUser_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    OfficeUser_Id = $("#lblEntryId").html();
  }

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  var url = "/Users/User";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    officeuser_id: OfficeUser_Id,
    employee_id: Employee_Id,
    officeuser_name: OfficeUser_Name,
    joining_date: Joining_Date,
    mobile_no: Mobile_No,
    role_id: Role_Id,
    email_id: Email_ID,
    pan_no: Pan_No,
    aadhar_no: Aadhar_No,
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
        Hide_Loader();
        ShowEntrySuccess("User details saved successfully");
        Show_Success_Toastr("User details saved successfully");
        $("#lblEntryId").html(result[0].result_extra_key);
        // $("#lblAction").html("Edit");

        ShowEditEntry(result[0].result_extra_key);
        $("#divFooterDelete").show();
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : User details not saved");
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
  var User_Id = $("#lblEntryId").html();

  var Is_Deleted = 1;

  var APIEndPoint = "SaveUser";
  var url = "/Users/User";
  var reqdata = {
    officeuser_id: User_Id,
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
        ShowEntrySuccess("User details deleted successfully");

        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : User details not deleted");
    },
  });
}
