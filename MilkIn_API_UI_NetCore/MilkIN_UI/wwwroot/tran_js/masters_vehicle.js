$(document).ready(function () {
  $("#ddlSearchOwnershipType").select2();
  GetMaster(
    "ddlSearchOwnershipType",
    "Select Ownership Type",
    "GetOwnershipType",
    "",
    ""
  );
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  var APIEndPoint = "GetVehicle";
  var VehicleNo = "%" + $("#txtSearchVehicleNo").val() + "%";
  var OwnershipType_Id = "%" + $("#ddlSearchOwnershipType").val() + "%";
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Masters/Vehicle";
  var reqdata = {
    method_name: Method_Name,
    vehicle_no: VehicleNo,
    vehicleownershiptype_id: OwnershipType_Id,
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
      //var Row_No = 0;

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
        //Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.vehicle_no + "</td>";
        TableHTML += "<td>" + value.vehiclemake_name + "</td>";
        TableHTML += "<td>" + value.vehicletype_name + "</td>";
        TableHTML += "<td>" + value.vehicleownershiptype_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.vehicle_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Vehicle");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
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
  ShowContentDiv("Masters", "VehicleAdd", "", function () {
    // Initialization Code
    $("#ddlEntryVehicle").select2();
    $("#ddlEntryOwnershipType").select2();
    $("#ddlEntryTransporter").select2();
    $("#ddlEntryVehicleMake").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();

    // Vehicle Entry
    GetMaster(
      "ddlEntryVehicle",
      "Select Vehicle Type",
      "GetVehicleType",
      "",
      ""
    );
    GetMaster(
      "ddlEntryOwnershipType",
      "Select Ownership Type",
      "GetOwnershipType",
      "",
      ""
    );
    GetMaster(
      "ddlEntryTransporter",
      "Select Transporter",
      "GetTransporter",
      "",
      ""
    );
    GetMaster(
      "ddlEntryVehicleMake",
      "Select Vehicle Make",
      "GetVehicleMake",
      "",
      ""
    );

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");

    // Hide dependent textboxes
    $("#divEntryOwnerName").hide();
    $("#divEntryNoOfCells").hide();

    // Show/Hide TextBox based on Dropdown Value

    $("#ddlEntryVehicle").on("change", function () {
      if ($("#ddlEntryVehicle").find(":selected").val() == "C020002") {
        $("#divEntryNoOfCells").show();
      } else {
        $("#divEntryNoOfCells").hide();
      }
    });

    $("#ddlEntryOwnershipType").on("change", function () {
      if ($("#ddlEntryOwnershipType").find(":selected").val() == "C021001") {
        $("#divEntryOwnerName").show();
      } else {
        $("#divEntryOwnerName").hide();
      }
    });

    $("#txtEntryNoOfCells").on("change", function () {
      var TotalCells = $("#txtEntryNoOfCells").val();
      GenerateNewCellTable(TotalCells);
      $("#divCellsTable").show();
    });
  });
}

function GenerateNewCellTable(TotalCells) {
  var TableHTML = "";
  for (var i = 1; i <= TotalCells; i++) {
    TableHTML += "<tr>";
    TableHTML += "<td>" + i + "</td>";
    TableHTML +=
      "<td><input type='number' id='check_" +
      i +
      "' class='form-control' value='0' onkeyup='OnCheck(" +
      i +
      ")'></td>";
    TableHTML += "</tr>";
  }
  ClearDataTable("tableCells");
  $("#tableEntryCellsItem").html(TableHTML);
  // SetDataTable("tableCells", [6], "Vehicle");
}

function GetCellTable(Vehicle_Id) {
  var APIEndPoint = "GetVehicle";
  var Method_Name = "GetCells";
  var url = "/Masters/Vehicle";
  var reqdata = {
    method_name: Method_Name,
    vehicle_id: Vehicle_Id,
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
        TableHTML += "<tr>";
        TableHTML += "<td>" + value.cellno + "</td>";
        TableHTML +=
          "<td><input type='number' class='form-control' value='" +
          value.capacity +
          "'></td>";
        TableHTML += "</tr>";
      });

      ClearDataTable("tableCells");
      $("#tableEntryCellsItem").html(TableHTML);
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
    },
  });
}

function ShowEditEntry(Vehicle_Id) {
  ShowContentDiv("Masters", "VehicleEdit", "", function () {
    // Initialization Code
    $("#txtEntryVehicleNo").prop("disabled", true);
    $("#ddlEntryVehicleMake").prop("disabled", true);
    $("#ddlEntryVehicle").prop("disabled", true);
    $("#txtEntryChassisNo").prop("disabled", true);
    $("#txtEntryNoOfCells").prop("disabled", true);

    $("#ddlEntryVehicle").select2();
    $("#ddlEntryOwnershipType").select2();
    $("#ddlEntryTransporter").select2();
    $("#ddlEntryVehicleMake").select2();

    $("#lblEntryId").html(Vehicle_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();

    // Hide dependent textboxes
    $("#divEntryOwnerName").hide();
    $("#divEntryNoOfCells").hide();

    // Show/Hide TextBox based on Dropdown Value

    $("#ddlEntryVehicle").on("change", function () {
      if ($("#ddlEntryVehicle").find(":selected").val() == "C020002") {
        $("#divEntryNoOfCells").show();
      } else {
        $("#divEntryNoOfCells").hide();
      }
    });

    $("#ddlEntryOwnershipType").on("change", function () {
      if ($("#ddlEntryOwnershipType").find(":selected").val() == "C021001") {
        $("#divEntryOwnerName").show();
      } else {
        $("#divEntryOwnerName").hide();
      }
    });

    var APIEndPoint = "GetVehicle";
    var Method_Name = "Get_One";
    var url = "/Masters/Vehicle";
    var reqdata = {
      method_name: Method_Name,
      vehicle_id: Vehicle_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
          var res = JSON.parse(result);

        if (res[0].is_locked == 1) {
          // $("#chkEntryStatus").prop({ checked: true, disabled: true });
          $("#divFooterDelete").hide();
        } else {
          // $("#chkEntryStatus").prop({ checked: false, disabled: false });
          $("#divFooterDelete").show();
        }

        $("#txtEntryVehicleNo").val(res[0].vehicle_no);
        $("#txtEntryMake").val(res[0].make);
        $("#txtEntryChassisNo").val(res[0].chassis_no);
        $("#txtEntryOwnerName").val(res[0].ownername);
        $("#txtEntryCapacityInKg").val(res[0].capacityinkg);
        $("#txtEntryNoOfCells").val(res[0].noofcellsintanker);
        $("#txtEntryVehicleAverage").val(res[0].vehicleaverage);
        $("#txtEntryFSSAILicenseNo").val(res[0].fssailicense_no);
        $("#txtEntryFSSAILicenseValidity").val(res[0].fssailicensevalidity_on);
        GetMaster(
          "ddlEntryVehicleMake",
          "Select Vehicle Make",
          "GetVehicleMake",
          res[0].vehiclemake_id,
          ""
        );
        GetMaster(
          "ddlEntryVehicle",
          "Select Vehicle Type",
          "GetVehicleType",
          res[0].vehicletype_id,
          ""
        );
        if (res[0].vehicletype_id == "C020002") {
          $("#divEntryNoOfCells").show();
          $("#divCellsTable").show();
          GetCellTable(Vehicle_Id);
        } else {
          $("#divEntryNoOfCells").hide();
          $("#divCellsTable").hide();
        }
        GetMaster(
          "ddlEntryOwnershipType",
          "Select Ownership Type",
          "GetOwnershipType",
          res[0].vehicleownershiptype_id,
          ""
        );
        if (res[0].vehicleownershiptype_id == "C021001") {
          $("#divEntryOwnerName").show();
        } else {
          $("#divEntryOwnerName").hide();
        }
        GetMaster(
          "ddlEntryTransporter",
          "Select Transporter",
          "GetTransporter",
          res[0].transporter_id,
          ""
        );
        //if (res[0].laborcharge == 1) {
        //  $("#chkEntryLaborCharge").prop("checked", true);
        //} else {
        //  $("#chkEntryLaborCharge").prop("checked", false);
        //}
          $("#txtEntryLaborCharge").val(res[0].laborcharge);

        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var VehicleNo = $("#txtEntryVehicleNo").val().trim();
  var VehicleMake_Id = $("#ddlEntryVehicleMake").val();
  var VehicleType_Id = $("#ddlEntryVehicle").val();
  var ChassisNo = $("#txtEntryChassisNo").val().trim();
  var OwnerName = $("#txtEntryOwnerName").val().trim();
  var OwnershipType_Id = $("#ddlEntryOwnershipType").val();
  var Transporter_Id = $("#ddlEntryTransporter").val();

  var CapacityInKg = $("#txtEntryCapacityInKg").val().trim();
  var NoOfCells = $("#txtEntryNoOfCells").val().trim();
    var LaborCharge = $("#txtEntryLaborCharge").val().trim();
  var VehicleAverage = $("#txtEntryVehicleAverage").val().trim();
  var FSSAILicenseNo = $("#txtEntryFSSAILicenseNo").val().trim();
  var FSSAILicenceValidity = $("#txtEntryFSSAILicenseValidity").val();
  //if ($("#chkEntryLaborCharge").prop("checked")) {
  //  LaborCharge = 1;
  //}

  var IsValid = 1;

  if (VehicleNo == "" || VehicleNo == null || VehicleNo == undefined) {
    IsValid = 0;
    $("#txtEntryVehicleNo").addClass("is-invalid state-invalid");
  }
  if (
    VehicleMake_Id == "" ||
    VehicleMake_Id == null ||
    VehicleMake_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryVehicleMake").addClass("is-invalid state-invalid");
  }
  if (
    VehicleType_Id == "" ||
    VehicleType_Id == null ||
    VehicleType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryVehicle").addClass("is-invalid state-invalid");
  }
  if (
    OwnershipType_Id == "" ||
    OwnershipType_Id == null ||
    OwnershipType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryOwnershipType").addClass("is-invalid state-invalid");
  }
  if (
    Transporter_Id == "" ||
    Transporter_Id == null ||
    Transporter_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryTransporter").addClass("is-invalid state-invalid");
  }
  if (
    CapacityInKg == "" ||
    CapacityInKg == null ||
    CapacityInKg == undefined ||
    Is_Valid_Float(CapacityInKg) == false
    // Is_Positive_Number_Greater_Than_Zero(CapacityInKg) == false
  ) {
    IsValid = 0;
    $("#txtEntryCapacityInKg").addClass("is-invalid state-invalid");
  }
  if (OwnerName != "") {
    if (
      OwnerName == null ||
      OwnerName == undefined ||
      Is_Valid_Name(OwnerName) == false
    ) {
      IsValid = 0;
      $("#txtEntryOwnerName").addClass("is-invalid state-invalid");
    }
  }
  if (NoOfCells != "") {
    if (
      NoOfCells < 1 ||
      NoOfCells > 8 ||
      NoOfCells == null ||
      NoOfCells == undefined ||
      Is_Positive_Integer(NoOfCells) == false ||
      Is_Positive_Number_Greater_Than_Zero(NoOfCells) == false
    ) {
      IsValid = 0;
      $("#txtEntryNoOfCells").addClass("is-invalid state-invalid");
    }
  }
  if (
    VehicleAverage == "" ||
    VehicleAverage == null ||
    VehicleAverage == undefined ||
    Is_Valid_Float(VehicleAverage) == false // ||
    //  Is_Positive_Number_Greater_Than_Zero(VehicleAverage) == false
  ) {
    IsValid = 0;
    $("#txtEntryVehicleAverage").addClass("is-invalid state-invalid");
  }
  if (
    FSSAILicenseNo == "" ||
    FSSAILicenseNo == null ||
    FSSAILicenseNo == undefined ||
    Is_Valid_FSSAINO(FSSAILicenseNo) == false
  ) {
    IsValid = 0;
    $("#txtEntryFSSAILicenseNo").addClass("is-invalid state-invalid");
  }
  if (
    FSSAILicenceValidity == "" ||
    FSSAILicenceValidity == null ||
    FSSAILicenceValidity == undefined
  ) {
    IsValid = 0;
    $("#txtEntryFSSAILicenseValidity").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    Show_Loader();
    var CellData = "<D>";
    $("#tableCells tbody tr").each(function () {
      CellData += "<R>";
      CellData += "<Cell>" + $(this).find("td:eq(0)").text() + "</Cell>";
      CellData +=
        "<Capacity>" + $(this).find("td:eq(1) input").val() + "</Capacity>";
      CellData += "</R>";
    });
    CellData += "</D>";

    var APIEndPoint = "SaveVehicle";
    var Method_Name = "Create";
    var Vehicle_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Vehicle_Id = $("#lblEntryId").html();
    }
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var Is_Deleted = 0;
    var url = "/Masters/Vehicle";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      vehicle_id: Vehicle_Id,

      vehicle_no: VehicleNo,
      vehiclemake_id: VehicleMake_Id,
      vehicletype_id: VehicleType_Id,
      chassis_no: ChassisNo,
      ownername: OwnerName,
      vehicleownershiptype_id: OwnershipType_Id,

      transporter_id: Transporter_Id,
      capacityinkg: CapacityInKg,
      noofcellsintanker: NoOfCells,
      laborcharge: LaborCharge,
      vehicleaverage: VehicleAverage,

      celldata: CellData,
      fssailicense_no: FSSAILicenseNo,
      fssailicensevalidity_on: FSSAILicenceValidity,
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
          $("#txtEntryVehicleNo").prop("disabled", true);
          $("#ddlEntryVehicleMake").prop("disabled", true);
          $("#ddlEntryVehicle").prop("disabled", true);
          $("#txtEntryChassisNo").prop("disabled", true);
          $("#txtEntryNoOfCells").prop("disabled", true);
          $("#divFooterDelete").show();
          ShowEntrySuccess("Vehicle details saved successfully");
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        Show_Error_Toastr("Error : Vehicle details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}

function ShowDeleteEntry() {
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
    }
  );
}

function SaveDeleteEntry() {
  // Write code to delete
  var Vehicle_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveVehicle";
  var Is_Deleted = 1;
  var url = "/Masters/Vehicle";
  var reqdata = {
    vehicle_id: Vehicle_Id,
    is_deleted: Is_Deleted,
    method_name: "Delete",
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
        Show_Success_Toastr("Vehicle details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Vehicle details not deleted");
    },
  });
}
