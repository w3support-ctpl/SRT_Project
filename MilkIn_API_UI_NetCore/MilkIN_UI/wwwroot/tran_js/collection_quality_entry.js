$(document).ready(function () {
  var date = new Date().toISOString().slice(0, 10);
  $("#txtSearchDuration").val(date);
});

function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetQualityEntry";
  var Method_Name = "Get";
  // var ApprovalStatus_Id = $("#ddlSearchSAPPostedStatus").val();
  var url = "/Collection/QualityEntry";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }

  // var Status_Id = "";

  // if (ApprovalStatus_Id == "") {
  //   Status_Id = "0";
  // } else {
  //   Status_Id = ApprovalStatus_Id;
  // }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    search_period: Search_Period,
    // approvalstatus_id: Status_Id,
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
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      $.each(res, function (data, value) {
        // if (value.is_posted == 1) {
        //   Status = "Posted";
        //   EditFlag = false;
        // } else {
        //   Status = "Pending";
        //   EditFlag = true;
        // }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.vehicletype_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        // TableHTML += "<td>" + value.amount + "</td>";

        // TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        // if (EditFlag) {
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick=\'ShowAddEntry("' +
          value.milkcollectiondairy_id +
          '", "' +
          value.vehicle_no +
          '", "' +
          value.vehicletype_name +
          '", "' +
          value.collectionshift_name +
          '");\'><i class="fa fa-pencil"></i></a>';

        // }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [4], "Quality Entry");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function ShowAddEntry(
  MilkCollectionDairy_Id,
  Vehicle_No,
  VehicleType_Name,
  CollectionShift_Name
) {
  ShowContentDiv("Collection", "QualityEntryEdit", "", function () {
    $("#divChkForAllowManualQuality").hide();
    var SessionRoleId = $("#lblSessionRoleId").html();
    if (SessionRoleId == "MU001" || SessionRoleId == "MU01241000008") {
      $("#divChkForAllowManualQuality").show();
    } else {
      $("#divChkForAllowManualQuality").hide();
    }
    // $("#lblMilkCollectionDairyId").html(MilkCollectionDairy_Id);
    $("#lblEntryId").html(MilkCollectionDairy_Id);

    $("#txtEntryVehicleNo").val(Vehicle_No);
    $("#txtEntryVehicleType").val(VehicleType_Name);
    $("#txtEntryShift").val(CollectionShift_Name);

    $("#lblAction").html("Edit");
    ShowEditEntry();
  });
}

function ShowEditEntry() {
  ClearDataTable("tablequalityentryitems");
  var MilkCollectionDairy_Id = $("#lblEntryId").html().trim();

  var Is_ManualQuality = 1;

  if (!$("#chkForAllowManualQuality").prop("checked")) {
    Is_ManualQuality = 0;
  }
  // var Method_Name = "Get_One";
  var Method_Name = "";
  var VehicleType = $("#txtEntryVehicleType").val();

  if (VehicleType == "Truck") {
    Method_Name = "Get_One_Truck";
  }
  if (VehicleType == "Tanker") {
    Method_Name = "Get_One_Tanker";
  }
  if (VehicleType == "BulkSupplier") {
    Method_Name = "Get_One";
  }

  var APIEndPoint = "GetQualityEntry";

  var url = "/Collection/QualityEntry";
  var reqdata = {
    method_name: Method_Name,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // console.log(res);
      var TableHTML = "";
      var Prev_Is_MCC = "0";

      if (VehicleType == "Truck") {
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
          if (value.is_mcc == 0) {
            TableHTML += "<td>";
            TableHTML += "<label class='custom-control custom-checkbox '>";
            TableHTML +=
              "<input type='checkbox' class='custom-control-input select-item checkbox' id='txtChk" +
              value.entry_id +
              "' value='" +
              value.entry_id +
              "'";
            // TableHTML +=
            //   "style='vertical-align:sub; text-align: center;' checked>";
            if (
              value.milkstatus_id == "C016001" ||
              value.milkstatus_id == "" ||
              value.milkstatus_id == null ||
              value.milkstatus_id == undefined
            ) {
              TableHTML +=
                "style='vertical-align:sub; text-align: center;' checked onclick='confirmCheckboxToggle(this)'>";
            } else {
              TableHTML +=
                "style='vertical-align:sub; text-align: center;' onclick='confirmCheckboxToggle(this)'>";
            }
            TableHTML +=
              "<span class='custom-control-label text-dark'></span></label></td>";
          }

          TableHTML += "<td>" + value.sample_no + "</td>";

          if (Is_ManualQuality == 1) {
            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtFat" +
              value.entry_id +
              "' value='" +
              value.fat +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSNF" +
              value.entry_id +
              "' value='" +
              value.snf +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtProtein" +
              value.entry_id +
              "' value='" +
              value.protein +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Protein.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAsh" +
              value.entry_id +
              "' value='" +
              value.ash +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSodium" +
              value.entry_id +
              "' value='" +
              value.sodium +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";
            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAdulteration" +
              value.entry_id +
              "' value='" +
              value.adulteration +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";
          } else {
            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtFat" +
              value.entry_id +
              "' value='" +
              value.fat +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSNF" +
              value.entry_id +
              "' value='" +
              value.snf +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtProtein" +
              value.entry_id +
              "' value='" +
              value.protein +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Protein.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAsh" +
              value.entry_id +
              "' value='" +
              value.ash +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSodium" +
              value.entry_id +
              "' value='" +
              value.sodium +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAdulteration" +
              value.entry_id +
              "' value='" +
              value.adulteration +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";
          }

          TableHTML +=
            "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Data" onclick=\'SaveEntryAfterGetData("' +
            value.entry_id +
            '");\'><i class="fa fa-save"></i></a>';

          TableHTML += "</td>";
          TableHTML += "</tr>";
        });
      }
      if (VehicleType == "Tanker") {
        $.each(res, function (data, value) {
          // console.log(Prev_Is_MCC, " - ", value.is_mcc);
          if (value.is_mcc == "0") {
            TableHTML += "<tr>";
            TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

            TableHTML += "<td>";
            TableHTML += "<label class='custom-control custom-checkbox '>";
            TableHTML +=
              "<input type='checkbox' class='custom-control-input select-item checkbox' id='txtChk" +
              value.entry_id +
              "' value='" +
              value.entry_id +
              "'";
            // TableHTML +=
            //   "style='vertical-align:sub; text-align: center;' checked>";
            if (
              value.milkstatus_id == "C016001" ||
              value.milkstatus_id == "" ||
              value.milkstatus_id == null ||
              value.milkstatus_id == undefined
            ) {
              TableHTML +=
                "style='vertical-align:sub; text-align: center;' checked onclick='confirmCheckboxToggle(this)'>";
            } else {
              TableHTML +=
                "style='vertical-align:sub; text-align: center;' onclick='confirmCheckboxToggle(this)'>";
            }

            TableHTML +=
              "<span class='custom-control-label text-dark'></span></label></td>";

            TableHTML += "<td>" + value.sample_no + "</td>";

            if (Is_ManualQuality == 1) {
              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtFat" +
                value.entry_id +
                "' value='" +
                value.fat +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSNF" +
                value.entry_id +
                "' value='" +
                value.snf +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtProtein" +
                value.entry_id +
                "' value='" +
                value.protein +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Protein.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAsh" +
                value.entry_id +
                "' value='" +
                value.ash +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSodium" +
                value.entry_id +
                "' value='" +
                value.sodium +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAdulteration" +
                value.entry_id +
                "' value='" +
                value.adulteration +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";
            } else {
              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtFat" +
                value.entry_id +
                "' value='" +
                value.fat +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSNF" +
                value.entry_id +
                "' value='" +
                value.snf +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtProtein" +
                value.entry_id +
                "' value='" +
                value.protein +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Protein.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAsh" +
                value.entry_id +
                "' value='" +
                value.ash +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSodium" +
                value.entry_id +
                "' value='" +
                value.sodium +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAdulteration" +
                value.entry_id +
                "' value='" +
                value.adulteration +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";
            }

            TableHTML +=
              "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Data" onclick=\'SaveEntryAfterGetData("' +
              value.entry_id +
              '");\'><i class="fa fa-save"></i></a>';

            TableHTML += "</td>";
            TableHTML += "</tr>";
          }

          // TableHTML += "<td colspan='9'></td>";

          if (value.is_mcc == "1") {
            if (value.is_mcc == "1" && Prev_Is_MCC == "0") {
              TableHTML += "<tr>";
              TableHTML +=
                "<td colspan='9' class='text-center'>Quality Entry for Bottle Samples</td>";
              TableHTML += "</tr>";
            }

            TableHTML += "<tr>";
            TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
            TableHTML += "<td>";
            TableHTML += "<label class='custom-control custom-checkbox '>";
            TableHTML +=
              "<input type='checkbox' class='custom-control-input select-item checkbox' id='txtChk" +
              value.entry_id +
              "' value='" +
              value.entry_id +
              "'";
            TableHTML +=
              "style='vertical-align:sub; text-align: center;' checked disabled>";
            TableHTML +=
              "<span class='custom-control-label text-dark'></span></label></td>";
            TableHTML += "<td>" + value.sample_no + "</td>";

            if (Is_ManualQuality == 1) {
              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtFat" +
                value.entry_id +
                "' value='" +
                value.fat +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSNF" +
                value.entry_id +
                "' value='" +
                value.snf +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtProtein" +
                value.entry_id +
                "' value='" +
                value.protein +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Protein.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAsh" +
                value.entry_id +
                "' value='" +
                value.ash +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSodium" +
                value.entry_id +
                "' value='" +
                value.sodium +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAdulteration" +
                value.entry_id +
                "' value='" +
                value.adulteration +
                "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";
            } else {
              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtFat" +
                value.entry_id +
                "' value='" +
                value.fat +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSNF" +
                value.entry_id +
                "' value='" +
                value.snf +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtProtein" +
                value.entry_id +
                "' value='" +
                value.protein +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Protein.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAsh" +
                value.entry_id +
                "' value='" +
                value.ash +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtSodium" +
                value.entry_id +
                "' value='" +
                value.sodium +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";

              TableHTML += "<td>";
              TableHTML += "<div class='form-group'>";
              TableHTML +=
                "<input type='text' id='txtAdulteration" +
                value.entry_id +
                "' value='" +
                value.adulteration +
                "' class='form-control' onchange='ClearInvalidState(this);' >";
              TableHTML +=
                "<div class='invalid-feedback'>Invalid Sodium.</div>";
              TableHTML += "</div>";
              TableHTML += "</td>";
            }

            TableHTML +=
              "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

            TableHTML +=
              '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Data" onclick=\'SaveEntryAfterGetData("' +
              value.entry_id +
              '");\'><i class="fa fa-save"></i></a>';

            TableHTML += "</td>";
            TableHTML += "</tr>";
          }
          Prev_Is_MCC = value.is_mcc;
        });
      }
      if (VehicleType == "BulkSupplier") {
        $.each(res, function (data, value) {
          TableHTML += "<tr>";
          TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
          if (value.is_mcc == 0) {
            TableHTML += "<td>";
            TableHTML += "<label class='custom-control custom-checkbox '>";
            TableHTML +=
              "<input type='checkbox' class='custom-control-input select-item checkbox' id='txtChk" +
              value.entry_id +
              "' value='" +
              value.entry_id +
              "'";
            // TableHTML +=
            //   "style='vertical-align:sub; text-align: center;' checked>";

            if (
              value.milkstatus_id == "C016001" ||
              value.milkstatus_id == "" ||
              value.milkstatus_id == null ||
              value.milkstatus_id == undefined
            ) {
              TableHTML +=
                "style='vertical-align:sub; text-align: center;' checked onclick='confirmCheckboxToggle(this)'>";
            } else {
              TableHTML +=
                "style='vertical-align:sub; text-align: center;'  onclick='confirmCheckboxToggle(this)'>";
            }
            TableHTML +=
              "<span class='custom-control-label text-dark'></span></label></td>";
          }
          if (value.is_mcc == 1) {
            TableHTML += "<td>";
            TableHTML += "<label class='custom-control custom-checkbox '>";
            TableHTML +=
              "<input type='checkbox' class='custom-control-input select-item checkbox' id='txtChk" +
              value.entry_id +
              "' value='" +
              value.entry_id +
              "'";
            TableHTML +=
              "style='vertical-align:sub; text-align: center;' checked disabled>";
            TableHTML +=
              "<span class='custom-control-label text-dark'></span></label></td>";
          }

          TableHTML += "<td>" + value.sample_no + "</td>";

          if (Is_ManualQuality == 1) {
            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtFat" +
              value.entry_id +
              "' value='" +
              value.fat +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSNF" +
              value.entry_id +
              "' value='" +
              value.snf +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtProtein" +
              value.entry_id +
              "' value='" +
              value.protein +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Protein.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAsh" +
              value.entry_id +
              "' value='" +
              value.ash +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSodium" +
              value.entry_id +
              "' value='" +
              value.sodium +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAdulteration" +
              value.entry_id +
              "' value='" +
              value.adulteration +
              "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";
          } else {
            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtFat" +
              value.entry_id +
              "' value='" +
              value.fat +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Fat.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSNF" +
              value.entry_id +
              "' value='" +
              value.snf +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtProtein" +
              value.entry_id +
              "' value='" +
              value.protein +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Protein.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAsh" +
              value.entry_id +
              "' value='" +
              value.ash +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtSodium" +
              value.entry_id +
              "' value='" +
              value.sodium +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";

            TableHTML += "<td>";
            TableHTML += "<div class='form-group'>";
            TableHTML +=
              "<input type='text' id='txtAdulteration" +
              value.entry_id +
              "' value='" +
              value.adulteration +
              "' class='form-control' onchange='ClearInvalidState(this);' >";
            TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
            TableHTML += "</div>";
            TableHTML += "</td>";
          }

          TableHTML +=
            "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Data" onclick=\'SaveEntryAfterGetData("' +
            value.entry_id +
            '");\'><i class="fa fa-save"></i></a>';

          TableHTML += "</td>";
          TableHTML += "</tr>";
        });
      }

      $("#tableEntry").html(TableHTML);

      // SetDataTable("tablequalityentryitems", [8], "Quality Entry");
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}
function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function SaveEntryAfterGetData(Entry_Id) {
  GetMachineData(function (machineData) {
    // Do something with the machine data, then call SaveEntry
    SaveEntry(Entry_Id, machineData);
  });
}

function SaveEntry(Entry_Id, machineData) {
  var MilkCollectionDairy_Id = $("#lblEntryId").html().trim();

  var FAT = "";
  var SNF = "";
  var Protein = "";
  var Ash = "";
  var Sodium = "";
  if ($("#chkForAllowManualQuality").prop("checked")) {
    var FAT = machineData.FAT;
    var SNF = machineData.SNF;
    var Protein = machineData.Protein;
    var Ash = machineData.Ash;
    var Sodium = machineData.Sodium;
    var Adulteration = machineData.Adulteration;
  }
  if (!$("#chkForAllowManualQuality").prop("checked")) {
    var FAT = $("#txtFat" + Entry_Id)
      .val()
      .trim();
    var SNF = $("#txtSNF" + Entry_Id)
      .val()
      .trim();
    var Protein = $("#txtProtein" + Entry_Id)
      .val()
      .trim();
    var Ash = $("#txtAsh" + Entry_Id)
      .val()
      .trim();
    var Sodium = $("#txtSodium" + Entry_Id)
      .val()
      .trim();

    var Adulteration = $("#txtAdulteration" + Entry_Id)
      .val()
      .trim();
  }

  var MilkStatus_Id = "";
  if ($("#txtChk" + Entry_Id).prop("checked")) {
    MilkStatus_Id = "C016001";
  }
  if (!$("#txtChk" + Entry_Id).prop("checked")) {
    MilkStatus_Id = "C016002";
  }

  // // console.log(MilkStatus_Id);
  // return;

  // Start Saving
  Show_Loader();

  // Save
  var APIEndPoint_Save = "SaveQualityEntry";
  var Method_Name_Save = "Update";

  var url = "/Collection/QualityEntry";
  var reqdata = {
    method_name: Method_Name_Save,
    entry_id: Entry_Id,
    milkcollectiondairy_id: MilkCollectionDairy_Id,
    api_end_point: APIEndPoint_Save,

    fat: FAT,
    snf: SNF,
    protein: Protein,
    ash: Ash,
    sodium: Sodium,
    adulteration: Adulteration,
    milkstatus_id: MilkStatus_Id,
  };
  // console.log(reqdata);
  // return;
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
        ShowEntrySuccess("Quality Entry details saved successfully");
        Show_Success_Toastr("Quality Entry details saved successfully");
        $("#lblEntryId").html(MilkCollectionDairy_Id);
        ShowEditEntry();
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Quality Entry details not saved");
    },
  });
}

function GetMachineData(callback) {
  var Method_Name = "Machine3";
  var url = "/Collection/MilkCollectionQuantity";
  var APIEndPoint = "GetMachineData";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result.length > 0) {
        const data = result[0].machine_data;
        const dataArray = data.split(",");

        var machineData = {
          FAT: dataArray[2],
          SNF: dataArray[3],
          Protein: dataArray[4],
          Ash: "", // You might want to get Ash and Sodium from somewhere
          Sodium: "",
          Adulteration: dataArray[5],
        };
      } else {
        var machineData = {
          FAT: "",
          SNF: "",
          Protein: "",
          Ash: "", // You might want to get Ash and Sodium from somewhere
          Sodium: "",
          Adulteration: "",
        };
        Show_Error_Toastr("Error : Machine details not found");
      }
      callback(machineData);
    },
    error: function (res) {
      Show_Error_Toastr("Error : Machine details not found");
    },
  });
}

// $("#chkForAllowManualQuality").on("click", function () {
//   // // Your logic here when the checkbox is clicked
//   if ($(this).prop("checked")) {
//     // Checkbox is checked
//     // console.log("Checkbox is checked");
//     // Add your code here
//   } else {
//     // Checkbox is unchecked
//     // console.log("Checkbox is unchecked");
//     // Add your code here
//   }

//   ShowEditEntry();
// });

function ManualQuality() {
  ShowEditEntry();
}

function OpenRefresh() {
  ShowEditEntry();
}

function confirmCheckboxToggle(checkbox) {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, proceed",
    },
    function (result) {
      if (result == true) {
        if (checkbox.value == "1") {
          checkbox.value = "0";
        }
        if (checkbox.value == "0") {
          checkbox.value = "1";
        }
        // checkbox.checked = !checkbox.checked;
      }
      if (result == false) {
        checkbox.value = checkbox.value;
      }
    }
  );
}
