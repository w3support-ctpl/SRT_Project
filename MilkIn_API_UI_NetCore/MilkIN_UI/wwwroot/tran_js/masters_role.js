$(document).ready(function () {});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  var APIEndPoint = "GetRole";
  var RoleName = "%" + $("#txtSearchRoleName").val() + "%";
  $("#btn_Search").prop("disabled", true);

  var Method_Name = "Get";
  var url = "/Masters/Role";
  var reqdata = {
    method_name: Method_Name,
    role_name: RoleName,
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
        TableHTML += "<td>" + value.role_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 50px; padding: 8px 5px 8px 5px;">';
        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.role_id +
            "', '" +
            value.role_name +
            "', '" +
            value.is_active +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [3], "Role");
      $("#btn_Search").prop("disabled", false);
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function ShowAddEntry() {
  ShowContentDiv("Masters", "RoleAdd", "", function () {
    // Initialization Code

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();

    $("#divMenuTable").hide();
  });
}

function ShowEditEntry(Role_Id, Role_Name, Active_Status) {
  ShowContentDiv("Masters", "RoleEdit", "", function () {
    // Initialization Code

    $("#lblEntryId").html(Role_Id);
    $("#lblAction").html("Edit");
    $("#divFooterDelete").show();
    $("#divMenuTable").show();
    $("#txtEntryRoleName").val(Role_Name);
    if (Active_Status == 1) {
      $("#chkEntryStatus").prop("checked", true);
    } else {
      $("#chkEntryStatus").prop("checked", false);
    }

    // Taking values from DB
    var APIEndPoint = "GetRole";
    var Method_Name = "Get_One";
    var url = "/Masters/Role";
    var reqdata = {
      method_name: Method_Name,
      role_id: Role_Id,
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
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
          TableHTML += "<td hidden>" + value.menu_id + "</td>";
          TableHTML += "<td>" + value.menu_name + "</td>";

          // Display Flag
          var checked = "";
          if (value.display_flag == 1) {
            checked = "checked";
          }
          TableHTML += '<td class="text-center">';
          TableHTML += '<label class="custom-control custom-checkbox">';
          TableHTML +=
            '<input type="checkbox" class="custom-control-input" id="' +
            "displayflag" +
            (data + 1) +
            '" ' +
            checked +
            " />";
          TableHTML +=
            '<label for="' +
            "displayflag" +
            (data + 1) +
            '" class="custom-control-label text-dark"></label>';
          TableHTML += "</label>";
          TableHTML += "</td>";

          // Add Flag
          checked = "";
          if (value.add_flag == 1) {
            checked = "checked";
          }
          TableHTML += '<td class="text-center">';
          TableHTML += '<label class="custom-control custom-checkbox">';
          TableHTML +=
            '<input type="checkbox" class="custom-control-input" id="' +
            "addflag" +
            (data + 1) +
            '" ' +
            checked +
            "  />";
          TableHTML +=
            '<label for="' +
            "addflag" +
            (data + 1) +
            '" class="custom-control-label text-dark"></label>';
          TableHTML += "</label>";
          TableHTML += "</td>";

          // Edit Flag
          checked = "";
          if (value.edit_flag == 1) {
            checked = "checked";
          }
          TableHTML += '<td class="text-center">';
          TableHTML += '<label class="custom-control custom-checkbox">';
          TableHTML +=
            '<input type="checkbox" class="custom-control-input" id="' +
            "editflag" +
            (data + 1) +
            '" ' +
            checked +
            " />";
          TableHTML +=
            '<label for="' +
            "editflag" +
            (data + 1) +
            '" class="custom-control-label text-dark"></label>';
          TableHTML += "</label>";
          TableHTML += "</td>";

          // Delete Flag
          checked = "";
          if (value.delete_flag == 1) {
            checked = "checked";
          }
          TableHTML += '<td class="text-center">';
          TableHTML += '<label class="custom-control custom-checkbox">';
          TableHTML +=
            '<input type="checkbox" class="custom-control-input" id="' +
            "deleteflag" +
            (data + 1) +
            '" ' +
            checked +
            " />";
          TableHTML +=
            '<label for="' +
            "deleteflag" +
            (data + 1) +
            '" class="custom-control-label text-dark"></label>';
          TableHTML += "</label>";
          TableHTML += "</td>";

          TableHTML += "<td hidden></td>";

          TableHTML += "</tr>";
        });
        ClearDataTable("tableRoleMenu");
        $("#tableEntry").html(TableHTML);
        //SetDataTable("tableRoleMenu", [7], "Role Menu");
      },
      error: function (result) {
        ShowEntryError(
          "Error in fetching details from server.",
          result[0].result_description
        );
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
 
  $("#btn_Save").prop("disabled", true);
  var RoleName = $("#txtEntryRoleName").val();

  var IsValid = 1;
  if (
    RoleName == "" ||
    RoleName == null ||
    RoleName == undefined ||
    Is_Valid_Name(RoleName) == false
  ) {
    IsValid = 0;
    $("#txtEntryRoleName").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    var Role_Id = "";
    var Method_Name = "Create";
    var Action_Name = $("#lblAction").html();
    var APIEndPoint = "SaveRole";
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var RoleMenu = "";
    var Is_Deleted = 0;
    var url = "/Masters/Role";
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Role_Id = $("#lblEntryId").html();

      // Getting Table values and converting it to XML
      RoleMenu += "<Menu>";
      $("#tableRoleMenu tbody tr").each(function () {
        var Display_Flag = 0;
        var Add_Flag = 0;
        var Edit_Flag = 0;
        var Delete_Flag = 0;
        // set values of flags as 1 if checked
        if ($(this).find("td:eq(3) input").prop("checked") == true) {
          Display_Flag = 1;
        }

        if ($(this).find("td:eq(4) input").prop("checked") == true) {
          Add_Flag = 1;
        }

        if ($(this).find("td:eq(5) input").prop("checked") == true) {
          Edit_Flag = 1;
        }

        if ($(this).find("td:eq(6) input").prop("checked") == true) {
          Delete_Flag = 1;
        }

        RoleMenu += "<MenuItem>";
        RoleMenu +=
          "<Menu_Id>" + $(this).find("td:eq(1)").text() + "</Menu_Id>";
        RoleMenu += "<Display_Flag>" + Display_Flag + "</Display_Flag>";
        RoleMenu += "<Add_Flag>" + Add_Flag + "</Add_Flag>";
        RoleMenu += "<Edit_Flag>" + Edit_Flag + "</Edit_Flag>";
        RoleMenu += "<Delete_Flag>" + Delete_Flag + "</Delete_Flag>";
        RoleMenu += "</MenuItem>";
      });
      RoleMenu += "</Menu>";
    }
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      role_id: Role_Id,
      role_name: RoleName,
      api_end_point: APIEndPoint,
      role_menu: RoleMenu,
    };
    //Save
    Show_Loader();
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          var Role_Id = result[0].result_extra_key;
          ShowEntrySuccess("Role details saved successfully");
          ShowEditEntry(Role_Id, RoleName, Is_Active);
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : Role details not saved");
      },
    });
    $("#btn_Save").prop("disabled", false);
  }
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
  var Role_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveRole";
  var url = "/Masters/Role";
  var reqdata = {
    method_name: "Delete",
    role_id: Role_Id,
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
        Show_Success_Toastr("Role details deleted successfully");
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Role details not deleted");
    },
  });
}
