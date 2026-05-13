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
});

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

function GetSearchFarmerName() {
  $("#ddlEntryFarmer")
    .empty()
    .append($("<option></option>").val("").html("Select Farmer Name"));
  var MCC_Id = $("#ddlEntryMCC").val();

  GetMaster("ddlEntryFarmer", "Select Farmer Name", "GetMCCFarmer", "", MCC_Id);
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function ShowAddEntry() {
  // document.getElementById("chkEntryMilkPayment").checked = false;

  $("#ddlEntryIncomeFor").val("");
  $("#ddlEntryFarmer").val("");
  $("#txtEntryAmount").val("");
  $("#txtEntryDescription").val("");
  $("#ddlEntryMCC").val("");

  GetSearchIncomeFor();
  $("#modelEntryFarmer")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  var date = $("#txtSearchDuration").val();
  $("#txtEntryVoucherDate").val(date);

  $("#ddlEntryIncomeFor").select2();

  GetMaster("ddlEntryIncomeFor", "Select Income For", "GetFMStatus", "", "");

  $("#ddlEntryMCC").select2();
  $("#ddlEntryFarmer").select2();

  GetMaster("ddlEntryMCC", "Select MCC", "GetMCC", "", "");
}

function GetSearchIncomeFor() {
  var IncomeFor = $("#ddlEntryIncomeFor").val();

  if (IncomeFor == "" || IncomeFor == null || IncomeFor == undefined) {
    $("#divddlEntryMCC").show();
    $("#divddlEntryFarmer").show();
    $("#divddlEntryRadio1").hide();
    $("#divddlEntryRadio2").hide();
  }
  if (IncomeFor == "MCC") {
    $("#divddlEntryMCC").show();
    $("#divddlEntryFarmer").hide();
    $("#divddlEntryRadio1").show();
    $("#divddlEntryRadio2").show();
  }
  if (IncomeFor == "Farmer") {
    $("#divddlEntryMCC").show();
    $("#divddlEntryFarmer").show();
    $("#divddlEntryRadio1").hide();
    $("#divddlEntryRadio2").hide();
  }
}

function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetInvoiceSAPPosting";
  var Method_Name = "Get";
  var MCCType_Id = "%" + $("#dllSearchEntryMCCType").val() + "%";
  var MCC_Id = "%" + $("#dllSearchEntryMCC").val() + "%";
  var url = "/Invoice/InvoiceSAPPosting";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }

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
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      $.each(res, function (data, value) {
        Row_No = Row_No + 1;
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

        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.invoice_date + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mustercycle + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.income_document + "</td>";
        TableHTML += "<td>" + value.remark + "</td>";

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

        if (value.is_posted == 0) {
        }
        if (value.is_posted == 3) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseEntry(\'' +
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
        if (value.is_posted == 2) {
        }
        if (value.is_posted == 4) {
        }
        if (value.is_posted == 1) {
        }

        TableHTML += "</td>";

        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [8], "SAP Posting Invoice");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SaveFarmerEntry() {
  var IncomeFor = $("#ddlEntryIncomeFor").val();

  var Farmer_Id = $("#ddlEntryFarmer").val();
  var Search_Period = $("#txtEntryVoucherDate").val();
  var Amount = $("#txtEntryAmount").val();

  var Remark = $("#txtEntryDescription").val();

  var MCC_Id = $("#ddlEntryMCC").val();
  var APIEndPoint = "SaveInvoiceSAPPosting";
  var Method_Name = "Create";
  var url = "/Invoice/InvoiceSAPPosting";


  // var MilkPayment = $('input[name="radioAcceptReject"]:checked').val();

  var MilkPayment = 1;
  // if (document.getElementById("chkEntryMilkPayment").checked == false) {
  //   MilkPayment = 0;
  // }

  var IsValid = 1;

  if (IncomeFor == "" || IncomeFor == null || IncomeFor == undefined) {
    IsValid = 0;
    $("#ddlEntryIncomeFor").addClass("is-invalid state-invalid");
  }
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtEntryVoucherDate").addClass("is-invalid state-invalid");
  }
  if (MCC_Id == "" || MCC_Id == null || MCC_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMCC").addClass("is-invalid state-invalid");
  }
  if (IncomeFor == "Farmer") {
    if (Farmer_Id == "" || Farmer_Id == null || Farmer_Id == undefined) {
      IsValid = 0;
      $("#ddlEntryFarmer").addClass("is-invalid state-invalid");
    }
  }

  if (Amount == "" || Amount == null || Amount == undefined || isNaN(Amount)) {
    IsValid = 0;
    $("#txtEntryAmount").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }

  if (IncomeFor == "MCC") {
    Farmer_Id = $("#ddlEntryMCC").val();
    MilkPayment = $('input[name="radioAcceptReject"]:checked').val();
  }
  if (IncomeFor == "Farmer") {
    Farmer_Id = $("#ddlEntryFarmer").val();
    MilkPayment = 1;
  }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    amount: Amount,
    farmer_id: Farmer_Id,
    mcc_id: MCC_Id,
    incomefor: IncomeFor,
    remark: Remark,
    milkpayment: MilkPayment,
  };

  //   //Save
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        Show_Success_Toastr("SAP Posted successfully");
        $("#modelEntryFarmer").modal("hide");
        GetSearchList();
      } else {
        $("#modelEntryFarmer").modal("hide");
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      $("#modelEntryFarmer").modal("hide");
      Show_Error_Toastr("Error : SAP Posting Invoice not Posted");
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

function getIncomeDeduction(invoice_id) {
  $("#txtEntryErrorMessage").val("");
  var APIEndPoint = "GetInvoiceSAPPosting";
  var Method_Name = "GetIncomeError";
  var url = "/Invoice/InvoiceSAPPosting";
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

function ReverseEntry(invoice_id) {
  var Method_Name = "Set_Reverse";

  var APIEndPoint = "SaveInvoiceSAPPosting";
  var url = "/Invoice/InvoiceSAPPosting";

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
        Show_Success_Toastr("SAP Invoice Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : SAP Invoice not Reverse");
    },
  });
}
