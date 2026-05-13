$(document).ready(function () {
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

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table

  $("#tableData").empty();

  var Dealer_Id = $("#ddlSearchDealerName").val();
  var dateRange = $("#txtSearchDeliveryDate").val();

  if (Dealer_Id == "") {
    $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
    return;
  }

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

  // $("#btn_Search").prop('disabled', true);

  var Method_Name = "Get";
  var url = "/Delivery/Delivery";
  var Api_End_Point = "GetDelivery";

  var reqdata = {
    method_name: Method_Name,
    org_id: "",
    user_id: "",
    user_name: "",
    dealer_id: Dealer_Id,
    start_date: formattedStartDate,
    end_date: formattedEndDate,
    api_end_point: Api_End_Point,
    is_active: 1,
    is_deleted: 0,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      var TableHTML = "";

      console.log(res_output);
      $.each(res_output, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML +=
          "<td style='width: 120px;'>" + value.DeliveryDocument + "</td>";
        TableHTML += "<td>" + value.ActualGoodsMovementDate + "</td>";
        TableHTML += "<td>" + value.OverallGoodsMovementStatus + "</td>";
        //TableHTML += "<td>" + value.CreatedByUser + "</td>";
        //TableHTML += "<td>" + value.CreationDate + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";

        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
          value.DeliveryDocument +
          "','" +
          value.ActualGoodsMovementDate +
          "','" +
          value.ShipToParty +
          "','" +
          value.CreatedByUser +
          "','" +
          value.TransportationGroup +
          "','" +
          value.SoldToParty +
          "','" +
          value.OrderID +
          "')\">";
        TableHTML += '<i class="fa fa-pencil"></i>';
        TableHTML += "</a>";

        TableHTML +=
          '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowPDFEntry(\'' +
          value.DeliveryDocument +
          '\')"><i class="fa fa-file-pdf-o"></i></a>';

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      // assign the html string to table body present in the search page
      $("#tableData").html(TableHTML);

      console.log(res_output);

      SetDataTable("tableSearch", [4], "Delivery");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function ShowEntry() {
  ShowContentDiv("Delivery", "ShowDelivery", "", function () {
    $("#ddlSearchDealerName").select2();

    $("#lblEntryId").html(); //for updating the record
    $("#lblAction").html("Edit");
  });
}

function ShowEditEntry(
  DeliveryDocument,
  creationDate,
  ShipToParty,
  CreatedByUser,
  TransportationGroup,
  SoldToParty,
  OrderID
) {
  ShowContentDiv("Delivery", "ShowDelivery", "", function () {
    $("#ddlSearchDealerName").select2();

    $("#lblEntryId").html(); //for updating the record
    $("#lblAction").html("Edit");
    $("#txtEntryDeliveryId").val(DeliveryDocument);
    $("#txtEntryDeliveryDate").val(creationDate);
    $("#txtEntryOrderId").val(OrderID);
    $("#txtEntryOrderDate").val(creationDate);
    $("#txtEntryTransporter").val(TransportationGroup);
    $("#txtEntryBuyer").val(SoldToParty);
    $("#txtEntryShipToParty").val(ShipToParty);
  });

  var Method_Name = "Get";
  var url = "/Delivery/Delivery";
  var Api_End_Point = "GetOneDelivery";

  var reqdata = {
    method_name: Method_Name,
    org_id: "",
    user_id: "",
    user_name: "",
    dealer_id: "",
    start_date: "",
    end_date: "",
    api_end_point: Api_End_Point,
    is_active: 1,
    is_deleted: 0,
    delivery_no: DeliveryDocument,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,

    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      var TableHTML = "";
      // Initialize an object to store grouped data
      var groupedData = {};

      // Initialize variables for total quantity and amount
      var totalQuantity = 0;
      var totalAmount = 0;
      var Row_No = 0;
      // Iterate through the response and group items based on Material
      // res_output.forEach(function (value) {
      //   // Check if the Material is in the specified list
      //   if (
      //     value.Material == "700000" ||
      //     value.Material == "700001" ||
      //     value.Material == "700002" ||
      //     value.Material == "700003" ||
      //     value.Material == "700004" ||
      //     value.Material == "700005" ||
      //     value.Material == "700006" ||
      //     value.Material == "700007" ||
      //     value.Material == "700008" ||
      //     value.Material == "700009" ||
      //     value.Material == "700010" ||
      //     value.Material == "700011" ||
      //     value.Material == "700012" ||
      //     value.Material == "700013" ||
      //     value.Material == "700014"
      //   ) {
      //     // Check if the Material already exists in groupedData
      //     if (groupedData.hasOwnProperty(value.Material)) {
      //       // If yes, update the BillingQuantity, NetAmount, BillingDocumentDate, and ItemWeightUnit
      //       groupedData[value.Material].BillingQuantity += parseFloat(
      //         value.BillingQuantity
      //       );
      //       // groupedData[value.Material].NetAmount += parseFloat(
      //       //   value.NetAmount
      //       // );
      //       // groupedData[value.Material].BillingDocumentDate =
      //       //   value.BillingDocumentDate;
      //       groupedData[value.Material].ItemWeightUnit = value.ItemWeightUnit;
      //       groupedData[value.Material].BillingDocumentItemText =
      //         value.BillingDocumentItemText;
      //     } else {
      //       // If not, initialize the Material in groupedData
      //       groupedData[value.Material] = {
      //         BillingQuantity: parseFloat(value.BillingQuantity),
      //         // NetAmount: parseFloat(value.NetAmount),
      //         NetAmount: 0,
      //         BillingDocumentDate: "",
      //         ItemWeightUnit: value.ItemWeightUnit,
      //         BillingDocumentItemText: value.BillingDocumentItemText,
      //         ReferenceSDDocument: value.ReferenceSDDocument,
      //       };
      //     }
      //     totalQuantity += parseFloat(value.BillingQuantity);
      //     // totalAmount += parseFloat(value.NetAmount);
      //     totalAmount += 0;
      //   } else {
      //     Row_No++;
      //     // If Material is not in the specified list, add it directly to the table
      //     totalQuantity += parseFloat(value.BillingQuantity);
      //     // totalAmount += parseFloat(value.NetAmount);
      //     totalAmount += 0;

      //     // Construct table row for non-grouped Material
      //     TableHTML += "<tr>";
      //     // TableHTML += "<td style=width: 85px;>" + value.BillingDocumentItem + "</td>";
      //     TableHTML += "<td style=width: 85px;>" + Row_No + "</td>";
      //     TableHTML += "<td>" + value.Material + "</td>";
      //     TableHTML += "<td>" + value.BillingDocumentItemText + "</td>";
      //     TableHTML += "<td>" + value.ReferenceSDDocument + "</td>";
      //     TableHTML += "<td>" + value.BillingDocumentDate + "</td>";
      //     TableHTML += "<td>" + value.BillingQuantity + "</td>";
      //     TableHTML += "<td>" + value.ItemWeightUnit + "</td>";
      //     // TableHTML += "<td>" + value.NetAmount + "</td>";
      //     TableHTML += "<td>----</td>";
      //     TableHTML += "</tr>";
      //   }
      // });

      // Iterate through the response and group items based on both Material and ItemWeightUnit
      res_output.forEach(function (value) {
        // Construct a unique key combining Material and ItemWeightUnit
        var set_Material = value.Material;
        const key = `${value.Material}_${value.ItemWeightUnit}`;

        // Check if the Material is in the specified list
        if (
          value.Material == "700000" ||
          value.Material == "700001" ||
          value.Material == "700002" ||
          value.Material == "700003" ||
          value.Material == "700004" ||
          value.Material == "700005" ||
          value.Material == "700006" ||
          value.Material == "700007" ||
          value.Material == "700008" ||
          value.Material == "700009" ||
          value.Material == "700010" ||
          value.Material == "700011" ||
          value.Material == "700012" ||
          value.Material == "700013" ||
          value.Material == "700014"
        ) {
          // Check if the combination of Material and ItemWeightUnit already exists in groupedData
          if (groupedData.hasOwnProperty(key)) {
            // If yes, update the BillingQuantity and other properties
            groupedData[key].BillingQuantity += parseFloat(
              value.BillingQuantity
            );
            groupedData[key].ItemWeightUnit = value.ItemWeightUnit;
            groupedData[key].BillingDocumentItemText =
              value.BillingDocumentItemText;
            groupedData[key].Material = set_Material;
          } else {
            // If not, initialize the entry for this unique combination in groupedData
            groupedData[key] = {
              BillingQuantity: parseFloat(value.BillingQuantity),
              NetAmount: 0,
              BillingDocumentDate: "",
              ItemWeightUnit: value.ItemWeightUnit,
              BillingDocumentItemText: value.BillingDocumentItemText,
              ReferenceSDDocument: value.ReferenceSDDocument,
              Material: set_Material,
            };
          }
          totalQuantity += parseFloat(value.BillingQuantity);
          totalAmount += 0;
        } else {
          Row_No++;
          totalQuantity += parseFloat(value.BillingQuantity);
          totalAmount += 0;

          // Construct table row for non-grouped Material
          TableHTML += "<tr>";
          TableHTML += "<td style=width: 85px;>" + Row_No + "</td>";
          TableHTML += "<td>" + value.Material + "</td>";
          TableHTML += "<td>" + value.BillingDocumentItemText + "</td>";
          TableHTML += "<td>" + value.ReferenceSDDocument + "</td>";
          TableHTML += "<td>" + value.BillingDocumentDate + "</td>";
          TableHTML += "<td>" + value.BillingQuantity + "</td>";
          TableHTML += "<td>" + value.ItemWeightUnit + "</td>";
          TableHTML += "<td>----</td>";
          TableHTML += "</tr>";
        }
      });

      // Fill data in table for grouped Materials

      Object.keys(groupedData).forEach(function (material) {
        var data = groupedData[material];
        Row_No++;

        TableHTML += "<tr>";
        TableHTML += "<td style=width: 85px;>" + Row_No + "</td>"; // Assuming Row_No starts from 1
        TableHTML += "<td>" + data.Material + "</td>";
        TableHTML += "<td>"; // Start of conditional logic for BillingDocumentItemText
        if (data.flag) {
          TableHTML +=
            data.BillingDocumentItemText +
            "<span class='text-red'>( RP )</span>";
        } else {
          TableHTML += data.BillingDocumentItemText;
        }
        TableHTML += "</td>"; // End of conditional logic for BillingDocumentItemText
        TableHTML += "<td>" + data.ReferenceSDDocument + "</td>";
        TableHTML += "<td>" + data.BillingDocumentDate + "</td>"; // Display BillingDocumentDate
        TableHTML += "<td>" + data.BillingQuantity + "</td>";
        TableHTML += "<td>" + data.ItemWeightUnit + "</td>"; // Display ItemWeightUnit
        // TableHTML += "<td>" + data.NetAmount + "</td>"; // Assuming you want to display NetAmount with 2 decimal places
        TableHTML += "<td>----</td>";
        TableHTML += "</tr>";
      });

      // Add total row
      TableHTML += "<tr>";
      TableHTML +=
        "<td style='width: 85px;' class='font-weight-bold'>TOTAL</td>";
      TableHTML += "<td>----</td>";
      TableHTML += "<td>----</td>";
      TableHTML += "<td>----</td>";
      TableHTML += "<td>----</td>";
      TableHTML += "<td class='font-weight-bold'>" + totalQuantity + "</td>";
      TableHTML += "<td>----</td>";
      TableHTML += "<td class='font-weight-bold'>" + totalAmount + "</td>"; // Assuming you want to display totalAmount with 2 decimal places
      TableHTML += "</tr>";

      $("#tableBillingItem").html(TableHTML);
    },

    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });

  var Method_Name = "Get";
  var url = "/Delivery/Delivery";
  var Api_End_Point = "GetDeliverydata";

  var reqdata = {
    method_name: Method_Name,
    org_id: "",
    user_id: "",
    user_name: "",
    dealer_id: "",
    start_date: "",
    end_date: "",
    api_end_point: Api_End_Point,
    is_active: 1,
    is_deleted: 0,
    delivery_no: DeliveryDocument,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      $.each(res_output, function (data, value) {
        if (value.TextElementDescription == "Loader Name") {
          $("#txtLoaderName").val(value.TextElementText);
        } else if (value.TextElementDescription == "Driver Name") {
          $("#txtDriverName").val(value.TextElementText);
        } else if (value.TextElementDescription == "Vehicle Number") {
          $("#txtVehiceno").val(value.TextElementText);
        } else if (value.TextElementDescription == "Transporter Name") {
          $("#txtTransporterName").val(value.TextElementText);
        } else if (value.TextElementDescription == "Vehicle Type") {
          $("#txtVehicleType").val(value.TextElementText);
        }
      });
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      $("#btn_Search").prop("disabled", false);
    },
  });

  //   GetSalesOrderByInvoice(DeliveryDocument);
  GetSalesOrderByInvoice(DeliveryDocument);
}

// function GetSalesOrderByDelivery(DeliveryDocument) {
//   var Method_Name = "Get";
//   var url = "/Delivery/Delivery";
//   var Api_End_Point = "GetSalesOrderByDelivery";

//   var reqdata = {
//     method_name: Method_Name,
//     org_id: "",
//     user_id: "",
//     user_name: "",
//     dealer_id: "",
//     start_date: "",
//     end_date: "",
//     api_end_point: Api_End_Point,
//     is_active: 1,
//     is_deleted: 0,
//     delivery_no: DeliveryDocument,
//   };

//   $.ajax({
//     type: "POST",
//     url: url,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata,

//     success: function (result) {
//       var res = JSON.parse(result);
//       var res_output = JSON.parse(res);
//       if (res_output.length > 0) {
//         // console.log(res_output[0].ReferenceSDDocument);
//         GetSalesOrderByInvoice(res_output[0].ReferenceSDDocument)
//       }
//     },

//     error: function () {
//       ShowItemError(
//         "Error in fetching details from server.",
//         res[0].result_description
//       );
//     },
//   });
// }

function GetSalesOrderByInvoice(DeliveryDocument) {
  ClearDataTable("tableInvoice");
  var Method_Name = "Get";
  var url = "/Delivery/Delivery";
  var Api_End_Point = "GetSalesOrderByInvoice";

  var reqdata = {
    method_name: Method_Name,
    org_id: "",
    user_id: "",
    user_name: "",
    dealer_id: "",
    start_date: "",
    end_date: "",
    api_end_point: Api_End_Point,
    is_active: 1,
    is_deleted: 0,
    delivery_no: DeliveryDocument,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,

    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      console.log(res_output);

      var TableHTML = "";

      $.each(res_output, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.BillingDocument + "</td>";
        TableHTML += "<td>" + value.BillingDocumentItemText + "</td>";

        TableHTML += "</tr>";
      });
      $("#tableInvoiceItem").html(TableHTML);
    },

    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function ShowPDFEntry(DeliveryDocument) {
  var APIEndPoint_1 = "GetDeliveryPDF";
  var Method_Name_1 = "Get_One";
  var url_1 = "/Delivery/Delivery";
  var reqdata_1 = {
    method_name: Method_Name_1,
    delivery_no: DeliveryDocument,
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
