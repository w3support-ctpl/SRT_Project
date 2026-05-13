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
});

function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetInvoiceTransporter";
  var Method_Name = "Get";
  var ApprovalStatus_Id = $("#ddlSearchSAPPostedStatus").val();
  var url = "/Invoice/InvoiceTransporter";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }

  // // console.log(Search_Period);
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
      var IncomeStatus = "";
      var DeductionStatus = "";
      $.each(res, function (data, value) {
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
        // TableHTML += "<td></td>";
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
        TableHTML += "<td>" + value.transporter_name + "</td>";
        TableHTML += "<td>" + value.mustercycle + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.income_document + "</td>";
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
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";

        if (value.is_posted == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseVoucherEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";
        }
        if (value.is_posted == 1) {
        }
        if (value.is_posted == 2 && SessionRoleId == "MU001") {
          TableHTML +=
            '<a style="color: #F5444C;" href="javascript:void(0);" class="btn btn-icon py-0" title="SAP Reverse" onclick="SAPReverseEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward "></i>';
          TableHTML += "</a>";
        }
        if (value.is_posted == 3) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseIncomeDeductionEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";

          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Error" onclick="ErrorIncomeDeductionEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-exclamation-triangle"></i>';
          TableHTML += "</a>";
        }
        if (value.is_posted == 4) {
        }

        TableHTML += "</td>";

        TableHTML += "/tr>";
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
  ShowContentDiv("Invoice", "TransporterAdd", "", function () {
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
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function GetSearchEntryList() {
  GetSearchEntryHiddenList();
  GetSearchEntryShowList();
}

function GetSearchEntryHiddenList() {
  ClearDataTable("tableTransporterHidden");
  Search_Period = $("#txtSearchEntryDuration").val();
  var APIEndPoint = "GetInvoiceTransporter";
  var Method_Name = "Get_Generate";
  var url = "/Invoice/InvoiceTransporter";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
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

        TableHTML += "<td>" + value.transporter_name + "</td>";
        TableHTML += "<td>" + value.entry_type + "</td>";
        TableHTML += "<td>" + value.entry_on + "</td>";
        TableHTML += "<td>" + value.particulars + "</td>";
        if (value.is_voucher == "1") {
          TableHTML +=
            "<td><span class='badge badge-danger'>" +
            value.amount +
            "</span></td>";
        } else {
          TableHTML += "<td> <span>" + value.amount + "</span></td>";
        }
        TableHTML += "<td hidden>" + value.check_id + "</td>";
        TableHTML += "<td hidden>" + value.transporter_id + "</td>";
        TableHTML += "<td hidden>" + value.startdate + "</td>";
        TableHTML += "<td hidden>" + value.enddate + "</td>";
        TableHTML += "<td hidden>" + value.is_voucher + "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryHidden").html(TableHTML);

      SetPagingDataTable("tableTransporterHidden", [8], "Transporter Invoice");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function GetSearchEntryShowList() {
  $("#loader").show();
  ClearDataTable("tableTransporterShow");
  Search_Period = $("#txtSearchEntryDuration").val();
  var APIEndPoint = "GetInvoiceTransporter";
  var Method_Name = "Get_GenerateSum";
  var url = "/Invoice/InvoiceTransporter";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
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
      $("#loader").hide();
      var organizedData = {};
      res.forEach(function (entry) {
        var transporterCode = entry.transporter_code;
        if (!organizedData[transporterCode]) {
          organizedData[transporterCode] = {
            entry_on: entry.entry_on,
            transporter_code: transporterCode,
            transporter_id: entry.transporter_id,
            transporter_name: entry.transporter_name,
          };
        }
        organizedData[transporterCode][entry.entry_type.replace(/ /g, "_")] =
          Math.abs(entry.amount).toFixed(2);
      });
      for (var code in organizedData) {
        var entry = organizedData[code];
        [
          "Transporter",
          "Sec_Dep",
          // "Diesel_Recovery",
          "Advance",
          "Bank_Loan",
          "Can_Recovery_Charges",
          "TDS",
          "Cattle_Feed",
          "Labour_Charges",
          "Diesel_Rate_Diff",
          "Recovery_Amount",
          "Recovery_Ltr",
        ].forEach(function (type) {
          if (!entry[type]) {
            entry[type] = "0.00";
          }
        });
      }
      // Convert organized data to array
      var output = Object.values(organizedData);

      $.each(output, function (index, value) {
        if (parseFloat(value.Transporter) === 0) {
          value.Labour_Charges = "0.00";
        }
        var netAmount =
          parseFloat(value.Transporter) +
          parseFloat(value.Labour_Charges) +
          parseFloat(value.Cattle_Feed) -
          parseFloat(value.Sec_Dep) -
          parseFloat(value.Diesel_Rate_Diff) -
          // parseFloat(value.Diesel_Recovery) -
          parseFloat(value.Advance) -
          parseFloat(value.Bank_Loan) -
          parseFloat(value.Can_Recovery_Charges) -
          parseFloat(value.Recovery_Amount);

        TableHTML += "<tr>";
        TableHTML += '<td class="text-right">';
        TableHTML += '<label class="custom-control custom-checkbox">';
        TableHTML +=
          '<input type="checkbox" class="custom-control-input" id="T_' +
          value.transporter_id +
          '" />';
        TableHTML +=
          '<label for="T_' +
          value.transporter_id +
          '" class="custom-control-label text-dark"></label>';
        TableHTML += "</label>";
        TableHTML += "</td>";
        TableHTML += "<td>" + value.entry_on + "</td>";
        TableHTML += "<td>" + value.transporter_code + "</td>";
        TableHTML += "<td>" + value.transporter_name + "</td>";
        TableHTML += "<td>" + value.Transporter + "</td>";
        TableHTML += "<td>" + value.Labour_Charges + "</td>";
        // TableHTML += "<td>" + value.Recovery_Amount + "</td>";
        TableHTML += "<td>0.00</td>";
        TableHTML += "<td>" + value.Sec_Dep + "</td>";
        TableHTML += "<td>" + value.Cattle_Feed + "</</td>";
        TableHTML += "<td>" + value.Diesel_Rate_Diff + "</td>";
        // TableHTML += "<td>" + value.Diesel_Recovery + "</td>";
        TableHTML += "<td>" + value.Recovery_Ltr + "</td>";
        TableHTML += "<td>" + value.Recovery_Amount + "</td>";
        TableHTML += "<td>" + value.Advance + "</td>";
        TableHTML += "<td>" + value.Bank_Loan + "</td>";
        TableHTML += "<td>" + value.Can_Recovery_Charges + "</td>";
        TableHTML += "<td>" + netAmount.toFixed(2) + "</td>"; // Net Amount

        TableHTML += "<td hidden>" + value.transporter_id + "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntryShow").html(TableHTML);

      SetPagingDataTable("tableTransporterShow", [16], "Transporter Invoice");
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

function SaveEntry() {
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
        $("#loader").show();
        var XMLData = "<Invoice>";

        $("#tableTransporterShow tbody tr").each(function () {
          if ($(this).find("input[type='checkbox']").is(":checked")) {
            var transporterId = $(this).find("td:eq(16)").text(); // Transporter ID from tableTransporterShow
            var netPayable = parseFloat($(this).find("td:eq(15)").text());
            // Look for corresponding row in tableTransporterHidden
            $("#tableTransporterHidden tbody tr").each(function () {
              var hiddenTransporterId = $(this).find("td:eq(7)").text();
              if (hiddenTransporterId === transporterId && netPayable != 0) {
                // Match found, add data to XML
                XMLData += "<InvoiceItem>";
                XMLData +=
                  "<Check_Id>" +
                  $(this).find("td:eq(6)").text() +
                  "</Check_Id>";
                XMLData +=
                  "<Transporter_Id>" + transporterId + "</Transporter_Id>";
                XMLData +=
                  "<Amount>" +
                  $(this).find("td:eq(5) span").text() +
                  "</Amount>";
                XMLData +=
                  "<StartDate>" +
                  $(this).find("td:eq(8)").text() +
                  "</StartDate>";
                XMLData +=
                  "<EndDate>" + $(this).find("td:eq(9)").text() + "</EndDate>";
                XMLData +=
                  "<Is_Voucher>" +
                  $(this).find("td:eq(10)").text() +
                  "</Is_Voucher>";
                XMLData += "</InvoiceItem>";
              }
            });
          }
        });

        XMLData += "</Invoice>";

        //Post it
        var APIEndPoint = "SaveInvoiceTransporter";
        var Method_Name = "Create";

        var url = "/Invoice/InvoiceTransporter";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoicedata: XMLData,
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
              $("#loader").hide();
              Show_Success_Toastr("Transporter Invoice Generate successfully");

              GetSearchEntryList();
            } else {
              $("#loader").hide();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            $("#loader").hide();
            Show_Error_Toastr("Error : Transporter Invoice not Generate");
            //   $("#btn" + Entry_Id).show();
            //   $("#loader" + Entry_Id).hide();
          },
        });
      }
    }
  );
}

function SavePost(Amount, Invoice_Id, Transporter_Code) {
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
        var APIEndPoint = "SaveInvoiceTransporterInSap";
        var Method_Name = "Get_Voucher";
        var url = "/Invoice/InvoiceTransporter";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          invoice_id: Invoice_Id,
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
              Show_Success_Toastr("Transporter Invoice Posted successfully");
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
            Show_Error_Toastr("Error : Transporter Invoice not Posted");
            $("#btn" + Invoice_Id).show();
            $("#loader" + Invoice_Id).hide();
          },
        });
      }
    }
  );
}

function SelectAllCheckboxShow() {
  $("#selectAllShow").on("click", function () {
    var isChecked = $(this).prop("checked");
    $(
      "#tableTransporterShow #tableEntryShow .custom-control-input:not(:disabled)"
    ).prop("checked", isChecked);
  });

  $(document).on(
    "click",
    "#tableTransporterShow #tableEntryShow .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tableTransporterShow #tableEntryShow .custom-control-input:not(:disabled)"
      );
      var selectedCheckboxes = $(
        "#tableTransporterShow #tableEntryShow .custom-control-input:checked:not(:disabled)"
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#selectAllShow").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function ReverseVoucherEntry(invoice_id) {
  var APIEndPoint = "SaveInvoiceTransporter";
  var Method_Name = "Set_ReverseVoucher";
  var url = "/Invoice/InvoiceTransporter";
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
        Show_Success_Toastr("Transporter Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Transporter Invoice not Reverse");
    },
  });
}

function ErrorIncomeDeductionEntry(invoice_id) {
  $("#modelEntryTransporter")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  getErrorDeduction(invoice_id);
}

function getErrorDeduction(invoice_id) {
  $("#txtEntryIncomeErrorMessage").val("");
  var APIEndPoint = "SaveInvoiceTransporter";
  var Method_Name = "GetDeductionError";
  var url = "/Invoice/InvoiceTransporter";
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

        $("#txtEntryIncomeErrorMessage").val(errorMessage);
      } else {
        // Handle case where no result is returned
        // console.log("No error deduction found for the invoice.");
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}

function getErrorDeduction(invoice_id) {
  $("#txtEntryIncomeErrorMessage").val("");
  var APIEndPoint = "GetInvoiceTransporter";
  var Method_Name = "GetDeductionError";
  var url = "/Invoice/InvoiceTransporter";
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

        $("#txtEntryIncomeErrorMessage").val(errorMessage);
      } else {
        // Handle case where no result is returned
        // console.log("No error deduction found for the invoice.");
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}

function ShowPostEntry() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, approve it!",
    },
    function (result) {
      if (result == true) {
        if (checkedIds.length === 0) {
          Show_Error_Toastr("No items with status 'Pending' selected.");
          return;
        }

        var APIEndPoint = "SaveInvoiceTransporter";
        var Method_Name = "SetFlag";
        var url = "/Invoice/InvoiceTransporter";
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
              Show_Success_Toastr("Transporter Invoice Added successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Transporter Invoice not Added");
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

function ReverseIncomeDeductionEntry(invoice_id) {
  var APIEndPoint = "SaveInvoiceTransporter";
  var Method_Name = "Set_ReverseIncomeDeduction";
  var url = "/Invoice/InvoiceTransporter";
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
        Show_Success_Toastr("Transporter Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Transporter Invoice not Reverse");
    },
  });
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
        var APIEndPoint = "SaveInvoiceTransporter";
        var Method_Name = "Set_Pending";
        var url = "/Invoice/InvoiceTransporter";
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
              Show_Success_Toastr(
                "Transporter Invoice SAP Reverse successfully"
              );

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Transporter Invoice SAP not Reverse");
          },
        });
      }
    }
  );
}
