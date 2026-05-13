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
  var APIEndPoint = "GetCollectionApproval";
  var Method_Name = "Get_Confirm";
  var url = "/Collection/CollectionApproval";
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
            '" class="btn btn-icon py-0" onclick=\'ShowEntry("Add", "' +
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
        } else {
          TableHTML +=
            '<a href="javascript:void(0)" id="btn' +
            value.entry_id +
            '" class="btn btn-icon py-0" onclick=\'ShowEntry("Edit", "' +
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
            '");\'><i class="fa fa-eye"></i></a>';
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
  _Action,
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
  Action = _Action;
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

  ShowContentDiv("Collection", "CollectionApprovalEdit", "", function () {
    $("#btn_Reverse").hide();
    $("#btn_Save").hide();
    $("#ddlEntryApprovalStatus").select2();

    $("#divQuantityList").hide();
    $("#divQualityList").hide();
    $("#divGRN").hide();
    $("#divDetails").hide();
    if (Action == "Edit") {
      GetReverse(MilkCollectionDairy_Id);
      $("#divDetails").hide();
    } else {
      $("#divDetails").show();
    }

    if (VehicleType_Name == "Truck" || VehicleType_Name == "BulkSupplier") {
      $("#divQuantityList").show();
      $("#divQualityList").show();
      GetQuantityList(MilkCollectionDairy_Id);
      GetQualityList(MilkCollectionDairy_Id);
    }
    if (VehicleType_Name == "Tanker") {
      $("#divGRN").show();
      GetGRNList(MilkCollectionDairy_Id);
    }
    if (VehicleType_Name == "Truck" || VehicleType_Name == "Tanker") {
      $("#txtRouteName").text("Route");
    }
    if (VehicleType_Name == "BulkSupplier") {
      $("#txtRouteName").text("MCC");
    }

    $("#ddlEntryApprovalStatus").on("change", function () {
      if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
        $("#btn_Save").show();
      } else {
        $("#btn_Save").hide();
      }
    });

    GetMaster(
      "ddlEntryApprovalStatus",
      "Select Approval Status",
      "GetApprovedStatus",
      Is_Locked,
      ""
    );
    $("#lblAction").html(Action);
    $("#txtEntryVehicleNo").val(Vehicle_No);
    $("#txtEntryRouteName").val(Route_Name);
    $("#txtEntryShift").val(CollectionShift_Name);
    $("#txtEntryTime").val(End_Time);
    $("#txtEntryNetWeight").val(Weight);
    $("#txtEntryVehicleType").val(VehicleType_Name);
  });
}

function SavePost() {
  var VehicleType_Name = $("#txtEntryVehicleType").val();

  if (VehicleType_Name == "Truck") {
    var APIEndPoint_1 = "GetCollectionApproval";
    var Method_Name_1 = "Check_Data_Truck";
    var url_1 = "/Collection/CollectionApproval";

    var reqdata_1 = {
      method_name: Method_Name_1,
      api_end_point: APIEndPoint_1,
      milkcollectiondairy_id: MilkCollectionDairy_Id,
      tripdocument_id: TripDocument_Id,
    };

    $.ajax({
      type: "POST",
      url: url_1,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata_1,
      success: function (result) {
        // debugger;
        var res = JSON.parse(result);

        var flags = res[0].checkavailableflag.split(" ").map(Number);

        if (flags.includes(0)) {
          var errorMsg = "Collection Approval can't be started as - ";

          if (flags[0] == 0) {
            errorMsg += "Trip document is not entered. ";
          }

          if (flags[1] != flags[2]) {
            errorMsg +=
              "There is mismatch between collection in Manage Trip and Milk Receipt. ";
          }

          if (flags[1] != flags[3]) {
            errorMsg += "Agent data is not entered in Manage Trip. ";
          }

          ShowEntryError(errorMsg);

          return;
        } else {
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
                var Approval_Status = $("#ddlEntryApprovalStatus").val();
                var Approval_Remarks = $("#txtEntryRemark").val();

                if (
                  VehicleType_Name == "Truck" ||
                  VehicleType_Name == "BulkSupplier"
                ) {
                  var Approval_Quality = 0;
                  var Approval_Quantity = 0;

                  if ($("#chkEntryQuantity").prop("checked")) {
                    Approval_Quantity = 1;
                  }

                  if ($("#chkEntryQuality").prop("checked")) {
                    Approval_Quality = 1;
                  }

                  if (Approval_Quantity == "1") {
                    ShowEntryError("Quantity is not maintained");
                    return;
                  }
                  if (Approval_Quality == "1") {
                    ShowEntryError("Quality is not maintained");
                    return;
                  }
                }

                var IsValid = 1;

                if (Approval_Status == "") {
                  IsValid = 0;
                  $("#ddlEntryApprovalStatus").addClass(
                    "is-invalid state-invalid"
                  );
                }

                if (IsValid == 0) {
                  ShowEntryError("Invalid Input(s). Can't be saved.");
                  return;
                }
                Show_Loader();
                var MCCCommissionData = "";

                //Post it
                var APIEndPoint = "SaveCollectionApproval";
                var Method_Name = "Locked";
                var url = "/Collection/CollectionApproval";
                var reqdata = {
                  method_name: Method_Name,
                  api_end_point: APIEndPoint,

                  batch_id: Batch_Id,
                  entry_id: Entry_Id,
                  milkcollectiondairy_id: MilkCollectionDairy_Id,
                  tripdocument_id: TripDocument_Id,
                  vehicletype_id: VehicleType_Id,

                  approvalstatus_id: Approval_Status,
                  approval_remarks: Approval_Remarks,
                  mcc_commission: MCCCommissionData,
                };

                //Save
                $.ajax({
                  type: "POST",
                  url: url,
                  contentType:
                    "application/x-www-form-urlencoded; charset=UTF-8",
                  data: reqdata,
                  success: function (res) {
                    var result = JSON.parse(res);
                    if (result[0].result_id == 1) {
                      Hide_Loader();
                      Show_Success_Toastr("Collection Approved Successfully");
                      CloseEntry();
                    } else {
                      Hide_Loader();
                      Show_Error_Toastr(
                        "Error : " + result[0].result_description
                      );
                    }
                  },
                  error: function () {
                    Hide_Loader();
                    Show_Error_Toastr("Error : Collection Not Approved");
                  },
                });
              }
            }
          );
        }
      },
      error: function () {
        ShowEntryError("Error occurred during validation.");
      },
    });
  }
  if (VehicleType_Name == "Tanker") {
    var APIEndPoint_2 = "GetCollectionApproval";
    var Method_Name_2 = "Check_Data_Tanker";
    var url_2 = "/Collection/CollectionApproval";

    var reqdata_2 = {
      method_name: Method_Name_2,
      api_end_point: APIEndPoint_2,
      milkcollectiondairy_id: MilkCollectionDairy_Id,
      tripdocument_id: TripDocument_Id,
    };

    $.ajax({
      type: "POST",
      url: url_2,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata_2,
      success: function (result) {
        var res = JSON.parse(result);

        var flags = res[0].checkavailableflag.split(" ").map(Number);

        if (flags.includes(0)) {
          var errorMsg = "Milk Collection can't be approved as -";

          if (flags[0] == 0) {
            errorMsg += "Trip document is not entered. ";
          }

          if (flags[1] != flags[2]) {
            errorMsg += "Agent data is not entered in Manage Trip. ";
          }

          if (flags[1] != flags[3] || flags[2] != flags[3]) {
            errorMsg += "Gain Loss data is not entered for this trip. ";
          }

          ShowEntryError(errorMsg);

          return;
        } else {
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
                var Approval_Status = $("#ddlEntryApprovalStatus").val();
                var Approval_Remarks = $("#txtEntryRemark").val();

                if (
                  VehicleType_Name == "Truck" ||
                  VehicleType_Name == "BulkSupplier"
                ) {
                  var Approval_Quality = 0;
                  var Approval_Quantity = 0;

                  if ($("#chkEntryQuantity").prop("checked")) {
                    Approval_Quantity = 1;
                  }

                  if ($("#chkEntryQuality").prop("checked")) {
                    Approval_Quality = 1;
                  }

                  if (Approval_Quantity == "1") {
                    ShowEntryError("Quantity is not maintained");
                    return;
                  }
                  if (Approval_Quality == "1") {
                    ShowEntryError("Quality is not maintained");
                    return;
                  }
                }

                var IsValid = 1;

                if (Approval_Status == "") {
                  IsValid = 0;
                  $("#ddlEntryApprovalStatus").addClass(
                    "is-invalid state-invalid"
                  );
                }

                if (IsValid == 0) {
                  ShowEntryError("Invalid Input(s). Can't be saved.");
                  return;
                }
                Show_Loader();
                var MCCCommissionData = "";

                //Post it
                var APIEndPoint = "SaveCollectionApproval";
                var Method_Name = "Locked";
                var url = "/Collection/CollectionApproval";
                var reqdata = {
                  method_name: Method_Name,
                  api_end_point: APIEndPoint,

                  batch_id: Batch_Id,
                  entry_id: Entry_Id,
                  milkcollectiondairy_id: MilkCollectionDairy_Id,
                  tripdocument_id: TripDocument_Id,
                  vehicletype_id: VehicleType_Id,

                  approvalstatus_id: Approval_Status,
                  approval_remarks: Approval_Remarks,
                  mcc_commission: MCCCommissionData,
                };

                //Save
                $.ajax({
                  type: "POST",
                  url: url,
                  contentType:
                    "application/x-www-form-urlencoded; charset=UTF-8",
                  data: reqdata,
                  success: function (res) {
                    var result = JSON.parse(res);
                    if (result[0].result_id == 1) {
                      Hide_Loader();
                      Show_Success_Toastr("Collection Approved Successfully");
                      CloseEntry();
                    } else {
                      Hide_Loader();
                      Show_Error_Toastr(
                        "Error : " + result[0].result_description
                      );
                    }
                  },
                  error: function () {
                    Hide_Loader();
                    Show_Error_Toastr("Error : Collection Not Approved");
                  },
                });
              }
            }
          );
        }
      },
      error: function () {
        ShowEntryError("Error occurred during validation.");
      },
    });
  }
  if (VehicleType_Name == "BulkSupplier") {
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
          var Approval_Status = $("#ddlEntryApprovalStatus").val();
          var Approval_Remarks = $("#txtEntryRemark").val();

          if (
            VehicleType_Name == "Truck" ||
            VehicleType_Name == "BulkSupplier"
          ) {
            var Approval_Quality = 0;
            var Approval_Quantity = 0;

            if ($("#chkEntryQuantity").prop("checked")) {
              Approval_Quantity = 1;
            }

            if ($("#chkEntryQuality").prop("checked")) {
              Approval_Quality = 1;
            }

            if (Approval_Quantity == "1") {
              ShowEntryError("Quantity is not maintained");
              return;
            }
            if (Approval_Quality == "1") {
              ShowEntryError("Quality is not maintained");
              return;
            }
          }

          var IsValid = 1;

          if (Approval_Status == "") {
            IsValid = 0;
            $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
          }

          if (IsValid == 0) {
            ShowEntryError("Invalid Input(s). Can't be saved.");
            return;
          }
          Show_Loader();
          var MCCCommissionData = "";

          //Post it
          var APIEndPoint = "SaveCollectionApproval";
          var Method_Name = "Locked";
          var url = "/Collection/CollectionApproval";
          var reqdata = {
            method_name: Method_Name,
            api_end_point: APIEndPoint,

            batch_id: Batch_Id,
            entry_id: Entry_Id,
            milkcollectiondairy_id: MilkCollectionDairy_Id,
            tripdocument_id: TripDocument_Id,
            vehicletype_id: VehicleType_Id,

            approvalstatus_id: Approval_Status,
            approval_remarks: Approval_Remarks,
            mcc_commission: MCCCommissionData,
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
                Hide_Loader();
                Show_Success_Toastr("Collection Approved Successfully");
                CloseEntry();
              } else {
                Hide_Loader();
                Show_Error_Toastr("Error : " + result[0].result_description);
              }
            },
            error: function () {
              Hide_Loader();
              Show_Error_Toastr("Error : Collection Not Approved");
            },
          });
        }
      }
    );
  }
}

// function SavePost() {
//   swal(
//     {
//       title: "Are you sure?",
//       text: "You won't be able to revert this!",
//       icon: "question",
//       type: "warning",
//       showCancelButton: true,
//       confirmButtonText: "Yes, approve it!",
//     },
//     function (result) {
//       if (result == true) {
//         // Validation code
//         var Approval_Status = $("#ddlEntryApprovalStatus").val();
//         var Approval_Remarks = $("#txtEntryRemark").val();

//         if (VehicleType_Name == "Truck" || VehicleType_Name == "BulkSupplier") {
//           var Approval_Quality = 0;
//           var Approval_Quantity = 0;

//           if ($("#chkEntryQuantity").prop("checked")) {
//             Approval_Quantity = 1;
//           }

//           if ($("#chkEntryQuality").prop("checked")) {
//             Approval_Quality = 1;
//           }

//           if (Approval_Quantity == "1") {
//             ShowEntryError("Quantity is not maintained");
//             return;
//           }
//           if (Approval_Quality == "1") {
//             ShowEntryError("Quality is not maintained");
//             return;
//           }
//         }

//         var IsValid = 1;

//         if (Approval_Status == "") {
//           IsValid = 0;
//           $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
//         }

//         if (IsValid == 0) {
//           ShowEntryError("Invalid Input(s). Can't be saved.");
//           return;
//         }

//         var MCCCommissionData = "";

//         //Post it
//         var APIEndPoint = "SaveCollectionApproval";
//         var Method_Name = "Locked";
//         var url = "/Collection/CollectionApproval";
//         var reqdata = {
//           method_name: Method_Name,
//           api_end_point: APIEndPoint,

//           batch_id: Batch_Id,
//           entry_id: Entry_Id,
//           milkcollectiondairy_id: MilkCollectionDairy_Id,
//           tripdocument_id: TripDocument_Id,
//           vehicletype_id: VehicleType_Id,

//           approvalstatus_id: Approval_Status,
//           approval_remarks: Approval_Remarks,
//           mcc_commission: MCCCommissionData,
//         };

//         //Save
//         $.ajax({
//           type: "POST",
//           url: url,
//           contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//           data: reqdata,
//           success: function (res) {
//             var result = JSON.parse(res);
//             if (result[0].result_id == 1) {
//               Show_Success_Toastr("Collection Approved Successfully");
//               CloseEntry();
//             } else {
//               Show_Error_Toastr("Error : " + result[0].result_description);
//             }
//           },
//           error: function () {
//             Show_Error_Toastr("Error : Collection Not Approved");
//           },
//         });
//       }
//     }
//   );
// }

function CloseEntry() {
  HideContentDiv();
  GetSearchList();
}

function GetQuantityList(MilkCollectionDairy_Id) {
  $("#chkEntryQuantity").prop("checked", false);
  var Method_Name = "Get_Quantity";
  var APIEndPoint = "GetMilkCollection";
  var url = "/Collection/MilkCollection";

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
        TableHTML += "<td>" + value.batch_id + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.start_time + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableMilkQuantityList");
      $("#tableEntryQuantity").html(TableHTML);
      SetDataTable("tableMilkQuantityList", [7], "Milk Quantity at Dairy");

      if (
        res.some(
          (item) =>
            item.weight == null ||
            item.weight === "" ||
            item.weight === undefined ||
            item.weight <= 0
        ) &&
        res.some(
          (item) =>
            item.liters == null ||
            item.liters === "" ||
            item.liters === undefined ||
            item.liters <= 0
        )
      ) {
        $("#chkEntryQuantity").prop("checked", true);
      } else {
        $("#chkEntryQuantity").prop("checked", false);
      }
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

function GetQualityList(MilkCollectionDairy_Id) {
  $("#chkEntryQuality").prop("checked", false);
  var Method_Name = "Get_Quality";
  var APIEndPoint = "GetMilkCollection";
  var url = "/Collection/MilkCollection";

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
        // TableHTML += "<td>" + value.batch_id + "</td>";
        TableHTML += "<td>" + value.sample_no + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableMilkQualityList");
      $("#tableEntryQuality").html(TableHTML);
      SetDataTable("tableMilkQualityList", [5], "Milk Quantity at Dairy");

      if (
        res.some(
          (item) =>
            item.fat == null ||
            item.fat === "" ||
            item.fat === undefined ||
            item.fat <= 0
        ) &&
        res.some(
          (item) =>
            item.snf == null ||
            item.snf === "" ||
            item.snf === undefined ||
            item.snf <= 0
        )
      ) {
        $("#chkEntryQuality").prop("checked", true);
      } else {
        $("#chkEntryQuality").prop("checked", false);
      }
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

function GetMCCCommissionList(MilkCollectionDairy_Id) {
  // // console.log(MilkCollectionDairy_Id);
  var Method_Name = "Get_MCCCommission";
  var APIEndPoint = "GetMilkCollection";
  var url = "/Collection/MilkCollection";

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
        TableHTML += "<td >" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.mppitype_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td>" + value.rate + "</td>";
        // TableHTML += "<td>" + value.servicecharge + "</td>";
        TableHTML += "<td>" + value.amount + "</td>";

        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "<td hidden>" + value.milktype_id + "</td>";
        TableHTML += "<td hidden>" + value.milkstatus_id + "</td>";
        TableHTML += "<td hidden>" + value.mppitype_id + "</td>";

        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      ClearDataTable("tableMCCCommissionList");
      $("#tableEntryMCCCommission").html(TableHTML);
      SetDataTable("tableMCCCommissionList", [13], "Milk Quantity at Dairy");
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

function GetGRNList(MilkCollectionDairy_Id) {
  var Method_Name = "Get_GRN_Data";
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

        TableHTML += "<td>" + value.final_ltr + "</td>";
        TableHTML += "<td>" + value.final_fat + "</td>";
        TableHTML += "<td>" + value.final_snf + "</td>";

        TableHTML += "<td>" + value.composite_protein + "</td>";
        TableHTML += "<td>" + value.composite_ash + "</td>";
        TableHTML += "<td>" + value.composite_sodium + "</td>";

        // TableHTML += "<td>";
        // TableHTML += "<div class='form-group'>";
        // TableHTML +=
        //   "<input type='text' id='txtLtr" +
        //   value.chemistcollection_id +
        //   "' value='" +
        //   value.final_ltr +
        //   "' class='form-control' onchange='ClearInvalidState(this);' >";
        // TableHTML += "<div class='invalid-feedback'>Invalid Ltr.</div>";
        // TableHTML += "</div>";
        // TableHTML += "</td>";

        // TableHTML += "<td>";
        // TableHTML += "<div class='form-group'>";
        // TableHTML +=
        //   "<input type='text' id='txtFat" +
        //   value.chemistcollection_id +
        //   "' value='" +
        //   value.final_fat +
        //   "' class='form-control' onchange='ClearInvalidState(this);' >";
        // TableHTML += "<div class='invalid-feedback'>Invalid FAT.</div>";
        // TableHTML += "</div>";
        // TableHTML += "</td>";

        // TableHTML += "<td>";
        // TableHTML += "<div class='form-group'>";
        // TableHTML +=
        //   "<input type='text' id='txtSNF" +
        //   value.chemistcollection_id +
        //   "' value='" +
        //   value.final_snf +
        //   "' class='form-control' onchange='ClearInvalidState(this);' >";
        // TableHTML += "<div class='invalid-feedback'>Invalid SNF.</div>";
        // TableHTML += "</div>";
        // TableHTML += "</td>";

        TableHTML += "<td hidden></td>";

        TableHTML += "<td hidden>" + value.cellno + "</td>";
        TableHTML += "<td hidden>" + value.chemistcollection_id + "</td>";
        TableHTML += "<td hidden>" + value.mcc_id + "</td>";
        TableHTML += "<td hidden>" + value.milktype_id + "</td>";
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

function GetReverse(MilkCollectionDairy_Id) {
  var APIEndPoint = "GetCollectionApproval";
  var Method_Name = "Get_ReverseGRN";
  var url = "/Collection/CollectionApproval";
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
      var res = JSON.parse(result);
      if (res[0].is_locked == 0) {
        $("#btn_Reverse").show();
      }
      if (res[0].is_locked == 1) {
        $("#btn_Reverse").hide();
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}

function SetReverse() {
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
        Show_Loader();
        //Post it
        var APIEndPoint = "SaveGoodsInwardPostingList";
        var Method_Name = "Set_ReverseGRN";
        var url = "/Collection/CollectionApproval";
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
              Hide_Loader();
              Show_Success_Toastr("Collection Reverse Successfully");
              CloseEntry();
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Collection Not Reverse");
          },
        });
      }
    }
  );
}
