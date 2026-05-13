$(document).ready(function () {
  $("#divSearchPeriod").show();
  $("#divSearchDate").hide();
  $("#divSearchMPPIType").hide();

  var ReportGroup = $("#lblReportGroup").html();
  var ReportGroupType = "MC";

  if (ReportGroup == "Milk") {
    ReportGroupType = "MC";
  } else {
    ReportGroupType = "MI";
    $("#lblPageHeader").html("Procurement Invoice Report");
    $("#lblBreadCrumb").html("Procurement Invoice");
    $("#divSearchCollectionShift").hide();
    $("#divSearchMilkType").hide();
  }

  $("#ddlSearchMilkType").select2();
  GetMaster("ddlSearchMilkType", "", "GetMilkType", "", "");

  $("#ddlSearchShift").select2();
  GetMaster("ddlSearchShift", "", "GetMilkCollectionShiftAll", "", "");

  $("#ddlSearchMCCType").select2();
  GetMaster("ddlSearchMCCType", "", "GetMCCType", "", "");

  $("#ddlSearchMCCWorkType").select2();
  GetMaster("ddlSearchMCCWorkType", "", "GetMCCWorkType", "", "");

  $("#ddlSearchMCCName").select2();
  GetMaster("ddlSearchMCCName", "", "Get_MCC_ALL", "", "");

  $("#ddlSearchTransporterName").select2();
  GetMaster("ddlSearchTransporterName", "", "GetTransporter", "", "");

  $("#ddlSearchRouteName").select2();
  GetMaster("ddlSearchRouteName", "", "GetRoute", "", "");

  $("#ddlSearchMPPIType").select2();
  GetMaster("ddlSearchMPPIType", "", "GetMPPIType", "", "");

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
  // Handle manually typed date
  $('input[name="datefilter"]').on("change", function () {
    let dateRange = $(this).val().split(" - ");
    if (dateRange.length === 2) {
      let startDate = moment(dateRange[0], "DD MMM YYYY");
      let endDate = moment(dateRange[1], "DD MMM YYYY");
      if (startDate.isValid() && endDate.isValid()) {
        $("#txtSearchPeriodHidden").val(
          startDate.format("MM/DD/YYYY") + " - " + endDate.format("MM/DD/YYYY")
        );
      } else {
        alert("Invalid date format. Please use DD MMM YYYY format.");
        $(this).val(""); // Clear input if invalid
      }
    } else {
      alert("Invalid date range format.");
      $(this).val(""); // Clear input if invalid
    }
  });

  $("#ddlSearchReportType").select2();
  GetMaster("ddlSearchReportType", "", "GetReportTypes", "", ReportGroupType);

  var ReportType = $("#lblReportType").html();
  if (ReportType != "") {
    GetSearchList(ReportType);
  }

  $("#txtSearchDate").val(getCurrentDateTime());
});

function getCurrentDateTime() {
  const now = new Date();
  const year = now.getFullYear();
  const month = (now.getMonth() + 1).toString().padStart(2, "0");
  const day = now.getDate().toString().padStart(2, "0");
  const hours = now.getHours().toString().padStart(2, "0");
  const minutes = now.getMinutes().toString().padStart(2, "0");

  return `${year}-${month}-${day}T${hours}:${minutes}`;
}

function SetReportFilters() {
  var ReportGroup = $("#lblReportGroup").html();
  var ReportType = $("#ddlSearchReportType").val();
  $("#divSearchPeriod").show();
  $("#divSearchDate").hide();
  $("#divSearchMPPIType").hide();
  if (ReportGroup == "Invoice") {
    // if (ReportType == "C048007") {
    //   // Transporter Invoice
    //   $("#divSearchMCCType").hide();
    //   $("#divSearchMCCName").hide();
    //   $("#divSearchMCCWorkType").hide();
    //   $("#divSearchTransporterName").show();
    //   $("#divSearchMPPIType").hide();
    // } else {
    //   $("#divSearchMCCType").show();
    //   $("#divSearchMCCName").show();
    //   $("#divSearchMCCWorkType").show();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMPPIType").hide();
    // }
    // if (ReportType == "C048004" || ReportType == "C048005") {
    //   $("#divMusterSearchDate").show();
    //   $("#divSearchMPPIType").hide();
    // }
    // // if (ReportType == "C048005") {
    // //   $("#divMusterSearchDate").show();
    // // }
    // else {
    //   $("#divSearchMPPIType").hide();
    //   $("#divMusterSearchDate").hide();
    // }
    if (ReportType == "C048007") {
      $("#divSearchMCCType").hide();
      $("#divSearchMCCName").hide();
      $("#divSearchMCCWorkType").hide();
      $("#divSearchTransporterName").show();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048004" || ReportType == "C048005") {
      $("#divMusterSearchDate").show();
      $("#divSearchMPPIType").hide();
    } else {
      $("#divSearchMCCType").show();
      $("#divSearchMCCName").show();
      $("#divSearchMCCWorkType").show();
      $("#divSearchTransporterName").hide();
      $("#divSearchMPPIType").hide();
      $("#divSearchMPPIType").hide();
      $("#divMusterSearchDate").hide();
    }
  } else if (ReportGroup == "Milk") {
    // if (ReportType == "C048009" || ReportType == "C048013") {
    //   // Transporter Invoice
    //   $("#divSearchMCCType").hide();
    //   $("#divSearchMCCName").hide();
    //   $("#divSearchTransporterName").show();
    //   $("#divSearchMilkType").hide();
    //   $("#divSearchMCCWorkType").hide();
    //   $("#divSearchCollectionShift").hide();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchMPPIType").hide();
    // }
    // if (ReportType == "C048015") {
    //   $("#divSearchMCCType").hide();
    //   $("#divSearchMCCName").hide();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMilkType").hide();
    //   $("#divSearchMCCWorkType").hide();
    //   $("#divSearchCollectionShift").hide();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchMPPIType").hide();
    // }
    // if (
    //   ReportType == "C048016" ||
    //   ReportType == "C048028" ||
    //   ReportType == "C048031" ||
    //   ReportType == "C048032"
    // ) {
    //   $("#divSearchMCCType").show();
    //   $("#divSearchMCCName").show();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMilkType").show();
    //   $("#divSearchMCCWorkType").show();
    //   $("#divSearchPeriod").hide();
    //   $("#divSearchDate").show();
    //   $("#divSearchCollectionShift").show();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchMPPIType").hide();
    // }

    // if (ReportType == "C048017") {
    //   $("#divSearchMCCType").hide();
    //   $("#divSearchMCCName").hide();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMilkType").hide();
    //   $("#divSearchMCCWorkType").hide();
    //   $("#divSearchPeriod").show();
    //   $("#divSearchDate").hide();
    //   $("#divSearchCollectionShift").hide();
    //   $("#divSearchRouteName").show();
    //   $("#divSearchMPPIType").hide();
    // } else {
    //   $("#divSearchMCCType").show();
    //   $("#divSearchMCCName").show();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMilkType").show();
    //   $("#divSearchMCCWorkType").show();
    //   $("#divSearchCollectionShift").show();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchMPPIType").hide();
    // }

    // if (ReportType == "C048020") {
    //   $("#divSearchMCCType").hide();
    //   $("#divSearchMCCName").hide();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMilkType").hide();
    //   $("#divSearchMCCWorkType").hide();
    //   $("#divSearchPeriod").hide();
    //   $("#divSearchDate").show();
    //   $("#divSearchCollectionShift").hide();
    //   $("#divSearchRouteName").show();
    //   $("#divSearchMPPIType").hide();
    // } else {
    //   $("#divSearchMCCType").show();
    //   $("#divSearchMCCName").show();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMilkType").show();
    //   $("#divSearchMCCWorkType").show();
    //   $("#divSearchCollectionShift").show();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchMPPIType").hide();
    // }

    // if (ReportType == "C048018") {
    //   // Transporter Invoice
    //   $("#divSearchMCCType").hide();
    //   $("#divSearchMCCName").hide();
    //   $("#divSearchMCCWorkType").hide();
    //   $("#divSearchTransporterName").show();
    //   $("#divSearchCollectionShift").hide();
    //   $("#divSearchMilkType").hide();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchMPPIType").hide();
    // } else {
    //   // $("#divSearchMCCType").show();
    //   // $("#divSearchMCCName").show();
    //   // $("#divSearchMCCWorkType").show();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMPPIType").hide();
    // }
    // if (ReportType == "C048030") {
    //   // Transporter Invoice
    //   $("#divSearchMCCType").hide();
    //   $("#divSearchMCCName").show();
    //   $("#divSearchMCCWorkType").hide();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchCollectionShift").hide();
    //   $("#divSearchMilkType").hide();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMPPIType").hide();
    // } else {
    //   $("#divSearchMPPIType").hide();
    //   // $("#divSearchMCCName").hide();
    //   // $("#divSearchMCCType").show();
    //   // $("#divSearchMCCName").show();
    //   // $("#divSearchMCCWorkType").show();
    // }
    // if (ReportType == "C048003" || ReportType == "C048026") {
    //   $("#divMusterSearchDate").show();
    //   $("#divSearchMPPIType").hide();
    // }
    // if (ReportType == "C048035") {
    //   $("#divSearchMCCType").show();
    //   $("#divSearchMCCName").show();
    //   $("#divSearchTransporterName").hide();
    //   $("#divSearchMilkType").show();
    //   $("#divSearchMCCWorkType").show();
    //   $("#divSearchPeriod").hide();
    //   $("#divSearchDate").show();
    //   $("#divSearchCollectionShift").hide();
    //   $("#divSearchRouteName").hide();
    //   $("#divSearchMPPIType").show();
    // } else {
    //   $("#divMusterSearchDate").hide();
    //   $("#divSearchMPPIType").hide();
    // }
    if (
      ReportType == "C048009" ||
      ReportType == "C048013" ||
      ReportType == "C048036"
    ) {
      // Transporter Invoice
      $("#divSearchMCCType").hide();
      $("#divSearchMCCName").hide();
      $("#divSearchTransporterName").show();
      $("#divSearchMilkType").hide();
      $("#divSearchMCCWorkType").hide();
      $("#divSearchCollectionShift").hide();
      $("#divSearchRouteName").hide();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048015") {
      $("#divSearchMCCType").hide();
      $("#divSearchMCCName").hide();
      $("#divSearchTransporterName").hide();
      $("#divSearchMilkType").hide();
      $("#divSearchMCCWorkType").hide();
      $("#divSearchCollectionShift").hide();
      $("#divSearchRouteName").hide();
      $("#divSearchMPPIType").hide();
    } else if (
      ReportType == "C048016" ||
      ReportType == "C048028" ||
      ReportType == "C048031" ||
      ReportType == "C048032"
    ) {
      $("#divSearchMCCType").show();
      $("#divSearchMCCName").show();
      $("#divSearchTransporterName").hide();
      $("#divSearchMilkType").show();
      $("#divSearchMCCWorkType").show();
      $("#divSearchPeriod").hide();
      $("#divSearchDate").show();
      $("#divSearchCollectionShift").show();
      $("#divSearchRouteName").hide();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048017") {
      $("#divSearchMCCType").hide();
      $("#divSearchMCCName").hide();
      $("#divSearchTransporterName").hide();
      $("#divSearchMilkType").hide();
      $("#divSearchMCCWorkType").hide();
      $("#divSearchPeriod").show();
      $("#divSearchDate").hide();
      $("#divSearchCollectionShift").hide();
      $("#divSearchRouteName").show();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048020") {
      $("#divSearchMCCType").hide();
      $("#divSearchMCCName").hide();
      $("#divSearchTransporterName").hide();
      $("#divSearchMilkType").hide();
      $("#divSearchMCCWorkType").hide();
      $("#divSearchPeriod").hide();
      $("#divSearchDate").show();
      $("#divSearchCollectionShift").hide();
      $("#divSearchRouteName").show();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048018") {
      // Transporter Invoice
      $("#divSearchMCCType").hide();
      $("#divSearchMCCName").hide();
      $("#divSearchMCCWorkType").hide();
      $("#divSearchTransporterName").show();
      $("#divSearchCollectionShift").hide();
      $("#divSearchMilkType").hide();
      $("#divSearchRouteName").hide();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048030") {
      // Transporter Invoice
      $("#divSearchMCCType").hide();
      $("#divSearchMCCName").show();
      $("#divSearchMCCWorkType").hide();
      $("#divSearchTransporterName").hide();
      $("#divSearchCollectionShift").hide();
      $("#divSearchMilkType").hide();
      $("#divSearchRouteName").hide();
      $("#divSearchTransporterName").hide();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048003" || ReportType == "C048026") {
      $("#divMusterSearchDate").show();
      $("#divSearchMPPIType").hide();
    } else if (ReportType == "C048035") {
      $("#divSearchMCCType").show();
      $("#divSearchMCCName").show();
      $("#divSearchTransporterName").hide();
      $("#divSearchMilkType").show();
      $("#divSearchMCCWorkType").show();
      $("#divSearchPeriod").hide();
      $("#divSearchDate").show();
      $("#divSearchCollectionShift").hide();
      $("#divSearchRouteName").hide();
      $("#divSearchMPPIType").show();
    } else {
      $("#divSearchMCCType").show();
      $("#divSearchMCCName").show();
      $("#divSearchTransporterName").hide();
      $("#divSearchMilkType").show();
      $("#divSearchMCCWorkType").show();
      $("#divSearchCollectionShift").show();
      $("#divSearchRouteName").hide();
      $("#divSearchMPPIType").hide();
      $("#divSearchMCCType").show();
      $("#divSearchMCCName").show();
      $("#divSearchTransporterName").hide();
      $("#divSearchMilkType").show();
      $("#divSearchMCCWorkType").show();
      $("#divSearchCollectionShift").show();
      $("#divSearchRouteName").hide();
      $("#divSearchMPPIType").hide();
      $("#divSearchTransporterName").hide();
      $("#divSearchMPPIType").hide();
      $("#divSearchMPPIType").hide();
      $("#divMusterSearchDate").hide();
      $("#divSearchMPPIType").hide();
    }
  }
}

function GetSearchList(ReportType) {
  $("#divReportLoader").show();
  var MCCType_Id = "";
  var MCCCollectionShift_Id = "";
  var MilkType_Id = "";
  var MCC_Id = "";
  var ReportPeriod = "";
  var MCCWorkType_Id = "";
  var ReportGroup = $("#lblReportGroup").html();
  var ReportTypeId = $("#ddlSearchReportType").val();
  var MusterStartSearchDate = $("#txtMusterStartSearchDate").val();
  var MusterEndSearchDate = $("#txtMusterEndSearchDate").val();
  var MPPIType_Id = "";
  if (
    ReportType != "R1" &&
    ReportType != "R2" &&
    ReportType != "R3" &&
    ReportType != "R4"
  ) {
    // Do validations
    var ErrorCount = 0;
    var ErrorMessage = "";

    var MCCTypeCount = $("#ddlSearchMCCType option:selected").length;
    if (
      MCCTypeCount == 0 &&
      ReportTypeId != "C048007" &&
      ReportTypeId != "C048009" &&
      ReportTypeId != "C048036" &&
      ReportTypeId != "C048013" &&
      ReportTypeId != "C048015" &&
      ReportTypeId != "C048017" &&
      ReportTypeId != "C048018" &&
      ReportTypeId != "C048020" &&
      ReportTypeId != "C048030"
    ) {
      ErrorCount = ErrorCount + 1;
      ErrorMessage += "- Select one or more MCC Type. <br/>";
    }

    var CollectionShiftCount = $("#ddlSearchShift option:selected").length;
    if (
      CollectionShiftCount == 0 &&
      ReportGroup == "Milk" &&
      ReportTypeId != "C048009" &&
      ReportTypeId != "C048036" &&
      ReportTypeId != "C048013" &&
      ReportTypeId != "C048015" &&
      ReportTypeId != "C048017" &&
      ReportTypeId != "C048018" &&
      ReportTypeId != "C048020" &&
      ReportTypeId != "C048030" &&
      ReportTypeId != "C048035"
    ) {
      ErrorCount = ErrorCount + 1;
      ErrorMessage += "- Select one or more Collection Shift. <br/>";
    }

    var MilkTypeCount = $("#ddlSearchMilkType option:selected").length;
    if (
      MilkTypeCount == 0 &&
      ReportGroup == "Milk" &&
      ReportTypeId != "C048009" &&
      ReportTypeId != "C048036" &&
      ReportTypeId != "C048013" &&
      ReportTypeId != "C048015" &&
      ReportTypeId != "C048017" &&
      ReportTypeId != "C048018" &&
      ReportTypeId != "C048020" &&
      ReportTypeId != "C048030"
    ) {
      ErrorCount = ErrorCount + 1;
      ErrorMessage += "- Select one or more Milk Type. <br/>";
    }

    var MCCWorkTypeCount = $("#ddlSearchMCCWorkType option:selected").length;
    if (
      MCCWorkTypeCount == 0 &&
      ReportTypeId != "C048007" &&
      ReportTypeId != "C048009" &&
      ReportTypeId != "C048036" &&
      ReportTypeId != "C048013" &&
      ReportTypeId != "C048015" &&
      ReportTypeId != "C048017" &&
      ReportTypeId != "C048018" &&
      ReportTypeId != "C048020" &&
      ReportTypeId != "C048030"
    ) {
      ErrorCount = ErrorCount + 1;
      ErrorMessage += "- Select one or more MCC Work Type. <br/>";
    }

    if (ErrorCount > 0) {
      $("#divError").show();
      $("#lblErrorMessage").html(ErrorMessage);
      return;
    } else {
      $("#divError").hide();
    }
  }

  ShowContentDiv("Report", "MilkCollectionReport", "", function () {
    switch (ReportType) {
      case "R1":
        $("#lblReportTitle").html("RMRD Morning Collection");
        $("#divCardOptions").hide();
        break;
      case "R2":
        $("#lblReportTitle").html("RMRD Evening Collection");
        $("#divCardOptions").hide();
        break;
      case "R3":
        $("#lblReportTitle").html("BMC & Bulk Supplier Collection");
        $("#divCardOptions").hide();
        break;
      case "R4":
        $("#lblReportTitle").html("Total Collection");
        $("#divCardOptions").hide();
        break;
      default:
        MCCType_Id = $("#ddlSearchMCCType").val().join();
        ReportPeriod = $("#txtSearchPeriodHidden").val();
        MCCCollectionShift_Id = $("#ddlSearchShift").val().join();
        MilkType_Id = $("#ddlSearchMilkType").val().join();
        MCC_Id = $("#ddlSearchMCCName").val().join();
        Ttansporter_Id = $("#ddlSearchTransporterName").val().join();
        Route_Id = $("#ddlSearchRouteName").val().join();
        MCCWorkType_Id = $("#ddlSearchMCCWorkType").val().join();
        ReportType = $("#ddlSearchReportType").val();

        MPPIType_Id = $("#ddlSearchMPPIType").val();

        if (
          ReportType == "C048007" ||
          ReportType == "C048009" ||
          ReportTypeId == "C048036" ||
          ReportType == "C048013" ||
          ReportType == "C048015" ||
          ReportType == "C048018"
        ) {
          // Transporter Invoice Report
          MCC_Id = Ttansporter_Id;
        }
        if (ReportType == "C048017" || ReportType == "C048020") {
          // Transporter Invoice Report
          MCC_Id = Route_Id;
        }

        if (ReportType == "C048035") {
          // Transporter Invoice Report
          MCCCollectionShift_Id = MPPIType_Id;
        }

        $("#divCardOptions").show();
    }
    ClearDataTable("tableReport");

    if (
      ReportType == "C048016" ||
      ReportType == "C048020" ||
      ReportType == "C048028" ||
      ReportType == "C048031" ||
      ReportType == "C048032" ||
      ReportType == "C048035"
    ) {
      ReportPeriod = $("#txtSearchDate").val();
    } else {
      ReportPeriod = $("#txtSearchPeriodHidden").val();
    }

    var ReportGroup = $("#lblReportGroup").html();
    var ReportName = $("#ddlSearchReportType option:selected").text();
    var APIEndPoint = "GetMilkReport";
    if (ReportGroup == "Milk") {
      APIEndPoint = "GetMilkReport";
      $("#lblReportTitle").html("Milk Collection Report");
    } else {
      APIEndPoint = "GetInvoiceReport";
      $("#lblReportTitle").html(ReportName);
    }
    var url = "/Report/GetMilkReport";
    var Method_Name = "Get";
    var reqdata = {
      Method_Name: Method_Name,
      api_end_point: APIEndPoint,
      Report_Type: ReportType,
      MCCType_Id: MCCType_Id + "",
      ReportPeriod: ReportPeriod,
      MCCCollectionShift_Id: MCCCollectionShift_Id + "",
      MilkType_Id: MilkType_Id + "",
      MCC_Id: MCC_Id + "",
      MCCWorkType_Id: MCCWorkType_Id + "",
      MusterStartDate: MusterStartSearchDate + "",
      MusterEndDate: MusterEndSearchDate + "",
    };

    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result);
        const ReportResult = JSON.parse(res);

        if (ReportResult.count == 0) {
          $("#divReportLoader").hide();
          ShowEntryError("Error : Milk Collection details not found");
          return;
        }

        // Fill Table Head
        var TableHeadHTML = "";
        if (ReportResult[0].RowType == "TH") {
          TableHeadHTML = "<tr>";
          Object.keys(ReportResult[0]).forEach(function (key) {
            if (key != "RowType") {
              TableHeadHTML += "<th>" + ReportResult[0][key] + "</th>";
            }
          });
          TableHeadHTML += "</tr>";
          $("#tableHead").html(TableHeadHTML);
        } else {
          // This is not report data.  Skip
          $("#divReportLoader").hide();
          return;
        }

        // Fill data in table
        var TableHTML = "";
        $.each(ReportResult, function (data, value) {
          if (value.RowType == "TR") {
            // Check if this is a row entry
            TableHTML += "<tr>";

            Object.keys(ReportResult[0]).forEach(function (key) {
              if (key != "RowType") {
                TableHTML += "<td>" + value[key] + "</td>";
              }
            });
            TableHTML += "</tr>";
          }
        });
        $("#tableData").html(TableHTML);

        SetDataTable_Report("tableReport", [], "Milk Collection Report");
        $("#divReportLoader").hide();
      },
      error: function () {
        $("#divReportLoader").hide();
        ShowEntryError("Error : Milk Collection details not found");
      },
    });
  });
}

function CloseReport() {
  HideContentDiv();
}

function GetMilkRateEntryList(
  MCC_Id,
  MilkType_Id,
  CollectionShift_Id,
  MilkRateEntryType_Id
) {
  ClearDataTable("tableEntryModal");
  $("#modelEntry")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  var Method_Name = "";

  if (MilkRateEntryType_Id == "C012001") {
    Method_Name = "GetRate";
  } else {
    Method_Name = "GetSlab";
  }

  var ReportPeriod = $("#txtSearchDate").val();
  var url = "/Report/GetMilkReport";
  var APIEndPoint = "GetMilkReport";
  var reqdata = {
    Method_Name: Method_Name,
    api_end_point: APIEndPoint,
    Report_Type: MilkRateEntryType_Id,
    MCCType_Id: "",
    ReportPeriod: ReportPeriod,
    MCCCollectionShift_Id: CollectionShift_Id,
    MilkType_Id: MilkType_Id,
    MCC_Id: MCC_Id,
    MCCWorkType_Id: "",
    MusterStartDate: "",
    MusterEndDate: "",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      const res = JSON.parse(result);
      const ReportResult = JSON.parse(res);

      if (ReportResult.count == 0) {
        ShowEntryError("Error : Milk Collection details not found");
        return;
      }

      // Fill Table Head
      var TableHeadHTML = "";
      if (ReportResult[0].RowType == "TH") {
        TableHeadHTML = "<tr>";
        Object.keys(ReportResult[0]).forEach(function (key) {
          if (key != "RowType") {
            TableHeadHTML += "<th>" + ReportResult[0][key] + "</th>";
          }
        });
        TableHeadHTML += "</tr>";
        $("#tableEntryModelDataHeader").html(TableHeadHTML);
      }

      // Fill data in table
      var TableHTML = "";
      $.each(ReportResult, function (data, value) {
        if (value.RowType == "TR") {
          // Check if this is a row entry
          TableHTML += "<tr>";

          Object.keys(ReportResult[0]).forEach(function (key) {
            if (key != "RowType") {
              TableHTML += "<td>" + value[key] + "</td>";
            }
          });
          TableHTML += "</tr>";
        }
      });
      $("#tableEntryModelData").html(TableHTML);

      // SetDataTable("tableEntryModal", [], "Milk Collection Report");
    },
    error: function () {
      ShowEntryError("Error : Milk Collection details not found");
    },
  });
}

function GetCommissionEntryList(MCC_Id, MilkType_Id, MilkRateEntryType_Id) {
  ClearDataTable("tableEntryModal");
  $("#modelEntry")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  var Method_Name = "GetCommission";

  var ReportPeriod = $("#txtSearchDate").val();
  var url = "/Report/GetMilkReport";
  var APIEndPoint = "GetMilkReport";
  var reqdata = {
    Method_Name: Method_Name,
    api_end_point: APIEndPoint,
    Report_Type: MilkRateEntryType_Id,
    MCCType_Id: "",
    ReportPeriod: ReportPeriod,
    MCCCollectionShift_Id: "",
    MilkType_Id: MilkType_Id,
    MCC_Id: MCC_Id,
    MCCWorkType_Id: "",
    MusterStartDate: "",
    MusterEndDate: "",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      const res = JSON.parse(result);
      const ReportResult = JSON.parse(res);

      if (ReportResult.count == 0) {
        ShowEntryError("Error : Milk Collection details not found");
        return;
      }

      // Fill Table Head
      var TableHeadHTML = "";
      if (ReportResult[0].RowType == "TH") {
        TableHeadHTML = "<tr>";
        Object.keys(ReportResult[0]).forEach(function (key) {
          if (key != "RowType") {
            TableHeadHTML += "<th>" + ReportResult[0][key] + "</th>";
          }
        });
        TableHeadHTML += "</tr>";
        $("#tableEntryModelDataHeader").html(TableHeadHTML);
      }

      // Fill data in table
      var TableHTML = "";
      $.each(ReportResult, function (data, value) {
        if (value.RowType == "TR") {
          // Check if this is a row entry
          TableHTML += "<tr>";

          Object.keys(ReportResult[0]).forEach(function (key) {
            if (key != "RowType") {
              TableHTML += "<td>" + value[key] + "</td>";
            }
          });
          TableHTML += "</tr>";
        }
      });
      $("#tableEntryModelData").html(TableHTML);

      // SetDataTable("tableEntryModal", [], "Milk Collection Report");
    },
    error: function () {
      ShowEntryError("Error : Milk Collection details not found");
    },
  });
}

function GetCurrentMilkRateEntryList(MCC_Id, MilkType_Id, CollectionShift_Id) {
  ClearDataTable("tableEntryModal");
  $("#modelEntry")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  var Method_Name = "CurrentGetRate";

  var ReportPeriod = $("#txtSearchDate").val();
  var url = "/Report/GetMilkReport";
  var APIEndPoint = "GetMilkReport";
  var reqdata = {
    Method_Name: Method_Name,
    api_end_point: APIEndPoint,
    Report_Type: "",
    MCCType_Id: "",
    ReportPeriod: ReportPeriod,
    MCCCollectionShift_Id: CollectionShift_Id,
    MilkType_Id: MilkType_Id,
    MCC_Id: MCC_Id,
    MCCWorkType_Id: "",
    MusterStartDate: "",
    MusterEndDate: "",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      const res = JSON.parse(result);
      const ReportResult = JSON.parse(res);

      if (ReportResult.count == 0) {
        ShowEntryError("Error : Milk Collection details not found");
        return;
      }

      // Fill Table Head
      var TableHeadHTML = "";
      if (ReportResult[0].RowType == "TH") {
        TableHeadHTML = "<tr>";
        Object.keys(ReportResult[0]).forEach(function (key) {
          if (key != "RowType") {
            TableHeadHTML += "<th>" + ReportResult[0][key] + "</th>";
          }
        });
        TableHeadHTML += "</tr>";
        $("#tableEntryModelDataHeader").html(TableHeadHTML);
      }

      // Fill data in table
      var TableHTML = "";
      $.each(ReportResult, function (data, value) {
        if (value.RowType == "TR") {
          // Check if this is a row entry
          TableHTML += "<tr>";

          Object.keys(ReportResult[0]).forEach(function (key) {
            if (key != "RowType") {
              TableHTML += "<td>" + value[key] + "</td>";
            }
          });
          TableHTML += "</tr>";
        }
      });
      $("#tableEntryModelData").html(TableHTML);

      // SetDataTable("tableEntryModal", [], "Milk Collection Report");
    },
    error: function () {
      ShowEntryError("Error : Milk Collection details not found");
    },
  });
}
