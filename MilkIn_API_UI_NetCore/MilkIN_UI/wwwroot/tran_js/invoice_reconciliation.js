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
  
    GetMaster("dllSearchMCCType", "All MCC Type", "GetMCCType", "", "");
    
  });
  
  function GetSearchMCCName() {
    $("#dllSearchMCC")
      .empty()
      .append($("<option></option>").val("").html("All MCC"));
    var MCCType_Id = $("#dllSearchMCCType").val();
    GetMaster("dllSearchMCC", "All MCC", "Get_MCC", "", MCCType_Id);
  }