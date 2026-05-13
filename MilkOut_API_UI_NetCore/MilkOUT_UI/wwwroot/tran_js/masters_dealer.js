/* -----    ----    ----    Assigning intital values to all the elements    ----    ----    ----- */
$(document).ready(function () {
  $("#ddlSearchSalesArea").select2();
  GetMaster("ddlSearchSalesArea", "Select Sales Group", "GetSalesArea", "", ""); // Topmost Section

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
          picker.endDate.format("MM/DD/YYYY"),
      );
    },
  );

  $('input[name="datefilter"]').on(
    "cancel.daterangepicker",
    function (ev, picker) {
      $(this).val("");
    },
  );
});

/* -----    ----    ----    Getting Records from the table based on the values provided    ----    ----    ----- */
function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Get data from database and show in table

  $("#tableData").empty();
  var DealerCode = "%" + $("#txtSearchDealerCode").val() + "%";
  var DealerName = "%" + $("#txtSearchDealerName").val() + "%";
  var SalesArea_Id = "%" + $("#ddlSearchSalesArea").val() + "%";

  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get_V2";
  var APIEndPoint = "GetDealer";
  var url = "/Masters/Dealer";
  var reqdata = {
    method_name: Method_Name,
    dealer_code: DealerCode,
    dealer_name: DealerName,
    salesarea_id: SalesArea_Id,
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
      var Row_No = 0;
      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
      $.each(res, function (data, value) {
        var Active_Status;
        Row_No = Row_No + 1;
        if (value.is_active == 0) {
          Active_Status = "In-active";
        } else {
          Active_Status = "Active";
        }

        TableHTML += "<tr>";
        TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";

        TableHTML += "<td>" + value.dealer_code + "</td>";
        TableHTML += "<td>" + value.dealer_name + "</td>";
        TableHTML += "<td>" + value.salesarea_name + "</td>";
        TableHTML += "<td>" + value.salesuser_name + "</td>";
        TableHTML += "<td>" + value.phone_no + "</td>";
        TableHTML += "<td>" + value.mobile_no + "</td>";
        TableHTML += "<td>" + value.contact_person + "</td>";
        TableHTML += "<td>" + value.email_id + "</td>";
        TableHTML += "<td>" + value.address_line_1_text + "</td>";
        TableHTML += "<td>" + value.address_line_2_text + "</td>";
        TableHTML += "<td>" + value.address_line_3_text + "</td>";
        TableHTML += "<td>" + value.state_name + "</td>";
        TableHTML += "<td>" + value.district_name + "</td>";
        TableHTML += "<td>" + value.taluka_name + "</td>";
        TableHTML += "<td>" + value.village_name + "</td>";
        TableHTML += "<td>" + value.pincode + "</td>";
        TableHTML += "<td>" + value.pan_no + "</td>";
        TableHTML += "<td>" + value.bank_name + "</td>";
        TableHTML += "<td>" + value.branch_name + "</td>";
        TableHTML += "<td>" + value.account_no + "</td>";
        TableHTML += "<td>" + value.ifsc_code + "</td>";
        TableHTML += "<td>" + value.account_name + "</td>";
        TableHTML += "<td>" + value.msme_no + "</td>";
        TableHTML += "<td>" + value.fssai_license_no + "</td>";
        TableHTML += "<td>" + value.fssai_licensevalidity_on + "</td>";
        TableHTML += "<td>" + value.gst_no + "</td>";
        TableHTML += "<td>" + value.agreementvalidiy_startdate + "</td>";
        TableHTML += "<td>" + value.agreementvalidity_enddate + "</td>";
        TableHTML += "<td>" + value.securitydepositamount + "</td>";
        TableHTML += "<td>" + value.shoplatitude + "</td>";
        TableHTML += "<td>" + value.shoplongitude + "</td>";
        TableHTML += "<td>" + value.payment_url + "</td>";
        TableHTML += "<td>" + value.cratelimit + "</td>";
        TableHTML += "<td>" + Active_Status + "</td>";
        TableHTML +=
          "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

        if (EditFlag == true) {
          TableHTML +=
            '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
            value.dealer_id +
            "')\">";
          TableHTML += '<i class="fa fa-pencil"></i>';
          TableHTML += "</a>";
        }

        TableHTML += "</td>";
        TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);

      // SetDataTable("tableSearch", [7], "Dealer");

      SetDataTable_Master(
        "tableSearch",
        [35],
        "Dealer",
        [
          7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
          25, 26, 27, 28, 29, 30, 31, 32, 33,
        ],
        [
          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
        ],
      );
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description,
      );
      $("#btn_Search").prop("disabled", false);
    },
  });

  return;
}

/* -----    ----    ----    Show Entry Page with default/null values to add new entry    ----    ----    ----- */
function ShowAddEntry() {
  ShowContentDiv("Masters", "DealerAdd", "", function () {
    $("#ddlEntrySalesArea").select2();
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntrySalesUser").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();

    $("#lblEntryId").html(""); //No id first
    $("#lblAction").html("Add");

    $("#divFooterDelete").hide();

    GetMaster("ddlEntrySalesUser", "Select Sales User", "GetSalesUser", "", "");
    GetMaster(
      "ddlEntrySalesArea",
      "Select Sales Group",
      "GetSalesArea",
      "",
      "",
    );
    GetMaster("ddlEntryState", "Select State", "GetState", "", "");
    GetMaster("ddlEntryBankName", "Select Bank", "GetBank", "", "");
    GetMaster("ddlEntryBranchName", "Select Branch", "GetBranch", "", "");

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
            picker.endDate.format("MM/DD/YYYY"),
        );
      },
    );

    $('input[name="datefilter"]').on(
      "cancel.daterangepicker",
      function (ev, picker) {
        $(this).val("");
      },
    );
  });
}

function ShowDownloadEntry() {
  var APIEndPoint = "GetDealerMaster";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    org_id: "",
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
      var res_output = JSON.parse(res);

      if ((res_output[0].result_id = 1)) {
        Show_Success_Toastr("Dealer Get Successfully");
      }

      GetSearchList();

      if (res_output.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }

      // extract values and create an html string to assign to html table
    },
    error: function () {
      // Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

function DownloadDealerRoute() {
  var APIEndPoint = "GetDownloadRoute";
  var url = "/Masters/DownloadRoute";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
  };

  Show_Loader();

  $("#btn_Search").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/json",
    data: JSON.stringify(reqdata),
    success: function (result) {
      Hide_Loader();

      var res = JSON.parse(result);
      var res_output = JSON.parse(res);

      console.log(res_output);

      if (res_output.length > 0) {
        if ((res_output[0].result_id = 1)) {
          Show_Success_Toastr("Download Successfully");
        }
      }
    },
    error: function () {
      Hide_Loader();
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

/* -----    ----    ----    Show Entry(Edit) Page and assign input elements with the values extracted from the table in database    ----    ----    ----- */
function ShowEditEntry(Dealer_Id) {
  ShowContentDiv("Masters", "DealerEdit", "", function () {
    /*$("#ddlEntrySalesArea").select2();
        $("#ddlEntryState").select2();
        $("#ddlEntryDistrict").select2();
        $("#ddlEntryTaluka").select2();
        $("#ddlEntryBankName").select2();
        $("#ddlEntryBranchName").select2();
        */

    $("#ddlEntrySalesUser").select2();

    $("#ddlEntrySalesArea").select2();

    $("#lblEntryId").html(Dealer_Id); //for updating the record
    $("#lblAction").html("Edit");

    //$("#divFooterDelete").show();

    var APIEndPoint = "GetDealer";
    var Method_Name = "Get_One";
    var url = "/Masters/Dealer";
    var reqdata = {
      method_name: Method_Name,
      dealer_id: Dealer_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);
        $("#txtEntryDealerCode").val(res[0].dealer_code);
        $("#txtEntryDealerName").val(res[0].dealer_name);
        $("#txtEntryDealerPan").val(res[0].pan_no);
        $("#txtEntryPhoneNo").val(res[0].phone_no);
        $("#txtEntryEmail").val(res[0].email_id);
        $("#txtAddressLine1").val(res[0].address_line_1_text);
        $("#txtAddressLine2").val(res[0].address_line_2_text);
        $("#txtEntryPin").val(res[0].pincode);
        $("#txtEntryContactPerson").val(res[0].contact_person);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        $("#txtEntryAccountName").val(res[0].account_name);
        $("#txtEntryAccountNo").val(res[0].account_no);

        $("#txtEntryMSMENo").val(res[0].msme_no);
        $("#txtEntryFSSAILicenseNo").val(res[0].fssai_license_no);
        $("#txtEntryFSSAIValidityDate").val(res[0].fssai_licensevalidity_on);
        $("#txtEntryGSTNo").val(res[0].gst_no);
        $("#txtEntryAgreementValidityPeriod").val(
          res[0].agreement_validity_period,
        );
        $("#txtEntrySecurityDepositAmount").val(res[0].securitydepositamount);
        $("#txtEntryShopLatitude").val(res[0].shoplatitude);
        $("#txtEntryShopLongitude").val(res[0].shoplongitude);

        $("#txtEntryBankName").val(res[0].bank_name);
        $("#txtEntryBranchName").val(res[0].branch_name);
        $("#txtEntryState").val(res[0].state_name);
        $("#txtEntryDistrict").val(res[0].district_name);
        $("#txtEntryTaluka").val(res[0].taluka_name);
        $("#txtEntryIFSCCode").val(res[0].ifsc_code);

        $("#txtEntryPassword").val(res[0].login_password);
        $("#txtEntryPaymentUrl").val(res[0].payment_url);

        $("#txtEntryCrateLimit").val(res[0].cratelimit);

        if (res[0].is_payment == "0") {
          document.getElementById("chkPaymentFlag").checked = false;
        } else {
          document.getElementById("chkPaymentFlag").checked = true;
        }

        GetMaster(
          "ddlEntryBankName",
          "Select Bank",
          "GetBank",
          res[0].bank_id,
          "",
        );
        GetMaster(
          "ddlEntryBranchName",
          "Select Branch",
          "GetBranch",
          res[0].branch_id,
          res[0].bank_id,
        );

        GetMaster(
          "ddlEntrySalesUser",
          "Select Sales User",
          "GetSalesUserbydealer",
          res[0].salesuser_id,
          Dealer_Id,
        );
        GetMaster(
          "ddlEntrySalesArea",
          "Select Sales Group",
          "GetSalesArea",
          res[0].salesarea_id,
          "",
        );

        GetMaster(
          "ddlEntryState",
          "Select State",
          "GetState",
          res[0].state_id,
          "",
        );
        GetMaster(
          "ddlEntryDistrict",
          "Select District",
          "GetDistrict",
          res[0].district_id,
          res[0].state_id,
        );
        GetMaster(
          "ddlEntryTaluka",
          "Select Taluka",
          "GetTaluka",
          res[0].taluka_id,
          res[0].district_id,
        );

        SetIFSCCode(res[0].branch_id);

        if (res[0].is_active == 1) {
          $("#chkEntryStatus").prop("checked", true);
        } else {
          $("#chkEntryStatus").prop("checked", false);
        }
        if (res[0].is_agreement_done == 1) {
          $("#chkAgreementDoneFlag").prop("checked", true);
        } else {
          $("#chkAgreementDoneFlag").prop("checked", false);
        }

        $('input[name="datefilter"]').daterangepicker({
          locale: {
            cancelLabel: "Clear",
          },
          startDate: moment().subtract(30, "days"), // Set the startDate to 30 days ago
          endDate: moment(), // Set the endDate to the current date
          ranges: {
            Today: [moment(), moment()],
            Yesterday: [
              moment().subtract(1, "days"),
              moment().subtract(1, "days"),
            ],
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
                picker.endDate.format("MM/DD/YYYY"),
            );
          },
        );

        $('input[name="datefilter"]').on(
          "cancel.daterangepicker",
          function (ev, picker) {
            $(this).val("");
          },
        );
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}

/* -----    ----    ----    Assign Values to the District Dropdown based on the State selected    ----    ----    ----- */
function GetDistrict() {
  //Empty All Childeren/Dependent DDLs
  $("#ddlEntryTaluka")
    .empty()
    .append($("<option></option>").val("").html("Select Taluka"));
  $("#ddlEntryVillage")
    .empty()
    .append($("<option></option>").val("").html("Select Village"));

  var State_Id = $("#ddlEntryState").val();
  GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", "", State_Id);
}

/* -----    ----    ----    Assign Values to the Taluka Dropdown based on the District selected    ----    ----    ----- */
function GetTaluka() {
  // Empty All Children/Dependent DDls
  $("#ddlEntryVillage")
    .empty()
    .append($("<option></option>").val("").html("Select Village"));

  var District_Id = $("#ddlEntryDistrict").val();
  GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", "", District_Id);
}

/* -----    ----    ----    Assign Values to the Village Dropdown based on the Taluka selected    ----    ----    ----- */
function GetVillage() {
  var Taluka_Id = $("#ddlEntryTaluka").val();
  //GetMaster("ddlEntryVillage", "Select Village", "GetVillage", "", Taluka_Id);
}

/* -----    ----    ----    Assign Values to the Branch Dropdown based on the Bank selected    ----    ----    ----- */
function GetBranch() {
  $("#txtEntryIFSCCode").text("");
  var Bank_Id = $("#ddlEntryBankName").val();
  GetMaster(
    "ddlEntryBranchName",
    "Select Branch Name",
    "GetBranch",
    "",
    Bank_Id,
  );
}

/* -----    ----    ----    Assign Values to the IFSC Code Textbox based on the Bank Branch selected    ----    ----    ----- */
function SetIFSCCode(Branch_Id) {
  if (Branch_Id == "") {
    var Branch_Id = $("#ddlEntryBranchName").val();
  }
  GetIFSCCode(Branch_Id, "txtEntryIFSCCode");
}

/* -----    ----    ----    Close Entry Page and get all the data on the Search Page    ----    ----    ----- */
function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

/* -----    ----    ----    Validate all the inserted values and Save it to the database    ----    ----    ----- */
/*function SaveEntry2() {

    var APIEndPoint = "SaveDealer";

    // Validation code
    var DealerCode = $("#txtEntryDealerCode").val().trim();
    var DealerName = $("#txtEntryDealerName").val().trim();
    var SalesArea_Id = $("#ddlEntrySalesArea").val();
    var SalesUser_Id = $("#ddlEntrySalesUser").val();
    var PANNo = $("#txtEntryDealerPan").val().trim();
    var PhoneNo = $("#txtEntryPhoneNo").val().trim();
    var Email_Id = $("#txtEntryEmail").val().trim();
    var AddressLine1 = $("#txtAddressLine1").val().trim();
    var AddressLine2 = $("#txtAddressLine2").val().trim();
    var State_Id = $("#ddlEntryState").val();
    var District_Id = $("#ddlEntryDistrict").val();
    var Taluka_Id = $("#ddlEntryTaluka").val();
    var PinCode = $("#txtEntryPin").val().trim();
    var ContactPerson = $("#txtEntryContactPerson").val().trim();
    var MobileNo = $("#txtEntryMobileNo").val().trim();
    var Bank_Id = $("#ddlEntryBankName").val();
    var Branch_Id = $("#ddlEntryBranchName").val();
    var Account_Name = $("#txtEntryAccountName").val().trim();
    var Account_No = $("#txtEntryAccountNo").val().trim();
    var IFSC_Code = $("#txtEntryIFSCCode").text();
    var MSME_No = $("#txtEntryMSMENo").val().trim();
    var FSSAILicense_No = $("#txtEntryFSSAILicenseNo").val().trim();
    var FSSAIValidityDate = $("#txtEntryFSSAIValidityDate").val();
    var GSTNo = $("#txtEntryGSTNo").val().trim();
    var AgreementValidityPeriod = $("#txtEntryAgreementValidityPeriod").val();
    var AgreementDoneFlag = 0;
    if ($("#chkAgreementDoneFlag").prop("checked")) {
        AgreementDoneFlag = 1;
    }
    var Is_Active = 0;
    if ($('#chkEntryStatus').prop("checked")) {
        Is_Active = 1;
    }
    var Is_Deleted = 0;


    var IsValid = 1;
    var_Pan_Card_Photo = "";
    var_Shop_License_Photo = "";
    var_Cheque_Leaf_Photo = "";

    if (DealerCode == "") {
        IsValid = 0;
        $("#txtEntryDealerCode").addClass("is-invalid state-invalid");
    }
    if (DealerName == "") {
        IsValid = 0;
        $("#txtEntryDealerName").addClass("is-invalid state-invalid");
    }
    if (SalesArea_Id == "") {
        IsValid = 0;
        $("#ddlEntrySalesArea").addClass("is-invalid state-invalid");
    }
    if (SalesUser_Id == "") {
        IsValid = 0;
        $("#ddlEntrySalesUser").addClass("is-invalid state-invalid");
    }
    if (Is_Valid_PanNO(PANNo) == false) {
        IsValid = 0;
        $("#txtEntryDealerPan").addClass("is-invalid state-invalid");
    }
    if ((PhoneNo != "") && (Is_Valid_PhoneNo(PhoneNo)) == false) {
        IsValid = 0;
        $("#txtEntryPhoneNo").addClass("is-invalid state-invalid");
    }

    if ((Email_Id != "") && (Is_Valid_Email(Email_Id)) == false) {
        IsValid = 0;
        $("#txtEntryEmail").addClass("is-invalid state-invalid");
    }
    if (AddressLine1 == "") {
        IsValid = 0;
        $("#txtAddressLine1").addClass("is-invalid state-invalid");
    }
    if (AddressLine2 == "") {
        IsValid = 0;
        $("#txtAddressLine2").addClass("is-invalid state-invalid");
    }
    if (State_Id == "") {
        IsValid = 0;
        $("#ddlEntryState").addClass("is-invalid state-invalid");
    }
    if (District_Id == "") {
        IsValid = 0;
        $("#ddlEntryDistrict").addClass("is-invalid state-invalid");

    }
    if (Taluka_Id == "") {
        IsValid = 0;
        $("#ddlEntryTaluka").addClass("is-invalid state-invalid");
    }
    if (PinCode == "") {
        IsValid = 0;
        $("#txtEntryPin").addClass("is-invalid state-invalid");
    }

    if (ContactPerson == "") {
        IsValid = 0;
        $("#txtEntryContactPerson").addClass("is-invalid state-invalid");
    }

    if ((MobileNo != "") && (Is_Valid_MobileNo(MobileNo)) == false) {
        IsValid = 0;
        $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
    }

    if (Bank_Id == "") {
        IsValid = 0;
        $("#ddlEntryBankName").addClass("is-invalid state-invalid");
    }

    if (Branch_Id == "") {
        IsValid = 0;
        $("#ddlEntryBranchName").addClass("is-invalid state-invalid");
    }

    if (Account_Name == "" || Is_Valid_Name(Account_Name) == false) {
        IsValid = 0;
        $("#txtEntryAccountName").addClass("is-invalid state-invalid");
    }

    if (Account_No == "" || Is_Positive_Integer(Account_No) == false) {
        IsValid = 0;
        $("#txtEntryAccountNo").addClass("is-invalid state-invalid");
    }
    if (MSME_No == "" || Is_AlphaNumeric(MSME_No) == false) {
        IsValid = 0;
        $("#txtEntryMSMENo").addClass("is-invalid state-invalid");
    }
    if (FSSAILicense_No == "" || Is_AlphaNumeric(FSSAILicense_No) == false) {
        IsValid = 0;
        $("#txtEntryFSSAILicenseNo").addClass("is-invalid state-invalid");
    }
    if (FSSAIValidityDate == "") {
        IsValid = 0;
        $("#txtEntryFSSAIValidityDate").addClass("is-invalid state-invalid");
    }
    if (GSTNo == "" || Is_AlphaNumeric(GSTNo) == false) {
        IsValid = 0;
        $("#txtEntryGSTNo").addClass("is-invalid state-invalid");
    }
    if (AgreementValidityPeriod == "") {
        IsValid = 0;
        $("#txtEntryAgreementValidityPeriod").addClass("is-invalid state-invalid");
    }

    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }
    else {
        // Start Saving
        $("#btn_Save").prop('disabled', true);
        var Method_Name = 'Create';
        var Dealer_Id = "";
        var Action_Name = $("#lblAction").html();
        if (Action_Name == 'Edit') {
            Method_Name = 'Update';
            Dealer_Id = $("#lblEntryId").html();
        }
        

        var url = "/Masters/Dealer";

        var reqdata = {
            "is_active": Is_Active,
            "is_deleted": Is_Deleted,
            "method_name": Method_Name,
            "api_end_point": APIEndPoint,

            "dealer_id": Dealer_Id,
            "dealer_code": DealerCode,
            "dealer_name": DealerName,

            "salesarea_id": SalesArea_Id,
            "salesuser_id": SalesUser_Id,

            "mobile_no": MobileNo,
            "phone_no": PhoneNo,
            "contact_person": ContactPerson,
            "email_id": Email_Id,
            "pan_no": PANNo,

            "address_line_1_text": AddressLine1,
            "address_line_2_text": AddressLine2,
            "state_id": State_Id,
            "district_id": District_Id,
            "taluka_id": Taluka_Id,
            "pincode": PinCode,

            bank_id: Bank_Id,
            branch_id: Branch_Id,
            account_name: Account_Name,
            account_no: Account_No,
            ifsc_code: IFSC_Code,

            msme_no: MSME_No,
            fssai_license_no: FSSAILicense_No,
            fssai_licensevalidity_on: FSSAIValidityDate,
            agreement_validity_period: AgreementValidityPeriod,
            gst_no: GSTNo,
            is_agreement_done: AgreementDoneFlag,

            "pan_card_photo": "",
            "shop_license_photo": "",
            "cheque_leaf_photo": "",

        }

        //Save
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,

            success: function (res) {
                var result = JSON.parse(res);
                console.log("success", result);
                if (result[0].result_id == 1) {
                    // Show Success Message
                    ShowEntrySuccess("Dealers details saved successfully");
                    ShowEditEntry(result[0].result_extra_key);
                    $("#btn_Save").prop('disabled', false);
                } else {
                    ShowEntryError("Error : " + result[0].result_description);
                    $("#btn_Save").prop('disabled', false);
                }

            },
            error: function () {
                ShowEntryError("Error : Dealers details not saved");
                $("#btn_Save").prop('disabled', false);
            }
        });

    }
    return;

}
*/

/* -----    ----    ----    Delete particular entry present in the table    ----    ----    ----- */
function SaveDeleteEntry() {
  // Write code to delete
  var Dealer_Id = $("#lblEntryId").html();
  // In success do following things
  var APIEndPoint = "SaveDealer";

  var url = "/Masters/Dealer";

  var reqdata = {
    dealer_id: Dealer_Id,
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
        Show_Success_Toastr("Dealers details deleted successfully");
        GetSearchList();
        CloseEntry();
      } else {
        Show_Error_Toastr("Error : " + result[0].result_description);
      }
    },
    error: function () {
      Show_Error_Toastr("Error : Dealers details not deleted");
    },
  });
}

/* -----    ----    ----    Show Dialogue box to ask if user is sure they want to delete the entry    ----    ----    ----- */
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
    },
  );
}

/* -----    ----    ----    Validate all the inserted values and Save it to the database    ----    ----    ----- */
function SaveEntry() {
  var APIEndPoint = "SaveDealer";

  // Validation code
  var DealerCode = $("#txtEntryDealerCode").val().trim();
  var DealerName = $("#txtEntryDealerName").val().trim();
  var SalesArea_Id = $("#ddlEntrySalesArea").val();
  var SalesUser_Id = $("#ddlEntrySalesUser").val();
  var PANNo = $("#txtEntryDealerPan").val().trim();
  var PhoneNo = $("#txtEntryPhoneNo").val().trim();
  var Email_Id = $("#txtEntryEmail").val().trim();
  var AddressLine1 = $("#txtAddressLine1").val().trim();
  var AddressLine2 = $("#txtAddressLine2").val().trim();
  var State_Id = $("#ddlEntryState").val();
  var District_Id = $("#ddlEntryDistrict").val();
  var Taluka_Id = $("#ddlEntryTaluka").val();
  var PinCode = $("#txtEntryPin").val().trim();
  var ContactPerson = $("#txtEntryContactPerson").val().trim();
  var MobileNo = $("#txtEntryMobileNo").val().trim();
  var Bank_Id = $("#ddlEntryBankName").val();
  var Branch_Id = $("#ddlEntryBranchName").val();
  var Account_Name = $("#txtEntryAccountName").val().trim();
  var Account_No = $("#txtEntryAccountNo").val().trim();
  var IFSC_Code = $("#txtEntryIFSCCode").text();
  var MSME_No = $("#txtEntryMSMENo").val().trim();
  var FSSAILicense_No = $("#txtEntryFSSAILicenseNo").val().trim();
  var FSSAIValidityDate = $("#txtEntryFSSAIValidityDate").val();
  var GSTNo = $("#txtEntryGSTNo").val().trim();
  var AgreementValidityPeriod = $("#txtEntryAgreementValidityPeriod").val();
  var ShopLatitude = $("#txtEntryShopLatitude").val().trim();
  var ShopLongitude = $("#txtEntryShopLongitude").val().trim();

  var Password = $("#txtEntryPassword").val().trim();
  var PaymentUrl = $("#txtEntryPaymentUrl").val().trim();

  var PaymentFlag = 0;
  if ($("#chkPaymentFlag").prop("checked")) {
    PaymentFlag = 1;
  }

  var AgreementDoneFlag = 0;
  if ($("#chkAgreementDoneFlag").prop("checked")) {
    AgreementDoneFlag = 1;
  }
  var Is_Active = 0;
  if ($("#chkEntryStatus").prop("checked")) {
    Is_Active = 1;
  }
  var Is_Deleted = 0;

  var IsValid = 1;
  var_Pan_Card_Photo = "";
  var_Shop_License_Photo = "";
  var_Cheque_Leaf_Photo = "";
  /*
    if (DealerCode == "") {
        IsValid = 0;
        $("#txtEntryDealerCode").addClass("is-invalid state-invalid");
    }
    if (DealerName == "") {
        IsValid = 0;
        $("#txtEntryDealerName").addClass("is-invalid state-invalid");
    }
    if (SalesArea_Id == "") {
        IsValid = 0;
        $("#ddlEntrySalesArea").addClass("is-invalid state-invalid");
    }*/
  if (SalesUser_Id == "") {
    IsValid = 0;
    $("#ddlEntrySalesUser").addClass("is-invalid state-invalid");
  }
  /*
    if (Is_Valid_PanNO(PANNo) == false) {
        IsValid = 0;
        $("#txtEntryDealerPan").addClass("is-invalid state-invalid");
    }
    if ((PhoneNo != "") && (Is_Valid_PhoneNo(PhoneNo)) == false) {
        IsValid = 0;
        $("#txtEntryPhoneNo").addClass("is-invalid state-invalid");
    }

    if ((Email_Id != "") && (Is_Valid_Email(Email_Id)) == false) {
        IsValid = 0;
        $("#txtEntryEmail").addClass("is-invalid state-invalid");
    }
    if (AddressLine1 == "") {
        IsValid = 0;
        $("#txtAddressLine1").addClass("is-invalid state-invalid");
    }
    if (AddressLine2 == "") {
        IsValid = 0;
        $("#txtAddressLine2").addClass("is-invalid state-invalid");
    }
    if (State_Id == "") {
        IsValid = 0;
        $("#ddlEntryState").addClass("is-invalid state-invalid");
    }
    if (District_Id == "") {
        IsValid = 0;
        $("#ddlEntryDistrict").addClass("is-invalid state-invalid");

    }
    if (Taluka_Id == "") {
        IsValid = 0;
        $("#ddlEntryTaluka").addClass("is-invalid state-invalid");
    }
    if (PinCode == "") {
        IsValid = 0;
        $("#txtEntryPin").addClass("is-invalid state-invalid");
    }

    if (ContactPerson == "") {
        IsValid = 0;
        $("#txtEntryContactPerson").addClass("is-invalid state-invalid");
    }

    if ((MobileNo != "") && (Is_Valid_MobileNo(MobileNo)) == false) {
        IsValid = 0;
        $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
    }

    if (Bank_Id == "") {
        IsValid = 0;
        $("#ddlEntryBankName").addClass("is-invalid state-invalid");
    }

    if (Branch_Id == "") {
        IsValid = 0;
        $("#ddlEntryBranchName").addClass("is-invalid state-invalid");
    }

    if (Account_Name == "" || Is_Valid_Name(Account_Name) == false) {
        IsValid = 0;
        $("#txtEntryAccountName").addClass("is-invalid state-invalid");
    }

    if (Account_No == "" || Is_Positive_Integer(Account_No) == false) {
        IsValid = 0;
        $("#txtEntryAccountNo").addClass("is-invalid state-invalid");
    }
    if (MSME_No == "" || Is_AlphaNumeric(MSME_No) == false) {
        IsValid = 0;
        $("#txtEntryMSMENo").addClass("is-invalid state-invalid");
    }
    if (FSSAILicense_No == "" || Is_AlphaNumeric(FSSAILicense_No) == false) {
        IsValid = 0;
        $("#txtEntryFSSAILicenseNo").addClass("is-invalid state-invalid");
    }
    if (FSSAIValidityDate == "") {
        IsValid = 0;
        $("#txtEntryFSSAIValidityDate").addClass("is-invalid state-invalid");
    }
    if (GSTNo == "" || Is_AlphaNumeric(GSTNo) == false) {
        IsValid = 0;
        $("#txtEntryGSTNo").addClass("is-invalid state-invalid");
    }
    if (AgreementValidityPeriod == "") {
        IsValid = 0;
        $("#txtEntryAgreementValidityPeriod").addClass("is-invalid state-invalid");
    }
    */
  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Create";
    var Dealer_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Dealer_Id = $("#lblEntryId").html();
    }

    var url = "/Masters/Dealer";

    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      dealer_id: Dealer_Id,
      dealer_code: DealerCode,
      dealer_name: DealerName,

      salesarea_id: SalesArea_Id,
      salesuser_id: SalesUser_Id,

      mobile_no: MobileNo,
      phone_no: PhoneNo,
      contact_person: ContactPerson,
      email_id: Email_Id,
      pan_no: PANNo,

      address_line_1_text: AddressLine1,
      address_line_2_text: AddressLine2,
      state_id: State_Id,
      district_id: District_Id,
      taluka_id: Taluka_Id,
      pincode: PinCode,

      bank_id: Bank_Id,
      branch_id: Branch_Id,
      account_name: Account_Name,
      account_no: Account_No,
      ifsc_code: IFSC_Code,

      msme_no: MSME_No,
      fssai_license_no: FSSAILicense_No,
      fssai_licensevalidity_on: FSSAIValidityDate,
      agreement_validity_period: AgreementValidityPeriod,
      gst_no: GSTNo,
      is_agreement_done: AgreementDoneFlag,

      pan_card_photo: "",
      shop_license_photo: "",
      cheque_leaf_photo: "",

      shoplatitude: ShopLatitude,
      shoplongitude: ShopLongitude,

      login_password: Password,
      payment_url: PaymentUrl,
      is_payment: PaymentFlag,
    };

    //Save
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,

      success: function (res) {
        var result = JSON.parse(res);
        console.log("success", result);
        if (result[0].result_id == 1) {
          // Show Success Message
          ShowEntrySuccess("Dealers details saved successfully");
          ShowEditEntry(result[0].result_extra_key);
          $("#btn_Save").prop("disabled", false);
        } else {
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        ShowEntryError("Error : Dealers details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  return;
}

function SalesGroupEntry() {
  var DealerCode = $("#txtEntryDealerCode").val().trim();
  var APIEndPoint = "GetDealerMasterSalesArea";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    org_id: "",
    api_end_point: APIEndPoint,
    dealer_code: DealerCode,
  };
  Show_Loader();

  $("#btnSaveSalesGroup").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      Hide_Loader();
      if ((res_output[0].result_id = 1)) {
        Show_Success_Toastr("Dealer Sales Group Get Successfully");
      }

      GetSearchList();

      if (res_output.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
    },
    error: function () {
      Hide_Loader();
      Show_Error_Toastr("Error : Dealer Sales Group details not saved");
      $("#btnSaveSalesGroup").prop("disabled", false);
    },
  });
  $("#btnSaveSalesGroup").prop("disabled", false);
  return;
}

// function DownloadDealerSecurityDepositAmount() {
//   var APIEndPoint = "GetDealerMasterSecurityDeposits";
//   var url = "/Masters/DownloadDealer";

//   var reqdata = {
//     method_name: "Get",
//     org_id: "",
//     api_end_point: APIEndPoint,
//     dealer_code: "",
//   };

//   Show_Loader();

//   $("#btn_Search").prop("disabled", true);
//   $.ajax({
//     type: "POST",
//     url: url,
//     contentType: "application/json",
//     data: JSON.stringify(reqdata),
//     success: function (result) {
//       Hide_Loader();

//       var res = JSON.parse(result);
//       var res_output = JSON.parse(res);

//       console.log(res_output);

//       if (res_output.length > 0) {
//         if ((res_output[0].result_id = 1)) {
//           Show_Success_Toastr("Download Successfully");
//         }
//       }
//     },
//     error: function () {
//       Hide_Loader();
//     },
//   });
//   // enable search button to let user make function calls
//   $("#btn_Search").prop("disabled", false);
//   return;
// }

function DownloadDealerSecurityDepositAmount() {
  var APIEndPoint = "GetDealerMasterSecurityDeposits";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    org_id: "",
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

      if ((res.result_id = 1)) {
        Show_Success_Toastr(res.result_extra_key);
      } else {
        Show_Error_Toastr("Data not found.");
      }

      GetSearchList();

      // extract values and create an html string to assign to html table
    },
    error: function () {
      // Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
    },
  });
  // enable search button to let user make function calls
  $("#btn_Search").prop("disabled", false);
  return;
}

function SalesGroupEntryAll() {
  var APIEndPoint = "GetDealerMasterSalesAreaAll";
  var url = "/Masters/DownloadDealer";

  var reqdata = {
    method_name: "Download",
    api_end_point: APIEndPoint,
  };
  // Show_Loader();

  Show_Success_Toastr(
    "Data update is running in the background. Please do not press the button again.",
  );

  // $("#btnSaveSalesGroup").prop("disabled", true);
  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      var res_output = JSON.parse(res);
      // Hide_Loader();
      if ((res_output[0].result_id = 1)) {
        Show_Success_Toastr("Dealer Sales Group Get Successfully");
      }

      // GetSearchList();

      if (res_output.length == 0) {
        Show_Error_Toastr("Data not found.");
        return;
      }
    },
    error: function () {
      // Hide_Loader();
      Show_Error_Toastr("Error : Dealer Sales Group details not saved");
      $("#btnSaveSalesGroup").prop("disabled", false);
    },
  });
  $("#btnSaveSalesGroup").prop("disabled", false);
  return;
}
