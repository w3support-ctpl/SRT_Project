$(document).ready(function () {

    $("#ddlSearchSchemeStatus").select2();
    GetMaster("ddlSearchSchemeStatus", "Select Scheme Status", "GetSchemeStatus", "", "");

    $('input[name="datefilter"]').daterangepicker({
        locale: {
            cancelLabel: "Clear",
        },
        startDate: moment().subtract(30, 'days'), // Set the startDate to 30 days ago
        endDate: moment(), // Set the endDate to the current date
        ranges: {
            'Today': [moment(), moment()],
            'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            'Last 7 Days': [moment().subtract(6, 'days'), moment()],
            'Last 30 Days': [moment().subtract(29, 'days'), moment()],
            'This Month': [moment().startOf('month'), moment().endOf('month')],
            'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        }
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
    ClearDataTable("tableSearch");

    //Get data from database and show in table

    //Validate Data
    var APIEndPoint = "GetAgentIncentiveSchemes";
    var SearchIncentiveScheme_Period = $("#txtSearchIncentiveSchemePeriod").val();
    var SearchIncentiveStatus_Id = $("#ddlSearchSchemeStatus").val();
    if (SearchIncentiveScheme_Period == "") {
        $("#txtSearchIncentiveSchemePeriod").addClass("is-invalid state-invalid");
        Show_Error_Toastr("Please enter required values");
        return;
    }
    $("#btn_Search").prop('disabled', true);
    var Method_Name = 'Get';
    var url = "/Manage/AgentIncentiveSchemes";
    var reqdata = {
        "method_name": Method_Name,
        "scheme_period": SearchIncentiveScheme_Period,
        "incentivestatus_id": SearchIncentiveStatus_Id,
        "api_end_point": APIEndPoint
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            if (res.length == 0) {
                Show_Error_Toastr("Data not found.");
                return;
            }
            //Fill data in table
            var TableHTML = "";
            // var EditFlag = 1;

            $.each(res, function (data, value) {
                var Scheme_Status = "";

                if (value.is_completed == 1) {
                    Scheme_Status = "Completed";
                }
                else {
                    if (value.is_active == 0) {
                        Scheme_Status = "In-active";
                    }
                    else {
                        Scheme_Status = "Active";
                    }
                }
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.scheme_name + "</td>";
                TableHTML += "<td>" + value.scheme_duration + "</td>";
                TableHTML += "<td>" + value.incentivetype_name + "</td>";
                TableHTML += "<td>" + Scheme_Status + "</td>";
                TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Open\" "
                    + "onclick=\"ShowEditEntry('"
                    + value.incentivescheme_id + "', '"
                    + Scheme_Status + "')\">";
                TableHTML += "<i class=\"fa fa-eye\"></i>";
                TableHTML += "</a>";
                TableHTML += "</td>";
                TableHTML += "</tr>";

            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [5], "Agent Incentive Schemes");
            $("#btn_Search").prop('disabled', false);
        },
        error: function (res) {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            $("#btn_Search").prop('disabled', false);
        }
    });
    $("#btn_Search").prop('disabled', false);
    return;

}


function ShowEditEntry(IncentiveScheme_Id, Scheme_Status) {
    ShowContentDiv("Manage", "AgentIncentiveSchemesEdit", "", function () {
        $("#lblEntryId").text(IncentiveScheme_Id);
        $("#lblAction").text("Edit");

        $("#txtEntrySchemeId").text(IncentiveScheme_Id);

        var APIEndPoint = "GetAgentIncentiveSchemes";
        var Method_Name = 'Get_One';
        var url = "/Manage/AgentIncentiveSchemes";
        var reqdata = {
            "method_name": Method_Name,
            "incentivescheme_id": IncentiveScheme_Id,
            "api_end_point": APIEndPoint
        };
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result)[0];
                // assign values to input fields
                $("#txtEntrySchemeName").text(res.scheme_name);
                $("#txtEntrySchemeStartDate").text(res.from_date);
                $("#txtEntrySchemeEndDate").text(res.to_date);
                $("#txtEntrySchemeType").text(res.incentivetype_name);
                $("#txtEntrySchemeFrequency").text(res.incentivefrequency_name);
                $("#txtEntrySchemeStatus").text(res.scheme_status);


                IS_COMPLETED = res.is_completed;
                IS_ACTIVE = res.is_active;


                var today_date;
                today_date = new Date(Date.now());
                var to_date = new Date(res.to_date);
                if (to_date < today_date) {
                    $("#btn_Calc_Incentive").show();
                    $("#btn_Stop_Incentive").hide();
                }
                else {
                    if (res.is_active == 1) {
                        $("#btn_Calc_Incentive").hide();
                        $("#btn_Stop_Incentive").show();
                    }
                    else {
                        $("#btn_Calc_Incentive").hide();
                        $("#btn_Stop_Incentive").hide();
                    }

                }
                if (IS_ACTIVE == 0) {
                    $("#btn_Stop_Incentive").hide();
                }
                if (IS_COMPLETED == 1) {
                    $("#btn_Calc_Incentive").hide();
                    $("#btn_Stop_Incentive").hide();
                    $("#btn_Post_Incentive").hide();
                }
            },
            error: function (res) {
                Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
                $("#btn_Search").prop('disabled', false);
            }
        });



        // assign agent table
        Method_Name = 'Get_Agents';
        var reqdata = {
            "method_name": Method_Name,
            "incentivescheme_id": IncentiveScheme_Id,
            "api_end_point": APIEndPoint
        };
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);
                // assign values to input fields
                if (res.length == 0) {
                    ShowEntryError("No Agents eligible for this scheme.");
                    return;
                }
                var TableHTML = "";
                // var EditFlag = 1;

                $.each(res, function (data, value) {

                    TableHTML += "<tr>";
                    TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                    TableHTML += "<td hidden>" + value.agent_id + "</td>";
                    TableHTML += "<td>" + value.mcc_name + "</td>";
                    TableHTML += "<td>" + value.agent_name + "</td>";
                    TableHTML += "<td>" + value.eligibility + "</td>";
                    TableHTML += "<td hidden></td>";
                    TableHTML += "</tr>";

                });
                ClearDataTable("tableAgentList");
                $("#tableEntryAgentList").html(TableHTML);
                SetDataTable("tableAgentList", [5], "Agent List");

            },
            error: function (res) {
                Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            }
        });
    });
}


function StopIncentive() {
    var APIEndPoint = "SaveFarmerIncentiveSchemes";
    var Method_Name = 'Stop_Incentive';
    var IncentiveScheme_Id = $("#lblEntryId").html();
    var url = "/Manage/FarmerIncentiveSchemes";
    var reqdata = {
        "method_name": Method_Name,
        "incentivescheme_id": IncentiveScheme_Id,
        "api_end_point": APIEndPoint
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result)[0];
            if (res.result_id == 1) {
                // Show Success Message
                Show_Success_Toastr("Incentive Stopped successfully");
                $("#btn_Stop_Incentive").hide();
                $("#btn_Calc_Incentive").show();

            } else {
                ShowEntryError("Error : " + result[0].result_description);
            }

        },
        error: function (res) {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
        }
    });
}

function PostIncentive() {
    var APIEndPoint = "SaveFarmerIncentiveSchemes";
    var Method_Name = 'Post_Incentive';
    var IncentiveScheme_Id = $("#lblEntryId").html();
    var url = "/Manage/FarmerIncentiveSchemes";
    var reqdata = {
        "method_name": Method_Name,
        "incentivescheme_id": IncentiveScheme_Id,
        "api_end_point": APIEndPoint
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result)[0];
            if (res.result_id == 1) {
                // Show Success Message
                Show_Success_Toastr("Incentive Posted successfully");
                $("#btn_Post_Incentive").hide();
            } else {
                ShowEntryError("Error : " + result.result_description);
            }

        },
        error: function (res) {
            Show_Error_Toastr("Error in fetching details from server.", res.result_description);
        }
    });
}

function CalculateIncentive() {
    $("#btn_Calc_Incentive").hide();
    $("#btn_Post_Incentive").show();
}




function CloseEntry() {
    GetSearchList();
    HideContentDiv();
}
