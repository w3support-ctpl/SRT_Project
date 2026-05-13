$(document).ready(function () {
  $("#ddlSearchSalesUser").select2();
  $("#ddlSearchSalesArea").select2();

  GetMaster("ddlSearchSalesUser", "Select Sales User", "GetSalesUser", "", "");
  GetMaster("ddlSearchSalesArea", "Select Sales Group", "GetSalesArea", "", "");

  const style = document.createElement("style");
  document.head.appendChild(style);
  style.sheet.insertRule(
    "input::-webkit-inner-spin-button { -webkit-appearance: none; }",
    0
  );

  // SetDataTable("tableSearch", [5], "Retailer");

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
});

function changesakesarea() {
  var SalesArea_Id = $("#ddlSearchSalesArea").val();

  //GetMaster("ddlSearchSalesArea", "Select Sales Group", "GetSalesArea", "", "");
}

/* -----    -----      Search for data in database as per values provided       -----   ----- */
function GetSearchList(e) {
  // disable search button to avoid multiple function calls
  ClearDataTable("tableSearch");
  // Get data from database and show in table
  var SearchPeriod = $("#txtSearchOrderPeriod").val();
  var SalesUser_Id = "%" + $("#ddlSearchSalesUser").val() + "%";
  var SalesArea_Id = "%" + $("#ddlSearchSalesArea").val() + "%";

  if (SearchPeriod == "") {
    $("#txtSearchOrderPeriod").addClass("is-invalid state-invalid");
    return;
  }

  var Method_Name = "Get";
  var APIEndPoint = "GetRetailerOrder";
  var url = "/Secondary/RetailerOrder";
  // store data in object and send to the controller
  var reqdata = {
    method_name: Method_Name,
    search_period: SearchPeriod,
    salesuser_id: SalesUser_Id,
    salesarea_id: SalesArea_Id,
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
      // send message if there's no result
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      // extract values and create an html string to assign to html table
      var TableHTML = "";
      var EditFlag = true;

      $.each(res, function (data, value) {
        var Status;
        if (value.is_closed == 0) {
          Status = "Pending";
          EditFlag = true;
        }else if (value.is_closed == 1) {
          Status = "Open ";
          EditFlag = true;
        }
        else if (value.is_closed == 2) {
          Status = "Complete";
          EditFlag = false;
        }
        else if (value.is_closed == -1) {
          Status = "Cancel ";
          EditFlag = false;
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.order_no + "</td>";
        TableHTML += "<td>" + value.retailer_name + "</td>";
        TableHTML += "<td>" + value.salesuser_name + "</td>";
        TableHTML += "<td>" + value.dealer_name + "</td>";
        TableHTML += "<td>" + value.order_date + "</td>";
        TableHTML += "<td>" + value.no_of_items + "</td>";
        TableHTML += "<td>" + Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        // if not locked, let the user edit the entry and give access to Edit & Delete functionality
        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
            value.retailerorder_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\'' +
            value.retailerorder_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      // assign the html string to table body present in the search page
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [8], "Retailer Order List");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

function ShowAddEntry() {
  ShowContentDiv("Secondary", "RetailerOrderAdd", "", function () {
    // Initialization Code
    var currentDate = new Date();
    var formattedDate = currentDate.toISOString().slice(0, 10);
    $("#txtEntryOrderDate").val(formattedDate);

    $("#ddlEntryRetailerName").select2();
    $("#ddlEntryDealerName").select2();
    $("#ddlEntrySalesPersonName").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    GetMaster(
      "ddlEntryRetailerName",
      "Select Retailer Name",
      "GetRetailer",
      "",
      ""
    );
    GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");
    GetMaster(
      "ddlEntrySalesPersonName",
      "Select User Name",
      "GetSalesUser",
      "",
      ""
    );

    $("#divFooterDelete").hide();
  });
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function ShowEditEntry(action, retailerorder_id) {
  ShowContentDiv("Secondary", "RetailerOrderEdit", "", function () {
    // Initialization Code

    $("#ddlEntryRetailerName").select2();
    $("#ddlEntryDealerName").select2();
    $("#ddlEntrySalesPersonName").select2();

    $("#lblEntryId").html(retailerorder_id);
    $("#lblAction").html(action);

    $("#ddlEntryRetailerName").prop("disabled", true);
    $("#ddlEntrySalesPersonName").prop("disabled", true);
    $("#ddlEntryDealerName").prop("disabled", true);

    var APIEndPoint = "GetRetailerOrder";
    var Method_Name = "Get_One";
    var url = "/Secondary/RetailerOrder";
    var reqdata = {
      method_name: Method_Name,
      retailerorder_id: retailerorder_id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        if(res[0].is_closed == 1){
          $("#btn_Save").hide();
        }else{
          $("#btn_Save").show();
        }
        $("#txtEntryOrderDate").val(res[0].order_date);
        $("#txtEntryOrderNo").val(res[0].order_no);
        $("#txtEntryRemarks").val(res[0].remarks);
        GetMaster(
          "ddlEntryRetailerName",
          "Select Retailer Name",
          "GetRetailer",
          res[0].retailer_id,
          ""
        );
        GetMaster(
          "ddlEntryDealerName",
          "Select Dealer Name",
          "GetDealer",
          res[0].dealer_id,
          ""
        );
        GetMaster(
          "ddlEntrySalesPersonName",
          "Select User Name",
          "GetSalesUser",
          res[0].salesuser_id,
          ""
        );
        GetItemList(retailerorder_id);

        $("#divFooterDelete").show();
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

// save retailer order details - header
function SaveEntry() {
  $("#btn_Save").prop("disabled", false);
  // Validation code
  var Retailer_Id = $("#ddlEntryRetailerName").val();
  var Dealer_Id = $("#ddlEntryDealerName").val();
  var SalesUser_Id = $("#ddlEntrySalesPersonName").val();
  var Remarks = $("#txtEntryRemarks").val();

  var IsValid = 1;

  if (Retailer_Id == "") {
    IsValid = 0;
    $("#ddlEntryRetailerName").addClass("is-invalid state-invalid");
  }
  if (Dealer_Id == "") {
    IsValid = 0;
    $("#ddlEntryDealerName").addClass("is-invalid state-invalid");
  }
  if (SalesUser_Id == "") {
    IsValid = 0;
    $("#ddlEntrySalesPersonName").addClass("is-invalid state-invalid");
  }
  if (Remarks == "") {
    IsValid = 0;
    $("#txtEntryRemarks").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving if valid date is inserted
    var Method_Name = "Create";
    var RetailerOrder_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      RetailerOrder_Id = $("#lblEntryId").html();
    }
    var Is_Active = 0;
    var Is_Deleted = 0;
    var APIEndPoint = "SaveRetailerOrder";
    var url = "/Secondary/RetailerOrder";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      retailerorder_id: RetailerOrder_Id,

      retailer_id: Retailer_Id,
      dealer_id: Dealer_Id,
      salesuser_id: SalesUser_Id,
      remarks: Remarks,

      request_for: "Header",
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
          ShowEntrySuccess("Retailer Order " + result[0].result_description);
          ShowEditEntry("Edit", result[0].result_extra_key);
          $("#btn_Save").prop("disabled", false);
        } else {
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        ShowEntryError("Error : Retail Order details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  $("#btn_Save").prop("disabled", false);
  return;
}

// delete Retailer Order
function ShowDeleteEntry(RetailerOrder_Id) {
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
        SaveDeleteEntry(RetailerOrder_Id);
      }
    }
  );
}

function SaveDeleteEntry(RetailerOrder_Id) {
  // Write code to delete
  if (RetailerOrder_Id == "") {
    RetailerOrder_Id = $("#lblEntryId").html();
  }
  var APIEndPoint = "SaveRetailerOrder";
  var url = "/Secondary/RetailerOrder";
  var reqdata = {
    retailerorder_id: RetailerOrder_Id,
    method_name: "Delete",
    api_end_point: APIEndPoint,
    request_for: "Header",
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
        Show_Success_Toastr("Retailer Order details deleted successfully");
        CloseEntry();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : Retailer Order details not deleted");
    },
  });
}

function ShowModalEntry(Action, RetailerOrderItem_Id) {
  $("#btn_Modal_Add").prop("disabled", true);

  $("#txtModalQuantity").removeClass("is-invalid state-invalid");

  $("#modelEntryRetailerOrder")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#lblModalAction").text(Action);
  $("#lblModalId").text(RetailerOrderItem_Id);

  $("#ddlModalItem").select2();
  $("#ddlModalItemUOM").select2();

  // get then set rate of selected product to the Rate Input Field
  $("#ddlModalItem").on("change", function () {
    var Product_Id = $("#ddlModalItem").val();
    var Quantity = $("#txtModalQuantity").val();
    var MethodName = "GetProductRate";
    var url = "/Home/GetMasterData";
    var reqdata = {
      Method_Name: MethodName,
      ParentField_Id: Product_Id,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        //var res = JSON.parse(result);
        // set rate
        var product_rate = res[0].item_value;
        $("#txtModalRate").val(product_rate);
        var amount = CalculateAmount(Quantity, product_rate);
        $("#txtModalAmount").val(amount);
      },
      error: function () {
        Show_Error_Toastr("Error in fetching master data");
      },
    });
  });

  // change amount on quantity change
  $("#txtModalQuantity").on("change", function () {
    var quantity = $("#txtModalQuantity").val();
    var rate = $("#txtModalRate").val();
    var amount = CalculateAmount(quantity, rate);
    $("#txtModalAmount").val(amount);
  });

  if (Action == "Add") {
    // Reset Input fields
    $(".modal input, .modal select").val("");
    GetMaster("ddlModalItem", "Select Item", "GetProducts", "", "");
  } else {
    // if Action = edit/view
    // get single data from database
    var APIEndPoint = "GetRetailerOrder";
    var Method_Name = "Get_One_Item";
    var RetailerOrder_Id = $("#lblEntryId").text();
    var url = "/Secondary/RetailerOrder";
    var reqdata = {
      method_name: Method_Name,
      retailerorderitem_id: RetailerOrderItem_Id,
      retailerorder_id: RetailerOrder_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        GetMaster(
          "ddlModalItem",
          "Select Item",
          "GetProducts",
          res[0].product_id,
          ""
        );
        GetMaster(
          "ddlModalItemUOM",
          "Select UOM",
          "GetProductUOM",
          res[0].uom,
          res[0].product_id
        );
        $("#txtModalQuantity").val(res[0].quantity);
        $("#txtModalRate").val(res[0].rate);
        var amount = CalculateAmount(res[0].quantity, res[0].rate);
        $("#txtModalAmount").val(amount);

        $("#divFooterDelete").show();
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  }

  $("#btn_Modal_Add").prop("disabled", true);
  return;
}

// Reset values on hiding the modal
$("#modelEntryRetailerOrder").on("hidden.bs.modal", function (e) {
  $("#lblModalAction").text("");
  $("#lblModalId").text("");

  // Reset Input fields
  $(".modal input, .modal select").val("");
  var RetailerOrder_Id = $("#lblEntryId").text();
  GetItemList(RetailerOrder_Id);
});

// save retailer order details - item
function SaveItemEntry() {
  $("#btn_SaveItem").prop("disabled", false);
  // Validation code
  var Product_Id = $("#ddlModalItem").val();
  var Quantity = $("#txtModalQuantity").val();
  var UOM = $("#ddlModalItemUOM").val();

  var IsValid = 1;

  if (Product_Id == "") {
    IsValid = 0;
    $("#ddlModalItem").addClass("is-invalid state-invalid");
  }
  if (UOM == "") {
    IsValid = 0;
    $("#ddlModalItemUOM").addClass("is-invalid state-invalid");
  }
  if (Quantity == "" || Is_Valid_Number(Quantity) == false) {
    IsValid = 0;
    $("#txtModalQuantity").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving if valid date is inserted
    var Method_Name = "Create";
    var RetailerOrder_Id = $("#lblEntryId").html();
    var RetailerOrderItem_Id = "";
    var Action_Name = $("#lblModalAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      RetailerOrderItem_Id = $("#lblModalId").text();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var APIEndPoint = "SaveRetailerOrder";
    var url = "/Secondary/RetailerOrder";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      retailerorder_id: RetailerOrder_Id,
      retailerorderitem_id: RetailerOrderItem_Id,

      product_id: Product_Id,
      uom: UOM,
      quantity: Quantity,

      request_for: "Item",
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
          Show_Success_Toastr(
            "Retailer Order Item " + result[0].result_description
          );
          // ShowModalEntry("Edit",result[0].result_extra_key);
          $("#btn_SaveItem").prop("disabled", false);
          GetItemList(RetailerOrder_Id);

          $("#modelEntryRetailerOrder")
            .modal({
              backdrop: "static",
            })
            .modal("hide");
        } else {
          Show_Error_Toastr("Error : " + result[0].result_description);
          $("#btn_SaveItem").prop("disabled", false);
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Retail Order details not saved");
        $("#btn_SaveItem").prop("disabled", false);
      },
    });
  }
  $("#btn_SaveItem").prop("disabled", false);
  return;
}

function GetItemList(RetailerOrder_Id) {
  // disable search button to avoid multiple function calls
  ClearDataTable("tableItemList");
  // Get data from database and show in table
  if (RetailerOrder_Id == "") {
    RetailerOrder_Id = $("#lblEntryId").text();
  }
  $("#divItemList").show();
  var Method_Name = "Get_Item";
  var APIEndPoint = "GetRetailerOrder";
  var url = "/Secondary/RetailerOrder";
  // store data in object and send to the controller
  var reqdata = {
    method_name: Method_Name,
    retailerorder_id: RetailerOrder_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // extract values and create an html string to assign to html table
      var TableHTML = "";
      var EditFlag = true;

      $.each(res, function (data, value) {

        if (value.is_closed == 0) {
          EditFlag = true;
        } else {
          EditFlag = false;
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.product_id + "</td>";
        TableHTML += "<td>" + value.product_name + "</td>";
        TableHTML += "<td>" + value.uom + "</td>";
        TableHTML += "<td>" + value.quantity + "</td>";
        //TableHTML += "<td>" + value.rate + "</td>";
        //TableHTML += "<td>" + CalculateAmount(value.quantity, value.rate) + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";

        // if not locked, let the user edit the entry and give access to Edit & Delete functionality
        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowModalEntry(\'Edit\',\'' +
            value.retailerorderitem_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";

          // delete
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowDeleteItemEntry(\'' +
            value.retailerorderitem_id +
            "')\">";
          TableHTML += '<i class="fa fa-trash"></i>';
          TableHTML += "</a>";
        } else {
          // TableHTML +=
          //   '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowModalEntry(\'View\',\'' +
          //   value.retailerorderitem_id +
          //   "')\">";
          // TableHTML += '<i class="fa fa-eye"></i>';
          // TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      // assign the html string to table body present in the search page
      $("#tableItemEntry").html(TableHTML);
      SetDataTable("tableItemList", [4], "Retailer Order Item List");
    },
    error: function () {
      ShowEntryError(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });

  return;
}

// delete Retailer Order Item
function ShowDeleteItemEntry(RetailerOrderItem_Id) {
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
        SaveDeleteItemEntry(RetailerOrderItem_Id);
      }
    }
  );
}

function SaveDeleteItemEntry(RetailerOrderItem_Id) {
  // Write code to delete
  if (RetailerOrderItem_Id == "") {
    RetailerOrderItem_Id = $("#lblModalId").text();
  }
  var RetailerOrder_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveRetailerOrder";
  var url = "/Secondary/RetailerOrder";
  var reqdata = {
    retailerorder_id: RetailerOrder_Id,
    retailerorderitem_id: RetailerOrderItem_Id,
    method_name: "Delete",
    api_end_point: APIEndPoint,
    request_for: "Item",
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
        Show_Success_Toastr("Retailer Order Item details deleted successfully");
        GetItemList(RetailerOrder_Id);
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : Retailer Order Item details not deleted");
    },
  });
}

function CalculateAmount(quantity, rate) {
  var amount = parseFloat(quantity) * parseFloat(rate);
  return amount;
}

function changeDealer() {
  var dealerid = $("#ddlEntryDealerName").val();

  GetMaster(
    "ddlEntrySalesPersonName",
    "Select Sales User",
    "GetSalesUserbydealer",
    "",
    dealerid
  );

  GetMaster(
    "ddlEntryRetailerName",
    "Select Retailer Name",
    "GetRetailerByDealer",
    "",
    dealerid
  );
}

function GetProductUOMtList() {
  $("#ddlModalItemUOM")
    .empty()
    .append($("<option></option>").val("").html("Select UOM"));
  var Product_Id = $("#ddlModalItem").val();

  GetMaster("ddlModalItemUOM", "Select UOM", "GetProductUOM", "", Product_Id);
}
