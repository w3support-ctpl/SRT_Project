$(document).ready(function () {
  $("#ddlSearchApprovalStatus").select2();

  GetMaster(
    "ddlSearchApprovalStatus",
    "Select Approval Status",
    "GetApprovedStatus",
    0,
    ""
  );

  //SetDataTable("tableSearch", [6], "Farmer Service");

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

  var currentDate = new Date().toISOString().slice(0, 10);

  // Set the current date as the value for the input field
  $("#txtEntryDate").val(currentDate);
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  $("#btn_Search").prop("disabled", true);
  // Get data from database and show in table

  var url = "/Approvals/FarmerService";

  var APIEndPoint = "GetFarmerService";
  var Method_Name = "Get";
  var Request_Date = $("#txtSearchRequestPeriod").val();
  var ApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();

  var Status_Id = ApprovalStatus_Id;

  var reqdata = {
    method_name: Method_Name,
    request_date: Request_Date,
    approvalstatus_id: Status_Id,
    api_end_point: APIEndPoint,
    order_type: "Material",
  };

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result); //.responseData);

      // Fill data in table
      var TableHTML = "";

      var EditFlag = true; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Approved_Status;
        if (value.is_approved == 1) {
          Approved_Status = "Approved";
          EditFlag = false;
        } else if (value.is_approved == 0) {
          Approved_Status = "Pending";
          EditFlag = true;
        } else {
          Approved_Status = "Rejected";
          EditFlag = false;
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        TableHTML += "<td>" + value.request_date + "</td>";
        TableHTML += "<td>" + value.farmer_agent_name_request_for + "</td>";
        TableHTML += "<td>" + value.mobile_no_request_for + "</td>";
        TableHTML += "<td>" + value.servicetype_name + "</td>";
        TableHTML += "<td>" + value.service_name + "</td>";
        TableHTML += "<td>" + Approved_Status + "</td>";
        if (EditFlag == true) {
          TableHTML +=
            "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowApproveEntry(\'' +
            value.request_id +
            "', '" +
            value.servicetype_id +
            "', '" +
            value.requestfor_id +
            "', '" +
            value.farmer_agent_name_request_for +
            "', '" +
            value.mobile_no_request_for +
            "', '" +
            value.servicetype_name +
            "', '" +
            value.service_name +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
          TableHTML += "</td>";
        } else {
          TableHTML +=
            "<td class='text-right' style='width: 100px; padding:8px 5px 8px 5px;'>";
          TableHTML += "" + value.approved_on + "";
          TableHTML += "</td>";
        }

        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      SetDataTable("tableSearch", [6], "Farmer Service");
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr("Error in fetching details from server.");
      $("#btn_Search").prop("disabled", false);
    },
  });
}

function ShowApproveEntry(
  Request_Id,
  _ServiceTypeId,
  _FarmerId,
  Farmer_Name,
  Mobile_No,
  Service_Type,
  Service_Name
) {
  ServiceType_Id = _ServiceTypeId;
  Farmer_Id = _FarmerId;

  ShowContentDiv("Approvals", "FarmerServiceAdd", "", function () {
    // Initialization Code
    $("#btn_Save").hide();
    $("#ddlEntryApprovalStatus").select2();

    $("#lblEntryId").html(Request_Id);
    $("#lblAction").html("Edit");

    $("#txtEntryFarmerName").val(Farmer_Name);
    $("#txtEntryMobileNo").val(Mobile_No);
    $("#txtEntryServiceType").val(Service_Type);
    $("#txtEntryServiceRequested").val(Service_Name);

    GetMaster(
      "ddlEntryApprovalStatus",
      "Select Approval Status",
      "GetApprovedStatus",
      0,
      ""
    );
    //GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", Is_Approved, "");
    //$("#txtEntryRemarks").val(Approval_Remarks);

    $("#ddlEntryApprovalStatus").on("change", function () {
      var selectedValue = $(this).val();
      var selectedWord = "Yes, Reject it."; //$(this).children("option:selected").text();
      if (selectedValue == 0) {
        selectedWord = "Yes, Keep it Pending.";
      }

      if (selectedValue != "") {
        if (!(selectedValue == 1)) {
          swal({
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "question",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: selectedWord,
          });
        }
        if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
          $("#btn_Save").show();
        } else {
          $("#btn_Save").hide();
        }
      }
    });

    var APIEndPoint = "GetFarmerService";
    var url = "/Approvals/FarmerService";
    var reqdata = {
      request_id: Request_Id,
      method_name: "Get_One",
      api_end_point: APIEndPoint,
      order_type: "Material",
      servicetype_id: ServiceType_Id,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        // Financial Service
        if (ServiceType_Id == "C026002") {
          //show financial service division and hide others
          $("#divFinancialService").show();
          $("#divApprovedAmount").show();

          $("#divVeterinaryService").hide();
          $("#divDate").hide();

          $("#divMaterialService").hide();

          // assign values
          $("#txtEntryRequestedAmount").val(res[0].request_amount);
          $("#txtEntryFarmerRemarksFinancial").val(res[0].request_remark);
        }
        // Veterinary Service
        else if (ServiceType_Id == "C026001") {
          // show veterinary service division and hide others
          $("#divFinancialService").hide();
          $("#divApprovedAmount").hide();

          $("#divVeterinaryService").show();
          $("#divDate").show();

          $("#divMaterialService").hide();

          // assign values
          $("#txtEntryVeterinaryService").val(res[0].service_name);
          $("#txtEntryFarmerRemarksVeterinary").val(res[0].request_remark);
        }
        // Material Service
        else if (ServiceType_Id == "C026003") {
          // show material service
          $("#divFinancialService").hide();
          $("#divApprovedAmount").hide();

          $("#divVeterinaryService").hide();
          $("#divDate").hide();

          $("#divMaterialService").show();

          ClearDataTable("tableMaterialEntry");
          // Fill data in table
          var TableHTML = "";
          var EditFlag = true;
          $.each(res, function (data, value) {
            TableHTML += "<tr>";
            TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
            TableHTML += "<td hidden>" + value.material_id + "</td>";
            TableHTML += "<td>" + value.material_name + "</td>";
            TableHTML +=
              "<td><input type='number' class='form-control' maxlength='10' autocomplete='off'";
            TableHTML += "value=" + value.quantity + " disabled></td>";
            TableHTML +=
              "<td><input type='number' class='form-control' maxlength='10' autocomplete='off'";
            TableHTML += "value=" + value.approved_quantity + "></td>";
            TableHTML += "<td hidden></td>";
            TableHTML += "</tr>";
          });

          $("#tableMaterialData").html(TableHTML);

          SetDataTable("tableMaterialEntry", [6], "Farmer Service");

          $("#divRemarks").attr("class", "col-lg-9 col-md-4 col-sm-12");
        }
      },
      error: function () {
        Show_Error_Toastr("Error : Farmer Service details not found");
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
  var Approval_Status = $("#ddlEntryApprovalStatus").val();
  var Approval_Remarks = $("#txtEntryRemarks").val();
  var Approved_Amount = $("#txtEntryApprovedAmount").val();
  var VeterinaryService_Date = $("#txtEntryDate").val();

  var IsValid = 1;
  OrderDetails = "";

  if (Approval_Status == "") {
    IsValid = 0;
    $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
  }
  if (Approval_Remarks == "") {
    IsValid = 0;
    $("#txtEntryRemarks").addClass("is-invalid state-invalid");
  }

  // Financial Service
  if (ServiceType_Id == "C026002") {
    if (Approved_Amount == "") {
      IsValid = 0;
      $("#txtEntryRequestedAmount").addClass("is-invalid state-invalid");
    }
  }

  // Veterinary Service
  else if (ServiceType_Id == "C026001") {
    if (VeterinaryService_Date == "") {
      IsValid = 0;
      $("#txtEntryDate").addClass("is-invalid state-invalid");
    }
  }
  // Material Service
  else if (ServiceType_Id == "C026003") {
    if (Approval_Status == 1) {
      var quantity_sum = 0;
      var quantity_flag = 0;
      $("#tableMaterialEntry tbody tr").each(function () {
        quantity_sum += parseInt($(this).find("td:eq(4) input").val());
        var temp_quantity = parseInt($(this).find("td:eq(3) input").val());
        var temp_app_quantity = parseInt($(this).find("td:eq(4) input").val());
        if (temp_app_quantity > temp_quantity) {
          quantity_flag = 1;
          return;
        }
      });
      if (quantity_sum == 0) {
        ShowEntryError(
          "Can't approve. The sum of Approved Quantity values must be greater than 0."
        );
        return;
      }

      if (quantity_flag == 1) {
        ShowEntryError(
          "Can't approve. Approved Quantity can't be greater than Requested Quantity."
        );
        return;
      } else {
        OrderDetails = "<Products>";
        $("#tableMaterialEntry tbody tr").each(function () {
          OrderDetails += "<ProductItem>";
          OrderDetails +=
            "<Product_Id>" + $(this).find("td:eq(1)").text() + "</Product_Id>";
          OrderDetails +=
            "<Product_Name>" +
            $(this).find("td:eq(2)").text() +
            "</Product_Name>";
          OrderDetails +=
            "<Quantity>" + $(this).find("td:eq(3) input").val() + "</Quantity>";
          OrderDetails +=
            "<Approved_Quantity>" +
            $(this).find("td:eq(4) input").val() +
            "</Approved_Quantity>";
          OrderDetails +=
            "<Rate>" + $(this).find("td:eq(5)").text() + "</Rate>";
          OrderDetails += "</ProductItem>";
        });
        OrderDetails += "</Products>";
      }
    }
  }

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  }

  // Start Saving
  $("#btn_Save").prop("disabled", true);

  // Save
  var APIEndPoint = "SaveFarmerService";
  Method_Name = "Update";
  Request_Id = $("#lblEntryId").html();

  var url = "/Approvals/FarmerService";
  var reqdata = {
    method_name: Method_Name,
    approvalstatus_id: Approval_Status,
    approval_remarks: Approval_Remarks,
    api_end_point: APIEndPoint,
    request_id: Request_Id,
    approved_amount: Approved_Amount,
    requestfor_id: Farmer_Id,
    veterinaryservice_date: VeterinaryService_Date,
    order_data: OrderDetails,
    order_type: "Material",
    servicetype_id: ServiceType_Id,
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
        Show_Success_Toastr("Farmer Service " + result[0].result_description);
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
        $("#btn_Save").prop("disabled", false);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Farmer Service details not saved");
      $("#btn_Save").prop("disabled", false);
    },
  });
}

function ShowAddEntry() {
  $("#modelEntryServiceRequest")
    .modal({
      backdrop: "static",
    })
    .modal("show");
  $("#ddlEntryMCC").select2();
  $("#ddlEntryFarmer").select2();
  $("#ddlEntryServiceType").select2();
  $("#ddlEntryMaterial").select2();

  GetMaster("ddlEntryMCC", "Select MCC", "GetMCC", "", "");
  GetMaster(
    "ddlEntryServiceType",
    "Select Service Type",
    "GetServiceTypeMaterialSales",
    "",
    ""
  );
  GetMaster("ddlEntryMaterial", "Select Material", "GetMaterials", "", "");
}

$("#modelEntryServiceRequest").on("hidden.bs.modal", function (e) {
  $("#ddlEntryMCC").val("");
  $("#ddlEntryFarmer").val("");
  $("#ddlEntryServiceType").val("");
  $("#ddlEntryMaterial").val("");
  $("#txtEntryQuantity").val("");
  GetSearchList();
});

function GetFarmer() {
  //Empty All Childeren/Dependent DDLs
  $("#ddlEntryFarmer")
    .empty()
    .append($("<option></option>").val("").html("Select Farmer"));
  

  var MCC_Id = $("#ddlEntryMCC").val();
  GetMaster("ddlEntryFarmer", "Select Farmer", "GetMCCFarmer", "", MCC_Id);
}

function SaveFarmerCollectionEntry() {
  Show_Loader();

  var MCC_Id = $("#ddlEntryMCC").val();
  var ServiceType_Id = $("#ddlEntryServiceType").val();
  var Material_Id = $("#ddlEntryMaterial").val();
  var Search_Period = $("#txtEntryDate").val();
  var Quantity = $("#txtEntryQuantity").val();

  var Method_Name = "Create";
  var APIEndPoint = "SaveFarmerService";
  var url = "/Approvals/FarmerService";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    order_type: "Material",
    request_id: MCC_Id,
    veterinaryservice_date: Search_Period,
    product_id: Material_Id,
    quantity: Quantity,
  };

  //   // console.log(reqdata);
  // debugger;
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

        $("#modelEntryServiceRequest").modal("hide");
        // GetSearchList();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        // $("#btn_MCCSave").show();
        $("#modelEntryServiceRequest").modal("hide");
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Farmer details not saved");
      // $("#btn_MCCSave").show();
    },
  });
}


function SaveServiceEntry() {
  var MCC_Id = $("#ddlEntryMCC").val();
  var Farmer_Id = $("#ddlEntryFarmer").val();
  var ServiceType_Id = $("#ddlEntryServiceType").val();
  var Material_Id = $("#ddlEntryMaterial").val();
  var Search_Period = $("#txtEntryDate").val();
  var Quantity = $("#txtEntryQuantity").val();

  var IsValid = 1;
  if (MCC_Id == "" || MCC_Id == null || MCC_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMCC").addClass("is-invalid state-invalid");
  }
  if (Farmer_Id == "" || Farmer_Id == null || Farmer_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryFarmer").addClass("is-invalid state-invalid");
  }
  if (ServiceType_Id == "" || ServiceType_Id == null || ServiceType_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryServiceType").addClass("is-invalid state-invalid");
  }
  if (Material_Id == "" || Material_Id == null || Material_Id == undefined) {
    IsValid = 0;
    $("#ddlEntryMaterial").addClass("is-invalid state-invalid");
  }
  if (
    Search_Period == "" ||
    Search_Period == null ||
    Search_Period == undefined
  ) {
    IsValid = 0;
    $("#txtEntryDate").addClass("is-invalid state-invalid");
  }
  if (
    Quantity == "" ||
    Quantity == null ||
    Quantity == undefined ||
    Is_Valid_Float(Quantity) == false
  ) {
    IsValid = 0;
    $("#txtEntryQuantity").addClass("is-invalid state-invalid");
  }
  if (IsValid == 0) {
    ShowItemError("Invalid Input(s). Can't be saved.");
    return;
  }

  Show_Loader();
  var Method_Name = "Create_Farmer";
  var APIEndPoint = "SaveFarmerService";
  var url = "/Approvals/FarmerService";
  var reqdata = {
    method_name: Method_Name,
    api_end_point: APIEndPoint,
    mcc_id: MCC_Id,
    order_type: "Material",
    request_id: Farmer_Id,
    veterinaryservice_date: Search_Period,
    product_id: Material_Id,
    quantity: Quantity,
    approvalstatus_id: 1,
    approved_amount: 0,
  };

  //   // console.log(reqdata);
  // debugger;
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

        $("#modelEntryServiceRequest").modal("hide");
        // GetSearchList();
      } else {
        Hide_Loader();
        Show_Error_Toastr("Error : " + result[0].result_description);
        // $("#btn_MCCSave").show();
        $("#modelEntryServiceRequest").modal("hide");
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : MCC details not saved");
      // $("#btn_MCCSave").show();
    },
  });
}