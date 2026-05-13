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
  $("#dllSearchEntryChartName").select2();
  GetMaster("dllSearchEntryMCCType", "All MCC Type", "GetMCCType", "", "");

  $("#dllSearchEntryMCCWorkType").select2();
  GetMaster(
    "dllSearchEntryMCCWorkType",
    "All MCC Work Type",
    "GetMCCWorkType",
    "",
    ""
  );

  // SetDataTable("tableSearch", [13], "Goods Inward Posting");
});

// function GetSearchMCCName() {
//   $("#dllSearchEntryMCC")
//     .empty()
//     .append($("<option></option>").val("").html("All MCC"));
//   var MCCType_Id = $("#dllSearchEntryMCCType").val();
//   GetMaster("dllSearchEntryMCC", "All MCC", "Get_MCC", "", MCCType_Id);
// }

function GetSearchMCCName() {
  $("#dllSearchEntryMCC")
    .empty()
    .append($("<option></option>").val("").html("All MCC"));
  var MCCType_Id = $("#dllSearchEntryMCCType").val();
  var MCCWorkType_Id = $("#dllSearchEntryMCCWorkType").val();
  if (
    MCCWorkType_Id == "" ||
    MCCWorkType_Id == null ||
    MCCWorkType_Id == undefined
  ) {
    GetMaster("dllSearchEntryMCC", "All MCC", "Get_MCC", "", MCCType_Id);
  } else {
    GetMasters(
      "dllSearchEntryMCC",
      "All MCC",
      "Get_MCC",
      "",
      MCCType_Id,
      MCCWorkType_Id
    );
  }
}
function GetRate() {
  $("#dllSearchEntryChartName")
    .empty()
    .append($("<option></option>").val("").html("All Chart Name"));
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetInvoiceRateChange";
  var Method_Name = "Get";
  var MCCType_Id = "%" + $("#dllSearchEntryMCCType").val() + "%";
  var MCC_Id = $("#dllSearchEntryMCC").val();
  var url = "/Invoice/InvoiceRateChange";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  if (MCC_Id == "" || MCC_Id == undefined || MCC_Id == null) {
    Show_Error_Toastr("Select MCC Name");
    return;
  }
  GetRateList();
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
      // Fill data in table
      var TableHTML = "";
      var Row_No = 0;
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.invoice_no + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.old_rate + "</td>";
        TableHTML += "<td>" + value.old_amount + "</td>";
        TableHTML += "<td></td>";
        TableHTML += "<td></td>";
        TableHTML += "<td></td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [8], "Rate Change");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}
function GetSearchNewRateList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetInvoiceRateChange";
  var Method_Name = "Get_NewRate";
  var MCCType_Id = $("#dllSearchEntryMCCType").val();
  var MCC_Id = $("#dllSearchEntryMCC").val();
  var Chart_Id = $("#dllSearchEntryChartName").val();
  var url = "/Invoice/InvoiceRateChange";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }
  if (MCC_Id == "" || MCC_Id == undefined || MCC_Id == null) {
    Show_Error_Toastr("Select MCC Name");
    return;
  }
  if (Chart_Id == "" || Chart_Id == undefined || Chart_Id == null) {
    Show_Error_Toastr("Select Chart Name");
    return;
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    chart_id: Chart_Id,
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
      var Row_No = 0;
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.invoice_no + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        // TableHTML += "<td>" + value.old_rate + "</td>";
        TableHTML += "<td>" + value.old_amount + "</td>";
        TableHTML += "<td>" + value.new_rate + "</td>";
        // TableHTML += "<td>" + value.new_amount + "</td>";
        TableHTML +=
          "<td><a href='javascript:void(0)' class='btn btn-sm btn-link' onclick=\"OpenModal('" +
          value.invoice_id +
          "', '" +
          value.farmer_id +
          "')\">" +
          value.new_amount +
          "</a></td>";
        TableHTML +=
          "<td>" + (value.new_amount - value.old_amount).toFixed(2) + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "<td hidden>" + value.farmer_id + "</td>";
        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "<td hidden>" + value.invoice_date + "</td>";
        TableHTML += "<td hidden>" + value.startdate + "</td>";
        TableHTML += "<td hidden>" + value.enddate + "</td>";
        TableHTML +=
          "<td hidden>" +
          (value.new_amount - value.old_amount).toFixed(2) +
          "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [7], "Rate Change");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}
function GetRateList() {
  $("#dllSearchEntryChartName")
    .empty()
    .append($("<option></option>").val("").html("All Chart Name"));
  var Search_Period = $("#txtSearchDuration").val();
  var MCC_Id = $("#dllSearchEntryMCC").val();
  if (MCC_Id == "" || MCC_Id == undefined || MCC_Id == null) {
    // $("#dllSearchEntryMCC").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Select MCC Name");
    return;
  }
  GetMasters(
    "dllSearchEntryChartName",
    "All Chart Name",
    "Get_Chart",
    "",
    Search_Period,
    MCC_Id
  );
}

function OpenModal(Invoice_Id, Farmer_Id) {
  ClearDataTable("tableEntryModal");
  $("#modalEntry")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  var APIEndPoint = "GetInvoiceRateChange";
  var Method_Name = "Get_One";
  var MCCType_Id = $("#dllSearchEntryMCCType").val();
  var MCC_Id = $("#dllSearchEntryMCC").val();
  var Chart_Id = $("#dllSearchEntryChartName").val();
  var Search_Period = $("#txtSearchDuration").val();
  var url = "/Invoice/InvoiceRateChange";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    invoice_id: Invoice_Id,
    search_period: Search_Period,
    mcc_id: MCC_Id,
    mcctype_id: MCCType_Id,
    chart_id: Chart_Id,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      var TableHTML = "";
      var Row_No = 0;
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.invoice_date + "</td>";
        // TableHTML += "<td>" + value.farmer_code + "</td>";
        // TableHTML += "<td>" + value.farmer_name + "</td>";
        // TableHTML += "<td>" + value.mcc_code + "</td>";
        // TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td>" + value.old_rate + "</td>";
        TableHTML += "<td>" + value.old_amount + "</td>";
        TableHTML += "<td>" + value.new_rate + "</td>";
        TableHTML += "<td>" + value.new_amount + "</td>";
        TableHTML +=
          "<td>" + (value.new_amount - value.old_amount).toFixed(2) + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryModalData").html(TableHTML);

      SetPagingDataTable("tableEntryModal", [10], "New Rate Change");
    },
    error: function () {
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
        var XMLData = "<RateChange>";

        $("#tableSearch tbody tr").each(function () {
          // Match found, add data to XML
          XMLData += "<RateChangeItem>";

          XMLData +=
            "<Farmer_Id>" + $(this).find("td:eq(8)").text() + "</Farmer_Id>";
          XMLData +=
            "<MCC_Id>" + $(this).find("td:eq(9)").text() + "</MCC_Id>";
          XMLData +=
            "<Invoice_Date>" +
            $(this).find("td:eq(10)").text() +
            "</Invoice_Date>";
          XMLData +=
            "<Start_Date>" + $(this).find("td:eq(11)").text() + "</Start_Date>";
          XMLData +=
            "<End_Date>" + $(this).find("td:eq(12)").text() + "</End_Date>";
          XMLData +=
            "<Amount>" + $(this).find("td:eq(13)").text() + "</Amount>";

          XMLData += "</RateChangeItem>";
        });

        XMLData += "</RateChange>";
        //Post it
        var APIEndPoint = "SaveInvoiceRateChange";
        var Method_Name = "Create";
        var url = "/Invoice/InvoiceRateChange";
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
              Show_Success_Toastr("Farmer Rate Change Generate successfully");

              GetSearchNewRateList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Farmer Rate Change not Generate");
          },
        });
      }
    }
  );
}
