var successfulCallbacks = 0;
$(document).ready(function () {
  $("#ddlSearchDealerName").select2();
  GetMaster("ddlSearchDealerName", "Select Dealer Name", "GetDealer", "", "");

  const style = document.createElement("style");
  document.head.appendChild(style);
  style.sheet.insertRule(
    "input::-webkit-inner-spin-button { -webkit-appearance: none; }",
    0
  );

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

  var ProdutList = [];
});

/* -----    -----      Search for data in database as per values provided       -----   ----- */
function GetSearchList() {
  // disable search button to avoid multiple function calls

  ClearDataTable("tableSearch");
  // Get data from database and show in table
  var Dealer_Id = $("#ddlSearchDealerName").val();
  var SearchPeriod = $("#txtSearchInquiryDate").val();

  var Is_Valid = 1;

  if (SearchPeriod == "") {
    Is_Valid = 0;
    $("#txtSearchInquiryDate").addClass("is-invalid state-invalid");
  }
  // if (Dealer_Id == "") {
  //   Is_Valid = 0;
  //   $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
  // }
  if (Is_Valid == 0) {
    Show_Error_Toastr(
      "Can't search. Please provide all the required information."
    );
    return;
  }

  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var APIEndPoint = "GetInquiry";
  var url = "/Inquiry/Inquiry";
  // store data in object and send to the controller
  var reqdata = {
    method_name: Method_Name,
    search_period: SearchPeriod,
    api_end_point: APIEndPoint,
    dealer_id: Dealer_Id,
  };
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
      var InquiryStatus = "";
      $.each(res, function (data, value) {
        EditFlag = false;

        if (value.inquiry_status == 1) {
          InquiryStatus = "Successfully Closed";
        } else if (value.inquiry_status == -1) {
          InquiryStatus = "Cancelled";
        } else if (value.inquiry_status == 0) {
          InquiryStatus = "Open";
          EditFlag = true;
        } else {
          InquiryStatus = "Not Defined";
        }
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.inquiry_no + "</td>";
        TableHTML += "<td>" + value.dealer_name + "</td>";
        TableHTML += "<td>" + value.retailer_name + "</td>";
        TableHTML += "<td>" + value.salesuser_name + "</td>";
        TableHTML += "<td>" + value.inquiry_date + "</td>";
        TableHTML += "<td>" + InquiryStatus + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        // if not locked, let the user edit the entry and give access to Edit & Delete functionality
        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
            value.inquiry_no + '\',\'' + value.dealer_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";

          //TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"ShowDeleteEntry('" + value.inquiry_no + "')\">";
          //TableHTML += "<i class=\"fa fa-trash\"></i>";
          //TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\'' +
            value.inquiry_no + '\',\'' + value.dealer_id +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      // assign the html string to table body present in the search page
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [7], "Sales Inquiry List");
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
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

function GetSalesUser() {
  var Retailer_Id = $("#ddlEntryRetailerName").val();
  var Dealer_Id = $("#ddlSearchDealerName").val();
  if (Dealer_Id == null || Dealer_Id == undefined || Dealer_Id == "") {
    Dealer_Id = $("#lblDealerId").html();
  }
  if (Retailer_Id == null || Retailer_Id == "" || Retailer_Id == undefined) {
    GetMaster(
      "ddlEntrySalesUser",
      "Select Sales User",
      "GetDealerSalesUser",
      "",
      Dealer_Id
    );
  }
  if (Retailer_Id != null || Retailer_Id != "" || Retailer_Id != undefined) {
    GetMasters(
      "ddlEntrySalesUser",
      "Select Sales User",
      "GetDealerRetailerSalesUser",
      "",
      Dealer_Id,
      Retailer_Id
    );
  }
}

function ShowAddEntry() {
  var Dealer_Id = $("#ddlSearchDealerName").val();
  if (Dealer_Id == "") {
    $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Please select Dealer Name");
    return;
  }

  ShowContentDiv("Inquiry", "InquiryEntry", "", function () {
    // Initialization Code
    var currentDate = new Date();
    var formattedDate = currentDate.toISOString().slice(0, 10);

    $("#txtEntryInquiryDate").val(formattedDate);
    $("#ddlEntrySalesUser").select2();
    $("#btn_Add_Item").hide();

    GetMaster(
      "ddlEntrySalesUser",
      "Select Sales User",
      "GetDealerSalesUser",
      "",
      Dealer_Id
    );

    $("#ddlEntryRetailerName").select2();
    GetMaster(
      "ddlEntryRetailerName",
      "Select Retailer Name",
      "GetDealerRetailer",
      "",
      Dealer_Id
    );

    /*$("#ddlEntryShipParty").select2();
        $("#ddlEntryBuyer").select2();
        $("#ddlEntryTransport").select2();
        $("#ddlEntryPayer").select2();
        $("#ddlEntryIncoTerm").select2();
        $("#ddlEntryPaymentTerm").select2();
        $("#ddlEntrySalesPerson").select2();*/

    $("#ddlEntryInquiryStatus").select2();
    GetMaster(
      "ddlEntryInquiryStatus",
      "Select Inquiry Status",
      "GetInquiryStatus",
      0,
      ""
    );
    getproducts();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();
  });
}

function getproducts() {
  var Method_Name = "Get_Product";
  var APIEndPoint = "GetInquiryProduct";
  var url = "/Inquiry/Inquiry";
  // store data in object and send to the controller
  var reqdata = {
    method_name: Method_Name,
    salesinquiry: "",
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      ProdutList = res;
    },
    error: function () { },
  });
}

function OnChnageSelectSalesUser() {
  var ProductId = $("#ddlModalItemCode").val();

  for (var i = 0; i <= ProdutList.length; i++) {
    if (
      ProdutList[i] != null ||
      ProdutList[i] != undefined ||
      ProdutList[i] != ""
    ) {
      if (ProdutList[i].item_id == ProductId) {
        $("#txtModalUOM").val(ProdutList[i].item_unit);
        return;
      }
    }
  }
}

function ChangePrice() {
  var Rate = $("#txtModalRate").val();
  var Quantity = $("#txtModalQuantity").val();

  $("#txtModalPrice").val(Rate * Quantity);
}

function ChangePriceZero() {
  $("#txtModalRate").val(0);
}

function ShowEditEntry(Action, SalesInquiry, Dealer_Id) {
  ShowContentDiv("Inquiry", "InquiryEntry", "", function () {
    // Initialization Code
    var currentDate = new Date();
    var formattedDate = currentDate.toISOString().slice(0, 10);
    $("#txtEntryInquiryDate").val(formattedDate);

    //modal dropdown
    /*$("#ddlEntryShipParty").select2();
        $("#ddlEntryBuyer").select2();
        $("#ddlEntryTransport").select2();
        $("#ddlEntryPayer").select2();
        $("#ddlEntryIncoTerm").select2();
        $("#ddlEntryPaymentTerm").select2();
        $("#ddlEntrySalesPerson").select2();
        */
    getproducts();
    // $("#ddlEntrySalesUser").select2();
    // GetMaster("ddlEntrySalesUser", "Select Sales User", "GetSalesUser", "", "");

    $("#lblEntryId").html(SalesInquiry);
    $("#lblAction").html(Action);
    $("#lblDealerId").html(Dealer_Id);

    if (Action == "Edit") {
      $("#btn_Add_Item").show();
    }

    // GetMaster("ddlAddBranch", "", "GetBranch", "383", "");
    // GetMaster("ddlEntryState", "Select State", "GetState", "", "");
    //GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");

    var Method_Name = "Get_One";
    var APIEndPoint = "GetInquiry";
    var url = "/Inquiry/Inquiry";
    // store data in object and send to the controller
    var reqdata = {
      method_name: Method_Name,
      salesinquiry: SalesInquiry,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result)[0];
        $("#txtEntryInquiryDate").val(res.inquiry_date);
        //$("#txtEntryInquirySalesArea").val(res.salesarea);
        //$("#txtEntryDestination").val(res.destination);
        $("#txtEntryInquiryNo").val(SalesInquiry);
        $("#txtEntryCustReference").val(res.customer_reference);
        $("#txtEntryInquirySalesAreaNote").val(res.salesnote);




        $("#ddlEntryRetailerName").select2();
        GetMaster(
          "ddlEntryRetailerName",
          "Select Retailer Name",
          "GetDealerRetailer",
          res.retailer_id,
          res.dealer_id
        );


        $("#ddlEntryInquiryStatus").select2();
        GetMaster(
          "ddlEntryInquiryStatus",
          "Select Inquiry Status",
          "GetInquiryStatus",
          res.inquiry_status,
          ""
        );

        $("#ddlEntrySalesUser").select2();
        GetMaster(
          "ddlEntrySalesUser",
          "Select Sales User",
          "GetSalesUser",
          res.salesuser_id,
          ""
        );


        $("#ddlEntrySalesUser").prop("disabled", true);

        $("#ddlEntryRetailerName").prop("disabled", true);

        if (res.is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }

        if (Action == "View") {
          $("#txtEntryCustReference").prop("disabled", true);
          $("#txtEntryInquirySalesAreaNote").prop("disabled", true);
          $("#ddlEntryInquiryStatus").prop("disabled", true);
          $("#chkEntryStatus").prop("disabled", true);
          $("#ddlEntrySalesUser").prop("disabled", true);
          $("#ddlEntryRetailerName").prop("disabled", true);
        } else {
          $("#txtEntryCustReference").prop("disabled", false);
          $("#txtEntryInquirySalesAreaNote").prop("disabled", false);
          $("#ddlEntryInquiryStatus").prop("disabled", false);
          $("#chkEntryStatus").prop("disabled", false);
        }

        GetItemList(Action, SalesInquiry);
      },
      error: function () {
        Show_Error_Toastr(
          "Error in fetching details from server.",
          res.result_description
        );
        $("#btn_Search").prop("disabled", false);
      },
    });

    $("#divFooterDelete").show();
  });
}

function SaveEntry() {
  // Validation code
  //var SalesArea = $("#txtEntryInquirySalesArea").val();
  //var Destination = $("#txtEntryDestination").val();
  var Cust_Reference = $("#txtEntryCustReference").val();
  var Sales_Note = $("#txtEntryInquirySalesAreaNote").val();
  var InquiryStatus_Id = $("#ddlEntryInquiryStatus").val();
  var Dealer_Id = $("#ddlSearchDealerName").val();

  if (Dealer_Id == null || Dealer_Id == undefined || Dealer_Id == "") {
    Dealer_Id = $("#lblDealerId").html();
  }

  var SalesUserId = $("#ddlEntrySalesUser").val();
  var RetailerId = $("#ddlEntryRetailerName").val();

  var IsValid = 1;

  if (SalesUserId == "") {
    IsValid = 0;
    $("#ddlEntrySalesUser").addClass("is-invalid state-invalid");
  }

  /*
    if (Destination == "") {
        IsValid = 0;
        $("#txtEntryDestination").addClass("is-invalid state-invalid");
    }
    if (Cust_Reference == "") {
        IsValid = 0;
        $("#txtEntryCustReference").addClass("is-invalid state-invalid");
    }
    if (Sales_Note == "") {
        IsValid = 0;
        $("#txtEntryInquirySalesAreaNote").addClass("is-invalid state-invalid");
    }*/

  if (InquiryStatus_Id == "") {
    //IsValid = 0;
    //$("#ddlEntryInquiryStatus").addClass("is-invalid state-invalid");
    InquiryStatus_Id = 0;
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    //Start Saving
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Create";
    var SalesInquiry = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      SalesInquiry = $("#lblEntryId").html();
    }
    var Is_Active = 1;
    if (document.getElementById("chkEntryStatus").checked == false) {
      Is_Active = 0;
    }
    var Is_Deleted = 0;
    var url = "/Inquiry/Inquiry";
    var APIEndPoint = "SaveInquiry";

    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      salesinquiry: SalesInquiry,
      //"salesarea": SalesArea,
      customerreference: Cust_Reference,
      //"destination": Destination,
      salesnote: Sales_Note,
      inquiry_status: InquiryStatus_Id,
      dealer_id: Dealer_Id,
      api_end_point: APIEndPoint,
      sales_person: SalesUserId,
      salesuser_id: SalesUserId,
      retailer_id: RetailerId,
    };

    //Save
    return $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,

      success: function (result) {
        var res = JSON.parse(result)[0];
        if (res.result_id == 1) {
          // Show Success Message
          $("#lblEntryId").html(res.result_extra_key);
          $("#lblAction").html("Edit");

          $("#btn_Add_Item").show();

          ShowEntrySuccess("Sales Inquiry details saved successfully");

          $("#txtEntryInquiryNo").val(res.result_extra_key);
          ShowEditEntry("Edit", res.result_extra_key);
          // if (InquiryStatus_Id == 1 || InquiryStatus_Id == -1) {
          //   GetItemList("View", res.result_extra_key);
          // }

          // return res.result_extra_key;
        } else {
          ShowEntryError("Error : " + res.result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Sales Inquiry details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}

function ShowDeleteEntry(SalesInquiry) {
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
        SaveDeleteEntry(SalesInquiry);
      }
    }
  );
}

function SaveDeleteEntry(SalesInquiry) {
  var APIEndPoint = "SaveInquiry";
  var url = "/Inquiry/Inquiry";

  var reqdata = {
    salesinquiry: SalesInquiry,
    method_name: "Delete",
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result)[0];
      if (res.result_id == 1) {
        // Show Success Message
        Show_Success_Toastr("Sales Inquiry details deleted successfully");
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + res.result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Sales Inquiry details not deleted");
    },
  });
}

function GetItemList(Action, SalesInquiry) {
  ClearDataTable("tableItem");
  // Get data from database and show in table

  var Method_Name = "Get_Item";
  var APIEndPoint = "GetInquiry";
  var url = "/Inquiry/Inquiry";
  // store data in object and send to the controller
  var reqdata = {
    method_name: Method_Name,
    salesinquiry: SalesInquiry,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // send message if there's no result
      if (res.length == 0) {
        Show_Error_Toastr("Item Data not found.");
        return;
      }
      // extract values and create an html string to assign to html table
      var TableHTML = "";
      var EditFlag = true;

      if (Action == "View") {
        $("#btn_Add_Item").hide();
        EditFlag = false;
      } else {
        $("#btn_Add_Item").show();
      }

      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.item_id + "</td>";
        TableHTML += "<td>" + value.item_description + "</td>";
        TableHTML += "<td>" + value.rate + "</td>";
        TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML += "<td>" + value.uom + "</td>";
        TableHTML += "<td>" + value.price + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        // if not locked, let the user edit the entry and give access to Edit & Delete functionality
        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowItemEditEntry(\'Edit\', \'' +
            SalesInquiry +
            "','" +
            value.item_id +
            "','" +
            value.rate +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";

          //TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"ShowItemDeleteEntry('" + value.item_id + "')\">";
          //TableHTML += "<i class=\"fa fa-trash\"></i>";
          //TableHTML += "</a>";
        } else {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowItemEditEntry(\'View\',\'' +
            SalesInquiry +
            "','" +
            value.item_id +
            "','" +
            value.rate +
            "')\">";
          TableHTML += '<i class="fa fa-eye"></i>';
          TableHTML += "</a>";
        }
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      // assign the html string to table body present in the search page
      $("#tableEntryItem").html(TableHTML);
      SetDataTable("tableItem", [7], "Sales Inquiry Item List");
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
  // enable search button to let user make function calls
  return;
}

function ShowItemEditEntry(Action, SalesInquiry, Item_Id, rate) {
  // Initialization Code
  $("#modelEntryInquiryItem").on("hidden.bs.modal", function (e) {
    successfulCallbacks = 0;
    $("#lblAction").html("");
    $("#ddlModalProductGroup").val("");
    $("#ddlModalItemCode").val("");
    $("#txtModalRate").val("");
    $("#txtModalQuantity").val("");
    $("#txtModalUOM").val("");
    $("#txtModalPrice").val("");

    $("#txtModalSAPRate").val("");
    $("#txtModalSAPUOM").val("");
    $("#txtModalSAPQuantity").val("");

    $("#txtModalSAPRate").removeClass("is-invalid state-invalid");
    $("#txtModalSAPUOM").removeClass("is-invalid state-invalid");
    $("#txtModalSAPQuantity").removeClass("is-invalid state-invalid");

    $("#ddlModalProductGroup").removeClass("is-invalid state-invalid");
    $("#ddlModalItemCode").removeClass("is-invalid state-invalid");
    $("#txtModalRate").removeClass("is-invalid state-invalid");

    $("#txtModalQuantity").removeClass("is-invalid state-invalid");
    $("#txtModalUOM").removeClass("is-invalid state-invalid");
    $("#txtModalPrice").removeClass("is-invalid state-invalid");

    $("#txtEntryNote").val("");
    $("#txtEntryNote").removeClass("is-invalid state-invalid");
  });

  OpenModal("Edit");

  //modal dropdown
  $("#ddlModalItemCode").select2();
  $("#ddlModalProductGroup").select2();
  $("#txtModalUOM").select2();

  $("#lblItemEntryId").html(Item_Id);
  $("#lblItemAction").html(Action);
  $("#txtModalRate").val(rate);

  // GetMaster("ddlModalItemCode", "", "GetProducts", "", "");
  // GetMaster("ddlEntryState", "Select State", "GetState", "", "");
  //GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");

  var Method_Name = "Get_One_Item";
  var APIEndPoint = "GetInquiry";
  var url = "/Inquiry/Inquiry";
  // store data in object and send to the controller
  var reqdata = {
    method_name: Method_Name,
    salesinquiry: SalesInquiry,
    item_id: Item_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result)[0];
      // GetMaster(
      //   "ddlModalItemCode",
      //   "Select Product",
      //   "GetProductByProductGroup",
      //   res.item_id,
      //   res.productgroup_id
      // );
      GetMaster(
        "ddlModalProductGroup",
        "Select Product Group",
        "GetProductsfortarget",
        res.productgroup_id,
        ""
      );

      GetMaster(
        "ddlModalItemCode",
        "Select Product",
        "GetProductByProductGroup",
        res.item_id,
        res.productgroup_id
      );

      GetMaster(
        "txtModalUOM",
        "Select UOM",
        "GetProductUOM",
        res.uom,
        res.item_id
      );

      // var totalCallbacks = 1;

      // GetMasterCallback(
      //   "ddlModalItemCode",
      //   "Select Product",
      //   "GetProductByProductGroup",
      //   res.item_id,
      //   res.productgroup_id,
      //   function (success) {
      //     if (success) {
      //       successfulCallbacks++;
      //       checkCallbacks(totalCallbacks);
      //     }
      //   }
      // );



      //   GetMaster(
      //     "ddlModalItemCode",
      //     "Select Product",
      //     "GetProducts",
      //     res.item_id,
      //     ""
      //   );
      //$("#ddlModalItemCode").val(res.item_id);
      $("#txtModalRate").val(res.rate);
      $("#txtModalQuantity").val(res.quantity);

      $("#txtEntryNote").val(res.lrdetails);
      //   $("#txtModalUOM").val(res.uom);


      $("#txtModalPrice").val(res.price);

      if (Action == "View") {
        $("#ddlModalItemCode").prop("disabled", true);
        $("#txtModalQuantity").prop("disabled", true);
        $("#btn_Save_Item").hide();
      } else {
        $("#ddlModalItemCode").prop("disabled", false);
        $("#txtModalQuantity").prop("disabled", false);
        $("#btn_Save_Item").show();
      }
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res.result_description
      );
    },
  });

  return;
}

function checkCallbacks(totalCallbacks) {
  if (successfulCallbacks === totalCallbacks) {
    GetRate();
  }
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}
function GetProductList() {
  $("#ddlModalItemCode")
    .empty()
    .append($("<option></option>").val("").html("All Product"));

  $("#txtModalUOM")
    .empty()
    .append($("<option></option>").val("").html("Select UOM"));

  $("#txtModalRate").val("");
  $("#txtModalPrice").val("");
  $("#txtModalSAPRate").val("");
  $("#txtModalSAPUOM").val("");
  $("#txtModalSAPQuantity").val("");

  var ProductGroup_Id = $("#ddlModalProductGroup").val();

  GetMaster(
    "ddlModalItemCode",
    "Select Product",
    "GetProductByProductGroup",
    "",
    ProductGroup_Id
  );
}

function GetProductUOMtList() {
  $("#txtModalUOM")
    .empty()
    .append($("<option></option>").val("").html("All UOM"));
  $("#txtModalRate").val("");
  $("#txtModalPrice").val("");
  $("#txtModalSAPRate").val("");
  $("#txtModalSAPUOM").val("");
  $("#txtModalSAPQuantity").val("");
  var Product_Id = $("#ddlModalItemCode").val();

  GetMaster("txtModalUOM", "Select UOM", "GetProductUOM", "", Product_Id);
}

function OpenModal(Action) {
  $("#ddlModalItemCode").select2();
  if (Action == "Add") {
    $("#lblItemEntryId").html("");
    $("#lblItemAction").html("Add");
    $("#ddlModalProductGroup").select2();
    $("#txtModalUOM").select2();
    GetMaster(
      "ddlModalProductGroup",
      "Select Product Group",
      "GetProductsfortarget",
      "",
      ""
    );

    // GetMaster("ddlModalItemCode", "Select Product", "GetProducts", "", "");
  }
  $("#ddlModalProductGroup").val("");
  $("#ddlModalItemCode").val("");
  $("#txtModalRate").val("");
  $("#txtModalQuantity").val("");
  $("#txtModalUOM").val("");
  $("#txtModalPrice").val("");
  $("#txtModalSAPRate").val("");
  $("#txtModalSAPUOM").val("");
  $("#txtModalSAPQuantity").val("");
  $("#txtEntryNote").val("");
  $("#modelEntryInquiryItem")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  return;
}

// item save and delete

function SaveItemEntry() {
  // Validation code
  var Item_Id = $("#ddlModalItemCode").val();
  var Rate = $("#txtModalRate").val();
  var Quantity = $("#txtModalQuantity").val();
  var Note = $("#txtEntryNote").val();
  var UOM = $("#txtModalUOM").val();
  var Price = $("#txtModalPrice").val();

  var IsValid = 1;

  if (Item_Id == "") {
    IsValid = 0;
    $("#ddlModalItemCode").addClass("is-invalid state-invalid");
  }
  if (Quantity == "") {
    IsValid = 0;
    $("#txtModalQuantity").addClass("is-invalid state-invalid");
  }
  if (UOM == "") {
    IsValid = 0;
    $("#txtModalUOM").addClass("is-invalid state-invalid");
  }

  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    //Start Saving
    $("#btn_Save_Item").prop("disabled", true);

    var SalesInquiry = $("#lblEntryId").html();

    //  if($("#lblAction").html() != "Edit")
    // SaveEntry();
    //SalesInquiry = SaveEntry();
    //$.when(SaveEntry()).done(function (result) {

    //    SalesInquiry = JSON.parse(result)[0].result_extra_key;

    //if (SalesInquiry == "") {
    //    Show_Error_Toastr("Can't save. Enter all the header details.");
    //    $("#modelEntryInquiryItem")
    //        .modal({
    //            backdrop: "static",
    //        })
    //        .modal("hide");
    //    $("#btn_Save_Item").prop('disabled', false);
    //    return;
    //}
    //else {
    var Method_Name = "Create_Item";
    var Action_Name = $("#lblItemAction").html();
    var Entry_Item_Id = "";
    if (Action_Name == "Edit") {
      Method_Name = "Update_Item";
      Entry_Item_Id = $("#lblItemEntryId").html();
    }
    var Is_Active = 1;
    var Is_Deleted = 0;
    var url = "/Inquiry/Inquiry";
    APIEndPoint = "SaveInquiry";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      salesinquiry: SalesInquiry,
      api_end_point: APIEndPoint,
      entry_item_id: Entry_Item_Id,
      item_id: Item_Id,
      rate: Rate,
      uom: UOM,
      quantity: Quantity,
      price: Price,
      lrdetails: Note,
    };

    //Save
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,

      success: function (result) {
        var res = JSON.parse(result)[0];

        if (res.result_id == 1) {
          // Show Success Message
          $("#lblItemEntryId").html(Item_Id);
          $("#lblItemAction").html("Edit");
          Show_Success_Toastr("Sales Inquiry Item details saved successfully");
          GetItemList("Edit", SalesInquiry);
          // hide modal
          $("#modelEntryInquiryItem")
            .modal({
              backdrop: "static",
            })
            .modal("hide");
          successfulCallbacks = 0;

          $("#btn_Save_Item").prop("disabled", false);
        } else {
          Show_Error_Toastr("Error : " + res.result_description);
          $("#btn_Save_Item").prop("disabled", false);
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Sales Inquiry Item details not saved");
        $("#btn_Save_Item").prop("disabled", false);
      },
    });
  }
  /*            }*/
  //);
}
//$("#btn_Save_Item").prop('disabled', false);
//return;
//}

function ShowItemDeleteEntry(Item_Id) {
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
        SaveItemDeleteEntry(Item_Id);
      }
    }
  );
}

function SaveItemDeleteEntry(Item_Id) {
  var APIEndPoint = "SaveInquiry";
  var url = "/Inquiry/Inquiry";
  var SalesInquiry = $("#lblEntryId").html();
  var reqdata = {
    salesinquiry: SalesInquiry,
    item_id: Item_Id,
    method_name: "Delete_Item",
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result)[0];
      if (res.result_id == 1) {
        // Show Success Message
        Show_Success_Toastr("Sales Inquiry Item details deleted successfully");
        GetItemList("Edit", SalesInquiry);
      } else {
        Show_Error_Toastr("Error : " + res.result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Sales Inquiry Item details not deleted");
    },
  });
}

function ShowViewEntry() {
  ShowContentDiv("Inquiry", "InquiryViewEntry", "", function () {
    // Initialization Code
    var currentDate = new Date();
    var formattedDate = currentDate.toISOString().slice(0, 10);
    $("#txtEntryInquiryDate").val(formattedDate);

    // $("#ddlModalItemCode").select2();
  });
}

function GetRate() {
  Show_Loader();
  debugger;
  var APIEndPoint = "GetProductRateByDealerId";
  var Method_Name = "Get";
  var Product_Id = $("#ddlModalItemCode").val();
  var Dealer_Id = $("#ddlSearchDealerName").val();

  if (Dealer_Id == null || Dealer_Id == undefined || Dealer_Id == "") {
    Dealer_Id = $("#lblDealerId").html();
  }
  var url = "/Masters/Product";

  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    dealer_id: Dealer_Id,
    product_id: Product_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (res) {
      var result = JSON.parse(res);
      var set_result = JSON.parse(result);

      if (set_result.code == 1) {
        Hide_Loader();
        $("#txtModalRate").val(set_result.ConditionRateValue);
        $("#txtModalSAPRate").val(set_result.ConditionRateValue);
        $("#txtModalSAPUOM").val(set_result.ConditionQuantityUnit);
        $("#txtModalSAPQuantity").val(set_result.ConditionQuantity);
        ChangePrice();
      } else {
        Hide_Loader();
        $("#txtModalRate").val(0);
        $("#txtModalSAPRate").val(0);
        $("#txtModalSAPUOM").val("");
        $("#txtModalSAPQuantity").val("");
        ChangePrice();
        Show_Error_Toastr("Error :" + set_result.ConditionRateValue);
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}
