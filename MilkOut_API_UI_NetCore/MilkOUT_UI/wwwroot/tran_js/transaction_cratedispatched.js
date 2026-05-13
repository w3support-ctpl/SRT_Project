$(document).ready(function () {
    $("#ddlSearchDealerName").select2();
    GetMaster("ddlSearchDealerName", "Select Dealer Name", "GetDealer", "", "");
    //  SetDataTable("tableSearch", [4], "SalesArea");

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
    // Validate Data
    $('#tableData').empty();
    var Dealer_Id = $("#ddlSearchDealerName").val();
    var Dispatch_Period = $("#txtSearchDispatchPeriod").val();
    var IsValid = 1
    if (Dealer_Id == "") {
        $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (Dispatch_Period == "") {
        $("#txtSearchDispatchPeriod").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (IsValid == 0) {
        Show_Error_Toastr("Invalid data. Can't search.");
        return;
    }
    $("#btn_Search").prop('disabled', true);
    var Method_Name = 'GetCrates';
    var APIEndPoint = "GetCrateDispatched";

    var url = "/Transactions/CrateDispatched";

    var reqdata = {
        "method_name": Method_Name,
        "dealer_id": Dealer_Id,
        "dispatch_period": Dispatch_Period,
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
                $("#btn_Search").prop('disabled', false);

                return;
            }
            // Fill data in table
            var TableHTML = "";

            $.each(res, function (data, value) {
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.dispatch_date + "</td>";
                TableHTML += "<td>" + value.material_name + "</td>";
                TableHTML += "<td>" + value.quantity + "</td>";

                /*TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"View\" onclick=\"ShowEditEntry('" + value.dispatch_id + "')\">";
                TableHTML += "<i class=\"fa fa-eye\"></i>";
                TableHTML += "</a>";
                TableHTML += "</td>";*/

                TableHTML += "<td hidden></td>";
                TableHTML += "</tr>";

            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [4], "Crate Dispatched");
            $("#btn_Search").prop('disabled', false);
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            $("#btn_Search").prop('disabled', false);
        }
    });
    $("#btn_Search").prop('disabled', false);

    return;
}

/*
function ShowAddEntry() {
    ShowContentDiv('CrateDispatchToDealer', 'CrateDispatchToDealerAdd', '', function () {
        // Initialization Code
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        $("#txtEntryDispatchDate").val(formattedDate);
        $("#txtEntryDealerName").select2();
        $("#lblEntryId").html("");
        $("#lblAction").html("Add");
        $("#divFooterDelete").hide();
        GetMaster("txtEntryDealerName", "Select Dealer Name", "GetDealer", "", "");

        // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
    });
}


function ShowEditEntry() {
    ShowContentDiv('CrateDispatchToDealer', 'CrateDispatchToDealerEdit', '', function () {
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        $("#txtEntryDispatchDate").val(formattedDate);
        // Initialization Code
        $("#txtEntryDealerName").select2();
        GetMaster("txtEntryDealerName", "Select Dealer Name", "GetDealer", "", "");

    });
}

function CloseEntry() {
    HideContentDiv();
}

function SaveEntry() {
    // Validation code
    var DealerName = $("#txtEntryDealerName").val();
    var Quantity = $("#txtEntryQuantity").val();

    var IsValid = 1;

    if (DealerName == "") {
        IsValid = 0;
        $("#txtEntryDealerName").addClass("is-invalid state-invalid");

        //ShowEntryError("Enter Quantity");
    }
    if (Quantity == "") {
        IsValid = 0;
        $("#txtEntryQuantity").addClass("is-invalid state-invalid");

        //ShowEntryError("Enter Quantity");
    }
    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }
    else {
        // Start Saving
        $("#btn_Save").prop('disabled', true);
        var Method_Name = 'Create';
        var SalesArea_Id = "";
        var Action_Name = $("#lblAction").html();
        if (Action_Name == 'Edit') {
            Method_Name = 'Update';
            SalesArea_Id = $("#lblEntryId").html();
        }
        var Is_Active = 1;
        if (document.getElementById('chkEntryStatus').checked == false) {
            Is_Active = 0;
        }
        var Is_Deleted = 0;
        var APIEndPoint = "SaveSalesArea";
        var url = "/Masters/SalesArea";
        var reqdata = {
            "is_active": Is_Active,
            "is_deleted": Is_Deleted,
            "method_name": Method_Name,

            "salesarea_id": SalesArea_Id,
            "salesarea_code": SalesAreaCode,
            "salesarea_name": SalesAreaName,
            "api_end_point": APIEndPoint
        };

        //Save
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (res) {
                var result = JSON.parse(res);
                console.log("success", result);
                if (result[0].result_id == 1) {
                    // Show Success Messageq
                    GetSearchList();
                    $("#lblEntryId").html(result[0].result_extra_key);
                    $("#lblAction").html("Edit");
                    $("#divFooterDelete").show();
                    ShowEntrySuccess("Sales Area details saved successfully");
                    //$("#lblEntryId").html(result[0].result_extra_key);
                    //$("#lblAction").html("Edit");

                } else {
                    ShowEntryError("Error : " + result[0].result_description);
                    $("#btn_Save").prop('disabled', false);
                }

            },
            error: function () {
                Show_Error_Toastr("Error : Sales Area details not saved");
                $("#btn_Save").prop('disabled', false);
            }
        });
    }
    return;



}

function ShowDeleteEntry() {

    swal(
        {
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: 'question',
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, delete it!"
        }, function (result) {
            if (result == true) {
                SaveDeleteEntry();
            }
        });

}

function SaveDeleteEntry() {
    // Write code to delete
    var SalesArea_Id = $("#lblEntryId").html();
    // In success do following things
    var Is_Deleted = 1;
    // In success do following things

    var APIEndPoint = "SaveDealer";

    var url = "/Masters/SalesArea";
    var reqdata = {
        "salesarea_id": SalesArea_Id,
        "is_deleted": Is_Deleted,
        "method_name": "Delete",
        "api_end_point": APIEndPoint
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            if (result[0].result_id == 1) {
                // Show Success Message
                Show_Success_Toastr("Sales Area details deleted successfully");
                GetSearchList();
                CloseEntry();
            } else {
                Show_Error_Toastr("Error : " + result[0].result_description);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Sales Area details not deleted");
        }
    });
}
*/