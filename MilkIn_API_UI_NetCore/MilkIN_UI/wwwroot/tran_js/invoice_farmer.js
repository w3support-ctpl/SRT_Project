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

  // SetDataTable("tableSearch", [13], "Goods Inward Posting");
});

function GetSearchMCCName() {
  $("#dllSearchEntryMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#dllSearchEntryMCCType").val();
  GetMaster("dllSearchEntryMCC", "All MCC", "Get_MCC", "", MCCType_Id);
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}
/*  ----    ----    ----    Get Farmer Invoice data and assign it to the table on Search Page    ----    ----    ----    ----    */
function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetInvoiceFarmer";
  var Method_Name = "Get";
  var ApprovalStatus_Id = $("#ddlSearchSAPPostedStatus").val();
  var MCCType_Id = "%" + $("#dllSearchEntryMCCType").val() + "%";
  var MCC_Id = "%" + $("#dllSearchEntryMCC").val() + "%";
  var url = "/Invoice/InvoiceFarmer";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }

  var Status_Id = "";
  var SessionRoleId = $("#SessionRoleId").text().trim();
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
      var IncomeStatus = "";
      var DeductionStatus = "";
      $.each(res, function (data, value) {
        // if (value.is_posted == 1) {
        //   Status = "Posted";
        //   EditFlag = false;
        // } else {
        //   Status = "Pending";
        //   EditFlag = true;
        // }
        if (value.is_incomeposted == 0) {
          IncomeStatus = "Pending";
          // EditFlag = false;
        }
        if (value.is_incomeposted == 1) {
          IncomeStatus = "In Queue";
          // EditFlag = true;
        }
        if (value.is_incomeposted == 2) {
          IncomeStatus = "Posted";
          // EditFlag = true;
        }
        if (value.is_incomeposted == 3) {
          IncomeStatus = "Error";
          // EditFlag = true;
        }
        if (value.is_incomeposted == 4) {
          IncomeStatus = "";
          // EditFlag = true;
        }

        if (value.is_deductionposted == 0) {
          DeductionStatus = "Pending";
          // EditFlag = false;
        }
        if (value.is_deductionposted == 1) {
          DeductionStatus = "In Queue";
          // EditFlag = true;
        }
        if (value.is_deductionposted == 2) {
          DeductionStatus = "Posted";
          // EditFlag = true;
        }
        if (value.is_deductionposted == 3) {
          DeductionStatus = "Error";
          // EditFlag = true;
        }
        if (value.is_deductionposted == 4) {
          DeductionStatus = "";
          // EditFlag = true;
        }

        TableHTML += "<tr>";
        // TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += '<td style="width: 20px;">';
        TableHTML +=
          '<label class="custom-control custom-checkbox " for="chk' +
          value.invoice_id +
          '">';

        if (value.is_incomeposted == 0) {
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
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mustercycle + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.income_document + "</td>";
        TableHTML += "<td>" + value.deduction_document + "</td>";

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
        //     value.farmer_code +
        //     '");\'><i class="fa fa-plus mr-2"></i> Post</a>';
        //   TableHTML +=
        //     '<div style="display: none; class="dimmer active" id="loader' +
        //     value.invoice_id +
        //     '"><div class="lds-ring" style="margin: 0px !important;"><div></div><div></div><div></div><div></div></div></div>';
        // }

        // TableHTML += "</td>";
        // TableHTML += "<td>" + IncomeStatus + "</td>";
        // TableHTML += "<td>" + DeductionStatus + "</td>";

        if (value.is_incomeposted == 0) {
          TableHTML += "<td>" + IncomeStatus + "</td>";
        }
        if (value.is_incomeposted == 1) {
          TableHTML +=
            "<td><span class='label label-warning mt-2'>" +
            IncomeStatus +
            "</span></td>";
        }
        if (value.is_incomeposted == 2) {
          TableHTML +=
            "<td><span class='label label-success mt-2'>" +
            IncomeStatus +
            "</span></td>";
        }
        if (value.is_incomeposted == 3) {
          TableHTML +=
            "<td><span class='label label-danger mt-2'>" +
            IncomeStatus +
            "</span></td>";
        }
        if (value.is_incomeposted == 4) {
          TableHTML += "<td></td>";
        }

        if (value.is_deductionposted == 0) {
          TableHTML += "<td>" + DeductionStatus + "</td>";
        }
        if (value.is_deductionposted == 1) {
          TableHTML +=
            "<td><span class='label label-warning mt-2'>" +
            DeductionStatus +
            "</span></td>";
        }
        if (value.is_deductionposted == 2) {
          TableHTML +=
            "<td><span class='label label-success mt-2'>" +
            DeductionStatus +
            "</span></td>";
        }
        if (value.is_deductionposted == 3) {
          TableHTML +=
            "<td><span class='label label-danger mt-2'>" +
            DeductionStatus +
            "</span></td>";
        }
        if (value.is_deductionposted == 4) {
          TableHTML += "<td></td>";
        }
        // TableHTML += "<td hidden></td>";

        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";

        if (value.is_incomeposted == 0 && value.is_deductionposted == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseVoucherEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";
        }
        if (value.is_incomeposted == 3 && value.is_deductionposted == 2) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseIncomeEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";

          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Error" onclick="ErrorIncomeEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-exclamation-triangle"></i>';
          TableHTML += "</a>";
        }
        if (value.is_incomeposted == 2 && value.is_deductionposted == 3) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseDeductionEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";

          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Error" onclick="ErrorDeductionEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-exclamation-triangle"></i>';
          TableHTML += "</a>";
        }
        if (value.is_incomeposted == 3 && value.is_deductionposted == 4) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseIncomeEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";

          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Error" onclick="ErrorIncomeEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-exclamation-triangle"></i>';
          TableHTML += "</a>";
        }
        if (value.is_incomeposted == 4 && value.is_deductionposted == 3) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseDeductionEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";

          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Error" onclick="ErrorDeductionEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-exclamation-triangle"></i>';
          TableHTML += "</a>";
        }
        if (value.is_incomeposted == 3 && value.is_deductionposted == 3) {
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
        if (value.is_incomeposted == 2 && value.is_deductionposted == 2) {
        }
        if (value.is_incomeposted == 4 && value.is_deductionposted == 4) {
        }
        if (value.is_incomeposted == 1 && value.is_deductionposted == 1) {
        }
        if (value.is_incomeposted == 2 && value.is_deductionposted == 1) {
        }
        if (value.is_incomeposted == 1 && value.is_deductionposted == 2) {
        }

        if (
          value.is_incomeposted == 2 &&
          value.is_deductionposted == 2 &&
          SessionRoleId == "MU001"
        ) {
          TableHTML +=
            '<a style="color: #F5444C;" href="javascript:void(0);" class="btn btn-icon py-0" title="SAP Reverse" onclick="SAPReverseEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward "></i>';
          TableHTML += "</a>";
        }

        if (
          value.is_incomeposted == 2 &&
          value.is_deductionposted == 4 &&
          SessionRoleId == "MU001"
        ) {
          TableHTML +=
            '<a style="color: #F5444C;" href="javascript:void(0);" class="btn btn-icon py-0" title="SAP Reverse" onclick="SAPReverseEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward "></i>';
          TableHTML += "</a>";
        }
        if (
          value.is_incomeposted == 4 &&
          value.is_deductionposted == 2 &&
          SessionRoleId == "MU001"
        ) {
          TableHTML +=
            '<a style="color: #F5444C;" href="javascript:void(0);" class="btn btn-icon py-0" title="SAP Reverse" onclick="SAPReverseEntry(\'' +
            value.invoice_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward "></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [10], "Farmer Invoice");
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
  ShowContentDiv("Invoice", "FarmerAdd", "", function () {
    $('input[name="datefilter"]').daterangepicker({
      locale: {
        cancelLabel: "Clear",
        // "format": "DD/MM/YYYY",
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
    $("#txtSearchEntryMCCWorkType").select2();
    $("#txtSearchEntryMCC").select2();

    GetMaster("txtSearchEntryMCCType", "All MCC Type", "GetMCCType", "", "");
    GetMaster(
      "txtSearchEntryMCCWorkType",
      "All MCC Work Type",
      "GetMCCWorkType",
      "",
      ""
    );
  });
}

function GetMCCName() {
  $("#txtSearchEntryMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#txtSearchEntryMCCType").val();
  var MCCWorkType_Id = $("#txtSearchEntryMCCWorkType").val();
  if (
    MCCWorkType_Id == "" ||
    MCCWorkType_Id == null ||
    MCCWorkType_Id == undefined
  ) {
    GetMaster("txtSearchEntryMCC", "All MCC", "Get_MCC", "", MCCType_Id);
  } else {
    GetMasters(
      "txtSearchEntryMCC",
      "All MCC",
      "Get_MCC",
      "",
      MCCType_Id,
      MCCWorkType_Id
    );
  }
}
function GetSearchEntryList() {
  GetSearchEntryHideList();
}

function GetSearchEntryHideList() {
  var CheckMCCType_Id = $("#txtSearchEntryMCCType").val();
  var CheckMCCWorkType_Id = $("#txtSearchEntryMCCWorkType").val();

  if (
    CheckMCCType_Id == "" ||
    CheckMCCType_Id == null ||
    CheckMCCType_Id == undefined
  ) {
    $("#txtSearchEntryMCCType").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Select MCC Type.");
    return;
  }
  if (CheckMCCType_Id != "C014003") {
    if (
      CheckMCCWorkType_Id == "" ||
      CheckMCCWorkType_Id == null ||
      CheckMCCWorkType_Id == undefined
    ) {
      $("#txtSearchEntryMCCWorkType").addClass("is-invalid state-invalid");
      Show_Error_Toastr("Select MCC Work Type.");
      return;
    }
  }

  if (CheckMCCType_Id == "C014001" && CheckMCCWorkType_Id == "C023002") {
    var CheckMCC_Id = $("#txtSearchEntryMCC").val();
    if (CheckMCC_Id == "" || CheckMCC_Id == null || CheckMCC_Id == undefined) {
      IsValid = 0;
      $("#txtSearchEntryMCC").addClass("is-invalid state-invalid");
    }
    if (IsValid == 0) {
      // ShowEntryError("Invalid Input(s). Can't be saved.");
      Show_Error_Toastr("Select MCC Name.");
      return;
    }
  }
  if (CheckMCCType_Id == "C014002" && CheckMCCWorkType_Id == "C023002") {
    var CheckMCC_Id = $("#txtSearchEntryMCC").val();
    if (CheckMCC_Id == "" || CheckMCC_Id == null || CheckMCC_Id == undefined) {
      IsValid = 0;
      $("#txtSearchEntryMCC").addClass("is-invalid state-invalid");
    }
    if (IsValid == 0) {
      // ShowEntryError("Invalid Input(s). Can't be saved.");
      Show_Error_Toastr("Select MCC Name.");
      return;
    }
  }

  // Show_Loader();
  $("#loader").show();

  ClearDataTable("tableFarmer");
  ClearDataTable("tableFarmerShow");
  Search_Period = $("#txtSearchEntryDuration").val();
  var MCCType_Id = "%" + $("#txtSearchEntryMCCType").val() + "%";
  var MCC_Id = "%" + $("#txtSearchEntryMCC").val() + "%";
  var MCCWorkType_Id = "%" + $("#txtSearchEntryMCCWorkType").val() + "%";
  var APIEndPoint = "GetInvoiceFarmer";
  var Method_Name = "Get_Generate";
  var url = "/Invoice/InvoiceFarmer";
  var IsValid = 1;

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    mccworktype_id: MCCWorkType_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      // Hide_Loader();
      // $("#loader").hide();
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

        TableHTML += "<td>" + value.farmer_name + "</td>";
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
        TableHTML += "<td hidden>" + value.farmer_id + "</td>";
        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "<td hidden>" + value.startdate + "</td>";
        TableHTML += "<td hidden>" + value.enddate + "</td>";
        TableHTML += "<td hidden>" + value.is_voucher + "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntry").html(TableHTML);

      SetPagingDataTable("tableFarmer", [7], "Farmer Invoice");
      //   SetDataTable("tableFarmer", [1], "Farmer");
      GetSearchEntryShowList();
    },
    error: function () {
      // $("#loader").hide();
      // Hide_Loader();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SavePost(Amount, Invoice_Id, Farmer_Code) {
  // // console.log(Invoice_Id);
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
        var APIEndPoint = "SaveInvoiceFarmerInSap";
        var Method_Name = "Get_Voucher";
        var url = "/Invoice/InvoiceFarmer";
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
              Show_Success_Toastr("Farmer Invoice Posted successfully");
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
            Show_Error_Toastr("Error : Farmer Invoice not Posted");
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
    $("#tableFarmer #tableEntry .custom-control-input:not(:disabled)").prop(
      "checked",
      isChecked
    );
  });

  $(document).on(
    "click",
    "#tableFarmer #tableEntry .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tableFarmer #tableEntry .custom-control-input:not(:disabled)"
      );
      var selectedCheckboxes = $(
        "#tableFarmer #tableEntry .custom-control-input:checked:not(:disabled)"
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#selectAll").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}

function SelectAllShowCheckbox() {
  $("#selectAllShow").on("click", function () {
    var isChecked = $(this).prop("checked");
    $(
      "#tableFarmerShow #tableEntryShow .custom-control-input:not(:disabled)"
    ).prop("checked", isChecked);
  });

  $(document).on(
    "click",
    "#tableFarmerShow #tableEntryShow .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tableFarmerShow #tableEntryShow .custom-control-input:not(:disabled)"
      );
      var selectedCheckboxes = $(
        "#tableFarmerShow #tableEntryShow .custom-control-input:checked:not(:disabled)"
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#selectAllShow").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}
function CloseEntry() {
  HideContentDiv();
  GetSearchList();
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
//         $("#loader").show();
//         var XMLData = "";

//         XMLData += "<Invoice>";
//         $("#tableFarmer tbody tr").each(function () {
//           if ($(this).find("input[type='checkbox']").is(":checked")) {
//             XMLData += "<InvoiceItem>";
//             XMLData +=
//               "<Check_Id>" + $(this).find("td:eq(7)").text() + "</Check_Id>";
//             XMLData +=
//               "<Farmer_Id>" + $(this).find("td:eq(8)").text() + "</Farmer_Id>";
//             XMLData +=
//               "<MCC_Id>" + $(this).find("td:eq(9)").text() + "</MCC_Id>";
//             XMLData +=
//               "<StartDate>" + $(this).find("td:eq(10)").text() + "</StartDate>";
//             XMLData +=
//               "<EndDate>" + $(this).find("td:eq(11)").text() + "</EndDate>";
//             XMLData +=
//               "<Amount>" + $(this).find("td:eq(6) span").text() + "</Amount>";
//             XMLData +=
//               "<Is_Voucher>" +
//               $(this).find("td:eq(12)").text() +
//               "</Is_Voucher>";
//             XMLData += "</InvoiceItem>";
//           }
//         });

//         XMLData += "</Invoice>";

//         //Post it
//         var APIEndPoint = "SaveInvoiceFarmer";
//         var Method_Name = "Create";
//         var Search_Period = $("#txtSearchEntryDuration").val();
//         var url = "/Invoice/InvoiceFarmer";
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
//               $("#loader").hide();
//               Show_Success_Toastr("Farmer Invoice Generate successfully");

//               GetSearchEntryList();
//             } else {
//               $("#loader").hide();
//               Show_Error_Toastr("Error : " + result[0].result_description);
//             }
//           },
//           error: function () {
//             $("#loader").hide();
//             Show_Error_Toastr("Error : Farmer Invoice not Generate");
//             // $("#btn" + Entry_Id).show();
//             // $("#loader" + Entry_Id).hide();
//           },
//         });
//       }
//     }
//   );
// }
// function SaveEntry() {
//   var APIEndPoint_2 = "GetInvoiceFarmer";
//   var Method_Name_2 = "Locked";
//   var url_2 = "/Invoice/InvoiceFarmer";
//   var Search_Period_2 = $("#txtSearchEntryDuration").val();
//   var MCC_Id_2 = $("#txtSearchEntryMCC").val();

//   var reqdata_2 = {
//     method_name: Method_Name_2,
//     api_end_point: APIEndPoint_2,
//     search_period: Search_Period_2,
//     mcc_id: MCC_Id_2,
//   };

//   $.ajax({
//     type: "POST",
//     url: url_2,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata_2,
//     success: function (result) {
//       var res = JSON.parse(result);
//       // console.log(res);
//       var flags = res[0].is_locked;

//       if (flags == 0) {
//         var errorMsg =
//           "Farmer Income is not authorized for all days in the Muster Cycle.";
//         ShowEntryError(errorMsg);

//         return;
//       } else {
//         swal(
//           {
//             title: "Are you sure?",
//             text: "You won't be able to revert this!",
//             icon: "question",
//             type: "warning",
//             showCancelButton: true,
//             confirmButtonText: "Yes, generate it!",
//           },
//           function (result) {
//             if (result == true) {
//               $("#loader").show();
//               var XMLData = "";

//               XMLData += "<Invoice>";
//               $("#tableFarmer tbody tr").each(function () {
//                 if ($(this).find("input[type='checkbox']").is(":checked")) {
//                   XMLData += "<InvoiceItem>";
//                   XMLData +=
//                     "<Check_Id>" +
//                     $(this).find("td:eq(7)").text() +
//                     "</Check_Id>";
//                   XMLData +=
//                     "<Farmer_Id>" +
//                     $(this).find("td:eq(8)").text() +
//                     "</Farmer_Id>";
//                   XMLData +=
//                     "<MCC_Id>" + $(this).find("td:eq(9)").text() + "</MCC_Id>";
//                   XMLData +=
//                     "<StartDate>" +
//                     $(this).find("td:eq(10)").text() +
//                     "</StartDate>";
//                   XMLData +=
//                     "<EndDate>" +
//                     $(this).find("td:eq(11)").text() +
//                     "</EndDate>";
//                   XMLData +=
//                     "<Amount>" +
//                     $(this).find("td:eq(6) span").text() +
//                     "</Amount>";
//                   XMLData +=
//                     "<Is_Voucher>" +
//                     $(this).find("td:eq(12)").text() +
//                     "</Is_Voucher>";
//                   XMLData += "</InvoiceItem>";
//                 }
//               });

//               XMLData += "</Invoice>";

//               //Post it
//               var APIEndPoint = "SaveInvoiceFarmer";
//               var Method_Name = "Create";
//               var Search_Period = $("#txtSearchEntryDuration").val();
//               var url = "/Invoice/InvoiceFarmer";
//               var reqdata = {
//                 method_name: Method_Name,
//                 api_end_point: APIEndPoint,
//                 invoicedata: XMLData,
//                 invoice_id: Search_Period,
//               };

//               //Save
//               $.ajax({
//                 type: "POST",
//                 url: url,
//                 contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//                 data: reqdata,
//                 success: function (res) {
//                   var result = JSON.parse(res);
//                   if (result[0].result_id == 1) {
//                     $("#loader").hide();
//                     Show_Success_Toastr("Farmer Invoice Generate successfully");

//                     GetSearchEntryList();
//                   } else {
//                     $("#loader").hide();
//                     Show_Error_Toastr(
//                       "Error : " + result[0].result_description
//                     );
//                   }
//                 },
//                 error: function () {
//                   $("#loader").hide();
//                   Show_Error_Toastr("Error : Farmer Invoice not Generate");
//                   // $("#btn" + Entry_Id).show();
//                   // $("#loader" + Entry_Id).hide();
//                 },
//               });
//             }
//           }
//         );
//       }
//     },
//     error: function () {
//       ShowEntryError("Error occurred during validation.");
//     },
//   });
// }
// function NegativeSaveEntry() {
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
//         $("#loader").show();
//         var XMLData = "";

//         XMLData += "<Invoice>";
//         $("#tableFarmer tbody tr").each(function () {
//           if ($(this).find("input[type='checkbox']").is(":checked")) {
//             XMLData += "<InvoiceItem>";
//             XMLData +=
//               "<Check_Id>" + $(this).find("td:eq(7)").text() + "</Check_Id>";
//             XMLData +=
//               "<Farmer_Id>" + $(this).find("td:eq(8)").text() + "</Farmer_Id>";
//             XMLData +=
//               "<MCC_Id>" + $(this).find("td:eq(9)").text() + "</MCC_Id>";
//             XMLData +=
//               "<StartDate>" + $(this).find("td:eq(10)").text() + "</StartDate>";
//             XMLData +=
//               "<EndDate>" + $(this).find("td:eq(11)").text() + "</EndDate>";
//             XMLData +=
//               "<Amount>" + $(this).find("td:eq(6) span").text() + "</Amount>";
//             XMLData +=
//               "<Is_Voucher>" +
//               $(this).find("td:eq(12)").text() +
//               "</Is_Voucher>";
//             XMLData += "</InvoiceItem>";
//           }
//         });

//         XMLData += "</Invoice>";

//         //Post it
//         var APIEndPoint = "SaveInvoiceFarmer";
//         var Method_Name = "NCreate";
//         var Search_Period = $("#txtSearchEntryDuration").val();
//         var url = "/Invoice/InvoiceFarmer";
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
//               $("#loader").hide();
//               Show_Success_Toastr("Farmer Invoice Generate successfully");

//               GetSearchEntryList();
//             } else {
//               $("#loader").hide();
//               Show_Error_Toastr("Error : " + result[0].result_description);
//             }
//           },
//           error: function () {
//             $("#loader").hide();
//             Show_Error_Toastr("Error : Farmer Invoice not Generate");
//             // $("#btn" + Entry_Id).show();
//             // $("#loader" + Entry_Id).hide();
//           },
//         });
//       }
//     }
//   );
// }

function SaveEntry() {
  var APIEndPoint_2 = "GetInvoiceFarmer";
  var Method_Name_2 = "Lock";
  var url_2 = "/Invoice/InvoiceFarmer";
  var Search_Period_2 = $("#txtSearchEntryDuration").val();
  var MCC_Id_2 = $("#txtSearchEntryMCC").val();

  var reqdata_2 = {
    method_name: Method_Name_2,
    api_end_point: APIEndPoint_2,
    search_period: Search_Period_2,
    mcc_id: MCC_Id_2,
  };

  $.ajax({
    type: "POST",
    url: url_2,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata_2,
    success: function (result) {
      var res = JSON.parse(result);

      var flags = res[0].is_locked;

      if (flags == "0 0") {
        var errorMsg =
          "Farmer Income is not authorized for all days in the Muster Cycle.";
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
              // Stop the function

              var hasError = false;

              $("#tableFarmerShow tbody tr").each(function () {
                if ($(this).find("input[type='checkbox']").is(":checked")) {
                  var Amount = parseFloat($(this).find("td:eq(15)").text()); // Parse the amount as a float
                  if (Amount <= 50) {
                    // If amount is less than or equal to 50, show alert and set hasError to true
                    Show_Error_Toastr(
                      "Net Payable Amount should be greater than 50 for selected items."
                    );
                    hasError = true;
                    return false; // Exit the loop
                  }
                }
              });

              if (hasError) return;

              $("#loader").show();
              // var XMLData = "";

              // XMLData += "<Invoice>";
              // $("#tableFarmer tbody tr").each(function () {
              //   if ($(this).find("input[type='checkbox']").is(":checked")) {
              //     XMLData += "<InvoiceItem>";
              //     XMLData +=
              //       "<Check_Id>" +
              //       $(this).find("td:eq(7)").text() +
              //       "</Check_Id>";
              //     XMLData +=
              //       "<Farmer_Id>" +
              //       $(this).find("td:eq(8)").text() +
              //       "</Farmer_Id>";
              //     XMLData +=
              //       "<MCC_Id>" + $(this).find("td:eq(9)").text() + "</MCC_Id>";
              //     XMLData +=
              //       "<StartDate>" +
              //       $(this).find("td:eq(10)").text() +
              //       "</StartDate>";
              //     XMLData +=
              //       "<EndDate>" +
              //       $(this).find("td:eq(11)").text() +
              //       "</EndDate>";
              //     XMLData +=
              //       "<Amount>" +
              //       $(this).find("td:eq(6) span").text() +
              //       "</Amount>";
              //     XMLData +=
              //       "<Is_Voucher>" +
              //       $(this).find("td:eq(12)").text() +
              //       "</Is_Voucher>";
              //     XMLData += "</InvoiceItem>";
              //   }
              // });

              // XMLData += "</Invoice>";

              //Post it

              var XMLData = "<Invoice>";

              $("#tableFarmerShow tbody tr").each(function () {
                if ($(this).find("input[type='checkbox']").is(":checked")) {
                  var farmerId = $(this).find("td:eq(16)").text(); // Transporter ID from tableFarmerShow

                  // Look for corresponding row in tableFarmer
                  $("#tableFarmer tbody tr").each(function () {
                    var hiddenFarmerId = $(this).find("td:eq(8)").text();

                    if (hiddenFarmerId === farmerId) {
                      // Match found, add data to XML
                      XMLData += "<InvoiceItem>";
                      XMLData +=
                        "<Check_Id>" +
                        $(this).find("td:eq(7)").text() +
                        "</Check_Id>";
                      XMLData +=
                        "<Farmer_Id>" +
                        $(this).find("td:eq(8)").text() +
                        "</Farmer_Id>";
                      XMLData +=
                        "<MCC_Id>" +
                        $(this).find("td:eq(9)").text() +
                        "</MCC_Id>";
                      XMLData +=
                        "<StartDate>" +
                        $(this).find("td:eq(10)").text() +
                        "</StartDate>";
                      XMLData +=
                        "<EndDate>" +
                        $(this).find("td:eq(11)").text() +
                        "</EndDate>";
                      XMLData +=
                        "<Amount>" +
                        $(this).find("td:eq(6) span").text() +
                        "</Amount>";
                      XMLData +=
                        "<Is_Voucher>" +
                        $(this).find("td:eq(12)").text() +
                        "</Is_Voucher>";
                      XMLData += "</InvoiceItem>";
                    }
                  });
                }
              });

              XMLData += "</Invoice>";

              var APIEndPoint = "SaveInvoiceFarmer";
              var Method_Name = "Create";
              var Search_Period = $("#txtSearchEntryDuration").val();
              var url = "/Invoice/InvoiceFarmer";
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
                    $("#loader").hide();
                    Show_Success_Toastr("Farmer Invoice Generate successfully");

                    GetSearchEntryList();
                  } else {
                    $("#loader").hide();
                    Show_Error_Toastr(
                      "Error : " + result[0].result_description
                    );
                  }
                },
                error: function () {
                  $("#loader").hide();
                  Show_Error_Toastr("Error : Farmer Invoice not Generate");
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
function NegativeSaveEntry() {
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
        // var XMLData = "";

        // XMLData += "<Invoice>";
        // $("#tableFarmer tbody tr").each(function () {
        //   if ($(this).find("input[type='checkbox']").is(":checked")) {
        //     XMLData += "<InvoiceItem>";
        //     XMLData +=
        //       "<Check_Id>" + $(this).find("td:eq(7)").text() + "</Check_Id>";
        //     XMLData +=
        //       "<Farmer_Id>" + $(this).find("td:eq(8)").text() + "</Farmer_Id>";
        //     XMLData +=
        //       "<MCC_Id>" + $(this).find("td:eq(9)").text() + "</MCC_Id>";
        //     XMLData +=
        //       "<StartDate>" + $(this).find("td:eq(10)").text() + "</StartDate>";
        //     XMLData +=
        //       "<EndDate>" + $(this).find("td:eq(11)").text() + "</EndDate>";
        //     XMLData +=
        //       "<Amount>" + $(this).find("td:eq(6) span").text() + "</Amount>";
        //     XMLData +=
        //       "<Is_Voucher>" +
        //       $(this).find("td:eq(12)").text() +
        //       "</Is_Voucher>";
        //     XMLData += "</InvoiceItem>";
        //   }
        // });

        // XMLData += "</Invoice>";

        var XMLData = "<Invoice>";

        $("#tableFarmerShow tbody tr").each(function () {
          if ($(this).find("input[type='checkbox']").is(":checked")) {
            var farmerId = $(this).find("td:eq(16)").text(); // Transporter ID from tableFarmerShow

            // Look for corresponding row in tableFarmer
            $("#tableFarmer tbody tr").each(function () {
              var hiddenFarmerId = $(this).find("td:eq(8)").text();

              if (hiddenFarmerId === farmerId) {
                // Match found, add data to XML
                XMLData += "<InvoiceItem>";
                XMLData +=
                  "<Check_Id>" +
                  $(this).find("td:eq(7)").text() +
                  "</Check_Id>";
                XMLData +=
                  "<Farmer_Id>" +
                  $(this).find("td:eq(8)").text() +
                  "</Farmer_Id>";
                XMLData +=
                  "<MCC_Id>" + $(this).find("td:eq(9)").text() + "</MCC_Id>";
                XMLData +=
                  "<StartDate>" +
                  $(this).find("td:eq(10)").text() +
                  "</StartDate>";
                XMLData +=
                  "<EndDate>" + $(this).find("td:eq(11)").text() + "</EndDate>";
                XMLData +=
                  "<Amount>" +
                  $(this).find("td:eq(6) span").text() +
                  "</Amount>";
                XMLData +=
                  "<Is_Voucher>" +
                  $(this).find("td:eq(12)").text() +
                  "</Is_Voucher>";
                XMLData += "</InvoiceItem>";
              }
            });
          }
        });

        XMLData += "</Invoice>";
        //Post it
        var APIEndPoint = "SaveInvoiceFarmer";
        var Method_Name = "NCreate";
        var Search_Period = $("#txtSearchEntryDuration").val();
        var url = "/Invoice/InvoiceFarmer";
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
              $("#loader").hide();
              Show_Success_Toastr("Farmer Invoice Generate successfully");

              GetSearchEntryList();
            } else {
              $("#loader").hide();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            $("#loader").hide();
            Show_Error_Toastr("Error : Farmer Invoice not Generate");
            // $("#btn" + Entry_Id).show();
            // $("#loader" + Entry_Id).hide();
          },
        });
      }
    }
  );
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

        var APIEndPoint = "SaveInvoiceFarmer";
        var Method_Name = "SetFlag";
        var url = "/Invoice/InvoiceFarmer";
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
              Show_Success_Toastr("Farmer Invoice posted successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Farmer Invoice not posted");
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
  var APIEndPoint = "SaveInvoiceFarmer";
  var Method_Name = "Set_ReverseIncomeDeduction";
  var url = "/Invoice/InvoiceFarmer";
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
        Show_Success_Toastr("Farmer Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}
function ReverseIncomeEntry(invoice_id) {
  var APIEndPoint = "SaveInvoiceFarmer";
  var Method_Name = "Set_ReverseIncome";
  var url = "/Invoice/InvoiceFarmer";
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
        Show_Success_Toastr("Farmer Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}
function ReverseDeductionEntry(invoice_id) {
  var APIEndPoint = "SaveInvoiceFarmer";
  var Method_Name = "Set_ReverseDeduction";
  var url = "/Invoice/InvoiceFarmer";
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
        Show_Success_Toastr("Farmer Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}
function ReverseVoucherEntry(invoice_id) {
  var APIEndPoint = "SaveInvoiceFarmer";
  var Method_Name = "Set_ReverseVoucher";
  var url = "/Invoice/InvoiceFarmer";
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
        Show_Success_Toastr("Farmer Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}

function ErrorIncomeEntry(invoice_id) {
  $("#modelEntryFarmer")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#divEntryDeductionErrorMessage").hide();
  getIncomeDeduction(invoice_id);
}

function ErrorDeductionEntry(invoice_id) {
  $("#modelEntryFarmer")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#divEntryIncomeErrorMessage").hide();

  getErrorDeduction(invoice_id);
}
function ErrorIncomeDeductionEntry(invoice_id) {
  $("#modelEntryFarmer")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  getIncomeDeduction(invoice_id);
  getErrorDeduction(invoice_id);
}

function getIncomeDeduction(invoice_id) {
  $("#txtEntryIncomeErrorMessage").val("");
  var APIEndPoint = "GetInvoiceFarmer";
  var Method_Name = "GetIncomeError";
  var url = "/Invoice/InvoiceFarmer";
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

        $("#txtEntryIncomeErrorMessage").val(xmlDoc.error.message.value);
      } else {
        // Handle case where no result is returned
        // console.log("No error income found for the invoice.");
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Invoice not Reverse");
    },
  });
}

function getErrorDeduction(invoice_id) {
  $("#txtEntryDeductionErrorMessage").val("");
  var APIEndPoint = "GetInvoiceFarmer";
  var Method_Name = "GetDeductionError";
  var url = "/Invoice/InvoiceFarmer";
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

        $("#txtEntryDeductionErrorMessage").val(errorMessage);
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

        var APIEndPoint = "SaveInvoiceFarmer";
        var Method_Name = "SetFlagDummy";
        var url = "/Invoice/InvoiceFarmer";
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
              Show_Success_Toastr("Farmer Invoice posted successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Farmer Invoice not posted");
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

function GetSearchEntryShowList() {
  // $("#loader").show();
  ClearDataTable("tableFarmerShow");
  Search_Period = $("#txtSearchEntryDuration").val();
  var MCCType_Id = "%" + $("#txtSearchEntryMCCType").val() + "%";
  var MCC_Id = "%" + $("#txtSearchEntryMCC").val() + "%";
  var MCCWorkType_Id = "%" + $("#txtSearchEntryMCCWorkType").val() + "%";
  var APIEndPoint = "GetInvoiceFarmer";
  var Method_Name = "Get_GenerateSum";
  var url = "/Invoice/InvoiceFarmer";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    mccworktype_id: MCCWorkType_Id,
  };

  $.ajax({
    type: "POST",
    url: url,
    timeout: 0,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // Fill data in table
      var TableHTML = "";
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      // $("#loader").hide();
      var organizedData = {};
      res.forEach(function (entry) {
        var farmerCode = entry.farmer_code;
        var mccCode = entry.mcc_code;
        var startDate = entry.startdate;
        var endDate = entry.enddate;

        if (
          !organizedData[farmerCode] &&
          !organizedData[mccCode] &&
          !organizedData[startDate] &&
          !organizedData[endDate]
        ) {
          organizedData[farmerCode] = {
            farmer_code: farmerCode,
            farmer_id: entry.farmer_id,
            farmer_name: entry.farmer_name,
            mcc_code: mccCode,
            mcc_id: entry.mcc_id,
            mcc_name: entry.mcc_name,
            particulars: entry.mustercycle,
          };
        }
        organizedData[farmerCode][entry.entry_type.replace(/ /g, "_")] =
          Math.abs(entry.amount).toFixed(2);
      });
      for (var code in organizedData) {
        var entry = organizedData[code];
        [
          "Milk_Ltr",
          "Milk_Deposit",
          "Bank_Loan",
          "Dairy_Advance",
          "MCC_Advance",
          "Product_Sales",
          "Trading_Material",
          "Anamat",
          "Freight",
        ].forEach(function (type) {
          if (!entry[type]) {
            entry[type] = "0.00";
          }
        });
      }
      // Convert organized data to array
      var output = Object.values(organizedData);

      $.each(output, function (index, value) {
        var netAmount =
          parseFloat(value.Milk_Deposit) -
          parseFloat(value.Bank_Loan) -
          parseFloat(value.MCC_Advance) -
          parseFloat(value.Dairy_Advance) -
          parseFloat(value.Product_Sales) -
          parseFloat(value.Trading_Material) -
          parseFloat(value.Anamat) -
          parseFloat(value.Freight);
        var netDeduction =
          parseFloat(value.Bank_Loan) +
          parseFloat(value.MCC_Advance) +
          parseFloat(value.Dairy_Advance) +
          parseFloat(value.Product_Sales) +
          parseFloat(value.Trading_Material) +
          parseFloat(value.Anamat) +
          parseFloat(value.Freight);
        TableHTML += "<tr>";
        TableHTML += '<td class="text-right">';
        TableHTML += '<label class="custom-control custom-checkbox">';
        TableHTML +=
          '<input type="checkbox" class="custom-control-input" id="F_' +
          value.farmer_id +
          '" />';
        TableHTML +=
          '<label for="F_' +
          value.farmer_id +
          '" class="custom-control-label text-dark"></label>';
        TableHTML += "</label>";
        TableHTML += "</td>";
        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.particulars + "</td>";
        TableHTML += "<td>" + value.Milk_Ltr + "</td>";
        TableHTML += "<td>" + value.Milk_Deposit + "</td>";
        TableHTML += "<td>" + value.Anamat + "</td>";

        TableHTML += "<td>" + value.Bank_Loan + "</td>";

        TableHTML += "<td>" + value.Product_Sales + "</td>";
        TableHTML += "<td>" + value.Trading_Material + "</td>";
        TableHTML += "<td>" + value.Freight + "</td>";
        TableHTML += "<td>" + value.Dairy_Advance + "</td>";
        if (value.MCC_Advance != 0) {
          TableHTML +=
            "<td><a href='javascript:void(0)' class='btn btn-sm btn-link' onclick=\"OpenModal('" +
            value.farmer_id +
            "', '" +
            value.particulars +
            "')\">" +
            value.MCC_Advance +
            "</a></td>";
        } else {
          TableHTML += "<td>" + value.MCC_Advance + "</td>";
        }

        TableHTML += "<td>" + netDeduction.toFixed(2) + "</td>"; // Net Amount
        TableHTML += "<td>" + netAmount.toFixed(2) + "</td>"; // Net Amount

        TableHTML += "<td hidden>" + value.farmer_id + "</td>";
        TableHTML += "</tr>";
      });
      $("#loader").hide();
      $("#tableEntryShow").html(TableHTML);

      SetPagingDataTable("tableFarmerShow", [16], "Farmer Invoice");
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

// function GetSearchEntryShowList() {
//   // $("#loader").show();
//   ClearDataTable("tableFarmerShow");
//   Search_Period = $("#txtSearchEntryDuration").val();
//   var MCCType_Id = "%" + $("#txtSearchEntryMCCType").val() + "%";
//   var MCC_Id = "%" + $("#txtSearchEntryMCC").val() + "%";
//   var APIEndPoint = "GetInvoiceFarmer";
//   var Method_Name = "Get_GenerateSum_2";
//   var url = "/Invoice/InvoiceFarmer";

//   var reqdata = {
//     method_name: Method_Name,
//     api_end_point: APIEndPoint,
//     search_period: Search_Period,
//     mcc_id: MCC_Id,
//     mcctype_id: MCCType_Id,
//   };

//   $.ajax({
//     type: "POST",
//     url: url,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata,
//     // success: function (result) {
//     //   var res = JSON.parse(result);
//     //   // Fill data in table
//     //   var TableHTML = "";
//     //   var EditFlag = true; // IsEditAllowed($("#lblAS").html());
//     //   var Status = "";
//     //   // $("#loader").hide();
//     //   var organizedData = {};
//     //   res.forEach(function (entry) {
//     //     var farmerCode = entry.farmer_code;
//     //     var mccCode = entry.mcc_code;
//     //     var startDate = entry.startdate;
//     //     var endDate = entry.enddate;

//     //     if (
//     //       !organizedData[farmerCode] &&
//     //       !organizedData[mccCode] &&
//     //       !organizedData[startDate] &&
//     //       !organizedData[endDate]
//     //     ) {
//     //       organizedData[farmerCode] = {
//     //         farmer_code: farmerCode,
//     //         farmer_id: entry.farmer_id,
//     //         farmer_name: entry.farmer_name,
//     //         mcc_code: mccCode,
//     //         mcc_id: entry.mcc_id,
//     //         mcc_name: entry.mcc_name,
//     //         particulars: entry.mustercycle,
//     //       };
//     //     }
//     //     organizedData[farmerCode][entry.entry_type.replace(/ /g, "_")] =
//     //       Math.abs(entry.amount).toFixed(2);
//     //   });
//     //   for (var code in organizedData) {
//     //     var entry = organizedData[code];
//     //     [
//     //       "Milk_Ltr",
//     //       "Milk_Deposit",
//     //       "Bank_Loan",
//     //       "Dairy_Advance",
//     //       "MCC_Advance",
//     //       "Product_Sales",
//     //       "Trading_Material",
//     //       "Anamat",
//     //       "Freight",
//     //     ].forEach(function (type) {
//     //       if (!entry[type]) {
//     //         entry[type] = "0.00";
//     //       }
//     //     });
//     //   }
//     //   // Convert organized data to array
//     //   var output = Object.values(organizedData);

//     //   $.each(output, function (index, value) {
//     //     var netAmount =
//     //       parseFloat(value.Milk_Deposit) -
//     //       parseFloat(value.Bank_Loan) -
//     //       parseFloat(value.MCC_Advance) -
//     //       parseFloat(value.Dairy_Advance) -
//     //       parseFloat(value.Product_Sales) -
//     //       parseFloat(value.Trading_Material) -
//     //       parseFloat(value.Anamat) -
//     //       parseFloat(value.Freight);
//     //     var netDeduction =
//     //       parseFloat(value.Bank_Loan) +
//     //       parseFloat(value.MCC_Advance) +
//     //       parseFloat(value.Dairy_Advance) +
//     //       parseFloat(value.Product_Sales) +
//     //       parseFloat(value.Trading_Material) +
//     //       parseFloat(value.Anamat) +
//     //       parseFloat(value.Freight);
//     //     TableHTML += "<tr>";
//     //     TableHTML += '<td class="text-right">';
//     //     TableHTML += '<label class="custom-control custom-checkbox">';
//     //     TableHTML +=
//     //       '<input type="checkbox" class="custom-control-input" id="F_' +
//     //       value.farmer_id +
//     //       '" />';
//     //     TableHTML +=
//     //       '<label for="F_' +
//     //       value.farmer_id +
//     //       '" class="custom-control-label text-dark"></label>';
//     //     TableHTML += "</label>";
//     //     TableHTML += "</td>";
//     //     TableHTML += "<td>" + value.farmer_code + "</td>";
//     //     TableHTML += "<td>" + value.farmer_name + "</td>";
//     //     TableHTML += "<td>" + value.mcc_name + "</td>";
//     //     TableHTML += "<td>" + value.particulars + "</td>";
//     //     TableHTML += "<td>" + value.Milk_Ltr + "</td>";
//     //     TableHTML += "<td>" + value.Milk_Deposit + "</td>";
//     //     TableHTML += "<td>" + value.Anamat + "</td>";

//     //     TableHTML += "<td>" + value.Bank_Loan + "</td>";

//     //     TableHTML += "<td>" + value.Product_Sales + "</td>";
//     //     TableHTML += "<td>" + value.Trading_Material + "</td>";
//     //     TableHTML += "<td>" + value.Freight + "</td>";
//     //     TableHTML += "<td>" + value.Dairy_Advance + "</td>";
//     //     if (value.MCC_Advance != 0) {
//     //       TableHTML +=
//     //         "<td><a href='javascript:void(0)' class='btn btn-sm btn-link' onclick=\"OpenModal('" +
//     //         value.farmer_id +
//     //         "', '" +
//     //         value.particulars +
//     //         "')\">" +
//     //         value.MCC_Advance +
//     //         "</a></td>";
//     //     } else {
//     //       TableHTML += "<td>" + value.MCC_Advance + "</td>";
//     //     }

//     //     TableHTML += "<td>" + netDeduction.toFixed(2) + "</td>"; // Net Amount
//     //     TableHTML += "<td>" + netAmount.toFixed(2) + "</td>"; // Net Amount

//     //     TableHTML += "<td hidden>" + value.farmer_id + "</td>";
//     //     TableHTML += "</tr>";
//     //   });
//     //   $("#loader").hide();
//     //   $("#tableEntryShow").html(TableHTML);

//     //   SetPagingDataTable("tableFarmerShow", [16], "Farmer Invoice");
//     // },

//     success: function (result) {
//       var res = JSON.parse(result);

//       var TableHTML = "";
//       var EditFlag = true; // IsEditAllowed($("#lblAS").html());
//       var Status = "";
//       $.each(res, function (data, value) {
//         var netAmount =
//           parseFloat(value.milk_deposit) -
//           parseFloat(value.bank_loan) -
//           parseFloat(value.mcc_advance) -
//           parseFloat(value.dairy_advance) -
//           parseFloat(value.product_sales) -
//           parseFloat(value.trading_material) -
//           parseFloat(value.anamat) -
//           parseFloat(value.freight);
//         var netDeduction =
//           parseFloat(value.bank_loan) +
//           parseFloat(value.mcc_advance) +
//           parseFloat(value.dairy_advance) +
//           parseFloat(value.product_sales) +
//           parseFloat(value.trading_material) +
//           parseFloat(value.anamat) +
//           parseFloat(value.freight);

//         TableHTML += "<tr>";
//         TableHTML += '<td class="text-right">';
//         TableHTML += '<label class="custom-control custom-checkbox">';
//         TableHTML +=
//           '<input type="checkbox" class="custom-control-input" id="' +
//           value.farmer_id +
//           '" />';
//         TableHTML +=
//           '<label for="' +
//           value.farmer_id +
//           '" class="custom-control-label text-dark"></label>';
//         TableHTML += "</label>";
//         TableHTML += "</td>";

//         TableHTML += "<td>" + value.farmer_code + "</td>";
//         TableHTML += "<td>" + value.farmer_name + "</td>";
//         TableHTML += "<td>" + value.mcc_name + "</td>";
//         TableHTML += "<td>" + value.mustercycle + "</td>";
//         TableHTML += "<td>" + value.quality + "</td>";
//         TableHTML += "<td>" + value.milk_deposit + "</td>";
//         TableHTML += "<td>" + value.anamat + "</td>";

//         TableHTML += "<td>" + value.bank_loan + "</td>";

//         TableHTML += "<td>" + value.product_sales + "</td>";
//         TableHTML += "<td>" + value.trading_material + "</td>";
//         TableHTML += "<td>" + value.freight + "</td>";
//         TableHTML += "<td>" + value.dairy_advance + "</td>";

//         if (value.mcc_advance != 0) {
//           TableHTML +=
//             "<td><a href='javascript:void(0)' class='btn btn-sm btn-link' onclick=\"OpenModal('" +
//             value.farmer_id +
//             "', '" +
//             value.mustercycle +
//             "')\">" +
//             value.mcc_advance +
//             "</a></td>";
//         } else {
//           TableHTML += "<td>" + value.mcc_advance + "</td>";
//         }

//         TableHTML += "<td>" + netDeduction.toFixed(2) + "</td>"; // Net Amount
//         TableHTML += "<td>" + netAmount.toFixed(2) + "</td>"; // Net Amount
//         TableHTML += "<td hidden>" + value.farmer_id + "</td>";

//         TableHTML += "</tr>";
//       });
//       $("#loader").hide();
//       $("#tableEntryShow").html(TableHTML);

//       SetPagingDataTable("tableFarmerShow", [16], "Farmer Invoice");
//     },
//     error: function () {
//       $("#loader").hide();
//       Show_Error_Toastr(
//         "Error in fetching details from server.",
//         res[0].result_description
//       );
//     },
//   });
// }

function OpenModal(Farmer_Id, MusterCycle) {
  $("#lblDeductionsIdMCCAdvance").html("");
  $("#lblEntryIdMCCAdvance").html("");
  $("#lblAmountMCCAdvance").html("");

  $("#ddlEntryMCCAdvanceFarmer").val("");
  $("#txtEntryMCCAdvanceAmount").val("");

  $("#ddlEntryMCCAdvanceFarmer").select2();
  $("#modelEntryFarmerMCCAdvance")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  GetMaster(
    "ddlEntryMCCAdvanceFarmer",
    "Select Farmer",
    "GetFarmer",
    Farmer_Id,
    ""
  );

  var dates = MusterCycle.split(" - ");

  // Convert each date to the desired format
  var startDate = convertDateFormat(dates[0]);
  var endDate = convertDateFormat(dates[1]);

  var Search_Period = startDate + " - " + endDate;

  var APIEndPoint = "GetInvoiceFarmer";
  var Method_Name = "Get_MCCAdvance";
  var url = "/Invoice/InvoiceFarmer";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    farmer_id: Farmer_Id,
    search_period: Search_Period,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length > 0) {
        $("#lblDeductionsIdMCCAdvance").html(res[0].deductions_id);
        $("#lblEntryIdMCCAdvance").html(res[0].entry_id);
        $("#lblAmountMCCAdvance").html(res[0].amount);

        $("#txtEntryMCCAdvanceAmount").val(res[0].amount);
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function convertDateFormat(dateString) {
  // Convert month name to number
  var months = {
    Jan: "01",
    Feb: "02",
    Mar: "03",
    Apr: "04",
    May: "05",
    Jun: "06",
    Jul: "07",
    Aug: "08",
    Sep: "09",
    Oct: "10",
    Nov: "11",
    Dec: "12",
  };

  // Split the date string by space
  var parts = dateString.split(" ");

  // Get the day, month, and year
  var day = parts[0];
  var month = months[parts[1]];
  var year = parts[2];

  // Return the date in the desired format
  return month + "/" + day + "/" + year;
}

function SaveMCCAdvanceEntry() {
  var Deductions_Id = $("#lblDeductionsIdMCCAdvance").html();
  var Entry_Id = $("#lblEntryIdMCCAdvance").html();
  var Current_Amount = $("#lblAmountMCCAdvance").html();
  var Amount = $("#txtEntryMCCAdvanceAmount").val();
  var IsValid = 1;
  if (
    Amount == null ||
    Amount == undefined ||
    Is_Positive_Number_Greater_Than_Zero(Amount) == false ||
    Is_Valid_Float(Amount) == false
  ) {
    IsValid = 0;
    $("#txtEntryMCCAdvanceAmount").addClass("is-invalid state-invalid");
  }
  if (parseFloat(Amount) > parseFloat(Current_Amount)) {
    Show_Error_Toastr(
      "Updated details can't be saved as updated Amount are more than current Amount."
    );
    return;
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }
  Show_Loader();
  var APIEndPoint = "SaveDeductions";
  var Method_Name = "UpdateAmount";
  var url = "/Manage/Deductions";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    no_of_installments: 1,
    deductions_id: Deductions_Id,
    deduction_data: Entry_Id,
    amount: Amount,
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
        Hide_Loader();
        $("#modelEntryFarmerMCCAdvance").modal("hide");
        Show_Success_Toastr("Farmer MCC Advance Update successfully");
        GetSearchEntryList();
      } else {
        Hide_Loader();
        $("#modelEntryFarmerMCCAdvance").modal("hide");
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Hide_Loader();
      $("#modelEntryFarmerMCCAdvance").modal("hide");
      Show_Error_Toastr("Error : Farmer MCC Advance not Update");
    },
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
        var APIEndPoint = "SaveInvoiceFarmer";
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
        var url = "/Invoice/InvoiceFarmer";
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
        var APIEndPoint = "SaveInvoiceFarmer";
        var Method_Name = "Set_Pending";
        var url = "/Invoice/InvoiceFarmer";
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
              Show_Success_Toastr("Farmer Invoice SAP Reverse successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Farmer Invoice SAP not Reverse");
          },
        });
      }
    }
  );
}
