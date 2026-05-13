$(document).ready(function () {
  $("#ddlSearchStateName").select2();
  $("#ddlSearchDistrictName").select2();
  $("#ddlSearchTalukaName").select2();

  GetMaster("ddlSearchStateName", "Select State Name", "GetState", "", "");
  GetMaster(
    "ddlSearchDistrictName",
    "Select District Name",
    "GetDistrict",
    "",
    ""
  );

  //SetDataTable("tableSearch", [7], "Village");
});

function GetSearchDistrict() {
  $("#ddlSearchTalukaName")
    .empty()
    .append($("<option></option>").val("").html("Select Taluka"));
  var State_Id = $("#ddlSearchStateName").val();
  GetMaster(
    "ddlSearchDistrictName",
    "Select District Name",
    "GetDistrict",
    "",
    State_Id
  );
}

function GetSearchTaluka() {
  var District_Id = $("#ddlSearchDistrictName").val();
  GetMaster(
    "ddlSearchTalukaName",
    "Select Taluka Name",
    "GetTaluka",
    "",
    District_Id
  );
}

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var APIEndPoint = "GetVillage";
  var url = "/Location/Village";
  var State_Id = $("#ddlSearchStateName").val();
  var District_Id = $("#ddlSearchDistrictName").val();
  var Taluka_Id = $("#ddlSearchTalukaName").val();

  var IsValid = 1;
  if (State_Id == "") {
    IsValid = 0;
    $("#ddlSearchStateName").addClass("is-invalid state-invalid");
  }

  if (District_Id == "") {
    IsValid = 0;
    $("#ddlSearchDistrictName").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't search.");
    return;
  }

  var reqdata = {
    state_id: "%" + State_Id + "%",
    district_id: "%" + District_Id + "%",
    taluka_id: "%" + Taluka_Id + "%",
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
      // show message if there is no data to show
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
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.state_name + "</td>";
        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML += '<td class="text-right" style="width: 40px; padding:8px 5px 8px 5px;">';

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.village_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Village");
      //$("#btn_Search").prop('disabled', false);
    },
    error: function () {
      // $("#btn_Search").prop('disabled', false);
    },
  });
}

function ShowAddEntry() {
  $("#btn_Add").prop("disabled", true);
  ShowContentDiv("Location", "VillageAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#ddlEntryStateName").select2();
    $("#ddlEntryDistrictName").select2();
    $("#ddlEntryTalukaName").select2();
    $("#divFooterActions").hide();

    GetMaster("ddlEntryStateName", "Select State", "GetState", "", "");
  });
  $("#btn_Add").prop("disabled", false);
  return;
}

function GetDistrict() {
  $("#ddlEntryTalukaName")
    .empty()
    .append($("<option></option>").val("").html("Select Taluka"));
  var StateId = $("#ddlEntryStateName").val();
  GetMaster(
    "ddlEntryDistrictName",
    "Select District",
    "GetDistrict",
    "",
    StateId
  );
}

function GetTaluka() {
  var DistrictId = $("#ddlEntryDistrictName").val();
  GetMaster("ddlEntryTalukaName", "Select Taluka", "GetTaluka", "", DistrictId);
}

function ShowEditEntry(Village_Id) {
  ShowContentDiv("Location", "VillageEdit", "", function () {
    // Initialization Code

    $("#lblEntryId").html(Village_Id);
    $("#lblAction").html("Edit");
    $("#ddlEntryStateName").select2();
    $("#ddlEntryDistrictName").select2();
    $("#ddlEntryTalukaName").select2();
    $("#btn_Save").prop("disabled", false);

    GetMaster("ddlEntryStateName", "Select State", "GetState", "", "");
    GetMaster("ddlEntryDistrictName", "Select State", "GetDistrict", "", "");
    var APIEndPoint = "GetVillage";
    var url = "/Location/Village";
    var reqdata = {
      Village_Id: Village_Id,
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
        document.getElementById("txtEntryVillageName").value =
          res[0].village_name;
        document.getElementById("txtEntryPinCode").value = res[0].pin_code;

        if (res[0].is_locked == 1) {
          $("#divFooterActions").hide();
        }

        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }

        GetMaster(
          "ddlEntryStateName",
          "Select State Name",
          "GetState",
          res[0].state_id,
          ""
        );
        GetMaster(
          "ddlEntryDistrictName",
          "Select District Name",
          "GetDistrict",
          res[0].district_id,
          res[0].state_id
        );
        GetMaster(
          "ddlEntryTalukaName",
          "Select Taluka Name",
          "GetTaluka",
          res[0].taluka_id,
          res[0].district_id
        );
      },
      error: function () {
        ShowEntryError("Error : Village details not found");
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
  var DistrictName = $("#ddlEntryDistrictName").val();
  var TalukaName = $("#ddlEntryTalukaName").val();
  var VillageName = $("#txtEntryVillageName").val().trim();
  var PinCode = $("#txtEntryPinCode").val().trim();
  var IsValid = 1;

  if (StateName == "" || StateName == null || StateName == undefined) {
    IsValid = 0;
    $("#ddlEntryStateName").addClass("is-invalid state-invalid");
  }

  if (DistrictName == "" || DistrictName == null || DistrictName == undefined) {
    IsValid = 0;
    $("#ddlEntryDistrictName").addClass("is-invalid state-invalid");
  }

  if (TalukaName == "" || TalukaName == null || TalukaName == undefined) {
    IsValid = 0;
    $("#ddlEntryTalukaName").addClass("is-invalid state-invalid");
  }

  if (
    VillageName == "" ||
    VillageName == null ||
    VillageName == undefined ||
    Is_Valid_Name(VillageName) == false
  ) {
    IsValid = 0;
    $("#txtEntryVillageName").addClass("is-invalid state-invalid");
  }

  if (
    PinCode == "" ||
    PinCode == null ||
    PinCode == undefined ||
    Is_Valid_PinCode(PinCode) == false
  ) {
    IsValid = 0;
    $("#txtEntryPinCode").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  Show_Loader();
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveVillage";
  var Method_Name = "Create";
  var Village_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Village_Id = $("#lblEntryId").html();
  }

  var State_Id = $("#ddlEntryStateName").val();
  var District_Id = $("#ddlEntryDistrictName").val();
  var Taluka_Id = $("#ddlEntryTalukaName").val();
  var Village_Name = $("#txtEntryVillageName").val();
  var Pin_Code = $("#txtEntryPinCode").val();
  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  var url = "/Location/Village";
  var reqdata = {
    village_id: Village_Id,
    state_id: State_Id,
    district_id: District_Id,
    taluka_id: Taluka_Id,
    village_name: Village_Name,
    pin_code: Pin_Code,
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
        ShowEntrySuccess("Village details saved successfully");
        Show_Success_Toastr("Village details saved successfully");
        $("#lblEntryId").html(result[0].result_extra_key);
        // $("#lblAction").html("Edit");
        // $("#txtEntryVillageCode").val(result[0].result_extra_key);
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
      ShowEntryError("Error : Village details not saved");
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
  // Write code to save
  var Village_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  var APIEndPoint = "SaveVillage";
  var url = "/Location/Village";
  var reqdata = {
    village_id: Village_Id,
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
        Show_Success_Toastr("Village details deleted successfully");

        CloseEntry();
        //GetSearchList();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : Village details not deleted");
    },
  });
}
