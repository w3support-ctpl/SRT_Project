$(document).ready(function () {
  $("#tableStructure").hide();
  $("#pdfStructure").hide();
  $("#ddlSearchDealerName").select2();
  GetMaster("ddlSearchDealerName", "Select Dealer Name ", "GetDealer", "", "");

  const style = document.createElement("style");
  document.head.appendChild(style);
  style.sheet.insertRule(
    "input::-webkit-inner-spin-button { -webkit-appearance: none; }",
    0
  );

  // Topmost Section
  $('input[name="datefilter"]').daterangepicker({
    locale: {
      cancelLabel: "Clear",
    },
    startDate: moment().subtract(30, "days"), // Set the startDate to 30 days ago
    endDate: moment(), // Set the endDate to the current date
    ranges: {
      Today: [moment(), moment()],
      Yesterday: [moment().subtract(1, "days"), moment().subtract(1, "days")],
      "Last 7 Days": [moment().subtract(6, "days"), moment()],
      "Last 30 Days": [moment().subtract(29, "days"), moment()],
      "This Month": [moment().startOf("month"), moment().endOf("month")],
      "Last Month": [
        moment().subtract(1, "month").startOf("month"),
        moment().subtract(1, "month").endOf("month"),
      ],
    },
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
  $("#tableStructure").show();
  $("#pdfStructure").hide();
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  $("#tableData").empty();

  var dateRange = $("#txtSearchPaymentsDate").val();
  var Dealer_Id = $("#ddlSearchDealerName").val();

  if (Dealer_Id == "") {
    $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
    return;
  }

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

  var IsValid = 1;

  if (dateRange == "") {
    $("#txtSearchPaymentsDate").addClass("is-invalid state-invalid");
    IsValid = 0;
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid data. Can't search.");
    return;
  }
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var APIEndPoint = "GetPayment";

  var url = "/Payment/Payment";

  var reqdata = {
    method_name: Method_Name,
    start_date: formattedStartDate,
    end_date: formattedEndDate,
    dealer_id: Dealer_Id,
    api_end_point: APIEndPoint,
  };

  Show_Loader();

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/json",
    data: JSON.stringify(reqdata),
    success: function (result) {
      var res = JSON.parse(result);

      var res_output = JSON.parse(res);
      var TableHTML = "";
      $.each(res_output, function (data, value) {
        // if (value.GLAccount != "10601010") {
        //   if (value.DebitCreditCode == "S") {
        //     TableHTML += "<tr>";
        //     TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        //     TableHTML += "<td>" + value.AccountingDocument + "</td>";
        //     TableHTML += "<td>" + value.PostingDate + "</td>";
        //     // TableHTML += "<td> Customer Payment </td>";
        //     TableHTML += "<td>" + value.AccountingDocumentType + "</td>";
        //     TableHTML += "<td>" + value.AmountInBalanceTransacCrcy + "</td>";
        //     TableHTML += "<td>" + value.BalanceTransactionCurrency + "</td>";
        //     TableHTML += "<td hidden></td>";
        //     TableHTML += "</tr>";
        //   }
        // } else {
        //   TableHTML += "<tr>";
        //   TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        //   TableHTML += "<td>" + value.AccountingDocument + "</td>";
        //   TableHTML += "<td>" + value.PostingDate + "</td>";
        //   // TableHTML += "<td> Customer Payment </td>";
        //   TableHTML += "<td>" + value.AccountingDocumentType + "</td>";
        //   TableHTML += "<td>" + value.AmountInBalanceTransacCrcy + "</td>";
        //   TableHTML += "<td>" + value.BalanceTransactionCurrency + "</td>";
        //   TableHTML += "<td hidden></td>";
        //   TableHTML += "</tr>";
        // }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.AccountingDocument + "</td>";
        TableHTML += "<td>" + value.ReferenceDocument + "</td>";
        TableHTML += "<td>" + value.PostingDate + "</td>";
        // TableHTML += "<td> Customer Payment </td>";
        TableHTML += "<td>" + value.AccountingDocumentType + "</td>";
        TableHTML += "<td>" + value.AmountInBalanceTransacCrcy + "</td>";
        TableHTML += "<td>" + value.BalanceTransactionCurrency + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });

      // assign the html string to table body present in the search page
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [7], "Payments");
      Hide_Loader();
    },
    error: function () {
      Hide_Loader();
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


function GetSearchPDFList(e) {
  $("#tableStructure").hide();
  $("#pdfStructure").show();
 

  var dateRange = $("#txtSearchPaymentsDate").val();
  var Dealer_Id = $("#ddlSearchDealerName").val();

  if (Dealer_Id == "") {
    $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
    return;
  }

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

  var IsValid = 1;

  if (dateRange == "") {
    $("#txtSearchPaymentsDate").addClass("is-invalid state-invalid");
    IsValid = 0;
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid data. Can't search.");
    return;
  }
  $("#btn_SearchPDF").prop("disabled", true);
  var Method_Name = "Get";
  var APIEndPoint = "GetAccountStatementSAPPDF";

  var url = "/Payment/Payment";

  var reqdata = {
    method_name: Method_Name,
    start_date: formattedStartDate,
    end_date: formattedEndDate,
    dealer_id: Dealer_Id,
    api_end_point: APIEndPoint,
  };

  Show_Loader();

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/json",
    data: JSON.stringify(reqdata),
    success: function (result) {

    
      var res = JSON.parse(result);
      
      if (!res.result_description || res.result_description.trim() === "") {
        Show_Error_Toastr("PDF not found");
      } else {
        // Clear the existing content in the div
        $("#pdfStructure").empty();
    
        // Create an iframe element to display the PDF
        var pdfIframe = `<iframe src="data:application/pdf;base64,${res.result_description}" 
                              width="100%" 
                              height="600px" 
                              style="border: none;"></iframe>`;
    
        // Insert the iframe into the div
        $("#pdfStructure").html(pdfIframe);
      }
      
     
      Hide_Loader();
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_SearchPDF").prop("disabled", false);
    },
  });
  $("#btn_SearchPDF").prop("disabled", false);
  return;
}