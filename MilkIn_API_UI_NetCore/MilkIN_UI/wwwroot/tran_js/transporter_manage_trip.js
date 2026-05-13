// var TripDocument_Id;
// var Entry_Id;
// var Driver_Id;
var successfulCallbacks = 0;
$(document).ready(function () {
  var date = new Date().toISOString().slice(0, 10);
  $("#txtSearchDuration").val(date);
});

function GetSearchList() {
  ClearDataTable("tableSearch");
  $("#tableData").empty();
  Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetManageTrip";
  var Method_Name = "Get";
  var url = "/Transporter/ManageTrip";
  var IsValid = 1;
  if (Search_Period == "") {
    IsValid = 0;
    $("#txtSearchDuration").addClass("is-invalid state-invalid");
    return;
  }

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
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      $.each(res, function (data, value) {
        if (value.is_tripassigned == 1) {
          Status = "Trip Started";
          EditFlag = false;
        } else {
          Status = "Trip Not Started";
          EditFlag = true;
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.driver_name + "</td>";
        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.vehicletype_name + "</td>";
        TableHTML += "<td>" + value.chemist_name + "</td>";
        TableHTML += "<td>" + value.collectionshift_name + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        if (value.is_tripassigned == 0) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'View\', \'' +
            value.entry_id +
            "', '" +
            value.route_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }
        if (value.is_tripassigned == 1) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowViewEntry(\'Edit\', \'' +
            value.entry_id +
            "', '" +
            value.route_id +
            "', '" +
            value.tripdocument_id +
            "', '" +
            value.driver_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [8], "Manage Trip");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
    },
  });
}

function ShowViewEntry(Action, Entry_Id, Route_Id, TripDocument_Id, Driver_Id) {
  ShowContentDiv("Transporter", "ManageTripEdit", "", function () {
    $("#lblAction").html("Edit");
    $("#lblEntryId").html(Entry_Id);
    $("#lblTripDocumentId").html(TripDocument_Id);
    // $("#lblDriverId").html(Driver_Id);
    ShowAddEntry(Entry_Id, "2");
    $("#divEntryRouteItemTable").show();
    $("#btn_Save").hide();
    GetMCCList(TripDocument_Id, Driver_Id);
    // TripDocument_Id = TripDocument_Id;
    // Entry_Id = Entry_Id;
    // Driver_Id = Driver_Id;
  });
}

function ShowEditEntry(Action, Entry_Id, Route_Id) {
  ShowContentDiv("Transporter", "ManageTripAdd", "", function () {
    $("#lblAction").html("Add");
    $("#lblEntryId").html(Entry_Id, "1");
    ShowAddEntry(Entry_Id, "1");
    $("#divEntryRouteItemTable").hide();

    // $("#btn_Save").show();
  });
}

function ShowAddEntry(Entry_Id, number) {
  if (number == "1") {
    $("#btn_Save").hide();
  }
  if (number == "2") {
    $("#btn_Save").hide();
  }
  var totalCallbacks = 5; // Number of callbacks to wait for

  var APIEndPoint = "GetManageTrip";
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "Get_One";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    entry_id: Entry_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      $("#txtEntryRouteName").val(res[0].route_name);
      GetMasterCallback(
        "ddlEntryDriver",
        "Select Driver",
        "GetDriver",
        res[0].driver_id,
        "",
        function (success) {
          if (success) {
            successfulCallbacks++;
            checkCallbacks(number, totalCallbacks);
          }
        },
      );
      GetMasterCallback(
        "ddlEntryVehicleNo",
        "Select Vehicle",
        "GetVehicle",
        res[0].vehicle_id,
        "",
        function (success) {
          if (success) {
            successfulCallbacks++;
            checkCallbacks(number, totalCallbacks);
          }
        },
      );
      GetMasterCallback(
        "ddlEntryVehicleType",
        "Select Vehicle Type",
        "GetVehicleType",
        res[0].vehicletype_id,
        "",
        function (success) {
          if (success) {
            successfulCallbacks++;
            checkCallbacks(number, totalCallbacks);
          }
        },
      );
      GetMasterCallback(
        "ddlEntryRouteChemist",
        "Select Chemist",
        "GetRouteChemist",
        res[0].chemist_id,
        "",
        function (success) {
          if (success) {
            successfulCallbacks++;
            checkCallbacks(number, totalCallbacks);
          }
        },
      );
      GetMasterCallback(
        "ddlEntryMilkCollectionShift",
        "Select Collection Shift",
        "GetMilkCollectionShiftAll",
        res[0].collectionshift_id,
        "",
        function (success) {
          if (success) {
            successfulCallbacks++;
            checkCallbacks(number, totalCallbacks);
          }
        },
      );

      // if (number == "1" ) {
      //   $("#btn_Save").show();
      // }
    },
    error: function (result) {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        result[0].result_description,
      );
    },
  });
}

function checkCallbacks(number, totalCallbacks) {
  if (successfulCallbacks === totalCallbacks && number === "1") {
    $("#btn_Save").show();
  }
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
  successfulCallbacks = 0;
}

function SaveTripEntry() {
  var Search_Period = $("#txtSearchDuration").val();

  // // console.log(Search_Period);

  var APIEndPoint = "SaveManageTrip";

  var Entry_Id = $("#lblEntryId").html();
  var Vehicle_Id = $("#ddlEntryVehicleNo").val();
  var Driver_Id = $("#ddlEntryDriver").val();
  // var MCC_Id = $('#txtEntryRemarks').val();
  // var Trip_Id = $('#txtEntryRemarks').val();
  // var Reason= $('#txtEntryRemarks').val();

  var Method_Name = "StartTrip";
  var Action_Name = $("#lblAction").html();
  // // // console.log(Action_Name);
  if (Action_Name == "Edit") {
    Method_Name = "StartTrip";
  }

  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    entry_id: Entry_Id,
    vehicle_id: Vehicle_Id,
    profile_id: Driver_Id,
    search_period: Search_Period,
  };
  // // // console.log(reqdata);
  // return;

  // return;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      // // console.log(result);
      if (result[0].result_id == 1) {
        // Show Success Message
        Show_Success_Toastr(result[0].result_description);
        $("#divEntryRouteItemTable").show();
        $("#btn_Save").hide();
        GetMCCList(result[0].result_extra_key, Driver_Id);
        $("#lblTripDocumentId").html(result[0].result_extra_key);
        // CloseEntry();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
        // $("#btn_Save").prop('disabled', false);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Manage Trip details not saved");
      // $("#btn_Save").prop('disabled', false);
    },
  });
}

function GetMCCList(TripDocument_Id, Driver_Id) {
  ClearDataTable("tablemcclists");
  $("#tableEntry").empty();
  // Search_Period = $("#txtSearchDuration").val();
  // var Driver_Id = $("#ddlEntryDriver").val();
  var APIEndPoint = "GetManageTrip";
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "GetVehicleStatus";
  var url = "/Transporter/ManageTrip";
  // var IsValid = 1;
  // if (Search_Period == "") {
  //   IsValid = 0;
  //   $("#txtSearchDuration").addClass("is-invalid state-invalid");
  //   return;
  // }

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    profile_id: Driver_Id,
    tripdocument_id: TripDocument_Id,
    search_period: Search_Period,
  };

  // // console.log(reqdata);
  // return;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // // console.log(res);
      // Fill data in table
      var TableHTML = "";
      var EditFlag = true; // IsEditAllowed($("#lblAS").html());
      var Status = "";
      $.each(res, function (data, value) {
        if (value.is_collected == 1) {
          Status = "Milk Collected";
          EditFlag = false;
        } else {
          Status = "Milk Not Collected";
          EditFlag = true;
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + value.order_by + "</td>";
        TableHTML += "<td>" + value.mcc_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.expected_time + "</td>";
        TableHTML += "<td>" + value.arrival_at + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowMCCEntry(\'' +
          value.entry_id +
          "', '" +
          value.route_id +
          "', '" +
          value.tripdocument_id +
          "', '" +
          value.driver_id +
          "', '" +
          value.mcc_id +
          "', '" +
          value.mcc_name +
          "', '" +
          value.collectionshift_id +
          "', '" +
          value.collectionshift_name +
          "', '" +
          value.trip_status +
          "', '" +
          value.mcc_collectionshift_id +
          "');\">";
        TableHTML += '<i class="fa fa-pencil"></i>';
        TableHTML += "</a>";

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntry").html(TableHTML);

      SetDataTable("tablemcclists", [7], "Manage Trip");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
    },
  });
}

function ShowMCCEntry(
  Entry_Id,
  Route_Id,
  TripDocument_Id,
  Driver_Id,
  MCC_Id,
  MCC_Name,
  CollectionShift_id,
  CollectionShift_Name,
  Trip_Status,
  MCCCollectionShift_Id,
) {
  var APIEndPoint = "GetManageTrip";
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "GetRateMCC";
  var url = "/Transporter/ManageTrip";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    search_period: Search_Period,
  };

  // return;
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // // console.log(res[0].rateavailableflag);

      if (res[0].rateavailableflag == "1 1 1 1") {
        // // console.log(MCCCollectionShift_Id);
        var Vehicle_Id = $("#ddlEntryVehicleNo").val();
        var Vehicle_Type = $("#ddlEntryVehicleType").val();
        // // // console.log(Vehicle_Type);
        $("#liChemist").hide();

        if (Vehicle_Type == "C020002") {
          $("#liChemist").show();
        }
        if (Vehicle_Type == "C020001") {
          $("#liChemist").hide();
        }
        ShowContentDiv("Transporter", "ManageTripMCC", "", function () {
          // if(MCCCollectionShift_Id == "" || MCCCollectionShift_Id == undefined || MCCCollectionShift_Id == null){
          //   $("#shift_btn_Save").html(" Start Shift");
          // }else{
          //   $("#shift_btn_Save").html(" End Shift");
          // }
          $("#liChemist").hide();

          if (Vehicle_Type == "C020002") {
            $("#liChemist").show();
          }
          if (Vehicle_Type == "C020001") {
            $("#liChemist").hide();
          }
          $("#shift_btn_Save").hide();
          $("#end_btn_Save").hide();
          $("#lblMCCEntryId").html(Entry_Id);
          $("#lblMCCRouteId").html(Route_Id);
          $("#lblMCCTripDocumentId").html(TripDocument_Id);
          $("#lblMCCDriverId").html(Driver_Id);
          $("#lblMCCMCCId").html(MCC_Id);
          $("#lblMCCCollectionShift").html(CollectionShift_id);
          $("#lblMCCMCCCollectionShiftId").html(MCCCollectionShift_Id);
          $("#txtEntryMCCName").val(MCC_Name);
          $("#txtEntryMilkCollectionShift").val(CollectionShift_Name);
          $("#txtEntryShiftStatus").val(Trip_Status);
          $("#lblMCCVehicleId").html(Vehicle_Id);
          $("#lblMCCVehicleType").html(Vehicle_Type);

          if (
            MCCCollectionShift_Id == "" ||
            MCCCollectionShift_Id == null ||
            MCCCollectionShift_Id == undefined
          ) {
            if (Vehicle_Type == "C020002") {
              GetMCCCollectionShiftId();
            }
            $("#shift_btn_Save").show();
            $("#end_btn_Save").hide();
          } else {
            $("#shift_btn_Save").hide();
            $("#end_btn_Save").show();
          }
          GetFarmerCollectionList();
          $("#ddlEntryFarmer").select2();
          $("#ddlEntryMilkType").select2();
          $("#ddlEntryMilkStatus").select2();

          GetMaster(
            "ddlEntryFarmer",
            "Select Farmer",
            "GetMCCFarmer",
            "",
            MCC_Id,
          );
          GetMaster(
            "ddlEntryMilkType",
            "Select Milk Status",
            "GetMilkType",
            "",
            "",
          );
          GetMaster(
            "ddlEntryMilkStatus",
            "Select Milk Status",
            "GetMilkStatus",
            "C016001",
            "",
          );
        });
      } else {
        var flags = res[0].rateavailableflag.split(" ").map(Number);

        // Check if any of the flags is 0
        if (flags.includes(0)) {
          var errorMsg = "MCC Collection can't be started as -  ";

          if (flags[0] === 0) {
            errorMsg += "Milk rate is not maintained. ";
          }

          if (flags[1] === 0) {
            errorMsg += "MPPI chart is not maintained. ";
          }

          if (flags[2] === 0) {
            errorMsg += "Milk Transport rate not maintained. ";
          }

          if (flags[3] === 0) {
            errorMsg += "Anamat rate not maintained.";
          }

          ShowEntryError(errorMsg);
        }
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
    },
  });
}

function CloseMCCEntry() {
  var Entry_Id = $("#lblMCCEntryId").html();
  var Route_Id = $("#lblMCCRouteId").html();
  var TripDocument_Id = $("#lblMCCTripDocumentId").html();
  var Driver_Id = $("#lblMCCDriverId").html();

  ShowContentDiv("Transporter", "ManageTripEdit", "", function () {
    $("#lblAction").html("Edit");
    $("#lblEntryId").html(Entry_Id);
    ShowAddEntry(Entry_Id, "2");
    $("#divEntryRouteItemTable").show();
    $("#btn_Save").hide();
    GetMCCList(TripDocument_Id, Driver_Id);
  });
}

function GetFarmerCollectionList() {
  var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
  var MCC_Id = $("#lblMCCMCCId").html();
  ClearDataTable("tableFarmerCollectionList");
  $("#tableEntryFarmerCollection").empty();
  var APIEndPoint = "GetManageTrip";
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "Get_Farmer";
  var url = "/Transporter/ManageTrip";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_collectionshift_id: MCCCollectionShift_Id,
    mcc_id: MCC_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // // console.log(res);
      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.farmer_code + "</td>";
        TableHTML += "<td>" + value.farmer_name + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";

        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowGetDeleteFarmerEntry(\'' +
          value.farmer_id +
          "','" +
          value.is_locked +
          "')\">";
        TableHTML += '<i class="fa fa-trash"></i>';
        TableHTML += "</a>";

        TableHTML += "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryFarmerCollection").html(TableHTML);

      SetDataTable("tableFarmerCollectionList", [10], "Farmer Milk Collection");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
    },
  });
}

function GetMCCCollectionList() {
  var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
  var MCC_Id = $("#lblMCCMCCId").html();
  ClearDataTable("tableMCCCollectionList");
  $("#tableEntryMCCCollection").empty();
  var Search_Period = $("#txtSearchDuration").val();
  var APIEndPoint = "GetManageTrip";
  var Method_Name = "Get_MCC";
  var url = "/Transporter/ManageTrip";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_collectionshift_id: MCCCollectionShift_Id,
    mcc_id: MCC_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryMCCCollection").html(TableHTML);

      SetDataTable("tableMCCCollectionList", [6], "MCC Milk Collection");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
    },
  });
}

function GetChemistCollectionList() {
  var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
  var MCC_Id = $("#lblMCCMCCId").html();
  var TripDocument_Id = $("#lblMCCTripDocumentId").html();
  ClearDataTable("tableChemistCollectionList");
  $("#tableEntryChemistCollection").empty();
  var APIEndPoint = "GetManageTrip";
  var Method_Name = "Get_Chemist";
  var url = "/Transporter/ManageTrip";
  var Search_Period = $("#txtSearchDuration").val();

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_collectionshift_id: MCCCollectionShift_Id,
    mcc_id: MCC_Id,
    tripdocument_id: TripDocument_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var TableHTML = "";
      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.cell_no + "</td>";
        TableHTML += "<td>" + value.milktype_name + "</td>";
        TableHTML += "<td>" + value.milkstatus_name + "</td>";
        TableHTML += "<td>" + value.weight + "</td>";
        TableHTML += "<td>" + value.liters + "</td>";
        TableHTML += "<td>" + value.fat + "</td>";
        TableHTML += "<td>" + value.snf + "</td>";
        TableHTML += "<td hidden></td>";
        TableHTML += "</tr>";
      });
      $("#tableEntryChemistCollection").html(TableHTML);

      SetDataTable(
        "tableChemistCollectionList",
        [8],
        "Chemist Milk Collection",
      );
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
    },
  });
}

function SaveShiftStartEntry() {
  var MCC_Id = $("#lblMCCMCCId").html();
  var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "StartShift";
  var APIEndPoint = "SaveManageTrip";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    mcc_collectionshift_id: MCCCollectionShift_Id,
    search_period: Search_Period,
  };
  // // console.log(reqdata);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      // // console.log(result);
      if (result[0].result_id == 1) {
        // Show Success Message
        Show_Success_Toastr(result[0].result_description);
        $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        $("#shift_btn_Save").hide();
        $("#end_btn_Save").show();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
        $("#shift_btn_Save").show();
        $("#end_btn_Save").hide();
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Manage Trip details not saved");
      $("#shift_btn_Save").show();
      $("#end_btn_Save").hide();
    },
  });
}

function SaveShiftEndEntry() {
  var MCC_Id = $("#lblMCCMCCId").html();
  var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "EndShift";
  var APIEndPoint = "SaveManageTrip";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    mcc_collectionshift_id: MCCCollectionShift_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      // // console.log(result);
      if (result[0].result_id == 1) {
        // Show Success Message
        Show_Success_Toastr(result[0].result_description);
        // $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        $("#end_btn_Save").hide();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
        $("#end_btn_Save").show();
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Manage Trip details not saved");
      $("#end_btn_Save").show();
    },
  });
}

function SaveMCCEntry() {
  var MCC_Id = $("#lblMCCMCCId").html();
  var TripDocument_Id = $("#lblMCCTripDocumentId").html();
  var Driver_Id = $("#lblMCCDriverId").html();
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "ReachedDestination";
  var APIEndPoint = "SaveManageTrip";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    profile_id: Driver_Id,
    tripdocument_id: TripDocument_Id,
    search_period: Search_Period,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);

      // // console.log(result);
      if (result[0].result_id == 1) {
        // Show Success Message
        Show_Success_Toastr(result[0].result_description);
        // $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        $("#btn_MCCSave").hide();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
        $("#btn_MCCSave").show();
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Manage Trip details not saved");
      $("#btn_MCCSave").show();
    },
  });
}

function OpenModalFarmerChemist(action, version_no, entry_id) {
  // $("#modelEntryFarmerCollection").modal("show");
  $("#txtEntryWeight").val("");
  $("#txtEntryFAT").val("");
  $("#txtEntrySNF").val("");
  $("#ddlEntryCellNo").select2();
  $("#divEntryCellNo").hide();
  $("#divEntryFarmer").hide();
  if (action == "Farmer") {
    $("#modelEntryFarmerCollection").modal("show");
    $("#lblWeightName").html("Quantity (Ltr)");
    $("#divEntryCellNo").hide();
    $("#divEntryFarmer").show();
    $("#AddEditFarmerChemistCollection").html("Add Quantity Details");
    $("#lblActionFarmerChemistCollection").html("Farmer");
  }
  if (action == "Chemist") {
    var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
    if (
      MCCCollectionShift_Id == "" ||
      MCCCollectionShift_Id == null ||
      MCCCollectionShift_Id == undefined
    ) {
      $("#divEntryMCCSuccess").hide();
      $("#divEntryMCCError").html(
        "Chemist entry cannot be done without farmer entry.",
      );

      $("#divEntryMCCError")
        .fadeTo(2000, 500)
        .slideUp(500, function () {
          $("#divEntryMCCError").slideUp(500);
        });
      return;
    }
    $("#modelEntryFarmerCollection").modal("show");
    $("#lblWeightName").html("Quantity (KG)");
    $("#divEntryFarmer").hide();
    $("#AddEditFarmerChemistCollection").html("Add Quantity Details");
    $("#lblActionFarmerChemistCollection").html("Chemist");
    if ($("#lblMCCVehicleType").html() == "C020002") {
      var vehicle_id = $("#lblMCCVehicleId").html();
      // // console.log(vehicle_id);
      $("#divEntryCellNo").show();
      GetMaster(
        "ddlEntryCellNo",
        "Select Cell No",
        "GetNoOfCellsInManageTrip",
        "",
        vehicle_id,
      );
    }
  }

  var MCC_Id = $("#lblMCCMCCId").html();
  GetMaster("ddlEntryFarmer", "Select Farmer", "GetMCCFarmer", "", MCC_Id);
  GetMaster("ddlEntryMilkType", "Select Milk Status", "GetMilkType", "", "");
  GetMaster(
    "ddlEntryMilkStatus",
    "Select Milk Status",
    "GetMilkStatus",
    "C016001",
    "",
  );
}
$("#modelEntryFarmerCollection").on("hidden.bs.modal", function (e) {});

function ExcelUpload() {
  $("#modelEntryExcelUpload").modal("show");
}
function SaveExcelUploadEntry() {
  Show_Loader();
  var file = $("#txtEntryExcelUpload");
  var reqdata = new FormData();
  reqdata.append("FIle", file[0].files[0]);
  reqdata.append("ModuleName", "CategoryMaster");

  var url = "/Transporter/CovertExcelToTable";
  $.ajax({
    url: url,
    type: "POST",
    processData: false,
    contentType: false,
    data: reqdata,
    async: false,
    success: function (response) {
      if (response.status == 200) {
        var res_Json = JSON.parse(response.data);
        // // console.log(res_Json);

        var farmerCollectionData = "<CollectionData>";
        for (var i = 0; i < res_Json.length; i++) {
          var farmerData = res_Json[i];
          if (
            farmerData["Farmer Code"] &&
            farmerData["Milk Category"] &&
            farmerData["Liters"] &&
            farmerData["FAT"] &&
            farmerData["SNF"]
          ) {
            farmerCollectionData += "<Farmer>";
            farmerCollectionData +=
              "<MCC_Farmer_Code>" +
              farmerData["Farmer Code"] +
              "</MCC_Farmer_Code>";
            // farmerCollectionData +=
            //   "<MilkCategory>" + farmerData["Milk Category"] + "</MilkCategory>";

            if (
              farmerData["Milk Category"] === "Cow Milk" ||
              farmerData["Milk Category"] === "Cow"
            ) {
              farmerCollectionData += "<MilkType_Id>C011001</MilkType_Id>";
            } else if (
              farmerData["Milk Category"] === "Buffalo Milk" ||
              farmerData["Milk Category"] === "Buffalo"
            ) {
              farmerCollectionData += "<MilkType_Id>C011002</MilkType_Id>";
            }
            farmerCollectionData += "<MilkStatus_Id>C016001</MilkStatus_Id>";
            farmerCollectionData +=
              "<Liters>" + farmerData["Liters"] + "</Liters>";
            farmerCollectionData += "<Fat>" + farmerData["FAT"] + "</Fat>";
            farmerCollectionData += "<SNF>" + farmerData["SNF"] + "</SNF>";
            // farmerCollectionData +=
            //   "<CellNo>" + farmerData["Cell No"] + "</CellNo>";
            farmerCollectionData += "</Farmer>";
          }
        }

        farmerCollectionData += "</CollectionData>";

        var MCC_Id = $("#lblMCCMCCId").html();
        var TripDocument_Id = $("#lblMCCTripDocumentId").html();
        var Driver_Id = $("#lblMCCDriverId").html();
        var CollectionShift_Id = $("#lblMCCCollectionShift").html();
        var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
        var Entry_Id = $("#lblMCCEntryId").html();
        var VehicleType_Id = $("#lblMCCVehicleType").html();
        var VehicleNo_Id = $("#lblMCCVehicleId").html();
        var Search_Period = $("#txtSearchDuration").val();
        // var Farmer_Id = $("#ddlEntryFarmer").val().trim();
        // var MilkType_Id = $("#ddlEntryMilkType").val().trim();
        // var MilkStatus_Id = $("#ddlEntryMilkStatus").val().trim();
        // var Weight = $("#txtEntryWeight").val().trim();
        // var FAT = $("#txtEntryFAT").val().trim();
        // var SNF = $("#txtEntrySNF").val().trim();

        var Method_Name = "BulkCollectMilk";
        var APIEndPoint = "SaveManageTrip";
        var url_One = "/Transporter/ManageTrip";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          profile_id: Driver_Id,
          tripdocument_id: TripDocument_Id,
          mcc_collectionshift_id: MCCCollectionShift_Id,
          collectionshift_id: CollectionShift_Id,
          collection_data: farmerCollectionData,
          entry_id: Entry_Id,
          vehicletype_id: VehicleType_Id,
          vehicle_id: VehicleNo_Id,
          search_period: Search_Period,
          // farmer_id: Farmer_Id,
          // weight: Weight,
          // snf: SNF,
          // fat: FAT,
          // milktype_id: MilkType_Id,
          // milkstatus_id: MilkStatus_Id,
        };

        // // console.log(reqdata);

        $.ajax({
          type: "POST",
          url: url_One,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            var result = JSON.parse(res);

            // // console.log(result);
            if (result[0].result_id == 1) {
              Hide_Loader();
              // Show Success Message
              $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
              Show_Success_Toastr(result[0].result_description);
              // $("#modelEntryFarmerCollection").hide();
              $("#modelEntryExcelUpload").modal("hide");
              // $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
              // $("#btn_MCCSave").hide();
              GetFarmerCollectionList();
            } else {
              Hide_Loader();
              Show_Error_Toastr("Error : " + result[0].result_description);
              // $("#btn_MCCSave").show();
            }
          },
          error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Farmer details not saved");
            // $("#btn_MCCSave").show();
          },
        });
      } else {
        Hide_Loader();
        Show_Error_Toastr(response.data);
      }

      // Hide_Loader();
    },
    error: function (msg) {
      Hide_Loader();
      Show_Error_Toastr(msg);
      // Hide_Loader();
    },
  });
}

$("#modelEntryExcelUpload").on("hidden.bs.modal", function (e) {
  // Clear the file input field
  $("#txtEntryExcelUpload").val("");

  // Optionally, you can also reset the dropify plugin if you are using it
  // $("#txtEntryExcelUpload").dropifyReset();
});

function SaveFarmerCollectionEntry() {
  Show_Loader();
  var MCC_Id = $("#lblMCCMCCId").html();
  var TripDocument_Id = $("#lblMCCTripDocumentId").html();
  var Driver_Id = $("#lblMCCDriverId").html();
  var CollectionShift_Id = $("#lblMCCCollectionShift").html();
  var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();

  var Farmer_Id = $("#ddlEntryFarmer").val().trim();
  var MilkType_Id = $("#ddlEntryMilkType").val().trim();
  var MilkStatus_Id = $("#ddlEntryMilkStatus").val().trim();
  var Weight = $("#txtEntryWeight").val().trim();
  var FAT = $("#txtEntryFAT").val().trim();
  var SNF = $("#txtEntrySNF").val().trim();
  var Cell_No = $("#ddlEntryCellNo").val();
  var VehicleType_Id = $("#lblMCCVehicleType").html();
  var VehicleNo_Id = $("#lblMCCVehicleId").html();
  var Search_Period = $("#txtSearchDuration").val();

  var Action = $("#lblActionFarmerChemistCollection").html();
  if (Action == "Farmer") {
    var Method_Name = "CollectMilk";
  }
  if (Action == "Chemist") {
    var Method_Name = "ChemistCollectMilk";
  }

  var APIEndPoint = "SaveManageTrip";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    profile_id: Driver_Id,
    tripdocument_id: TripDocument_Id,
    mcc_collectionshift_id: MCCCollectionShift_Id,
    collectionshift_id: CollectionShift_Id,
    farmer_id: Farmer_Id,
    weight: Weight,
    snf: SNF,
    fat: FAT,
    milktype_id: MilkType_Id,
    milkstatus_id: MilkStatus_Id,
    cell_no: Cell_No,
    vehicletype_id: VehicleType_Id,
    vehicle_id: VehicleNo_Id,
    search_period: Search_Period,
  };
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
        $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        Show_Success_Toastr(result[0].result_description);
        // $("#modelEntryFarmerCollection").hide();
        $("#modelEntryFarmerCollection").modal("hide");
        // $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        // $("#btn_MCCSave").hide();
        GetFarmerCollectionList();
        GetChemistCollectionList();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        // $("#btn_MCCSave").show();
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Farmer details not saved");
      // $("#btn_MCCSave").show();
    },
  });
}

function MilkCollection() {
  Show_Loader();
  $("#btn_collection").prop("disabled", true);
  $("#btn_collection").hide();

  // var MCC_Id = $("#lblMCCMCCId").html();
  var TripDocument_Id = $("#lblTripDocumentId").html();
  var Driver_Id = $("#ddlEntryDriver").val();
  var CollectionShift_Id = $("#ddlEntryMilkCollectionShift").val();
  var Search_Period = $("#txtSearchDuration").val();
  var Method_Name = "Collection";
  var APIEndPoint = "SaveManageTrip";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    profile_id: Driver_Id,
    tripdocument_id: TripDocument_Id,
    collectionshift_id: CollectionShift_Id,
    search_period: Search_Period,
  };
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
        // $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        // $("#btn_MCCSave").hide();
        GetMCCList(TripDocument_Id, Driver_Id);
      } else {
        Hide_Loader();
        ShowEntryError("Error : " + result[0].result_description);
        Show_Error_Toastr("Error : " + result[0].result_description);
        GetMCCList(TripDocument_Id, Driver_Id);
        // $("#btn_MCCSave").show();
      }
      $("#btn_collection").prop("disabled", false);
      $("#btn_collection").show();
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Collection details not saved");
      $("#btn_collection").prop("disabled", false);
      $("#btn_collection").show();
      // $("#btn_MCCSave").show();
    },
  });
}

function OnDurationChnage() {
  ClearDataTable("tableSearch");

  $("#txtSearchDuration").removeClass("is-invalid state-invalid");
}

function ExcelDownload() {
  var data = [
    ["Milk Category", "Farmer Code", "Liters", "FAT", "SNF"],
    ["xxxx", "xxxxx", "xx.xxx", "xx.xx", "xx.xx"],
  ];

  // Convert data to CSV format
  var csvContent =
    "data:text/csv;charset=utf-8," +
    data.map((row) => row.join(",")).join("\n");

  // Create a virtual link and trigger download
  var encodedUri = encodeURI(csvContent);
  var link = document.createElement("a");
  link.setAttribute("href", encodedUri);
  link.setAttribute("download", "FarmerCollectionUploadTemplate.csv");
  document.body.appendChild(link); // Required for Firefox
  link.click();
}

function OnAgentClear() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, Clear it!",
    },
    function (result) {
      if (result == true) {
        var MCC_Id = $("#lblMCCMCCId").html();
        var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
        var Method_Name = "DeleteAgent";
        var APIEndPoint = "SaveManageTrip";
        var url = "/Transporter/ManageTrip";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          mcc_collectionshift_id: MCCCollectionShift_Id,
        };
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            GetMCCCollectionList();
          },
          error: function () {
            Show_Error_Toastr("Error : Manage Trip details not Clear");
          },
        });
      }
    },
  );
}

function OnChemistClear() {
  swal(
    {
      title: "Are you sure?",
      text: "You won't be able to revert this!",
      icon: "question",
      type: "warning",
      showCancelButton: true,
      confirmButtonText: "Yes, Clear it!",
    },
    function (result) {
      if (result == true) {
        var MCC_Id = $("#lblMCCMCCId").html();
        var TripDocument_Id = $("#lblMCCTripDocumentId").html();
        var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
        var Method_Name = "DeleteChemist";
        var APIEndPoint = "SaveManageTrip";
        var url = "/Transporter/ManageTrip";
        var reqdata = {
          method_name: Method_Name,
          api_end_point: APIEndPoint,
          mcc_id: MCC_Id,
          mcc_collectionshift_id: MCCCollectionShift_Id,
          tripdocument_id: TripDocument_Id,
        };
        $.ajax({
          type: "POST",
          url: url,
          contentType: "application/x-www-form-urlencoded; charset=UTF-8",
          data: reqdata,
          success: function (res) {
            GetChemistCollectionList();
          },
          error: function () {
            Show_Error_Toastr("Error : Manage Trip details not Clear");
          },
        });
      }
    },
  );
}

function GetMCCCollectionShiftId() {
  var MCC_Id = $("#lblMCCMCCId").html();
  var CollectionShift_id = $("#lblMCCCollectionShift").html();
  var Search_Period = $("#txtSearchDuration").val();
  var TripDocument_Id = $("#lblMCCTripDocumentId").html();
  var Method_Name = "GetMCCCollectionShiftId";
  var APIEndPoint = "SaveManageTrip";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    collectionshift_id: CollectionShift_id,
    search_period: Search_Period,
    tripdocument_id: TripDocument_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
      } else {
        if (
          res[0].result_extra_key == "" ||
          res[0].result_extra_key == null ||
          res[0].result_extra_key == undefined
        ) {
        } else {
          $("#lblMCCMCCCollectionShiftId").html(res[0].result_extra_key);
          GetFarmerCollectionList();
        }
      }
    },
    error: function () {
      Show_Error_Toastr("Error : MCC Collection Shift Not Found");
    },
  });
}

function ShowGetDeleteFarmerEntry(farmer_id, is_locked) {
  if (is_locked == 1) {
    Show_Error_Toastr(
      "Error : The farmer invoice is already posted, so this entry cannot be removed.",
    );
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
          SaveDeleteEntry(farmer_id);
        }
      },
    );
  }
}

function SaveDeleteEntry(farmer_id) {
  Show_Loader();
  var MCC_Id = $("#lblMCCMCCId").html();
  var TripDocument_Id = $("#lblMCCTripDocumentId").html();
  var Driver_Id = $("#lblMCCDriverId").html();
  var CollectionShift_Id = $("#lblMCCCollectionShift").html();
  var MCCCollectionShift_Id = $("#lblMCCMCCCollectionShiftId").html();
  var Farmer_Id = farmer_id;
  var Method_Name = "DeleteFarmerCollection";
  var Search_Period = $("#txtSearchDuration").val();

  var APIEndPoint = "SaveManageTrip";
  var url = "/Transporter/ManageTrip";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    profile_id: Driver_Id,
    tripdocument_id: TripDocument_Id,
    mcc_collectionshift_id: MCCCollectionShift_Id,
    collectionshift_id: CollectionShift_Id,
    farmer_id: Farmer_Id,
    search_period: Search_Period,
  };
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
        $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        Show_Success_Toastr(result[0].result_description);
        // $("#modelEntryFarmerCollection").hide();
        $("#modelEntryFarmerCollection").modal("hide");
        // $("#lblMCCMCCCollectionShiftId").html(result[0].result_extra_key);
        // $("#btn_MCCSave").hide();
        GetFarmerCollectionList();
        GetChemistCollectionList();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        // $("#btn_MCCSave").show();
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Farmer details not saved");
      // $("#btn_MCCSave").show();
    },
  });
}
