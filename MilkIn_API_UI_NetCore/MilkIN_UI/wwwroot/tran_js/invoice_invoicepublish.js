$(document).ready(function () {
  $('input[name="datefilter"]').daterangepicker({
    locale: {
      cancelLabel: "Clear",
      format: "DD MMM YYYY",
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

  $("#txtSearchPeriodHidden").val(
    moment().subtract(30, "days").format("MM/DD/YYYY") +
      " - " +
      moment().format("MM/DD/YYYY")
  );

  $('input[name="datefilter"]').on(
    "apply.daterangepicker",
    function (ev, picker) {
      $(this).val(
        picker.startDate.format("DD MMM YYYY") +
          " - " +
          picker.endDate.format("DD MMM YYYY")
      );
      $("#txtSearchPeriodHidden").val(
        picker.startDate.format("MM/DD/YYYY") +
          " - " +
          picker.endDate.format("MM/DD/YYYY")
      );
    }
  );

  $("#dllSearchMCCType").select2();
  $("#dllSearchMCC").select2();
  $("#dllSearchVoucherType").select2();

  GetMaster("dllSearchMCCType", "All MCC Type", "GetMCCType", "", "");
  GetMaster(
    "dllSearchVoucherType",
    "Select Invoice Type",
    "GetUserType",
    "",
    ""
  );

  var date = new Date().toISOString().slice(0, 10);
  $("#tab1txtSearchPeriod").val(date);

  $("#tab1dllSearchMCCType").select2();
  $("#tab1dllSearchMCCWorkType").select2();
  $("#tab1dllSearchMCC").select2();

  GetMaster("tab1dllSearchMCCType", "All MCC Type", "GetMCCType", "", "");
  GetMaster(
    "tab1dllSearchMCCWorkType",
    "All MCC Work Type",
    "GetMCCWorkType",
    "",
    ""
  );

  $("#tab1dllSearchVoucherType").select2();

  GetMaster(
    "tab1dllSearchVoucherType",
    "Select Invoice Type",
    "GetUserType",
    "",
    ""
  );

  var date = new Date().toISOString().slice(0, 10);
  $("#tab2txtSearchPeriod").val(date);

  $("#tab2dllSearchMCCType").select2();
  $("#tab2dllSearchMCCWorkType").select2();
  $("#tab2dllSearchMCC").select2();

  GetMaster("tab2dllSearchMCCType", "All MCC Type", "GetMCCType", "", "");
  GetMaster(
    "tab2dllSearchMCCWorkType",
    "All MCC Work Type",
    "GetMCCWorkType",
    "",
    ""
  );

  $("#tab2dllSearchVoucherType").select2();

  GetMaster(
    "tab2dllSearchVoucherType",
    "Select Invoice Type",
    "GetUserType",
    "",
    ""
  );
});

function GetMCCName() {
  $("#tab1dllSearchMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#tab1dllSearchMCCType").val();
  var MCCWorkType_Id = $("#tab1dllSearchMCCWorkType").val();
  if (
    MCCWorkType_Id == "" ||
    MCCWorkType_Id == null ||
    MCCWorkType_Id == undefined
  ) {
    GetMaster("tab1dllSearchMCC", "All MCC", "Get_MCC", "", MCCType_Id);
  } else {
    GetMasters(
      "tab1dllSearchMCC",
      "All MCC",
      "Get_MCC",
      "",
      MCCType_Id,
      MCCWorkType_Id
    );
  }
}

function tab2GetMCCName() {
  $("#tab2dllSearchMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#tab2dllSearchMCCType").val();
  var MCCWorkType_Id = $("#tab2dllSearchMCCWorkType").val();
  if (
    MCCWorkType_Id == "" ||
    MCCWorkType_Id == null ||
    MCCWorkType_Id == undefined
  ) {
    GetMaster("tab2dllSearchMCC", "All MCC", "Get_MCC", "", MCCType_Id);
  } else {
    GetMasters(
      "tab2dllSearchMCC",
      "All MCC",
      "Get_MCC",
      "",
      MCCType_Id,
      MCCWorkType_Id
    );
  }
}

function GetSearchMCCName() {
  $("#dllSearchMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#dllSearchMCCType").val();
  GetMaster("dllSearchMCC", "All MCC", "Get_MCC", "", MCCType_Id);
}

function OnDurationChnage() {
  ClearDataTable("tab1tableSearch");

  $("#tab1txtSearchPeriod").removeClass("is-invalid state-invalid");

  ClearDataTable("tab2tableSearch");

  $("#tab2txtSearchPeriod").removeClass("is-invalid state-invalid");
}

function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  var Search_Period = $("#txtSearchPeriodHidden").val();
  var VoucherType_Id = $("#dllSearchVoucherType").val();
  var APIEndPoint = "GetInvoicePublish";
  var Method_Name = "Get";
  var MCCType_Id = "%" + $("#dllSearchMCCType").val() + "%";
  var MCC_Id = "%" + $("#dllSearchMCC").val() + "%";
  var url = "/Invoice/InvoicePublish";
  var IsValid = 1;
  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    IsValid = 0;
    $("#txtSearchPeriod").addClass("is-invalid state-invalid");
  }
  if (
    VoucherType_Id == "" ||
    VoucherType_Id == null ||
    VoucherType_Id == undefined
  ) {
    IsValid = 0;
    $("#dllSearchVoucherType").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    vouchertype_id: VoucherType_Id,
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
      var Status = "";
      $.each(res, function (data, value) {
        if (value.is_published == 1) {
          Status = "Yes";
        }
        if (value.is_published == 0) {
          Status = "No";
        }
        TableHTML += "<tr>";
        TableHTML += '<td style="width: 20px;">';
        TableHTML +=
          '<label class="custom-control custom-checkbox " for="chk' +
          value.invoice_id +
          '">';

        TableHTML +=
          '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
          value.invoice_id +
          '"';
        TableHTML +=
          'style="vertical-align:sub; text-align: center;" id="chk' +
          value.invoice_id +
          '">';

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';

        TableHTML += "<td>" + value.invoice_date + "</td>";
        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mcctype_name + "</td>";

        TableHTML += "<td>" + value.invoice_no + "</td>";

        TableHTML += "<td>" + value.mustercycle + "</td>";

        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.generated_date + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [12], "Invoice Publish");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function ShowGenerateInvoice() {
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

        var APIEndPoint = "SaveInvoicePublish";
        var Method_Name = "Generate";
        var VoucherType_Id = $("#dllSearchVoucherType").val();
        var url = "/Invoice/InvoicePublish";
        var Search_Period = $("#tab1txtSearchPeriod").val();
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          vouchertype_id: VoucherType_Id,
          invoice_id: checkedIds.join(),
          search_period: Search_Period,
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
              Show_Success_Toastr("Invoice Generate Added successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Invoice Generate not Added");
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

function ShowPublishInvoice() {
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

        var APIEndPoint = "SaveInvoicePublish";
        var Method_Name = "Publish";
        var VoucherType_Id = $("#dllSearchVoucherType").val();
        var url = "/Invoice/InvoicePublish";
        var Search_Period = $("#tab1txtSearchPeriod").val();
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          vouchertype_id: VoucherType_Id,
          invoice_id: checkedIds.join(),
          search_period: Search_Period,
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
              Show_Success_Toastr("Invoice Publish Added successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Invoice Publish not Added");
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

function ShowDownloadInvoice() {
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

        var APIEndPoint = "GetInvoicePublish";
        var Method_Name = "Download";
        var VoucherType_Id = $("#dllSearchVoucherType").val();
        var url = "/Invoice/CreateZipFile";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          vouchertype_id: VoucherType_Id,
          invoice_id: checkedIds.join(),
        };
        //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            window.location.href = "/Invoice/DownloadInvoiceFile";
          },
          error: function () {
            Show_Error_Toastr("Error : Invoice Publish not Added");
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

function tab1SelectAllInvoiceCheckbox() {
  $("#tab1selectAllInvoice").on("click", function () {
    var isChecked = $(this).prop("checked");
    $(
      "#tab1tableSearch #tab1tableData .custom-control-input:not(:disabled)"
    ).prop("checked", isChecked);
  });

  $(document).on(
    "click",
    "#tab1tableSearch #tab1tableData .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tab1tableSearch #tab1tableData .custom-control-input:not(:disabled)"
      );
      var selectedCheckboxes = $(
        "#tab1tableSearch #tab1tableData .custom-control-input:checked:not(:disabled)"
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#tab1selectAllInvoice").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}
function GetSearchMCCList() {
  ClearDataTable("tab1tableSearch");
  $("#tab1tableData").empty();
  var Search_Period = $("#tab1txtSearchPeriod").val();
  var VoucherType_Id = $("#tab1dllSearchVoucherType").val();
  var MCCType_Id = "%" + $("#tab1dllSearchMCCType").val() + "%";
  var MCCWork_Id = "%" + $("#tab1dllSearchMCCWorkType").val() + "%";
  var MCC_Id = "%" + $("#tab1dllSearchMCC").val() + "%";

  var APIEndPoint = "GetInvoicePublish";
  var Method_Name = "Get_MCC";

  var url = "/Invoice/InvoicePublish";
  var IsValid = 1;
  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    IsValid = 0;
    $("#tab1txtSearchPeriod").addClass("is-invalid state-invalid");
  }
  if (
    VoucherType_Id == "" ||
    VoucherType_Id == null ||
    VoucherType_Id == undefined
  ) {
    IsValid = 0;
    $("#tab1dllSearchVoucherType").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    mccworktype_id: MCCWork_Id,
    vouchertype_id: VoucherType_Id,
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
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += '<td style="width: 20px;">';
        TableHTML +=
          '<label class="custom-control custom-checkbox " for="chk' +
          value.mcc_id +
          '">';

        TableHTML +=
          '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
          value.mcc_id +
          '"';
        TableHTML +=
          'style="vertical-align:sub; text-align: center;" id="chk' +
          value.mcc_id +
          '">';

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';

        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mcctype_name + "</td>";

        TableHTML += "<td>" + value.mccworktype_name + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tab1tableData").html(TableHTML);

      SetPagingDataTable("tab1tableSearch", [5], "Invoice Publish");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function tab1ShowPublishInvoice() {
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

        var APIEndPoint = "SaveInvoicePublish";
        var Method_Name = "MCCPublish";
        var VoucherType_Id = $("#tab1dllSearchVoucherType").val();
        var Search_Period = $("#tab1txtSearchPeriod").val();
        var url = "/Invoice/InvoicePublish";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          vouchertype_id: VoucherType_Id,
          invoice_id: checkedIds.join(),
          search_period: Search_Period,
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
              Show_Success_Toastr("Invoice Publish Added successfully");

              GetSearchMCCList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Invoice Publish not Added");
          },
        });
      }
    }
  );
  var checkedIds = [];

  $('#tab1tableSearch input[type="checkbox"]:checked').each(function () {
    var checkboxId = $(this).attr("id");
    var idWithoutPrefix = checkboxId.replace("chk", "");

    // Check if the checkbox is disabled
    if (!$(this).is(":disabled")) {
      checkedIds.push(idWithoutPrefix);
    }
  });
}

function tab1ShowGenerateInvoice() {
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

        var APIEndPoint = "SaveInvoicePublish";
        var Method_Name = "MCCGenerate";
        var VoucherType_Id = $("#tab1dllSearchVoucherType").val();
        var url = "/Invoice/InvoicePublish";
        var Search_Period = $("#tab1txtSearchPeriod").val();

        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          vouchertype_id: VoucherType_Id,
          invoice_id: checkedIds.join(),
          search_period: Search_Period,
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
              Show_Success_Toastr("Invoice Generate Added successfully");

              GetSearchMCCList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Invoice Generate not Added");
          },
        });
      }
    }
  );
  var checkedIds = [];

  $('#tab1tableSearch input[type="checkbox"]:checked').each(function () {
    var checkboxId = $(this).attr("id");
    var idWithoutPrefix = checkboxId.replace("chk", "");

    // Check if the checkbox is disabled
    if (!$(this).is(":disabled")) {
      checkedIds.push(idWithoutPrefix);
    }
  });
}

function GetSearchListData() {
  ClearDataTable("tab2tableSearch");
  $("#tab2tableData").empty();
  var Search_Period = $("#tab2txtSearchPeriod").val();
  var VoucherType_Id = $("#tab2dllSearchVoucherType").val();
  var MCCType_Id = "%" + $("#tab2dllSearchMCCType").val() + "%";
  var MCCWork_Id = "%" + $("#tab2dllSearchMCCWorkType").val() + "%";
  var MCC_Id = "%" + $("#tab2dllSearchMCC").val() + "%";

  var APIEndPoint = "GetInvoicePublish";
  var Method_Name = "Get";

  var url = "/Invoice/InvoicePublish";
  var IsValid = 1;
  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    IsValid = 0;
    $("#tab2txtSearchPeriod").addClass("is-invalid state-invalid");
  }
  if (
    VoucherType_Id == "" ||
    VoucherType_Id == null ||
    VoucherType_Id == undefined
  ) {
    IsValid = 0;
    $("#tab2dllSearchVoucherType").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    mccworktype_id: MCCWork_Id,
    vouchertype_id: VoucherType_Id,
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
      var Status = "";
      $.each(res, function (data, value) {
        if (value.is_published == 1) {
          Status = "Yes";
        }
        if (value.is_published == 0) {
          Status = "No";
        }
        TableHTML += "<tr>";
        TableHTML += '<td style="width: 20px;">';
        TableHTML +=
          '<label class="custom-control custom-checkbox " for="chk' +
          value.invoice_id +
          '">';

        TableHTML +=
          '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
          value.invoice_id +
          '"';
        TableHTML +=
          'style="vertical-align:sub; text-align: center;" id="chk' +
          value.invoice_id +
          '">';

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';

        TableHTML += "<td>" + value.invoice_date + "</td>";
        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mcctype_name + "</td>";

        TableHTML += "<td>" + value.invoice_no + "</td>";

        TableHTML += "<td>" + value.mustercycle + "</td>";

        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.generated_date + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tab2tableData").html(TableHTML);

      SetPagingDataTable("tab2tableSearch", [12], "Invoice Publish");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function tab2ShowDownloadInvoice() {
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

        var APIEndPoint = "GetInvoicePublish";
        var Method_Name = "Download";
        var VoucherType_Id = $("#tab2dllSearchVoucherType").val();
        var url = "/Invoice/CreateZipFile";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          vouchertype_id: VoucherType_Id,
          invoice_id: checkedIds.join(),
        };
        //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            window.location.href = "/Invoice/DownloadInvoiceFile";
          },
          error: function () {
            Show_Error_Toastr("Error : Invoice Publish not Added");
          },
        });
      }
    }
  );
  var checkedIds = [];

  $('#tab2tableSearch input[type="checkbox"]:checked').each(function () {
    var checkboxId = $(this).attr("id");
    var idWithoutPrefix = checkboxId.replace("chk", "");

    // Check if the checkbox is disabled
    if (!$(this).is(":disabled")) {
      checkedIds.push(idWithoutPrefix);
    }
  });
}

function tab2SelectAllInvoiceCheckbox() {
  $("#tab2selectAllInvoice").on("click", function () {
    var isChecked = $(this).prop("checked");
    $(
      "#tab2tableSearch #tab2tableData .custom-control-input:not(:disabled)"
    ).prop("checked", isChecked);
  });

  $(document).on(
    "click",
    "#tab2tableSearch #tab2tableData .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tab2tableSearch #tab2tableData .custom-control-input:not(:disabled)"
      );
      var selectedCheckboxes = $(
        "#tab2tableSearch #tab2tableData .custom-control-input:checked:not(:disabled)"
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#tab2selectAllInvoice").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length
      );
    }
  );
}
