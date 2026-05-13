$(document).ready(function () {
    $("#txtSearchDealerName").select2();
    GetMaster("txtSearchDealerName", "Select Dealer Name", "GetDealer", "", ""); // Topmost Section
      // SetDataTable("tableSearch", [6], "Dealer");
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

function ShowAddEntry() {
    ShowContentDiv('CreditMemoRequest', 'CreditMemoRequestView', '', function () {
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        $("#txtEntryCreditMemoDate").val(formattedDate);

        $("#ddlEntryItemCode").select2();
        $("#divTabs").hide();
        $("#ddlEntrySalesArea").select2();
        $("#ddlEntryState").select2();
        $("#ddlEntryDistrict").select2();
        $("#ddlEntryTaluka").select2();
        $("#ddlEntrySalesArea").select2();

        $("#lblEntryId").html("");//No id first
        $("#lblAction").html("Add");

        $("#divFooterDelete").hide();



    });
}

function ShowEditEntry(
    Action,
    OverallSDProcessStatus,
    CreditMemoRequest,
    CreditMemoRequestDate,
    SoldToParty
) {
    ShowContentDiv('CreditMemoRequest', 'CreditMemoRequestView', '', function () {

        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        $("#txtEntryCreditMemoDate").val(formattedDate);

        $("#lblAction").html("Edit");

        $("#divFooterDelete").show();

        GetMaster("ddlDealerName", "Select Dealer Name", "GetDealerdebitmemo", SoldToParty, SoldToParty); // Topmost Section

        $("#txtmemoStatus").val(OverallSDProcessStatus);
        $("#txtEntryCreditmemo").val(CreditMemoRequest);
        $("#txtEntryDate").val(CreditMemoRequestDate);
        $("#ddlDealerName").prop("disabled", true);
        $("#txtmemoStatus").prop("disabled", true);
        $("#txtEntryCreditmemo").prop("disabled", true);
        $("#txtEntryDate").prop("disabled", true);

        getonecreditmemo(CreditMemoRequest);



    });
}


function CloseEntry() {
    HideContentDiv();
}


function GetSearchList(e) {
    ClearDataTable("tableSearch");
    // Get data from database and show in table
    // Validate Data
    $("#tableData").empty();
    var Dealer_Id = $("#txtSearchDealerName").val();

    var dateRange = $("#txtSearchCreditMemoOrderDate").val();

    console.log(dateRange);

    // Split the date range string into start and end date strings
    var dateArray = dateRange.split(" - ");
    var startDateString = dateArray[0];
    var endDateString = dateArray[1];

    // Parse the dates using Date object
    var startDate = new Date(startDateString);
    var endDate = new Date(endDateString);

    startDate.setDate(startDate.getDate() + 1);

    // Adjust the endDate to consider the end of the day
    endDate.setDate(endDate.getDate() + 1); // Increment the day by 1 to include the end date
    endDate.setHours(0, 0, 0, 0);

    // Format the dates as per your requirement
    var formattedStartDate = startDate.toISOString().split("T")[0] + "T00:00:00";
    var formattedEndDate = endDate.toISOString().split("T")[0] + "T00:00:00";

    // console.log("Start Date:", formattedStartDate);
    // console.log("End Date:", formattedEndDate);

    var IsValid = 1;
    if (Dealer_Id == "") {
        $("#txtSearchDealerName").addClass("is-invalid state-invalid");
        IsValid = 0;
    }

    if (IsValid == 0) {
        Show_Error_Toastr("Invalid data. Can't search.");
        return;
    }

    $("#btn_Search").prop("disabled", true);

    var Method_Name = "Get";
    var APIEndPoint = "GetCreditMemoRequest";
    var url = "/CreditMemoRequest/CreditMemoRequest";
  

    var reqdata = {
        "method_name": Method_Name,
        "dealer_id": Dealer_Id,
        "StartDate": formattedStartDate,
        "EndDate": formattedEndDate,
        // "search_period": dateRange,
        "api_end_point": APIEndPoint
    };

    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json",
        data: JSON.stringify(reqdata),
        success: function (result) {
            var res = JSON.parse(result);

            console.log(res);

            var res_output = JSON.parse(res);

            console.log(res_output);

            if (res_output.length == 0) {
                Show_Error_Toastr("Data not found.");
                //   $("#btn_Search").prop('disabled', false);
                return;
            }
            // Fill data in table
            var TableHTML = "";

            $.each(res_output, function (data, value) {
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.CreditMemoRequest + "</td>";
                TableHTML += "<td>" + value.CreditMemoRequestType + "</td>";

                TableHTML += "<td>" + value.SoldToParty + "</td>";
                TableHTML += "<td>" + value.PurchaseOrderByCustomer + "</td>";
                

                TableHTML += "<td>" + value.CreditMemoRequestDate + "</td>";
                TableHTML += "<td>" + value.TotalNetAmount + "</td>";
                TableHTML += "<td>" + value.TransactionCurrency + "</td>";
                TableHTML += "<td>" + value.OverallSDProcessStatus + "</td>";
                // if (EditFlag == 0) {
                TableHTML +=
                    "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                TableHTML +=
                    '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
                    value.OverallSDProcessStatus +
                    "', '" +
                value.CreditMemoRequest +
                    "', '" +
                value.CreditMemoRequestDate +
                    "', '" +
                    value.SoldToParty +
                    "')\">";
                TableHTML += '<i class="fa fa-eye"></i>';
                TableHTML += "</a>";
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [0], "Debit Memo");
            $("#btn_Search").prop("disabled", false);
        },
        error: function () {
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description
            );
            $("#btn_Search").prop("disabled", false);
        },
    });
    $("#btn_Search").prop("disabled", false);
    return;
}



function getonecreditmemo(CreditMemoRequest) {

    var Method_Name = "Get";
    var APIEndPoint = "GetOneCreditMemoRequest";
    var url = "/CreditMemoRequest/CreditMemoRequest";

    var reqdata = {
        "CreditMemoRequest": CreditMemoRequest,
        "api_end_point": APIEndPoint
    };

    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/json",
        data: JSON.stringify(reqdata),
        success: function (result) {
            var res = JSON.parse(result);

            console.log(res);

            var res_output = JSON.parse(res);

            console.log(res_output);

            if (res_output.length == 0) {
                Show_Error_Toastr("Data not found.");
                //   $("#btn_Search").prop('disabled', false);
                return;
            }
            // Fill data in table
            var TableHTML = "";

            $.each(res_output, function (data, value) {
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.CreditMemoRequestItem + "</td>";
                TableHTML += "<td>" + value.CreditMemoRequestItemText + "</td>";

                TableHTML += "<td>" + value.Material + "</td>";

                TableHTML += "<td>" + value.MaterialGroup + "</td>";
                
                TableHTML += "<td>" + value.RequestedQuantity + "</td>";
                TableHTML += "<td>" + value.NetAmount + "</td>";
                TableHTML += "<td>" + value.RequestedQuantityUnit + "</td>";
                TableHTML += "</tr>";
            });

            $("#tableEntryItemDetails").html(TableHTML);
            SetDataTable("tableItemDetailsList", [0], "Credit Memo");
            $("#btn_Search").prop("disabled", false);
        },
        error: function () {
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description
            );
            $("#btn_Search").prop("disabled", false);
        },
    });



}



