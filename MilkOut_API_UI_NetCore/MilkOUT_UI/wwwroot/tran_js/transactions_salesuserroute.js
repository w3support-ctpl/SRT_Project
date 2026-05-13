var said = '';
$(document).ready(function () {
  //SetDataTable("tableSearch", [4], "SalesArea");



  $("#ddlSearchSalesUser").select2();
  GetMaster("ddlSearchSalesUser", "Select Sales User", "GetSalesUser", "", "");

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
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  // Validate Data
  var SalesUser_Id = $("#ddlSearchSalesUser").val();
  if (SalesUser_Id == "") {
    $("#ddlSearchSalesUser").addClass("is-invalid state-invalid");
  }
  var Method_Name = "Get";
  var APIEndPoint = "GetSalesUserRoute";
  var url = "/Transactions/SalesUserRoute";
  var reqdata = {
    method_name: Method_Name,
    salesuser_id: SalesUser_Id,
    api_end_point: APIEndPoint,
  };
  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        $("#btn_Search").prop("disabled", false);
        return;
      }
      var TableHTML = "";
      var EditFlag = 1;
      var Working_Status;

      $.each(res, function (data, value) {
        if (value.working_status == 1) {
          Working_Status = "Working";
        } else {
          Working_Status = "Not Working";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.route_name + "</td>";
        TableHTML += "<td>" + value.routeday_name + "</td>";
        TableHTML += "<td>" + Working_Status + "</td>";
        TableHTML += "<td>" + value.total_retailers + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.route_id +
            "', '" +
            value.salesuser_id +
            "', '" +
            value.salesarea_id +
            "', '" +
            value.salesuser_name +
            "','" +
            value.working_status +
            "', '" +
            value.routeday_id +
            "', '" +
            value.routeday_name +
            "','" +
            value.remarks +
            "', '" +
            value.route_name +
            "') \">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [5], "Sales User Route");
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

/*
function ShowAddEntry() {
    ShowContentDiv('Masters', 'SalesAreaAdd', '', function () {
        // Initialization Code

        $("#lblEntryId").html("");
        $("#lblAction").html("Add");
        $("#divFooterDelete").hide();

        // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
    });
}
*/

function ShowEditEntry(
  Route_Id,
  SalesUser_Id,
  SalesArea_Id,
  SalesUser_Name,
  Working_Status,
  RouteDay_Id,
  RouteDay_Name,
  Remarks,
  Route_Name
) {
  ShowContentDiv("Transactions", "SalesUserRouteEdit", "", function () {
    // Initialization Code
    // debugger;
    $("#lblEntryId").html(Route_Id);
    said = SalesArea_Id;
    $("#lblAction").html("Edit");
    $("#lblSalesUserId").html(SalesUser_Id);
    $("#txtEntrySalesRouteName").select2()
    // debugger;
    GetMaster("txtEntrySalesRouteName", "Select Day", "GetRouteNameDrp", Route_Id || "", SalesUser_Id);
    $("#txtEntrySalesUserName").val(SalesUser_Name);

    $("#txtEntryRouteDay").val(RouteDay_Name);
    $("#lblRouteId").html(RouteDay_Id);
    $("#txtEntryRemarks").val(Remarks);


    if (Working_Status == 1) {
      $("#chkWorkingStatus").prop("checked", true);
    } else {
      $("#chkWorkingStatus").prop("checked", false);
    }

    if (Route_Id == "") {
      txtEntrySalesRouteName;
    }

    if (
      Route_Name == "" ||
      Route_Name == "null" ||
      Route_Id == "" ||
      Route_Id == "null"
    ) {
      $("#txtEntrySalesRouteName").prop("disabled", false);
    }
    OnChangeGetRetailer();

    // Get Retailer List
    ClearDataTable("tableRetailerList");

  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var Remarks = $("#txtEntryRemarks").val().trim();
  var Working_Status = 0;
  if ($("#chkWorkingStatus").prop("checked") == true) {
    Working_Status = 1;
  }

  // store table data in an xml string
  var RetailerList = "<RetailerList>";
  var Total_Retailers = 0;
  $("#tableRetailerList tbody tr").each(function () {
    // set values of flags as 1 if checked
    if ($(this).find("td:eq(0) input").prop("checked") == true) {
      RetailerList += "<RetailerItem>";
      RetailerList +=
        "<Retailer_Id>" + $(this).find("td:eq(1)").text() + "</Retailer_Id>";
      RetailerList += "</RetailerItem>";
      Total_Retailers += 1;
    }
  });
  RetailerList += "</RetailerList>";

  var IsValid = 1;

  /*if (Remarks == "") {
        IsValid = 0;
        $("#txtEntryRemarks").addClass("is-invalid state-invalid");
    }*/
  if (Total_Retailers <= 0 && Working_Status == 1) {
    ShowEntryError(
      "If Sales User is Working, atleast one Retailer must be selected."
    );
    return;
  }
  if (Total_Retailers > 0 && Working_Status == 0) {
    ShowEntryError(
      "If Sales User is not Working, no Retailer can be selected."
    );
    return;
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    var Day = $("#lblRouteId").html();
    var routename = $("#txtEntrySalesRouteName :selected").html();
    var routeid = $("#txtEntrySalesRouteName").val().join(',');

    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Update";
    var Route_Id = $("#lblEntryId").html();
    // var Action_Name = $("#lblAction").html();
    var SalesUser_Id = $("#lblSalesUserId").html();
    var Is_Active = 1;
    var Is_Deleted = 0;
    var APIEndPoint = "SaveSalesUserRoute";
    var url = "/Transactions/SalesUserRoute";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      route_id: routeid,
      salesuser_id: SalesUser_Id,
      remarks: Remarks,
      working_status: Working_Status,
      total_retailers: Total_Retailers,
      retailer_list: RetailerList,
      routeday_id: Day,
      route_name: routename,
      salesarea_id: said
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
          // Show Success Messageq
          ShowEntrySuccess("Sales User Route details saved successfully");
          $("#btn_Save").prop("disabled", false);
        } else {
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        ShowEntryError("Error : Sales Area details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}
function OnChangeGetRetailer() {
  $("#txtEntrySalesRouteName").on("change", function () {
    var SalesUser_Id = $("#lblSalesUserId").html();
    var RouteDay_Id = $("#lblRouteId").html();

    var Route_Id = $(this).val()
    GetRetailerList(
      SalesUser_Id,
      Route_Id ? JSON.stringify(Route_Id) : "[]",
      RouteDay_Id
    );

  })


}
function GetRetailerList(SalesUser_Id, Route_Id, RouteDay_Id) {
  // 1. Clear existing data
  ClearDataTable("tableRetailerList");

  // 2. Dynamically Inject "Select All" checkbox into the Header if it's not already there
  var headerCheck = '<label class="custom-control custom-checkbox" style="margin-bottom: 0;">' +
    '<input type="checkbox" id="selectAllRetailers" class="custom-control-input">' +
    '<span class="custom-control-label"></span>' +
    '</label>';

  // Target the first 'th' of the table header and put the checkbox in it
  $("#tableRetailerList thead tr th:first").html(headerCheck);

  // Ensure the master checkbox starts unchecked for a new request
  $("#selectAllRetailers").prop('checked', false);

  var Method_Name = "Get_One";
  var APIEndPoint = "GetSalesUserRoute";
  var url = "/Transactions/SalesUserRoute";
  var reqdata = {
    method_name: Method_Name,
    salesuser_id: SalesUser_Id,
    route_id: Route_Id,
    api_end_point: APIEndPoint,
    routeday_id: RouteDay_Id
  };

  Show_Loader();

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      if (!res || res.length == 0) {
        Hide_Loader();
        Show_Error_Toastr("Retailers not found.");
        return;
      }

      var TableHTML = "";
      var checked = "";
      $.each(res, function (data, value) {
        // Existing logic for checkbox
        var checked = (value.is_locked == 1) ? "checked" : "";
        // debugger;
        // New logic for the badge
        var badgeHTML = "";
        if (value.assigned == 1) {
          badgeHTML = ' <span class="badge badge-pill badge-light-info" title="Currently assigned to ' + value.assigned_To_Other_User + '"> Assigned to: ' + value.assigned_To_Other_User + '</span>';
        }

        TableHTML += "<tr>";
        TableHTML += '<td class="text-center" style="width: 20px;">';
        TableHTML += '<label class="custom-control custom-checkbox">';
        TableHTML += '<input type="checkbox" id="retailer' + (data + 1) +
          '" class="custom-control-input retailer-checkbox" ' + checked + " />";
        TableHTML += '<label for="retailer' + (data + 1) +
          '" class="custom-control-label text-dark"></label>';
        TableHTML += "</label></td>";
        TableHTML += "<td hidden>" + value.retailer_id + "</td>";
        TableHTML += "<td>" + value.retailer_name + badgeHTML + "</td>"; // Badge added here

        TableHTML += "</tr>";
      });

      $("#tableEntryRetailerList").html(TableHTML);

      SetDataTable_Filter(
        "tableRetailerList",
        [1],
        "Sales User Route Retailer List"
      );

      Hide_Loader();
    },
    error: function (xhr, status, error) {
      Hide_Loader();
      Show_Error_Toastr("Error in fetching details from server.", error);
    },
  });
}

/** * EVENT LISTENERS 
 * These must be outside the function so they don't get duplicated 
 */

// Handle "Select All" logic
$(document).off('change', '#selectAllRetailers').on('change', '#selectAllRetailers', function () {
  var isChecked = $(this).prop('checked');
  $('.retailer-checkbox').prop('checked', isChecked);
});

// Sync "Select All" if individual checkboxes are manually clicked
$(document).off('change', '.retailer-checkbox').on('change', '.retailer-checkbox', function () {
  var total = $('.retailer-checkbox').length;
  var checked = $('.retailer-checkbox:checked').length;

  if (total > 0 && total === checked) {
    $('#selectAllRetailers').prop('checked', true);
  } else {
    $('#selectAllRetailers').prop('checked', false);
  }
});


function AddDealerEntry() {
  ClearDataTable("tableEntryModal");

  var SalesUser_Id = $("#ddlSearchSalesUser").val();
  if (SalesUser_Id == "") {
    $("#ddlSearchSalesUser").addClass("is-invalid state-invalid");
  } else {
    $("#modalEntry")
      .modal({
        backdrop: "static",
      })
      .modal("show");

    var Method_Name = "Get_Dealer";
    var APIEndPoint = "GetSalesUserRoute";
    var url = "/Transactions/SalesUserRoute";
    var reqdata = {
      method_name: Method_Name,
      salesuser_id: SalesUser_Id,
      api_end_point: APIEndPoint,
    };

    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        console.log(res);

        if (res.length == 0) {
          Show_Error_Toastr("Data not found. Please assign a Sales Area to the Sales User.");

          return;
        }
        var TableHTML = "";
        $.each(res, function (data, value) {
          TableHTML += "<tr>";

          TableHTML += '<td style="width: 20px;">';
          TableHTML += '<label class="custom-control custom-checkbox ">';

          if (value.is_dealer == 1) {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
              value.dealer_id +
              '"';
            TableHTML +=
              'style="vertical-align:sub; text-align: center;" checked>';
          } else {
            TableHTML +=
              '<input type="checkbox" class="custom-control-input select-item checkbox" value="' +
              value.dealer_id +
              '"';
            TableHTML += 'style="vertical-align:sub; text-align: center;">';
          }

          TableHTML +=
            '<span class="custom-control-label text-dark"></span></label></td>';
          TableHTML += "<td>" + value.dealer_code + "</td>";
          TableHTML += "<td>" + value.dealer_name + "</td>";
          TableHTML += "<td hidden></td>";
        });

        $("#tableEntryModalData").html(TableHTML);
        SetPagingDataTable("tableEntryModal", [3], "Sales User Route Dealer");

      },
      error: function () {
        Show_Error_Toastr(
          "Error in fetching details from server.",
          res[0].result_description
        );
      },
    });
  }


}
function SaveDealer() {
  // Validation
  Show_Loader();
  var SalesUser_Id = $("#ddlSearchSalesUser").val();


  var selectedCheckboxes = $("#tableEntryModal").find(
    "tbody input[type='checkbox']:checked"
  );
  var Dealer_Id = [];

  selectedCheckboxes.each(function () {
    var checkboxId = $(this).val();
    Dealer_Id.push(checkboxId);
  });

  // console.log(Dealer_Id);
  var Method_Name = "Update_Dealer";
  var APIEndPoint = "SaveSalesUserRoute";
  var url = "/Transactions/SalesUserRoute";
  var reqdata = {
    is_active: 1,
    is_deleted: 0,
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    route_id: "",
    salesuser_id: SalesUser_Id,
    remarks: "",
    working_status: 1,
    total_retailers: 1,
    retailer_list: Dealer_Id.join(","),
    routeday_id: "",
    route_name: "",
    salesarea_id: ""
  };


  $("#btnSaveDealer").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        Hide_Loader();
        // Show Success Messageq
        Show_Success_Toastr("Sales User Route Dealer details saved successfully");
        $("#btnSaveDealer").prop("disabled", false);
        AddDealerEntry();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        $("#btnSaveDealer").prop("disabled", false);
        AddDealerEntry();
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Dealer details not saved");
      $("#btnSaveDealer").prop("disabled", false);
    },
  });
}