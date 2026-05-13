$(document).ready(function () {
  $("#ddlSearchSalesUser").select2();
  $("#ddlSearchFinancialYear").select2();

  GetMaster("ddlSearchSalesUser", "Select Sales User", "GetSalesUser", "", "");
  GetMaster(
    "ddlSearchFinancialYear",
    "Select Financial Year",
    "GetFinancialYear",
    "",
    ""
  );

  const style = document.createElement("style");
  document.head.appendChild(style);
  style.sheet.insertRule(
    "input::-webkit-inner-spin-button { -webkit-appearance: none; }",
    0
  );
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table

  var SearchSalesUser_Id = $("#ddlSearchSalesUser").val();
  // var SearchFinancialYear_Id = $("#ddlSearchFinancialYear").val();
  var IsValid = 1;
  if (SearchSalesUser_Id == "") {
    IsValid = 0;
    $("#ddlSearchSalesUser").addClass("is-invalid state-invalid");
  }
  /*
    if (SearchFinancialYear_Id == "") {
        IsValid = 0;
        $("#ddlSearchFinancialYear").addClass("is-invalid state-invalid");
    } */
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't search for data.");
    return;
  }
  var Method_Name = "Get";
  var APIEndPoint = "GetTarget";
  var url = "/Transactions/Targets";

  var reqdata = {
    method_name: Method_Name,
    salesuser_id: SearchSalesUser_Id,
    // "financialyear_id": SearchFinancialYear_Id,
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
        // return;
      }
      // Fill data in table
      var TableHTML = "";

      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.month_year_name + "</td>";
        // TableHTML += "<td>" + value.productgroup_id + "</td>";
        // TableHTML += "<td>" + value.productgroup_name + "</td>";
        // TableHTML += "<td>" + value.product_name + "</td>";
        // TableHTML += "<td>" + value.productuom + "</td>";
        TableHTML += "<td>" + value.dealer_name + "</td>";
        TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
          value.target_id +
          "')\">";
        TableHTML += '<i class="fa fa-pencil"></i>';
        TableHTML += "</a>";
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableData").html(TableHTML);
      SetDataTable("tableSearch", [4], "Targets");
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
  $("#btn_Search").prop("disabled", false);
  return;
}

function ShowAddEntry() {
  var SalesUserName = $("#ddlSearchSalesUser").val();
  if (
    SalesUserName == "" ||
    SalesUserName == undefined ||
    SalesUserName == null
  ) {
    $("#ddlSearchSalesUser").addClass("is-invalid state-invalid");
    Show_Error_Toastr("Sales User Name");
    return;
  } else {
    ShowContentDiv("Transactions", "TargetsEntry", "", function () {
      $("#lblEntryId").html(""); //No id first
      $("#lblAction").html("Add");
      $("#divFooterDelete").hide();
      $("#divTabs").hide();

      var nextdate = new Date(Date.now());
      var newdate = nextdate.toISOString().slice(0, 7);
      $("#txtEntryMonthYear").val(newdate);

      $("#ddlEntryDealer").select2();
      var salesdserid = $("#ddlSearchSalesUser").val();

      GetMaster(
        "ddlEntryDealer",
        "Select Dealer Name",
        "GetDealersBySalesuser",
        "",
        salesdserid
      );

      const $monthInput = $("#txtEntryMonthYear");
      const today = new Date();
      const currentMonth = today.getMonth() + 1; // Add 1 because getMonth() returns zero-based month (0-11)
      const currentYear = today.getFullYear();

      // Set min attribute to disable past months
      $monthInput.attr(
        "min",
        `${currentYear}-${currentMonth.toString().padStart(2, "0")}`
      );
    });
  }
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  // Validation code
  var SalesUser_Id = $("#ddlSearchSalesUser").val();
  var Dealer_Id = $("#ddlEntryDealer").val();
  // var ProductGroup_Id = $("#ddlEntryProductGroup").val();
  // var Quantity = $("#txtEntryQuantity").val().trim();
  var Month_Year = $("#txtEntryMonthYear").val();

  // var Product_Id = $("#ddlModalItemCode").val();
  // var UOM = $("#txtModalUOM").val();

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;
  var IsValid = 1;

  if (Dealer_Id == "") {
    IsValid = 0;
    $("#ddlEntryDealer").addClass("is-invalid state-invalid");
  }
  // if (ProductGroup_Id == "") {
  //   IsValid = 0;
  //   $("#ddlEntryProductGroup").addClass("is-invalid state-invalid");
  // }
  // if (Product_Id == "") {
  //   IsValid = 0;
  //   $("#ddlModalItemCode").addClass("is-invalid state-invalid");
  // }
  // if (UOM == "") {
  //   IsValid = 0;
  //   $("#txtModalUOM").addClass("is-invalid state-invalid");
  // }
  // if (Quantity == "" || Is_Valid_Number(Quantity) == false) {
  //   IsValid = 0;
  //   $("#txtEntryQuantity").addClass("is-invalid state-invalid");
  // }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving

    $("#btn_Save").prop("disabled", true);

    var FullDate = Month_Year + "-01";

    var APIEndPoint = "SaveTarget";
    var Method_Name = "Create";
    var Target_Id = "";
    var Action_Name = $("#lblAction").text();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Target_Id = $("#lblEntryId").text();
    }
    var Is_Deleted = 0;
    var url = "/Transactions/Targets";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      target_id: Target_Id,
      salesuser_id: SalesUser_Id,
      dealer_id: Dealer_Id,
      target_date: FullDate,
      type: "Header",
    };

    console.log(reqdata);
    // return;

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
          Show_Success_Toastr("Target " + result[0].result_description);
          // $("#lblEntryId").html(result[0].result_extra_key);
          // $("#lblAction").html("Edit");
          // $("#divFooterDelete").show();
          ShowEditEntry(result[0].result_extra_key);
        } else {
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Target details not saved");
      },
    });
  }

  return;
}

function ShowEditEntry(Target_Id) {
  // console.log(Target_Id);

  ShowContentDiv("Transactions", "TargetsEntry", "", function () {
    $("#modelTargets").on("hidden.bs.modal", function (e) {
      $("#ddlEntryProductGroup").val("");
      $("#ddlModalItemCode").val("");
      $("#txtModalUOM").val("");
      $("#txtEntryQuantityItem").val("");
      $("#lblEntryIdItem").html("");
      $("#lblActionItem").html("");
    });

    $("#ddlEntryDealer").select2();
    $("#divFooterDelete").show();
    $("#divTabs").show();
    var salesdserid = $("#ddlSearchSalesUser").val();

    var APIEndPoint = "GetTarget";
    var Method_Name = "Get_One";
    var url = "/Transactions/Targets";
    var reqdata = {
      method_name: Method_Name,
      target_id: Target_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        // res[0].is_locked
        if (res.length == 0) {
          Show_Error_Toastr("Data not found.");
          return;
        }
        $("#btn_Save").prop("disabled", false);
        $("#lblEntryId").html(res[0].target_id);
        $("#lblAction").html("Edit");
        GetMaster(
          "ddlEntryDealer",
          "Select Dealer Name",
          "GetDealersBySalesuser",
          res[0].dealer_id,
          salesdserid
        );
        $("#txtEntryMonthYear").val(res[0].month_year);
        $("#txtEntryQuantity").val(res[0].quantity);

        if (res[0].is_active == "0") {
          document.getElementById("chkEntryStatus").checked = false;
        } else {
          document.getElementById("chkEntryStatus").checked = true;
        }
        GetSearchListIem(res[0].target_id);
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

function OpenModal(action, entry_id) {
  $("#lblActionItem").html(action);
  $("#lblEntryIdItem").html(entry_id);

  $("#modelTargets")
    .modal({
      backdrop: "static",
    })
    .modal("show");

  $("#ddlEntryProductGroup").select2();
  $("#ddlModalItemCode").select2();
  $("#txtEntryQuantityItem").val("");
  $("#btn_Save_Item").prop("disabled", false);
  $("#txtModalUOM").select2();
  var Dealerid = $("#ddlEntryDealer").val();

  GetMaster(
    "ddlEntryProductGroup",
    "Select Product Group",
    "GetProductsfortarget",
    "",
    Dealerid
  );
}

function GetProductList() {
  $("#ddlModalItemCode")
    .empty()
    .append($("<option></option>").val("").html("All Product"));
  var ProductGroup_Id = $("#ddlEntryProductGroup").val();

  GetMaster(
    "ddlModalItemCode",
    "Select Product",
    "GetProductByProductGroup",
    "",
    ProductGroup_Id
  );
}

function GetProductUOMtList() {
  // $("#txtModalUOM")
  //   .empty()
  //   .append($("<option></option>").val("").html("All UOM"));
  // var Product_Id = $("#ddlModalItemCode").val();

  // GetMaster("txtModalUOM", "Select UOM", "GetProductUOM", "", Product_Id);

  $("#txtModalUOM")
    .empty()
    .append($("<option></option>").val("").html("All UOM"));
  var Product_Id = $("#ddlModalItemCode").val();

  var Method_Name = "Get_Product";
  var APIEndPoint = "GetTarget";
  var url = "/Transactions/Targets";

  var reqdata = {
    method_name: Method_Name,
    entry_id: Product_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);

      // console.log(res[0].productuom);

      GetMaster(
        "txtModalUOM",
        "Select UOM",
        "GetProductUOM",
        res[0].productuom,
        Product_Id
      );
    },
    error: function () {},
  });
}

function SaveEntryItem() {
  // Validation code
  var SalesUser_Id = $("#ddlSearchSalesUser").val();
  var Dealer_Id = $("#ddlEntryDealer").val();
  var ProductGroup_Id = $("#ddlEntryProductGroup").val();
  var Quantity = $("#txtEntryQuantityItem").val().trim();
  var Month_Year = $("#txtEntryMonthYear").val();

  var Product_Id = $("#ddlModalItemCode").val();
  var UOM = $("#txtModalUOM").val();

  var Is_Active = 1;
  if (document.getElementById("chkEntryStatus").checked == false) {
    Is_Active = 0;
  }
  var Is_Deleted = 0;
  var IsValid = 1;

  if (Dealer_Id == "") {
    IsValid = 0;
    $("#ddlEntryDealer").addClass("is-invalid state-invalid");
  }
  if (ProductGroup_Id == "") {
    IsValid = 0;
    $("#ddlEntryProductGroup").addClass("is-invalid state-invalid");
  }
  if (Product_Id == "") {
    IsValid = 0;
    $("#ddlModalItemCode").addClass("is-invalid state-invalid");
  }
  if (UOM == "") {
    IsValid = 0;
    $("#txtModalUOM").addClass("is-invalid state-invalid");
  }
  if (Quantity == "" || Is_Valid_Number(Quantity) == false) {
    IsValid = 0;
    $("#txtEntryQuantity").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving

    $("#btn_Save_Item").prop("disabled", true);

    var FullDate = Month_Year + "-01";

    var APIEndPoint = "SaveTarget";
    var Method_Name = "Create";
    var Target_Id = $("#lblEntryId").text();
    var Entry_Id = "";
    var Action_Name = $("#lblActionItem").text();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Entry_Id = $("#lblEntryIdItem").text();
    }
    var Is_Deleted = 0;
    var url = "/Transactions/Targets";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,
      entry_id: Entry_Id,
      target_id: Target_Id,
      salesuser_id: SalesUser_Id,
      productgroup_id: ProductGroup_Id,
      product_id: Product_Id,
      productuom: UOM,
      dealer_id: Dealer_Id,
      target_date: FullDate,
      type: "Item",
      quantity: Quantity,
    };

    console.log(reqdata);
    // return;

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
          Show_Success_Toastr("Target " + result[0].result_description);
          $("#modelTargets").modal("hide");
          ShowEditEntry(Target_Id);
        } else {
          Show_Error_Toastr("Error : " + result[0].result_description);
          $("#modelTargets").modal("hide");
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Target details not saved");
        $("#modelTargets").modal("hide");
      },
    });
  }

  return;
}

function GetSearchListIem(Target_Id) {
  ClearDataTable("tableList");
  // var Target_Id = $("#lblEntryId").text();
  var Method_Name = "Get_Item";
  var APIEndPoint = "GetTarget";
  var url = "/Transactions/Targets";

  var reqdata = {
    method_name: Method_Name,
    target_id: Target_Id,
    api_end_point: APIEndPoint,
  };
  console.log(reqdata);
  // return;

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
        // return;
      }
      // Fill data in table
      var TableHTML = "";

      $.each(res, function (data, value) {
        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

        TableHTML += "<td>" + value.productgroup_id + "</td>";
        TableHTML += "<td>" + value.productgroup_name + "</td>";
        TableHTML += "<td>" + value.product_name + "</td>";
        TableHTML += "<td>" + value.productuom + "</td>";

        TableHTML += "<td>" + value.quantity + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntryItem(\'' +
          value.entry_id +
          "')\">";
        TableHTML += '<i class="fa fa-pencil"></i>';
        TableHTML += "</a>";
        TableHTML +=
          '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowDeleteEntryItem(\'' +
          value.entry_id +
          "')\">";
        TableHTML += '<i class="fa fa-trash"></i>';
        TableHTML += "</a>";
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });
      $("#tableEntry").html(TableHTML);
      SetDataTable("tableList", [4], "Targets");
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
  $("#btn_Save_Item").prop("disabled", true);

  var APIEndPoint = "SaveTarget";
  var Method_Name = "Delete";
  var Target_Id = $("#lblEntryId").text();

  var url = "/Transactions/Targets";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,

    target_id: Target_Id,
    type: "Header",
  };

  console.log(reqdata);
  // return;

  //Save
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,

    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Target details not saved");
    },
  });

  return;
}

function ShowDeleteEntryItem(Entry_id) {
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
        SaveDeleteEntryItem(Entry_id);
      }
    }
  );
}

function SaveDeleteEntryItem(Entry_id) {
  $("#btn_Save_Item").prop("disabled", true);

  var APIEndPoint = "SaveTarget";
  var Method_Name = "Delete";
  var Target_Id = $("#lblEntryId").text();

  var url = "/Transactions/Targets";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    entry_id: Entry_id,
    target_id: Target_Id,
    type: "Item",
  };

  console.log(reqdata);
  // return;

  //Save
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,

    success: function (res) {
      var result = JSON.parse(res);
      if (result[0].result_id == 1) {
        ShowEditEntry(Target_Id);
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Target details not saved");
    },
  });

  return;
}

function ShowEditEntryItem(Entry_Id) {
  $("#modelTargets")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#ddlEntryProductGroup").select2();
  $("#ddlModalItemCode").select2();
  $("#txtModalUOM").select2();
  $("#divFooterDelete").show();
  $("#divTabs").show();
  var Target_Id = $("#lblEntryId").text();
  var APIEndPoint = "GetTarget";
  var Method_Name = "Get_One_Item";
  var url = "/Transactions/Targets";
  var reqdata = {
    method_name: Method_Name,
    target_id: Target_Id,
    api_end_point: APIEndPoint,
    entry_id: Entry_Id,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // res[0].is_locked
      if (res.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
      $("#btn_Save_Item").prop("disabled", false);
      $("#lblEntryIdItem").html(res[0].entry_id);
      $("#lblActionItem").html("Edit");

      GetMaster(
        "ddlEntryProductGroup",
        "Select Product Group",
        "GetProductsfortarget",
        res[0].productgroup_id,
        ""
      );
      GetMaster(
        "ddlModalItemCode",
        "Select Product",
        "GetProductByProductGroup",
        res[0].product_id,
        res[0].productgroup_id
      );

      GetMaster(
        "txtModalUOM",
        "Select UOM",
        "GetProductUOM",
        res[0].productuom,
        res[0].product_id
      );

      $("#txtEntryQuantityItem").val(res[0].quantity);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}
