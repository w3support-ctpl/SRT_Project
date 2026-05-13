// $(document).ready(function () {
//   let port;

// //** Machine1  */
// $("#GetSearchList").click(async function () {
//   try {
//     port = await navigator.serial.requestPort();

//     await port.open({
//       baudRate: 9600,
//       dataBits: 8,
//       stopBits: 1,
//       parity: "none",
//     });

//     // Listen for incoming data
//     const reader = port.readable.getReader();
//     while (true) {
//       const { value, done } = await reader.read();
//       if (done) {
//         break;
//       }
//       // console.log(value);
//     }
//   } catch (error) {
//     console.error(error);
//   }
// });

//   //** Machine2  */
//   $("#GetSearchList").click(async function () {
//     try {
//       port = await navigator.serial.requestPort();

//       await port.open({
//         baudRate: 9600,
//         dataBits: 7,
//         stopBits: 1,
//         parity: "even",
//       });

//       // Listen for incoming data
//       const reader = port.readable.getReader();
//       while (true) {
//         const { value, done } = await reader.read();
//         if (done) {
//           break;
//         }
//         // console.log(value);
//       }
//     } catch (error) {
//       console.error(error);
//     }
//   });

//   //** Machine3  */
//   $("#GetSearchList").click(async function () {
//     try {
//       port = await navigator.serial.requestPort();

//       await port.open({
//         baudRate: 2400,
//         dataBits: 8,
//         stopBits: 1,
//         parity: "none",
//       });

//       // Listen for incoming data
//       const reader = port.readable.getReader();
//       while (true) {
//         const { value, done } = await reader.read();
//         if (done) {
//           break;
//         }
//         // console.log(value);
//       }
//     } catch (error) {
//       console.error(error);
//     }
//   });
// });

$(document).ready(function () {
  $("#ddlSearchSAPPostedStatus").select2();
  GetMaster(
    "ddlSearchSAPPostedStatus",
    "Select Posted Status",
    "GetSAPPosted",
    0,
    ""
  );

  var date = new Date().toISOString().slice(0, 10);
  $("#txtSearchDuration").val(date);

  $("#dllSearchEntryMCCType").select2();
  $("#dllSearchEntryMCC").select2();

  GetMaster("dllSearchEntryMCCType", "All MCC Type", "GetMCCType", "", "");
});

function GetSearchMCCName() {
  $("#dllSearchEntryMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#dllSearchEntryMCCType").val();
  GetMaster("dllSearchEntryMCC", "All MCC", "Get_MCC", "", MCCType_Id);
}
function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetInvoiceMCC";
  var Method_Name = "Get";
  var ApprovalStatus_Id = $("#ddlSearchSAPPostedStatus").val();
  var MCCType_Id = "%" + $("#dllSearchEntryMCCType").val() + "%";
  var MCC_Id = "%" + $("#dllSearchEntryMCC").val() + "%";
  var url = "/Invoice/InvoiceMCC";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  var SessionRoleId = $("#SessionRoleId").text().trim();

  var Status_Id = "";

  if (ApprovalStatus_Id == "") {
    Status_Id = "0";
  } else {
    Status_Id = ApprovalStatus_Id;
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    approvalstatus_id: Status_Id,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // Fill data in table
      var TableHTML = "";
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      // var IncomeStatus = "";
      // var DeductionStatus = "";
      $.each(res, function (data, value) {
        // if (value.is_posted == 1) {
        //   Status = "Posted";
        //   EditFlag = false;
        // } else {
        //   Status = "Pending";
        //   EditFlag = true;
        // }

        if (value.is_posted == 0) {
          Status = "Pending";
          // EditFlag = false;
        }
        if (value.is_posted == 1) {
          Status = "In Queue";
          // EditFlag = true;
        }
        if (value.is_posted == 2) {
          Status = "Posted";
          // EditFlag = true;
        }
        if (value.is_posted == 3) {
          Status = "Error";
          // EditFlag = true;
        }
        if (value.is_posted == 4) {
          Status = "";
          // EditFlag = true;
        }

        TableHTML += "<tr>";
        // TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += '<td style="width: 20px;">';
        TableHTML +=
          '<label class="custom-control custom-checkbox " for="chk' +
          value.invoice_id +
          '">';

        if (value.is_posted == 0) {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.invoice_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;" id="chk' +
            value.invoice_id +
            '">';
        } else {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.invoice_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;"  id="chk' +
            value.invoice_id +
            '" checked disabled>';
        }

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';
        TableHTML += "<td>" + value.invoice_date + "</td>";
        // TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mppitype_name + "</td>";
        TableHTML += "<td>" + value.mustercycle + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.income_document + "</td>";
        // TableHTML += "<td>" + Status + "</td>";
        // TableHTML += "<td>";
        // if (EditFlag) {
        //   TableHTML +=
        //     '<a href="javascript:void(0)" id="btn' +
        //     value.invoice_id +
        //     '" class="btn btn-primary btn-sm" onclick=\'SavePost("' +
        //     value.amount +
        //     '", "' +
        //     value.invoice_id +
        //     '", "' +
        //     value.mcc_code +
        //     '");\'><i class="fa fa-plus mr-2"></i> Post</a>';
        //   TableHTML +=
        //     '<div style="display: none; class="dimmer active" id="loader' +
        //     value.invoice_id +
        //     '"><div class="lds-ring" style="margin: 0px !important;"><div></div><div></div><div></div><div></div></div></div>';
        // }

        // TableHTML += "</td>";

        if (value.is_posted == 0) {
          TableHTML += "<td>" + Status + "</td>";
        }
        if (value.is_posted == 1) {
          TableHTML +=
            "<td><span class='label label-warning mt-2'>" +
            Status +
            "</span></td>";
        }
        if (value.is_posted == 2) {
          TableHTML +=
            "<td><span class='label label-success mt-2'>" +
            Status +
            "</span></td>";
        }
        if (value.is_posted == 3) {
          TableHTML +=
            "<td><span class='label label-danger mt-2'>" +
            Status +
            "</span></td>";
        }
        if (value.is_posted == 4) {
          TableHTML += "<td></td>";
        }

        TableHTML +=
          "<td class='text-right' style='width: 120px; padding:8px 5px 8px 5px;'>";

        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowViewEntry(\'' +
          value.invoice_id +
          "', '" +
          value.mppitype_id +
          "', '" +
          value.invoice_date +
          "', '" +
          value.mcc_name +
          "', '" +
          value.mppitype_name +
          "', '" +
          value.mustercycle +
          "', '" +
          value.amount +
          "')\">";
        TableHTML += '<i class="fa fa-eye"></i>';
        TableHTML += "</a>";

        if (value.is_posted == 0) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseVoucherEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";
        }
        if (value.is_posted == 3) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";

          if (value.mppitype_name == "MPPI") {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Error" onclick="ErrorIncomeEntry(\'' +
              value.invoice_id +
              "')\">";
            TableHTML += '<i class="fa fa-exclamation-triangle"></i>';
            TableHTML += "</a>";
          } else {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Error" onclick="ErrorDeductionEntry(\'' +
              value.invoice_id +
              "')\">";
            TableHTML += '<i class="fa fa-exclamation-triangle"></i>';
            TableHTML += "</a>";
          }
        }
        if (value.is_posted == 2 && SessionRoleId == "MU001") {
          TableHTML +=
            '| <a style="color: #F5444C;" href="javascript:void(0);" class="btn btn-icon py-0" title="SAP Reverse" onclick="SAPReverseEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward "></i>';
          TableHTML += "</a>";
        }
        if (value.is_posted == 4) {
        }
        if (value.is_posted == 1) {
        }

        TableHTML += "</td>";

        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [7], "MCC Invoice");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function ShowAddEntry() {
  ShowContentDiv("Invoice", "MCCAdd", "", function () {
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
    $("#txtSearchEntryMCCType").select2();
    $("#txtSearchEntryMCC").select2();

    GetMaster("txtSearchEntryMCCType", "All MCC Type", "GetMCCType", "", "");
  });
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function GetMCCName() {
  $("#txtSearchEntryMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#txtSearchEntryMCCType").val();
  GetMaster("txtSearchEntryMCC", "All MCC", "Get_MCC", "", MCCType_Id);
}

function GetSearchEntryList() {
  $("#loader").show();
  ClearDataTable("tableMCC");
  Search_Period = $("#txtSearchEntryDuration").val();
  var MCCType_Id = "%" + $("#txtSearchEntryMCCType").val() + "%";
  var MCC_Id = "%" + $("#txtSearchEntryMCC").val() + "%";
  var APIEndPoint = "GetInvoiceMCC";
  var Method_Name = "Get_Generate";
  var url = "/Invoice/InvoiceMCC";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      $("#loader").hide();
      // Fill data in table
      var TableHTML = "";
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += '<td class="text-right">';
        TableHTML += '<label class="custom-control custom-checkbox">';
        TableHTML +=
          '<input type="checkbox" class="custom-control-input" id="' +
          value.check_id +
          '" />';
        TableHTML +=
          '<label for="' +
          value.check_id +
          '" class="custom-control-label text-dark"></label>';
        TableHTML += "</label>";
        TableHTML += "</td>";

        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.entry_type + "</td>";
        TableHTML += "<td>" + value.entry_on + "</td>";
        TableHTML += "<td>" + value.particulars + "</td>";
        // TableHTML += "<td>" + value.milktype_name + "</td>";

        // TableHTML += "<td>" + value.quantity + "</td>";
        // TableHTML += "<td>" + value.rate + "</td>";
        if (value.is_voucher == "1") {
          TableHTML +=
            "<td><span class='badge badge-danger'>" +
            value.amount +
            "</span></td>";
        } else {
          TableHTML += "<td> <span>" + value.amount + "</span></td>";
        }

        // TableHTML += "<td>" + value.mustertype_name + "</td>";
        // TableHTML += "<td>" + value.mustercycle + "</td>";
        TableHTML += "<td hidden>" + value.check_id + "</td>";
        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "<td hidden>" + value.startdate + "</td>";
        TableHTML += "<td hidden>" + value.enddate + "</td>";
        TableHTML += "<td hidden>" + value.mppitype_id + "</td>";
        TableHTML += "<td hidden>" + value.is_voucher + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableEntry").html(TableHTML);

      // SetPagingDataTable("tableMCC", [], "MCC");
      SetPagingDataTable("tableMCC", [7], "MCC Invoice");
    },
    error: function () {
      $("#loader").hide();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

// function SaveEntry() {
//   swal(
//     {
//       title: "Are you sure?",
//       text: "You won't be able to revert this!",
//       icon: "question",
//       type: "warning",
//       showCancelButton: true,
//       confirmButtonText: "Yes, generate it!",
//     },
//     function (result) {
//       if (result == true) {
//         var XMLData = "";

//         XMLData += "<Invoice>";
//         $("#tableMCC tbody tr").each(function () {
//           if ($(this).find("input[type='checkbox']").is(":checked")) {
//             XMLData += "<InvoiceItem>";
//             XMLData +=
//               "<Check_Id>" + $(this).find("td:eq(6)").text() + "</Check_Id>";
//             XMLData +=
//               "<MCC_Id>" + $(this).find("td:eq(7)").text() + "</MCC_Id>";
//             XMLData +=
//               "<StartDate>" + $(this).find("td:eq(8)").text() + "</StartDate>";
//             XMLData +=
//               "<EndDate>" + $(this).find("td:eq(9)").text() + "</EndDate>";
//             XMLData +=
//               "<Amount>" + $(this).find("td:eq(5) span").text() + "</Amount>";
//             XMLData +=
//               "<Is_Voucher>" +
//               $(this).find("td:eq(11)").text() +
//               "</Is_Voucher>";
//             XMLData +=
//               "<MPPIType_Id>" +
//               $(this).find("td:eq(10)").text() +
//               "</MPPIType_Id>";
//             XMLData += "</InvoiceItem>";
//           }
//         });
//         XMLData += "</Invoice>";
//         //Post it
//         var APIEndPoint = "SaveInvoiceMCC";
//         var Method_Name = "Create";
//         var Search_Period = $("#txtSearchEntryDuration").val();
//         var url = "/Invoice/InvoiceMCC";
//         var reqdata = {
//           method_name: Method_Name,
//           api_end_point: APIEndPoint,
//           invoicedata: XMLData,
//           invoice_id: Search_Period,
//         };

//         //Save
//         $.ajax({
//           type: "POST",
//           url: url,
//           contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//           data: reqdata,
//           success: function (res) {
//             var result = JSON.parse(res);
//             if (result[0].result_id == 1) {
//               Show_Success_Toastr("MCC Invoice Generate successfully");

//               GetSearchEntryList();
//             } else {
//               Show_Error_Toastr("Error : " + result[0].result_description);
//             }
//           },
//           error: function () {
//             Show_Error_Toastr("Error : MCC Invoice not Generate");
//             // $("#btn" + Entry_Id).show();
//             // $("#loader" + Entry_Id).hide();
//           },
//         });
//       }
//     }
//   );
// }

function SaveEntry() {
  var APIEndPoint_2 = "GetInvoiceMCC";
  var Method_Name_2 = "Lock";
  var url_2 = "/Invoice/InvoiceMCC";
  var Search_Period_2 = $("#txtSearchEntryDuration").val();
  var MCC_Id_2 = $("#txtSearchEntryMCC").val();
  var MCCType_Id_2 = $("#txtSearchEntryMCCType").val();
  var reqdata_2 = {
    method_name: Method_Name_2,
    api_end_point: APIEndPoint_2,
    search_period: Search_Period_2,
    mcc_id: MCC_Id_2,
    mcctype_id: MCCType_Id_2,
  };

  $.ajax({
    type: "POST",
    url: url_2,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata_2,
    success: function (result) {
      var res = JSON.parse(result);

      var flags = res[0].is_locked;

      if (flags != "1") {
        var errorMsg =
          "MCC Income is not authorized for all days in the Muster Cycle.";
        ShowEntryError(errorMsg);

        return;
      } else {
        swal(
          {
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "question",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, generate it!",
          },
          function (result) {
            if (result == true) {
              var XMLData = "";
      
              XMLData += "<Invoice>";
              $("#tableMCC tbody tr").each(function () {
                if ($(this).find("input[type='checkbox']").is(":checked")) {
                  XMLData += "<InvoiceItem>";
                  XMLData +=
                    "<Check_Id>" + $(this).find("td:eq(6)").text() + "</Check_Id>";
                  XMLData +=
                    "<MCC_Id>" + $(this).find("td:eq(7)").text() + "</MCC_Id>";
                  XMLData +=
                    "<StartDate>" + $(this).find("td:eq(8)").text() + "</StartDate>";
                  XMLData +=
                    "<EndDate>" + $(this).find("td:eq(9)").text() + "</EndDate>";
                  XMLData +=
                    "<Amount>" + $(this).find("td:eq(5) span").text() + "</Amount>";
                  XMLData +=
                    "<Is_Voucher>" +
                    $(this).find("td:eq(11)").text() +
                    "</Is_Voucher>";
                  XMLData +=
                    "<MPPIType_Id>" +
                    $(this).find("td:eq(10)").text() +
                    "</MPPIType_Id>";
                  XMLData += "</InvoiceItem>";
                }
              });
              XMLData += "</Invoice>";
              //Post it
              var APIEndPoint = "SaveInvoiceMCC";
              var Method_Name = "Create";
              var Search_Period = $("#txtSearchEntryDuration").val();
              var url = "/Invoice/InvoiceMCC";
              var reqdata = {
                method_name: Method_Name,
                api_end_point: APIEndPoint,
                invoicedata: XMLData,
                invoice_id: Search_Period,
              };
      
              //Save
              $.ajax({
                type: "POST",
                url: url,
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                data: reqdata,
                success: function (res) {
                  var result = JSON.parse(res);
                  if (result[0].result_id == 1) {
                    Show_Success_Toastr("MCC Invoice Generate successfully");
      
                    GetSearchEntryList();
                  } else {
                    Show_Error_Toastr("Error : " + result[0].result_description);
                  }
                },
                error: function () {
                  Show_Error_Toastr("Error : MCC Invoice not Generate");
                  // $("#btn" + Entry_Id).show();
                  // $("#loader" + Entry_Id).hide();
                },
              });
            }
          }
        );
      }
    },
    error: function () {
      ShowEntryError("Error occurred during validation.");
    },
  });
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function SavePost(Amount, Invoice_Id, MCC_Code) {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, post it!",
    },
    function (result) {
      if (result == true) {
        $("#btn" + Invoice_Id).hide();
        $("#loader" + Invoice_Id).show();
        //Post it
        var APIEndPoint = "SaveInvoiceMCCInSap";
        var Method_Name = "Get_Voucher";
        var url = "/Invoice/InvoiceMCC";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoice_id: Invoice_Id,
        };

        // console.log(reqdata);
        //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
              Show_Success_Toastr("MCC Invoice Posted successfully");
              $("#btn" + Invoice_Id).hide();
              $("#loader" + Invoice_Id).hide();
              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);

              $("#btn" + Invoice_Id).show();
              $("#loader" + Invoice_Id).hide();
            }
          },
          error: function () {
            Show_Error_Toastr("Error : MCC Invoice not Posted");
            $("#btn" + Invoice_Id).show();
            $("#loader" + Invoice_Id).hide();
          },
        });
      }
    }
  );
}

function SelectAllCheckbox() {
  $("#selectAll").on("click", function () {
    var isChecked = $(this).prop("checked");
    $("#tableMCC #tableEntry .custom-control-input:not(:disabled)").prop(
      "checked",
      isChecked
    );
  });

  $(document).on(
    "click",
    "#tableMCC #tableEntry .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tableMCC #tableEntry .custom-control-input:not(:disabled)"
      );
      var selectedCheckboxes = $(
        "#tableMCC #tableEntry .custom-control-input:checked:not(:disabled)"
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#selectAll").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}

function ShowViewEntry(
  Invoice_Id,
  MPPIType_Id,
  invoice_date,
  mcc_name,
  mppitype_name,
  mustercycle,
  amount
) {
  ShowContentDiv("Invoice", "MCCView", "", function () {
    // $("#divContentView").show();

    $("#txtEntryVoucherDate").val(invoice_date);
    $("#txtEntryMCCName").val(mcc_name);
    $("#txtEntryType").val(mppitype_name);
    $("#txtEntryMusterCycle").val(mustercycle);
    $("#txtEntryAmount").val(amount);

    $("#divGainLoss").hide();
    $("#divMPPI").hide();
    $("#showDetails").html("");

    if (MPPIType_Id == "C047001") {
      $("#showDetails").html("MPPI");
      $("#divGainLoss").hide();
      $("#divMPPI").show();
      GetMPPIList(Invoice_Id);
    }
    if (MPPIType_Id == "C047003") {
      $("#showDetails").html("Gain - Loss");
      $("#divGainLoss").show();
      $("#divMPPI").hide();
      GetGainLossList(Invoice_Id);
    }
  });
}

function GetGainLossList(Invoice_Id) {
  ClearDataTable("tableGainLossList");

  var url = "/Invoice/InvoiceMCC";

  var APIEndPoint = "GetInvoiceMCC";
  var Method_Name = "Get_GainLoss";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    invoice_id: Invoice_Id,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var Row_No = 0;
      var TableHTML = "";
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.collection_date + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.agent_quantity_kg + "</td>";
        TableHTML += "<td>" + value.agent_quantity_ltr + "</td>";
        TableHTML += "<td>" + value.agent_fat + "</td>";
        TableHTML += "<td>" + value.agent_snf + "</td>";
        TableHTML += "<td>" + value.agent_fat_kg + "</td>";
        TableHTML += "<td>" + value.agent_snf_kg + "</td>";

        TableHTML += "<td>" + value.dairy_quantity_kg + "</td>";
        TableHTML += "<td>" + value.dairy_quantity_ltr + "</td>";
        TableHTML += "<td>" + value.dairy_fat + "</td>";
        TableHTML += "<td>" + value.dairy_snf + "</td>";
        TableHTML += "<td>" + value.dairy_fat_kg + "</td>";
        TableHTML += "<td>" + value.dairy_snf_kg + "</td>";

        TableHTML += "<td>" + value.fatkg_gainloss + "</td>";
        TableHTML += "<td>" + value.snfkg_gainloss + "</td>";
        TableHTML += "<td>" + value.fatkg_rate + "</td>";
        TableHTML += "<td>" + value.snfkg_rate + "</td>";
        if (value.total_gainloss < 0) {
          TableHTML +=
            "<td><span class='badge badge-danger'>" +
            value.total_gainloss +
            "</span></td>";
        } else {
          TableHTML += "<td>" + value.total_gainloss + "</td>";
        }

        TableHTML += "<td hidden></td>";

        TableHTML += "</tr>";
      });

      $("#tableGainLossData").html(TableHTML);

      SetDataTable("tableGainLossList", [21], "MCCGainLoss");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
  return;
}

function GetMPPIList(Invoice_Id) {
  ClearDataTable("tableMPPIList");

  var url = "/Invoice/InvoiceMCC";

  var APIEndPoint = "GetInvoiceMCC";
  var Method_Name = "Get_MPPI";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    invoice_id: Invoice_Id,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var Row_No = 0;
      var TableHTML = "";
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.collection_date + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";

        TableHTML += "<td>" + value.dairy_quantity_ltr + "</td>";
        TableHTML += "<td>" + value.rate + "</td>";
        TableHTML += "<td>" + value.agentcost + "</td>";
        TableHTML += "<td hidden></td>";

        TableHTML += "</tr>";
      });

      $("#tableMPPIData").html(TableHTML);

      SetDataTable("tableMPPIList", [7], "MCCMPPI");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
  return;
}

function SelectAllInvoiceCheckbox() {
  $("#selectAllInvoice").on("click", function () {
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
      $("#selectAllInvoice").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}

function ShowPostEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, post it!",
    },
    function (result) {
      if (result == true) {
        if (checkedIds.length === 0) {
          Show_Error_Toastr("No items with status 'Pending' selected.");
          return;
        }

        var APIEndPoint = "SaveInvoiceMCC";
        var Method_Name = "SetFlag";
        var url = "/Invoice/InvoiceMCC";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoice_id: checkedIds.join(),
        };

        //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
              Show_Success_Toastr("MCC Invoice Added successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : MCC Invoice not Added");
          },
        });
      }
    }
  );
  var checkedIds = [];

  $('#tableSearch input[type="checkbox"]:checked').each(function () {
    var checkboxId = $(this).attr("id");
    var idWithoutPrefix = checkboxId.replace("chk", "");

    // Check if the checkbox is disabled
    if (!$(this).is(":disabled")) {
      checkedIds.push(idWithoutPrefix);
    }
  });
}

function ReverseVoucherEntry(invoice_id) {
  var APIEndPoint = "SaveInvoiceMCC";
  var Method_Name = "Set_ReverseVoucher";
  var url = "/Invoice/InvoiceMCC";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    invoice_id: invoice_id,
  };
  //Save
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        Show_Success_Toastr("MCC Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : MCC Invoice not Reverse");
    },
  });
}

function ReverseEntry(invoice_id) {
  var APIEndPoint = "SaveInvoiceMCC";
  var Method_Name = "Set_ReverseMCC";
  var url = "/Invoice/InvoiceMCC";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    invoice_id: invoice_id,
  };
  //Save
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        Show_Success_Toastr("MCC Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : MCC Invoice not Reverse");
    },
  });
}

function ErrorIncomeEntry(invoice_id) {
  $("#modelEntryMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  getIncomeDeduction(invoice_id);
}

function ErrorDeductionEntry(invoice_id) {
  $("#modelEntryMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  getErrorDeduction(invoice_id);
}

function getIncomeDeduction(invoice_id) {
  $("#txtEntryErrorMessage").val("");
  var APIEndPoint = "GetInvoiceMCC";
  var Method_Name = "GetIncomeError";
  var url = "/Invoice/InvoiceMCC";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    invoice_id: invoice_id,
  };
  //Save
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      if (result.length > 0) {
        var xmlString = result[0].response_body;
        var xmlDoc = JSON.parse(xmlString);

        $("#txtEntryErrorMessage").val(xmlDoc.error.message.value);
      } else {
        // Handle case where no result is returned
        // console.log("No error found for the invoice.");
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}

function getErrorDeduction(invoice_id) {
  $("#txtEntryErrorMessage").val("");
  var APIEndPoint = "GetInvoiceMCC";
  var Method_Name = "GetDeductionError";
  var url = "/Invoice/InvoiceMCC";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    invoice_id: invoice_id,
  };
  //Save
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      if (result.length > 0) {
        var xmlString = result[0].response_body;
        var xmlDoc = $.parseXML(xmlString);

        var notes = $(xmlDoc)
          .find("Item Note")
          .map(function () {
            return $(this).text();
          })
          .get();
        var errorMessage = notes.join(" , ");

        $("#txtEntryErrorMessage").val(errorMessage);
      } else {
        // Handle case where no result is returned
        // console.log("No error found for the invoice.");
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}

function ShowDummyPostEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, mark it as posted!",
    },
    function (result) {
      if (result == true) {
        if (checkedIds.length === 0) {
          Show_Error_Toastr("No items with status 'Pending' selected.");
          return;
        }

        var APIEndPoint = "SaveInvoiceMCC";
        var Method_Name = "SetFlagDummy";
        var url = "/Invoice/InvoiceMCC";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoice_id: checkedIds.join(),
        };

        //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
              Show_Success_Toastr("MCC Invoice posted successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : MCC Invoice not posted");
          },
        });
      }
    }
  );
  var checkedIds = [];

  $('#tableSearch input[type="checkbox"]:checked').each(function () {
    var checkboxId = $(this).attr("id");
    var idWithoutPrefix = checkboxId.replace("chk", "");

    // Check if the checkbox is disabled
    if (!$(this).is(":disabled")) {
      checkedIds.push(idWithoutPrefix);
    }
  });
}

function MusterCycleSaveEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, generate it!",
    },
    function (result) {
      if (result == true) {
        // debugger;

        //Post it
        var APIEndPoint = "SaveInvoiceMCC";
        var Method_Name = "Set_MusterCycle";
        var IsValid = 1;
        var Search_Period = $("#txtSearchEntryDuration").val();
        var MCC_Id = $("#txtSearchEntryMCC").val();

        if (
          Search_Period == "" ||
          Search_Period == null ||
          Search_Period == undefined
        ) {
          IsValid = 0;
          Show_Error_Toastr("Select Entry Period.");
          $("#txtSearchEntryDuration").addClass("is-invalid state-invalid");

          return;
        }
        if (MCC_Id == "" || MCC_Id == null || MCC_Id == undefined) {
          IsValid = 0;
          Show_Error_Toastr("Select MCC Name.");
          $("#txtSearchEntryMCC").addClass("is-invalid state-invalid");
          return;
        }
        // if (IsValid == 0) {
        //   Show_Error_Toastr("Invalid Input(s). Can't be saved.");
        //   return;
        // }
        $("#loader").show();
        var url = "/Invoice/InvoiceMCC";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoice_id: Search_Period,
          sap_document_id: MCC_Id,
        };

        // return

        // Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
              $("#loader").hide();
              Show_Success_Toastr("Muster Cycle Updated successfully");

              GetSearchEntryList();
            } else {
              $("#loader").hide();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            $("#loader").hide();
            Show_Error_Toastr("Error : Farmer Invoice not Generate");
          },
        });
      }
    }
  );
}

function SAPReverseEntry(invoice_id) {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, post it!",
    },
    function (result) {
      if (result == true) {
        var APIEndPoint = "SaveInvoiceMCC";
        var Method_Name = "Set_Pending";
        var url = "/Invoice/InvoiceMCC";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoice_id: invoice_id,
        };
        //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
              Show_Success_Toastr("MCC Invoice SAP Reverse successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : MCC Invoice SAP not Reverse");
          },
        });
      }
    }
  );
}
