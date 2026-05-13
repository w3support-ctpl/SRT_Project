$(document).ready(function () {

    $("#ddlSearchMCCName").select2();
    GetMaster("ddlSearchMCCName", "Select MCC Name", "GetMCC", "", "");

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
    var APIEndPoint = "GetMaterialReturnFromMCC";
    var Method_Name = "Get";
    var url = "/Manage/MaterialReturnFromMCC";
    var Search_MCC_Id = "%" + $("#ddlSearchMCCName").val() + "%";
    var Search_Date = $("#txtSearchReturnPeriod").val();
    var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

    if (ApprovalStatus_Id == "") {
        Show_Error_Toastr("Approval Status can't be blank");
        return;
    }

    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        search_mcc_id: Search_MCC_Id,
        search_period: Search_Date,
        approvalstatus_id: ApprovalStatus_Id
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            var EditFlag = 1;
            var TableHTML = "";

            $.each(res, function (data, value) {
                EditFlag = value.is_dairy_accepted;
                var Active_Status;
                if (value.is_dairy_accepted == 0) {
                    Active_Status = "Pending";
                }
                else if (value.is_dairy_accepted == 1) {
                    Active_Status = "Approved";
                }
                else {
                    Active_Status = "Rejected";
                }
                TableHTML += "<tr>";
                TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.dispatched_on + "</td>";
                TableHTML += "<td>" + value.dispatchstock_id + "</td>";
                TableHTML += "<td>" + value.mcc_name + "</td>";
                TableHTML += "<td>" + value.total_quantity + "</td>";
                TableHTML += "<td>" + Active_Status + "</td>";
                TableHTML += "<td class='text-right'>";
                if (EditFlag == 0) {
                    TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick=\'ShowEditEntry("Edit", "'
                        + value.dispatchstock_id + '","' + value.dispatched_on + '","'
                        + value.mcc_name + '","'
                        + value.agent_name + '","' + value.mobile_no + '","'
                        + value.total_quantity + '","' + value.is_dairy_accepted + '")\'>';
                    TableHTML += '<i class="fa fa-pencil"></i>';
                    TableHTML += "</a>";
                }
                else {
                    TableHTML += value.approved_on;
                    /*
                    TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick=\'ShowEditEntry("View", "'
                        + value.dispatchstock_id + '","' + value.dispatched_on + '","'
                        + value.mcc_name + '","'
                        + value.agent_name + '","' + value.mobile_no + '","'
                        + value.total_quantity + '","' + value.is_dairy_accepted + '")\'>';
                    TableHTML += '<i class="fa fa-eye"></i>';
                    TableHTML += "</a>";*/
                }

                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [6], "Material Return from MCC");
        },
        error: function () {
            Show_Error_Toastr("Error in fetching Material Issue From MCC details.");
        },
    });

}

/*
function ShowAddEntry() {
    ShowContentDiv("Manage", "MaterialIssueToMCCAdd", "", function () {


        $("#lblEntryId").html("");
        $("#lblAction").html("Add");
        $("#txtEntryDeliveryDate").val(new Date().toDateInputValue());

        // Initialization Code
        $("#ddlEntryMCCName").select2();
        $("#ddlEntryVehicleNo").select2();
        $("#ddlEntryDriverId").select2();

        GetMaster("ddlEntryMCCName", "Select MCC Name", "GetMCC", "", "");
        GetMaster("ddlEntryVehicleNo", "Select Vehicle No", "GetVehicle", "", "");
        GetMaster("ddlEntryDriverId", "Select Driver", "GetDriver", "", "");

        // Add OTHER option to the dropdown lists
        $('#ddlEntryVehicleNo').append($('<option></option>').val('other').html('Other'));
        $('#ddlEntryDriverId').append($('<option></option>').val('other').html('Other'));

        // show text boxes if OTHER is selected
        $("#ddlEntryVehicleNo").on("change", function () {
            if ($("#ddlEntryVehicleNo").find(":selected").val() == "other") {
                $("#divEntryVehicleNo").show();
            } else {
                $("#divEntryVehicleNo").hide();
                $("#txtEntryVehicleNo").val($("#ddlEntryVehicleNo").find(":selected").html());
            }
        });

        // show text boxes if OTHER is selected
        $("#ddlEntryDriverId").on("change", function () {
            if ($("#ddlEntryDriverId").find(":selected").val() == "other") {
                $("#divEntryDriverName").show();
            } else {
                $("#divEntryDriverName").hide();
                $("#txtEntryDriverName").val($("#ddlEntryDriverId").find(":selected").html());

            }
        });

    });
}
*/

function ShowEditEntry(
    Action, DispatchStock_Id, Dispatched_On, MCC_Name,
    Agent_Name, Mobile_No, Total_Quantity, ApprovalStatus_Id) {
    ShowContentDiv("Manage", "MaterialReturnFromMCCEdit", "", function () {
        // Initialization Code

        $("#txtEntryReturnNo").prop("disabled", true);
        $("#txtEntryReturnDate").prop("disabled", true);
        $("#txtEntryMCCName").prop("disabled", true);
        $("#txtEntryAgentName").prop("disabled", true);
        $("#txtEntryMobileNo").prop("disabled", true);
        $("#txtEntryNoOfItems").prop("disabled", true);


        $("#txtEntryReturnNo").val(DispatchStock_Id);

        $("#lblEntryId").html(DispatchStock_Id);
        $("#lblAction").html(Action);

        $("#txtEntryReturnDate").val(Dispatched_On);
        $("#txtEntryMCCName").val(MCC_Name);
        $("#txtEntryAgentName").val(Agent_Name);
        $("#txtEntryMobileNo").val(Mobile_No);
        $("#txtEntryNoOfItems").val(Total_Quantity);

        $("#ddlEntryApprovalStatus").select2();
        GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", ApprovalStatus_Id, "");

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




        // Extract Material list from database
        var APIEndPoint = "GetMaterialReturnFromMCC";
        var Method_Name = "Get_One";
        var disabled = "";
        if (Action == "View") {
            disabled = "disabled";
            $("#btn_Save").prop("hidden", true);
        }
        var url = "/Manage/MaterialReturnFromMCC";
        var reqdata = {
            method_name: Method_Name,
            dispatchstock_id: DispatchStock_Id,
            api_end_point: APIEndPoint,
        };
        $.ajax({
            type: "POST",
            url: url,
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);
                ClearDataTable("tableMaterialList");
                var TableHTML = "";
                $.each(res, function (data, value) {
                    TableHTML += "<tr>";

                    TableHTML += '<td>' + (data + 1) + '</td>';
                    TableHTML += '<td>' + value.material_name + '</td>';
                    TableHTML += '<td>' + value.stock_type + '</td>';
                    TableHTML += "<td>" + value.dispatched_quantity + "</td>";
                    TableHTML += "<td hidden></td>";

                    TableHTML += "</tr>";


                });
                ClearDataTable("tableMaterialList");
                $("#tableEntryMaterialList").append(TableHTML);
                SetDataTable("tableMaterialList", [4], "Returned Material List");
            },
            error: function () {
                Show_Error_Toastr("Error in fetching details from server.");
            },
        });




    });
}

function CloseEntry() {
    GetSearchList();
    HideContentDiv();
}

function SaveEntry() {
    $("#btn_Save").prop('disabled', true);

    var ApprovalStatus_Id = $('#ddlEntryApprovalStatus').val();
    var Approval_Remarks = $('#txtEntryRemarks').val().trim();
    $('#txtEntryRemarks').val(Approval_Remarks);

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
    // Save
    var APIEndPoint = "SaveMaterialReturnFromMCC";
    var DispatchStock_Id = $("#lblEntryId").html();
    var Method_Name = 'Update';

    var url = "/Manage/MaterialReturnFromMCC";
    var reqdata = {
        "method_name": Method_Name,
        "approvalstatus_id": ApprovalStatus_Id,
        "approval_remarks": Approval_Remarks,
        "api_end_point": APIEndPoint,
        "dispatchstock_id": DispatchStock_Id
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
                Show_Success_Toastr("Material Return From MCC " + result[0].result_description);
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


    $("#btn_Save").prop('disabled', true);
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

function SaveDeleteEntry() {
    // Write code to delete
    //var Agent_Id = $("#lblEntryId").html();
    //var Is_Deleted = 1;

    //var APIEndPoint = "SaveAgent";
    //var url = "/Users/Agent";
    //var reqdata = {
    //    "agent_id": Agent_Id,
    //    "is_deleted": Is_Deleted,
    //    "method_name": "Delete",
    //    "api_end_point": APIEndPoint,
    //};
    //$.ajax({
    //    type: 'POST',
    //    url: url,
    //    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
    //    data: reqdata,
    //    success: function (res) {
    //        var result = JSON.parse(res);
    //        if (result[0].result_id == 1) {
    //            // Show Success Message
    //            ShowEntrySuccess("Agent details deleted successfully");

    //            GetSearchList();
    //            CloseEntry();

    //        } else {

    //            Show_Error_Toastr("Error : " + result[0].result_description);
    //        }
    //    },
    //    error: function () {
    //        Show_Error_Toastr("Error : Agent details not deleted");
    //    }
    //});
}


function OpenModal(action) {
    $('#modelEntryMaterial').modal('show')
    $('#ddlEntryMaterialName').select2();
    $("#lblActionMaterial").html(action);
    if (action == 'Add') {
        $("#AddEditMaterial").text("Add Entry");
    }
    else if (action == 'Edit') {
        $("#AddEditMaterial").text("Edit Entry");
    }
}

$("#modelEntryMaterial").on("hidden.bs.modal", function (e) {

    $("#lblActionMaterial").html('');
    $("#AddEditMaterial").text('');
});


Date.prototype.toDateInputValue = function () {
    var local = new Date(this);
    local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
    return local.toJSON().slice(0, 10);
};
