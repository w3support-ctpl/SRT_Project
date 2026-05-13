$(document).ready(function () {});

function GetSearchList(e) {
  $("#btn_Search").prop("disabled", true);
  ClearDataTable("tableSearch");
  var url = "/Rate/Slab";
  var FatSlab_Name = $("#txtSearchFatSlabName").val();
  var APIEndPoint = "GetSlab";
  var reqdata = {
    slab_name: "%" + FatSlab_Name + "%",
    method_name: "Get",
    slab_type: "fat",
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
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.slab_name + "</td>";
        TableHTML += "<td>" + value.slab_min + "</td>";
        TableHTML += "<td>" + value.slab_max + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML += '<td class="text-right" style="width: 40px;">';

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.slab_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [5], "Fat Slab");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      $("#btn_Search").prop("disabled", false);
    },
  });
}

function ShowAddEntry() {
  ShowContentDiv("Rate", "FatSlabAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divFooterActions").hide();
  });
}

function ShowEditEntry(FatSlab_Id) {
  ShowContentDiv("Rate", "FatSlabEdit", "", function () {
    // Initialization Code
    $("#lblEntryId").html(FatSlab_Id);
    $("#lblAction").html("Edit");

    var APIEndPoint = "GetSlab";
    var url = "/Rate/Slab";
    var reqdata = {
      slab_id: FatSlab_Id,
      method_name: "Get_One",
      slab_type: "fat",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result);

        $("#txtEntryFatSlabName").val(res[0].slab_name);
        $("#txtEntryFatMin").val(res[0].slab_min);
        $("#txtEntryFatMax").val(res[0].slab_max);

        if (res[0].is_locked == 1) {
          $("#divFooterActions").hide();
        }

        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }
      },
      error: function () {
        ShowEntryError("Error : Fat Slab details not found");
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

  var FatSlab_Min = $("#txtEntryFatMin").val().trim();
  var FatSlab_Max = $("#txtEntryFatMax").val().trim();
  var IsValid = 1;

  if (
    FatSlab_Min == "" ||
    FatSlab_Min == null ||
    FatSlab_Min == undefined ||
    Is_Valid_Float(FatSlab_Min) == false
  ) {
    IsValid = 0;
    $("#txtEntryFatMin").addClass("is-invalid state-invalid");
  }

  if (
    FatSlab_Max == "" ||
    FatSlab_Max == null ||
    FatSlab_Max == undefined ||
    Is_Valid_Float(FatSlab_Max) == false
  ) {
    IsValid = 0;
    $("#txtEntryFatMax").addClass("is-invalid state-invalid");
  }

  if (parseFloat(FatSlab_Min) > parseFloat(FatSlab_Max)) {
    IsValid = 0;
    //$("#txtEntryFatMin").addClass("is-invalid state-invalid");
    //$("#txtEntryFatMax").addClass("is-invalid state-invalid");
    ShowEntryError("Fat Max should be greter than Fat Min");
    return;
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }
  // Start Saving
  Show_Loader();
  $("#btn_Save").prop("disabled", true);
  // Save
  var APIEndPoint = "SaveSlab";
  var Method_Name = "Create";
  var FatSlab_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    FatSlab_Id = $("#lblEntryId").html();
  }
  var FatSlab_Min = $("#txtEntryFatMin").val();
  var FatSlab_Max = $("#txtEntryFatMax").val();
  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;
  var url = "/Rate/Slab";
  var reqdata = {
    slab_id: FatSlab_Id,
    slab_name: FatSlab_Max + " - " + FatSlab_Min,
    slab_min: FatSlab_Min,
    slab_max: FatSlab_Max,
    is_active: Is_Active,
    is_deleted: Is_Deleted,
    method_name: Method_Name,
    slab_type: "fat",
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
        ShowEntrySuccess("Fat Slab details saved successfully");
        $("#lblEntryId").html(result[0].result_extra_key);
        $("#lblAction").html("Edit");
        $("#txtEntryFatSlabName").val(FatSlab_Max + " - " + FatSlab_Min);

        //GetSearchList();
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Hide_Loader();
      ShowEntryError("Error : Fat Slab details not saved");
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
  var FatSlab_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  var APIEndPoint = "SaveSlab";
  var url = "/Rate/Slab";
  var reqdata = {
    slab_id: FatSlab_Id,
    is_deleted: Is_Deleted,
    method_name: "Delete",
    slab_type: "fat",
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
        ShowEntrySuccess("Fat Slab details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        ShowEntrySuccess("Error : " + result[0].result_Description);
      }
    },
    error: function () {
      ShowEntryError("Error : Fat Slab details not deleted");
    },
  });
}
