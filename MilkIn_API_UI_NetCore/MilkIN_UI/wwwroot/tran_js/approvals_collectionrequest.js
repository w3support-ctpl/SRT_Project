$(document).ready(function () {
    $("#ddlSearchApprovalStatus").select2();

    GetMaster("ddlSearchApprovalStatus", "Select Approval Status", "GetApprovedStatus", 0, "");

    //SetDataTable("tableSearch", [6], "CollectionRequest");

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

    var url = "/Approvals/CollectionRequest";

    var APIEndPoint = "GetCollectionRequest";
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
            var Row_No = 0;

            var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

            $.each(res, function (data, value) {
                var Approved_Status;
                Row_No = Row_No + 1;
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
                TableHTML += "<td style='width: 20px;'>" + (data+1) + "</td>";
                TableHTML += "<td>" + value.created_on + "</td>";
                TableHTML += "<td>" + value.shiftend_time + "</td>"; 
                TableHTML += "<td>" + value.mcc_name + "</td>";
                TableHTML += "<td>" + value.requesttype_name + "</td>";
                TableHTML += "<td>" + value.request_details + "</td>";
                TableHTML += "<td>" + value.request_remarks + "</td>";
                TableHTML += "<td>" + Approved_Status + "</td>";

                if (EditFlag == true) {
                    if (value.is_approved != 1 && value.is_approved != -1) {
                        TableHTML += "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
                        TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowApproveEntry('" + value.collectionrequest_id + "')\">";
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

            SetDataTable("tableSearch", [8], "Collection Request");
            /*$("#btn_Search").prop('disabled', false);*/
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.");
            /*$("#btn_Search").prop('disabled', false);*/
        }
    });
}

function ShowApproveEntry(CollectionRequest_Id) {
    ShowContentDiv("Approvals", "CollectionRequestAdd", "", function () {
        // Initialization Code
        $("#btn_Save").hide();
        $("#ddlEntryApprovalStatus").select2();
        $("#ddlEntryMCC").select2();
        $("#ddlEntryRequestType").select2();
        // $("#divExpectedTime").hide();

        $("#lblEntryId").html(CollectionRequest_Id);
        $("#lblAction").html("Edit");

        $('#ddlEntryApprovalStatus').on("change", function () {
            var selectedValue = $(this).val();
            var selectedWord = $(this).children("option:selected").text();

            if (selectedValue != "") {
                if (!(selectedValue == 1)) {
                    swal({
                        title: "Are you sure?",
                        text: "You won't be able to revert this!",
                        icon: "question",
                        type: "warning",
                        showCancelButton: true,
                        confirmButtonText: "Yes, " + selectedWord + " it!",
                    });
                }
                if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
                    $("#btn_Save").show();
                } else {
                    $("#btn_Save").hide();
                }
            }
        });

        var APIEndPoint = "GetCollectionRequest";
        var url = "/Approvals/CollectionRequest";
        var reqdata = {
            "collectionrequest_id": CollectionRequest_Id,
            "method_name": "Get_One",
            "api_end_point": APIEndPoint,
        }
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);//.responseData);
                if (res[0].requesttype_id == "C038003") {
                    //$("#divExpectedTime").show();

                }
                CreatedBy_Id = res[0].createdby_id;
                CollectionShift_Id = res[0].mcccollectionshift_id;

                GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", res[0].is_approved, "");
                GetMaster("ddlEntryMCC", "Select MCC Name", "GetMCC", res[0].mcc_id, "");
                GetMaster("ddlEntryRequestType", "Select Request Type", "GetRequestType", res[0].requesttype_id, "");
                $("#txtEntryRequestRemark").val(res[0].request_remarks);

                RequestType = res[0].requesttype_id;


                if (res[0].requesttype_id == "C038003") {
                    $("#divExtraTime").show();
                    $("#txtEntryRequestDetails").val(res[0].request_details);
                    $("#txtEntryOriginalTime").val(res[0].shiftend_time);
                    expected_time = CalculateTime(res[0].shiftend_time, res[0].request_details);
                    $("#txtEntryExpectedTime").val(expected_time);
                    
                }
                else {
                    $("#divExtraTime").hide();
                }
                
            },
            error: function () {
                Show_Error_Toastr("Error : Collection Request details not found");
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
    var ApprovalStatus_Id = $('#ddlEntryApprovalStatus').val();
    var MCC_Id = $('#ddlEntryMCC').val();
    var RequestType_Id = $('#ddlEntryRequestType').val();
    var Request_Details = $('#txtEntryRequestDetails').val();
    var Expected_Time = $('#txtEntryExpectedTime').val();
    var Request_Remark = $('#txtEntryRequestRemark').val();

    var IsValid = 1;

    if (ApprovalStatus_Id == "") {
        IsValid = 0;
        $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
    }

    if (MCC_Id == "") {
        IsValid = 0;
        $("#ddlEntryMCC").addClass("is-invalid state-invalid");
    }

    if (RequestType == "C038003" && Expected_Time == "") {
        IsValid = 0;
        $("#txtEntryExpectedTime").addClass("is-invalid state-invalid");
    }
    if (RequestType == "C038003" && Is_Valid_Time(Expected_Time) == false) {
        IsValid = 0;
        $("#txtEntryExpectedTime").addClass("is-invalid state-invalid");
    }
    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }

    // Start Saving
    $("#btn_Save").prop('disabled', true);

    // Save
    var APIEndPoint = "SaveCollectionRequest";
    var Method_Name = 'Create';
    var CollectionRequest_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == 'Edit') {
        Method_Name = 'Update';
        CollectionRequest_Id = $("#lblEntryId").html();
    }

    var url = "/Approvals/CollectionRequest";
    var reqdata = {
        "method_name": Method_Name,
        "api_end_point": APIEndPoint,
        "collectionrequest_id": CollectionRequest_Id,
        "approvalstatus_id": ApprovalStatus_Id,
        "mcc_id": MCC_Id,
        "requesttype_id": RequestType_Id,
        "expected_time": Expected_Time,
        "agent_id": CreatedBy_Id,
        "mcccollectionshift_id": CollectionShift_Id
        
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
                Show_Success_Toastr("Collection Request " + result[0].result_description);
                CloseEntry();

            } else {
                ShowEntryError("Error : " + result[0].result_description);
                $("#btn_Save").prop('disabled', false);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Collection Request details not saved");
            $("#btn_Save").prop('disabled', false);
        }
    });
}


function CalculateTime(originaltime, addminutes) {
    addminutes = parseInt(addminutes);
    // originaltime = originaltime;
    var hr = parseInt(originaltime.substring(0, 2));
    var min = parseInt(originaltime.substring(3, 5));
    var dt = new Date();
    // hour, minute, second, milisecond
    dt.setHours(hr, min, 0, 0);
    dt.setMinutes(dt.getMinutes() + addminutes);

    var hrs = "" + dt.getHours() + "";
    if (hrs.length == 1) {
        hrs = "0" + hrs;
    }
    else if (hrs.length == 0) {
        hrs = "00";
    }

    var mins = "" + dt.getMinutes() + "";
    if (mins.length == 1) {
        mins = "0" + mins;
    }
    else if (mins.length == 1) {
        mins = "00";
    }

    var updatedtime = hrs + ":" + mins;
    return updatedtime;
}

// submitted time should not be less than current time
function Is_Valid_Time(newtime) {
    var current_dt = new Date(Date.now());
    var given_dt = new Date(Date.now());
    var hr = parseInt(newtime.substring(0, 2));
    var min = parseInt(newtime.substring(3, 5));
    given_dt.setHours(hr, min, 0, 0);
    return current_dt < given_dt;
}

