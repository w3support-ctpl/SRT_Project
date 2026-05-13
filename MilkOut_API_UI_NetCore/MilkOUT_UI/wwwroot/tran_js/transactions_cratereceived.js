$(document).ready(function () {
  //SetDataTable("tableSearch", [4], "SalesArea");
  $("#ddlSearchDealer").select2();
  GetMaster("ddlSearchDealer", "Select Dealer Name", "GetDealer", "", "");

  const style = document.createElement("style");
  document.head.appendChild(style);
  style.sheet.insertRule(
    "input::-webkit-inner-spin-button { -webkit-appearance: none; }",
    0
  );

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

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  $("#tableData").empty();
  var SearchDealer_Id = "%" + $("#ddlSearchDealer").val() + "%";
  var ReceivedPeriod = $("#txtSearchReceivedPeriod").val();
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var APIEndPoint = "GetCrateReceived";
  var url = "/Transactions/CrateReceived";
  var reqdata = {
    method_name: Method_Name,
    dealer_id: SearchDealer_Id,
    received_period: ReceivedPeriod,
    api_end_point: APIEndPoint,
  };

  Show_Loader();

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
        Hide_Loader();
        Show_Error_Toastr("Data not found.");
        $("#btn_Search").prop("disabled", false);
        return;
      }
      // Fill data in table
      var TableHTML = "";
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        EditFlag = value.is_approved;

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.dealer_name + "</td>";
        TableHTML += "<td>" + value.created_on + "</td>";
        TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML += "<td>" + value.cratebalance + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
            value.receivedcrate_id +
            "', '" +
            value.dealer_id +
            "','" +
            value.created_on +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\'' +
            value.receivedcrate_id +
            "', '" +
            value.dealer_id +
            "','" +
            value.created_on +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [5], "Crate Received from Dealer");
      $("#btn_Search").prop("disabled", false);
      Hide_Loader();
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

function ShowAddEntry() {
  ShowContentDiv("Transactions", "CrateReceivedAdd", "", function () {
    // Initialization Code

    $("#lblEntryId").html("New");
    $("#lblAction").html("Add");
    $("#divFooterDelete").hide();

    $("#ddlEntryDealer").select2();
    GetMaster("ddlEntryDealer", "Select Dealer Name", "GetDealer", "", "");

    var currentDate = new Date();
    var formattedDate = currentDate.toISOString().slice(0, 10);
    $("#txtEntryReceivedOn").val(formattedDate);

    $("#ddlEntryDealer").prop("disabled", false);

    $("#txtEntryReceivedOn").prop("disabled", false);

    // get material and quantity from database and assign it's values to the rows in table
    var Method_Name = "Get_Material";
    var APIEndPoint = "GetCrateReceived";
    var url = "/Transactions/CrateReceived";
    var reqdata = {
      method_name: Method_Name,
      receivedcrate_id: "",
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td>" + (data + 1) + "</td>";
          TableHTML += "<td>" + value.material_name + "</td>";
          //   TableHTML += "<td>" + value.quantity + "</td>";

          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.quantity +
            "'/>";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.approved_quantity +
            "'/>";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.approved_quantity +
            "'/>";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.approved_quantity +
            "'/>";
          TableHTML += "<td hidden>" + value.material_id + "</td>";
          TableHTML += "</tr>";
        });

        ClearDataTable("tableEntryList");
        $("#tableEntry").html(TableHTML);
        SetDataTable(
          "tableEntryList",
          [4],
          "Crate Received Quantity and Material"
        );

        $("#btn_Save").show();
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

function ShowEditEntry(Action, ReceivedCrate_Id, Dealer_Id, Created_On) {
  ShowContentDiv("Transactions", "CrateReceivedEdit", "", function () {
    var inputDate = new Date(Created_On);

    // Extract year, month, and day
    var year = inputDate.getFullYear();
    var month = ("0" + (inputDate.getMonth() + 1)).slice(-2); // Add leading zero if needed
    var day = ("0" + inputDate.getDate()).slice(-2); // Add leading zero if needed

    // Format the date as YYYY-MM-DD
    var formattedDate = year + "-" + month + "-" + day;
    $("#txtEntryReceivedOn").val(formattedDate);

    // assign values to input fields
    $("#lblEntryId").html(ReceivedCrate_Id);
    $("#lblAction").html(Action);

    $("#ddlEntryDealer").select2();
    GetMaster(
      "ddlEntryDealer",
      "Select Dealer Name",
      "GetDealer",
      Dealer_Id,
      ""
    );

    var disabled = "";
    if (Action == "Edit") {
      $("#btn_Save").show();
    } else if (Action == "View") {
      $("#btn_Save").hide();
      disabled = "disabled";
    }

    // get material and quantity from database and assign it's values to the rows in table
    var Method_Name = "Get_One";
    var APIEndPoint = "GetCrateReceived";
    var url = "/Transactions/CrateReceived";
    var reqdata = {
      method_name: Method_Name,
      receivedcrate_id: ReceivedCrate_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td>" + (data + 1) + "</td>";
          TableHTML += "<td>" + value.material_name + "</td>";
          // TableHTML += "<td>" + value.quantity + "</td>";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.quantity +
            "' " +
            disabled +
            " />";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.good_quantity +
            "' " +
            disabled +
            " />";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.broken_quantity +
            "' " +
            disabled +
            " />";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.thirdparty_quantity +
            "' " +
            disabled +
            " />";
          TableHTML += "<td hidden>" + value.material_id + "</td>";
          TableHTML += "</tr>";
        });

        ClearDataTable("tableEntryList");
        $("#tableEntry").html(TableHTML);
        SetDataTable(
          "tableEntryList",
          [4],
          "Crate Received Quantity and Material"
        );
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
  return;
}

function ShowEdit(Action, ReceivedCrate_Id, Dealer_Id, Created_On) {
  ShowContentDiv("Transactions", "CrateReceivedEdit", "", function () {
    var inputDate = new Date(Created_On);

    // Extract year, month, and day
    var year = inputDate.getFullYear();
    var month = ("0" + (inputDate.getMonth() + 1)).slice(-2); // Add leading zero if needed
    var day = ("0" + inputDate.getDate()).slice(-2); // Add leading zero if needed

    // Format the date as YYYY-MM-DD
    var formattedDate = year + "-" + month + "-" + day;
    $("#txtEntryReceivedOn").val(formattedDate);

    // assign values to input fields
    $("#lblEntryId").html(ReceivedCrate_Id);
    $("#lblAction").html(Action);

    $("#ddlEntryDealer").select2();
    GetMaster(
      "ddlEntryDealer",
      "Select Dealer Name",
      "GetDealer",
      Dealer_Id,
      ""
    );

    var disabled = "";
    if (Action == "Edit") {
      $("#btn_Save").show();
    } else if (Action == "View") {
      $("#btn_Save").hide();
      disabled = "disabled";
    }

    // get material and quantity from database and assign it's values to the rows in table
    var Method_Name = "Get_One";
    var APIEndPoint = "GetCrateReceived";
    var url = "/Transactions/CrateReceived";
    var reqdata = {
      method_name: Method_Name,
      receivedcrate_id: ReceivedCrate_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td>" + (data + 1) + "</td>";
          TableHTML += "<td>" + value.material_name + "</td>";
          TableHTML += "<td>" + value.quantity + "</td>";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.good_quantity +
            "' " +
            disabled +
            " />";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.broken_quantity +
            "' " +
            disabled +
            " />";
          TableHTML +=
            "<td>" +
            "<input type='number' class='form-control' value='" +
            value.thirdparty_quantity +
            "' " +
            disabled +
            " />";
          TableHTML += "<td hidden>" + value.material_id + "</td>";
          TableHTML += "</tr>";
        });

        ClearDataTable("tableEntryList");
        $("#tableEntry").html(TableHTML);
        SetDataTable(
          "tableEntryList",
          [4],
          "Crate Received Quantity and Material"
        );
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
  return;
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var Is_Approved = 1;

  // Start Saving
  $("#btn_Save").prop("disabled", true);

  var Dealer_Id = $("#ddlEntryDealer").val();
  var Received_Period = $("#txtEntryReceivedOn").val();

  if ($("#lblAction").html() == "Add") {
    var Method_Name = "Create_1";
    if (Dealer_Id == "") {
      Show_Error_Toastr("Error :Please Select Dealer");
      return;
    }
  } else {
    var Method_Name = "Update";
  }

  var ReceivedCrate_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveCrateReceived";
  var url = "/Transactions/CrateReceived";

  var Approved_Data = "<ApprovedData>";
  var invalid = 0;
  var invalid_1 = 0;
  $("#tableEntryList tbody tr").each(function () {
    var Quantity =
      $(this).find("td:eq(2) input").val() == ""
        ? 0
        : $(this).find("td:eq(2) input").val();

    var Good =
      $(this).find("td:eq(3) input").val() == ""
        ? 0
        : $(this).find("td:eq(3) input").val();
    var Bad =
      $(this).find("td:eq(4) input").val() == ""
        ? 0
        : $(this).find("td:eq(4) input").val();
    var ThirdParty =
      $(this).find("td:eq(5) input").val() == ""
        ? 0
        : $(this).find("td:eq(5) input").val();

    var Material = $(this).find("td:eq(1)").text();
    var MaterialId = $(this).find("td:eq(6)").text();
    Approved_Data += "<Item>";
    Approved_Data += "<MaterialId>" + MaterialId + "</MaterialId>";
    Approved_Data += "<Quantity>" + Quantity + "</Quantity>";
    Approved_Data += "<GoodQuantity>" + Good + "</GoodQuantity>";
    Approved_Data += "<BrokenQuantity>" + Bad + "</BrokenQuantity>";
    Approved_Data +=
      "<ThirdPartyQuantity>" + ThirdParty + "</ThirdPartyQuantity>";
    Approved_Data += "</Item>";

    if (Good < 0 || Bad < 0 || ThirdParty < 0) {
      invalid = 1;
    }
    // 🔴 Quantity mismatch check
    if (
      invalid_1 == 0 &&
      Number(Quantity) !== Number(Good) + Number(Bad) + Number(ThirdParty)
    ) {
      //   console.log(Quantity, Good, Bad, ThirdParty);
      //   console.log(Quantity, Number(Good) + Number(Bad) + Number(ThirdParty));

      invalid_1 = 2;
      return false; // stop loop
    }
  });
  Approved_Data += "</ApprovedData>";

  if (invalid == 1) {
    Show_Error_Toastr("Error :Quantity Can not be negative");
    return;
  }
  if (invalid_1 == 2) {
    Show_Error_Toastr(
      "Error: Total Quantity must be equal to Good + Bad + Third Party quantities."
    );
    return;
  }

  var reqdata = {
    method_name: Method_Name,
    receivedcrate_id: ReceivedCrate_Id,
    is_approved: Is_Approved,
    approved_data: Approved_Data,
    api_end_point: APIEndPoint,
    dealer_id: Dealer_Id,
    received_period: Received_Period,
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
        // Show Success Message

        $("#btn_Save").hide();
        $("#lblEntryId").html(result[0].result_extra_key);
        $("#lblAction").html("View");
        $("#tableEntryList tbody tr").each(function () {
          $(this).find("td:eq(2) input").prop("disabled", true);
          $(this).find("td:eq(3) input").prop("disabled", true);
          $(this).find("td:eq(4) input").prop("disabled", true);
          $(this).find("td:eq(5) input").prop("disabled", true);
        });

        ShowEditEntry(
          "Edit",
          result[0].result_extra_key,
          Dealer_Id,
          Received_Period
        );

        ShowEntrySuccess("Entry Saved Successfully.");

        Show_Success_Toastr("Entry Saved Successfully.");
      } else if (result[0].result_id == -1) {
        swal(
          {
            title: "Are you sure?",
            text: "Crate Already Added",
            icon: "question",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, Add!",
          },
          function (result) {
            if (result == true) {
              var reqdata = {
                method_name: "CreateNew_1",
                receivedcrate_id: ReceivedCrate_Id,
                is_approved: Is_Approved,
                approved_data: Approved_Data,
                api_end_point: APIEndPoint,
                dealer_id: Dealer_Id,
                received_period: Received_Period,
              };

              $.ajax({
                type: "POST",
                url: url,
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                data: reqdata,
                success: function (res) {
                  var result = JSON.parse(res);
                  if (result[0].result_id == 1) {
                    // Show Success Message

                    $("#btn_Save").hide();
                    $("#lblEntryId").html(result[0].result_extra_key);
                    $("#lblAction").html("View");
                    $("#tableEntryList tbody tr").each(function () {
                      $(this).find("td:eq(2) input").prop("disabled", true);
                      $(this).find("td:eq(3) input").prop("disabled", true);
                      $(this).find("td:eq(4) input").prop("disabled", true);
                      $(this).find("td:eq(5) input").prop("disabled", true);
                    });

                    ShowEditEntry(
                      "Edit",
                      result[0].result_extra_key,
                      Dealer_Id,
                      Received_Period
                    );

                    ShowEntrySuccess("Entry Saved Successfully.");

                    Show_Success_Toastr("Entry Saved Successfully.");
                  } else {
                    ShowEntryError("Error : " + result[0].result_description);
                    $("#btn_Save").prop("disabled", false);
                  }
                },
                error: function () {
                  Show_Error_Toastr("Error : Sales Area details not saved");
                  $("#btn_Save").prop("disabled", false);
                },
              });
            }
          }
        );

        ShowEntryError("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Sales Area details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
  return;
}
