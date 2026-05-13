$(document).ready(function () {
    $("#ddlSearchLedgerStatus").select2();
    GetMaster(
        "ddlSearchLedgerStatus",
        "Select Ledger Status",
        "GetLedgerStatus",
        0,
        ""
    );
    //SetDataTable("tableSearch", [6], "RecurringIncentives");
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
    var APIEndPoint = "GetIncentives";
    var SearchPeriod = $("#txtSearchEntryPeriod").val();
    var LedgerStatus = $("#ddlSearchLedgerStatus").val();
    if (LedgerStatus == "") {
        $("#ddlSearchLedgerStatus").addClass("is-invalid state-invalid");
        return;
    }
    $("#btn_Search").prop("disabled", true);
    var Method_Name = "Get";
    var url = "/Manage/Incentives";
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
                TableHTML += "<td>" + value.request_type + "</td>";
                TableHTML += "<td>" + value.total_amount + "</td>";
                TableHTML += "<td>" + value.amount_paid + "</td>";
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
                        value.incentives_id +
                        "', '" +
                        value.request_user_id +
                        "', '" +
                        value.request_user_name +
                        "', '" +
                        value.no_of_installments +
                        "','" +
                        value.total_amount +
                        "','" +
                        value.amount_paid +
                        "', '" +
                        value.balance +
                        "','" +
                        value.entry_date +
                        "')\">";
                    TableHTML += '<i class="fa fa-pencil"></i>';
                    TableHTML += "</a>";
                } else {
                    TableHTML +=
                        '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\'' +
                        value.incentives_id +
                        "', '" +
                        value.request_user_id +
                        "', '" +
                        value.request_user_name +
                        "', '" +
                        value.no_of_installments +
                        "','" +
                        value.total_amount +
                        "','" +
                        value.amount_paid +
                        "', '" +
                        value.balance +
                        "','" +
                        value.entry_date +
                        "')\">";
                    TableHTML += '<i class="fa fa-eye"></i>';
                    TableHTML += "</a>";
                }

                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);

            SetDataTable("tableSearch", [6], "Incentives");
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
    _IncentivesId,
    _UserId,
    _UserName,
    _NoOfInstallments,
    _TotalAmount,
    _AmountPaid,
    _Balance,
    _EntryDate
) {
    Incentives_Id = _IncentivesId;
    User_Id = _UserId;
    User_Name = _UserName;
    No_Of_Installments = _NoOfInstallments;
    Total_Amount = parseFloat(_TotalAmount);
    amount_paid = parseFloat(_AmountPaid);
    Balance = parseFloat(_Balance);
    Entry_Date = _EntryDate;
    ShowContentDiv("Manage", "IncentivesEdit", "", function () {
        Current_No_Of_Installments = 0;

        $("#lblEntryId").html(Incentives_Id);
        if (No_Of_Installments == 0) {
            $("#lblAction").html("Add");
        } else {
            $("#lblAction").html(Action);
        }

        $("#txtEntryRequestUserName").val(User_Name);
        $("#txtEntryRequestUserName").prop("disabled", true);

        $("#txtEntryTotalAmount").val(Total_Amount);
        $("#txtEntryTotalAmount").prop("disabled", true);

        $("#txtEntryAmountPaid").val(amount_paid);
        $("#txtEntryAmountPaid").prop("disabled", true);

        $("#txtEntryBalance").val(Balance);
        $("#txtEntryBalance").prop("disabled", true);

        $("#txtEntryApprovalDate").val(Entry_Date);
        $("#txtEntryApprovalDate").prop("disabled", true);

        $("#txtEntryNoOfInstallments").val(No_Of_Installments);

        if (Action == "View") {
            $("#txtEntryNoOfInstallments").prop("disabled", true);
            //GetIncentivesItem_Table(Action);
        } else {
            $("#txtEntryNoOfInstallments").prop("disabled", false);
        }

        GetItemTable(Action, GetIncentivesItem_Table);
        // $("#txtEntryNoOfInstallments").on("change", function () {
        //   GenerateIncentivesItem_Table(
        //     $("#txtEntryNoOfInstallments").val(),
        //     Total_Amount,
        //     amount_paid
        //   );
        // });
        $("#txtEntryNoOfInstallments").keypress(function (e) {
            GenerateIncentivesItem_Table(
                $("#txtEntryNoOfInstallments").val(),
                Total_Amount,
                amount_paid
            );
        });
    });
    return;
}

function GetInstallments() {
    GenerateIncentivesItem_Table(
        $("#txtEntryNoOfInstallments").val(),
        Total_Amount,
        amount_paid
    );
}
// Generate New Table with row_count = No_Of_Installments
function GenerateIncentivesItem_Table(
    NoOfInstallments,
    TotalAmount,
    AmountPaid
) {
    //var Action = $("#lblAction").html();
    //GetItemTable(Action,GetIncentivesItem_Table);

    $("#divIncentivesItemTable").show();
    var New_Total_Amount = TotalAmount; // - AmountPaid;

    // get rows where Is_Paid = 1
    // store in new array of arrays
    var PaidRows = [];
    var totaldeductedamt = 0.0;
    $("#tableIncentivesItem tbody tr").each(function () {
        var ddate = $(this).find("td:eq(1) div input").val();
        var damount = parseFloat($(this).find("td:eq(2) div input").val());
        var ispaid = $(this).find("td:eq(3) span").text();
        if (ispaid == 1) {
            var onerow = [ddate, damount, ispaid];
            PaidRows.push(onerow);
            totaldeductedamt += damount;
        }
    });
    if (PaidRows.length > 0) {
        New_Total_Amount = Total_Amount - totaldeductedamt;
    }
    Total_Rows = NoOfInstallments;
    NoOfInstallments -= PaidRows.length;
    index = 1;
    var Incentive_Amount = parseInt(
        parseFloat(New_Total_Amount) / parseFloat(NoOfInstallments)
    );
    var Last_Amount =
        Incentive_Amount +
        (parseFloat(New_Total_Amount) % parseFloat(NoOfInstallments));

    ClearDataTable("tableIncentivesItem");
    var TableHTML = "";
    var j;
    for (j = 0; j < PaidRows.length; j++) {
        TableHTML += "<tr>";

        TableHTML += "<td>" + index + "</td>";

        TableHTML += "<td>";
        TableHTML += "<div class='form-group'>";
        TableHTML +=
            "<input type='date' id='txtInstallmentDate" +
            index +
            "' value='" +
            PaidRows[j][0] +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
        TableHTML +=
            "<div class='invalid-feedback'>Incentive Date can't be blank.</div>";
        TableHTML += "</div>";
        TableHTML += "</td>";

        TableHTML += "<td>";
        TableHTML += "<div class='form-group'>";
        TableHTML +=
            "<input type='text' id='txtInstallmentAmount" +
            index +
            "' value='" +
            PaidRows[j][1] +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
        TableHTML +=
            "<div class='invalid-feedback'>Invalid Incentive Amount.</div>";
        TableHTML += "</div>";
        TableHTML += "</td>";

        TableHTML +=
            "<td><span hidden>" + PaidRows[j][2] + "</span>Paid<td>";
        TableHTML += "</tr>";

        index += 1;
    }
    /*
      if (PaidRows.length > 0) {
          // assign index to +1 most recent installment
          index = parseInt(PaidRows[PaidRows.length - 1][3]);
          index += 1;
      }*/
    //New_Installment_No = NoOfInstallments - Current_No_Of_Installments;

    var i;
    for (i = 0; i < NoOfInstallments; i++) {
        // last value
        if (i == NoOfInstallments - 1) {
            Incentive_Amount = Last_Amount;
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
            "<div class='invalid-feedback'>Incentive Date can't be blank.</div>";
        TableHTML += "</div>";
        TableHTML += "</td>";

        TableHTML += "<td>";
        TableHTML += "<div class='form-group'>";
        TableHTML +=
            "<input type='text' id='txtInstallmentAmount" +
            index +
            "' value='" +
            Incentive_Amount +
            "' class='form-control' onchange='ClearInvalidState(this);'>";
        TableHTML +=
            "<div class='invalid-feedback'>Invalid Incentive Amount.</div>";
        TableHTML += "</div>";
        TableHTML += "</td>";

        TableHTML += "<td><span hidden>0</span>Not Paid<td>";
        TableHTML += "</tr>";

        index += 1;
    }
    $("#tableEntryIncentivesItem").html(TableHTML);
    //SetDataTable("tableIncentivesItem", [1], "Incentives Item");

    // Disable Past Dates
    for (var k = 0; k < index; k++) {
        DisablePastDates("txtInstallmentDate" + k);
    }
    return;
}

// Get Incentives Item Table from database
function GetIncentivesItem_Table(Action) {
    $("#divIncentivesItemTable").show();
    ClearDataTable("tableIncentivesItem");
    var APIEndPoint = "GetIncentives";
    var Method_Name = "Get_One";
    var url = "/Manage/Incentives";
    var reqdata = {
        method_name: Method_Name,
        incentives_id: Incentives_Id,
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
                var Incentive_Status = "";

                $.each(res, function (data, value) {
                    disabled = "";
                    //checked = "";
                    Incentive_Status = "Not Paid";
                    if (value.is_deducted == 1) {
                        disabled = "disabled";
                        //checked = "checked";
                        Incentive_Status = "Paid";
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
                        value.incentive_date +
                        "' " +
                        disabled +
                        " onchange='ClearInvalidState(this); SetLaterDates(" +
                        (data + 1) +
                        ", " +
                        res.length +
                        ")'>";
                    TableHTML +=
                        "<div class='invalid-feedback'>Incentive Date can't be blank.</div>";
                    TableHTML += "</div>";
                    TableHTML += "</td>";

                    TableHTML += "<td>";
                    TableHTML += "<div class='form-group'>";
                    TableHTML +=
                        "<input type='text' id='txtInstallmentAmount" +
                        (data + 1) +
                        "' class='form-control' value='" +
                        value.incentive_amount +
                        "' " +
                        disabled;
                    TableHTML += " onkeyup='IsTotalAmount();' > ";
                    TableHTML +=
                        "<div class='invalid-feedback'>Invalid Incentive Amount.</div>";
                    TableHTML += "</div>";
                    TableHTML += "</td>";

                    TableHTML +=
                        "<td><span hidden>" +
                        value.is_deducted +
                        "</span>" +
                        Incentive_Status +
                        "</td>";

                    TableHTML += "</tr>";
                });
            } else {
                Current_No_Of_Installments = res.length;
            }

            $("#tableEntryIncentivesItem").html(TableHTML);
            //SetDataTable("tableIncentivesItem", [1], "Incentives Item");

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
    $("#btn_Save").prop("disabled", true);
    if (IsTotalAmount()) {
        Show_Error_Toastr(
            "Sum of Incentive Amounts should be equal to Total Amount."
        );
        $("#btn_Save").prop("disabled", false);
        return;
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
    var IncentiveTable = "<Incentive>";
    $("#tableIncentivesItem tbody tr").each(function () {
        var Is_Paid = 0;
        index = $(this).find("td:eq(0)").text();

        // set values of flag as 1 if checked
        Is_Paid = $(this).find("td:eq(3) span").text();
        var dt = $(this).find("td:eq(1) div input").val();
        if (dt == "") {
            $("#txtInstallmentDate" + index).addClass("is-invalid state-invalid");
            return;
        }
        amount_paid += parseFloat($(this).find("td:eq(2) input").val());

        // validate dates - no two dates can be same

        if (DD_Dates.includes($(this).find("td:eq(1) div input").val())) {
            IsValid = 0;
            return false;
        } else {
            DD_Dates.push($(this).find("td:eq(1) div input").val());
        }
        GetIncentivesItem_Table;
        IncentiveTable += "<IncentiveItem>";
        IncentiveTable += "<Index>" + $(this).find("td:eq(0)").text() + "</Index>";
        IncentiveTable +=
            "<IncentiveDate>" +
            $(this).find("td:eq(1) div input").val() +
            "</IncentiveDate>";
        IncentiveTable +=
            "<IncentiveAmount>" +
            $(this).find("td:eq(2) div input").val() +
            "</IncentiveAmount>";
        IncentiveTable += "<IsPaid>" + Is_Paid + "</IsPaid>";
        IncentiveTable += "</IncentiveItem>";
    });
    IncentiveTable += "</Incentive>";
    if (IsValid == 0) {
        Show_Error_Toastr("No two incentive dates can be same.");
        return;
    }

    var url = "/Manage/Incentives";
    var APIEndPoint = "SaveIncentives";
    var Method_Name = "Update";
    var Action = $("#lblAction").html();
    if (Action == "Add") {
        Method_Name = "Create";
    }

    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        incentives_id: Incentives_Id,
        no_of_installments: Installments,
        incentive_data: IncentiveTable,
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
                Show_Success_Toastr("Incentive details saved successfully");
                //ShowEditEntry("Edit", Incentives_Id, User_Id, User_Name, Installments, Total_Amount, amount_paid, Balance, Entry_Date);
            } else {
                ShowEntryError("Error : " + result[0].result_description);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Incentive details not saved");
        },
    });
    $("#btn_Save").prop("disabled", false);
}

// to check and make sure user doesn't invalid values in
function IsTotalAmount() {
    var temptotal = 0;
    $("#tableIncentivesItem tbody tr").each(function () {
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
    ShowContentDiv("Manage", "IncentivesAdd", "", function () {
        $("#ddlEntryUserType").select2();
        $("#ddlEntryUserName").select2();
        $("#ddlEntryRequestType").select2();
        $("#txtEntryAmount").val("");
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
        GetMaster("ddlEntryUserName", "Select User Name", "GetMCC", "", "");
    }
    if (UserType_Id == "Farmer") {
        GetMaster("ddlEntryUserName", "Select User Name", "GetFarmer", "", "");
    }
    if (UserType_Id == "Transporter") {
        GetMaster("ddlEntryUserName", "Select User Name", "GetTransporter", "", "");
    }
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
    GetMaster("ddlEntryRequestType", "Select Type", "GetIncentiveTypes", "", UserType_Id);
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
    var APIEndPoint = "SaveIncentives";
    var Method_Name = "Insert";

    var url = "/Manage/Incentives";
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
                GetIncentives(result[0].result_extra_key);
            } else {
                ShowEntryError("Error : " + result[0].result_description);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Incentives details not saved");
            $("#btn_Save").prop("disabled", false);
        },
    });
}

function GetIncentives(Incentives_Id) {
    var APIEndPoint = "GetIncentives";
    var Method_Name = "GetOne";
    var url = "/Manage/Incentives";
    var reqdata = {
        method_name: Method_Name,
        incentives_id: Incentives_Id,
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
                res[0].incentives_id,
                res[0].request_user_id,
                res[0].request_user_name,
                res[0].no_of_installments,
                res[0].total_amount,
                res[0].amount_paid,
                res[0].balance,
                res[0].entry_date
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

                var farmerIncentivesData = "<Incentives>";
                for (var i = 0; i < res_Json.length; i++) {
                    var farmerData = res_Json[i];

                    // Check if any of the required fields are null, blank, or undefined
                    if (
                        farmerData["Farmer Code"] &&
                        farmerData["Entry Date"] &&
                        farmerData["Amount"]
                    ) {
                        farmerIncentivesData += "<Farmer>";
                        farmerIncentivesData +=
                            "<MCC_Farmer_Code>" +
                            farmerData["Farmer Code"] +
                            "</MCC_Farmer_Code>";
                        farmerIncentivesData +=
                            "<EntryDate>" + farmerData["Entry Date"] + "</EntryDate>";
                        farmerIncentivesData +=
                            "<Amount>" + farmerData["Amount"] + "</Amount>";
                        farmerIncentivesData += "</Farmer>";
                    }
                }
                farmerIncentivesData += "</Incentives>";

                var MCC_Id = $("#ddlSearchMCC").val();

                var Method_Name = "ExcelUpload";
                var APIEndPoint = "SaveIncentive";
                var url_One = "/Manage/Incentives";
                var reqdata_one = {
                    method_name: Method_Name,
                    api_end_point: APIEndPoint,
                    username_id: MCC_Id,
                    usertype_id: "Farmer",
                    requesttype_id: "M020231000012",
                    incentive_data: farmerIncentivesData,
                    no_of_installments: "1",
                };

                // // console.log(reqdata);

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

                        SetDataTable("tableUploadFarmerEntryModal", [5], "Incentives");

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
                        Show_Error_Toastr("Error : Farmer incentives details not saved");
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
