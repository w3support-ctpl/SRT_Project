$(document).ready(function () {
  $("#txtSearchPeriod").daterangepicker();

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

  var currentDate = new Date().toISOString().slice(0, 10);

  // Set the current date as the value for the input field
  $("#txtEntryCollectionDate").val(currentDate);
});

function ShowAddEntry() {
  $("#modelEntryFarmerCollection")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#ddlEntryFarmer").select2();
  $("#ddlEntryMilkType").select2();
  $("#ddlEntryMilkStatus").select2();
  $("#ddlEntryCollectionShift").select2();

  GetMaster("ddlEntryFarmer", "Select Farmer", "GetFarmer", "", "");
  GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", "", "");
  GetMaster(
    "ddlEntryMilkStatus",
    "Select Milk Status",
    "GetMilkStatus",
    "C016001",
    ""
  );
  GetMaster(
    "ddlEntryCollectionShift",
    "Select Collection Shift",
    "GetMilkCollectionShiftAll",
    "",
    ""
  );
}

function GetSearchList() {
  ClearDataTable("tableSearch");
  // Get Milk Collection data from database and show in the table on Search page
  var APIEndPoint = "GetMissingFarmer";
  var Search_Period = $("#txtSearchPeriod").val();

  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    $("#txtSearchPeriod").addClass("is-invalid state-invalid");
    return;
  }

  var Method_Name = "Get";
  var url = "/invoice/InvoiceMissingFarmer";
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
      var Status;
      $.each(res, function (data, value) {
        if (value.is_posted == 0) {
          Status = "Pending";
        } else {
          Status = "Posted";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.collection_date + "</td>";
        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [11], "Farmer Income");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SaveFarmerCollectionEntry() {
  var Farmer_Id = $("#ddlEntryFarmer").val().trim();
  var MilkType_Id = $("#ddlEntryMilkType").val().trim();
  var MilkStatus_Id = $("#ddlEntryMilkStatus").val().trim();
  var Weight = $("#txtEntryLiters").val().trim();
  var FAT = $("#txtEntryFAT").val().trim();
  var SNF = $("#txtEntrySNF").val().trim();
  var Search_Period = $("#txtEntryCollectionDate").val();
  var Collection_Shift = $("#ddlEntryCollectionShift").val();
  // var Action = ;
  var IsValid = 1;
  if (Farmer_Id == "" || Farmer_Id == null || Farmer_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryFarmer").addClass("is-invalid state-invalid");
  }
  if (MilkType_Id == "" || MilkType_Id == null || MilkType_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMilkType").addClass("is-invalid state-invalid");
  }
  if (
    MilkStatus_Id == "" ||
    MilkStatus_Id == null ||
    MilkStatus_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryMilkStatus").addClass("is-invalid state-invalid");
  }
  if (
    Collection_Shift == "" ||
    Collection_Shift == null ||
    Collection_Shift == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryCollectionShift").addClass("is-invalid state-invalid");
  }
  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    IsValid = 0;
    $("#txtEntryCollectionDate").addClass("is-invalid state-invalid");
  }
  if (
    Weight == "" ||
    Weight == null ||
    Weight == undefined ||
    Is_Valid_Float(Weight) == false
  ) {
    IsValid = 0;
    $("#txtEntryLiters").addClass("is-invalid state-invalid");
  }
  if (
    FAT == "" ||
    FAT == null ||
    FAT == undefined ||
    Is_Valid_Float(FAT) == false
  ) {
    IsValid = 0;
    $("#txtEntryFAT").addClass("is-invalid state-invalid");
  }
  if (
    SNF == "" ||
    SNF == null ||
    SNF == undefined ||
    Is_Valid_Float(SNF) == false
  ) {
    IsValid = 0;
    $("#txtEntrySNF").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowItemError("Invalid Input(s). Can't be saved.");
    return;
  }

  Show_Loader();
  var Method_Name = "Create";
  var Entry_Id = "";
  var Action_Name = $("#AddEditFarmerCollection").html();
  if (Action_Name == "Edit") {
    Method_Name = "Update";
    Entry_Id = $("#lblActionFarmerCollection").html();
  }

  var APIEndPoint = "SaveMissingFarmer";
  var url = "/invoice/InvoiceMissingFarmer";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    farmer_id: Farmer_Id,
    weight: Weight,
    snf: SNF,
    fat: FAT,
    milktype_id: MilkType_Id,
    milkstatus_id: MilkStatus_Id,
    search_period: Search_Period,
    collectionshift_id: Collection_Shift,
  };

  //   // console.log(reqdata);
  // debugger;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      // // console.log(result);
      if (result[0].result_id == 1) {
        Hide_Loader();
        // Show Success Message
        Show_Success_Toastr(result[0].result_description);

        $("#modelEntryFarmerCollection").modal("hide");
        // GetSearchList();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        // $("#btn_MCCSave").show();
        $("#modelEntryFarmerCollection").modal("hide");
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Farmer details not saved");
      // $("#btn_MCCSave").show();
    },
  });
}

$("#modelEntryFarmerCollection").on("hidden.bs.modal", function (e) {
  $("#ddlEntryFarmer").val("");
  $("#ddlEntryMilkType").val("");
  $("#ddlEntryMilkStatus").val("");
  $("#txtEntryLiters").val("");
  $("#txtEntryFAT").val("");
  $("#txtEntrySNF").val("");
  $("#txtEntryCollectionDate").val("");
  $("#ddlEntryCollectionShift").val("");
  GetSearchList();
});
