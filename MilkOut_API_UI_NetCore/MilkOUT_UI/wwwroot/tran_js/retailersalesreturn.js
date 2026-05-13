$(document).ready(function () {
    $("#ddlSearchDealerName").select2();
    GetMaster("ddlSearchDealerName", "Select Dealer Name", "GetDealer", "", "");
    // SetDataTable("tableSearch", [5], "Retailer");
    $('input[name="datefilter"]').daterangepicker({
        locale: {
            cancelLabel: "Clear",
        },
        startDate: moment(), // Set the startDate to 30 days ago
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

function CloseEntry() {
    HideContentDiv();
}

function ShowAddEntry() {
    ShowContentDiv('RetailerSalesReturn', 'RetailerSalesReturnAdd', '', function () {
        // Initialization Code
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        // $("#ddlEntrySalesArea").select2();
        $("#txtEntryReturnDate").val(formattedDate);

        $("#ddlEntryRetailerName").select2();
        $("#ddlEntryDealerName").select2();
        $("#ddlEntrySalesPersonName").select2();


        $("#lblEntryId").html("");
        $("#lblAction").html("Add");

        GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");

        $("#divFooterDelete").hide();
    });
}

function ShowEditEntry(Retailer_Id) {
    ShowContentDiv('RetailerSalesReturn', 'RetailerSalesReturnEdit', '', function () {
        // Initialization Code
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        // $("#ddlEntrySalesArea").select2();
        $("#txtEntryReturnDate").val(formattedDate);

        $("#ddlEntryRetailerName").select2();
        $("#ddlEntryDealerName").select2();
        $("#ddlEntrySalesPersonName").select2();

        $("#lblEntryId").html(Retailer_Id);
        $("#lblAction").html("Edit");

        // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
        // GetMaster("ddlEntryState", "Select State", "GetState", "", "");
        GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");
        //GetMaster("ddlEntryState", "Select State", "GetState", "", "");

        $("#divFooterDelete").show();



    });
}

function ShowModalEntry() {
    $("#ddlModalItem").select2();


}


function SaveEntry() {
    // Validation code
    // var RetailerCode = $("#txtEntryRetailerCode").val();
    var Retailer_Name = $("#ddlEntryRetailerName").val();

    var Dealer_Id = $("#ddlEntryDealerName").val();

    var Sales_PersonId = $("#ddlEntrySalesPersonName").val();

    var Entry_Id = $("#txtEntryNo").val();

    var Return_Date = $("#txtEntryReturnDate").val();
    var Remarks = $("#txtEntryRemarks").val();


    var IsValid = 1;
    //var APIEndPoint = "SaveRetailer";

    //var url = "/Masters/Retailer";

    if (Retailer_Name == "") {
        IsValid = 0;
        $("#ddlEntryRetailerName").addClass("is-invalid state-invalid");

    }

    if (Dealer_Id == "") {
        IsValid = 0;
        $("#ddlEntryDealerName").addClass("is-invalid state-invalid");

    }
    if (Sales_PersonId == "") {
        IsValid = 0;
        $("#ddlEntrySalesPersonName").addClass("is-invalid state-invalid");

    }

    if (Entry_Id == "") {
        IsValid = 0;
        $("#txtEntryNo").addClass("is-invalid state-invalid");

    }
    if (Return_Date == "") {
        IsValid = 0;
        $("#txtEntryReturnDate").addClass("is-invalid state-invalid");

    }
    if (Remarks == "") {
        IsValid = 0;
        $("#txtEntryRemarks").addClass("is-invalid state-invalid");

    }


    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }
    else {

        Show_Success_Toastr("Retailer Sales Return details Saved successfully");
    }


    return;
}