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

    isInvalidDate: function (date) {
      return date.isBefore("2024-02-01");
    },
  });

  $("#txtSearchPeriodHidden").val(
    moment().subtract(30, "days").format("MM/DD/YYYY") +
      " - " +
      moment().format("MM/DD/YYYY")
  );

  $("#SearchDealerNameDiv").hide();
  $("#SearchDealerNameDiv2").hide();

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
  GetMaster("ddlSearchReportType", "", "GetReportTypes_v1", "", "CR");

  $("#ddlSearchDealerName").select2();
  GetMaster("ddlSearchDealerName", "", "GetDealer", "", "");

  $("#ddlSearchDealerName2").select2();
  GetMaster("ddlSearchDealerName2", "Select Dealer", "GetDealer", "", "");

  var ReportType = $("#lblReportType").html();
  if (ReportType != "") {
    // GetSearchList(ReportType);
  }
});

function SetReportFilters() {
  $("#divError").hide();
  var ReportGroup = $("#lblReportGroup").html();
  var ReportType = $("#ddlSearchReportType").val();

  if (ReportType == "C048010") {
    $("#SearchDealerNameDiv").show();
    $("#SearchDealerNameDiv2").hide();
  }
  if (
    ReportType == "C048022" ||
    ReportType == "C048023" ||
    ReportType == "C048024" ||
    ReportType == "C048025"
  ) {
    $("#SearchDealerNameDiv").hide();
    $("#SearchDealerNameDiv2").show();
  }
}

function GetSearchList() {
  $("#divError").hide();
  $("#divReportLoader").show();
  var MCCType_Id = "";
  var MCCCollectionShift_Id = "";
  var MilkType_Id = "";
  var MCC_Id = "";
  var ReportPeriod = "";
  var ReportGroup = $("#lblReportGroup").html();
  var ReportTypeId = $("#ddlSearchReportType").val();

  var dealersid = $("#ddlSearchDealerName").val().join();
  var dealersid_2 = $("#ddlSearchDealerName2").val().trim();
  // // debugger;
  if (
    ReportTypeId == "C048022" ||
    ReportTypeId == "C048023" ||
    ReportTypeId == "C048024" ||
    ReportTypeId == "C048025"
  ) {
    if (dealersid_2 == "" || dealersid_2 == null || dealersid_2 == undefined) {
      $("#divError").show();
      $("#lblErrorMessage").html("Select Dealer Name <br/>");
      return;
    } else {
      dealersid = dealersid_2;
      $("#divError").hide();
    }
  } else {
    dealersid = dealersid;
    $("#divError").hide();
  }

  ShowContentDiv("Report", "CrateRegisterReport", "", function () {
    ClearDataTable("tableReport");

    var APIEndPoint = "GetDealerStockReport";
    ReportPeriod = $("#txtSearchPeriodHidden").val();

    var url = "/Report/GetDealerStockReport";
    var Method_Name = "Get";

    var reqdata = {
      Method_Name: Method_Name,
      api_end_point: APIEndPoint,
      Report_Type: ReportTypeId,
      ReportPeriod: ReportPeriod,
      Dealer_id: dealersid,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result);
        const ReportResult = JSON.parse(res);

        if (ReportResult.length == 1) {
          $("#divReportLoader").hide();
          ShowEntryError("Error : Report details not found");
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

        SetDataTable_Report("tableReport", [], "Crate Report");
        $("#divReportLoader").hide();
      },
      error: function () {
        $("#divReportLoader").hide();
        ShowEntryError("Error : Report details not found");
      },
    });
  });
}

function CloseReport() {
  HideContentDiv();
}
