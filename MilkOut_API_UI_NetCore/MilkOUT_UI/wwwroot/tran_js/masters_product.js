$(document).ready(function () {
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
  var APIEndPoint = "GetMastersProduct";
  var SearchText = "%" + $("#txtSearchText").val() + "%";
  //var Product_Id = "";
  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get";
  var url = "/Masters/Product";
  var reqdata = {
    method_name: Method_Name,
    search_text: SearchText,
    //"product_id": Product_Id,
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
      $.each(res, function (data, value) {
        //Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.product_code + "</td>";
        TableHTML += "<td>" + value.product_name + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
        TableHTML +=
          '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEntryModal(\'' +
          value.product_id +
          "');\">";
        TableHTML += '<i class="fa fa-pencil"></i>';
        TableHTML += "</a>";
        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [4], "Product");
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

function ShowEntryModal(Product_Id) {
  $("#modelProductPhoto")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#lblEntryProductId").html(Product_Id);

  $("#txtModalUOM").select2();

  GetMaster("txtModalUOM", "UOM List", "GetProductUOM", "", Product_Id);

  var APIEndPoint = "GetMastersProduct";
  var Method_Name = "Get_One";
  var url = "/Masters/Product";
  var reqdata = {
    method_name: Method_Name,
    product_id: Product_Id,
    api_end_point: APIEndPoint,
  };
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      if (res[0].is_active == 1) {
        $("#chkEntryStatus").prop("checked", true);
      } else {
        $("#chkEntryStatus").prop("checked", false);
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

function SaveModalEntry() {
  $("#btn_Save").prop("disabled", true);
  var ProductPhoto = $("#imgProductPhoto").attr("src");
  var IsValid = 1;
  if (Product_Id == "") {
    IsValid = 0;
    $("#imgProductPhoto").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    Show_Error_Toastr("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    var Is_Active = 0;
    if ($("#chkEntryStatus").prop("checked")) {
      Is_Active = 1;
    }
    var APIEndPoint = "SaveMasterProduct";
    var Method_Name = "Update";
    var Product_Id = $("#lblEntryProductId").html();
    var url = "/Masters/Product";
    var reqdata = {
      method_name: Method_Name,
      product_id: Product_Id,
      product_photo: ProductPhoto,
      api_end_point: APIEndPoint,
      is_active: Is_Active,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (res) {
        var result = JSON.parse(res);
        if (result[0].result_id == 1) {
          Show_Success_Toastr("Product saved successfully");
          GetSearchList();
        } else {
          Show_Error_Toastr("Error : " + result[0].result_description);
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Product not saved");
      },
    });
    $("#modelProductPhoto").modal("hide");
    $("#btn_Save").prop("disabled", false);
  }
}

function ShowDownloadUOM() {
  var apiendpoint = "SaveMasterProductUOM";
  var Method_Name = "GetCode";
  var url = "/Masters/ProductUOM";

  //var Method_Name = "Get";
  //var apiendpoint = "GetOneDebitMemoRequest";
  //var url = "/DebitMemoRequest/GetDebitMemoRequest";

  var reqdata = {
    method_name: Method_Name,
    xml_data: "n",
    api_end_point: apiendpoint,
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      GetSearchList();
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
    },
  });
}

function ShowDownloadEntry() {
  // Get data from database and show in table
  var APIEndPoint = "SaveSAPMasterProduct";
  var Method_Name = "Create";
  var url = "/Masters/Product";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    product_id: "",
    product_photo: "",
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      // var result = JSON.parse(result);
      // if (result[0].result_id == 1) {
      //     Show_Success_Toastr("Product Get successfully");
      //     GetSearchList();
      // } else {
      //     Show_Error_Toastr("Error : " + result[0].result_description);
      // }
      GetSearchList();
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
    },
  });
}
