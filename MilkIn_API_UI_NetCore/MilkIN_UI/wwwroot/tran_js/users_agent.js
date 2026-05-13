$(document).ready(function () {
  //SetDataTable("tableSearch", [6], "Agent");
  ClearInputFieldError();
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");

  // Get data from database and show in table
  var url = "/Users/Agent";

  var APIEndPoint = "GetAgent";
  var Method_Name = "Get";
  var Search_Text = $("#txtSearchText").val();

  $("#btn_Search").prop("disabled", true);

  var reqdata = {
    method_name: Method_Name,
    search_text: "%" + Search_Text + "%",
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
        TableHTML += "<td>" + value.agent_code + "</td>";
        TableHTML += "<td>" + value.agent_name + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.joining_date + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.agent_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Agent");
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
  ShowContentDiv("Users", "AgentAdd", "", function () {
    // Initialization Code
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();
    $("#divFooterDelete").hide();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    DisableFutureDates("txtEntryBirthDate");
    // DisableFutureDates("txtEntryJoiningDate");
    ClearInputFieldError();

    GetMaster("ddlEntryState", "Select State", "GetState", "", "");
  });
  $("#btn_Add").prop("disabled", false);
  return;
}

function GetDistrict() {
  //Empty All Childeren/Dependent DDLs
  $("#ddlEntryTaluka")
    .empty()
    .append($("<option></option>").val("").html("Select Taluka"));
  $("#ddlEntryVillage")
    .empty()
    .append($("<option></option>").val("").html("Select Village"));

  var State_Id = $("#ddlEntryState").val();
  GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", "", State_Id);
}

function GetTaluka() {
  // Empty All Children/Dependent DDls
  $("#ddlEntryVillage")
    .empty()
    .append($("<option></option>").val("").html("Select Village"));

  var District_Id = $("#ddlEntryDistrict").val();
  GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", "", District_Id);
}

function GetVillage() {
  var Taluka_Id = $("#ddlEntryTaluka").val();
  GetMaster("ddlEntryVillage", "Select Village", "GetVillage", "", Taluka_Id);
}

function ShowEditEntry(Agent_Id) {
  ShowContentDiv("Users", "AgentEdit", "", function () {
    // Initialization Code
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntryVillage").select2();

    $("#lblEntryId").html(Agent_Id);
    $("#lblAction").html("Edit");
    $("#btn_Save").prop("disabled", false);
    DisableFutureDates("txtEntryBirthDate");
    // DisableFutureDates("txtEntryJoiningDate");

    ClearInputFieldError();

    var APIEndPoint = "GetAgent";
    var url = "/Users/Agent";
    var reqdata = {
      agent_id: Agent_Id,
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

        $("#txtEntryAgentCode").val(res[0].agent_code);
        $("#txtEntryAgentName").val(res[0].agent_name);
        $("#txtEntryBirthDate").val(res[0].birth_date);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        $("#txtEntryJoiningDate").val(res[0].joining_date);
        $("#txtEntryPanNo").val(res[0].pan_no);
        $("#txtEntryAadharNo").val(res[0].aadhar_no);
        $("#txtEntryEmailID").val(res[0].email_id);
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

        GetMaster(
          "ddlEntryState",
          "Select State",
          "GetState",
          res[0].state_id,
          ""
        );
        GetMaster(
          "ddlEntryDistrict",
          "Select District",
          "GetDistrict",
          res[0].district_id,
          res[0].state_id
        );
        GetMaster(
          "ddlEntryTaluka",
          "Select Taluka",
          "GetTaluka",
          res[0].taluka_id,
          res[0].district_id
        );
        GetMaster(
          "ddlEntryVillage",
          "Select Village",
          "GetVillage",
          res[0].village_id,
          res[0].taluka_id
        );
        $("#txtEntryAddress").val(res[0].address_text);

        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Agent details not found");
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
  var Agent_Code = $("#txtEntryAgentCode").val().trim();
  var Agent_Name = $("#txtEntryAgentName").val().trim().trim();
  var Birth_Date = $("#txtEntryBirthDate").val();
  var Mobile_No = $("#txtEntryMobileNo").val().trim();
  var Email_Id = $("#txtEntryEmailID").val().trim();
  var Joining_Date = $("#txtEntryJoiningDate").val();
  var Pan_No = $("#txtEntryPanNo").val().trim();
  var Aadhar_No = $("#txtEntryAadharNo").val().trim();
  var State_Id = $("#ddlEntryState").val();
  var District_Id = $("#ddlEntryDistrict").val();
  var Taluka_Id = $("#ddlEntryTaluka").val();
  var Village_Id = $("#ddlEntryVillage").val();
  var Address_Text = $("#txtEntryAddress").val().trim();
  var IsValid = 1;

  if (
    Agent_Name == "" ||
    Agent_Name == null ||
    Agent_Name == undefined ||
    Is_Valid_Name(Agent_Name) == false
  ) {
    IsValid = 0;
    $("#txtEntryAgentName").addClass("is-invalid state-invalid");
  }

  if (Birth_Date == "" || Birth_Date == null || Birth_Date == undefined) {
    IsValid = 0;
    $("#txtEntryBirthDate").addClass("is-invalid state-invalid");
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

  if (Email_Id != "") {
    if (
      Email_Id == null ||
      Email_Id == undefined ||
      Is_Valid_Email(Email_Id) == false
    ) {
      IsValid = 0;
      $("#txtEntryEmailID").addClass("is-invalid state-invalid");
    }
  }

  if (Joining_Date == "" || Joining_Date == null || Joining_Date == undefined) {
    IsValid = 0;
    $("#txtEntryJoiningDate").addClass("is-invalid state-invalid");
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

  if (State_Id == "" || State_Id == null || State_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryState").addClass("is-invalid state-invalid");
  }

  if (District_Id == "" || District_Id == null || District_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryDistrict").addClass("is-invalid state-invalid");
  }

  if (Taluka_Id == "" || Taluka_Id == null || Taluka_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryTaluka").addClass("is-invalid state-invalid");
  }

  if (Taluka_Id == "" || Taluka_Id == null || Taluka_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryVillage").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }
  Show_Loader();
  // Start Saving
  $("#btn_Save").prop("disabled", true);

  // Save
  var Method_Name = "Create";
  var Agent_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Agent_Id = $("#lblEntryId").html();
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

  var APIEndPoint = "SaveAgent";
  var url = "/Users/Agent";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    agent_code: Agent_Code,
    agent_id: Agent_Id,
    agent_name: Agent_Name,
    birth_date: Birth_Date,
    mobile_no: Mobile_No,
    email_id: Email_Id,
    joining_date: Joining_Date,
    pan_no: Pan_No,
    aadhar_no: Aadhar_No,
    state_id: State_Id,
    district_id: District_Id,
    taluka_id: Taluka_Id,
    village_id: Village_Id,
    address_text: Address_Text,
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
        Hide_Loader();
        // Show Success Message
        ShowEntrySuccess("Agent details saved successfully");
        Show_Success_Toastr("Agent details saved successfully");
        $("#lblEntryId").html(result[0].result_extra_key);

        ShowEditEntry(result[0].result_extra_key);
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Agent details not saved");
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
  var Agent_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;

  var APIEndPoint = "SaveAgent";
  var url = "/Users/Agent";
  var reqdata = {
    agent_id: Agent_Id,
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
        ShowEntrySuccess("Agent details deleted successfully");

        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Agent details not deleted");
    },
  });
}
