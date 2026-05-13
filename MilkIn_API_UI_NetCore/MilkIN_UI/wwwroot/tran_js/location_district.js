$(document).ready(function () {
  $("#ddlSearchStateName").select2();

  GetMaster("ddlSearchStateName", "Select State", "GetState", "", "");

    
  //SetDataTable("tableSearch", [5], "District");
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");

  var url = "/Location/District";
  var State_Id = $("#ddlSearchStateName").val();
  var District_Name = $("#txtSearchDistrictName").val();
  var APIEndPoint = "GetDistrict";
  var reqdata = {
    state_id: "%" + State_Id + "%",
    district_name: "%" + District_Name + "%",
    method_name: "Get",
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
        TableHTML += "<td style = 'width: 20px'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.district_code + "</td>";
        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + value.state_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML += '<td class="text-right" style="width: 40px; padding:8px 5px 8px 5px;">';

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.district_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [5], "District");
      //$("#btn_Search").prop('disabled', false);
    },
    error: function () {
      // $("#btn_Search").prop('disabled', false);
    },
  });
}

function ShowAddEntry() {
  $("#btn_Add").prop("disabled", true);

  ShowContentDiv("Location", "DistrictAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#ddlEntryStateName").select2();
    $("#divFooterActions").hide();

    GetMaster("ddlEntryStateName", "Select State", "GetState", "", "");
  });
  $("#btn_Add").prop("disabled", false);
  return;
}

function ShowEditEntry(District_Id) {
  ShowContentDiv("Location", "DistrictEdit", "", function () {
    // Initialization Code
    $("#lblEntryId").html(District_Id);
    $("#lblAction").html("Edit");
    $("#ddlEntryStateName").select2();
    $("#divFooterActions").show();
    $("#btn_Save").prop("disabled", false);
    GetMaster("ddlEntryStateName", "Select State", "GetState", "383", "");
    var APIEndPoint = "GetDistrict";
    var url = "/Location/District";
    var reqdata = {
      District_Id: District_Id,
      Method_Name: "Get_One",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result); //.responseData);

        document.getElementById("txtEntryDistrictName").value =
          res[0].district_name;
        document.getElementById("txtEntryDistrictCode").value =
          res[0].district_code;

        if (res[0].is_locked == 1) {
          $("#divFooterActions").hide();
        }

        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }

        GetMaster("ddlEntryStateName", "", "GetState", res[0].state_id, "");
      },
      error: function () {
        ShowEntryError("Error : District details not found");
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

  var StateName = $("#ddlEntryStateName").val();
  var DistrictName = $("#txtEntryDistrictName").val().trim();
  var IsValid = 1;

  if (StateName == "" || StateName == null || StateName == undefined) {
    IsValid = 0;
    $("#ddlEntryStateName").addClass("is-invalid state-invalid");
  }

  if (
    DistrictName == "" ||
    DistrictName == null ||
    DistrictName == undefined ||
    Is_Valid_Name(DistrictName) == false
  ) {
    IsValid = 0;
    $("#txtEntryDistrictName").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  Show_Loader();
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveDistrict";
  var Method_Name = "Create";
  var District_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    District_Id = $("#lblEntryId").html();
  }

  var State_Id = $("#ddlEntryStateName").val();
  var District_Name = $("#txtEntryDistrictName").val().trim();
  var District_Code = $("#txtEntryDistrictCode").val().trim();
  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  var url = "/Location/District";
  var reqdata = {
    district_id: District_Id,
    state_id: State_Id,
    district_name: District_Name,
    district_code: District_Code,
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
        ShowEntrySuccess("District details saved successfully");
        Show_Success_Toastr("District details saved successfully");
        $("#lblEntryId").html(result[0].result_extra_key);
        // $("#lblAction").html("Edit");
        // $("#txtEntryDistrictCode").val(result[0].result_extra_key);
        ShowEditEntry(result[0].result_extra_key);

        //GetSearchList();
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      ShowEntryError("Error : District details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
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
  var APIEndPoint = "SaveDistrict";
  var District_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  // In success do following things

  var url = "/Location/District";
  var reqdata = {
    district_id: District_Id,
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
        Show_Success_Toastr("District details deleted successfully");

        //GetSearchList();
        CloseEntry();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : District details not deleted");
    },
  });
}
