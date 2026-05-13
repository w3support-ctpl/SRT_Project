$(document).ready(function () {
  $("#ddlSearchLedgerStatus").select2();
  GetMaster(
    "ddlSearchLedgerStatus",
    "Select Ledger Status",
    "GetLedgerStatus",
    0,
    ""
  );
  //SetDataTable("tableSearch", [6], "RecurringDeductions");
  $('input[name="datefilter"]').daterangepicker({
    locale: {
      cancelLabel: "Clear",
    },
    startDate: moment().subtract(30, "days"), // Set the startDate to 30 days ago
    endDate: moment(), // Set the endDate to the current date
    ranges: {
      Today: [moment(), moment()],
      Yesterday: [moment().subtract(1, "days"), moment().subtract(1, "days")],
      "Last 7 Days": [moment().subtract(6, "days"), moment()],
      "Last 30 Days": [moment().subtract(29, "days"), moment()],
      "This Month": [moment().startOf("month"), moment().endOf("month")],
      "Last Month": [
        moment().subtract(1, "month").startOf("month"),
        moment().subtract(1, "month").endOf("month"),
      ],
    },
  });

  $('input[name="datefilter"]').on(
    "apply.daterangepicker",
    function (ev, picker) {
      $(this).val(
        picker.startDate.format("MM/DD/YYYY") +
          " - " +
          picker.endDate.format("MM/DD/YYYY")
      );
    }
  );

  $('input[name="datefilter"]').on(
    "cancel.daterangepicker",
    function (ev, picker) {
      $(this).val("");
    }
  );

  $("#ddlSearchLedgerStatus").on("change", function () {
    if ($("#ddlSearchLedgerStatus").find(":selected").val() == "1") {
      $("#divSearchEntryPeriod").show();
    } else {
      $("#divSearchEntryPeriod").hide();
    }
  });

  $("#modelEntryMCC").on("hidden.bs.modal", function (e) {
    GetSearchList();
    ClearDataTable("tableSearch");
  });
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var APIEndPoint = "GetDeductions";
  var SearchPeriod = $("#txtSearchEntryPeriod").val();
  var LedgerStatus = $("#ddlSearchLedgerStatus").val();
  if (LedgerStatus == "") {
    $("#ddlSearchLedgerStatus").addClass("is-invalid state-invalid");
    return;
  }
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Manage/Deductions";
  var reqdata = {
    method_name: Method_Name,
    ledger_status: LedgerStatus,
    search_period: SearchPeriod,
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
      var EditFlag; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        EditFlag = value.is_closed;
        if (value.is_closed == 0) {
          Active_Status = "Pending";
        } else {
          Active_Status = "Closed";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.entry_date + "</td>";
        TableHTML += "<td>" + value.request_user_type + "</td>";
        TableHTML += "<td>" + value.request_user_name + "</td>";
        TableHTML += "<td>" + value.request_user_mobile_no + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.request_type + "</td>";
        TableHTML += "<td>" + value.total_amount + "</td>";
        TableHTML += "<td>" + value.amount_deducted + "</td>";
        TableHTML += "<td>" + value.balance + "</td>";
        if (value.no_of_installments == 0) {
          TableHTML +=
            "<td><span class='label label-danger mt-2'> " +
            value.no_of_installments +
            " </span></td>";
        } else {
          TableHTML += "<td>" + value.no_of_installments + "</td>";
        }
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
            value.deductions_id +
            "', '" +
            value.request_user_id +
            "', '" +
            value.request_user_name +
            "', '" +
            value.no_of_installments +
            "','" +
            value.total_amount +
            "','" +
            value.amount_deducted +
            "', '" +
            value.balance +
            "','" +
            value.entry_date +
            "','" +
            value.request_type +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\'' +
            value.deductions_id +
            "', '" +
            value.request_user_id +
            "', '" +
            value.request_user_name +
            "', '" +
            value.no_of_installments +
            "','" +
            value.total_amount +
            "','" +
            value.amount_deducted +
            "', '" +
            value.balance +
            "','" +
            value.entry_date +
            "','" +
            value.request_type +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [7], "Deductions");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function GetItemTable(Action, mycallback) {
  mycallback(Action);
}
function ShowEditEntry(
  Action,
  _DeductionsId,
  _UserId,
  _UserName,
  _NoOfInstallments,
  _TotalAmount,
  _AmountDeducted,
  _Balance,
  _EntryDate,
  _RequestType
) {
  Deductions_Id = _DeductionsId;
  User_Id = _UserId;
  User_Name = _UserName;
  No_Of_Installments = _NoOfInstallments;
  Total_Amount = parseFloat(_TotalAmount);
  Amount_Deducted = parseFloat(_AmountDeducted);
  Balance = parseFloat(_Balance);
  Entry_Date = _EntryDate;
  RequestType = _RequestType;

  ShowContentDiv("Manage", "DeductionsEdit", "", function () {
    $("#DeleteEntry").hide();

    Current_No_Of_Installments = 0;

    $("#lblEntryId").html(Deductions_Id);
    if (No_Of_Installments == 0) {
      $("#lblAction").html("Add");
    } else {
      $("#lblAction").html(Action);
    }
    $("#lblRequestType").html(RequestType);
    $("#txtEntryRequestUserName").val(User_Name);
    $("#txtEntryRequestUserName").prop("disabled", true);

    $("#txtEntryTotalAmount").val(Total_Amount);
    $("#txtEntryTotalAmount").prop("disabled", true);

    $("#txtEntryAmountDeducted").val(Amount_Deducted);
    $("#txtEntryAmountDeducted").prop("disabled", true);

    $("#txtEntryBalance").val(Balance);
    $("#txtEntryBalance").prop("disabled", true);

    $("#txtEntryApprovalDate").val(Entry_Date);
    $("#txtEntryApprovalDate").prop("disabled", true);

    $("#txtEntryNoOfInstallments").val(No_Of_Installments);

    if (Action == "View") {
      $("#txtEntryNoOfInstallments").prop("disabled", true);
      //GetDeductionsItem_Table(Action);
    } else {
      $("#txtEntryNoOfInstallments").prop("disabled", false);
    }

    GetItemTable(Action, GetDeductionsItem_Table);
    // $("#txtEntryNoOfInstallments").on("change", function () {
    //   GenerateDeductionsItem_Table(
    //     $("#txtEntryNoOfInstallments").val(),
    //     Total_Amount,
    //     Amount_Deducted
    //   );
    // });
    GetDeductionsDelete(Deductions_Id);
    $("#txtEntryNoOfInstallments").keypress(function (e) {
      GenerateDeductionsItem_Table(
        $("#txtEntryNoOfInstallments").val(),
        Total_Amount,
        Amount_Deducted
      );
    });
  });
  return;
}

function GetInstallments() {
  GenerateDeductionsItem_Table(
    $("#txtEntryNoOfInstallments").val(),
    Total_Amount,
    Amount_Deducted
  );
}
// Generate New Table with row_count = No_Of_Installments
function GenerateDeductionsItem_Table(
  NoOfInstallments,
  TotalAmount,
  AmountDeducted
) {
  //var Action = $("#lblAction").html();
  //GetItemTable(Action,GetDeductionsItem_Table);

  $("#divDeductionsItemTable").show();
  var New_Total_Amount = TotalAmount; // - AmountDeducted;

  // get rows where Is_Deducted = 1
  // store in new array of arrays
  var DeductedRows = [];
  var totaldeductedamt = 0.0;
  $("#tableDeductionsItem tbody tr").each(function () {
    var ddate = $(this).find("td:eq(1) div input").val();
    var damount = parseFloat($(this).find("td:eq(2) div input").val());
    var isdeducted = $(this).find("td:eq(3) span").text();
    if (isdeducted == 1) {
      var onerow = [ddate, damount, isdeducted];
      DeductedRows.push(onerow);
      totaldeductedamt += damount;
    }
  });
  if (DeductedRows.length > 0) {
    New_Total_Amount = Total_Amount - totaldeductedamt;
  }
  Total_Rows = NoOfInstallments;
  NoOfInstallments -= DeductedRows.length;
  index = 1;
  var Deduction_Amount = parseInt(
    parseFloat(New_Total_Amount) / parseFloat(NoOfInstallments)
  );
  var Last_Amount =
    Deduction_Amount +
    (parseFloat(New_Total_Amount) % parseFloat(NoOfInstallments));

  ClearDataTable("tableDeductionsItem");
  var TableHTML = "";
  var j;
  for (j = 0; j < DeductedRows.length; j++) {
    TableHTML += "<tr>";

    TableHTML += "<td>" + index + "</td>";

    TableHTML += "<td>";
    TableHTML += "<div class='form-group'>";
    TableHTML +=
      "<input type='date' id='txtInstallmentDate" +
      index +
      "' value='" +
      DeductedRows[j][0] +
      "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
    TableHTML +=
      "<div class='invalid-feedback'>Deduction Date can't be blank.</div>";
    TableHTML += "</div>";
    TableHTML += "</td>";

    TableHTML += "<td>";
    TableHTML += "<div class='form-group'>";
    TableHTML +=
      "<input type='text' id='txtInstallmentAmount" +
      index +
      "' value='" +
      DeductedRows[j][1] +
      "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
    TableHTML +=
      "<div class='invalid-feedback'>Invalid Deduction Amount.</div>";
    TableHTML += "</div>";
    TableHTML += "</td>";

    TableHTML +=
      "<td><span hidden>" + DeductedRows[j][2] + "</span>Deducted<td>";
    TableHTML += "</tr>";

    index += 1;
  }
  /*
    if (DeductedRows.length > 0) {
        // assign index to +1 most recent installment
        index = parseInt(DeductedRows[DeductedRows.length - 1][3]);
        index += 1;
    }*/
  //New_Installment_No = NoOfInstallments - Current_No_Of_Installments;

  var i;
  for (i = 0; i < NoOfInstallments; i++) {
    // last value
    if (i == NoOfInstallments - 1) {
      Deduction_Amount = Last_Amount;
    }

    TableHTML += "<tr>";

    TableHTML += "<td>" + index + "</td>";

    TableHTML += "<td>";
    TableHTML += "<div class='form-group'>";
    TableHTML +=
      "<input type='date' id='txtInstallmentDate" +
      index +
      "' class='form-control' onchange='ClearInvalidState(this); SetLaterDates(" +
      index +
      "," +
      Total_Rows +
      ")'>";
    TableHTML +=
      "<div class='invalid-feedback'>Deduction Date can't be blank.</div>";
    TableHTML += "</div>";
    TableHTML += "</td>";

    TableHTML += "<td>";
    TableHTML += "<div class='form-group'>";
    TableHTML +=
      "<input type='text' id='txtInstallmentAmount" +
      index +
      "' value='" +
      Deduction_Amount +
      "' class='form-control' onchange='ClearInvalidState(this);'>";
    TableHTML +=
      "<div class='invalid-feedback'>Invalid Deduction Amount.</div>";
    TableHTML += "</div>";
    TableHTML += "</td>";

    TableHTML += "<td><span hidden>0</span>Not Deducted<td>";
    TableHTML += "</tr>";

    index += 1;
  }
  $("#tableEntryDeductionsItem").html(TableHTML);
  //SetDataTable("tableDeductionsItem", [1], "Deductions Item");

  // Disable Past Dates
  for (var k = 0; k < index; k++) {
    DisablePastDates("txtInstallmentDate" + k);
  }
  return;
}

// Get Deductions Item Table from database
function GetDeductionsItem_Table(Action) {
  $("#divDeductionsItemTable").show();
  ClearDataTable("tableDeductionsItem");
  var APIEndPoint = "GetDeductions";
  var Method_Name = "Get_One";
  var url = "/Manage/Deductions";
  var reqdata = {
    method_name: Method_Name,
    deductions_id: Deductions_Id,
    api_end_point: APIEndPoint,
  };
  var TableHTML = "";
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // Fill data in table

      if (res.length > 0) {
        //var EditFlag;
        var disabled;
        //var checked;
        var Deduction_Status = "";

        $.each(res, function (data, value) {
          disabled = "";
          //checked = "";
          Deduction_Status = "Not Deducted";
          if (value.is_deducted == 1) {
            disabled = "disabled";
            //checked = "checked";
            Deduction_Status = "Deducted";
          }
          if (Action == "View") {
            disabled = "disabled";
          }

          TableHTML += "<tr>";

          TableHTML += "<td>" + (data + 1) + "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='date' id='txtInstallmentDate" +
            (data + 1) +
            "' class='form-control' value='" +
            value.deduction_date +
            "' " +
            disabled +
            " onchange='ClearInvalidState(this); SetLaterDates(" +
            (data + 1) +
            ", " +
            res.length +
            ")'>";
          TableHTML +=
            "<div class='invalid-feedback'>Deduction Date can't be blank.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtInstallmentAmount" +
            (data + 1) +
            "' class='form-control' value='" +
            value.deduction_amount +
            "' " +
            disabled;
          TableHTML += " onkeyup='IsTotalAmount();' > ";
          TableHTML +=
            "<div class='invalid-feedback'>Invalid Deduction Amount.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML +=
            "<td><span hidden>" +
            value.is_deducted +
            "</span>" +
            Deduction_Status +
            "</td>";

          TableHTML += "</tr>";
        });
      } else {
        Current_No_Of_Installments = res.length;
      }

      $("#tableEntryDeductionsItem").html(TableHTML);
      //SetDataTable("tableDeductionsItem", [1], "Deductions Item");

      // Disable Past Dates
      for (var k = 0; k < res.length; k++) {
        DisablePastDates("txtInstallmentDate" + k);
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

// Save
function SaveEntry() {
  var SessionRoleId = $("#lblSessionRoleId").html();

  $("#btn_Save").prop("disabled", true);
  var checkRequestType = $("#lblRequestType").html();
  if (SessionRoleId != "MU001") {
    if (IsTotalAmount()) {
      Show_Error_Toastr(
        "Sum of Deduction Amounts should be equal to Total Amount."
      );
      $("#btn_Save").prop("disabled", false);
      return;
    }
  }

  var Installments = $("#txtEntryNoOfInstallments").val();

  var IsValid = 1;
  if (Installments == "") {
    IsValid = 0;
    $("#txtEntryNoOfInstallments").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // array to validate dates -  no two dates can be same
  DD_Dates = [];

  var index = 0;
  var DeductionTable = "<Deduction>";
  $("#tableDeductionsItem tbody tr").each(function () {
    var Is_Deducted = 0;
    index = $(this).find("td:eq(0)").text();

    // set values of flag as 1 if checked
    Is_Deducted = $(this).find("td:eq(3) span").text();
    var dt = $(this).find("td:eq(1) div input").val();
    if (dt == "") {
      $("#txtInstallmentDate" + index).addClass("is-invalid state-invalid");
      return;
    }
    Amount_Deducted += parseFloat($(this).find("td:eq(2) input").val());

    // validate dates - no two dates can be same

    if (DD_Dates.includes($(this).find("td:eq(1) div input").val())) {
      IsValid = 0;
      return false;
    } else {
      DD_Dates.push($(this).find("td:eq(1) div input").val());
    }
    GetDeductionsItem_Table;
    DeductionTable += "<DeductionItem>";
    DeductionTable += "<Index>" + $(this).find("td:eq(0)").text() + "</Index>";
    DeductionTable +=
      "<DeductionDate>" +
      $(this).find("td:eq(1) div input").val() +
      "</DeductionDate>";
    DeductionTable +=
      "<DeductionAmount>" +
      $(this).find("td:eq(2) div input").val() +
      "</DeductionAmount>";
    DeductionTable += "<IsDeducted>" + Is_Deducted + "</IsDeducted>";
    DeductionTable += "</DeductionItem>";
  });
  DeductionTable += "</Deduction>";
  if (IsValid == 0) {
    Show_Error_Toastr("No two deduction dates can be same.");
    return;
  }

  var url = "/Manage/Deductions";
  var APIEndPoint = "SaveDeductions";
  var Method_Name = "Update";
  var Action = $("#lblAction").html();
  if (Action == "Add") {
    Method_Name = "Create";
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    deductions_id: Deductions_Id,
    no_of_installments: Installments,
    deduction_data: DeductionTable,
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
        $("#lblAction").html("Edit");
        Show_Success_Toastr("Deduction details saved successfully");
        //ShowEditEntry("Edit", Deductions_Id, User_Id, User_Name, Installments, Total_Amount, Amount_Deducted, Balance, Entry_Date);
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Deduction details not saved");
    },
  });
  $("#btn_Save").prop("disabled", false);
}

// to check and make sure user doesn't invalid values in
function IsTotalAmount() {
  var temptotal = 0;
  $("#tableDeductionsItem tbody tr").each(function () {
    // // console.log($(this).find("td:eq(2) input").val());
    temptotal += parseFloat($(this).find("td:eq(2) input").val());
  });
  return temptotal < Total_Amount;
  // // console.log(temptotal + ", " + Total_Amount);
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function SetLaterDates(row_index, total_rows) {
  // get date on row_index
  var curr_date = new Date($("#txtInstallmentDate" + row_index).val());

  // add one day to the date
  var date = new Date(curr_date);
  date.setDate(curr_date.getDate() + 1);
  var newdate = date.toISOString().slice(0, 10);

  // disable the date and other for the datepickers for all the greater rows upto total_rows.
  for (var p = row_index + 1; p <= total_rows; p++) {
    $("#txtInstallmentDate" + p).attr("min", newdate);
    $("#txtInstallmentDate" + p).val(newdate);
  }
  return;
}

function ShowAddEntry() {
  ShowContentDiv("Manage", "DeductionsAdd", "", function () {
    $("#divMCCName").hide();
    $("#ddlEntryUserType").select2();
    $("#ddlEntryUserName").select2();
    $("#ddlEntryRequestType").select2();
    $("#txtEntryAmount").val("");
    $("#ddlEntryMCCName").select2();
    GetMaster("ddlEntryUserType", "Select User Type", "GetUserType", "", "");

    var date = new Date().toISOString().slice(0, 10);
    $("#txtEntryDate").val(date);
  });
  return;
}

function GetUserName() {
  //Empty All Childeren/Dependent DDLs
  $("#ddlEntryUserName")
    .empty()
    .append($("<option></option>").val("").html("Select User Name"));

  var UserType_Id = $("#ddlEntryUserType").val();

  if (UserType_Id == "Agent") {
    $("#divMCCName").hide();
    GetMaster("ddlEntryUserName", "Select User Name", "GetMCC", "", "");
  }
  if (UserType_Id == "Farmer") {
    $("#divMCCName").show();
    GetMaster("ddlEntryMCCName", "Select MCC Name", "GetMCC", "", "");
    // GetMaster("ddlEntryUserName", "Select User Name", "GetFarmer", "", "");
  }
  if (UserType_Id == "Transporter") {
    $("#divMCCName").hide();
    GetMaster("ddlEntryUserName", "Select User Name", "GetTransporter", "", "");
  }
  if (UserType_Id == "" || UserType_Id == null || UserType_Id == undefined) {
    $("#divMCCName").hide();
  }
}

function GetFarmer() {
  var MCC_Id = $("#ddlEntryMCCName").val();
  GetMaster("ddlEntryUserName", "Select User Name", "GetMCCFarmer", "", MCC_Id);
}

function GetRequestType() {
  //Empty All Childeren/Dependent DDLs
  $("#ddlEntryRequestType")
    .empty()
    .append($("<option></option>").val("").html("Select Type"));
  $("#ddlEntryRequestType")
    .empty()
    .append($("<option></option>").val("").html("Select Type"));

  var UserType_Id = $("#ddlEntryUserType").val();
  GetMaster(
    "ddlEntryRequestType",
    "Select Type",
    "GetRequestTypes",
    "",
    UserType_Id
  );
}

function SaveAddEntry() {
  var UserType_Id = $("#ddlEntryUserType").val();
  var UserName_Id = $("#ddlEntryUserName").val();
  var RequestType_Id = $("#ddlEntryRequestType").val();
  var Amount = $("#txtEntryAmount").val().trim();
  var EntryDate = $("#txtEntryDate").val();

  var IsValid = 1;

  if (UserType_Id == "" || UserType_Id == null || UserType_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryUserType").addClass("is-invalid state-invalid");
  }
  if (UserName_Id == "" || UserName_Id == null || UserName_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryUserName").addClass("is-invalid state-invalid");
  }

  if (
    RequestType_Id == "" ||
    RequestType_Id == null ||
    RequestType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryRequestType").addClass("is-invalid state-invalid");
  }

  if (
    Amount == "" ||
    Amount == null ||
    Amount == undefined ||
    Is_Positive_Number_Greater_Than_Zero(Amount) == false ||
    Is_Valid_Float(Amount) == false
  ) {
    IsValid = 0;
    $("#txtEntryAmount").addClass("is-invalid state-invalid");
  }

  if (EntryDate == "" || EntryDate == null || EntryDate == undefined) {
    IsValid = 0;
    $("#txtEntryDate").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Save
  var APIEndPoint = "SaveDeductions";
  var Method_Name = "Insert";

  var url = "/Manage/Deductions";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    usertype_id: UserType_Id,
    username_id: UserName_Id,
    requesttype_id: RequestType_Id,
    amount: Amount,
    date: EntryDate,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        // CloseEntry();
        GetDeductions(result[0].result_extra_key);
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Deductions details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
}

function GetDeductions(Deductions_Id) {
  var APIEndPoint = "GetDeductions";
  var Method_Name = "GetOne";
  var url = "/Manage/Deductions";
  var reqdata = {
    method_name: Method_Name,
    deductions_id: Deductions_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      ShowEditEntry(
        "Edit",
        res[0].deductions_id,
        res[0].request_user_id,
        res[0].request_user_name,
        res[0].no_of_installments,
        res[0].total_amount,
        res[0].amount_deducted,
        res[0].balance,
        res[0].entry_date,
        res[0].request_type
      );
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}
function OpenModal() {
  ClearDataTable("tableSearch");
  $("#modelEntryMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#ddlSearchMCC").select2();
  GetMaster("ddlSearchMCC", "Select MCC", "GetMCC", "", "");
}

function SaveExcelUploadEntry() {
  Show_Loader();
  ClearDataTable("tableUploadFarmerEntryModal");
  // Show_Loader();
  var file = $("#txtEntryExcelUpload");
  var reqdata = new FormData();
  reqdata.append("FIle", file[0].files[0]);
  reqdata.append("ModuleName", "CategoryMaster");

  var url = "/Transporter/CovertExcelToTable";
  $.ajax({
    url: url,
    type: "POST",
    processData: false,
    contentType: false,
    data: reqdata,
    async: false,
    success: function (response) {
      if (response.status == 200) {
        var res_Json = JSON.parse(response.data);
        // // console.log(res_Json);

        var farmerDeductionsData = "<Deductions>";
        for (var i = 0; i < res_Json.length; i++) {
          var farmerData = res_Json[i];

          // Check if any of the required fields are null, blank, or undefined
          if (
            farmerData["Farmer Code"] &&
            farmerData["Entry Date"] &&
            farmerData["Amount"]
          ) {
            farmerDeductionsData += "<Farmer>";
            farmerDeductionsData +=
              "<MCC_Farmer_Code>" +
              farmerData["Farmer Code"] +
              "</MCC_Farmer_Code>";
            farmerDeductionsData +=
              "<EntryDate>" + farmerData["Entry Date"] + "</EntryDate>";
            farmerDeductionsData +=
              "<Amount>" + farmerData["Amount"] + "</Amount>";
            farmerDeductionsData += "</Farmer>";
          }
        }
        farmerDeductionsData += "</Deductions>";

        var MCC_Id = $("#ddlSearchMCC").val();

        var Method_Name = "ExcelUpload";
        var APIEndPoint = "SaveDeduction";
        var url_One = "/Manage/Deductions";
        var reqdata_one = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          username_id: MCC_Id,
          usertype_id: "Farmer",
          requesttype_id: "M020231000012", // M020231000015 Dairy Advance // M020231000012 MCC Advance
          deduction_data: farmerDeductionsData,
          no_of_installments: "1",
        };

        $.ajax({
          type: "POST",
          url: url_One,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata_one,
          success: function (result) {
            Hide_Loader();
            var res = JSON.parse(result);
            var TableHTML = "";
            // console.log(res);

            $.each(res, function (data, value) {
              TableHTML += "<tr>";
              TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
              TableHTML += "<td>" + value.farmer_code + "</td>";
              TableHTML += "<td>" + value.date + "</td>";
              TableHTML += "<td>" + value.amount + "</td>";
              TableHTML += "<td>" + value.status + "</td>";
              TableHTML += "<td hidden></td>";
              TableHTML += "</tr>";
            });

            $("#tableEntryModelUploadFarmer").html(TableHTML);

            SetDataTable("tableUploadFarmerEntryModal", [5], "Deductions");

            // // // console.log(result);
            // if (result[0].result_id == 1) {
            //   Hide_Loader();
            //   // Show Success Message
            //   // Show_Success_Toastr(result[0].result_description);
            //   // $("#modelEntryMCC").modal("hide");
            //   // GetSearchList();
            // } else {
            //   Hide_Loader();
            //   Show_Error_Toastr("Error : " + result[0].result_description);
            // }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Farmer deductions details not saved");
          },
        });
      } else {
        Hide_Loader();
        Show_Error_Toastr(response.data);
      }

      // Hide_Loader();
    },
    error: function (msg) {
      Hide_Loader();
      Show_Error_Toastr(msg);
      // Hide_Loader();
    },
  });
}

function ExcelDownload() {
  var data = [
    ["Farmer Code", "Entry Date", "Amount"],
    ["xxxx", "yyyy-mm-dd", "xx.xx"],
  ];

  // Convert data to CSV format
  var csvContent =
    "data:text/csv;charset=utf-8," +
    data.map((row) => row.join(",")).join("\n");

  // Create a virtual link and trigger download
  var encodedUri = encodeURI(csvContent);
  var link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", "DeductionUploadTemplate.csv");
  document.body.appendChild(link); // Required for Firefox
  link.click();
}

function GetDeductionsDelete(deductions_id) {
  // ClearDataTable("tableDieselUploadList");
  var APIEndPoint = "GetDeductions";

  var Method_Name = "Get_Locked";
  var url = "/Manage/Deductions";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    deductions_id: deductions_id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res[0].is_locked == "1") {
        $("#DeleteEntry").hide();
      } else {
        $("#DeleteEntry").show();
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function DeleteEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        var Deductions_Id = $("#lblEntryId").html();
        var APIEndPoint = "SaveDeductions";
        var Method_Name = "Delete";
        var url = "/Manage/Deductions";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          deductions_id: Deductions_Id,
          no_of_installments: 0,
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
              Show_Success_Toastr("Deductions Data Delete successfully");

              CloseEntry();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Deductions Data Delete not Reverse");
          },
        });
      }
    }
  );
}
