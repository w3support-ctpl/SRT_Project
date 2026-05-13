$(document).ready(function () {
  const style = document.createElement("style");
  document.head.appendChild(style);
  style.sheet.insertRule(
    "input::-webkit-inner-spin-button { -webkit-appearance: none; }",
    0
  );

  $("#txtSearchDealerName").select2();
  GetMaster("txtSearchDealerName", "Select Dealer Name", "GetDealer", "", ""); // Topmost Section
  // SetDataTable("tableSearch", [6], "Dealer");
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

  var ItemList = [];
  var Document_ReferenceID = "";
  PaymentTerms();
});

var paymentTermsArray = [];

function PaymentTerms() {
  var url = "/Home/GetMasterData";
  var reqdata = {
    Method_Name: "GetPaymentTerms",
    ParentField_Id: "",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      // var res = JSON.parse(result);
      paymentTermsArray = result;
    },
    error: function () {
      Show_Error_Toastr("Error in fetching Payment Terms data");
    },
  });
}

function GetPaymentTerm(item_id) {
  // Find and return the item_value for the given item_id
  var paymentTerm = paymentTermsArray.find(function (term) {
    return term.item_id === item_id;
  });
  return paymentTerm ? paymentTerm.item_value : "";
}

function ShowEditEntry(
  invoice_no,
  invoice_date,
  invoice_amount,
  invoice_paymentterm,
  DocumentReferenceID
) {
  Document_ReferenceID = "";
  ShowContentDiv("Invoice", "InvoiceAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html();
    $("#lblAction").html("Edit");
    $("#divFooterDelete").hide();
    // $("#txtSearchDealerName").select2();
    // GetMaster("txtSearchDealerName", "Select Dealer Name", "GetDealer", "", ""); // Topmost Section
    $("#txtEntryPaymentTerm").select2();
    GetMaster(
      "txtEntryPaymentTerm",
      "Select Payment Terms",
      "GetPaymentTerms",
      invoice_paymentterm,
      ""
    );
    $("#txtEntryInvoiceId").val(invoice_no);
    $("#txtEntryInvoiceAmount").val(invoice_amount);
    $("#txtEntryInvoiceDate").val(invoice_date);
    // $("#txtEntryPaymentTerm").val(invoice_paymentterm);

    GetOneInvoice(invoice_no);

    Document_ReferenceID = DocumentReferenceID;
  });
}

function GetOneInvoice(invoice_no) {
  var arrayData = [];

  var APIEndPoint_1 = "GetOneInvoicePricing";
  var url_1 = "/Invoice/Invoice";

  var reqdata_1 = {
    method_name: "Get_One",
    api_end_point: APIEndPoint_1,
    destination_name: "",
    dealer_id: "",
    is_active: 1,
    is_deleted: 0,
    user_id: "",
    user_name: "",
    start_date: "",
    end_date: "",
    invoice_no: invoice_no,
  };

  $.ajax({
    type: "POST",
    url: url_1,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata_1,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      console.log(res_output);

      // Populate arrayData
      res_output.forEach((item) => {
        let existingItem = arrayData.find(
          (data) => data.BillingDocumentItem === item.BillingDocumentItem
        );

        if (!existingItem) {
          existingItem = {
            BillingDocumentItem: item.BillingDocumentItem,
            Rate: null,
            Amount: null,
            TaxableValue: null,
            CGST: null,
            SGST: null,
            IGST: null,
            DCD1: null,
            RoundingOff: null,
          };
          arrayData.push(existingItem);
        }

        switch (item.ConditionType) {
          case "PPR0":
            existingItem.Rate = item.ConditionRateValue;
            existingItem.Amount = item.ConditionAmount;
            break;
          case "JOCG":
            existingItem.TaxableValue = item.ConditionBaseValue;
            existingItem.CGST = item.ConditionAmount;
            break;
          case "JOSG":
            existingItem.SGST = item.ConditionAmount;
            break;
          case "JOIG":
            existingItem.IGST = item.ConditionAmount;
            break;
          case "DCD1":
            existingItem.DCD1 = item.ConditionBaseValue;
            break;
          case "DRD1":
            existingItem.RoundingOff = item.ConditionAmount;
            break;
        }
      });

      console.log(arrayData);

      // Now proceed with the second API call
      var APIEndPoint = "GetOneInvoice";
      var url = "/Invoice/Invoice";

      var reqdata = {
        method_name: "Get_One",
        api_end_point: APIEndPoint,
        destination_name: "",
        dealer_id: "",
        is_active: 1,
        is_deleted: 0,
        user_id: "",
        user_name: "",
        start_date: "",
        end_date: "",
        invoice_no: invoice_no,
      };

      $("#btn_Search").prop("disabled", true);
      $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
          var res = JSON.parse(result);
          var res_output = JSON.parse(res);

          ItemList = res_output;
          var TableHTML = "";
          $.each(res_output, function (index, value) {
            // Find matching item in arrayData after removing leading zeros
            var matchedItem = arrayData.find(
              (item) =>
                item.BillingDocumentItem.replace(/^0+/, "") ===
                value.BillingDocumentItem.replace(/^0+/, "")
            );

            TableHTML += "<tr>";
            TableHTML += "<td>" + value.Material + "</td>";
            TableHTML += "<td>" + value.BillingDocumentItemText + "</td>";
            TableHTML += "<td>" + value.BillingQuantity + "</td>";
            TableHTML += "<td>" + value.ItemWeightUnit + "</td>";
            TableHTML += "<td>" + value.Plant + "</td>";

            // Add values from matchedItem if found, else empty cells
            if (matchedItem) {
              // TableHTML +=
              //   "<td>" + (parseFloat(matchedItem.Rate).toFixed(2) || "") + "</td>";
              // TableHTML += "<td>" + (parseFloat(matchedItem.Amount).toFixed(2) || "") + "</td>";
              // TableHTML += "<td>" + (parseFloat(matchedItem.TaxableValue).toFixed(2) || "") + "</td>";
              // TableHTML += "<td>" + (parseFloat(matchedItem.CGST).toFixed(2) || "") + "</td>";
              // TableHTML += "<td>" + (parseFloat(matchedItem.SGST).toFixed(2) || "") + "</td>";
              // TableHTML += "<td>" + (parseFloat(matchedItem.IGST).toFixed(2) || "") + "</td>";
              // TableHTML += "<td>" + (parseFloat(matchedItem.DCD1).toFixed(2) || "") + "</td>";
              // TableHTML +=
              //   "<td>" +
              //   (!isNaN(parseFloat(matchedItem.Rate))
              //     ? parseFloat(matchedItem.Rate).toFixed(2)
              //     : "") +
              //   "</td>";
              // TableHTML +=
              //   "<td>" +
              //   (!isNaN(parseFloat(matchedItem.Amount))
              //     ? parseFloat(matchedItem.Amount).toFixed(2)
              //     : "") +
              //   "</td>";
              // TableHTML +=
              //   "<td>" +
              //   (!isNaN(parseFloat(matchedItem.TaxableValue))
              //     ? parseFloat(matchedItem.TaxableValue).toFixed(2)
              //     : "") +
              //   "</td>";
              // TableHTML +=
              //   "<td>" +
              //   (!isNaN(parseFloat(matchedItem.CGST))
              //     ? parseFloat(matchedItem.CGST).toFixed(2)
              //     : "") +
              //   "</td>";
              // TableHTML +=
              //   "<td>" +
              //   (!isNaN(parseFloat(matchedItem.SGST))
              //     ? parseFloat(matchedItem.SGST).toFixed(2)
              //     : "") +
              //   "</td>";
              // TableHTML +=
              //   "<td>" +
              //   (!isNaN(parseFloat(matchedItem.IGST))
              //     ? parseFloat(matchedItem.IGST).toFixed(2)
              //     : "") +
              //   "</td>";
              // TableHTML +=
              //   "<td>" +
              //   (!isNaN(parseFloat(matchedItem.DCD1))
              //     ? parseFloat(matchedItem.DCD1).toFixed(2)
              //     : "") +
              //   "</td>";

              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.Rate))
                  ? parseFloat(matchedItem.Rate)
                  : "") +
                "</td>";
              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.Amount))
                  ? parseFloat(matchedItem.Amount)
                  : "") +
                "</td>";
              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.TaxableValue))
                  ? parseFloat(matchedItem.TaxableValue)
                  : "") +
                "</td>";
              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.CGST))
                  ? parseFloat(matchedItem.CGST)
                  : "") +
                "</td>";
              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.SGST))
                  ? parseFloat(matchedItem.SGST)
                  : "") +
                "</td>";
              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.IGST))
                  ? parseFloat(matchedItem.IGST)
                  : "") +
                "</td>";
              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.RoundingOff))
                  ? parseFloat(matchedItem.RoundingOff)
                  : "") +
                "</td>";
              TableHTML +=
                "<td>" +
                (!isNaN(parseFloat(matchedItem.DCD1))
                  ? parseFloat(matchedItem.DCD1)
                  : "") +
                "</td>";
            } else {
              TableHTML += "<td colspan='8'>No matching data</td>";
            }
            // if (matchedItem) {
            //   TableHTML += "<td>" + (matchedItem.Rate || "") + "</td>";
            //   TableHTML += "<td>" + (matchedItem.Amount || "") + "</td>";
            //   TableHTML += "<td>" + (matchedItem.TaxableValue || "") + "</td>";
            //   TableHTML += "<td>" + (matchedItem.CGST || "") + "</td>";
            //   TableHTML += "<td>" + (matchedItem.SGST || "") + "</td>";
            //   TableHTML += "<td>" + (matchedItem.IGST || "") + "</td>";
            //   TableHTML += "<td>" + (matchedItem.DCD1 || "") + "</td>";
            // } else {
            //   TableHTML += "<td colspan='7'>No matching data</td>";
            // }

            TableHTML += "</tr>";
          });

          // if (res_output.length > 0) {
          //   TableHTML += "<tr>";
          //   TableHTML +=
          //     "<td style='width: 85px;' class='font-weight-bold' >" +
          //     "TOTAL" +
          //     "<span class='text-red'>*</span></td>";
          //   TableHTML += "<td>" + "----" + "</td>";
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total quantity   value.BillingQuantity
          //   TableHTML += "<td>" + "----" + "</td>";
          //   TableHTML += "<td>" + "----" + "</td>";
          //   TableHTML += "<td>" + "----" + "</td>";
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total Amount   matchedItem.Amount
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total TaxableValue   matchedItem.TaxableValue
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total CGST   matchedItem.CGST
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total SGST   matchedItem.SGST
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total IGST   matchedItem.IGST
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total RoundingOff   matchedItem.RoundingOff
          //   TableHTML += '<td class="font-weight-bold"></td>'; // total DCD1   matchedItem.DCD1

          // }

          if (res_output.length > 0) {
            // Initialize variables to calculate totals
            let totalQuantity = 0;
            let totalAmount = 0;
            let totalTaxableValue = 0;
            let totalCGST = 0;
            let totalSGST = 0;
            let totalIGST = 0;
            let totalRoundingOff = 0;
            let totalDCD1 = 0;

            // Iterate through res_output to calculate totals
            $.each(res_output, function (index, value) {
              var matchedItem = arrayData.find(
                (item) =>
                  item.BillingDocumentItem.replace(/^0+/, "") ===
                  value.BillingDocumentItem.replace(/^0+/, "")
              );

              if (matchedItem) {
                totalQuantity += !isNaN(parseFloat(value.BillingQuantity))
                  ? parseFloat(value.BillingQuantity)
                  : 0;
                totalAmount += !isNaN(parseFloat(matchedItem.Amount))
                  ? parseFloat(matchedItem.Amount)
                  : 0;
                totalTaxableValue += !isNaN(
                  parseFloat(matchedItem.TaxableValue)
                )
                  ? parseFloat(matchedItem.TaxableValue)
                  : 0;
                totalCGST += !isNaN(parseFloat(matchedItem.CGST))
                  ? parseFloat(matchedItem.CGST)
                  : 0;
                totalSGST += !isNaN(parseFloat(matchedItem.SGST))
                  ? parseFloat(matchedItem.SGST)
                  : 0;
                totalIGST += !isNaN(parseFloat(matchedItem.IGST))
                  ? parseFloat(matchedItem.IGST)
                  : 0;
                totalRoundingOff += !isNaN(parseFloat(matchedItem.RoundingOff))
                  ? parseFloat(matchedItem.RoundingOff)
                  : 0;
                // totalDCD1 += !isNaN(parseFloat(matchedItem.DCD1))
                //   ? parseFloat(matchedItem.DCD1)
                //   : 0;
              }
            });

            totalDCD1 =
              totalAmount +
              totalCGST +
              totalSGST +
              totalIGST +
              totalRoundingOff;

            // Add TOTAL row
            TableHTML += "<tr>";
            TableHTML += "<td class='font-weight-bold'>TOTAL</td>";
            TableHTML += "<td>----</td>";
            TableHTML +=
              "<td class='font-weight-bold'>" +
              totalQuantity.toFixed(2) +
              "</td>";
            TableHTML += "<td>----</td>";
            TableHTML += "<td>----</td>";
            TableHTML += "<td>----</td>";
            TableHTML +=
              "<td class='font-weight-bold' >" +
              totalAmount.toFixed(2) +
              "</td>";
            TableHTML +=
              "<td class='font-weight-bold' style='color: red !important'>" +
              totalTaxableValue.toFixed(2) +
              "</td>";
            TableHTML +=
              "<td class='font-weight-bold'>" + totalCGST.toFixed(2) + "</td>";
            TableHTML +=
              "<td class='font-weight-bold'>" + totalSGST.toFixed(2) + "</td>";
            TableHTML +=
              "<td class='font-weight-bold'>" + totalIGST.toFixed(2) + "</td>";
            TableHTML +=
              "<td class='font-weight-bold'>" +
              totalRoundingOff.toFixed(2) +
              "</td>";
            TableHTML +=
              "<td class='font-weight-bold'>" + totalDCD1.toFixed(2) + "</td>";
            TableHTML += "</tr>";
          }

          $("#tableInvoiceItem").html(TableHTML);

          if (res_output.length == 0) {
            Show_Error_Toastr("Data not found.");
            return;
          }
        },
        error: function () {},
      });

      $("#btn_Search").prop("disabled", false);
    },
    error: function () {},
  });

  return;
}

// function GetOneInvoice(invoice_no) {
//   var arrayData = [];

//   var APIEndPoint_1 = "GetOneInvoicePricing";
//   var url_1 = "/Invoice/Invoice";

//   var reqdata_1 = {
//     method_name: "Get_One",
//     api_end_point: APIEndPoint_1,
//     destination_name: "",
//     dealer_id: "",
//     is_active: 1,
//     is_deleted: 0,
//     user_id: "",
//     user_name: "",
//     start_date: "",
//     end_date: "",
//     invoice_no: invoice_no,
//   };

//   $.ajax({
//     type: "POST",
//     url: url_1,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata_1,
//     success: function (result) {
//       var res = JSON.parse(result);
//       var res_output = JSON.parse(res);

//       // Populate arrayData
//       res_output.forEach((item) => {
//         let existingItem = arrayData.find(
//           (data) => data.BillingDocumentItem === item.BillingDocumentItem
//         );

//         if (!existingItem) {
//           existingItem = {
//             BillingDocumentItem: item.BillingDocumentItem,
//             Rate: null,
//             Amount: null,
//             TaxableValue: null,
//             CGST: null,
//             SGST: null,
//             IGST: null,
//             DCD1: null,
//           };
//           arrayData.push(existingItem);
//         }

//         switch (item.ConditionType) {
//           case "PPR0":
//             existingItem.Rate = item.ConditionRateValue;
//             existingItem.Amount = item.ConditionAmount;
//             break;
//           case "JOCG":
//             existingItem.TaxableValue = item.ConditionBaseValue;
//             existingItem.CGST = item.ConditionAmount;
//             break;
//           case "JOSG":
//             existingItem.SGST = item.ConditionAmount;
//             break;
//           case "JOIG":
//             existingItem.IGST = item.ConditionAmount;
//             break;
//           case "DCD1":
//             existingItem.DCD1 = item.ConditionAmount;
//             break;
//         }
//       });

//       // Log arrayData after it’s fully populated
//       console.log(arrayData);

//       // Now proceed with the second API call
//       var APIEndPoint = "GetOneInvoice";
//       var url = "/Invoice/Invoice";

//       var reqdata = {
//         method_name: "Get_One",
//         api_end_point: APIEndPoint,
//         destination_name: "",
//         dealer_id: "",
//         is_active: 1,
//         is_deleted: 0,
//         user_id: "",
//         user_name: "",
//         start_date: "",
//         end_date: "",
//         invoice_no: invoice_no,
//       };

//       $("#btn_Search").prop("disabled", true);
//       $.ajax({
//         type: "POST",
//         url: url,
//         contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//         data: reqdata,
//         success: function (result) {
//           var res = JSON.parse(result);
//           var res_output = JSON.parse(res);

//           var TableHTML = "";
//           $.each(res_output, function (data, value) {
//             TableHTML += "<tr>";
//             TableHTML += "<td style='width: 20px;'>" + value.Material + "</td>";
//             TableHTML += "<td>" + value.BillingDocumentItemText + "</td>";
//             TableHTML += "<td>" + value.BillingQuantity + "</td>";
//             TableHTML += "<td>" + value.ItemWeightUnit + "</td>";
//             TableHTML += "<td>" + value.Plant + "</td>";
//             // TableHTML += "<td>" + value.NetAmount + "</td>";
//           });

//           $("#tableInvoiceItem").html(TableHTML);

//           if (res_output.length == 0) {
//             Show_Error_Toastr("Data not found.");
//             return;
//           }
//         },
//         error: function () {},
//       });

//       $("#btn_Search").prop("disabled", false);
//     },
//     error: function () {},
//   });

//   return;
// }

// function GetOneInvoice(invoice_no) {
//   var arrayData = [];

//   var APIEndPoint_1 = "GetOneInvoicePricing";
//   var url_1 = "/Invoice/Invoice";

//   var reqdata_1 = {
//     method_name: "Get_One",
//     api_end_point: APIEndPoint_1,
//     destination_name: "",
//     dealer_id: "",
//     is_active: 1,
//     is_deleted: 0,
//     user_id: "",
//     user_name: "",
//     start_date: "",
//     end_date: "",
//     invoice_no: invoice_no,
//   };

//   $.ajax({
//     type: "POST",
//     url: url_1,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata_1,
//     success: function (result) {
//       var res = JSON.parse(result);
//       var res_output = JSON.parse(res);

//       // Iterate over each BillingDocumentItem and create the desired structure
//       res_output.forEach((item) => {
//         // Check if the BillingDocumentItem already exists in the arrayData
//         let existingItem = arrayData.find(
//           (data) => data.BillingDocumentItem === item.BillingDocumentItem
//         );

//         // If not found, create a new entry
//         if (!existingItem) {
//           existingItem = {
//             BillingDocumentItem: item.BillingDocumentItem,
//             Rate: null,
//             Amount: null,
//             TaxableValue: null,
//             CGST: null,
//             SGST: null,
//             IGST: null,
//             DCD1: null,
//           };
//           arrayData.push(existingItem);
//         }

//         // Assign values based on ConditionType
//         switch (item.ConditionType) {
//           case "PPR0":
//             existingItem.Rate = item.ConditionRateValue;
//             existingItem.Amount = item.ConditionAmount;
//             break;
//           case "JOCG":
//             existingItem.TaxableValue = item.ConditionBaseValue;
//             existingItem.CGST = item.ConditionAmount;
//             break;
//           case "JOSG":
//             existingItem.SGST = item.ConditionAmount;
//             break;
//           case "JOIG":
//             existingItem.IGST = item.ConditionAmount;
//             break;
//           case "DCD1":
//             existingItem.DCD1 = item.ConditionAmount;
//             break;
//         }
//       });

//       // console.log(arrayData);

//     },
//     error: function () {
//     },
//   });

//   console.log(arrayData);

//   var APIEndPoint = "GetOneInvoice";
//   var url = "/Invoice/Invoice";

//   var reqdata = {
//     method_name: "Get_One",
//     api_end_point: APIEndPoint,
//     destination_name: "",
//     dealer_id: "",
//     is_active: 1,
//     is_deleted: 0,
//     user_id: "",
//     user_name: "",
//     start_date: "",
//     end_date: "",
//     invoice_no: invoice_no,
//   };

//   $("#btn_Search").prop("disabled", true);
//   $.ajax({
//     type: "POST",
//     url: url,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata,
//     success: function (result) {
//       var res = JSON.parse(result);
//       var res_output = JSON.parse(res);

//       console.log(res_output);

//       var TableHTML = "";

// ItemList = res_output;
//       $.each(res_output, function (data, value) {
//         TableHTML += "<tr>";
//         TableHTML += "<td style='width: 20px;'>" + value.Material + "</td>";
//         TableHTML += "<td>" + value.BillingDocumentItemText + "</td>";
//         TableHTML += "<td>" + value.BillingQuantity + "</td>";
//         TableHTML += "<td>" + value.ItemWeightUnit + "</td>";
//         TableHTML += "<td>" + value.Plant + "</td>";
//         TableHTML += "<td>" + value.NetAmount + "</td>";
//       });

//       // assign the html string to table body present in the search page
//       $("#tableInvoiceItem").html(TableHTML);

//       if (res_output.length == 0) {
//         Show_Error_Toastr("Data not found.");
//         return;
//       }

//       // extract values and create an html string to assign to html table
//     },
//     error: function () {
//     },
//   });
//   // enable search button to let user make function calls
//   $("#btn_Search").prop("disabled", false);
//   return;
// }

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function GetSearchList(e) {
  // disable search button to avoid multiple function calls
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  var SearchPeriod = $("#txtSearchInvoiceDate").val();
  var DealerUser_Id = $("#txtSearchDealerName").val();
  // var SalesArea_Id = "%" + $("#ddlSearchSalesArea").val() + "%";

  //let [startDateString, endDateString] = SearchPeriod.split(' - ');

  //// Create Date objects from the date strings
  //let startDate = startDateString;

  //let endDate = endDateString;

  var dateRange = $("#txtSearchInvoiceDate").val();

  // // console.log(DealerUser_Id);

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

  //// console.log(startDate, endDate, DealerUser_Id);

  // var StartDate = SearchPeriod

  if (SearchPeriod == "") {
    $("#txtSearchInvoiceDate").addClass("is-invalid state-invalid");
    return;
  }

  if (DealerUser_Id == "") {
    $("#txtSearchDealerName").addClass("is-invalid state-invalid");
    return;
  }

  var APIEndPoint = "GetInvoice";
  var url = "/Invoice/Invoice";

  var reqdata = {
    method_name: "Get",
    api_end_point: APIEndPoint,
    destination_name: "",
    dealer_id: DealerUser_Id,
    is_active: 1,
    is_deleted: 0,
    user_id: "",
    user_name: "",
    start_date: formattedStartDate,
    end_date: formattedEndDate,
    invoice_no: "",
  };

  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      // console.log(res_output);
      var TableHTML = "";

      $.each(res_output, function (data, value) {
        const date = new Date(value.BillingDocumentDate);
        const formattedDate = date.toLocaleDateString("en-US", {
          year: "numeric",
          month: "long",
          day: "numeric",
        });

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML +=
          "<td style='width: 85px;'>" + value.BillingDocument + "</td>";
        TableHTML += "<td>" + value.BillingDocumentType + "</td>";
        TableHTML += "<td>" + formattedDate + "</td>";
        // TableHTML += "<td>" + value.CustomerPaymentTerms + "</td>";
        TableHTML +=
          "<td>" + GetPaymentTerm(value.CustomerPaymentTerms) + "</td>";
        TableHTML += "<td>" + value.TotalNetAmount + "</td>";
        TableHTML += "<td>" + value.TransactionCurrency + "</td>";
        TableHTML +=
          '<td style="width: 80px;" ><a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick=\'ShowEditEntry("' +
          value.BillingDocument +
          '","' +
          value.BillingDocumentDate +
          '","' +
          value.TotalNetAmount +
          '","' +
          value.CustomerPaymentTerms +
          '","' +
          value.DocumentReferenceID +
          "\")'>";
        TableHTML += '<i class="fa fa-pencil"></i></a>';

        TableHTML +=
          '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowPDFEntry(\'' +
          value.BillingDocument +
          '\')"><i class="fa fa-file-pdf-o"></i></a>';

        TableHTML += "</td>";

        TableHTML += "</tr>";
      });

      // assign the html string to table body present in the search page
      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [0], "Invoice");

      if (res_output.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      // extract values and create an html string to assign to html table
    },
    error: function () {
      // Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

function PlaceReturn(type) {
  var invoice_no = $("#txtEntryInvoiceId").val();

  var DocumentReferenceID = $("#lblDocumentReferenceID").html();

  // console.log(type);

  $("#txtEntryPaymentTerm").val();

  var invoiceno = $("#txtEntryInvoiceId").val();
  var invoice_amount = $("#txtEntryInvoiceAmount").val();
  var invoice_date = $("#txtEntryInvoiceDate").val();
  var invoice_paymentterm = $("#txtEntryPaymentTerm").val();

  ShowContentDiv("Invoice", "InvoiceSalesReturn", "", function () {
    if (type == "SalesReturn") {
      $("#lbltitle").html("Sales Return Request");

      $("#theadingreturn").html("Requested Quantity");
    } else {
      $("#lbltitle").html("Credit Memo Request");
      $("#theadingreturn").html("Quantity");
    }

    $("#invoice_no").html(invoiceno);
    $("#invoice_amount").html(invoice_amount);
    $("#invoice_date").html(invoice_date);
    $("#invoice_paymentterm").html(invoice_paymentterm);

    var TableHTML = "";
    $.each(ItemList, function (data, value) {
      TableHTML += "<tr>";
      TableHTML += '<td class="text-center" style="width: 20px;">';
      TableHTML += '<label class="custom-control custom-checkbox">';
      TableHTML +=
        '<input type="checkbox" onchange="checkboxChanged(' +
        "'" +
        value.BillingDocumentItem +
        '\');" id="' +
        value.BillingDocumentItem +
        '"  class="select-item custom-control-input" />';
      TableHTML +=
        '<label for="' +
        value.BillingDocumentItem +
        '" class="custom-control-label text-dark"></label>';
      TableHTML += "</label>";
      TableHTML += "</td>";
      TableHTML +=
        "<td style='width: 20px;'>" + value.BillingDocumentItem + "</td>";
      TableHTML += "<td>" + value.BillingDocumentItemText + "</td>";
      TableHTML += "<td>" + value.BillingQuantity + "</td>";
      TableHTML += "<td>" + value.ItemWeightUnit + "</td>";
      TableHTML += '<td class="text-center">';
      TableHTML +=
        '<input type="number" id="I_' +
        value.BillingDocumentItem +
        '"  class="form-control" disabled />';
      TableHTML += "</td>";
      TableHTML += "<td hidden >" + value.Material + "</td>";
      TableHTML += "<td hidden >" + value.ReferenceSDDocument + "</td>";

      TableHTML += "<td hidden >" + value.SalesOrganization + "</td>";
      TableHTML += "<td hidden >" + value.DistributionChannel + "</td>";
      TableHTML += "<td hidden >" + value.OrganizationDivision + "</td>";
      TableHTML += "<td hidden >" + value.SalesGroup + "</td>";
      TableHTML += "<td hidden >" + value.SalesOffice + "</td>";
      TableHTML += "<td hidden >" + value.SoldToParty + "</td>";

      TableHTML += "</tr>";
    });

    // assign the html string to table body present in the search page
    $("#tableInvoiceItems").html(TableHTML);
    $("#lbltype").html(type);
    $("#lblinvoiceno").html(invoice_no);
  });

  // console.log(type);

  //$("#modelEntryItem")
  //    .modal({
  //        backdrop: "static",
  //    })
  //    .modal("show");
}

function checkboxChanged(BillingDocumentItem) {
  var isChecked = $("#" + BillingDocumentItem).prop("checked");

  if (isChecked) {
    $("#I_" + BillingDocumentItem).val("");
    $("#I_" + BillingDocumentItem).prop("disabled", false);
  } else {
    $("#I_" + BillingDocumentItem).prop("disabled", true);
  }
}

function SaveEntry() {
  var Type = $("#lbltype").html();

  /*  Show_Loader();*/

  var returnList = [];

  //var DocumentReferenceID = $("#lblDocumentReferenceID").html();

  var ReferenceSDDocument = "";
  var SalesOrganization = "";
  var DistributionChannel = "";
  var OrganizationDivision = "";
  var SalesGroup = "";
  var SalesOffice = "";
  var SoldToParty = "";

  var date = new Date();

  var tunixTimeStamp = Math.floor(date.getTime());
  var formattedDateSet = "/Date(" + tunixTimeStamp + ")/";
  //var formattedDateSet = "/Date(" + tunixTimeStamp + "+0000)/";
  //var formattedDateSet = "/Date(" + "1695772800000" + ")/";

  var InvoiceNo = $("#lblinvoiceno").html();

  $("#tableList tbody tr").each(function () {
    var itemid = $(this).find("td:eq(1)").text();

    var itemquantity = $(this).find("td:eq(5) input").val();

    var material = $(this).find("td:eq(6)").text();

    ReferenceSDDocument = $(this).find("td:eq(7)").text();

    SalesOrganization = $(this).find("td:eq(8)").text();
    DistributionChannel = $(this).find("td:eq(9)").text();
    OrganizationDivision = $(this).find("td:eq(10)").text();
    SalesGroup = $(this).find("td:eq(11)").text();
    SalesOffice = $(this).find("td:eq(12)").text();
    SoldToParty = $(this).find("td:eq(13)").text();

    if ($(this).find("td:eq(0) input").is(":checked") == true) {
      if (Type == "SalesReturn") {
        var reqObj = {
          CustomerReturnItem: itemid,
          HigherLevelItem: "0",
          CustomerReturnItemCategory: "CBEN",
          Material: material,
          CustomerReturnItemText: "",
          RequestedQuantity: itemquantity,
          RequestedQuantityUnit: "KG",
          TransactionCurrency: "INR",
          NetAmount: "",
          MaterialGroup: "",
          Batch: "",
          ProductionPlant: "1100",
          StorageLocation: "",
          ShippingPoint: "",
          ShippingType: "",
          DeliveryPriority: "0",
          IncotermsClassification: "CFR",
          IncotermsTransferLocation: "",
          IncotermsLocation1: "",
          IncotermsLocation2: "",
          CustomerPaymentTerms: "0001",
          ProfitCenter: "1100",
          ReferenceSDDocument: "",
          ReferenceSDDocumentItem: "",
          SDProcessStatus: "C",
          Subtotal1Amount: "0",
          Subtotal2Amount: "0",
          Subtotal3Amount: "0",
          Subtotal4Amount: "0.00",
          Subtotal5Amount: "0.00",
          Subtotal6Amount: "0.00",
          to_PricingElement: [
            {
              PricingProcedureStep: "10",
              ConditionType: "PPR0",
              ConditionRateValue: "10",
            },
          ],
        };

        returnList.push(reqObj);
      } else {
        var reqObj = {
          Material: material,
          RequestedQuantity: "1",
          to_PricingElement: [
            {
              ConditionType: "PPR0",
              ConditionRateValue: itemquantity,
            },
          ],
        };

        returnList.push(reqObj);
      }
    }
  });

  if (returnList.length < 1) {
    Show_Error_Toastr("Error : Please Select Item");
    return;
  }

  if (Type == "SalesReturn") {
    var Method_Name = "Save";
    var APIEndPoint = "CustomerReturn";
    var url = "/Invoice/CustomerReturn";

    var data = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      CustomerReturn: "",
      CustomerReturnType: "CBRE",
      SalesOrganization: SalesOrganization,
      DistributionChannel: DistributionChannel,
      OrganizationDivision: OrganizationDivision,
      SalesGroup: SalesGroup,
      SalesOffice: SalesOffice,
      SalesDistrict: "",
      SoldToParty: SoldToParty,
      CreationDate: formattedDateSet,
      CreatedByUser: "CB9980000016",
      LastChangeDate: formattedDateSet,
      SenderBusinessSystemName: "",
      LastChangeDateTime: formattedDateSet,
      PurchaseOrderByCustomer: "",
      CustomerPurchaseOrderType: "",
      CustomerPurchaseOrderDate: formattedDateSet,
      CustomerReturnDate: formattedDateSet,
      TotalNetAmount: "0",
      NetAmount: "0",
      TransactionCurrency: "INR",
      SDDocumentReason: "102",
      PricingDate: formattedDateSet,
      RequestedDeliveryDate: formattedDateSet,
      ShippingType: "",
      HeaderBillingBlockReason: "",
      DeliveryBlockReason: "",
      IncotermsClassification: "CFR",
      IncotermsTransferLocation: "",
      IncotermsLocation1: "",
      IncotermsLocation2: "",
      IncotermsVersion: "",
      CustomerPaymentTerms: "0001",
      PaymentMethod: "",
      RetsMgmtProcess: "",
      ReferenceSDDocument: InvoiceNo,
      ReferenceSDDocumentCategory: "M",
      AccountingDocExternalReference: Document_ReferenceID,
      AssignmentReference: "",
      CustomerReturnApprovalReason: "",
      SalesDocApprovalStatus: "",
      RetsMgmtLogProcgStatus: "",
      RetsMgmtCompnProcgStatus: "",
      RetsMgmtProcessingStatus: "",
      OverallSDProcessStatus: "C",
      TotalCreditCheckStatus: "",
      OverallSDDocumentRejectionSts: "A",
      to_Item: returnList,
    };

    // console.log(data);

    Show_Loader();

    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: data,
      success: function (res) {
        var result = JSON.parse(res);

        var set_result = JSON.parse(result);

        // console.log(set_result);

        if (set_result.code == 1) {
          Hide_Loader();
          var currentDate = new Date();
          var formattedDate = currentDate.toISOString().slice(0, 10);

          Show_Success_Toastr("Sales Return Successfuly saved");

          HideContentDiv();
        } else {
          Hide_Loader();
          $("#modelEntryItem")
            // .modal({
            //   backdrop: "static",
            // })
            .modal("hide");
          Show_Error_Toastr("Error :" + set_result.CustomerReturn);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : details not found");
      },
    });
  } else {
    var Method_Name = "Save";
    var APIEndPoint = "CreditMemoReturn";
    var url = "/Invoice/CreditMemoRequest";

    var data = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      CreditMemoRequestType: "CR",
      SalesOrganization: SalesOrganization,
      DistributionChannel: DistributionChannel,
      OrganizationDivision: OrganizationDivision,
      ReferenceSDDocument: InvoiceNo,
      SoldToParty: SoldToParty,
      PurchaseOrderByCustomer: "",
      CustomerPaymentTerms: "",
      to_Partner: [
        {
          PartnerFunction: "SH",
          Customer: SoldToParty,
        },
      ],
      to_Item: returnList,
    };

    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/json",
      data: JSON.stringify(data),
      success: function (res) {
        var result = JSON.parse(res);

        var set_result = JSON.parse(result);

        // console.log(set_result);

        if (set_result.code == 1) {
          Hide_Loader();

          Show_Success_Toastr("Credit Memo Return Successfuly saved");

          var currentDate = new Date();
          var formattedDate = currentDate.toISOString().slice(0, 10);
          HideContentDiv();
        } else {
          Hide_Loader();
          $("#modelEntryItem")
            // .modal({
            //   backdrop: "static",
            // })
            .modal("hide");
          Show_Error_Toastr("Error :" + set_result.CustomerReturn);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : details not found");
      },
    });
  }
}

function CloseReturnEntry() {
  var invoiceno = $("#invoice_no").html();
  var invoice_amount = $("#invoice_amount").html();
  var invoice_date = $("#invoice_date").html();
  var invoice_paymentterm = $("#invoice_paymentterm").html();

  ShowContentDiv("Invoice", "InvoiceAdd", "", function () {
    // Initialization Code
    $("#lblEntryId").html();
    $("#lblAction").html("Edit");
    $("#divFooterDelete").hide();
    $("#txtSearchDealerName").select2();
    GetMaster("txtSearchDealerName", "Select Dealer Name", "GetDealer", "", ""); // Topmost Section

    $("#txtEntryInvoiceId").val(invoiceno);
    $("#txtEntryInvoiceAmount").val(invoice_amount);
    $("#txtEntryInvoiceDate").val(invoice_date);
    $("#txtEntryPaymentTerm").val(invoice_paymentterm);

    GetOneInvoice(invoiceno);
  });
}

function ShowPDFEntry(BillingDocument) {
  var APIEndPoint_1 = "GetInvoicePDF";
  var Method_Name_1 = "Get_One";
  var url_1 = "/Invoice/Invoice";
  var reqdata_1 = {
    method_name: Method_Name_1,
    invoice_no: BillingDocument,
    api_end_point: APIEndPoint_1,
  };
  Show_Loader();

  $.ajax({
    type: "POST",
    url: url_1,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata_1,
    success: function (result) {
      // var res = JSON.parse(result);
      // console.log(res);

      try {
        var res = JSON.parse(result);

        if (res) {
          var base64String = res;

          // Convert base64 string to a byte array
          var byteCharacters = atob(base64String);
          var byteNumbers = new Array(byteCharacters.length);
          for (var i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
          }

          var byteArray = new Uint8Array(byteNumbers);
          var blob = new Blob([byteArray], { type: "application/pdf" });

          // Create a Blob URL and open in a new tab
          var blobURL = URL.createObjectURL(blob);
          window.open(blobURL, "_blank");
        } else {
          Show_Error_Toastr("Invalid PDF data received.");
        }
      } catch (error) {
        Show_Error_Toastr("Error processing PDF response.");
      }
      Hide_Loader();
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });

  return;
}
