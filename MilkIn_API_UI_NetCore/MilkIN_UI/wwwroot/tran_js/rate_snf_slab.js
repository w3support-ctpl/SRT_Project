$(document).ready(function () {});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  $("#btn_Search").prop("disabled", true);
  var APIEndPoint = "GetSlab";
  var url = "/Rate/Slab";
  var SNFSlab_Name = $("#txtSearchSlabName").val();

  var reqdata = {
    slab_name: "%" + SNFSlab_Name + "%",
    method_name: "Get",
    slab_type: "snf",
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

      SetDataTable("tableSearch", [5], "SNF Slab");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      $("#btn_Search").prop("disabled", false);
    },
  });
}

function ShowAddEntry() {
  ShowContentDiv("Rate", "SNFSlabAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divFooterActions").hide();
  });
}

function ShowEditEntry(SNFSlab_Id) {
  ShowContentDiv("Rate", "SNFSlabEdit", "", function () {
    // Initialization Code
    $("#lblEntryId").html(SNFSlab_Id);
    $("#lblAction").html("Edit");

    var APIEndPoint = "GetSlab";
    var url = "/Rate/Slab";
    var reqdata = {
      slab_id: SNFSlab_Id,
      method_name: "Get_One",
      slab_type: "snf",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result);

        $("#txtEntrySNFSlabName").val(res[0].slab_name);
        $("#txtEntrySNFMin").val(res[0].slab_min);
        $("#txtEntrySNFMax").val(res[0].slab_max);

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
        ShowEntryError("Error : SNF Slab details not found");
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

  var SNFSlab_Min = $("#txtEntrySNFMin").val();
  var SNFSlab_Max = $("#txtEntrySNFMax").val();

  var IsValid = 1;

  if (
    SNFSlab_Min == "" ||
    SNFSlab_Min == null ||
    SNFSlab_Min == undefined ||
    Is_Valid_Float(SNFSlab_Min) == false
  ) {
    IsValid = 0;
    $("#txtEntrySNFMin").addClass("is-invalid state-invalid");
  }

  if (
    SNFSlab_Max == "" ||
    SNFSlab_Max == null ||
    SNFSlab_Max == undefined ||
    Is_Valid_Float(SNFSlab_Max) == false
  ) {
    IsValid = 0;
    $("#txtEntrySNFMax").addClass("is-invalid state-invalid");
  }

  if (parseFloat(SNFSlab_Min) > parseFloat(SNFSlab_Max)) {
    IsValid = 0;
    ShowEntryError("SNF Max should be greter than SNF Min");
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
  var SNFSlab_Id = "";
  var Action_Name = $("#lblAction").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    SNFSlab_Id = $("#lblEntryId").html();
  }

  var SNFSlab_Min = $("#txtEntrySNFMin").val();
  var SNFSlab_Max = $("#txtEntrySNFMax").val();
  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;

  var url = "/Rate/Slab";
  var reqdata = {
    slab_id: SNFSlab_Id,
    slab_name: SNFSlab_Max + " - " + SNFSlab_Min,
    slab_min: SNFSlab_Min,
    slab_max: SNFSlab_Max,
    is_active: Is_Active,
    is_deleted: Is_Deleted,
    method_name: Method_Name,
    slab_type: "snf",
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
        ShowEntrySuccess("SNF Slab details saved successfully");
        $("#lblEntryId").html(result[0].result_extra_key);
        $("#lblAction").html("Edit");
        $("#txtEntrySNFSlabName").val(SNFSlab_Max + " - " + SNFSlab_Min);
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
  var SNFSlab_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  var APIEndPoint = "SaveSlab";
  var url = "/Rate/Slab";
  var reqdata = {
    slab_id: SNFSlab_Id,
    is_deleted: Is_Deleted,
    method_name: "Delete",
    slab_type: "snf",
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
        ShowEntrySuccess("SNF Slab details deleted successfully");

        //GetSearchList();
        CloseEntry();
      } else {
        ShowEntrySuccess("Error : " + result[0].result_Description);
      }
    },
    error: function () {
      ShowEntryError("Error : SNF Slab details not deleted");
    },
  });
}
