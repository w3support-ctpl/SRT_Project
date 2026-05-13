var successfulCallbacks = 0;
$(document).ready(function () {
  //Initialize Code
  $("#ddlSearchMilkType").select2();
  $("#ddlSearchMilkStatus").select2();
  GetMaster("ddlSearchMilkType", "Select Milk Type", "GetMilkType", "", "");
  GetMaster(
    "ddlSearchMilkStatus",
    "Select Milk Status",
    "GetMilkStatus",
    "C016001",
    ""
  );
  // SetDataTable("tableSearch", [6], "Milk");
  $("#divTabs").hide();
  $("#divassignmcctables").hide();
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  var ChartName = "%" + $("#txtSearchChartName").val() + "%";
  var MilkType_Id = "%" + $("#ddlSearchMilkType").val() + "%";
  var MilkStatus_Id = "%" + $("#ddlSearchMilkStatus").val() + "%";
  var APIEndPoint = "GetMilkRate";
  var Method_Name = "Get";
  var url = "/Rate/MilkRate";
  var reqdata = {
    method_name: Method_Name,
    chart_name: ChartName,
    milktype_id: MilkType_Id,
    milkstatus_id: MilkStatus_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      //// console.log(res);
      // Fill data in table
      var TableHTML = "";
      //var Row_No = 0;
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      $.each(res, function (data, value) {
        var Active_Status;
        //Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else if (value.is_active == 1) {
          Active_Status = "Active";
        }
        if (value.is_lived == 0) {
          Active_Status = "Draft";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.chart_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        // TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.base_rate + "</td>";
        TableHTML +=
          "<td>" + value.fat_deduction + value.fat_incentives + "</td>";
        TableHTML +=
          "<td>" + value.snf_deduction + value.snf_incentives + "</td>";
        // TableHTML += "<td>" + value.uom_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 120px; padding: 8px 5px 8px 5px;">';
        if (Active_Status == "Active") {
          // TableHTML +=
          //   '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
          //   value.chart_id +
          //   "', false);\">";
          //   // '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowMilkRateView();">'
          // TableHTML += '<i class="fa fa-eye"></i>';
          // TableHTML += "</a> |";

          TableHTML +=
            '<a href="javascript:void(0)" id="btn' +
            value.chart_id +
            '" class="btn btn-icon py-0" onclick=\'ShowMilkRateView("Home","Chart","' +
            value.chart_id +
            '", "' +
            value.chart_name +
            '", "' +
            value.milktype_id +
            '", "' +
            value.milktype_name +
            '", "' +
            value.collectionshift_id +
            '", "' +
            value.collectionshift_name +
            '", "' +
            "" +
            '");\'><i class="fa fa-eye"></i></a> |';
        }
        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.chart_id +
            "', false);\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (Active_Status == "Active") {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="AssignMCC" onclick="ShowEditEntry(\'' +
            value.chart_id +
            "', true);\">";
          TableHTML += '<i class="fa fa-sitemap"></i>';
          TableHTML += "</a>";
        }
        if (Active_Status == "Draft") {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntry(\'' +
            value.chart_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [8], "Milk");
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description
      );
    },
  });
  $("#btn_Search").prop("disabled", false);
  return;
}

function ShowAddEntry() {
  ShowContentDiv("Rate", "MilkAdd", "", function () {
    // hide tabs
    $("#divTabs").hide();
    $("#divassignmcctables").hide();

    // Initialization Code
    $("#ddlEntryMilkType").select2();
    $("#ddlEntryMilkStatus").select2();
    $("#ddlEntryMilkCollectionShift").select2();
    $("#ddlEntryBaseUnit").select2();

    $("#ddlEntryDeductionSNFSlab").select2();
    $("#ddlEntryDeductionFatSlab").select2();
    $("#ddlEntryIncentivesSNFSlab").select2();
    $("#ddlEntryIncentivesFatSlab").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();

    GetMaster("ddlEntryMilkType", "Select Milk Type", "GetMilkType", "", "");
    GetMaster(
      "ddlEntryMilkStatus",
      "Select Milk Status",
      "GetMilkStatus",
      "C016001",
      ""
    );
    GetMaster(
      "ddlEntryMilkCollectionShift",
      "Select Shift",
      "GetMilkCollectionShiftAll",
      "",
      ""
    );
    GetMaster("ddlEntryBaseUnit", "Select Base Unit", "GetUOM", "C019001", "");
  });
}

function ShowMilkRateView(
  set,
  action,
  chart_id,
  chart_name,
  milktype_id,
  milktype_name,
  collectionshift_id,
  collectionshift_name,
  date
) {
  ShowContentDiv("Rate", "MilkRateView", "", function () {
    var totalCallbacks = 3;
    //// console.log(action);
    $("#divVeiwMCC").hide();
    $("#divVeiwChart").hide();
    if (action == "MCC") {
      $("#divVeiwMCC").show();
      $("#divVeiwChart").hide();

      $("#ddlVeiwMCC").select2();
      $("#ddlViewMilkType").select2();
      $("#ddlViewMilkCollectionShift").select2();

      GetMaster("ddlViewMilkType", "Select Milk Type", "GetMilkType", "", "");

      GetMaster(
        "ddlViewMilkCollectionShift",
        "Select Shift",
        "GetMilkCollectionShiftAll",
        "",
        ""
      );
      GetMaster("ddlVeiwMCC", "Select MCC", "GetMCC", "", "");
      $("#lblActionView").html("MCC");
      $("#lblActionSet").html(set);
    }

    if (action == "Chart") {
      $("#divVeiwMCC").hide();
      $("#divVeiwChart").show();
      $("#ddlVeiwChart").prop("disabled", "true");
      $("#ddlViewMilkType").prop("disabled", "true");
      $("#ddlViewMilkCollectionShift").prop("disabled", "true");

      $("#ddlVeiwChart").select2();
      $("#ddlViewMilkType").select2();
      $("#ddlViewMilkCollectionShift").select2();
      $("#lblActionView").html("Chart");
      $("#lblActionSet").html(set);

      if (date != "" && date != null && date != undefined) {
        $("#txtViewDate").val(date);
        var totalCallbacks = 3;

        GetMasterCallback(
          "ddlViewMilkType",
          "Select Milk Type",
          "GetMilkType",
          milktype_id,
          "",
          function (success) {
            if (success) {
              successfulCallbacks++;
              checkCallbacks(totalCallbacks);
            }
          }
        );
        GetMasterCallback(
          "ddlViewMilkCollectionShift",
          "Select Shift",
          "GetMilkCollectionShiftAll",
          collectionshift_id,
          "",
          function (success) {
            if (success) {
              successfulCallbacks++;
              checkCallbacks(totalCallbacks);
            }
          }
        );
        GetMasterCallback(
          "ddlVeiwChart",
          "Select Chart",
          "GetChart",
          chart_id,
          "",
          function (success) {
            if (success) {
              successfulCallbacks++;
              checkCallbacks(totalCallbacks);
            }
          }
        );

        // GetMilkRateView();
      } else {
        GetMaster(
          "ddlViewMilkType",
          "Select Milk Type",
          "GetMilkType",
          milktype_id,
          ""
        );

        GetMaster(
          "ddlViewMilkCollectionShift",
          "Select Shift",
          "GetMilkCollectionShiftAll",
          collectionshift_id,
          ""
        );
        GetMaster("ddlVeiwChart", "Select Chart", "GetChart", chart_id, "");
      }
    }
    // Initialization Code
  });
}

function checkCallbacks(totalCallbacks) {
  if (successfulCallbacks === totalCallbacks) {
    GetMilkRateView();
  }
}

function ShowMilkRateMCCView() {
  ShowContentDiv("Rate", "MilkRateMCCView", "", function () {
    $("#ddlViewType").select2();
    GetMaster("ddlViewType", "Select Type", "GetMCCType", "", "");
  });
}

function GetMilkRateView() {
  $("#divTabsView").show();
  // $("#tab2").hide();
  // $("#btn_View").prop("disabled", true);
  var Action_Name = $("#lblActionView").html();
  var Method_Name = "";

  var ViewMCC_Id = "";
  if (Action_Name == "MCC") {
    ViewMCC_Id = $("#ddlVeiwMCC").val();
    Method_Name = "GetMilkRate";
  }
  if (Action_Name == "Chart") {
    ViewMCC_Id = $("#ddlVeiwChart").val();
    Method_Name = "GetMilkRateChart";
  }

  var ViewMilkType_Id = $("#ddlViewMilkType").val();
  var ViewShift_Id = $("#ddlViewMilkCollectionShift").val();
  var ViewDate = $("#txtViewDate").val();

  var IsValid = 1;
  if (ViewMCC_Id == "" && Action_Name == "MCC") {
    IsValid = 0;
    $("#ddlVeiwMCC").addClass("is-invalid state-invalid");
  }
  if (ViewMCC_Id == "" && Action_Name == "Chart") {
    IsValid = 0;
    $("#ddlVeiwChart").addClass("is-invalid state-invalid");
  }
  if (ViewMilkType_Id == "") {
    IsValid = 0;
    $("#ddlViewMilkType").addClass("is-invalid state-invalid");
  }
  if (ViewShift_Id == "") {
    IsValid = 0;
    $("#ddlViewMilkCollectionShift").addClass("is-invalid state-invalid");
  }
  if (ViewDate == "") {
    IsValid = 0;
    $("#txtViewDate").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't proceed.");
    return;
  }

  // Global Array to store Matrix Table
  RateChartMatrix = [];
  MilkRateDetails = [];
  // creare arrays for SNF - row & Fat - col
  // SNF_Heading = [
  //   "Fat/SNF",
  //   7.5,
  //   7.6,
  //   7.7,
  //   7.8,
  //   7.9,
  //   8.0,
  //   8.1,
  //   8.2,
  //   8.3,
  //   8.4,
  //   8.5,
  //   8.6,
  //   8.7,
  //   8.8,
  //   8.9,
  //   9.0,
  //   9.1,
  //   9.2,
  //   9.3,
  //   9.4,
  //   9.5,
  // ];
  // Fat_Heading = [
  //   3.0, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 4.1, 4.2, 4.3, 4.4,
  //   4.5, 4.6, 4.7, 4.8, 4.9, 5.0,
  // ];

  BaseRateAmount = 0;

  var BaseFAT = 0;
  var BaseSNF = 0;

  var APIEndPoint = "GetMilkRate";

  var url = "/Rate/MilkRate";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: ViewMCC_Id,
    milktype_id: ViewMilkType_Id,
    collectionshift_id: ViewShift_Id,
    rate_date: ViewDate,
  };

  //// console.log(reqdata);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      //// console.log(res);

      // Fill data in table
      var TableHTML = "";
      //var Row_No = 0;
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<th>" + value.milkrateentrytype_name + "</th>";
        TableHTML += "<td>" + value.slab_max + " - " + value.slab_min + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        //TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";

        var MilkRate = {
          milkrateentrytype_id: value.milkrateentrytype_id,
          milkrateentrytype_name: value.milkrateentrytype_name,
          slab_min: value.slab_min,
          slab_max: value.slab_max,
          amount: value.amount,
        };
        // if Base Rate, only store the amount
        if (value.milkrateentrytype_id == "C012001") {
          BaseFAT = value.basefat;
          BaseSNF = value.basesnf;

          BaseRateAmount = value.amount;
        } else {
          MilkRateDetails.push(MilkRate);
        }
        //// console.log(MilkRateDetails);
      });

      function findMinMaxValues(milkrateentrytype_id, prop) {
        var values = MilkRateDetails.filter(
          (entry) => entry.milkrateentrytype_id === milkrateentrytype_id
        ).map((entry) => parseFloat(entry[prop]));

        return {
          min: Math.min(...values),
          max: Math.max(...values),
        };
      }

      // Example usage
      var C012002_slab_min_values = findMinMaxValues("C012002", "slab_min");
      var C012003_slab_min_values = findMinMaxValues("C012003", "slab_min");
      var C012004_slab_max_values = findMinMaxValues("C012004", "slab_max");
      var C012005_slab_max_values = findMinMaxValues("C012005", "slab_max");

      //  SNF_Heading = [];

      // SNF_Heading.push("Fat/SNF" )

      // for (let i = C012002_slab_min_values.min; i < C012004_slab_max_values.max.length; i=i+0.1) {
      //   // console.log(i);
      //   SNF_Heading.push( i.toString());
      // }
      // // console.log(SNF_Heading);
      // Fat_Heading = [];

      // for (let i =  C012003_slab_min_values.min; i < C012005_slab_max_values.max.length; i=i+0.1) {

      //   Fat_Heading.push( i.toString());
      // }
      // // console.log(Fat_Heading);

      SNF_Heading = [];
      SNF_Heading.push("Fat/SNF");

      for (
        let i = C012003_slab_min_values.min;
        i <= C012005_slab_max_values.max;
        i += 0.1
      ) {
        SNF_Heading.push(i.toFixed(2)); // Use toFixed to limit decimal places to 2
      }
      // // console.log(SNF_Heading);

      Fat_Heading = [];

      for (
        let i = C012002_slab_min_values.min;
        i <= C012004_slab_max_values.max;
        i += 0.1
      ) {
        Fat_Heading.push(i.toFixed(2)); // Use toFixed to limit decimal places to 2
      }
      // // console.log(Fat_Heading);
      /*
            
            MilkRateDetails = [];
            var MilkRate = {
                milkrateentrytype_id: "C012002",
                milkrateentrytype_name: "Fat Deduction",
                slab_min: 2.1,
                slab_max: 7.6,
                amount: 0.20
            };
            MilkRateDetails.push(MilkRate);
            BaseRateAmount = 33;

            */
      //// console.log(MilkRateDetails);
      ClearDataTable("tableViewMilkRateList");
      $("#tableViewMilkRateListData").html(TableHTML);
      //SetDataTable("tableViewMilkRateList", [4], "Milk Rate");
      var TempArray = [];
      RateChartMatrix.push(SNF_Heading);
      for (var row = 0; row < Fat_Heading.length; row++) {
        TempArray.push(Fat_Heading[row]);
        for (var col = 1; col < SNF_Heading.length; col++) {
          var finalAmount = CalculateMilkRate(
            Fat_Heading[row],
            SNF_Heading[col],
            BaseFAT,
            BaseSNF
          );
          TempArray.push(finalAmount);
        }
        //// console.log(TempArray);
        RateChartMatrix.push(TempArray);
        TempArray = [];
      }
      //// console.log(RateChartMatrix);
      GetRateChartMatrix();
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description
      );
    },
  });
  // $("#btn_View").prop("disabled", false);
  return;
}

function CalculateMilkRate(fat, snf, BFAT, BSNF) {
  // calculate amount based on fat and snf provided
  // for both snf and fat

  snf *= 1.0;
  fat *= 1.0;
  var SNFAmount = 0.0;
  var PrevSNFAmount = 0.0;
  var PrevFatAmount = 0.0;
  var FatAmount = 0.0;
  var FinalAmount = 0.0;
  var BaseFat = parseFloat(BFAT);
  var BaseSNF = parseFloat(BSNF);

  //SNF
  if (snf < BaseSNF) {
    // deduction
    for (var p = 0; p < MilkRateDetails.length; p++) {
      if (MilkRateDetails[p].milkrateentrytype_id == "C012003") {
        if (
          parseFloat(MilkRateDetails[p].slab_min) <= snf &&
          parseFloat(MilkRateDetails[p].slab_max) >= snf
        ) {
          PrevSNFAmount = 0;
          for (let r = 0; r < MilkRateDetails.length; r++) {
            if (
              parseFloat(MilkRateDetails[r].slab_min) > snf &&
              MilkRateDetails[r].milkrateentrytype_id == "C012003"
            ) {
              // check difference from the lower value
              if (parseFloat(MilkRateDetails[r].slab_max) == 8.5) {
                SNFAmount =
                  (parseFloat(MilkRateDetails[r].slab_max) -
                    parseFloat(MilkRateDetails[r].slab_min)) *
                  10;
              } else {
                SNFAmount =
                  (parseFloat(MilkRateDetails[r].slab_max) -
                    parseFloat(MilkRateDetails[r].slab_min)) *
                    10 +
                  1;
              }

              //SNFAmount = (parseFloat(MilkRateDetails[r].slab_max) - parseFloat(MilkRateDetails[r].slab_min)) * 10;

              SNFAmount = SNFAmount.toFixed(0);

              SNFAmount *= parseFloat(MilkRateDetails[r].amount);

              PrevSNFAmount = SNFAmount + PrevSNFAmount;
            }
          }

          // check difference from the lower value
          if (parseFloat(MilkRateDetails[p].slab_max) == 8.5) {
            SNFAmount = (parseFloat(MilkRateDetails[p].slab_max) - snf) * 10;
          } else {
            SNFAmount =
              (parseFloat(MilkRateDetails[p].slab_max) - snf) * 10 + 1;
          }

          SNFAmount = SNFAmount.toFixed(0);
          // multiply by it's amount
          SNFAmount *= parseFloat(MilkRateDetails[p].amount);

          // multiply by 10
          // SNFAmount *= 10.0;
          SNFAmount = SNFAmount + PrevSNFAmount;
          // if deduction, make negative
          SNFAmount *= -1.0;

          break;
        }
      }
    }
  } else {
    //high
    for (var p = 0; p < MilkRateDetails.length; p++) {
      if (MilkRateDetails[p].milkrateentrytype_id == "C012005") {
        if (
          parseFloat(MilkRateDetails[p].slab_min) <= snf &&
          parseFloat(MilkRateDetails[p].slab_max) >= snf
        ) {
          PrevSNFAmount = 0;
          for (let r = 0; r < MilkRateDetails.length; r++) {
            if (
              parseFloat(MilkRateDetails[r].slab_max) < snf &&
              MilkRateDetails[r].milkrateentrytype_id == "C012005"
            ) {
              SNFAmount =
                (parseFloat(MilkRateDetails[r].slab_max) -
                  parseFloat(MilkRateDetails[r].slab_min)) *
                  10 +
                1;

              SNFAmount = SNFAmount.toFixed(0);

              SNFAmount *= parseFloat(MilkRateDetails[r].amount);

              PrevSNFAmount = SNFAmount + PrevSNFAmount;
            }
          }

          if (parseFloat(MilkRateDetails[p].slab_min) == 8.5) {
            SNFAmount = (snf - parseFloat(MilkRateDetails[p].slab_min)) * 10;
          } else {
            SNFAmount =
              (snf - parseFloat(MilkRateDetails[p].slab_min)) * 10 + 1;
          }

          SNFAmount = SNFAmount.toFixed(0);

          // check difference from the lower value
          // SNFAmount = snf - parseFloat(BaseSNF);

          // multiply by it's amount
          SNFAmount *= parseFloat(MilkRateDetails[p].amount);

          SNFAmount = SNFAmount + PrevSNFAmount;
          // multiply by 10
          // SNFAmount *= 10.0;

          break;
        }
      }
    }
  }

  //Fat
  if (fat < BaseFat) {
    // deduction
    for (var p = 0; p < MilkRateDetails.length; p++) {
      if (MilkRateDetails[p].milkrateentrytype_id == "C012002") {
        if (
          parseFloat(MilkRateDetails[p].slab_min) <= fat &&
          parseFloat(MilkRateDetails[p].slab_max) >= fat
        ) {
          PrevFatAmount = 0;
          for (let r = 0; r < MilkRateDetails.length; r++) {
            if (
              parseFloat(MilkRateDetails[r].slab_min) > fat &&
              MilkRateDetails[r].milkrateentrytype_id == "C012002"
            ) {
              FatAmount =
                (parseFloat(MilkRateDetails[r].slab_max) -
                  parseFloat(MilkRateDetails[r].slab_min)) *
                10;

              FatAmount = FatAmount.toFixed(0);

              FatAmount *= parseFloat(MilkRateDetails[r].amount);

              PrevFatAmount = FatAmount + PrevFatAmount;
            }
          }

          if (parseFloat(MilkRateDetails[p].slab_max) == 3.5) {
            FatAmount = (parseFloat(MilkRateDetails[p].slab_max) - fat) * 10;
          } else {
            FatAmount =
              (parseFloat(MilkRateDetails[p].slab_max) - fat) * 10 + 1;
          }

          FatAmount = FatAmount.toFixed(0);
          // multiply by it's amount
          FatAmount *= parseFloat(MilkRateDetails[p].amount);

          // multiply by 10
          // SNFAmount *= 10.0;
          FatAmount = FatAmount + PrevFatAmount;
          // if deduction, make negative
          FatAmount *= -1.0;

          // FatAmount = FatAmount.toFixed(0) ;

          // // check difference from the lower value
          // // FatAmount = parseFloat(BaseFat) - fat;

          // // multiply by it's amount
          // FatAmount *= parseFloat(MilkRateDetails[p].amount);

          // FatAmount = FatAmount - PrevFatAmount;
          // multiply by 10
          // FatAmount *= 10.0;

          // // if deduction, make negative
          // FatAmount *= -1.0;

          break;
        }
      }
    }
  } else {
    //high
    for (var p = 0; p < MilkRateDetails.length; p++) {
      if (MilkRateDetails[p].milkrateentrytype_id == "C012004") {
        if (
          parseFloat(MilkRateDetails[p].slab_min) <= fat &&
          parseFloat(MilkRateDetails[p].slab_max) >= fat
        ) {
          PrevFatAmount = 0;
          for (let r = 0; r < MilkRateDetails.length; r++) {
            if (
              parseFloat(MilkRateDetails[r].slab_max) < fat &&
              MilkRateDetails[r].milkrateentrytype_id == "C012004"
            ) {
              FatAmount =
                (parseFloat(MilkRateDetails[r].slab_max) -
                  parseFloat(MilkRateDetails[r].slab_min)) *
                  10 +
                1;

              FatAmount = FatAmount.toFixed(0);

              FatAmount *= parseFloat(MilkRateDetails[r].amount);

              PrevFatAmount = FatAmount + PrevFatAmount;
              //// console.log(PrevFatAmount, fat);
            }
          }

          //--
          // check difference from the lower value
          if (parseFloat(MilkRateDetails[p].slab_min) == 3.5) {
            FatAmount = (fat - parseFloat(MilkRateDetails[p].slab_min)) * 10;
          } else {
            FatAmount =
              (fat - parseFloat(MilkRateDetails[p].slab_min)) * 10 + 1;
          }

          FatAmount = FatAmount.toFixed(0);

          // multiply by it's amount
          FatAmount *= parseFloat(MilkRateDetails[p].amount);

          // multiply by 10
          // SNFAmount *= 10.0;
          FatAmount = FatAmount + PrevFatAmount;

          // if deduction, make negative
          // FatAmount *= -1.0;

          // // ---

          // // check difference from the lower value
          // FatAmount = fat - parseFloat(BaseFat);

          // // multiply by it's amount
          // FatAmount *= parseFloat(MilkRateDetails[p].amount);

          // // multiply by 10
          // FatAmount *= 10.0;

          break;
        }
      }
    }
  }

  // calculate final amount & return
  FinalAmount = (parseFloat(BaseRateAmount) + SNFAmount + FatAmount) * 1.0;

  return FinalAmount;

  //SNF
  /*
    for (var p = 0; p < MilkRateDetails.length; p++) {
        // check in which range it matches
        if (MilkRateDetails[p].milkrateentrytype_id == "C012003" || MilkRateDetails[p].milkrateentrytype_id == "C012005") {
            if (parseFloat(MilkRateDetails[p].slab_min) <= snf && parseFloat(MilkRateDetails[p].slab_max) > snf) {
                // check difference from the lower value
                SNFAmount = snf - parseFloat(MilkRateDetails[p].slab_min);

                // multiply by it's amount
                SNFAmount *= parseFloat(MilkRateDetails[p].amount);

                // multiply by 10
                SNFAmount *= 10.00;

                // if deduction, make negative
                if (MilkRateDetails[p].milkrateentrytype_id == "C012003") {
                    SNFAmount *= -1.0;
                }
                break;
            }
        }
    }
    */

  //Fat
  /*
    for (var p = 0; p < MilkRateDetails.length; p++) {
        // check in which range it matches
        if (MilkRateDetails[p].milkrateentrytype_id == "C012002" || MilkRateDetails[p].milkrateentrytype_id == "C012004") {
            if (parseFloat(MilkRateDetails[p].slab_min) <= fat && parseFloat(MilkRateDetails[p].slab_max) > fat) {
                // check difference from the lower value
                FatAmount = fat - parseFloat(MilkRateDetails[p].slab_min);

                // multiply by it's amount
                FatAmount *= parseFloat(MilkRateDetails[p].amount);

                // multiply by 10
                FatAmount *= 10.00;

                // if deduction, make negative
                if (MilkRateDetails[p].milkrateentrytype_id == "C012002") {
                    FatAmount *= -1.00;
                }
                break;
            }
        }
    }
    */
}

function GetRateChartMatrix() {
  // create table based on the 2-dimensional array
  /**
   *
   *      SNF_Heading = ["SNF/Fat", 7.0,7.1,7.2...]
   *      Fat_Heading = [3.0,3.1,3.2,...]
   *      RateChartMatrix[
   *          [calculated_amt1, cal_amt_2,...]
   *          [calculated_amt1, cal_amt_2,...]
   *      ]
   *
   */
  var TableHTML = "";
  for (var i = 0; i < RateChartMatrix.length; i++) {
    if (i == 0) {
      TableHTML += "<thead>";
    }
    if (i == 1) {
      TableHTML += "<tbody>";
    }
    TableHTML += "<tr>";
    for (var j = 0; j < RateChartMatrix[i].length; j++) {
      /*
            if (i == 0 && j == 0) {
                TableHTML += "<th>" + "Fat/SNF" + "</th>";
            }
            else if (i == 0) {
                TableHTML += "<th>" + SNF_Heading[j].toFixed(2) + "</th>";                
            }
            else if (j == 0) {
                TableHTML += "<th>" + Fat_Heading[i].toFixed(2) + "</th>";
            }
            else {
                TableHTML += "<td>" + parseFloat(RateChartMatrix[i][j]).toFixed(2) + "</td>";
            }*/
      if (i == 0 || j == 0) {
        if (i == 0 && j == 0) {
          TableHTML += "<th>" + RateChartMatrix[i][j] + "</th>";
        } else {
          TableHTML +=
            "<th>" + parseFloat(RateChartMatrix[i][j]).toFixed(1) + "</th>";
        }
      } else {
        TableHTML +=
          "<td>" + parseFloat(RateChartMatrix[i][j]).toFixed(1) + "</td>";
      }
    }
    TableHTML += "</tr>";
    if (i == 0) {
      TableHTML += "</thead>";
    }
    if (i == RateChartMatrix.length - 1) {
      TableHTML += "</tbody>";
    }
  }
  // assign the table
  ClearDataTable("tableViewMilkRateMatrix");
  $("#tableViewMilkRateMatrix").html(TableHTML);
  // $("#tableViewMilkRateMatrix tbody").prop("overflow", "scroll");
  return;
}

function GetMilkRateMCCView() {
  ClearDataTable("tableMCCViewMilkRateList");
  $("#divTabsMCCView").show();

  var ViewType_Id = $("#ddlViewType").val();
  var ViewDate = $("#txtMCCViewDate").val();

  var IsValid = 1;
  if (ViewType_Id == "") {
    IsValid = 0;
    $("#ddlViewType").addClass("is-invalid state-invalid");
  }
  if (ViewDate == "") {
    IsValid = 0;
    $("#txtMCCViewDate").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't proceed.");
    return;
  }

  var APIEndPoint = "GetMilkRate";
  var Method_Name = "Get_ChartMCC";
  var url = "/Rate/MilkRate";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: ViewType_Id,
    rate_date: ViewDate,
  };
  //// console.log(reqdata);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      //// console.log(res);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      var TableHTML = "";
      var Row_No = 0;

      var newDataArray = [];

      console.log(res);

      res.forEach(function (item) {
        var existingEntry = newDataArray.find(function (data) {
          return (
            data.mcc_id === item.mcc_id && data.milktype_id === item.milktype_id
          );
        });

        if (existingEntry) {
          if (item.collectionshift_id === "C015001") {
            existingEntry.morning_chart_id = item.chart_id;
            existingEntry.morning_chart_name = item.chart_name;
            existingEntry.morning_collectionshift_id = item.collectionshift_id;
            existingEntry.morning_collectionshift_name =
              item.collectionshift_name;
          } else if (item.collectionshift_id === "C015002") {
            existingEntry.evening_chart_id = item.chart_id;
            existingEntry.evening_chart_name = item.chart_name;
            existingEntry.evening_collectionshift_id = item.collectionshift_id;
            existingEntry.evening_collectionshift_name =
              item.collectionshift_name;
          } else if (item.collectionshift_id === "C015003") {
            existingEntry.all_day_chart_id = item.chart_id;
            existingEntry.all_day_chart_name = item.chart_name;
            existingEntry.all_day_collectionshift_id = item.collectionshift_id;
            existingEntry.all_day_collectionshift_name =
              item.collectionshift_name;
          }
        } else {
          newDataArray.push({
            mcc_name: item.mcc_name,
            mcc_id: item.mcc_id,
            milktype_name: item.milktype_name,
            milktype_id: item.milktype_id,
            morning_collectionshift_id:
              item.collectionshift_id === "C015001"
                ? item.collectionshift_id
                : "",
            morning_collectionshift_name:
              item.collectionshift_id === "C015001"
                ? item.collectionshift_name
                : "",
            morning_chart_id:
              item.collectionshift_id === "C015001" ? item.chart_id : "",
            morning_chart_name:
              item.collectionshift_id === "C015001" ? item.chart_name : "",

            evening_collectionshift_id:
              item.collectionshift_id === "C015002"
                ? item.collectionshift_id
                : "",
            evening_collectionshift_name:
              item.collectionshift_id === "C015002"
                ? item.collectionshift_name
                : "",
            evening_chart_id:
              item.collectionshift_id === "C015002" ? item.chart_id : "",
            evening_chart_name:
              item.collectionshift_id === "C015002" ? item.chart_name : "",

            all_day_collectionshift_id:
              item.collectionshift_id === "C015003"
                ? item.collectionshift_id
                : "",
            all_day_collectionshift_name:
              item.collectionshift_id === "C015003"
                ? item.collectionshift_name
                : "",
            all_day_chart_id:
              item.collectionshift_id === "C015003" ? item.chart_id : "",
            all_day_chart_name:
              item.collectionshift_id === "C015003" ? item.chart_name : "",
          });
        }
      });
      console.log(newDataArray);
      //// console.log(newDataArray);

      $.each(newDataArray, function (data, value) {
        Row_No = Row_No + 1;

        TableHTML += "<tr >";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td >" + value.milktype_name + "</td>";
        // TableHTML += "<td >" + value.morning_chart_name + "</td>";

        if (
          value.morning_chart_name != undefined &&
          value.morning_chart_name != "" &&
          value.morning_chart_name != null
        ) {
          TableHTML += "<td>";
          TableHTML +=
            '<a href="javascript:void(0)" id="btn' +
            value.morning_chart_id +
            '" class="btn btn-icon py-0" onclick=\'ShowMilkRateView("MCC","Chart","' +
            value.morning_chart_id +
            '", "' +
            value.morning_chart_name +
            '", "' +
            value.milktype_id +
            '", "' +
            value.milktype_name +
            '", "' +
            value.morning_collectionshift_id +
            '", "' +
            value.morning_collectionshift_name +
            '", "' +
            ViewDate +
            '");\'style="text-align: left;">' +
            value.morning_chart_name +
            '<i class="fa fa-eye ml-2"></i></a>';
          TableHTML += "</td>";
        } else {
          TableHTML += "<td></td>";
        }

        // TableHTML += "<td >" + value.evening_chart_name + "</td>";

        if (
          value.evening_chart_name != undefined &&
          value.evening_chart_name != "" &&
          value.evening_chart_name != null
        ) {
          TableHTML += "<td>";
          TableHTML +=
            '<a href="javascript:void(0)" id="btn' +
            value.evening_chart_id +
            '" class="btn btn-icon py-0" onclick=\'ShowMilkRateView("MCC","Chart","' +
            value.evening_chart_id +
            '", "' +
            value.evening_chart_name +
            '", "' +
            value.milktype_id +
            '", "' +
            value.milktype_name +
            '", "' +
            value.evening_collectionshift_id +
            '", "' +
            value.evening_collectionshift_name +
            '", "' +
            ViewDate +
            '");\'style="text-align: left;">' +
            value.evening_chart_name +
            '<i class="fa fa-eye ml-2""></i></a>';
          TableHTML += "</td>";
        } else {
          TableHTML += "<td></td>";
        }

        if (
          value.all_day_chart_name != undefined &&
          value.all_day_chart_name != "" &&
          value.all_day_chart_name != null
        ) {
          TableHTML += "<td>";
          TableHTML +=
            '<a href="javascript:void(0)" id="btn' +
            value.all_day_chart_id +
            '" class="btn btn-icon py-0" onclick=\'ShowMilkRateView("MCC","Chart","' +
            value.all_day_chart_id +
            '", "' +
            value.all_day_chart_name +
            '", "' +
            value.milktype_id +
            '", "' +
            value.milktype_name +
            '", "' +
            value.all_day_collectionshift_id +
            '", "' +
            value.all_day_collectionshift_name +
            '", "' +
            ViewDate +
            '");\'style="text-align: left;">' +
            value.all_day_chart_name +
            '<i class="fa fa-eye ml-2""></i></a>';
          TableHTML += "</td>";
        } else {
          TableHTML += "<td></td>";
        }

        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableMCCViewMilkRateListData").html(TableHTML);

      SetDataTable("tableMCCViewMilkRateList", [6], "MCCViewMilkRate");
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description
      );
    },
  });
}

function ShowEditEntry(Chart_Id, is_mcc) {
  ShowContentDiv("Rate", "MilkEdit", "", function () {
    // Initialization Code
    $("#ddlEntryMilkType").select2();
    $("#ddlEntryMilkStatus").select2();
    $("#ddlEntryMilkCollectionShift").select2();
    $("#ddlEntryBaseUnit").select2();

    $("#ddlEntryDeductionSNFSlab").select2();
    $("#ddlEntryDeductionFatSlab").select2();
    $("#ddlEntryIncentivesSNFSlab").select2();
    $("#ddlEntryIncentivesFatSlab").select2();

    $("#lblEntryId").html(Chart_Id);
    $("#lblAction").html("Edit");
    $("#divFooterDelete").show();

    $("#selectAll").change(function () {
      $(".select-item").prop("checked", $(this).prop("checked"));
    });

    $(document).on("change", ".select-item", function () {
      //// console.log(2);
      if (!$(this).prop("checked")) {
        $("#selectAll").prop("checked", false);
      }

      // Check if all .select-item checkboxes are checked
      var allChecked =
        $(".select-item:checked").length === $(".select-item").length;

      // If all checkboxes are checked, set #selectAll to be checked
      $("#selectAll").prop("checked", allChecked);
    });

    var APIEndPoint = "GetMilkRate";
    var Method_Name = "Get_One";
    var url = "/Rate/MilkRate";
    var reqdata = {
      method_name: Method_Name,
      chart_id: Chart_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        // Fill data in input fields
        $("#ddlEntryMilkType").prop("disabled", "true");
        if (res[0].is_lived == 1) {
          $("#chkEntryLiveStatus").prop({ checked: true, disabled: true });
          $("#ddlEntryMilkStatus").prop("disabled", "true");
          $("#ddlEntryBaseUnit").prop("disabled", "true");
          $("#ddlEntryMilkCollectionShift").prop("disabled", "true");
          $("#divFooterDelete").hide();
        } else {
          $("#chkEntryLiveStatus").prop({ checked: false, disabled: false });
        }
        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }
        $("#txtEntryRateChartName").val(res[0].chart_name);
        GetMaster(
          "ddlEntryMilkType",
          "Select Milk Type",
          "GetMilkType",
          res[0].milktype_id,
          ""
        );

        GetMaster(
          "ddlEntryMilkStatus",
          "Select Milk Status",
          "GetMilkStatus",
          res[0].milkstatus_id,
          ""
        );
        GetMaster(
          "ddlEntryMilkCollectionShift",
          "Select Shift",
          "GetMilkCollectionShiftAll",
          res[0].collectionshift_id,
          ""
        );
        GetMaster(
          "ddlEntryBaseUnit",
          "Select Base Unit",
          "GetUOM",
          res[0].uom_id,
          ""
        );

        if (is_mcc) {
          // assign mcc
          $("#divassignmcctables").show();
          $("#divTabs").hide();
          GetMCCEntryList();
        } else {
          // show edit tabs
          $("#divTabs").show();
          $("#divassignmcctables").hide();
          GetBaseRateTable();
        }
      },
      error: function (result) {
        Show_Error_Toastr(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  });
}

function ShowMCCEntry(Chart_Id) {
  ShowContentDiv("Rate", "MilkMCCEntry", "", function () {
    // Initialization Code
    $("#ddlEntryMilkTypeMCC").select2();
    $("#ddlEntryMilkStatusMCC").select2();
    $("#ddlEntryMilkCollectionShiftMCC").select2();
    $("#ddlEntryBaseUnitMCC").select2();
    $("#lblEntryIdMCC").html(Chart_Id);
    $("#lblActionMCC").html("");
    GetMaster("ddlEntryMilkTypeMCC", "Select Milk Type", "GetMilkType", "", "");
    GetMaster(
      "ddlEntryMilkStatusMCC",
      "Select Milk Status",
      "GetMilkStatus",
      "",
      ""
    );
    GetMaster(
      "ddlEntryMilkCollectionShiftMCC",
      "Select Shift",
      "GetMilkCollectionShiftAll",
      "",
      ""
    );
    GetMaster("ddlEntryBaseUnitMCC", "Select Base Unit", "GetUOM", "", "");

    // $("#selectAll").change(function () {
    //   $(".select-item").prop("checked", $(this).prop("checked"));
    //   // console.log(1);
    // });

    // // Individual checkbox change event
    // $(".select-item").change(function () {
    //   // console.log(2);
    //   if (!$(this).prop("checked")) {
    //     $("#selectAll").prop("checked", false);
    //   }
    // });
    //SetDataTable("tableBaseRateList", [6], "Milk");

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
  });
}

function CloseEntry() {
  var Action_Name = $("#lblActionSet").html();
  if (
    Action_Name == "Home" ||
    Action_Name == "" ||
    Action_Name == undefined ||
    Action_Name == null
  ) {
    GetSearchList();
    HideContentDiv();
  }
  if (Action_Name == "MCC") {
    ShowContentDiv("Rate", "MilkRateMCCView", "", function () {
      $("#ddlViewType").select2();
      GetMaster("ddlViewType", "Select Type", "GetMCCType", "", "");
    });
    HideContentDiv();
  }
  successfulCallbacks = 0;
}

// function CloseViewEntry() {
//   ShowMilkRateMCCView();
//   HideContentDiv();
// }

function SaveEntry() {
  // Validation code
  var Chart_Name = $("#txtEntryRateChartName").val().trim();
  var MilkType_Id = $("#ddlEntryMilkType").val();
  var MilkStatus_Id = $("#ddlEntryMilkStatus").val();
  var BaseUnit_Id = $("#ddlEntryBaseUnit").val();
  var CollectionShift_Id = $("#ddlEntryMilkCollectionShift").val();

  var IsValid = 1;

  if (
    Chart_Name == "" ||
    Chart_Name == null ||
    Chart_Name == undefined ||
    Is_Valid_Name_With_Number(Chart_Name) == false
  ) {
    IsValid = 0;
    $("#txtEntryRateChartName").addClass("is-invalid state-invalid");
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
  if (BaseUnit_Id == "" || BaseUnit_Id == null || BaseUnit_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryBaseUnit").addClass("is-invalid state-invalid");
  }
  if (
    CollectionShift_Id == "" ||
    CollectionShift_Id == null ||
    CollectionShift_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryMilkCollectionShift").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Create";
    Chart_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Chart_Id = $("#lblEntryId").html();
    }
    var Is_Lived = 0;
    if ($("#chkEntryLiveStatus").prop("checked")) {
      Is_Lived = 1;
    }

    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var APIEndPoint = "SaveMilkRate";
    var url = "/Rate/MilkRate";
    var reqdata = {
      is_lived: Is_Lived,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      chart_id: Chart_Id,
      chart_name: Chart_Name,
      milktype_id: MilkType_Id,
      milkstatus_id: MilkStatus_Id,
      uom_id: BaseUnit_Id,
      collectionshift_id: CollectionShift_Id,
      api_end_point: APIEndPoint,
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
          Hide_Loader();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          ShowEntrySuccess("Milk Rate details saved successfully");
          $("#ddlEntryMilkType").prop("disabled", "true");
          if (Is_Lived == 1) {
            $("#chkEntryLiveStatus").prop({ checked: true, disabled: true });
            $("#ddlEntryMilkStatus").prop("disabled", "true");
            $("#ddlEntryBaseUnit").prop("disabled", "true");
            $("#ddlEntryMilkCollectionShift").prop("disabled", "true");
            $("#divFooterDelete").show();
          }
          $("#divTabs").show();
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : Milk Rate details not saved");
      },
    });
    $("#btn_Save").prop("disabled", false);
  }
  return;
}

function ShowDeleteEntry(Chart_Id) {
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
      if (result) {
        SaveDeleteEntry(Chart_Id);
      }
    }
  );
}

function SaveDeleteEntry(Chart_Id) {
  // Write code to delete
  if (Chart_Id == "") {
    Chart_Id = $("#lblEntryId").html();
  }
  var APIEndPoint = "SaveMilkRate";
  var url = "/Rate/MilkRate";
  var reqdata = {
    method_name: "Delete",
    chart_id: Chart_Id,
    api_end_point: APIEndPoint,
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
        Show_Success_Toastr("Milk details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Milk details not deleted");
    },
  });
}

function OpenModalBaseRate(action, version_no, entry_id) {
  $("#modelEntryBaseRate")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#AddEditBaseRate").text(action + " Base Rate");

  $("#lblEntryBaseRateVersionNo").html(version_no);
  $("#lblEntryBaseRateId").html(entry_id);
  $("#lblActionBaseRate").html(action);

  $("#txtEntryBaseRateRate").val("");
  $("#txtEntryBaseRateFromDate").val("");
  GetBaseRateFatSNF();
  $("#txtEntryBaseRateBaseFat").prop("disabled", true);
  $("#txtEntryBaseRateBaseSNF").prop("disabled", true);
  Chart_Id = $("#lblEntryId").html();

  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/MilkRateItem";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetMilkRateItem";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012001",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var date;
      if (res.length === 0) {
        date = new Date(Date.now());
      } else {
        var latest_date = new Date(res[0].applicable_date);
        date = new Date(Date.now()); //.toISOString().slice(0, 16);
        if (latest_date > date) {
          date = latest_date;
        }
      }

      /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

      var offset = date.getTimezoneOffset();
      date.setMinutes(date.getMinutes() - offset);
      var newdate = date.toISOString().slice(0, 16);

      $("#txtEntryBaseRateFromDate").attr("min", newdate);
      $("#txtEntryBaseRateFromDate").val(newdate);

      $("#txtEntryBaseRateFromDate").prop("disabled", false);
    },
    error: function () {},
  });

  // Setting Values for Edit
  if (action == "Edit") {
    var Method_Name = "Get_One";
    var APIEndPoint = "GetMilkRateItem";
    var url = "/Rate/MilkRateItem";
    var Entry_Id = entry_id;
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      chart_id: Chart_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res != "") {
          $("#txtEntryBaseRateRate").val(res[0].amount);
          $("#txtEntryBaseRateFromDate").val(res[0].applicable_date);
          $("#txtEntryBaseRateFromDate").prop("disabled", true);
          GetBaseRateFatSNF();
        }
      },
      error: function () {
        ShowItemError(
          "Error in fetching details from server.",
          res[0].result_description
        );
      },
    });
  }
}
function OpenModalBackDate(
  action,
  version_no,
  entry_id,
  back_date,
  is_accessdate
) {
  $("#modelEntryBackDate")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#btn_Save_Back_Date").prop("disabled", false);
  $("#AddEditBackDate").text(action + "");

  $("#lblEntryVersionNoBackDate").html(version_no);
  $("#lblEntryIdBackDate").html(entry_id);
  $("#lblActionBackDate").html(action);
  $("#lblEntryIdBackDateMin").html(back_date);
  $("#lblEntryIsAccessDate").html(is_accessdate);
  $("#txtEntryFromDateBackDate").val("");

  Chart_Id = $("#lblEntryId").html();

  var Method_Name = "Get_One";
  var APIEndPoint = "GetMilkRateItem";
  var url = "/Rate/MilkRateItem";
  var Entry_Id = entry_id;
  var reqdata = {
    method_name: Method_Name,
    entry_id: Entry_Id,
    chart_id: Chart_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      if (is_accessdate == "1") {
        $("#txtEntryFromDateBackDate").attr("min", "");
        $("#txtEntryFromDateBackDate").val(back_date);
      } else {
        if (res.length === 0) {
          $("#txtEntryFromDateBackDate").attr("min", back_date);
          // $("#txtEntryFromDateBackDate").attr("max", back_date);
          $("#txtEntryFromDateBackDate").val(back_date);
        } else {
          $("#txtEntryFromDateBackDate").attr("min", back_date);
          // $("#txtEntryFromDateBackDate").attr("max", res[0].applicable_date);
          $("#txtEntryFromDateBackDate").val(res[0].applicable_date);
        }
      }
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

$("#modelEntryBaseRate").on("hidden.bs.modal", function (e) {
  $("#lblActionBaseRate").html("");
  $("#AddEditBaseRate").text("");
});

function GetBaseRateFatSNF() {
  var Method_Name = "Get_BaseRate";
  var APIEndPoint = "GetMilkRate";
  var url = "/Rate/MilkRate";
  var MilkType_Id = $("#ddlEntryMilkType").val();
  var reqdata = {
    method_name: Method_Name,
    milktype_id: MilkType_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res != "") {
        $("#txtEntryBaseRateBaseFat").val(res[0].basefat);
        $("#txtEntryBaseRateBaseSNF").val(res[0].basesnf);
      }
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function OpenModalSNFDeduction(action, version_no, entry_id) {
  $("#modelEntrySNFDeduction")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#AddEditSNFDeduction").text(action + " SNF Deduction");

  $("#lblEntrySNFDeductionVersionNo").html(version_no);
  $("#lblEntrySNFDeductionId").html(entry_id);
  $("#lblActionSNFDeduction").html(action);

  $("#txtEntrySNFDeductionDeductionPerPoint").val("");
  $("#txtEntrySNFDeductionFromDate").val("");
  $("#ddlEntryDeductionSNFSlab").val("");

  MilkType_Id = $("#ddlEntryMilkType").val();

  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/MilkRateItem";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetMilkRateItem";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012003",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var date;
      if (res.length === 0) {
        date = new Date(Date.now());
      } else {
        var latest_date = new Date(res[0].applicable_date);
        date = new Date(Date.now()); //.toISOString().slice(0, 16);
        if (latest_date > date) {
          date = latest_date;
        }
      }

      /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

      var offset = date.getTimezoneOffset();
      date.setMinutes(date.getMinutes() - offset);
      var newdate = date.toISOString().slice(0, 16);

      $("#txtEntrySNFDeductionFromDate").attr("min", newdate);
      $("#txtEntrySNFDeductionFromDate").val(newdate);
    },
    error: function () {},
  });

  if (action == "Add") {
    GetMaster(
      "ddlEntryDeductionSNFSlab",
      "Select SNF Slab",
      "Get_SNFDeduction",
      "",
      MilkType_Id
    );
  } else {
    var Method_Name = "Get_One";
    var APIEndPoint = "GetMilkRateItem";
    var url = "/Rate/MilkRateItem";
    var Entry_Id = entry_id;
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      api_end_point: APIEndPoint,
      chart_id: Chart_Id,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        $("#txtEntrySNFDeductionDeductionPerPoint").val(res[0].amount);
        $("#txtEntrySNFDeductionFromDate").val(res[0].applicable_date);
        GetMaster(
          "ddlEntryDeductionSNFSlab",
          "Select SNF Slab",
          "Get_SNFDeduction",
          res[0].slab_id,
          MilkType_Id
        );
      },
      error: function () {
        ShowItemError(
          "Error in fetching details from server.",
          res[0].result_description
        );
      },
    });
  }
  if (action == "View") {
    $("#txtEntrySNFDeductionDeductionPerPoint").prop("disabled", true);
    $("#txtEntrySNFDeductionFromDate").prop("disabled", true);
    $("#ddlEntryDeductionSNFSlab").prop("disabled", true);
  }
}
$("#modelEntrySNFDeduction").on("hidden.bs.modal", function (e) {
  $("#lblActionSNFDeduction").html("");
  $("#AddEditSNFDeduction").text("");
});

function OpenModalFatDeduction(action, version_no, entry_id) {
  $("#modelEntryFatDeduction")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#AddEditFatDeduction").text(action + " Fat Deduction");

  $("#lblEntryFatDeductionVersionNo").html(version_no);
  $("#lblEntryFatDeductionId").html(entry_id);
  $("#lblActionFatDeduction").html(action);

  $("#txtEntryFatDeductionDeductionPerPoint").val("");
  $("#txtEntryFatDeductionFromDate").val("");
  $("#ddlEntryDeductionFatSlab").val("");

  MilkType_Id = $("#ddlEntryMilkType").val();

  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/MilkRateItem";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetMilkRateItem";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012002",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var date;
      if (res.length === 0) {
        date = new Date(Date.now());
      } else {
        var latest_date = new Date(res[0].applicable_date);
        date = new Date(Date.now()); //.toISOString().slice(0, 16);
        if (latest_date > date) {
          date = latest_date;
        }
      }

      /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

      var offset = date.getTimezoneOffset();
      date.setMinutes(date.getMinutes() - offset);
      var newdate = date.toISOString().slice(0, 16);

      $("#txtEntryFatDeductionFromDate").attr("min", newdate);
      $("#txtEntryFatDeductionFromDate").val(newdate);
    },
    error: function () {},
  });

  /*
    $("#txtEntryFatDeductionDeductionPerPoint").prop("disabled", false);
    $("#txtEntryFatDeductionFromDate").prop("disabled", false);
    $("#ddlEntryDeductionFatSlab").prop("disabled", false);
    */

  if (action == "Add") {
    GetMaster(
      "ddlEntryDeductionFatSlab",
      "Select Fat Slab",
      "Get_FatDeduction",
      "",
      MilkType_Id
    );
  }
  //edit
  else {
    var Method_Name = "Get_One";
    var APIEndPoint = "GetMilkRateItem";
    var url = "/Rate/MilkRateItem";
    var Entry_Id = entry_id;
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      api_end_point: APIEndPoint,
      chart_id: Chart_Id,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        $("#txtEntryFatDeductionDeductionPerPoint").val(res[0].amount);
        $("#txtEntryFatDeductionFromDate").val(res[0].applicable_date);
        GetMaster(
          "ddlEntryDeductionFatSlab",
          "Select Fat Slab",
          "Get_FatDeduction",
          res[0].slab_id,
          MilkType_Id
        );
      },
      error: function () {
        ShowItemError(
          "Error in fetching details from server.",
          res[0].result_description
        );
      },
    });
  }
  if (action == "View") {
    $("#txtEntryFatDeductionDeductionPerPoint").prop("disabled", true);
    $("#txtEntryFatDeductionFromDate").prop("disabled", true);
    $("#ddlEntryDeductionFatSlab").prop("disabled", true);
  }
}
$("#modelEntryFatDeduction").on("hidden.bs.modal", function (e) {
  $("#lblActionFatDeduction").html("");
  $("#AddEditFatDeduction").text("");
});

function OpenModalSNFIncentives(action, version_no, entry_id) {
  var Chart_Id = $("#lblEntryId").html();
  $("#modelEntrySNFIncentives")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#AddEditSNFIncentives").text("Add SNF Incentives");

  $("#lblEntrySNFIncentivesVersionNo").html(version_no);
  $("#lblEntrySNFIncentivesId").html(entry_id);
  $("#lblActionSNFIncentives").html(action);

  $("#txtEntrySNFIncentivesIncentivePerPoint").val("");
  $("#txtEntrySNFIncentivesFromDate").val("");
  $("#ddlEntryIncentivesSNFSlab").val("");

  MilkType_Id = $("#ddlEntryMilkType").val();

  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/MilkRateItem";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetMilkRateItem";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012005",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length === 0) {
        date = new Date(Date.now());
      } else {
        var latest_date = new Date(res[0].applicable_date);
        date = new Date(Date.now()); //.toISOString().slice(0, 16);
        if (latest_date > date) {
          date = latest_date;
        }
      }

      /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

      var offset = date.getTimezoneOffset();
      date.setMinutes(date.getMinutes() - offset);
      var newdate = date.toISOString().slice(0, 16);

      $("#txtEntrySNFIncentivesFromDate").attr("min", newdate);
      $("#txtEntrySNFIncentivesFromDate").val(newdate);
    },
    error: function () {},
  });

  if (action == "Add") {
    GetMaster(
      "ddlEntryIncentivesSNFSlab",
      "Select SNF Slab",
      "Get_SNFIncentives",
      "",
      MilkType_Id
    );
  } else {
    var Method_Name = "Get_One";
    var APIEndPoint = "GetMilkRateItem";
    var url = "/Rate/MilkRateItem";
    var Entry_Id = entry_id;
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      api_end_point: APIEndPoint,
      chart_id: Chart_Id,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        $("#txtEntrySNFIncentivesIncentivePerPoint").val(res[0].amount);
        $("#txtEntrySNFIncentivesFromDate").val(res[0].applicable_date);
        GetMaster(
          "ddlEntryIncentivesSNFSlab",
          "Select SNF Slab",
          "Get_SNFIncentives",
          res[0].slab_id,
          MilkType_Id
        );
      },
      error: function () {
        ShowItemError(
          "Error in fetching details from server.",
          res[0].result_description
        );
      },
    });
  }
  if (action == "View") {
    $("#txtEntrySNFIncentivesIncentivePerPoint").prop("disabled", true);
    $("#txtEntrySNFIncentivesFromDate").prop("disabled", true);
    $("#ddlEntryIncentivesSNFSlab").prop("disabled", true);
  }
}
$("#modelEntrySNFIncentives").on("hidden.bs.modal", function (e) {
  $("#SNFIncentives").html("");
  $("#AddEditSNFIncentives").text("");
});

function OpenModalFatIncentives(action, version_no, entry_id) {
  $("#modelEntryFatIncentives")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#AddEditFatIncentives").text(action + " Fat Incentives");

  $("#lblEntryFatIncentivesVersionNo").html(version_no);
  $("#lblEntryFatIncentivesId").html(entry_id);
  $("#lblActionFatIncentives").html(action);

  $("#txtEntryFatIncentivesIncentivePerPoint").val("");
  $("#txtEntryFatIncentivesFromDate").val("");
  $("#ddlEntryIncentivesFatSlab").val("");

  MilkType_Id = $("#ddlEntryMilkType").val();

  // Setting Date Text Box value depending on the provided date from database

  var url = "/Rate/MilkRateItem";
  var Method_Name = "Get_Date";
  var APIEndPoint = "GetMilkRateItem";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012004",
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var date;
      if (res.length === 0) {
        date = new Date(Date.now());
      } else {
        var latest_date = new Date(res[0].applicable_date);
        date = new Date(Date.now()); //.toISOString().slice(0, 16);
        if (latest_date > date) {
          date = latest_date;
        }
      }

      /*
            next_date = new Date(date);
            next_date.setDate(next_date.getDate() + 1);
            newdate = next_date.toISOString().slice(0, 16);
            */

      var offset = date.getTimezoneOffset();
      date.setMinutes(date.getMinutes() - offset);
      var newdate = date.toISOString().slice(0, 16);

      $("#txtEntryFatIncentivesFromDate").attr("min", newdate);
      $("#txtEntryFatIncentivesFromDate").val(newdate);
    },
    error: function () {},
  });

  if (action == "Add") {
    GetMaster(
      "ddlEntryIncentivesFatSlab",
      "Select Fat Slab",
      "Get_FatIncentives",
      "",
      MilkType_Id
    );
  }
  //Edit
  else {
    var Method_Name = "Get_One";
    var APIEndPoint = "GetMilkRateItem";
    var url = "/Rate/MilkRateItem";
    var Entry_Id = entry_id;
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      api_end_point: APIEndPoint,
      chart_id: Chart_Id,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        $("#txtEntryFatIncentivesIncentivePerPoint").val(res[0].amount);
        $("#txtEntryFatIncentivesFromDate").val(res[0].applicable_date);
        GetMaster(
          "ddlEntryIncentivesFatSlab",
          "Select Fat Slab",
          "Get_FatIncentives",
          res[0].slab_id,
          MilkType_Id
        );
      },
      error: function () {
        ShowItemError(
          "Error in fetching details from server.",
          res[0].result_description
        );
      },
    });
  }
  if (action == "View") {
    $("#txtEntryFatIncentivesIncentivePerPoint").prop("disabled", true);
    $("#txtEntryFatIncentivesFromDate").prop("disabled", true);
    $("#ddlEntryIncentivesFatSlab").prop("disabled", true);
  }
}
$("#modelEntryFatIncentives").on("hidden.bs.modal", function (e) {
  $("#lblActionFatIncentives").html("");
  $("#AddEditFatIncentives").text("");
});

function OpenModalAssignMCC(action, version_no, set_date) {
  //// console.log(1);
  // ResetInputFields();
  // ClearDataTable("tableEntryModelMCC");
  // $('#tableAssignMCCEntryModal').empty();
  $("#selectAll").prop("checked", false);
  $("#modelEntryAssignMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  Chart_Id = $("#lblEntryId").html();

  $("#lblAssignMCCVersion").html(version_no);
  $("#lblActionAssignMCC").html(action);
  $("#txtEntryFromDateTimeMCC").val("");
  var MilkType_Id = $("#ddlEntryMilkType").val();
  var CollectionShift_Id = $("#ddlEntryMilkCollectionShift").val();

  if (action == "Add") {
    $("#divSearchField").show();
    if ($.fn.DataTable.isDataTable("#tableAssignMCCEntryModal")) {
      $("#tableAssignMCCEntryModal").DataTable().destroy();
      $(".filters").remove();
    }
    $("#AddEditAssignMCC").text("Assign MCC");
    $("#lblActionAssignMCC").html(action);
    $("#txtEntryFromDateTimeMCC").prop("disabled", false);
    $("#txtEntryToDateTimeMCC").prop("disabled", false);
    ClearDataTable("tableAssignMCCEntryModal");
    // TODO:
    // 1. Get vales for the MCC input table (MCC_CODE, MCC_NAME)
    // $('.filters').remove();
    var SearchText = "%%";
    var APIEndPoint = "GetMilkRateMCC";
    var Method_Name = "Get_MCC";
    var Version_No = $("#lblMCCVersion").html();
    var url = "/Rate/MilkRateMCC";
    // var reqdata = {
    //   method_name: Method_Name,
    //   api_end_point: APIEndPoint,
    //   milktype_id: MilkType_Id,
    //   collectionshift_id: CollectionShift_Id,
    //   search_text: SearchText,
    // };
    // $.ajax({
    //   type: "POST",
    //   url: url,
    //   contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    //   data: reqdata,
    //   success: function (result) {
    //     var res = JSON.parse(result);
    //     // console.log(res);
    //     // Fill data in table
    //     var TableHTML = "";
    //     // ClearDataTable("tableAssignMCCEntryModal");
    //     $.each(res, function (data, value) {
    //       TableHTML += "<tr>";
    //       TableHTML += '<td style="width: 20px;">';
    //       TableHTML += '<label class="custom-control custom-checkbox ">';
    //       TableHTML +=
    //         '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
    //         value.mcc_id +
    //         '"';
    //       TableHTML += 'style="vertical-align:sub; text-align: center;">';
    //       TableHTML +=
    //         '<span class="custom-control-label text-dark"></span></label></td>';
    //       TableHTML += "<td>" + value.mcc_code + "</td>";
    //       TableHTML += "<td>" + value.mcc_name + "</td>";
    //       TableHTML += "<td>" + value.taluka_name + "</td>";
    //       TableHTML += "<td>" + value.village_name + "</td>";
    //       TableHTML += "<td hidden></td>";
    //     });

    //     $("#tableEntryModelMCC").html(TableHTML);
    //     // SetDataTable("tableAssignMCCEntryModal", [5], "MilkMCCRate");
    //     $("#divAssignedMCCFooter").show();
    //     $("#thAssignedMCCCheckbox").show();
    //   },
    //   error: function (result) {
    //     ShowItemError(
    //       "Error in fetching details from server.",
    //       result[0].result_description
    //     );
    //   },
    // });

    var reqdata = {
      method_name: Method_Name,
      chart_id: Chart_Id,
      version_no: Version_No,
      api_end_point: APIEndPoint,
      milktype_id: MilkType_Id,
      collectionshift_id: CollectionShift_Id,
      search_text: SearchText,
    };
    //// console.log(reqdata);
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        //// console.log(res);
        // Fill data in table
        var allLocked = res.every(function (value) {
          return value.is_locked === 1;
        });
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";

          TableHTML += '<td style="width: 20px;">';
          TableHTML += '<label class="custom-control custom-checkbox ">';

          if (value.is_locked == 1) {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
              value.mcc_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" checked>';
          } else {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
              value.mcc_id +
              '"';
            TableHTML += 'style="vertical-align:sub; text-align: center;">';
          }

          TableHTML +=
            '<span class="custom-control-label text-dark"></span></label></td>';
          TableHTML += "<td>" + value.mcc_code + "</td>";
          TableHTML += "<td>" + value.mcc_name + "</td>";
          TableHTML += "<td>" + value.mcctype_name + "</td>";
          TableHTML += "<td>" + value.district_name + "</td>";
          TableHTML += "<td>" + value.taluka_name + "</td>";
          TableHTML += "<td>" + value.village_name + "</td>";
          TableHTML += "<td hidden></td>";
        });

        $("#tableEntryModelMCC").html(TableHTML);
        $("#thAssignedMCCCheckbox").show();
        SetDataTable_MCC("tableAssignMCCEntryModal", [7], "Milk MCC");

        // Check if all items have is_locked set to 1
        if (allLocked) {
          $("#selectAll").prop("checked", true);
        } else {
          $("#selectAll").prop("checked", false);
        }
        //show save button footer & th
        $("#divAssignedMCCFooter").show();

        // $("#tableAssignMCCEntryModal_filter").hide();
      },
      error: function (result) {
        ShowItemError(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  } else if (action == "Edit") {
    if ($.fn.DataTable.isDataTable("#tableAssignMCCEntryModal")) {
      $("#tableAssignMCCEntryModal").DataTable().destroy();
      $(".filters").remove();
    }
    $("#divSearchField").show();

    // Edit
    $("#lblActionAssignMCC").html(action);
    $("#lblAssignMCCVersion").html(version_no);

    $("#AddEditAssignMCC").text("Edit Assigned MCC");
    // $("#txtEntryFromDateTimeMCC").prop("disabled", true);
    $("#txtEntryFromDateTimeMCC").val(set_date);
    ClearDataTable("tableAssignMCCEntry");
    // $('.filters').remove();
    var SearchText = "%" + $("#txtSearchMCCSearchText").val() + "%";
    var APIEndPoint = "GetMilkRateMCC";
    var Method_Name = "Get_One";
    var url = "/Rate/MilkRateMCC";
    var reqdata = {
      method_name: Method_Name,
      chart_id: Chart_Id,
      version_no: version_no,
      api_end_point: APIEndPoint,
      milktype_id: MilkType_Id,
      collectionshift_id: CollectionShift_Id,
      search_text: SearchText,
    };
    //// console.log(reqdata);
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        //// console.log(res);
        // Fill data in table
        var allLocked = res.every(function (value) {
          return value.is_locked === 1;
        });
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";

          TableHTML += '<td style="width: 20px;">';
          TableHTML += '<label class="custom-control custom-checkbox ">';

          if (value.is_locked == 1) {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
              value.mcc_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" checked>';
          } else {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
              value.mcc_id +
              '"';
            TableHTML += 'style="vertical-align:sub; text-align: center;">';
          }

          TableHTML +=
            '<span class="custom-control-label text-dark"></span></label></td>';
          TableHTML += "<td>" + value.mcc_code + "</td>";
          TableHTML += "<td>" + value.mcc_name + "</td>";
          TableHTML += "<td>" + value.mcctype_name + "</td>";
          TableHTML += "<td>" + value.district_name + "</td>";
          TableHTML += "<td>" + value.taluka_name + "</td>";
          TableHTML += "<td>" + value.village_name + "</td>";
          TableHTML += "<td hidden></td>";
        });

        $("#tableEntryModelMCC").html(TableHTML);
        $("#thAssignedMCCCheckbox").show();
        SetDataTable_MCC("tableAssignMCCEntryModal", [7], "Milk MCC");
        // Check if all items have is_locked set to 1
        if (allLocked) {
          $("#selectAll").prop("checked", true);
        } else {
          $("#selectAll").prop("checked", false);
        }
        //show save button footer & th
        $("#divAssignedMCCFooter").show();
        // $("#thAssignedMCCCheckbox").show();
        // $("#tableAssignMCCEntryModal_filter").hide();
      },
      error: function (result) {
        ShowItemError(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  } else if (action == "View") {
    if ($.fn.DataTable.isDataTable("#tableAssignMCCEntryModal")) {
      $("#tableAssignMCCEntryModal").DataTable().destroy();
      $(".filters").remove();
    }
    $("#divSearchField").hide();
    // View
    $("#lblActionAssignMCC").html(action);
    $("#lblAssignMCCVersion").html(version_no);

    $("#AddEditAssignMCC").text("View Assigned MCC");
    $("#txtEntryFromDateTimeMCC").prop("disabled", true);
    $("#txtEntryFromDateTimeMCC").val(set_date);
    ClearDataTable("tableAssignMCCEntryModal");

    var APIEndPoint = "GetMilkRateMCC";
    var Method_Name = "Get_View";
    var url = "/Rate/MilkRateMCC";
    var reqdata = {
      method_name: Method_Name,
      chart_id: Chart_Id,
      version_no: version_no,
      api_end_point: APIEndPoint,
      milktype_id: MilkType_Id,
      collectionshift_id: CollectionShift_Id,
    };
    // // console.log(reqdata);
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        //// console.log(res);
        // Fill data in table
        var TableHTML = "";
        $.each(res, function (data, value) {
          if (value.is_locked == 1) {
            TableHTML += "<tr>";

            TableHTML += '<td style="width: 20px;" hidden>';
            TableHTML +=
              '<label class="custom-control custom-checkbox select-item checkbox">';

            TableHTML +=
              '<input type="checkbox" class="custom-control-input" value="' +
              value.mcc_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" checked disabled>';

            TableHTML +=
              '<span class="custom-control-label text-dark"></span></label></td>';
            TableHTML += "<td>" + value.mcc_code + "</td>";
            TableHTML += "<td>" + value.mcc_name + "</td>";
            TableHTML += "<td>" + value.mcctype_name + "</td>";
            TableHTML += "<td>" + value.district_name + "</td>";
            TableHTML += "<td>" + value.taluka_name + "</td>";
            TableHTML += "<td>" + value.village_name + "</td>";
            TableHTML += "<td hidden></td>";
            TableHTML += "</tr>";
          }
        });

        $("#tableEntryModelMCC").html(TableHTML);
        // SetDataTable_MCC("tableAssignMCCEntryModal", [7], "Milk MCC");
        //hide save button footer & th
        $("#divAssignedMCCFooter").hide();
        $("#thAssignedMCCCheckbox").hide();
        // $("#tableAssignMCCEntryModal_filter").hide();
      },
      error: function (result) {
        ShowItemError(
          "Error in fetching details from server.",
          result[0].result_description
        );
      },
    });
  }
}

function GetBaseRateTable() {
  ClearDataTable("tableBaseRateList");
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkRateItem";
  var url = "/Rate/MilkRateItem";
  Chart_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012001",
    api_end_point: APIEndPoint,
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
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        EditFlag = DeleteFlag = value.is_locked;
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 90px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML += "<td>" + value.basefat + "</td>";
        TableHTML += "<td>" + value.basesnf + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 120px; padding:8px 5px 8px 5px;'>";
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalBaseRate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag == 0) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntryItem(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 0 && value.is_backdate == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 1 && value.is_backdate == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntryBaseRate").html(TableHTML);
      SetDataTable("tableBaseRateList", [5], "Base Rate");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  GetBaseRateFatSNF();
  return;
}

function GetSNFDeductionTable() {
  ClearDataTable("tableSNFDeductionList");
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkRateItem";
  var url = "/Rate/MilkRateItem";
  Chart_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012003",
    api_end_point: APIEndPoint,
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
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());
      $.each(res, function (data, value) {
        EditFlag = DeleteFlag = value.is_locked;
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 90px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.slab_range + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 120px; padding:8px 5px 8px 5px;'>";
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalSNFDeduction(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag == 0) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntryItem(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 0 && value.is_backdate == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 1 && value.is_backdate == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableEntrySNFDeduction").html(TableHTML);
      SetDataTable("tableSNFDeductionList", [4], "SNF Deduction");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });

  return;
}

function GetFatDeductionTable() {
  ClearDataTable("tableFatDeductionList");
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkRateItem";
  var url = "/Rate/MilkRateItem";
  Chart_Id = $("#lblEntryId").html();
  var reqdata = {
    method_name: Method_Name,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012002",
    api_end_point: APIEndPoint,
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
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());
      $.each(res, function (data, value) {
        EditFlag = DeleteFlag = value.is_locked;
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 90px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.slab_range + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 120px; padding:8px 5px 8px 5px;'>";
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalFatDeduction(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag == 0) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntryItem(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 0 && value.is_backdate == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 1 && value.is_backdate == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryFatDeduction").html(TableHTML);
      SetDataTable("tableFatDeductionList", [4], "Fat Deduction");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

function GetSNFIncentivesTable() {
  ClearDataTable("tableSNFIncentivesList");
  var APIEndPoint = "GetMilkRateItem";
  var Method_Name = "Get";
  var url = "/Rate/MilkRateItem";
  Chart_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012005",
    api_end_point: APIEndPoint,
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
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());
      $.each(res, function (data, value) {
        EditFlag = DeleteFlag = value.is_locked;
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 90px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.slab_range + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 120px; padding:8px 5px 8px 5px;'>";
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalSNFIncentives(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag == 0) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntryItem(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 0 && value.is_backdate == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 1 && value.is_backdate == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntrySNFIncentives").html(TableHTML);
      SetDataTable("tableSNFIncentivesList", [4], "SNF Incentives");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
      //$("#btn_Save_Item").prop('disabled', false);
    },
  });
  return;
}

function GetFatIncentivesTable() {
  ClearDataTable("tableFatIncentivesList");
  var APIEndPoint = "GetMilkRateItem";
  var Method_Name = "Get";
  var url = "/Rate/MilkRateItem";
  Chart_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    chart_id: Chart_Id,
    milkrateentrytype_id: "C012004",
    api_end_point: APIEndPoint,
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
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());
      $.each(res, function (data, value) {
        EditFlag = DeleteFlag = value.is_locked;
        Row_No = Row_No + 1;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 90px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.slab_range + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 120px; padding:8px 5px 8px 5px;'>";
        if (EditFlag == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalFatIncentives(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (DeleteFlag == 0) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntryItem(\'' +
            value.entry_id +
            "');\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 0 && value.is_backdate == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 1 && value.is_backdate == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.entry_id +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryFatIncentives").html(TableHTML);
      SetDataTable("tableFatIncentivesList", [4], "Fat Incentives");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

function SaveBaseRateEntry() {
  // Validation
  Rate = $("#txtEntryBaseRateRate").val().trim();
  ApplicableDate = $("#txtEntryBaseRateFromDate").val();
  BaseFat = $("#txtEntryBaseRateBaseFat").val().trim();
  BaseSNF = $("#txtEntryBaseRateBaseSNF").val().trim();
  Chart_Id = $("#lblEntryId").html();

  Version_No = $("#lblEntryBaseRateVersionNo").val();
  var IsValid = 1;
  if (
    Rate == "" ||
    Rate == null ||
    Rate == undefined
    // ||
    // Is_Positive_Number_Greater_Than_Zero(Rate) == false ||
    // Is_Valid_Float(Rate) == false
  ) {
    IsValid = 0;
    $("#txtEntryBaseRateRate").addClass("is-invalid state-invalid");
  }
  if (
    ApplicableDate == "" ||
    ApplicableDate == null ||
    ApplicableDate == undefined
  ) {
    IsValid = 0;
    $("#txtEntryBaseRateFromDate").addClass("is-invalid state-invalid");
  }
  /*if (BaseFat == "") {
          IsValid = 0;
          $("#txtEntryBaseRateBaseFat").addClass("is-invalid state-invalid");
      }
      if (BaseSNF == "") {
          IsValid = 0;
          $("#txtEntryBaseRateBaseSNF").addClass("is-invalid state-invalid");
      }*/
  if (IsValid == 0) {
    ShowItemError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_Base_Rate").prop("disabled", true);

    var APIEndPoint = "SaveMilkRateItem";
    var Method_Name = "Create";
    var Entry_Id = "";
    var Action_Name = $("#lblActionBaseRate").html();

    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblEntryBaseRateId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MilkRateItem";
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      chart_id: Chart_Id,
      amount: Rate,
      version_no: Version_No,
      applicable_date: ApplicableDate,
      basefat: BaseFat,
      basesnf: BaseSNF,
      milkrateentrytype_id: "C012001",
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          $("#lblActionBaseRate").html("Edit");
          $("#lblEntryBaseRateId").html(result[0].result_extra_key);
          ShowItemSuccess("Base Rate details saved successfully");
          // ResetInputFields();
          GetBaseRateTable();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : Base Rate details not saved");
      },
    });
    $("#modelEntryBaseRate").modal("hide");
    $("#btn_Save_Base_Rate").prop("disabled", false);
  }
}

function SaveSNFDeductionEntry() {
  // Validation
  DeductionPerPoint = $("#txtEntrySNFDeductionDeductionPerPoint").val().trim();
  ApplicableDate = $("#txtEntrySNFDeductionFromDate").val();
  Slab_Id = $("#ddlEntryDeductionSNFSlab").val();
  Chart_Id = $("#lblEntryId").html();
  Entry_Id = $("#lblEntrySNFDeductionId").html();
  Version_No = $("#lblEntrySNFDeductionVersionNo").val();
  var IsValid = 1;
  if (
    DeductionPerPoint == "" ||
    DeductionPerPoint == null ||
    DeductionPerPoint == undefined
    // ||
    // Is_Positive_Number_Greater_Than_Zero(DeductionPerPoint) == false ||
    // Is_Valid_Float(DeductionPerPoint) == false
  ) {
    IsValid = 0;
    $("#txtEntrySNFDeductionDeductionPerPoint").addClass(
      "is-invalid state-invalid"
    );
  }
  if (
    ApplicableDate == "" ||
    ApplicableDate == null ||
    ApplicableDate == undefined
  ) {
    IsValid = 0;
    $("#txtEntrySNFDeductionFromDate").addClass("is-invalid state-invalid");
  }
  if (Slab_Id == "" || Slab_Id == null || Slab_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryDeductionSNFSlab").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowItemError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_SNF_Deduction").prop("disabled", true);
    var APIEndPoint = "SaveMilkRateItem";
    var Method_Name = "Create";
    var Entry_Id = "";
    var Action_Name = $("#lblActionSNFDeduction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblEntrySNFDeductionId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MilkRateItem";
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      chart_id: Chart_Id,
      version_no: Version_No,
      slab_id: Slab_Id,
      amount: DeductionPerPoint,
      applicable_date: ApplicableDate,
      milkrateentrytype_id: "C012003",
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          ShowItemSuccess("SNF Deduction details saved successfully");
          // ResetInputFields();
          GetSNFDeductionTable();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : SNF Deduction details not saved");
      },
    });
    $("#modelEntrySNFDeduction").modal("hide");
    $("#btn_Save_SNF_Deduction").prop("disabled", false);
  }
}

function SaveFatDeductionEntry() {
  // Validation
  DeductionPerPoint = $("#txtEntryFatDeductionDeductionPerPoint").val();
  $("#txtEntryFatDeductionDeductionPerPoint").val(DeductionPerPoint);

  ApplicableDate = $("#txtEntryFatDeductionFromDate").val();
  FatSlab_Id = $("#ddlEntryDeductionFatSlab").val();
  Chart_Id = $("#lblEntryId").html();
  Entry_Id = $("#lblEntryFatDeductionId").html();
  Version_No = $("#lblEntryFatDeductionVersionNo").val();
  var IsValid = 1;
  if (
    DeductionPerPoint == "" ||
    DeductionPerPoint == null ||
    DeductionPerPoint == undefined
    // ||
    // Is_Positive_Number_Greater_Than_Zero(DeductionPerPoint) == false ||
    // Is_Valid_Float(DeductionPerPoint) == false
  ) {
    IsValid = 0;
    $("#txtEntryFatDeductionDeductionPerPoint").addClass(
      "is-invalid state-invalid"
    );
  }
  if (
    ApplicableDate == "" ||
    ApplicableDate == null ||
    ApplicableDate == undefined
  ) {
    IsValid = 0;
    $("#txtEntryFatDeductionFromDate").addClass("is-invalid state-invalid");
  }
  if (FatSlab_Id == "" || FatSlab_Id == null || FatSlab_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryDeductionFatSlab").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowItemError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_Fat_Deduction").prop("disabled", true);
    var APIEndPoint = "SaveMilkRateItem";
    var Method_Name = "Create";
    var Action_Name = $("#lblActionFatDeduction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      SNFDeduction_Id = $("#lblEntryFatDeductionId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MilkRateItem";
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      chart_id: Chart_Id,
      version_no: Version_No,
      amount: DeductionPerPoint,
      applicable_date: ApplicableDate,
      slab_id: FatSlab_Id,
      milkrateentrytype_id: "C012002",
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          ShowItemSuccess("Fat Deduction details saved successfully");
          // ResetInputFields();
          GetFatDeductionTable();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : Fat Deduction details not saved");
      },
    });
    $("#modelEntryFatDeduction").modal("hide");
    $("#btn_Save_Fat_Deduction").prop("disabled", false);
  }
}

function SaveSNFIncentivesEntry() {
  // Validation
  IncentivePerPoint = $("#txtEntrySNFIncentivesIncentivePerPoint").val();
  $("#txtEntrySNFIncentivesIncentivePerPoint").val(IncentivePerPoint);

  ApplicableDate = $("#txtEntrySNFIncentivesFromDate").val();
  SNFSlab_Id = $("#ddlEntryIncentivesSNFSlab").val();
  Chart_Id = $("#lblEntryId").html();
  Entry_Id = $("#lblEntrySNFIncentivesId").html();
  Version_No = $("#lblEntrySNFIncentivesVersionNo").val();

  var IsValid = 1;

  if (
    IncentivePerPoint == "" ||
    IncentivePerPoint == null ||
    IncentivePerPoint == undefined
    // ||
    // Is_Positive_Number_Greater_Than_Zero(IncentivePerPoint) == false ||
    // Is_Valid_Float(IncentivePerPoint) == false
  ) {
    IsValid = 0;
    $("#txtEntrySNFIncentivesIncentivePerPoint").addClass(
      "is-invalid state-invalid"
    );
  }
  if (
    ApplicableDate == "" ||
    ApplicableDate == null ||
    ApplicableDate == undefined
  ) {
    IsValid = 0;
    $("#txtEntrySNFIncentivesFromDate").addClass("is-invalid state-invalid");
  }
  if (SNFSlab_Id == "" || SNFSlab_Id == null || SNFSlab_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryIncentivesSNFSlab").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowItemError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_SNF_Incentives").prop("disabled", true);
    var APIEndPoint = "SaveMilkRateItem";
    var Method_Name = "Create";
    var Action_Name = $("#lblActionSNFIncentives").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      SNFIncentives_Id = $("#lblEntrySNFIncentivesId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MilkRateItem";
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      chart_id: Chart_Id,
      version_no: Version_No,
      amount: IncentivePerPoint,
      applicable_date: ApplicableDate,
      slab_id: SNFSlab_Id,
      milkrateentrytype_id: "C012005",
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          ShowItemSuccess("SNF Incentives details saved successfully");
          // ResetInputFields();
          GetSNFIncentivesTable();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : SNF Incentives details not saved");
      },
    });
    $("#modelEntrySNFIncentives").modal("hide");
    $("#btn_Save_SNF_Incentives").prop("disabled", false);
  }
}

function SaveFatIncentivesEntry() {
  // Validation
  IncentivePerPoint = $("#txtEntryFatIncentivesIncentivePerPoint").val();
  $("#txtEntryFatIncentivesIncentivePerPoint").val(IncentivePerPoint);

  ApplicableDate = $("#txtEntryFatIncentivesFromDate").val();
  FatSlab_Id = $("#ddlEntryIncentivesFatSlab").val();
  Chart_Id = $("#lblEntryId").html();
  Entry_Id = $("#lblEntryFatIncentivesId").html();
  Version_No = $("#lblEntryFatIncentivesVersionNo").val();

  var IsValid = 1;
  if (
    IncentivePerPoint == "" ||
    IncentivePerPoint == null ||
    IncentivePerPoint == undefined
    // ||
    // Is_Positive_Number_Greater_Than_Zero(IncentivePerPoint) == false ||
    // Is_Valid_Float(IncentivePerPoint) == false
  ) {
    IsValid = 0;
    $("#txtEntryFatIncentivesIncentivePerPoint").addClass(
      "is-invalid state-invalid"
    );
  }
  if (
    ApplicableDate == "" ||
    ApplicableDate == null ||
    ApplicableDate == undefined
  ) {
    IsValid = 0;
    $("#txtEntryFatIncentivesFromDate").addClass("is-invalid state-invalid");
  }
  if (FatSlab_Id == "" || FatSlab_Id == null || FatSlab_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryIncentivesFatSlab").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowItemError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_Fat_Incentives").prop("disabled", true);
    var APIEndPoint = "SaveMilkRateItem";
    var Method_Name = "Create";
    var FatIncentives_Id = 0;
    var Action_Name = $("#lblActionFatIncentives").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      FatIncentives_Id = $("#lblEntryFatIncentivesId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MilkRateItem";
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      chart_id: Chart_Id,
      version_no: Version_No,
      amount: IncentivePerPoint,
      applicable_date: ApplicableDate,
      slab_id: FatSlab_Id,
      milkrateentrytype_id: "C012004",
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          ShowItemSuccess("Fat Incentives details saved successfully");
          // ResetInputFields();
          GetFatIncentivesTable();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : Fat Incentives details not saved");
      },
    });
    $("#modelEntryFatIncentives").modal("hide");
    $("#btn_Save_Fat_Incentives").prop("disabled", false);
  }
}

function ShowDeleteEntryItem(entry_id) {
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
        SaveDeleteEntryItem(entry_id);
      }
    }
  );
}

function SaveDeleteEntryItem(Entry_Id) {
  // Write code to delete
  Chart_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveMilkRateItem";
  var url = "/Rate/MilkRateItem";

  var reqdata = {
    method_name: "Delete",
    entry_id: Entry_Id,
    chart_id: Chart_Id,
    api_end_point: APIEndPoint,
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
        ShowItemSuccess("Milk Item details deleted successfully");
        GetBaseRateTable();
        GetSNFDeductionTable();
        GetFatDeductionTable();
        GetSNFIncentivesTable();
        GetFatIncentivesTable();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : Milk Item details not deleted");
    },
  });
}

function GetMCCEntryList() {
  ClearDataTable("MCCEntryList");
  $("#lblMCCVersion").html("");
  var Method_Name = "Get";
  var APIEndPoint = "GetMilkRateMCC";
  var url = "/Rate/MilkRateMCC ";
  Chart_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    chart_id: Chart_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      //// console.log(res);

      if (res.length > 0) {
        var lastItem = res[0];
        var version_no = lastItem.version_no;
        //// console.log(version_no);
        $("#lblMCCVersion").html(version_no);
      } else {
        $("#lblMCCVersion").html("");
      }

      // Fill data in table
      var TableHTML = "";
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      var DeleteFlag = 1;
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 120px;'>" + value.version_no + "</td>";
        TableHTML += "<td>" + value.applicable_date + "</td>";
        TableHTML +=
          '<td class="text-right" style="width: 80px; padding: 8px 5px 8px 5px;">';
        if (value.is_locked == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="OpenModalAssignMCC(\'View\', \'' +
            value.version_no +
            "', '" +
            value.set_date +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        } else {
          if (EditFlag == 1) {
            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="OpenModalAssignMCC(\'Edit\', \'' +
              value.version_no +
              "', '" +
              value.set_date +
              "')\">";
            TableHTML += '<i class="fa fa-pencil"></i>';
            TableHTML += "</a>";
          }
          if (DeleteFlag == 1) {
            TableHTML +=
              '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteEntryMCC(\'' +
              value.version_no +
              "')\">";
            TableHTML += '<i class="fa fa-trash"></i>';
            TableHTML += "</a>";
          }
        }
        if (value.is_locked == 0 && value.is_backdate == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackMCCDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        if (value.is_locked == 1 && value.is_backdate == 1) {
          TableHTML +=
            '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Back Date Rate" onclick="OpenModalBackMCCDate(\'Edit\',\'' +
            value.version_no +
            "','" +
            value.back_date +
            "','" +
            value.is_accessdate +
            "');\">";
          TableHTML += '<i class="fa fa-calendar"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableAssignMCC").html(TableHTML);
      SetDataTable("MCCEntryList", [2], "Milk MCC");
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

// function ResetInputFields() {
//   $(".modal input, select").val("");
// }

function SaveMilkRateMCC() {
  // Validation
  Applicable_Date = $("#txtEntryFromDateTimeMCC").val();

  Chart_Id = $("#lblEntryId").html();
  var Version_No = $("#lblAssignMCCVersion").html();

  var selectedCheckboxes = $("#tableAssignMCCEntryModal").find(
    "tbody input[type='checkbox']:checked"
  );
  var MCC_Id = [];

  selectedCheckboxes.each(function () {
    var checkboxId = $(this).val();
    MCC_Id.push(checkboxId);
  });

  var IsValid = 1;
  if (
    Applicable_Date == "" ||
    Applicable_Date == null ||
    Applicable_Date == undefined
  ) {
    IsValid = 0;
    $("#txtEntryFromDateTimeMCC").addClass("is-invalid state-invalid");
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_Fat_Incentives").prop("disabled", true);
    var APIEndPoint = "SaveMilkRateMCC";
    var Method_Name = "Create";

    var Action_Name = $("#lblActionAssignMCC").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      MilkRateMCC_Id = $("#lblActionAssignMCC").html();
      Version_No = $("#lblAssignMCCVersion").html();
    }

    var url = "/Rate/MilkRateMCC";
    var reqdata = {
      method_name: Method_Name,
      applicable_date: Applicable_Date,
      version_no: Version_No,
      chart_id: Chart_Id,
      mcc_id: MCC_Id.join(","),
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          ShowItemSuccess("Milk Rate MCC details saved successfully");
          GetMCCEntryList();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : Milk Rate MCC details not saved");
      },
    });
    $("#modelEntryAssignMCC").modal("hide");
  }
}
// $("#modelEntryAssignMCC").on("hidden.bs.modal", function (e) {
//   // console.log("Modal hidden event triggered");

// });

function ShowDeleteEntryMCC(Version_No) {
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
      if (result) {
        SaveDeleteEntryMCC(Version_No);
      }
    }
  );
}

function SaveDeleteEntryMCC(Version_No) {
  // Write code to delete
  Chart_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;

  var APIEndPoint = "SaveMilkRateMCC";
  var url = "/Rate/MilkRateMCC";
  var reqdata = {
    method_name: "Delete",
    version_no: Version_No,
    chart_id: Chart_Id,
    api_end_point: APIEndPoint,
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
        ShowItemSuccess("Milk Rate MCC details deleted successfully");
        GetMCCEntryList();
      } else {
        ShowItemError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowItemError("Error : Milk Rate MCC details not deleted");
    },
  });
}

function GetMCCforAssignedMCC() {
  //// console.log(1);
  // $("#btn_Search_MCC").prop("disabled", true);
  var SearchText = "%" + $("#txtSearchMCCSearchText").val() + "%";
  if (SearchText == "") {
    return;
  }
  var Method_Name = "Get_MCC";
  var Action = $("#lblActionAssignMCC").html();
  if (Action == "Edit") {
    Method_Name = "Get_One";
  }
  /*else if (Action == "View") {
          Method_Name = 'Get_View';
      }*/
  var MilkType_Id = $("#ddlEntryMilkType").val();
  var CollectionShift_Id = $("#ddlEntryMilkCollectionShift").val();
  var Version_No = $("#lblMCCVersion").html();
  ClearDataTable("tableAssignMCCEntryModal");
  var APIEndPoint = "GetMilkRateMCC";
  var url = "/Rate/MilkRateMCC ";
  Chart_Id = $("#lblEntryId").html();

  var reqdata = {
    method_name: Method_Name,
    chart_id: Chart_Id,
    version_no: Version_No,
    api_end_point: APIEndPoint,
    milktype_id: MilkType_Id,
    collectionshift_id: CollectionShift_Id,
    search_text: SearchText,
  };
  //// console.log(reqdata);
  // return;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      //// console.log(res);
      // Fill data in table
      var allLocked = res.every(function (value) {
        return value.is_locked === 1;
      });
      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";

        TableHTML += '<td style="width: 20px;">';
        TableHTML += '<label class="custom-control custom-checkbox ">';

        if (value.is_locked == 1) {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.mcc_id +
            '"';
          TableHTML +=
            'style="vertical-align:sub; text-align: center;" checked>';
        } else {
          TableHTML +=
            '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
            value.mcc_id +
            '"';
          TableHTML += 'style="vertical-align:sub; text-align: center;">';
        }

        TableHTML +=
          '<span class="custom-control-label text-dark"></span></label></td>';
        TableHTML += "<td>" + value.mcc_code + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mcctype_name + "</td>";
        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td hidden></td>";
      });

      $("#tableEntryModelMCC").html(TableHTML);
      $("#thAssignedMCCCheckbox").show();
      SetDataTable_MCC("tableAssignMCCEntryModal", [7], "Milk MCC");
      // Check if all items have is_locked set to 1
      if (allLocked) {
        $("#selectAll").prop("checked", true);
      } else {
        $("#selectAll").prop("checked", false);
      }
      //show save button footer & th
      $("#divAssignedMCCFooter").show();
    },
    error: function (result) {
      ShowItemError(
        "Error in fetching details from server.",
        result[0].result_description
      );
    },
  });
  // $.ajax({
  //   type: "POST",
  //   url: url,
  //   contentType: "application/x-www-form-urlencoded; charset=UTF-8",
  //   data: reqdata,
  //   success: function (result) {
  //     var res = JSON.parse(result);
  //     // Fill data in table
  //     var TableHTML = "";
  //     var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
  //     var DeleteFlag = 1;
  //     /*if (Action == "View") {
  //                     GetMCCModalList(Action, res);
  //                     return;
  //                 }*/
  //     $.each(res, function (data, value) {
  //       TableHTML += "<tr>";

  //       TableHTML += '<td style="width: 20px;">';
  //       TableHTML += '<label class="custom-control custom-checkbox ">';

  //       if (value.is_locked == 1) {
  //         TableHTML +=
  //           '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
  //           value.mcc_id +
  //           '"';
  //         TableHTML +=
  //           'style="vertical-align:sub; text-align: center;" checked >';
  //       } else {
  //         TableHTML +=
  //           '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
  //           value.mcc_id +
  //           '"';
  //         TableHTML += 'style="vertical-align:sub; text-align: center;">';
  //       }

  //       TableHTML +=
  //         '<span class="custom-control-label text-dark"></span></label></td>';
  //       TableHTML += "<td>" + value.mcc_code + "</td>";
  //       TableHTML += "<td>" + value.mcc_name + "</td>";
  //       TableHTML += "<td>" + value.taluka_name + "</td>";
  //       TableHTML += "<td>" + value.village_name + "</td>";
  //       TableHTML += "<td hidden></td>";
  //     });

  //     $("#tableEntryModelMCC").html(TableHTML);
  //     // SetDataTable("tableAssignMCCEntryModal", [5], "Milk MCC");

  //     //show save button footer & th
  //     $("#divAssignedMCCFooter").show();
  //     $("#thAssignedMCCCheckbox").show();
  //   },
  //   error: function (result) {
  //     ShowItemError(
  //       "Error in fetching details from server.",
  //       result[0].result_description
  //     );
  //   },
  // });
  $("#btn_Search_MCC").prop("disabled", false);
}

/*
function GetMCCModalList(Action, res) {
    if (Action == "View") {
        var TableHTML = "";
        $.each(res, function (data, value) {
            if (value.is_locked == 1) {
                TableHTML += "<tr>"

                TableHTML += '<td style="width: 20px;" hidden>';
                TableHTML += '<label class="custom-control custom-checkbox ">';

                TableHTML += '<input type="checkbox" class="custom-control-input" value="' + value.mcc_id + '"';
                TableHTML += 'style="vertical-align:sub; text-align: center;" checked disabled>';

                TableHTML += '<span class="custom-control-label text-dark"></span></label></td>';
                TableHTML += "<td>" + value.mcc_code + "</td>";
                TableHTML += "<td>" + value.mcc_name + "</td>";
                TableHTML += "<td hidden></td>";
                TableHTML += "</tr>";
            }
        });
        ClearDataTable("tableAssignMCCEntryModal");
        $("#tableEntryModelMCC").html(TableHTML);
        SetDataTable("tableAssignMCCEntry", [3], "Milk MCC");
        //hide save button footer & th
        $("#divAssignedMCCFooter").hide();
        $("#thAssignedMCCCheckbox").hide();
    }
}
*/

// // column checkbox select all or cancel
// $("input.select-all").click(function () {
//   var checked = this.checked;
//   $("input.select-item").prop("checked", checked);
// });

// // check selected items
// $("input.select-item").click(function () {
//   checkSelected();
// });

// // check if all selected
// function checkSelected() {
//   var all = $("input.select-all")[0];
//   var total = $("input.select-item").length;
//   var len = $("input.select-item:checked").length;
//   all.checked = len === total;
// }

function SaveBackDateEntry() {
  var ApplicableDate = $("#txtEntryFromDateBackDate").val();
  var BackDate = $("#lblEntryIdBackDateMin").html();
  var Chart_Id = $("#lblEntryId").html();
  var Version_No = $("#lblEntryVersionNoBackDate").html();

  var IsAccessDate = $("#lblEntryIsAccessDate").html();

  var IsValid = 1;
  if (
    ApplicableDate == "" ||
    ApplicableDate == null ||
    ApplicableDate == undefined
  ) {
    IsValid = 0;
    $("#txtEntryFromDateBackDate").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }

  var applicableDateObj = new Date(ApplicableDate);
  var backDateObj = new Date(BackDate);
  if (IsAccessDate != "1") {
    if (applicableDateObj <= backDateObj) {
      $("#txtEntryFromDateBackDate").addClass("is-invalid state-invalid");
      Show_Error_Toastr(
        `Applicable Date must be greater than ${formatDate(backDateObj)}`
      );
      return;
    } else {
      // Start Saving
      Show_Loader();
      $("#btn_Save_Back_Date").prop("disabled", true);

      var APIEndPoint = "SaveMilkRateItem";

      Method_Name = "Update_Date";
      var Entry_Id = $("#lblEntryIdBackDate").html();

      var Is_Active = 1;
      var Is_Deleted = 0;
      var url = "/Rate/MilkRateItem";
      var reqdata = {
        method_name: Method_Name,
        entry_id: Entry_Id,
        chart_id: Chart_Id,
        version_no: Version_No,
        applicable_date: ApplicableDate,
        api_end_point: APIEndPoint,
        is_active: Is_Active,
        is_deleted: Is_Deleted,
      };
      $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (res) {
          var result = JSON.parse(res);
          if (result[0].result_id == 1) {
            Hide_Loader();
            ShowItemSuccess("details saved successfully");

            GetBaseRateTable();
            GetSNFDeductionTable();
            GetFatDeductionTable();
            GetSNFIncentivesTable();
            GetFatIncentivesTable();
          } else {
            Hide_Loader();
            ShowItemError("Error : " + result[0].result_description);
          }
        },
        error: function () {
          Hide_Loader();
          ShowItemError("Error : details not saved");
        },
      });
      $("#modelEntryBackDate").modal("hide");
      $("#btn_Save_Back_Date").prop("disabled", false);
    }
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_Back_Date").prop("disabled", true);

    var APIEndPoint = "SaveMilkRateItem";

    Method_Name = "Update_Date";
    var Entry_Id = $("#lblEntryIdBackDate").html();

    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MilkRateItem";
    var reqdata = {
      method_name: Method_Name,
      entry_id: Entry_Id,
      chart_id: Chart_Id,
      version_no: Version_No,
      applicable_date: ApplicableDate,
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          ShowItemSuccess("details saved successfully");

          GetBaseRateTable();
          GetSNFDeductionTable();
          GetFatDeductionTable();
          GetSNFIncentivesTable();
          GetFatIncentivesTable();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : details not saved");
      },
    });
    $("#modelEntryBackDate").modal("hide");
    $("#btn_Save_Back_Date").prop("disabled", false);
  }
}

function formatDate(date) {
  var options = {
    year: "numeric",
    month: "short",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  };
  return new Intl.DateTimeFormat("en-US", options).format(date);
}

function OpenModalBackMCCDate(action, version_no, back_date, is_accessdate) {
  $("#modelEntryBackDateMCC")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#btn_Save_Back_Date_MCC").prop("disabled", false);
  $("#AddEditBackDateMCC").text(action + "");

  $("#lblEntryVersionNoBackDateMCC").html(version_no);
  $("#lblActionBackDateMCC").html(action);
  $("#lblEntryIdBackDateMinMCC").html(back_date);
  $("#lblEntryIsAccessDateMCC").html(is_accessdate);
  $("#txtEntryFromDateBackDateMCC").val("");

  Chart_Id = $("#lblEntryId").html();

  var Method_Name = "Get_One_MCC";
  var APIEndPoint = "GetMilkRateMCC";
  var url = "/Rate/MilkRateMCC";
  var Version_No = version_no;
  var reqdata = {
    method_name: Method_Name,
    version_no: Version_No,
    chart_id: Chart_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      if (is_accessdate == "1") {
        $("#txtEntryFromDateBackDateMCC").attr("");
        // $("#txtEntryFromDateBackDate").attr("max", back_date);
        $("#txtEntryFromDateBackDateMCC").val(back_date);
      } else {
        if (res.length === 0) {
          $("#txtEntryFromDateBackDateMCC").attr("min", back_date);
          // $("#txtEntryFromDateBackDate").attr("max", back_date);
          $("#txtEntryFromDateBackDateMCC").val(back_date);
        } else {
          $("#txtEntryFromDateBackDateMCC").attr("min", back_date);
          // $("#txtEntryFromDateBackDate").attr("max", res[0].applicable_date);
          $("#txtEntryFromDateBackDateMCC").val(res[0].applicable_date);
        }
      }
    },
    error: function () {
      ShowItemError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SaveBackDateEntryMCC() {
  var ApplicableDate = $("#txtEntryFromDateBackDateMCC").val();
  var BackDate = $("#lblEntryIdBackDateMinMCC").html();
  var Chart_Id = $("#lblEntryId").html();
  var Version_No = $("#lblEntryVersionNoBackDateMCC").html();

  var IsAccessDate = $("#lblEntryIsAccessDateMCC").html();

  console.log(IsAccessDate);
  

  var IsValid = 1;
  if (
    ApplicableDate == "" ||
    ApplicableDate == null ||
    ApplicableDate == undefined
  ) {
    IsValid = 0;
    $("#txtEntryFromDateBackDateMCC").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  }
  var applicableDateObj = new Date(ApplicableDate);
  var backDateObj = new Date(BackDate);
  if (IsAccessDate != "1") {
    if (applicableDateObj <= backDateObj) {
      $("#txtEntryFromDateBackDateMCC").addClass("is-invalid state-invalid");
      Show_Error_Toastr(
        `Applicable Date must be greater than ${formatDate(backDateObj)}`
      );
      return;
    } else {
      // Start Saving
      Show_Loader();
      $("#btn_Save_Back_Date_MCC").prop("disabled", true);

      var APIEndPoint = "SaveMilkRateMCC";

      Method_Name = "Update_Date_MCC";

      var Is_Active = 1;
      var Is_Deleted = 0;
      var url = "/Rate/MilkRateMCC";
      var reqdata = {
        method_name: Method_Name,
        chart_id: Chart_Id,
        version_no: Version_No,
        applicable_date: ApplicableDate,
        api_end_point: APIEndPoint,
        is_active: Is_Active,
        is_deleted: Is_Deleted,
      };
      $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (res) {
          var result = JSON.parse(res);
          if (result[0].result_id == 1) {
            Hide_Loader();
            ShowItemSuccess("details saved successfully");

            GetMCCEntryList();
          } else {
            Hide_Loader();
            ShowItemError("Error : " + result[0].result_description);
          }
        },
        error: function () {
          Hide_Loader();
          ShowItemError("Error : details not saved");
        },
      });
      $("#modelEntryBackDateMCC").modal("hide");
      $("#btn_Save_Back_Date_MCC").prop("disabled", false);
    }
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save_Back_Date_MCC").prop("disabled", true);

    var APIEndPoint = "SaveMilkRateMCC";

    Method_Name = "Update_Date_MCC";

    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Rate/MilkRateMCC";
    var reqdata = {
      method_name: Method_Name,
      chart_id: Chart_Id,
      version_no: Version_No,
      applicable_date: ApplicableDate,
      api_end_point: APIEndPoint,
      is_active: Is_Active,
      is_deleted: Is_Deleted,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Hide_Loader();
          ShowItemSuccess("details saved successfully");

          GetMCCEntryList();
        } else {
          Hide_Loader();
          ShowItemError("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Hide_Loader();
        ShowItemError("Error : details not saved");
      },
    });
    $("#modelEntryBackDateMCC").modal("hide");
    $("#btn_Save_Back_Date_MCC").prop("disabled", false);
  }
}
