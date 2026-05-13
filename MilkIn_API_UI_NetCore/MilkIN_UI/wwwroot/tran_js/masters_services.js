$(document).ready(function () {
  $("#ddlSearchServiceType").select2();
  GetMaster(
    "ddlSearchServiceType",
    "Select Service Type",
    "GetServiceType",
    "",
    ""
  );
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var ServiceName = "%" + $("#txtSearchServiceName").val() + "%";
  var ServiceType_Id = "%" + $("#ddlSearchServiceType").val() + "%";
  $("#btn_Search").prop("disabled", true);
  var APIEndPoint = "GetServices";
  var Method_Name = "Get";
  var url = "/Masters/Services";
  var reqdata = {
    method_name: Method_Name,
    service_name: ServiceName,
    servicetype_id: ServiceType_Id,
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
      var hidden = "";
      if (ServiceType_Id != "C026003" && ServiceType_Id != "%%") {
        $("#thMaterial").prop("hidden", true);
        hidden = "hidden";
      } else {
        $("#thMaterial").prop("hidden", false);
        hidden = "";
      }

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
        TableHTML += "<td>" + value.service_name + "</td>";
        TableHTML += "<td>" + value.servicetype_name + "</td>";
        TableHTML += "<td " + hidden + ">" + value.material_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.service_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [5], "Services");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  $("#btn_Search").prop("disabled", false);
  return;
}

function ShowAddEntry() {
  ShowContentDiv("Masters", "ServicesAdd", "", function () {
    // Initialization Code
    $("#ddlEntryServiceType").select2();
    $("#ddlEntryMaterial").select2();

    GetMaster(
      "ddlEntryServiceType",
      "Select Service Type",
      "GetServiceType",
      "",
      ""
    );
    GetMaster("ddlEntryMaterial", "Select Material", "GetMaterial", "", "");

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();
    $("#divEntryMaterial").hide();

    $("#ddlEntryServiceType").on("change", function () {
      if ($("#ddlEntryServiceType").find(":selected").val() == "C026003") {
        $("#divEntryMaterial").show();
      } else {
        $("#divEntryMaterial").hide();
      }
    });
  });
}

function ShowEditEntry(Service_Id) {
  ShowContentDiv("Masters", "ServicesEdit", "", function () {
    // Initialization Code
    $("#ddlEntryServiceType").select2();
    $("#ddlEntryMaterial").select2();

    $("#lblEntryId").html(Service_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();

    $("#ddlEntryServiceType").on("change", function () {
      if ($("#ddlEntryServiceType").find(":selected").val() == "C026003") {
        $("#divEntryMaterial").show();
      } else {
        $("#divEntryMaterial").hide();
      }
    });

    var APIEndPoint = "GetServices";
    var Method_Name = "Get_One";
    var url = "/Masters/Services";
    var reqdata = {
      method_name: Method_Name,
      service_id: Service_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        $("#txtEntryServiceName").val(res[0].service_name);
        $("#txtEntryServiceDescription").val(res[0].service_description);
        $("#txtEntryCondition1").val(res[0].condition_1);
        //$("#txtEntryCondition2").val(res[0].condition_2);
        //$("#txtEntryCondition3").val(res[0].condition_3);
        //$("#txtEntryCondition4").val(res[0].condition_4);
        //$("#txtEntryCondition5").val(res[0].condition_5);
        GetMaster(
          "ddlEntryServiceType",
          "Select Service Type",
          "GetServiceType",
          res[0].servicetype_id,
          ""
        );
        GetMaster(
          "ddlEntryMaterial",
          "Select Material",
          "GetMaterial",
          res[0].material_id,
          ""
        );
        // Check if it's for Farmer
        if (res[0].is_for_farmer == 1) {
          $("#chkForFarmer").prop("checked", true);
        } else {
          $("#chkForFarmer").prop("checked", false);
        }
        // Check if it's for Agent
        if (res[0].is_for_agent == 1) {
          $("#chkForAgent").prop("checked", true);
        } else {
          $("#chkForAgent").prop("checked", false);
        }
        // Check if it's active.
        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }

        // show/hide material type ddl
        if (res[0].servicetype_id == "C026003") {
          $("#divEntryMaterial").show();
        } else {
          $("#divEntryMaterial").hide();
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
  var ServiceCode = $("#txtEntryServiceCode").val();
  var ServiceName = $("#txtEntryServiceName").val();
  var ServiceType_Id = $("#ddlEntryServiceType").val();
  var Material_Id = $("#ddlEntryMaterial").val();
  var ServiceDescription = $("#txtEntryServiceDescription").val();
  var Condition1 = $("#txtEntryCondition1").val();
  var Condition2 = $("#txtEntryCondition2").val();
  var Condition3 = $("#txtEntryCondition3").val();
  var Condition4 = $("#txtEntryCondition4").val();
  var Condition5 = $("#txtEntryCondition5").val();

  var ForFarmer = 0;
  if ($("#chkForFarmer").prop("checked")) {
    ForFarmer = 1;
  }
  var ForAgent = 0;
  if ($("#chkForAgent").prop("checked")) {
    ForAgent = 1;
  }
  var IsValid = 1;

  // if (ServiceCode == "") {
  //   IsValid = 0;
  //   $("#txtEntryServiceCode").addClass("is-invalid state-invalid");
  // }
  if (
    ServiceName == "" ||
    ServiceName == null ||
    ServiceName == undefined ||
    Is_Valid_Name(ServiceName) == false
  ) {
    IsValid = 0;
    $("#txtEntryServiceName").addClass("is-invalid state-invalid");
  }
  if (
    ServiceType_Id == "" ||
    ServiceType_Id == null ||
    ServiceType_Id == undefined
  ) {
    IsValid = 0;
    $("#ddlEntryServiceType").addClass("is-invalid state-invalid");
  }
  if (ServiceType_Id == "C026003") {
    if (Material_Id == "" || Material_Id == null || Material_Id == undefined) {
      IsValid = 0;
      $("#ddlEntryMaterial").addClass("is-invalid state-invalid");
    }
  }
  if (
    ServiceDescription == "" ||
    ServiceDescription == null ||
    ServiceDescription == undefined ||
    Is_Valid_Name(ServiceDescription) == false
  ) {
    IsValid = 0;
    $("#txtEntryServiceDescription").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    Show_Loader();
    $("#btn_Save").prop("disabled", true);
    var APIEndPoint = "SaveServices";
    var Method_Name = "Create";
    var Service_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Service_Id = $("#lblEntryId").html();
    }
    var Is_Active = 1;
    if (document.getElementById("chkEntryStatus").checked == false) {
      Is_Active = 0;
    }
    var Is_Deleted = 0;
    var url = "/Masters/Services";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      service_id: Service_Id,

      service_code: ServiceCode,
      service_name: ServiceName,
      servicetype_id: ServiceType_Id,
      material_id: Material_Id,
      service_description: ServiceDescription,
      is_for_farmer: ForFarmer,
      is_for_agent: ForAgent,
      condition_1: Condition1,
      condition_2: "",
      condition_3: "",
      condition_4: "",
      condition_5: "",
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
          $("#btn_Save").prop("disabled", false);
          //GetSearchList();
          $("#lblEntryId").html(result[0].result_extra_key);
          $("#lblAction").html("Edit");
          $("#divFooterDelete").show();
          ShowEntrySuccess("Service details saved successfully");
        } else {
          Hide_Loader();
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Hide_Loader();
        ShowEntryError("Error : Service details not saved");
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

function DeleteEntry(Service_Entry) {
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
  var APIEndPoint = "SaveServices";
  var Service_Id = $("#lblEntryId").html();
  var Is_Deleted = 1;
  // In success do following things
  var url = "/Masters/Services";
  var reqdata = {
    service_id: Service_Id,
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
        Show_Success_Toastr("Service details deleted successfully");
        //GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Service details not deleted");
    },
  });
}

function SetEndDateRange() {
  $("#txtEntryApplicableTo").attr("min", $("#txtEntryApplicableFrom").val());
}
