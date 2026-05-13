$(document).ready(function () {
    $("#ddlSearchDealer").select2();
    GetMaster("ddlSearchDealer", "Select Dealer Name", "GetDealer", "", "");
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



function ShowEditEntry() {
    ShowContentDiv('DebitNote', 'DebitNoteAdd', '', function () {
        // Initialization Code
        $("#lblEntryId").html();
        $("#lblAction").html("Edit");
        $("#divFooterDelete").hide();
        $("#txtSearchDealerName").select2();
        GetMaster("txtSearchDealerName", "Select Dealer Name", "GetDealer", "", ""); // Topmost Section

        //var Method_Name = 'Get_One';
        //var url = "/Masters/GetSalesArea";
        //var reqdata = {
        //    "method_name": Method_Name,
        //    "salesarea_id": SalesArea_Id,
        //};
        //$.ajax({
        //    type: 'POST',
        //    url: url,
        //    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        //    data: reqdata,
        //    success: function (result) {
        //        var res = JSON.parse(result.responseData);
        //        $("#txtEntrySalesAreaCode").val(res[0].salesarea_code);
        //        $("#txtEntrySalesAreaName").val(res[0].salesarea_name);
        //        if (res[0].is_active == 1) {
        //            $('#chkEntryStatus').prop("checked", true);
        //        }
        //        else {
        //            $('#chkEntryStatus').prop("checked", false);
        //        }
        //    },
        //    error: function () {
        //        Show_Error_Toastr("Error in fetching details from server.");
        //    }
        //});
    });
}

function CloseEntry() {
    HideContentDiv();
}


    
