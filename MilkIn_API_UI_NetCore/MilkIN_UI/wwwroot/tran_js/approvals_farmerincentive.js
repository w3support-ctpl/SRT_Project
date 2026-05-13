$(document).ready(function () {
    $("#ddlSearchApprovalStatus").select2();

    GetMaster("ddlSearchApprovalStatus", "Select Approval Status", "GetApprovedStatus", 0, "");

    //SetDataTable("tableSearch", [6], "Farmer Incentive");

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
    $("#btn_Search").prop('disabled', true);
    // Get data from database and show in table

    var url = "/Approvals/FarmerIncentive";

    var APIEndPoint = "GetFarmerIncentive";
    var Method_Name = "Get";
    var Request_Date = $("#txtSearchRequestPeriod").val();
    var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

    var Status_Id = ApprovalStatus_Id;
    

    var reqdata = {
        "method_name": Method_Name,
        "request_date": Request_Date,
        "approvalstatus_id": Status_Id,
        "api_end_point": APIEndPoint,
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
            // var Row_No = 0;

            var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

            $.each(res, function (data, value) {
                var Approved_Status;
                // Row_No = Row_No + 1;
                if (value.is_approved == 1) {
                    Approved_Status = "Approved";
                }
                else if (value.is_approved == 0) {
                    Approved_Status = "Pending";
                }
                else {
                    Approved_Status = "Rejected";
                }

                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.request_date + "</td>";
                TableHTML += "<td>" + value.farmer_agent_name_request_for + "</td>";
                TableHTML += "<td>" + value.farmer_agent_mobile_request_for + "</td>";
                TableHTML += "<td>" + value.scheme_name + "</td>";
                TableHTML += "<td>" + Approved_Status + "</td>";
                if (EditFlag == true) {
                    if (value.is_approved != 1 && value.is_approved != -1) {
                        TableHTML += "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
                        TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowApproveEntry('" + value.request_id + "', '" + value.requestfor_id + "','" + value.farmer_agent_name_request_for + "', '" + value.scheme_name + "', '" + value.farmer_agent_mobile_request_for +"')\">";
                        TableHTML += "<i class=\"fa fa-pencil\"></i>";
                        TableHTML += "</a>";
                        TableHTML += "</td>";
                    }
                    else {
                        TableHTML += "<td class='text-right' style='width: 100px; padding:8px 5px 8px 5px;'>";
                        TableHTML += "" + value.approved_on + "";
                        TableHTML += "</td>";
                    }
                }
                TableHTML += "</tr>";

            });

            $("#tableData").html(TableHTML);

            SetDataTable("tableSearch", [6], "Farmer Incentive");
            $("#btn_Search").prop('disabled', false);
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.");
            $("#btn_Search").prop('disabled', false);
        }
    });
}

function ShowApproveEntry(Request_Id, _FarmerId, Farmer_Name, Scheme_Name, Mobile_No) {
    Farmer_Id = _FarmerId

    ShowContentDiv("Approvals", "FarmerIncentiveAdd", "", function () {
        // Initialization Code
        $("#btn_Save").hide();
        $("#ddlEntryApprovalStatus").select2();

        $("#lblEntryId").html(Request_Id);
        $("#lblAction").html("Edit");

        $("#txtEntryFarmerName").val(Farmer_Name);
        $("#txtEntrySchemeName").val(Scheme_Name);
        $("#txtEntryMobileNo").val(Mobile_No);

        $('#ddlEntryApprovalStatus').on("change", function () {
            var selectedValue = $(this).val();
            var selectedWord = "Yes, Reject it."; //$(this).children("option:selected").text();
            if (selectedValue == 0) {
                selectedWord = "Yes, Keep it Pending."
            }

            if (selectedValue != "") {
                if (!(selectedValue == 1)) {
                    swal({
                        title: "Are you sure?",
                        text: "You won't be able to revert this!",
                        icon: "question",
                        type: "warning",
                        showCancelButton: true,
                        confirmButtonText: selectedWord,
                    });
                }
                if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
                    $("#btn_Save").show();
                } else {
                    $("#btn_Save").hide();
                }
            }
        });



        var APIEndPoint = "GetFarmerIncentive";
        var url = "/Approvals/FarmerIncentive";
        var reqdata = {
            "request_id": Request_Id,
            "method_name": "Get_One",
            "api_end_point": APIEndPoint,
            "requestfor_id": Farmer_Id
        }
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);//.responseData);

                GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", res[0].is_approved, "");
                $("#txtEntryRemarks").val(res[0].approval_remarks);

            },
            error: function () {
                Show_Error_Toastr("Error : Farmer Incentive details not found");
            }
        });

    });
}

function CloseEntry() {
    GetSearchList();
    HideContentDiv();
}


function SaveEntry() {
    // Validation code
    var Approval_Status = $('#ddlEntryApprovalStatus').val();
    var Approval_Remarks = $('#txtEntryRemarks').val();

    var IsValid = 1;

    if (Approval_Status == "") {
        IsValid = 0;
        $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
    }

    if (Approval_Remarks == "") {
        IsValid = 0;
        $("#txtEntryRemarks").addClass("is-invalid state-invalid");
    }

    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }

    // Start Saving
    $("#btn_Save").prop('disabled', true);

    // Save
    var APIEndPoint = "SaveFarmerIncentive";
    var Method_Name = 'Create';
    var Request_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == 'Edit') {
        Method_Name = 'Update';
        Request_Id = $("#lblEntryId").html();
    }

    var url = "/Approvals/FarmerIncentive";
    var reqdata = {
        "method_name": Method_Name,
        "approvalstatus_id": Approval_Status,
        "approval_remarks": Approval_Remarks,
        "api_end_point": APIEndPoint,
        "request_id": Request_Id,
        "requestfor_id": Farmer_Id,
        "farmer_id": Farmer_Id
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
                Show_Success_Toastr("Farmer Incentive " + result[0].result_description);
                CloseEntry();

            } else {
                ShowEntryError("Error : " + result[0].result_description);
                $("#btn_Save").prop('disabled', false);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Farmer Incentive details not saved");
            $("#btn_Save").prop('disabled', false);
        }
    });
}

