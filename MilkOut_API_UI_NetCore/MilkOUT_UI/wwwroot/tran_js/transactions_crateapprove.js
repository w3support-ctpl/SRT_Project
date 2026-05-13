$(document).ready(function () {
    //SetDataTable("tableSearch", [4], "SalesArea");
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

function GetSearchList(e) {
    ClearDataTable("tableSearch");
    // Get data from database and show in table
    // Validate Data
    $('#tableData').empty();
    var SearchDealer_Id = "%" + $("#ddlSearchDealer").val() + "%";
    var ReceivedPeriod = $("#txtSearchReceivedPeriod").val();
    $("#btn_Search").prop('disabled', true);
    var Method_Name = 'Get';
    var APIEndPoint = "GetCrateApproval";
    var url = "/Transactions/CrateApprove";
    var reqdata = {
        "method_name": Method_Name,
        "dealer_id": SearchDealer_Id,
        "received_period": ReceivedPeriod,
        "api_end_point": APIEndPoint
    };


    Show_Loader();

    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            
            var res = JSON.parse(result);

            console.log(res);

            if (res.length == 0) {

                Hide_Loader();
                Show_Error_Toastr("Data not found.");
                $("#btn_Search").prop('disabled', false);
                return;
            }
            // Fill data in table
            var TableHTML = "";
            var EditFlag = 1; // IsEditAllowed($("#lblAS").html());


            $.each(res, function (data, value) {
                EditFlag = value.is_approved;

                TableHTML += "<tr>";
                TableHTML += '<td class="text-center" style="width: 20px;">';
                TableHTML += '<label class="custom-control custom-checkbox">';
                TableHTML += '<input type="checkbox"  onchange="checkboxChanged(' + '\'' + value.receivedcrate_id + '\');" id="' + value.receivedcrate_id + '" class="select-item custom-control-input" ' + "" + " />";
                TableHTML += '<label for="' + value.receivedcrate_id + '" class="custom-control-label text-dark"></label>';
                TableHTML += "</label>";
                TableHTML += "</td>";
                TableHTML += "<td hidden>" + value.receivedcrate_id + "</td>";
                TableHTML += "<td>" + value.dealer_name + "</td>";
                TableHTML += "<td>" + value.material_name + "</td>";
                TableHTML += "<td>" + value.created_on + "</td>";
                TableHTML += "<td>" + value.good_quantity + "</td>";
                TableHTML += "<td>" + value.broken_quantity + "</td>";
                TableHTML += "<td>" + value.thirdparty_quantity + "</td>";
       
            });

            $("#tableData").html(TableHTML);

            SetPagingDataTable("tableSearch", [2], "Crate Data");

            $("#btn_Search").prop('disabled', false);

            Hide_Loader();
        },

        error: function () {

            Hide_Loader();
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            $("#btn_Search").prop('disabled', false);
        }
    });

    return;
}


function checkboxChanged(checkid) {

    var isChecked = $( "#" + checkid).prop("checked");


    console.log(isChecked , checkid);

    $("input[id='" + checkid + "']").prop("checked", isChecked);

    
    
}

function ApproveCrate() {


    var xmldata = "<D>";
    $("#tableSearch tbody tr").each(function () {
        // set values of flags as 1 if checked
        if ($(this).find("td:eq(0) input").prop("checked") == true) {
            xmldata += "<R>";
            xmldata += "<CrateRecivedId>" + $(this).find("td:eq(1)").text() + "</CrateRecivedId>";
            xmldata += "</R>";

            console.log($(this).find("td:eq(1)").text());
        }
    });
    xmldata += "</D>";

    if (xmldata.length  < 20) {

        Show_Error_Toastr("Please Select Items");
        return;

    }


    ClearDataTable("tableSearch");
    // Get data from database and show in table
    // Validate Data
    $('#tableData').empty();
    var SearchDealer_Id = "%" + $("#ddlSearchDealer").val() + "%";
    var ReceivedPeriod = $("#txtSearchReceivedPeriod").val();
    $("#btn_Search").prop('disabled', true);
    var Method_Name = 'ApproveCrate';
    var APIEndPoint = "SaveCrateApproval";
    var url = "/Transactions/CrateApprove";
    var reqdata = {
        "method_name": Method_Name,
        "dealer_id": SearchDealer_Id,
        "received_period": ReceivedPeriod,
        "api_end_point": APIEndPoint,
        "approved_data": xmldata
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {

            var res = JSON.parse(result);
            Show_Success_Toastr("Crate Approved Successfully");

            $("#selectAll").prop("checked", false);

            GetSearchList();
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            $("#btn_Search").prop('disabled', false);
        }
    });

    return;

}



function SelectAllCheckbox() {
    $("#selectAll").on("click", function () {
        var isChecked = $(this).prop("checked");
        $("#tableSearch #tableData .custom-control-input:not(:disabled)").prop(
            "checked",
            isChecked
        );
    });

    $(document).on(
        "click",
        "#tableSearch #tableData .custom-control-input",
        function () {
            var allCheckboxes = $(
                "#tableSearch #tableData .custom-control-input:not(:disabled)"
            );
            var selectedCheckboxes = $(
                "#tableSearch #tableData .custom-control-input:checked:not(:disabled)"
            );

            // Update "Select All" checkbox state based on selected checkboxes
            $("#selectAll").prop(
                "checked",
                allCheckboxes.length === selectedCheckboxes.length
            );
        }
    );
}








function RejectCrate() {


    var xmldata = "<D>";
    $("#tableSearch tbody tr").each(function () {
        // set values of flags as 1 if checked
        if ($(this).find("td:eq(0) input").prop("checked") == true) {
            xmldata += "<R>";
            xmldata += "<CrateRecivedId>" + $(this).find("td:eq(1)").text() + "</CrateRecivedId>";
            xmldata += "</R>";

            console.log($(this).find("td:eq(1)").text());
        }
    });
    xmldata += "</D>";

    if (xmldata.length < 20) {

        Show_Error_Toastr("Please Select Items");
        return;

    }


    ClearDataTable("tableSearch");
    // Get data from database and show in table
    // Validate Data
    $('#tableData').empty();
    var SearchDealer_Id = "%" + $("#ddlSearchDealer").val() + "%";
    var ReceivedPeriod = $("#txtSearchReceivedPeriod").val();
    $("#btn_Search").prop('disabled', true);
    var Method_Name = 'RejectCrate';
    var APIEndPoint = "SaveCrateApproval";
    var url = "/Transactions/CrateApprove";
    var reqdata = {
        "method_name": Method_Name,
        "dealer_id": SearchDealer_Id,
        "received_period": ReceivedPeriod,
        "api_end_point": APIEndPoint,
        "approved_data": xmldata
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {

            var res = JSON.parse(result);
            Show_Error_Toastr("Crate Rejected Successfully");

            $("#selectAll").prop("checked", false);

            GetSearchList();
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            $("#btn_Search").prop('disabled', false);
        }
    });

    return;

}










//function ChanheSelectAll() {

//    var type = "checkbox";

//    var isChecked = $("#selectAll").prop("checked");

//    $("input[type='" + type + "']").prop("checked", isChecked);

//}


//$("#selectAll").change(function () {
//    $(".select-item").prop("checked", $(this).prop("checked"));
//});

$("#selectAll").change(function () {
    $(".select-item").prop("checked", $(this).prop("checked"));
});

//$(document).on("change", ".select-item", function () {
//    console.log(2);
//    if (!$(this).prop("checked")) {
//        $("#selectAll").prop("checked", false);
//    }

//    // Check if all .select-item checkboxes are checked
//    var allChecked =
//        $(".select-item:checked").length === $(".select-item").length;

//    // If all checkboxes are checked, set #selectAll to be checked
//    $("#selectAll").prop("checked", allChecked);
//});
