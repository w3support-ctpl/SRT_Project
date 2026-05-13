$(document).ready(function () {});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var APIEndPoint = "GetBank";
  var SearchText = "%" + $("#txtSearchText").val() + "%";
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Masters/Bank";
  var reqdata = {
    method_name: Method_Name,
    search_text: SearchText,
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
        TableHTML += "<td>" + value.bank_name + "</td>";
        TableHTML += "<td>" + value.branch_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 50px; padding: 8px 5px 8px 5px;">';
        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.bank_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [4], "Bank");
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
  ShowContentDiv("Masters", "BankAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html("");
    $("#lblAction").html("Add");
    $("#divEntryBankBranchTable").hide();
    $("#divFooterDelete").show();
  });
}

function ShowEditEntry(Bank_Id) {
  ShowContentDiv("Masters", "BankEdit", "", function () {
    // Initialization Code

    $("#lblEntryId").html(Bank_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").hide();

    // Taking values from DB
    var APIEndPoint = "GetBank";
    var Method_Name = "Get_One";
    var url = "/Masters/Bank";
    var reqdata = {
      method_name: Method_Name,
      bank_id: Bank_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        // Fill data in input fields
        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }
        if (res[0].is_locked == 1) {
          $("#divFooterDelete").hide();
        } else {
          $("#divFooterDelete").show();
        }
        $("#txtEntryBankName").val(res[0].bank_name);
        GetBankBranchList(res[0].bank_id);
      },
      error: function (result) {
        Show_Error_Toastr(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });

    // Bank Entry

    //GetMaster("ddlEntryMCCName", "Select MCC", "GetMCC", "", "");
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var BankName = $("#txtEntryBankName").val();
  var IsValid = 1;

  if (
    BankName == "" ||
    BankName == null ||
    BankName == undefined ||
    Is_Valid_Name(BankName) == false
  ) {
    IsValid = 0;
    $("#txtEntryBankName").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveBank";
    var Method_Name = "Create";
    var Bank_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Bank_Id = $("#lblEntryId").html();
    }
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Masters/Bank";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      bank_id: Bank_Id,
      bank_name: BankName,
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
          Hide_Loader();
          // Show Success Message
          $("#btn_Save").prop("disabled", false);
          $("#divEntryBankBranchTable").show();
          $("#lblBankBranchId").html("");
          $("#lblBankBranchAction").html("Add");
          //GetSearchList();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          GetBankBranchList(result[0].result_extra_key);
          ShowEntrySuccess("Bank details saved successfully");
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : Bank details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}

function ShowBankBranchEditEntry(Branch_Id) {
  $("#lblBankBranchId").html(Branch_Id);
  $("#lblBankBranchAction").html("Edit");
  var Bank_Id = $("#lblEntryId").html();
  OpenModal("Edit");
  var APIEndPoint = "GetBankBranch";
  var Bank_Id = $("#lblEntryId").html();
  var Method_Name = "Get_One";
  var url = "/Masters/BankBranch";
  var reqdata = {
    method_name: Method_Name,
    branch_id: Branch_Id,
    api_end_point: APIEndPoint,
    bank_id: Bank_Id,
  };

  //Get Individual Bank Item
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      $("#modelEntryBank")
        .modal({
          backdrop: "static",
        })
        .modal("show");
      $("#txtEntryBranchName").val(res[0].branch_name);
      $("#txtEntryIFSCCode").val(res[0].ifsc_code);
      $("#txtEntryAddress").val(res[0].address_text);
    },
    error: function () {
      $("#modelEntryBank").modal("hide");
      ShowItemError("Error : Unable to load Branch details");
    },
  });
}

function SaveBankBranchEntry() {
  // Validation
  var BranchName = $("#txtEntryBranchName").val();
  var IFSCCode = $("#txtEntryIFSCCode").val();
  var AddressText = $("#txtEntryAddress").val();
  var Bank_Id = $("#lblEntryId").html();
  var IsValid = 1;

  if (
    BranchName == "" ||
    BranchName == null ||
    BranchName == undefined ||
    Is_Valid_Name(BranchName) == false
  ) {
    IsValid = 0;
    $("#txtEntryBranchName").addClass("is-invalid state-invalid");
  }
  if (
    IFSCCode == "" ||
    IFSCCode == null ||
    IFSCCode == undefined ||
    Is_Valid_IFSCNO(IFSCCode) == false
  ) {
    IsValid = 0;
    $("#txtEntryIFSCCode").addClass("is-invalid state-invalid");
  }
  if (AddressText == "" || AddressText == null || AddressText == undefined) {
    IsValid = 0;
    $("#txtEntryAddress").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save_Item").prop("disabled", true);
    Show_Loader();
    var APIEndPoint = "SaveBankBranch";
    var Method_Name = "Create";
    var Branch_Id = "";
    var Action_Name = $("#lblBankBranchAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Branch_Id = $("#lblBankBranchId").html();
    }
    var Is_Active = 0;
    if ($("#chkBranchEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Masters/BankBranch";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      bank_id: Bank_Id,
      branch_id: Branch_Id,
      branch_name: BranchName,
      ifsc_code: IFSCCode,
      address_text: AddressText,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };

    //Save Branch Details
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          $("#modelEntryBank").modal("hide");
          ShowItemSuccess("Bank Item details saved successfully");
          $("#btn_Save_Item").prop("disabled", false);
          GetBankBranchList(Bank_Id);
          ResetInputFields();
          //GetSearchList();
        } else {
          Hide_Loader();
          $("#modelEntryBank").modal("hide");
          ShowItemError("Error : " + result[0].result_description);
          $("#btn_Save_Item").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        $("#modelEntryBank").modal("hide");
        ShowItemError("Error : Bank Item details not saved");
        $("#btn_Save_Item").prop("disabled", false);
      },
    });
  }
}

function GetBankBranchList(Bank_Id) {
  ClearDataTable("tableBankBranch");
  // ClearDataTable("tableEntry");
  var APIEndPoint = "GetBankBranch";
  var Method_Name = "Get";
  var url = "/Masters/BankBranch";
  var reqdata = {
    method_name: Method_Name,
    bank_id: Bank_Id,
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

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1;
      var Active_Status;
      // $.each(res, function (data, value) {
      //   // console.log("1");
      //   if (value.is_active == 0) {
      //     Active_Status = "In-active";
      //   } else {
      //     Active_Status = "Active";
      //   }
      //   TableHTML += "<tr>";
      //   TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
      //   TableHTML += "<td>" + value.branch_name + "</td>";
      //   TableHTML += "<td>" + value.ifsc_code + "</td>";
      //   TableHTML += "<td>" + value.address_text + "</td>";
      //   TableHTML += "<td>" + Active_Status + "</td>";

      //   if (value.is_locked == 1) {
      //     TableHTML +=
      //       '<td class="text-right" style="width: 80px; padding: 8px 5px 8px 5px;">';
      //     TableHTML +=
      //       '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowBankBranchEditEntry(\'' +
      //       value.branch_id +
      //       "')\">";
      //     TableHTML += '<i class="fa fa-eye"></i>';
      //     TableHTML += "</a>";
      //     TableHTML += TableHTML += "</td>";
      //   }
      //   if (value.is_locked == 0) {
      //     TableHTML +=
      //       '<td class="text-right" style="width: 80px; padding: 8px 5px 8px 5px;">';
      //     TableHTML +=
      //       '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowBankBranchEditEntry(\'' +
      //       value.branch_id +
      //       "')\">";
      //     TableHTML += '<i class="fa fa-pencil"></i>';
      //     TableHTML += "</a>";

      //     TableHTML +=
      //       ' <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryBankBranch(\'' +
      //       value.branch_id +
      //       "')\">";
      //     TableHTML += '<i class="fa fa-trash"></i>';
      //     TableHTML += "</a>";
      //     TableHTML += TableHTML += "</td>";
      //   }

      //   TableHTML += "</tr>";
      // });
      $.each(res, function (data, value) {
        EditFlag = value.is_locked;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.branch_name + "</td>";
        TableHTML += "<td>" + value.ifsc_code + "</td>";
        TableHTML += "<td>" + value.address_text + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";

        TableHTML +=
          "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
        if (value.is_locked == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowBankBranchEditEntry(\'' +
            value.branch_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowBankBranchEditEntry(\'' +
            value.branch_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryBankBranch(\'' +
            value.branch_id +
            "')\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntry").html(TableHTML);
      SetDataTable("tableBankBranch", [5], "Bank Item");
      $("#btn_Save_Item").prop("disabled", false);
      $("#modelEntryBank").modal("hide");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Save_Item").prop("disabled", false);
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

function DeleteEntry(Bank_Entry) {
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
  var APIEndPoint = "SaveBank";
  var Bank_Id = $("#lblEntryId").html();
  var url = "/Masters/Bank";
  var reqdata = {
    bank_id: Bank_Id,
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
        Show_Success_Toastr("Bank details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Bank details not deleted");
    },
  });
}

function SaveDeleteEntryBankBranch(Branch_Id) {
  // Write code to delete
  // In success do following things
  var Bank_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveBankBranch";
  var url = "/Masters/BankBranch";
  var reqdata = {
    method_name: "Delete",
    branch_id: Branch_Id,
    bank_id: Bank_Id,
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
        ShowItemSuccess("Branch details deleted successfully");
        GetBankBranchList(Bank_Id);
        //GetSearchList();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : Branch details not deleted");
    },
  });
}

function OpenModal(action) {
  $("#modelEntryBank")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  if (action == "Add") {
    $("#lblBankBranchId").html("");
    $("#lblBankBranchAction").html("Add");
    $("#AddEditBankBranch").text("Add Branch Details");
  }
  if (action == "Edit") {
    $("#AddEditBankBranch").text("Edit Branch Details");
  }
}

$("#modelEntryBank").on("hidden.bs.modal", function (e) {
  ResetInputFields();
  $("#lblAction").html("");
  $("#AddEditBankBranch").text("");
});

function AddEditEntry() {
  var Action = $("#lblAction").html();
}

function ResetInputFields() {
  $(".modal input,textarea").val("");
}
