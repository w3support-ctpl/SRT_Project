$(document).ready(function () {
    $("#ddlSearchApprovalStatus").select2();
    GetMaster("ddlSearchApprovalStatus", "Select Approval Status", "GetApprovedStatus", 0, "");

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

    // Get data from database and show in table
    $('#tableData').empty();

    var url = "/Approvals/DataCorrection";

    var APIEndPoint = "GetDataCorrection";
    var Method_Name = "Get";
    var Request_Date = $("#txtSearchRequestPeriod").val();
    var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

    var reqdata = {
        "method_name": Method_Name,
        "request_date": Request_Date,
        "approvalstatus_id": ApprovalStatus_Id,
        "api_end_point": APIEndPoint,
        "request_for": "Agent"
    };

    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
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
            var EditFlag = true;

            $.each(res, function (data, value) {
                var Approved_Status;
                EditFlag = false;
                if (value.is_approved == 1) {
                    Approved_Status = "Approved";
                }
                else if (value.is_approved == 0) {
                    Approved_Status = "Pending";
                    EditFlag = true;
                }
                else {
                    Approved_Status = "Rejected";
                }

                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.request_date + "</td>";
                TableHTML += "<td>" + value.request_type + "</td>";
                TableHTML += "<td>" + value.request_for_user_name + "</td>";
                TableHTML += "<td>" + value.mobile_no + "</td>";
                TableHTML += "<td>" + value.mcc_name + "</td>";
                TableHTML += "<td>" + Approved_Status + "</td>";

                if (EditFlag == true) {
                    TableHTML += "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowApproveEntry('Edit','" + value.request_id + "', '" + value.request_type + "')\">";
                    TableHTML += "<i class=\"fa fa-pencil\"></i>";
                    TableHTML += "</a>";
                    TableHTML += "</td>";
                }
                else {
                    TableHTML += "<td class='text-right' style='width: 100px; padding:8px 5px 8px 5px;'>";
                    TableHTML += "" + value.approved_on + "";
                    // View
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"View\" onclick=\"ShowApproveEntry('View','" + value.request_id + "', '" + value.request_type + "')\">";
                    TableHTML += "<i class=\"fa fa-eye\"></i>";

                    TableHTML += "</td>";
                }

                TableHTML += "</tr>";

            });

            $("#tableData").html(TableHTML);

            SetDataTable("tableSearch", [7], "Agent Data Correction");
            /*$("#btn_Search").prop('disabled', false);*/
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.");
            /*$("#btn_Search").prop('disabled', false);*/
        }
    });
}

function ShowApproveEntry(Action, Request_Id, _RequestType) {

    ShowContentDiv("Approvals", "AgentDataCorrectionEdit", "", function () {
        // Initialization Code
        RequestType = _RequestType;

        $("#btn_Save").hide();
        $("#ddlEntryApprovalStatus").select2();

        $("#lblEntryId").html(Request_Id);
        $("#lblAction").html("Edit");

        if (Action == "View") {
            $("#ddlEntryApprovalStatus").prop("disabled", true);
            $("#txtEntryRemark").prop("disabled", true);
            $("#txtEntryNewMobileNo").prop("disabled", true);
        }

        else if (Action == "Edit") {
            $("#ddlEntryApprovalStatus").prop("disabled", false);
            $("#txtEntryRemark").prop("disabled", false);
            $("#txtEntryNewMobileNo").prop("disabled", false);
        }


        $('#ddlEntryApprovalStatus').on("change", function () {
            var selectedValue = $(this).val();
            var selectedWord = "Yes, Reject it!";
            if (selectedValue == 0) {
                selectedWord = "Yes, Keep it Pending!";
            }


            if (selectedValue != "") {
                if (!(selectedValue == 1)) {
                    swal(
                        {
                            title: "Are you sure?",
                            text: "You won't be able to revert this!",
                            icon: "question",
                            type: "warning",
                            showCancelButton: true,
                            confirmButtonText: selectedWord,
                        },
                        function (result) {
                            if (result == true) {
                                GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", selectedValue, "");
                            }
                        }
                    );
                }
                if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
                    $("#btn_Save").show();
                } else {
                    $("#btn_Save").hide();
                }
            }
        });

        var APIEndPoint = "GetDataCorrection";
        var url = "/Approvals/DataCorrection";
        var reqdata = {
            "request_id": Request_Id,
            "method_name": "Get_One",
            "api_end_point": APIEndPoint,
            "request_for": "Agent"
        }
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);

                Agent_Id = res[0].request_for_user_id;

                GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", res[0].is_approved, "");
                $("#txtEntryRemark").val(res[0].approval_remarks);
                $("#txtEntryAgentName").val(res[0].request_for_user_name);
                $("#txtEntryMobileNo").val(res[0].mobile_no);
                GetMaster("ddlEntryMCCName", "Select MCC Name", "GetMCC", res[0].mcc_id, "");

                var reqdata = JSON.parse(res[0].request_data);

                // Assign values to requested data fields

                $("#txtEntryNewMobileNo").val(reqdata.mobile_no);

            },
            error: function () {
                Show_Error_Toastr("Error : Agent Data Correction details not found");
            }
        });
    });
}

function CloseEntry() {
    HideContentDiv();
    GetSearchList();
}

function SaveEntry() {
    // Validation code
    var Approval_Status = $('#ddlEntryApprovalStatus').val();
    var Approval_Remarks = $('#txtEntryRemark').val().trim();

    var New_Mobile_No = $('#txtEntryNewMobileNo').val().trim();

    var IsValid = 1;

    if (Approval_Status == "") {
        IsValid = 0;
        $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
    }

    if (New_Mobile_No == "" || Is_Valid_MobileNo(New_Mobile_No) == false) {
        IsValid = 0;
        $("#txtEntryNewMobileNo").addClass("is-invalid state-invalid");
    }


    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }

    // Start Saving
    $("#btn_Save").prop('disabled', true);

    // Save
    var APIEndPoint = "SaveDataCorrection";
    Request_Id = $("#lblEntryId").html();
    Method_Name = 'Update';

    var request_data_json = {
        "mobile_no": New_Mobile_No,
    }

    var request_data_string = JSON.stringify(request_data_json);

    var url = "/Approvals/DataCorrection";
    var reqdata = {
        "method_name": Method_Name,
        "api_end_point": APIEndPoint,
        "approvalstatus_id": Approval_Status,
        "approval_remarks": Approval_Remarks,
        "request_id": Request_Id,
        "request_type": RequestType,
        "request_data": request_data_string,
        "request_for_user_id": Agent_Id,
        "request_for": "Agent",
        "mobile_no": New_Mobile_No,
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
                // Show Success Message
                Show_Success_Toastr("Agent Data Correction " + result[0].result_description + " successfully.");
                CloseEntry();
            }
            else {
                ShowEntryError("Error : " + result[0].result_description);
            }
            $("#btn_Save").prop('disabled', false);
        },
        error: function () {
            Show_Error_Toastr("Error : Agent Data Correction details not saved");
            $("#btn_Save").prop('disabled', false);
        }
    });
}
