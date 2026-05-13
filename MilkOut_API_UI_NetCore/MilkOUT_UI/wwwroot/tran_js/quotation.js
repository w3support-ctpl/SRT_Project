$(document).ready(function () {
  $("#ddlSearchDealerName").select2();
  GetMaster("ddlSearchDealerName", "Select Dealer Name", "GetDealer", "", "");
  // SetDataTable("tableSearch", [9], "Quotation");
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
// function ShowEditEntry(Retailer_Id) {
//   ShowContentDiv("Quotation", "ShowOptionQuotation", "", function () {
//     // Initialization Code
//     var currentDate = new Date();
//     var formattedDate = currentDate.toISOString().slice(0, 10);
//     $("#txtEntryQuotationDate").val(formattedDate);

//     $("#lblEntryId").html(Retailer_Id);
//     $("#lblAction").html("EditQuotation");

//     // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
//     // GetMaster("ddlEntryState", "Select State", "GetState", "", "");
//     //GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");
//     $("#divFooterDelete").show();
//   });
// }

function ShowEditEntry(
  action,
  SalesQuotation,
  CreationDate,
  SalesQuotationType
) {
  ShowContentDiv("Quotation", "ShowOptionQuotation", "", function () {
    console.log(action, SalesQuotation, CreationDate, SalesQuotationType);
    if (action == "ADD") {
      $("#lblAction").html("ADD");
      var currentDate = new Date();
      var formattedDate = currentDate.toISOString().slice(0, 10);
      $("#txtEntryQuotationDate").val(formattedDate);

      $("#ddlEntrySalesArea").select2();
      $("#ddlEntryItemCode").select2();
    }
    if (action == "Edit") {
      $("#lblAction").html("Edit");
      $("#lblEntryId").html(SalesQuotation); //for updating the record
      $("#txtEntrySalesQuotation").val(SalesQuotation);
      $("#txtEntryQuotationDate").val(CreationDate);
      $("#txtEntryQuotationType").val(SalesQuotationType);

      ShowSalesQuotationItemTable(SalesQuotation);
    }

    $("#divFooterDelete").show();
  });
}

function ShowSalesQuotationItemTable(SalesQuotation) {
  ClearDataTable("tableItemDetailsList");
  var APIEndPoint = "GetOneQuotation";
  var Method_Name = "Get_One";
  var url = "/Quotation/Quotation";
  var reqdata = {
    method_name: Method_Name,
    quotation_id: SalesQuotation,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;

      $.each(res_output, function (data, value) {
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.SalesQuotationItem + "</td>";

        TableHTML += "<td>" + value.SalesQuotationItemCategory + "</td>";

        TableHTML += "<td>" + value.SalesQuotationItemText + "</td>";
        TableHTML += "<td>" + value.RequestedQuantity + "</td>";
        //TableHTML += "<td>" + value.ItemNetWeight + "</td>";
        TableHTML += "<td>" + value.RequestedQuantityUnit + "</td>";
        TableHTML += "<td>" + value.NetAmount + "</td>";
        TableHTML += "<td>" + value.TransactionCurrency + "</td>";

        TableHTML += "<td hidden></td>";
        // TableHTML +=
        //   '<td class="text-right" style="width: 160px; padding: 5px 3px 5px 3px;">';

        // TableHTML +=
        //   '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowRouteItemEditEntry(\'' +
        //   value.SalesQuotationItem +
        //   "')\">";
        // TableHTML += '<i class="fa fa-pencil"></i>';
        // TableHTML += "</a>";

        // TableHTML +=
        //   '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryRouteItem(\'' +
        //   value.SalesQuotationItem +
        //   "')\">";
        // TableHTML += '<i class="fa fa-trash"></i>';
        // TableHTML += "</a>";

        // TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntryItemDetails").html(TableHTML);
      SetDataTable("tableItemDetailsList", [8], "Sales Order Item");
      // $("#btn_Save_Item").prop("disabled", false);
      // $("#modelEntryRoute").modal("hide");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
      // $("#btn_Save_Item").prop("disabled", false);
    },
  });

  return;
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

// function GetSearchList(e) {
//     ClearDataTable("tableSearch");
//     // Validate Data
//     var Dealer_Id = "%" + $("#ddlSearchDealerName").val() + "%";
//     var Inquiry_Date = "%" + $("#txtSearchQuotationDeliveryDate").val() + "%";
//     $("#btn_Search").prop('disabled', true);
//     var Method_Name = 'Get';
//     // var APIEndPoint = "GetRetailer";
//     // var url = "/Masters/Retailer";
//     //var reqdata = {
//     //    "method_name": Method_Name,
//     //    "retailer_name": Retailer_Name,
//     //    "dealer_id": Dealer_Id,
//     //    "salesarea_id": SalesArea_Id,
//     //    "api_end_point": APIEndPoint

//     //};
//     //$.ajax({
//     //    type: 'POST',
//     //    url: url,
//     //    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
//     //    data: reqdata,
//     //    success: function (result) {
//     //        var res = JSON.parse(result);
//     //        // Fill data in table
//     //        var TableHTML = "";
//     //        var Row_No = 0;

//     //        var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

//     //        $.each(res, function (data, value) {
//     //            var Active_Status;
//     //            Row_No = Row_No + 1;
//     //            if (value.is_active == 0) {
//     //                Active_Status = "In-active";
//     //            }
//     //            else {
//     //                Active_Status = "Active";
//     //            }

//     //            TableHTML += "<tr>";
//     //            TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
//     //            TableHTML += "<td>" + value.retailer_name + "</td>";
//     //            TableHTML += "<td>" + value.dealer_name + "</td>";
//     //            TableHTML += "<td>" + value.salesarea_name + "</td>";
//     //            TableHTML += "<td>" + Active_Status + "</td>";
//     //            TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

//     //            if (EditFlag == true) {
//     //                TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowEditEntry('" + value.retailer_id + "')\">";
//     //                TableHTML += "<i class=\"fa fa-pencil\"></i>";
//     //                TableHTML += "</a>";
//     //            }

//     //            TableHTML += "</td>";
//     //            TableHTML += "</tr>";

//     //        });

//     //        $("#tableData").html(TableHTML);

//     //        SetDataTable("tableSearch", [5], "Retailer");
//     //        $("#btn_Search").prop('disabled', false);
//     //    },
//     //    error: function () {
//     //        Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
//     //        $("#btn_Search").prop('disabled', false);
//     //    }
//     //});

//     return;
// }

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  $("#tableData").empty();
  var Dealer_Id = $("#ddlSearchDealerName").val();

  var dateRange = $("#txtSearchQuotationDeliveryDate").val();

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
    $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
    IsValid = 0;
  }
  if (dateRange == "") {
    $("#txtSearchQuotationDeliveryDate").addClass("is-invalid state-invalid");
    IsValid = 0;
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid data. Can't search.");
    return;
  }
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var APIEndPoint = "GetQuotation";

  var url = "/Quotation/Quotation";

  var reqdata = {
    method_name: Method_Name,
    dealer_id: Dealer_Id,
    formattedStartDate: formattedStartDate,
    formattedEndDate: formattedEndDate,
    //   "search_period": dateRange,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // console.log(res);
      var res_output = JSON.parse(res);
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
        TableHTML += "<td>" + value.SalesQuotation + "</td>";
        TableHTML += "<td>" + value.SalesQuotationType + "</td>";
        TableHTML += "<td>" + value.CreationDate + "</td>";
        TableHTML += "<td>" + value.BindingPeriodValidityEndDate + "</td>";
        TableHTML += "<td>" + value.PurchaseOrderByCustomer + "</td>";
        TableHTML += "<td>" + value.OverallSDProcessStatus + "</td>";
        TableHTML += "<td>" + value.TotalNetAmount + "</td>";
        TableHTML += "<td>" + value.TransactionCurrency + "</td>";
        // if (EditFlag == 0) {
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
          value.SalesQuotation +
          "', '" +
          value.CreationDate +
          "', '" +
          value.SalesQuotationType +
          "')\">";
        TableHTML += '<i class="fa fa-eye"></i>';
        TableHTML += "</a>";

        TableHTML +=
          '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowPDFEntry(\'' +
          value.SalesQuotation +
          '\')"><i class="fa fa-file-pdf-o"></i></a>';

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [9], "Sales Order");
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

//function SaveDeleteEntry() {
//    // Write code to delete
//    var Retailer_Id = $("#lblEntryId").html();
//    // In success do following things
//    var Is_Deleted = 1;
//    // In success do following things
//    var APIEndPoint = "SaveRetailer";

//    var url = "/Masters/Retailer";

//    var reqdata = {
//        "retailer_id": Retailer_Id,
//        "is_deleted": Is_Deleted,
//        "method_name": "Delete",
//        "api_end_point": APIEndPoint
//    };
//    $.ajax({
//        type: 'POST',
//        url: url,
//        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
//        data: reqdata,
//        success: function (result) {
//            if (result[0].result_id == 1) {
//                // Show Success Message
//                Show_Success_Toastr("Retailer details deleted successfully");
//                GetSearchList();
//                CloseEntry();
//            } else {
//                Show_Error_Toastr("Error : " + result[0].result_description);
//            }
//        },
//        error: function () {
//            Show_Error_Toastr("Error : Vehicle details not deleted");
//        }
//    });
//}

function ShowPDFEntry(SalesQuotation) {
  var APIEndPoint_1 = "GetOneQuotationPDF";
  var Method_Name_1 = "Get_One";
  var url_1 = "/Quotation/Quotation";
  var reqdata_1 = {
    method_name: Method_Name_1,
    quotation_id: SalesQuotation,
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
