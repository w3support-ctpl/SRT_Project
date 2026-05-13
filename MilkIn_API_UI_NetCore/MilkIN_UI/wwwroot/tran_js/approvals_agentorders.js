$(document).ready(function () {
    $("#ddlSearchApprovalStatus").select2();

    GetMaster("ddlSearchApprovalStatus", "Select Approval Status", "GetApprovedStatus", 0, "");

    //SetDataTable("tableSearch", [6], "Agent Orders");

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

    var url = "/Approvals/AgentOrder";
    var APIEndPoint = "GetAgentOrder";
    var Method_Name = "Get";
    var Order_Date = $("#txtSearchRequestPeriod").val();
    var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

    var Status_Id = ApprovalStatus_Id;


    var reqdata = {
        "method_name": Method_Name,
        "order_date": Order_Date,
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
            var EditFlag = true;

            $.each(res, function (data, value) {
                var Approved_Status;
                if (value.is_approved == 1) {
                    Approved_Status = "Approved";
                    EditFlag = false;
                }
                else if (value.is_approved == 0) {
                    Approved_Status = "Pending";
                    EditFlag = true;
                }
                else {
                    Approved_Status = "Rejected";
                    EditFlag = false;
                }

                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.order_date + "</td>";
                TableHTML += "<td>" + value.farmer_agent_name_order_for + "</td>";
                TableHTML += "<td>" + value.mobile_no_order_for + "</td>";
                TableHTML += "<td>" + value.total_item + "</td>";
                TableHTML += "<td>" + Approved_Status + "</td>";
                if (EditFlag == true) {
                    TableHTML += "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" ";
                    TableHTML += "onclick =\"ShowApproveEntry('" + value.order_id + "', '" + value.orderfor_id + "', '"
                                    + value.farmer_agent_name_order_for + "', '" + value.mobile_no_order_for + "')\">";
                    TableHTML += "<i class=\"fa fa-pencil\"></i>";
                    TableHTML += "</a>";
                    TableHTML += "</td>";
                }
                else {
                    TableHTML += "<td class='text-right' style='width: 100px; padding:8px 5px 8px 5px;'>";
                    TableHTML += "" + value.approved_on + "";
                    TableHTML += "</td>";
                }
                TableHTML += "</tr>";

            });

            $("#tableData").html(TableHTML);

            SetDataTable("tableSearch", [6], "Agent Orders");
            $("#btn_Search").prop('disabled', false);
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.");
            $("#btn_Search").prop('disabled', false);
        }
    });
    $("#btn_Search").prop('disabled', false);

}

function ShowApproveEntry(Order_Id, _OrderForId, Agent_Name, Mobile_No) {
    OrderFor_Id = _OrderForId;
    ShowContentDiv("Approvals", "AgentOrdersAdd", "", function () {
        // Initialization Code
        $("#btn_Save").hide();
        $("#ddlEntryApprovalStatus").select2();

        $("#lblEntryId").html(Order_Id);
        $("#lblAction").html("Edit");

        $("#txtEntryAgentName").val(Agent_Name);
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

        var APIEndPoint = "GetAgentOrder";
        var url = "/Approvals/AgentOrder";
        var reqdata = {
            "order_id": Order_Id,
            "method_name": "Get_One",
            "api_end_point": APIEndPoint,
        }
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);

                GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", res[0].is_approved, "");
                $("#txtEntryRemarks").val(res[0].approval_remarks);
            },
            error: function () {
                Show_Error_Toastr("Error : Agent Order details not found");
            }
        });

        // Get Order Table

        var APIEndPoint = "GetAgentOrder";
        var url = "/Approvals/AgentOrder";
        var reqdata = {
            "order_id": Order_Id,
            "method_name": "Get_Orders",
            "api_end_point": APIEndPoint,
        }
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);
                // get table and bind it with table
                var TableHTML = "";
                $.each(res, function (data, value) {

                    TableHTML += "<tr>";
                    TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                    TableHTML += "<td hidden>" + value.product_id + "</td>";
                    TableHTML += "<td>" + value.product_name + "</td>";
                    TableHTML += "<td> <input type='number' class='form-control' maxlength='10' autocomplete='off'";
                    TableHTML += 'disabled value=\'' + value.quantity + '\'></td>';
                    TableHTML += "<td> <input type='number' class='form-control' maxlength='10' autocomplete='off'";
                    TableHTML += 'value=' + value.approved_quantity + '></td>';
                    TableHTML += "<td hidden>" + value.rate + "</td>";
                    TableHTML += "<td hidden></td>";
                    TableHTML += "</tr>";
                });
                ClearDataTable("tableOrderEntry");
                $("#tableOrderData").html(TableHTML);
                SetDataTable("tableOrderEntry", [6], "Agent Orders");


            },
            error: function () {
                Show_Error_Toastr("Error : Agent Order details not found");
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
    var Approval_Remarks = $('#txtEntryRemarks').val();

    // check atleast one quantity to be greater than 0 if Approving
    if (ApprovalStatus_Id == 1) {
        var quantity_sum = 0;
        $("#tableOrderEntry tbody tr").each(function () {
            quantity_sum += parseInt($(this).find("td:eq(4) input").val());
        });
        if (quantity_sum == 0) {
            ShowEntryError("Can't approve. The sum of Approved Quantity values must be greater than 0.");
            return;
        }
    }


    var IsValid = 1;

    if (ApprovalStatus_Id == "") {
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

    OrderDetails = "<Products>";
    $("#tableOrderEntry tbody tr").each(function () {
        OrderDetails += "<ProductItem>";
        OrderDetails += "<Product_Id>" + $(this).find("td:eq(1)").text() + "</Product_Id>";
        OrderDetails += "<Product_Name>" + $(this).find("td:eq(2)").text() + "</Product_Name>";
        OrderDetails += "<Quantity>" + $(this).find("td:eq(3) input").val() + "</Quantity>";
        OrderDetails += "<Approved_Quantity>" + $(this).find("td:eq(4) input").val() + "</Approved_Quantity>";
        OrderDetails += "<Rate>" + $(this).find("td:eq(4)").text() + "</Rate>";
        OrderDetails += "</ProductItem>";
    });
    OrderDetails += "</Products>";



    // Start Saving
    $("#btn_Save").prop('disabled', true);

    // Save
    var APIEndPoint = "SaveAgentOrder";
    var Order_Id = $("#lblEntryId").html();
    var Method_Name = 'Update';

    var url = "/Approvals/AgentOrder";
    var reqdata = {
        "method_name": Method_Name,
        "approvalstatus_id": ApprovalStatus_Id,
        "approval_remarks": Approval_Remarks,
        "api_end_point": APIEndPoint,
        "order_id": Order_Id,
        "order_data": OrderDetails,
        "orderfor_id": OrderFor_Id
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
                Show_Success_Toastr("Agent Order " + result[0].result_description);
                CloseEntry();

            } else {
                Show_Error_Toastr("Error : " + result[0].result_description);
                $("#btn_Save").prop('disabled', false);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Agent Order details not saved");
            $("#btn_Save").prop('disabled', false);
        }
    });
}

