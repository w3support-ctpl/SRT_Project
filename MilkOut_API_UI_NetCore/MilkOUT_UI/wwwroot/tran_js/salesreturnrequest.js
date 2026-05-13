$(document).ready(function () {
    
    $("#ddlSearchDealerName").select2();
    GetMaster("ddlSearchDealerName", "Select Dealer Name", "GetDealer", "", "");
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
  
    ShowContentDiv('SalesReturnRequest', 'SalesReturnRequestAdd', '', function () {

        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        $("#txtEntryReturnDate").val(formattedDate);

        $("#ddlEntrySalesArea").select2();
        GetMaster("ddlEntrySalesArea", "Select Sales Area", "GetSalesArea", "", "");

        $("#ddlEntryDocumentReason").select2();
      //  GetMaster("ddlEntryDocumentReason", "Select Document Reason ", "GetSalesArea", "", "");

        $("#ddlSearchItemCode").select2();
        GetMaster("ddlSearchItemCode", "Select Search Item Code", "GetSearchItemCode", "", "");

        $("#divTabs").hide();
        $("#ddlSearchDealerName").select2();
        $("#lblEntryId").html();//for updating the record
        $("#lblAction").html("Edit");
        
    });
    
}



function ShowEditEntry() {
    ShowContentDiv('SalesReturnRequest', 'SalesReturnRequestEdit', '', function () {
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        $("#txtEntryReturnDate").val(formattedDate);

        $("#ddlEntrySalesArea").select2();
        $("#ddlSearchItemCode").select2(); // for Modal Search Item Code
        
        $("#lblEntryId").html();   //for updating the record
        $("#lblAction").html("Edit");

       
       
    });
}
function CloseEntry() {
    HideContentDiv();
}
   
function btnclick() {

    $("#modelEntryItems").show();
}
function SaveEntry()
{

    $("#divTabs").show();
}


