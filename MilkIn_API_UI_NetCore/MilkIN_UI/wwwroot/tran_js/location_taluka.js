$(document).ready(function () {
  $("#ddlSearchStateName").select2();
  $("#ddlSearchDistrictName").select2();

  GetMaster("ddlSearchStateName", "Select State", "GetState", "", "");

  //SetDataTable("tableSearch", [6], "Taluka");
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");

  var APIEndPoint = "GetTaluka";
  var url = "/Location/Taluka";
  var State_Id = $("#ddlSearchStateName").val();
  var District_Id = $("#ddlSearchDistrictName").val();
  var Taluka_Name = $("#txtSearchTalukaName").val();

  var reqdata = {
    state_id: "%" + State_Id + "%",
    district_id: "%" + District_Id + "%",
    taluka_name: "%" + Taluka_Name + "%",
    method_name: "Get",
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

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.taluka_code + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.state_name + "</td>";
        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML += '<td class="text-right" style="width: 40px;padding:8px 5px 8px 5px;">';

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.taluka_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Taluka");
      //$("#btn_Search").prop('disabled', false);
    },
    error: function () {
      // $("#btn_Search").prop('disabled', false);
    },
  });
}

function ShowAddEntry() {
  $("#btn_Add").prop("disabled", true);
  ShowContentDiv("Location", "TalukaAdd", "", function () {
    // Initialization Code
    $("#ddlEntryStateName").select2();
    $("#ddlEntryDistrictName").select2();
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divFooterActions").hide();

    GetMaster("ddlEntryStateName", "Select State", "GetState", "", "");
  });
  $("#btn_Add").prop("disabled", false);
  return;
}

function GetSearchDistrict() {
  var State_Id = $("#ddlSearchStateName").val();
  GetMaster(
    "ddlSearchDistrictName",
    "Select District",
    "GetDistrict",
    "",
    State_Id
  );
}

function ShowEditEntry(Taluka_Id) {
  ShowContentDiv("Location", "TalukaEdit", "", function () {
    // Initialization Code
    $("#ddlEntryStateName").select2();
    $("#ddlEntryDistrictName").select2();

    $("#lblEntryId").html(Taluka_Id);
    $("#lblAction").html("Edit");
    $("#divFooterActions").show();
    $("#btn_Save").prop("disabled", false);

    GetMaster("ddlEntryStateName", "Select State", "GetState", "", "");
    var APIEndPoint = "GetTaluka";
    var url = "/Location/Taluka";
    var reqdata = {
      Taluka_Id: Taluka_Id,
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

        document.getElementById("txtEntryTalukaName").value =
          res[0].taluka_name;
        document.getElementById("txtEntryTalukaCode").value =
          res[0].taluka_code;

        if (res[0].is_locked == 1) {
          $("#divFooterActions").hide();
        }

        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }

        GetMaster("ddlEntryStateName", "", "GetState", res[0].state_id, "");
        GetMaster(
          "ddlEntryDistrictName",
          "",
          "GetDistrict",
          res[0].district_id,
          res[0].state_id
        );
      },
      error: function () {
        ShowEntryError("Error : Taluka details not found");
      },
    });
  });
}

function GetDistrict() {
  var StateId = $("#ddlEntryStateName").val();
  GetMaster(
    "ddlEntryDistrictName",
    "Select District",
    "GetDistrict",
    "",
    StateId
  );
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code

  var StateName = $("#ddlEntryStateName").val();
  var DistrictName = $("#ddlEntryDistrictName").val();
  var TalukaName = $("#txtEntryTalukaName").val().trim();
  var IsValid = 1;

  if (StateName == "" || StateName == null || StateName == undefined) {
    IsValid = 0;
    $("#ddlEntryStateName").addClass("is-invalid state-invalid");
  }

  if (DistrictName == "" || DistrictName == null || DistrictName == undefined) {
    IsValid = 0;
    $("#ddlEntryDistrictName").addClass("is-invalid state-invalid");
  }

  if (
    TalukaName == "" ||
    TalukaName == null ||
    TalukaName == undefined ||
    Is_Valid_Name(TalukaName) == false
  ) {
    IsValid = 0;
    $("#txtEntryTalukaName").addClass("is-invalid state-invalid");
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
  var Taluka_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Taluka_Id = $("#lblEntryId").html();
  }

  var State_Id = $("#ddlEntryStateName").val();
  var District_Id = $("#ddlEntryDistrictName").val();
  var Taluka_Name = $("#txtEntryTalukaName").val();
  var Taluka_Code = $("#txtEntryTalukaCode").val();
  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;
  var APIEndPoint = "SaveTaluka";
  var url = "/Location/Taluka";
  var reqdata = {
    taluka_id: Taluka_Id,
    state_id: State_Id,
    district_id: District_Id,
    taluka_name: Taluka_Name,
    taluka_code: Taluka_Code,
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
        ShowEntrySuccess("Taluka details saved successfully");
        Show_Success_Toastr("Taluka details saved successfully");
        $("#lblEntryId").html(result[0].result_extra_key);
        // $("#lblAction").html("Edit");
        // $("#txtEntryTalukaCode").val(result[0].result_extra_key);
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
      ShowEntryError("Error : SNF Slab details not saved");
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
  var Taluka_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;

  var APIEndPoint = "SaveTaluka";
  var url = "/Location/Taluka";
  var reqdata = {
    taluka_id: Taluka_Id,
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
        Show_Success_Toastr("Taluka details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        ShowEntrySuccess("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : Taluka details not deleted");
    },
  });
}
