$(document).ready(function () {});

function GetSearchList() {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var SalesGroupCode = "%" + $("#txtSearchSalesAreaCode").val() + "%";
  var SalesGroupName = "%" + $("#txtSearchSalesAreaName").val() + "%";
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";

  var APIEndPoint = "GetSalesGroup";

  var url = "/Masters/SalesGroup";

  var reqdata = {
    method_name: Method_Name,
    salesarea_code: SalesGroupCode,
    salesarea_name: SalesGroupName,
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
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.salesarea_code + "</td>";
        TableHTML += "<td>" + value.salesarea_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        //TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        //if (EditFlag == true) {
        //    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowEditEntry('" + value.salesarea_id + "')\">";
        //    TableHTML += "<i class=\"fa fa-pencil\"></i>";
        //    TableHTML += "</a>";
        //}

        //TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [0], "SalesGroup");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  $("#btn_Search").prop("disabled", false);
  return;
}
function ShowAddEntry() {
  ShowContentDiv("Masters", "SalesGroupAdd", "", function () {
    // Initialization Code

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divFooterDelete").hide();

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function ShowEditEntry(SalesGroup_Id) {
  ShowContentDiv("Masters", "SalesGroupEdit", "", function () {
    // Initialization Code
    $("#lblEntryId").html(SalesGroup_Id);
    $("#lblAction").html("Edit");
    $("#divFooterDelete").show();

    var Method_Name = "Get_One";

    var APIEndPoint = "GetSalesGroup";
    var url = "/Masters/SalesGroup";
    var reqdata = {
      method_name: Method_Name,
      salesarea_id: SalesGroup_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        $("#txtEntrySalesAreaCode").val(res[0].salesarea_code);
        $("#txtEntrySalesAreaName").val(res[0].salesarea_name);
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
  var SalesGroupCode = $("#txtEntrySalesAreaCode").val();
  var SalesGroupName = $("#txtEntrySalesAreaName").val();

  var IsValid = 1;

  if (
    SalesGroupCode == "" ||
    SalesGroupCode == null ||
    SalesGroupCode == undefined ||
    Is_AlphaNumeric(SalesGroupCode) == false
  ) {
    IsValid = 0;
    $("#txtEntrySalesAreaCode").addClass("is-invalid state-invalid");

    //ShowEntryError("Enter Vehicle No");
  }
  if (
    SalesGroupName == "" ||
    SalesGroupName == null ||
    SalesGroupName == undefined ||
    Is_Valid_Name(SalesGroupName) == false
  ) {
    IsValid = 0;
    $("#txtEntrySalesAreaName").addClass("is-invalid state-invalid");

    //ShowEntryError("Enter Make");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Create";
    var SalesGroup_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      SalesGroup_Id = $("#lblEntryId").html();
    }
    var Is_Active = 1;
    if (document.getElementById("chkEntryStatus").checked == false) {
      Is_Active = 0;
    }
    var Is_Deleted = 0;
    var APIEndPoint = "SaveSalesGroup";
    var url = "/Masters/SalesGroup";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,

      salesarea_id: SalesGroup_Id,
      salesarea_code: SalesGroupCode,
      salesarea_name: SalesGroupName,
      api_end_point: APIEndPoint,
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
          // Show Success Messageq
          /*  ShowEditEntry(result[0].result_extra_key);*/
          GetSearchList();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          ShowEntrySuccess("Sales Area details saved successfully");
          //$("#lblEntryId").html(result[0].result_extra_key);
          //$("#lblAction").html("Edit");
        } else {
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        ShowEntryError("Error : Sales Area details not saved");
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
  var SalesGroup_Id = $("#lblEntryId").html();
  // In success do following things
  var Is_Deleted = 1;
  // In success do following things

  var APIEndPoint = "SaveSalesGroup";

  var url = "/Masters/SalesGroup";
  var reqdata = {
    salesarea_id: SalesGroup_Id,
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
        Show_Success_Toastr("Sales Area details deleted successfully");
        CloseEntry();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : Sales Area details not deleted");
    },
  });
}

function ShowDownloadEntry() {
  var APIEndPoint = "GetMasterSalesArea";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };
  Show_Loader();

  // $("#btnSaveSalesGroup").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      Hide_Loader();
      if ((res_output[0].result_id = 1)) {
        Show_Success_Toastr("Sales Group Get Successfully");
      }
      GetSearchList();
      ShowDownloadEntryItem();

      if (res_output.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Sales Group details not saved");
      // $("#btnSaveSalesGroup").prop("disabled", false);
    },
  });
  // $("#btnSaveSalesGroup").prop("disabled", false);
  return;
}

function ShowDownloadEntryItem() {
  var APIEndPoint = "GetMasterSalesAreaItem";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };
  Show_Loader();

  // $("#btnSaveSalesGroup").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      Hide_Loader();
      if ((res_output[0].result_id = 1)) {
        Show_Success_Toastr("Sales Group Item Get Successfully");
      }

      GetSearchList();

      if (res_output.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Sales Group Item details not saved");
      // $("#btnSaveSalesGroup").prop("disabled", false);
    },
  });
  // $("#btnSaveSalesGroup").prop("disabled", false);
  return;
}
