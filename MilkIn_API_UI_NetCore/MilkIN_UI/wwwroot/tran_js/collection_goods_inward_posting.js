$(document).ready(function () {
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
          picker.endDate.format("MM/DD/YYYY"),
      );
    },
  );

  $('input[name="datefilter"]').on(
    "cancel.daterangepicker",
    function (ev, picker) {
      $(this).val("");
    },
  );

  // SetDataTable("tableSearch", [13], "Goods Inward Posting");
});

/*  ----    ----    ----    Get SAP Posting data and assign it to the table on Search Page    ----    ----    ----    ----    */
function GetSearchList() {
  ClearDataTable("tableSearch");
  var Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetGoodsInwardPosting";
  var Method_Name = "Get_Locked";
  var url = "/Collection/GoodsInwardPosting";
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

      // show message if there is no data to show
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }

      // Fill data in table
      var TableHTML = "";
      // var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
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
        TableHTML += "<tr>";
        // TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        // TableHTML += '<td class="text-right">';
        // TableHTML += '<label class="custom-control custom-checkbox">';
        // TableHTML +=
        //   '<input type="checkbox" class="custom-control-input" id="chk' +
        //   value.milkcollectiondairy_id +
        //   '" />';
        // TableHTML +=
        //   '<label for="chk' +
        //   value.milkcollectiondairy_id +
        //   '" class="custom-control-label text-dark"></label>';
        // TableHTML += "</label>";
        // TableHTML += "</td>";

        TableHTML += '<td style="width: 20px;">';
        TableHTML +=
          '<label class="custom-control custom-checkbox " for="chk' +
          value.milkcollectiondairy_id +
          '">';

        if (value.is_posted == 0) {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.milkcollectiondairy_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;" id="chk' +
            value.milkcollectiondairy_id +
            '">';
        } else {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.milkcollectiondairy_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;"  id="chk' +
            value.milkcollectiondairy_id +
            '" checked disabled>';
        }

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';

        TableHTML += "<td>" + value.posting_date + "</td>";
        TableHTML += "<td>" + value.batch_id + "</td>";
        // TableHTML += "<td>" + Status + "</td>";

        // if (value.is_posted == 0) {
        //   TableHTML += "<td>";
        //   TableHTML +=
        //     '<a href="javascript:void(0)" id="btn' +
        //     value.batch_id +
        //     '" class="" onclick=\'SavePost("' +
        //     value.batch_id +
        //     '", "' +
        //     value.batch_id +
        //     '", "' +
        //     value.milkcollectiondairy_id +
        //     '", "' +
        //     value.batch_id +
        //     '");\'>Post <i class="fa fa-play ml-2"></i></a>';
        //   TableHTML +=
        //     '<div style="display: none; class="dimmer active" id="loader' +
        //     value.batch_id +
        //     '"><div class="lds-ring" style="margin: 0px !important;"><div></div><div></div><div></div><div></div></div></div>';
        //   TableHTML += "</td>";
        // } else {
        //   TableHTML += "<td>" + Status + "</td>";
        // }

        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.quality + "</td>";
        TableHTML += "<td>" + value.quantity + "</td>";

        TableHTML += "<td>" + value.milkprice + "</td>";
        TableHTML +=
          "<td>" +
          (parseFloat(value.milkprice) / parseFloat(value.quality)).toFixed(2) +
          "</td>";
        TableHTML += "<td>" + value.agentcost + "</td>";
        TableHTML += "<td>" + value.transportcost + "</td>";

        TableHTML += "<td>" + value.totallandedcost + "</td>";

        TableHTML += "<td hidden>" + value.fat + "</td>";
        TableHTML += "<td hidden>" + value.fatkg + "</td>";

        TableHTML += "<td hidden>" + value.snf + "</td>";
        TableHTML += "<td hidden>" + value.snfkg + "</td>";
        TableHTML += "<td>" + value.sap_document_id + "</td>";
        // TableHTML += "<td>" + Status + "</td>";

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
        TableHTML +=
          "<td class='text-right' style='width: 120px; padding:8px 5px 8px 5px;'>";

        // TableHTML +=
        //   '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowViewEntry(\'' +
        //   value.milkcollectiondairy_id +
        //   "')\">";
        // TableHTML += '<i class="fa fa-eye"></i>';
        // TableHTML += "</a>";

        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowViewEntry(\'' +
          value.milkcollectiondairy_id +
          "', '" +
          value.sap_document_id +
          "')\">";
        TableHTML += '<i class="fa fa-eye"></i>';
        TableHTML += "</a>";

        if (value.is_posted == 3) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Reverse" onclick="ReverseEntry(\'' +
            value.milkcollectiondairy_id +
            "')\">";
          TableHTML += '<i class="fa fa-backward"></i>';
          TableHTML += "</a>";
        }

        if (
          value.agentcost == "" ||
          value.agentcost == undefined ||
          value.agentcost == null ||
          value.transportcost == "" ||
          value.transportcost == undefined ||
          value.transportcost == null ||
          value.totallandedcost == "" ||
          value.totallandedcost == undefined ||
          value.totallandedcost == null
        ) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowGetDeleteGRNEntry(\'' +
            value.milkcollectiondairy_id +
            "')\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";

        TableHTML += "<td hidden>" + value.feq + "</td>";

        // TableHTML += "<td>" + value.snfcost + "</td>";
        // TableHTML += "<td>" + value.fatcost + "</td>";

        TableHTML += "<td hidden>" + value.fatrate + "</td>";
        TableHTML += "<td hidden>" + value.snfrate + "</td>";

        TableHTML += "<td hidden>" + value.fatvalue + "</td>";
        TableHTML += "<td hidden>" + value.snfvalue + "</td>";

        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetPagingDataTable("tableSearch", [17], "Goods Inward Posting");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
    },
  });
}

function SavePost(Batch_Id, Entry_Id, MilkCollectionDairy_Id, TripDocument_Id) {
  // // console.log(Batch_Id, Entry_Id, MilkCollectionDairy_Id, TripDocument_Id);
  // return;
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
        $("#btn" + Entry_Id).hide();
        $("#loader" + Entry_Id).show();
        //Post it
        var APIEndPoint = "SaveGoodsInwardPosting";
        var Method_Name = "PostInSAP";
        var url = "/Collection/GoodsInwardPosting";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,

          batch_id: Batch_Id,
          entry_id: Entry_Id,
          milkcollectiondairy_id: MilkCollectionDairy_Id,
          tripdocument_id: TripDocument_Id,
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
              Show_Success_Toastr("Goods Inward Posted successfully");
              $("#btn" + Entry_Id).hide();
              $("#loader" + Entry_Id).hide();
              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);

              $("#btn" + Entry_Id).show();
              $("#loader" + Entry_Id).hide();
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Goods Inward not Posted");
            $("#btn" + Entry_Id).show();
            $("#loader" + Entry_Id).hide();
          },
        });
      }
    },
  );
}

function ShowViewEntry(MilkCollectionDairy_Id, sap_document_id) {
  $("#SAPReverseEntry").hide();
  ShowContentDiv("Collection", "GoodsInwardPostingView", "", function () {
    if (
      sap_document_id == "" ||
      sap_document_id == undefined ||
      sap_document_id == null
    ) {
      $("#SAPReverseEntry").hide();
    } else {
      $("#SAPReverseEntry").show();
    }
    // Initialization Code
    $("#lblEntryId").html("");
    // // console.log(MilkCollectionDairy_Id);
    $("#lblEntryId").html(MilkCollectionDairy_Id);
    // var Search_Period = $("#txtSearchDuration").val();
    var APIEndPoint = "GetGoodsInwardPosting";
    var Method_Name = "Get_One";
    var url = "/Collection/GoodsInwardPosting";
    ClearDataTable("tableOtherList");
    $("#divEntryMCC").hide();
    $("#divEntryShift").hide();
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      milkcollectiondairy_id: MilkCollectionDairy_Id,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        const res = JSON.parse(result);

        if (res[0].vehicletype_name == "Truck") {
          $("#divEntryMCC").hide();
          $("#divEntryShift").show();
        }
        if (res[0].vehicletype_name == "Tanker") {
          $("#divEntryMCC").show();
          $("#divEntryShift").hide();
        }
        $("#txtEntryDate").val(res[0].posting_date);
        $("#txtEntryBatchId").val(res[0].batch_id);
        $("#txtEntryType").val(res[0].vehicletype_name);
        $("#txtEntryMCC").val(res[0].mcc_name);
        $("#txtEntryShift").val(res[0].collectionshift_name);
        $("#txtEntryMilkType").val(res[0].milktype_name);
        $("#txtEntryGainLoss").val(res[0].total_gainloss);
        $("#txtEntryMilkPrice").val(res[0].milkprice);
        $("#txtEntryAgentCost").val(res[0].agentcost);
        $("#txtEntryTransportCost").val(res[0].transportcost);
        $("#txtEntryTotalLandedCost").val(res[0].totallandedcost);

        $("#txtEntryQtyKg").val(res[0].quantity);
        $("#txtEntryQtyLtr").val(res[0].quality);

        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
          TableHTML += "<td>" + value.fat + "</td>";
          TableHTML += "<td>" + value.snf + "</td>";
          TableHTML += "<td>" + value.fatkg + "</td>";
          TableHTML += "<td>" + value.snfkg + "</td>";
          TableHTML += "<td >" + value.feq + "</td>";

          TableHTML += "<td >" + value.fatrate + "</td>";
          TableHTML += "<td >" + value.snfrate + "</td>";

          TableHTML += "<td >" + value.fatvalue + "</td>";
          TableHTML += "<td >" + value.snfvalue + "</td>";
          TableHTML += "<td hidden></td>";
          TableHTML += "</tr>";
        });

        $("#tableOtherData").html(TableHTML);
        // SetDataTable("tableOtherList", [10], "Goods Inward Posting");
      },
      error: function () {
        ShowEntryError("Error : Goods Inward Posting details not found");
      },
    });
    GetFarmerCollectionList();
    GetDairyCollectionList();
  });
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function GetFarmerCollectionList() {
  ClearDataTable("tableFarmerCollectionList");
  var MilkCollectionDairy_Id = $("#lblEntryId").html();
  var APIEndPoint = "GetGoodsInwardPosting";
  var Method_Name = "Get_Farmer";
  var url = "/Collection/GoodsInwardPosting";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
  };
  var totalAmount = 0;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      const res = JSON.parse(result);

      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";

        TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML += "<td>" + value.quality + "</td>";
        TableHTML += "<td >" + value.fat + "</td>";

        TableHTML += "<td >" + value.snf + "</td>";
        TableHTML += "<td >" + value.rate + "</td>";

        TableHTML += "<td >" + value.amount + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
        totalAmount += parseFloat(value.amount);
      });
      $("#lblTotalAmount").val(totalAmount.toFixed(2));
      $("#tableFarmerCollection").html(TableHTML);
      SetDataTable("tableFarmerCollectionList", [9], "Goods Inward Posting");
    },
    error: function () {
      ShowEntryError("Error : Goods Inward Posting Farmer details not found");
    },
  });
}

function GetDairyCollectionList() {
  ClearDataTable("tableDairyCollectionList");
  var MilkCollectionDairy_Id = $("#lblEntryId").html();
  var SessionRoleId = $("#lblSessionRoleId").html();
  var APIEndPoint = "GetGoodsInwardPosting";
  var Method_Name = "Get_Dairy";
  var url = "/Collection/GoodsInwardPosting";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
  };
  var totalQtyKg = 0;
  var totalQtyLtr = 0;
  var totalFATKG = 0;
  var totalSNFKG = 0;
  var totalGainLoss = 0;
  var totalMilkPrice = 0;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      const res = JSON.parse(result);

      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";

        TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML += "<td>" + value.quality + "</td>";
        TableHTML += "<td >" + value.fat + "</td>";

        TableHTML += "<td >" + value.snf + "</td>";

        TableHTML += "<td >" + value.protein + "</td>";
        TableHTML += "<td >" + value.ash + "</td>";
        TableHTML += "<td >" + value.sodium + "</td>";

        TableHTML += "<td >" + value.fatkg + "</td>";

        TableHTML += "<td >" + value.snfkg + "</td>";

        TableHTML += "<td >" + value.rate + "</td>";
        TableHTML += "<td >" + value.amount + "</td>";

        TableHTML += "<td >" + value.total_gainloss + "</td>";
        // TableHTML += "<td hidden></td>";

        if (SessionRoleId == "MU001") {
          TableHTML +=
            "<td class='text-center' style='width: 40px; padding:8px 5px 8px 5px;'>";
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.entry_id +
            "', '" +
            value.milkcollectiondairy_id +
            "', '" +
            value.mcc_id +
            "','" +
            value.quantity +
            "', '" +
            value.quality +
            "', '" +
            value.fat +
            "','" +
            value.snf +
            "', '" +
            value.protein +
            "', '" +
            value.ash +
            "','" +
            value.sodium +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";

          TableHTML += "</td>";
        } else {
          TableHTML += "<td hidden></td>";
        }

        TableHTML += "</tr>";

        totalQtyKg += parseFloat(value.quantity);
        totalQtyLtr += parseFloat(value.quality);
        totalFATKG += parseFloat(value.fatkg);
        totalSNFKG += parseFloat(value.snfkg);
        totalGainLoss += parseFloat(value.total_gainloss);
        totalMilkPrice += parseFloat(value.amount);
      });

      $("#lblTotalQtyKg").val(totalQtyKg.toFixed(3));
      $("#lblTotalQtyLtr").val(totalQtyLtr.toFixed(3));
      $("#lblTotalFATKG").val(totalFATKG.toFixed(2));
      $("#lblTotalSNFKG").val(totalSNFKG.toFixed(2));
      $("#lblTotalMilkPrice").val(totalMilkPrice.toFixed(2));
      $("#lblTotalGainLoss").val(totalGainLoss.toFixed(2));
      $("#tableDairyCollection").html(TableHTML);
      SetDataTable("tableDairyCollectionList", [15], "Goods Inward Posting");
    },
    error: function () {
      ShowEntryError("Error : Goods Inward Posting Farmer details not found");
    },
  });
}

function SelectAllCheckbox() {
  $("#selectAll").on("click", function () {
    var isChecked = $(this).prop("checked");
    $("#tableSearch #tableData .custom-control-input:not(:disabled)").prop(
      "checked",
      isChecked,
    );
  });

  $(document).on(
    "click",
    "#tableSearch #tableData .custom-control-input",
    function () {
      var allCheckboxes = $(
        "#tableSearch #tableData .custom-control-input:not(:disabled)",
      );
      var selectedCheckboxes = $(
        "#tableSearch #tableData .custom-control-input:checked:not(:disabled)",
      );

      // Update "Select All" checkbox state based on selected checkboxes
      $("#selectAll").prop(
        "checked",
        allCheckboxes.length === selectedCheckboxes.length,
      );
    },
  );
}

function ShowAddEntry() {
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

        var APIEndPoint = "SaveGoodsInwardPostingList";
        var Method_Name = "SetFlag";
        var url = "/Collection/GoodsInwardPosting";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          milkcollectiondairy_id: checkedIds.join(),
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
              Show_Success_Toastr("Goods Inward Added successfully");

              GetSearchList();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Goods Inward not Added");
          },
        });
      }
    },
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

function SAPReverseEntry() {
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
        var APIEndPoint = "SaveMilkCollectionReverse";
        var Method_Name = "Set_Pending";
        var url = "/Collection/GoodsInwardPosting";
        var MilkCollectionDairy_Id = $("#lblEntryId").html();
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          milkcollectiondairy_id: MilkCollectionDairy_Id,
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
                "Goods Inward Posting SAP Reverse successfully",
              );

              CloseEntry();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Goods Inward Posting SAP not Reverse");
          },
        });
      }
    },
  );
}

function ReverseEntry(milkcollectiondairy_id) {
  var APIEndPoint = "SaveMilkCollectionReverse";
  var Method_Name = "Set_Reverse";
  var url = "/Collection/GoodsInwardPosting";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: milkcollectiondairy_id,
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
        Show_Success_Toastr("Goods Inward Posting SAP Reverse successfully");

        GetSearchList();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Goods Inward Posting SAP not Reverse");
    },
  });
}

function ShowEditEntry(
  entry_id,
  milkcollectiondairy_id,
  mcc_id,
  quantity,
  quality,
  fat,
  snf,
  protein,
  ash,
  sodium,
) {
  $("#modelEntryGoodsInwardPosting")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#AddEdit").text("Edit");

  $("#lblActionEntry_Id").html("");
  $("#lblEntryMilkCollectionDairy_Id").html("");
  $("#lblEntryMCC_Id").html("");

  // $("#txtEntryQuantityKG").val("");
  $("#txtEntryQuantityLTR").val("");
  $("#txtEntryFat").val("");
  $("#txtEntrySNF").val("");
  $("#txtEntryProtein").val("");
  $("#txtEntryAsh").val("");
  $("#txtEntrySodium").val("");

  $("#lblActionEntry_Id").html(entry_id);
  $("#lblEntryMilkCollectionDairy_Id").html(milkcollectiondairy_id);
  $("#lblEntryMCC_Id").html(mcc_id);

  // $("#txtEntryQuantityKG").val(quantity);
  $("#txtEntryQuantityLTR").val(quality);
  $("#txtEntryFat").val(fat);
  $("#txtEntrySNF").val(snf);
  $("#txtEntryProtein").val(protein);
  $("#txtEntryAsh").val(ash);
  $("#txtEntrySodium").val(sodium);
}

function SaveEntry() {
  var Quantity = $("#txtEntryQuantityLTR").val().trim();
  var Fat = $("#txtEntryFat").val().trim();
  var SNF = $("#txtEntrySNF").val().trim();
  var Protein = $("#txtEntryProtein").val().trim();
  var Ash = $("#txtEntryAsh").val().trim();
  var Sodium = $("#txtEntrySodium").val().trim();

  var Entry_Id = $("#lblActionEntry_Id").html();
  var MilkCollectionDairy_Id = $("#lblEntryMilkCollectionDairy_Id").html();
  var MCC_Id = $("#lblEntryMCC_Id").html();
  var IsValid = 1;

  if (Quantity == "" || Quantity == null || Quantity == undefined) {
    IsValid = 0;
    $("#txtEntryQuantityLTR").addClass("is-invalid state-invalid");
  }
  if (Fat == "" || Fat == null || Fat == undefined) {
    IsValid = 0;
    $("#txtEntryFat").addClass("is-invalid state-invalid");
  }
  if (SNF == "" || SNF == null || SNF == undefined) {
    IsValid = 0;
    $("#txtEntrySNF").addClass("is-invalid state-invalid");
  }
  if (Protein == "" || Protein == null || Protein == undefined) {
    IsValid = 0;
    $("#txtEntryProtein").addClass("is-invalid state-invalid");
  }
  if (Ash == "" || Ash == null || Ash == undefined) {
    IsValid = 0;
    $("#txtEntryAsh").addClass("is-invalid state-invalid");
  }
  if (Sodium == "" || Sodium == null || Sodium == undefined) {
    IsValid = 0;
    $("#txtEntrySodium").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveGoodsInwardPostingGRN";
    var Method_Name = "Update";

    var url = "/Collection/GoodsInwardPosting";
    var reqdata = {
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      entry_id: Entry_Id,
      milkcollectiondairy_id: MilkCollectionDairy_Id,
      mcc_id: MCC_Id,
      quantity: Quantity,
      fat: Fat,
      snf: SNF,
      protein: Protein,
      ash: Ash,
      sodium: Sodium,
    };

    console.log(reqdata);

    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          Show_Success_Toastr("Details saved successfully");

          GetDairyCollectionList();
        } else {
          Hide_Loader();
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : Details not saved");
      },
    });
    $("#modelEntryGoodsInwardPosting").modal("hide");
    $("#btn_Save").prop("disabled", false);
  }
}

function ShowGetDeleteGRNEntry(MilkCollectionDairy_Id) {
  Show_Loader();
  $("#modelEntryGRN")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  // $("#modelEntryGRN").modal("hide");

  $("#lblActionmilkcollectiondairy_id").html("");
  $("#lblAction_Is_Locked").html("");
  $("#lblActionmilkcollectiondairy_id").html(MilkCollectionDairy_Id);

  var APIEndPoint = "GetGoodsInwardPosting";
  var Method_Name = "Get_Delete";
  var url = "/Collection/GoodsInwardPosting";
  ClearDataTable("tableEntryModelGRN");

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      Hide_Loader();
      const res = JSON.parse(result);

      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.batch_id + "</td>";
        TableHTML += "<td>" + value.sap_document_id + "</td>";
        TableHTML += "<td hidden>" + value.is_posted + "</td>";
        TableHTML += "</tr>";

        if (value.is_posted == 1) {
          $("#lblAction_Is_Locked").html(1);
        }
      });

      $("#tableEntryModelGRNData").html(TableHTML);
      SetDataTable("tableEntryModelGRN", [3], "Goods Inward Posting");
    },
    error: function () {
      Hide_Loader();
      ShowEntryError("Error : Goods Inward Posting details not found");
    },
  });
}

function ShowDeleteGRNEntry() {
  var Is_Locked = $("#lblAction_Is_Locked").html();

  if (Is_Locked == 1) {
    Show_Error_Toastr(
      "Error : Material document is already created. Kindly first reverse the data from SAP, then remove the specific batch ID. Generate the material document batch reversal from the admin panel before removing this data.",
    );
    return;
  } else {
    swal(
      {
        title: "Are you sure?",
        text: "You won't be able to revert this!",
        icon: "question",
        type: "warning",
        showCancelButton: true,
        confirmButtonText: "Yes, delete it!",
      },
      function (result) {
        if (result == true) {
          SaveDeleteEntry();
        }
      },
    );
  }
}

function SaveDeleteEntry() {
  var MilkCollectionDairy_Id = $("#lblActionmilkcollectiondairy_id").html();

  var APIEndPoint = "SaveGoodsInwardPostingList";
  var Method_Name = "Set_Delete";
  var url = "/Collection/GoodsInwardPosting";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
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
        Show_Success_Toastr("Goods Inward Added successfully");
        $("#modelEntryGRN").modal("hide");
        GetSearchList();
      } else {
        $("#modelEntryGRN").modal("hide");
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      $("#modelEntryGRN").modal("hide");
      Show_Error_Toastr("Error : Goods Inward Posting not delete");
    },
  });
}
