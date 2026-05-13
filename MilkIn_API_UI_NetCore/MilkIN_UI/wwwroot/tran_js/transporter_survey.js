$(document).ready(function () {
    $("#txtSearchPeriod").daterangepicker();
    //GetSearchList();



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



});

function GetSearchList(e) {
    $("#btn_Search").prop('disabled', true);
    ClearDataTable("tableSearch");
    var url = "/Transporter/Survey";
    var Search_Period = $("#txtSearchPeriod").val();
    var Method_Name = "Get";
    var APIEndPoint = "GetSurvey";
    var reqdata = {
        "applicable_date": Search_Period,
        "method_name": Method_Name,
        "api_end_point": APIEndPoint,
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
                TableHTML += "<td>" + value.applicable_date + "</td>";
                TableHTML += "<td>" + value.chemist_name + "</td>";
                TableHTML += "<td>" + value.assign + "</td>";
                TableHTML += "<td>" + value.conducted + "</td>";
                TableHTML += "<td>" + Active_Status + "</td>";
                TableHTML += '<td class="text-right" style="width: 40px;">';

                if (value.is_locked == 1 || value.conducted == 1) {
                    //View
                    TableHTML +=
                        "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowEditEntry('" +
                        value.survey_id + "', 'View')\">";
                    TableHTML += '<i class="fa fa-eye"></i>';
                    TableHTML += "</a>";
                }
                else {
                    // Edit
                    TableHTML +=
                        "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowEditEntry('" +
                        value.survey_id + "', 'Edit')\">";
                    TableHTML += '<i class="fa fa-pencil"></i>';
                    TableHTML += "</a>";

                    // Delete
                    TableHTML +=
                        "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"ShowDeleteEntry('" +
                        value.survey_id + "')\">";
                    TableHTML += '<i class="fa fa-trash"></i>';
                    TableHTML += "</a>";
                }

                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);

            SetDataTable("tableSearch", [3], "Survey");
            $("#btn_Search").prop('disabled', false);
        },
        error: function () {
             $("#btn_Search").prop('disabled', false);
        },
    });
}

// Get data from database and show in table

function ShowAddEntry() {
    ShowContentDiv("Transporter", "SurveyAdd", "", function () {
        // Initialization Code
        $("#lblEntryId").html("");
        $("#lblAction").html("Add");
        $("#divFooterActions").hide();
        $("#ddlEntryChemist").select2();
        GetMaster("ddlEntryChemist", "Select Chemist", "GetRouteChemist", "", "");
        SetDate();


        Survey_Id = "";
        // Get MCC Table(All MCC)
        GetMCCList(Survey_Id, "Add");
        // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
    });
}

function ShowEditEntry(Survey_Id, Action) {
    ShowContentDiv("Transporter", "SurveyEdit", "", function () {
        // Initialization Code
        $("#lblEntryId").html(Survey_Id);
        $("#lblAction").html(Action);
        $("#divFooterActions").show();
        $("#ddlEntryChemist").select2();
        // SetDate();
        $("#txtEntryDate").prop("disabled", true);


        if (Action == "View") {
            $("#txtEntryDate").prop("disabled", true);
            $("#ddlEntryChemist").prop("disabled", true);
            $("#chkEntryStatus").prop("disabled", true);

        }


        var APIEndPoint = "GetSurvey";
        var url = "/Transporter/Survey";
        var Method_Name = "Get_One";
        var reqdata = {
            survey_id: Survey_Id,
            method_name: Method_Name,
            api_end_point: APIEndPoint,
        };
        $.ajax({
            type: "POST",
            url: url,
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            data: reqdata,
            success: function (result) {
                const res = JSON.parse(result);
                $("#txtEntryDate").val(res[0].applicable_date);
                GetMaster("ddlEntryChemist", "Select Chemist", "GetRouteChemist", res[0].chemist_id, "");

                if (res[0].is_active == "0") {
                    $("#chkEntryStatus").prop("checked", false);
                } else {
                    $("#chkEntryStatus").prop("checked", true);
                }

                // lock editing for past dates
                if (res[0].is_locked == 1) {
                    $("#txtEntryDate").prop("disabled", true);
                    $("#ddlEntryChemist").prop("disabled", true);
                    $("#chkEntryStatus").prop("disabled", true);
                    Action = "View";
                }

                // Get MCC List
                GetMCCList(Survey_Id, Action);

            },
            error: function () {
                ShowEntryError("Error : Survey details not found");
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
    var Applicable_Date = $("#txtEntryDate").val();
    var Chemist_Id = $("#ddlEntryChemist").val();
    var IsValid = 1;

    if (Applicable_Date == "") {
        IsValid = 0;
        $("#txtEntryDate").addClass("is-invalid state-invalid");
    }

    if (Chemist_Id == "") {
        IsValid = 0;
        $("#ddlEntryChemist").addClass("is-invalid state-invalid");
    }

    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }

    // Start Saving
    $("#btn_Save").prop("disabled", true);

    // Save
    var Method_Name = "Create";
    var APIEndPoint = "SaveSurvey";
    var Survey_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
        Method_Name = "Update";
        Survey_Id = $("#lblEntryId").html();
    }
    
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
        Is_Active = 1;
    }
    var Is_Deleted = 0;

    var selectedCheckboxes = $("#tableEntry").find(
        "tbody input[type='checkbox']:checked"
    );
    var MCC_Id = [];

    selectedCheckboxes.each(function () {
        var checkboxId = $(this).val();
        MCC_Id.push(checkboxId);
    });

    var Assign = MCC_Id.length;





    var url = "/Transporter/Survey";
    var reqdata = {
        survey_id: Survey_Id,
        applicable_date: Applicable_Date,
        chemist_id: Chemist_Id,
        is_active: Is_Active,
        is_deleted: Is_Deleted,
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        mcc_id: MCC_Id.join(","),
        assign: Assign
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
                ShowEntrySuccess("Survey details saved successfully!");
                $("#lblEntryId").html(result[0].result_extra_key);
                $("#lblAction").html("Edit");
                $("#divFooterActions").show();
                $("#btn_Save").prop("disabled", false);
            } else {
                ShowEntryError("Error : " + result[0].result_description);
                $("#btn_Save").prop("disabled", false);
            }
        },
        error: function () {
            ShowEntryError("Error : Survey details not saved");
            $("#btn_Save").prop("disabled", false);
        },
    });
}

function ShowDeleteEntry(Survey_Id) {
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
                SaveDeleteEntry(Survey_Id);
            }
        }
    );
}

function SaveDeleteEntry(Survey_Id) {
    // Write code to delete
    if (Survey_Id == "") {
        Survey_Id = $("#lblEntryId").html();
    }
    var APIEndPoint = "SaveSurvey";
    var url = "/Transporter/Survey";
    var reqdata = {
        survey_id: Survey_Id,
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
                Show_Success_Toastr("Survey details deleted successfully");
                CloseEntry();
            } else {
                Show_Error_Toastr("Error : " + result[0].result_description);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Survey details not deleted");
        },
    });
}



function SetDate() {
    // Setting Date Text Box value depending on the provided date from database

    var url = "/Transporter/Survey";
    var Method_Name = "Get_Date";
    var APIEndPoint = "GetSurvey";
    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            latest_date = res[0].applicable_date;
            var date = new Date().toISOString().slice(0, 10);
            if (latest_date > date) {
                date = latest_date;
                next_date = new Date(date);
                newdate = next_date.toISOString().slice(0, 10);
            }
            else if (latest_date == date) {
                next_date = new Date(date);
                next_date.setDate(next_date.getDate() + 1);
                newdate = next_date.toISOString().slice(0, 10);
            }
            else {
                next_date = new Date(date);
                newdate = next_date.toISOString().slice(0, 10);
            }

            /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

            $('#txtEntryDate').attr('min', newdate);
            $("#txtEntryDate").val(newdate);
            

           /*
            $('#txtEntryDate').attr('min', date);
            $("#txtEntryDate").val(date);
            */

        },
        error: function () {
        },
    });

}


function GetMCCList(Survey_Id, Action) {
    ClearDataTable("tableEntry");
    var url = "/Transporter/Survey";
    var Method_Name = "Get_MCCList";
    var APIEndPoint = "GetSurvey";
    var reqdata = {
        "survey_id": Survey_Id,
        "method_name": Method_Name,
        "api_end_point": APIEndPoint,
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

            //var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
            var checked = "";
            var disabled = "";
            var hidden = ""
            if (Action == "View") {
                disabled = "disabled";
                
            }
            $.each(res, function (data, value) {
                if (value.is_locked == 1) {
                    checked = "checked";
                    hidden = "";
                }
                else {
                    checked = "";
                    hidden = "";
                    if (Action == "View") {
                        hidden = "hidden";
                    }
                }
                TableHTML += '<tr '+ hidden +'>';
                TableHTML += '<td style="width: 20px;" >';
                TableHTML += '<label class="custom-control custom-checkbox ">';
                TableHTML +=
                    '<input type="checkbox" class="custom-control-input" value="' +
                    value.mcc_id +
                    '"';
                TableHTML += 'style="vertical-align:sub; text-align: center;" ' + checked + ' ' + disabled + '>';
                TableHTML +=
                    '<span class="custom-control-label text-dark"></span></label></td>';
                TableHTML += "<td>" + value.mcc_code + "</td>";
                TableHTML += "<td>" + value.mcc_name + "</td>";
                TableHTML += "<td>" + value.taluka_name + "</td>";
                TableHTML += "<td>" + value.village_name + "</td>";
                TableHTML += "<td hidden></td>";
                
            });

            $("#tableEntryData").html(TableHTML);
            // SetDataTable("tableEntry", [5], "Assigned MCC");
        },
        error: function () {
            Show_Error_Toastr("Error: MCC List couldn't be loaded");
        },
    });
}