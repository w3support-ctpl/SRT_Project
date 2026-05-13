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

  // SetDataTable("tableSearch", [13], "SAP Posting");
});

/*  ----    ----    ----    Get SAP Posting data and assign it to the table on Search Page    ----    ----    ----    ----    */
function GetSearchList() {
  ClearDataTable("tableSearch");
  var Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetGainLossEntry";
  var Method_Name = "Get_Confirm";
  var url = "/Collection/GainLossEntry";
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
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      $.each(res, function (data, value) {
        if (value.is_locked == 1) {
          Status = "Approved";
          EditFlag = false;
        } else if (value.is_locked == 0) {
          Status = "Pending";
          EditFlag = true;
        } else {
          Status = "Rejected";
          EditFlag = false;
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + value.end_time + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.vehicletype_name + "</td>";

        TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        if (EditFlag) {
          TableHTML +=
            '<a href="javascript:void(0)" id="btn' +
            value.entry_id +
            '" class="btn btn-icon py-0" onclick=\'ShowEntry("' +
            value.batch_id +
            '", "' +
            value.entry_id +
            '", "' +
            value.milkcollectiondairy_id +
            '", "' +
            value.vehicletype_id +
            '", "' +
            value.tripdocument_id +
            '", "' +
            value.vehicle_no +
            '", "' +
            value.route_name +
            '", "' +
            value.collectionshift_name +
            '", "' +
            value.end_time +
            '", "' +
            value.weight +
            '", "' +
            value.vehicletype_name +
            '", "' +
            value.is_locked +
            '");\'><i class="fa fa-pencil"></i></a>';
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [8], "Collection Approval");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function ShowEntry(
  _BatchId,
  _EntryId,
  _MilkCollectionDairyId,
  _VehicleTypeId,
  _TripDocumentId,
  _VehicleNo,
  _RouteName,
  _CollectionShiftName,
  _EndTime,
  _Weight,
  _VehicleTypeName,
  _IsLocked
) {
  Batch_Id = _BatchId;
  Entry_Id = _EntryId;
  MilkCollectionDairy_Id = _MilkCollectionDairyId;
  VehicleType_Id = _VehicleTypeId;
  TripDocument_Id = _TripDocumentId;
  Vehicle_No = _VehicleNo;
  Route_Name = _RouteName;
  CollectionShift_Name = _CollectionShiftName;
  End_Time = _EndTime;
  Weight = _Weight;
  VehicleType_Name = _VehicleTypeName;
  Is_Locked = _IsLocked;

  ShowContentDiv("Collection", "GainLossEntryEdit", "", function () {
    //   $("#btn_Save").hide();
    //   $("#ddlEntryApprovalStatus").select2();
    GetGRNList(MilkCollectionDairy_Id);

    $("#lblEntryId").html(MilkCollectionDairy_Id);

    //   GetQuantityList(MilkCollectionDairy_Id);
    //   GetQualityList(MilkCollectionDairy_Id);
    //   GetMCCCommissionList(MilkCollectionDairy_Id);

    //   $("#ddlEntryApprovalStatus").on("change", function () {
    //     var selectedValue = $(this).val();
    //     var selectedWord = "";
    //     if (selectedValue == 1) {
    //       selectedWord = "Yes, Approve it!";
    //     } else if (selectedValue == 0) {
    //       selectedWord = "Yes, Keep it Pending!";
    //     } else {
    //       selectedWord = "Yes, Reject it!";
    //     }
    //     //var selectedWord = $(this).children("option:selected").text();

    //     if (selectedValue != "") {
    //       //if (selectedValue != 1) {
    //       swal({
    //         title: "Are you sure?",
    //         text: "You won't be able to revert this!",
    //         icon: "question",
    //         type: "warning",
    //         showCancelButton: true,
    //         confirmButtonText: selectedWord,
    //       });
    //       //}

    //       if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
    //         $("#btn_Save").show();
    //       } else {
    //         $("#btn_Save").hide();
    //       }
    //     }
    //   });

    //   GetMaster(
    //     "ddlEntryApprovalStatus",
    //     "Select Approval Status",
    //     "GetApprovedStatus",
    //     Is_Locked,
    //     ""
    //   );
    $("#txtEntryVehicleNo").val(Vehicle_No);
    $("#txtEntryRouteName").val(Route_Name);
    $("#txtEntryShift").val(CollectionShift_Name);
    $("#txtEntryTime").val(End_Time);
    $("#txtEntryNetWeight").val(Weight);
    $("#txtEntryVehicleType").val(VehicleType_Name);
  });
}

function GetGRNList(MilkCollectionDairy_Id) {
  var Method_Name = "Get_GRN_Data_V1";
  var APIEndPoint = "GetGainLossEntry";
  var url = "/Collection/GainLossEntry";

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

      // Fill data in table
      var TableHTML = "";
      $.each(res, function (data, value) {
        //EditFlag = DeleteFlag = value.is_locked;
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.cellno + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";

        TableHTML += "<td>" + value.agent_ltr + "</td>";
        TableHTML += "<td>" + value.agent_fat + "</td>";
        TableHTML += "<td>" + value.agent_snf + "</td>";

        TableHTML += "<td>" + value.chemist_ltr + "</td>";
        TableHTML += "<td>" + value.chemist_fat + "</td>";
        TableHTML += "<td>" + value.chemist_snf + "</td>";

        TableHTML += "<td>" + value.lab_fat + "</td>";
        TableHTML += "<td>" + value.lab_snf + "</td>";

        TableHTML += "<td>" + value.composite_ltr + "</td>";
        TableHTML += "<td>" + value.composite_fat + "</td>";
        TableHTML += "<td>" + value.composite_snf + "</td>";

        // TableHTML += "<td></td>";
        // TableHTML += "<td></td>";
        // TableHTML += "<td></td>";
        if (value.milkstatus_id == "C016002") {
          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtLtr" +
            value.chemistcollection_id +
            "' value='" +
            value.final_ltr +
            "' class='form-control' onchange='ClearInvalidState(this);'>";
          TableHTML += "<div class='invalid-feedback'>Invalid Ltr.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtFat" +
            value.chemistcollection_id +
            "' value='" +
            value.final_fat +
            "' class='form-control' onchange='ClearInvalidState(this);'>";
          TableHTML += "<div class='invalid-feedback'>Invalid FAT.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtSNF" +
            value.chemistcollection_id +
            "' value='" +
            value.final_snf +
            "' class='form-control' onchange='ClearInvalidState(this);'>";
          TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtProtein" +
            value.chemistcollection_id +
            "' value='" +
            value.composite_protein +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
          TableHTML += "<div class='invalid-feedback'>Invalid Protein.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtAsh" +
            value.chemistcollection_id +
            "' value='" +
            value.composite_ash +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
          TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtSodium" +
            value.chemistcollection_id +
            "' value='" +
            value.composite_sodium +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
          TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";
        } else {
          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtLtr" +
            value.chemistcollection_id +
            "' value='" +
            value.final_ltr +
            "' class='form-control' onchange='ClearInvalidState(this);' >";
          TableHTML += "<div class='invalid-feedback'>Invalid Ltr.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtFat" +
            value.chemistcollection_id +
            "' value='" +
            value.final_fat +
            "' class='form-control' onchange='ClearInvalidState(this);' >";
          TableHTML += "<div class='invalid-feedback'>Invalid FAT.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtSNF" +
            value.chemistcollection_id +
            "' value='" +
            value.final_snf +
            "' class='form-control' onchange='ClearInvalidState(this);' >";
          TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtProtein" +
            value.chemistcollection_id +
            "' value='" +
            value.composite_protein +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
          TableHTML += "<div class='invalid-feedback'>Invalid Protein.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtAsh" +
            value.chemistcollection_id +
            "' value='" +
            value.composite_ash +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
          TableHTML += "<div class='invalid-feedback'>Invalid Ash.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";

          TableHTML += "<td>";
          TableHTML += "<div class='form-group'>";
          TableHTML +=
            "<input type='text' id='txtSodium" +
            value.chemistcollection_id +
            "' value='" +
            value.composite_sodium +
            "' class='form-control' onchange='ClearInvalidState(this);' disabled>";
          TableHTML += "<div class='invalid-feedback'>Invalid Sodium.</div>";
          TableHTML += "</div>";
          TableHTML += "</td>";
        }

        TableHTML += "<td hidden></td>";

        TableHTML += "<td hidden>" + value.cellno + "</td>";
        TableHTML += "<td hidden>" + value.chemistcollection_id + "</td>";
        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "<td hidden>" + value.milktype_id + "</td>";

        TableHTML += "<td hidden>" + value.composite_protein + "</td>";
        TableHTML += "<td hidden>" + value.composite_ash + "</td>";
        TableHTML += "<td hidden>" + value.composite_sodium + "</td>";

        TableHTML += "<td hidden>" + value.final_ltr + "</td>";
        TableHTML += "<td hidden>" + value.final_fat + "</td>";
        TableHTML += "<td hidden>" + value.final_snf + "</td>";

        if (value.milkstatus_id == "C016002") {
          if (value.sour_compartment_grn_flag == "1") {
            TableHTML += '<td style="width: 20px;">';
            TableHTML +=
              '<label class="custom-control custom-checkbox" for="checkbox' +
              value.chemistcollection_id +
              '">';
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox"  value="' +
              value.chemistcollection_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" id="checkbox' +
              value.chemistcollection_id +
              '" checked>';
            TableHTML +=
              '<span class="custom-control-label text-dark"></span></label></td>';
          } else {
            TableHTML += '<td style="width: 20px;">';
            TableHTML +=
              '<label class="custom-control custom-checkbox" for="checkbox' +
              value.chemistcollection_id +
              '">';
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox"  value="' +
              value.chemistcollection_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" id="checkbox' +
              value.chemistcollection_id +
              '">';
            TableHTML +=
              '<span class="custom-control-label text-dark"></span></label></td>';
          }
        } else {
          TableHTML += "<td></td>";
        }

        if (value.milkstatus_id == "C016002") {
          if (value.sour_compartment_adjustment_flag == "1") {
            TableHTML += '<td style="width: 20px;">';
            TableHTML +=
              '<label class="custom-control custom-radio" for="radio' +
              value.chemistcollection_id +
              '">';
            TableHTML +=
              '<input type="radio" class="custom-control-input" name="example-radios' +
              value.cellno +
              '" value="' +
              value.chemistcollection_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" id="radio' +
              value.chemistcollection_id +
              '" checked>';
            TableHTML +=
              '<span class="custom-control-label text-dark"></span></label></td>';
          } else {
            TableHTML += '<td style="width: 20px;">';
            TableHTML +=
              '<label class="custom-control custom-radio" for="radio' +
              value.chemistcollection_id +
              '">';
            TableHTML +=
              '<input type="radio" class="custom-control-input" name="example-radios' +
              value.cellno +
              '" value="' +
              value.chemistcollection_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" id="radio' +
              value.chemistcollection_id +
              '">';
            TableHTML +=
              '<span class="custom-control-label text-dark"></span></label></td>';
          }
        } else {
          TableHTML += "<td></td>";
        }

        if (value.milkstatus_id == "C016002") {
          TableHTML += "<td hidden>1</td>";
        } else {
          TableHTML += "<td hidden>0</td>";
        }

        TableHTML += "</tr>";
      });
      ClearDataTable("tableMilkGRNList");
      $("#tableEntryGRN").html(TableHTML);
      //   SetDataTable("tableMilkGRNList", [18], "Milk Quantity at Dairy");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  return;
}

function SavePost() {
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
        // Validation code

        var MilkCollectionDairy_Id = $("#lblEntryId").html();

        var GRNData = "<MCC_GRN>";

        $("#tableMilkGRNList tbody tr").each(function () {
        
          GRNData += "<GRN>";

          GRNData +=
            "<Cell_No>" + $(this).find("td:eq(22)").text() + "</Cell_No>";

          GRNData +=
            "<Chemistcollection_Id>" +
            $(this).find("td:eq(23)").text() +
            "</Chemistcollection_Id>";

          GRNData +=
            "<MCC_Id>" + $(this).find("td:eq(24)").text() + "</MCC_Id>";

          GRNData +=
            "<MilkType_Id>" +
            $(this).find("td:eq(25)").text() +
            "</MilkType_Id>";

          //   GRNData +=
          //   "<Weight>" + $(this).find("td:eq(4)").text() + "</Weight>";
          GRNData +=
            "<Liters>" +
            $(this).find("td:eq(15) input").val().trim() +
            "</Liters>";
          GRNData +=
            "<FAT>" + $(this).find("td:eq(16) input").val().trim() + "</FAT>";
          GRNData +=
            "<SNF>" + $(this).find("td:eq(17) input").val().trim() + "</SNF>";
          GRNData +=
            "<FatKG_Agent>" +
            (
              (($(this).find("td:eq(4)").text() / 0.97) * // agent milk in kg
                $(this).find("td:eq(5)").text()) /
              100
            ).toFixed(3) +
            "</FatKG_Agent>";
          GRNData +=
            "<FatSNF_Agent>" +
            (
              (($(this).find("td:eq(4)").text() / 0.97) * // agent milk in kg
                $(this).find("td:eq(6)").text()) /
              100
            ).toFixed(3) +
            "</FatSNF_Agent>";

          GRNData +=
            "<Protein>" +
            $(this).find("td:eq(18) input").val().trim() +
            "</Protein>";

          GRNData +=
            "<Ash>" + $(this).find("td:eq(19) input").val().trim() + "</Ash>";

          GRNData +=
            "<Sodium>" +
            $(this).find("td:eq(20) input").val().trim() +
            "</Sodium>";

          var isChecked = $(this)
            .find("td:eq(32) input[type='checkbox']")
            .is(":checked");
          GRNData += "<Is_GRN>" + (isChecked ? "1" : "0") + "</Is_GRN>";

          // For the radio button
          var isRadioChecked = $(this)
            .find("td:eq(33) input[type='radio']")
            .is(":checked");
          GRNData +=
            "<Is_Adjustment>" +
            (isRadioChecked ? "1" : "0") +
            "</Is_Adjustment>";

          GRNData +=
            "<Is_Sour>" + $(this).find("td:eq(34)").text() + "</Is_Sour>";

          GRNData += "</GRN>";
        });

        GRNData += "</MCC_GRN>";

        // //Post it
        var APIEndPoint = "SaveGainLossEntry";
        var Method_Name = "Update";
        var url = "/Collection/GainLossEntry";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          milkcollectiondairy_id: MilkCollectionDairy_Id,
          mcc_commission: GRNData,
        };

        // //Save
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
              Show_Success_Toastr("Gain Loss Entry Successfully");
              CloseEntry();
            } else {
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Show_Error_Toastr("Error : Gain Loss Entry Not Approved");
          },
        });
      }
    }
  );
}

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

//   function GetQuantityList(MilkCollectionDairy_Id) {
//     // console.log(MilkCollectionDairy_Id);
//     $("#chkEntryQuantity").prop("checked", false);
//     var Method_Name = "Get_Quantity";
//     var APIEndPoint = "GetMilkCollection";
//     var url = "/Collection/MilkCollection";

//     var reqdata = {
//       method_name: Method_Name,
//       milkcollectiondairy_id: MilkCollectionDairy_Id,
//       api_end_point: APIEndPoint,
//     };
//     $.ajax({
//       type: "POST",
//       url: url,
//       contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//       data: reqdata,
//       success: function (result) {
//         var res = JSON.parse(result);
//         // console.log(res);

//         // Fill data in table
//         var TableHTML = "";
//         $.each(res, function (data, value) {
//           //EditFlag = DeleteFlag = value.is_locked;
//           TableHTML += "<tr>";
//           TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
//           TableHTML += "<td>" + value.batch_id + "</td>";
//           TableHTML += "<td>" + value.milktype_name + "</td>";
//           TableHTML += "<td>" + value.milkstatus_name + "</td>";
//           TableHTML += "<td>" + value.weight + "</td>";
//           TableHTML += "<td>" + value.liters + "</td>";
//           TableHTML += "<td>" + value.start_time + "</td>";
//           TableHTML += "<td hidden></td>";
//           TableHTML += "</tr>";
//         });
//         ClearDataTable("tableMilkQuantityList");
//         $("#tableEntryQuantity").html(TableHTML);
//         SetDataTable("tableMilkQuantityList", [7], "Milk Quantity at Dairy");

//         if (
//           res.some(
//             (item) =>
//               item.weight == null ||
//               item.weight === "" ||
//               item.weight === undefined ||
//               item.weight <= 0
//           ) &&
//           res.some(
//             (item) =>
//               item.liters == null ||
//               item.liters === "" ||
//               item.liters === undefined ||
//               item.liters <= 0
//           )
//         ) {
//           $("#chkEntryQuantity").prop("checked", true);
//         } else {
//           $("#chkEntryQuantity").prop("checked", false);
//         }
//       },
//       error: function () {
//         Show_Error_Toastr(
//           "Error in fetching details from server.",
//           res[0].result_description
//         );
//       },
//     });
//     return;
//   }

//   function GetQualityList(MilkCollectionDairy_Id) {
//     // console.log(MilkCollectionDairy_Id);
//     $("#chkEntryQuality").prop("checked", false);
//     var Method_Name = "Get_Quality";
//     var APIEndPoint = "GetMilkCollection";
//     var url = "/Collection/MilkCollection";

//     var reqdata = {
//       method_name: Method_Name,
//       milkcollectiondairy_id: MilkCollectionDairy_Id,
//       api_end_point: APIEndPoint,
//     };
//     $.ajax({
//       type: "POST",
//       url: url,
//       contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//       data: reqdata,
//       success: function (result) {
//         var res = JSON.parse(result);
//         // console.log(res);

//         // Fill data in table
//         var TableHTML = "";
//         $.each(res, function (data, value) {
//           //EditFlag = DeleteFlag = value.is_locked;
//           TableHTML += "<tr>";
//           TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
//           // TableHTML += "<td>" + value.batch_id + "</td>";
//           TableHTML += "<td>" + value.sample_no + "</td>";
//           TableHTML += "<td>" + value.milkstatus_name + "</td>";
//           TableHTML += "<td>" + value.fat + "</td>";
//           TableHTML += "<td>" + value.snf + "</td>";
//           TableHTML += "<td hidden></td>";
//           TableHTML += "</tr>";
//         });
//         ClearDataTable("tableMilkQualityList");
//         $("#tableEntryQuality").html(TableHTML);
//         SetDataTable("tableMilkQualityList", [5], "Milk Quantity at Dairy");

//         if (
//           res.some(
//             (item) =>
//               item.fat == null ||
//               item.fat === "" ||
//               item.fat === undefined ||
//               item.fat <= 0
//           ) &&
//           res.some(
//             (item) =>
//               item.snf == null ||
//               item.snf === "" ||
//               item.snf === undefined ||
//               item.snf <= 0
//           )
//         ) {
//           $("#chkEntryQuality").prop("checked", true);
//         } else {
//           $("#chkEntryQuality").prop("checked", false);
//         }
//       },
//       error: function () {
//         Show_Error_Toastr(
//           "Error in fetching details from server.",
//           res[0].result_description
//         );
//       },
//     });
//     return;
//   }

//   function GetMCCCommissionList(MilkCollectionDairy_Id) {
//     // // console.log(MilkCollectionDairy_Id);
//     var Method_Name = "Get_MCCCommission";
//     var APIEndPoint = "GetMilkCollection";
//     var url = "/Collection/MilkCollection";

//     var reqdata = {
//       method_name: Method_Name,
//       milkcollectiondairy_id: MilkCollectionDairy_Id,
//       api_end_point: APIEndPoint,
//     };
//     $.ajax({
//       type: "POST",
//       url: url,
//       contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//       data: reqdata,
//       success: function (result) {
//         var res = JSON.parse(result);
//         // console.log(res);
//         // Fill data in table
//         var TableHTML = "";
//         $.each(res, function (data, value) {
//           //EditFlag = DeleteFlag = value.is_locked;
//           TableHTML += "<tr>";
//           TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
//           TableHTML += "<td >" + value.mcc_name + "</td>";
//           TableHTML += "<td>" + value.milktype_name + "</td>";
//           TableHTML += "<td>" + value.milkstatus_name + "</td>";
//           TableHTML += "<td>" + value.weight + "</td>";
//           TableHTML += "<td>" + value.liters + "</td>";
//           TableHTML += "<td>" + value.fat + "</td>";
//           TableHTML += "<td>" + value.snf + "</td>";
//           TableHTML += "<td>" + value.baserate + "</td>";
//           TableHTML += "<td>" + value.servicecharge + "</td>";
//           TableHTML += "<td>" + value.amount + "</td>";

//           TableHTML += "<td hidden>" + value.mcc_id + "</td>";
//           TableHTML += "<td hidden>" + value.milktype_id + "</td>";
//           TableHTML += "<td hidden>" + value.milkstatus_id + "</td>";

//           TableHTML += "<td hidden></td>";
//           TableHTML += "</tr>";
//         });
//         ClearDataTable("tableMCCCommissionList");
//         $("#tableEntryMCCCommission").html(TableHTML);
//         SetDataTable("tableMCCCommissionList", [13], "Milk Quantity at Dairy");
//       },
//       error: function () {
//         Show_Error_Toastr(
//           "Error in fetching details from server.",
//           res[0].result_description
//         );
//       },
//     });
//     return;
//   }
