var _pendingDistrictId = "";
var _pendingTalukaId = "";
var _pendingDealerId = "";
var _pendingSalesUserId = "";

$(document).ready(function () {
  $("#ddlSearchSalesArea").select2();
  $("#ddlSearchDealerName").select2();
  GetMaster("ddlSearchDealerName", "Select Dealer Name", "GetDealer", "", "");
  GetMaster("ddlSearchSalesArea", "Select Sales Group", "GetSalesArea", "", "");
});

function GetSearchList(e) {
  ClearDataTable("tableSearch");
  // Validate Data
  var Retailer_Name = "%" + $("#txtSearchRetailerName").val() + "%";
  var Dealer_Id = "%" + $("#ddlSearchDealerName").val() + "%";
  var SalesArea_Id = "%" + $("#ddlSearchSalesArea").val() + "%";

  // if (
  //   $("#ddlSearchSalesArea").val() == "" ||
  //   $("#ddlSearchSalesArea").val() == undefined
  // ) {
  //   $("#ddlSearchSalesArea").addClass("is-invalid state-invalid");
  //   return;
  // }

  $("#btn_Search").prop("disabled", true);
  var Method_Name = "Get_V1";
  var APIEndPoint = "GetRetailer";
  var url = "/Masters/Retailer";
  var reqdata = {
    method_name: Method_Name,
    retailer_name: Retailer_Name,
    dealer_id: Dealer_Id,
    salesarea_id: SalesArea_Id,
    api_end_point: APIEndPoint,
  };

  Show_Loader();

  $.ajax({
    type: "POST",
    url: url,
    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
    data: reqdata,
    success: function (result) {
      var res = JSON.parse(result);
      // Fill data in table
      var TableHTML = "";

      var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

      $.each(res, function (data, value) {
        var Active_Status;
          // ... Status logic ...
          if (value.is_active == 0) {
              Active_Status = "In-active";
          } else {
              Active_Status = "Active";
          }

          TableHTML += "<tr>";
          TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>"; // #

          TableHTML += "<td>" + (value.retailer_name || '') + "</td>"; // Retailer Name
          TableHTML += "<td>" + (value.salesarea_name || '') + "</td>"; // Sales Group
          TableHTML += "<td>" + (value.route_name || '') + "</td>"; // Route Name
          TableHTML += "<td>" + (value.dealer_code || '') + "</td>"; // Dealer Code
          TableHTML += "<td>" + (value.dealer_name || '') + "</td>"; // Dealer Name

          // Corrected Ternary Logic: (condition ? if_true : if_false)
          // Note: Ensure casing matches your SQL alias (e.g., Monday_User or monday_user)
          TableHTML += "<td>" + (value.monday_User ? value.monday_User : '') + "</td>";
          TableHTML += "<td>" + (value.tuesday_User ? value.tuesday_User : '') + "</td>";
          TableHTML += "<td>" + (value.wednesday_User ? value.wednesday_User : '') + "</td>";
          TableHTML += "<td>" + (value.thursday_User ? value.thursday_User : '') + "</td>";
          TableHTML += "<td>" + (value.friday_User ? value.friday_User : '') + "</td>";
          TableHTML += "<td>" + (value.saturday_User ? value.saturday_User : '') + "</td>";
          TableHTML += "<td>" + (value.sunday_User ? value.sunday_User : '') + "</td>";

          // REMOVED extra dealer_name here to keep alignment
          TableHTML += "<td>" + (value.mobile_no || '') + "</td>"; // Mobile No
          TableHTML += "<td>" + (value.landline_number || '') + "</td>"; // Landline No
          TableHTML += "<td>" + (value.contact_person || '') + "</td>"; // Contact Person
          TableHTML += "<td>" + (value.email_id || '') + "</td>"; // Email Id
          TableHTML += "<td>" + (value.address_line_1_text || '') + "</td>"; // Address 1
          TableHTML += "<td>" + (value.address_line_2_text || '') + "</td>"; // Address 2
          TableHTML += "<td>" + (value.address_line_3_text || '') + "</td>"; // Address 3
          TableHTML += "<td>" + (value.state_name || '') + "</td>"; // State
          TableHTML += "<td>" + (value.district_name || '') + "</td>"; // District
          TableHTML += "<td>" + (value.taluka_name || '') + "</td>"; // Taluka
          TableHTML += "<td>" + (value.pincode || '') + "</td>"; // Pincode
          TableHTML += "<td>" + (value.pan_no || '') + "</td>"; // Pan No
          TableHTML += "<td>" + (value.shoplatitude || '') + "</td>"; // Latitude
          TableHTML += "<td>" + (value.shoplongitude || '') + "</td>"; // Longitude
          TableHTML += "<td>" + (value.shop_license_no || '') + "</td>"; // Shop License
          TableHTML += "<td>" + (value.bank_name || '') + "</td>"; // Bank
          TableHTML += "<td>" + (value.branch_name || '') + "</td>"; // Branch
          TableHTML += "<td>" + (value.account_no || '') + "</td>"; // Account No
          TableHTML += "<td>" + (value.ifsc_code || '') + "</td>"; // IFSC
          TableHTML += "<td>" + (value.account_name || '') + "</td>"; // Account Name
          TableHTML += "<td>" + (value.fssai_license_no || '') + "</td>"; // FSSAI No
          TableHTML += "<td>" + (value.fssai_licensevalidity_on || '') + "</td>"; // FSSAI Date
          TableHTML += "<td>" + (value.agreementvalidiy_startdate || '') + "</td>"; // Start Date
          TableHTML += "<td>" + (value.agreementvalidity_enddate || '') + "</td>"; // End Date
          TableHTML += "<td>" + (value.securitydepositamount || '') + "</td>"; // Deposit
          TableHTML += "<td>" + (value.msme || '') + "</td>"; // MSME
          TableHTML += "<td>" + (value.aadhar_no || '') + "</td>"; // Aadhar
          TableHTML += "<td>" + (value.asme || '') + "</td>"; // ASME
          TableHTML += "<td>" + (value.gst_no || '') + "</td>"; // GST
          TableHTML += "<td>" + Active_Status + "</td>"; // Status

          TableHTML += "<td class='text-right' style='width: 50px; padding:8px 5px 8px 5px;'>";
          if (EditFlag == true) {
              TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' + value.retailer_id + "')\">";
              TableHTML += '<i class="fa fa-pencil"></i></a>';
          }
          TableHTML += "</td>";
          TableHTML += "</tr>";
      });

      $("#tableData").html(TableHTML);
      Hide_Loader();

      // SetDataTable("tableSearch", [5], "Retailer");
      SetDataTable_Master(
        "tableSearch",
        [41],
        "Retailer",
        [
          3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
          23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33,
        ],
        [
          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
          20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
        ]
      );
      $("#btn_Search").prop("disabled", false);
    },
    error: function () {
      Show_Error_Toastr(
        "Error in fetching details from server.",
        res[0].result_description
      );
      $("#btn_Search").prop("disabled", false);
      Hide_Loader();
    },
  });

  return;
}

function chnageSalesArea() {
  var SalesArea_Id = "%" + $("#ddlSearchSalesArea").val() + "%";
  GetMaster(
    "ddlSearchDealerName",
    "Select Dealer Name",
    "GetDealerBySalesGroup",
    "",
    SalesArea_Id
  );
}

function changeEntrySalesArea() {
    var SalesArea_Id = $("#ddlEntrySalesArea").val();
    GetMaster("ddlEntryDealerName", "Select Dealer", "GetDealerBySalesGroup", _pendingDealerId, SalesArea_Id);
    _pendingDealerId = "";
}

function ShowAddEntry() {
  ShowContentDiv("Masters", "RetailerAdd", "", function () {
    // Initialization Code

    $("#ddlEntrySalesArea").select2();
    $("#ddlEntryDealerName").select2();
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntrySalesUser").select2();
    $("#ddlEntryBankName").select2();
      $("#ddlEntryBranchName").select2();
      $("#txtEntrySalesRouteName").select2();

    $("#lblEntryId").html("");
    $("#lblAction").html("Add");

      GetMaster("ddlEntrySalesUser", "Select Sales User", "GetSalesUser", "", "");
    
      $("#ddlEntrySalesArea").off("change").on("change", function () {
          GetSalesRoute("", $("#ddlEntrySalesArea").val() || "");
      })
      
    GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");
    GetMaster("ddlEntrySalesArea", "Select Sales Area", "GetSalesArea", "", "");
    GetMaster("ddlEntryState", "Select State", "GetState", "", "");
    GetMaster("ddlEntryBankName", "Select Bank", "GetBank", "", "");
      GetMaster("ddlEntryBranchName", "Select Branch", "GetBranch", "", "");
      

    $("#divFooterDelete").hide();

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
}

function ShowEditEntry(Retailer_Id) {
  ShowContentDiv("Masters", "RetailerEdit", "", function () {
    // Initialization Code
    $("#ddlEntrySalesArea").select2();
    $("#ddlEntryDealerName").select2();
    $("#ddlEntryState").select2();
    $("#ddlEntryDistrict").select2();
    $("#ddlEntryTaluka").select2();
    $("#ddlEntrySalesUser").select2();
    $("#ddlEntryBankName").select2();
    $("#ddlEntryBranchName").select2();
      $("#txtEntrySalesRouteName").select2();

    $("#lblEntryId").html(Retailer_Id);
    $("#lblAction").html("Edit");

    $("#divFooterDelete").show();

    $("#ddlEntrySalesArea").prop("disabled", true);

    var Method_Name = "Get_One";
    var APIEndPoint = "GetRetailer";
    var url = "/Masters/Retailer";
    var reqdata = {
      method_name: Method_Name,
      retailer_id: Retailer_Id,
      api_end_point: APIEndPoint,
    };
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,
      success: function (result) {
        var res = JSON.parse(result);

        // console.log(res);
    
        $("#txtEntryRetailerName").val(res[0].retailer_name);
        $("#txtEntryContactPersonName").val(res[0].contact_person);
        $("#txtEntryMobileNo").val(res[0].mobile_no);
        $("#txtEntryLandlineNo").val(res[0].landline_number);
        $("#txtEntryEmailId").val(res[0].email_id);

        $("#txtEntryAddress1").val(res[0].address_line_1_text);
        $("#txtEntryAddress2").val(res[0].address_line_2_text);
        $("#txtEntryAddress3").val(res[0].address_line_3_text);
        $("#txtEntryPinCode").val(res[0].pincode);

        $("#txtEntryAccountName").val(res[0].account_name);
        $("#txtEntryAccountNo").val(res[0].account_no);

        $("#txtEntryShopLicenseNo").val(res[0].shop_license_no);
        $("#txtEntryPanNo").val(res[0].pan_no);
        $("#txtEntryMSME").val(res[0].msme);
        $("#txtEntryShopLatitude").val(res[0].shoplatitude);
        $("#txtEntryShopLongitude").val(res[0].shoplongitude);
        $("#txtEntryFSSAILicenseNo").val(res[0].fssai_license_no);
        $("#txtEntryFSSAIValidityDate").val(res[0].fssai_licensevalidity_on);
        $("#txtEntryGSTNo").val(res[0].gst_no);
        $("#txtEntryAgreementValidityPeriod").val(
          res[0].agreement_validity_period
        );
        $("#txtEntrySecurityDepositAmount").val(res[0].securitydepositamount);
          GetMaster(
              "ddlEntrySalesArea",
              "Select Sales Group",
              "GetSalesArea",
              res[0].salesarea_id,
              ""
          );
        GetMaster(
          "ddlEntryDealerName",
          "Select Dealer",
          "GetDealerBySalesGroup",
          res[0].dealer_id,
          res[0].salesarea_id
        );
          _pendingDealerId = res[0].dealer_id;
          _pendingSalesUserId = res[0].salesuser_id;

       

     
         
     
          $("#ddlEntrySalesArea").off("change").on("change", function () {
              GetSalesRoute(res[0].route_id || "", res[0].salesarea_id || $("#ddlEntrySalesArea").val()||"");
          })

          _pendingDistrictId = res[0].district_id;
          _pendingTalukaId = res[0].taluka_id;

          GetMaster("ddlEntryState", "Select State", "GetState", res[0].state_id, "");

        GetMaster(
          "ddlEntryBankName",
          "Select Bank",
          "GetBank",
          res[0].bank_id,
          ""
        );
        GetMaster(
          "ddlEntryBranchName",
          "Select Branch",
          "GetBranch",
          res[0].branch_id,
          res[0].bank_id
        );

        SetIFSCCode(res[0].branch_id);

        //GetMaster("ddlEntrySalesUser", "Select Sales User", "GetSalesUserbydealer", res[0].salesuser_id, Dealer_Id);
        //GetMaster("ddlEntrySalesArea", "Select Sales Group", "GetSalesArea", res[0].salesarea_id, "")
        //GetMaster("ddlEntryState", "Select State", "GetState", res[0].state_id, "");
        //GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", res[0].district_id, res[0].state_id);
        //GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", res[0].taluka_id, res[0].district_id);
        //GetMaster("ddlEntryBankName", "Select Bank", "GetBank", res[0].bank_id, "");
        //GetMaster("ddlEntryBranchName", "Select Branch", "GetBranch", res[0].branch_id, res[0].bank_id);

        $("#txtEntryASME").val(res[0].asme);
        $("#txtEntryAadharNo").val(res[0].aadhar_no);

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
      },
      error: function () {
        Show_Error_Toastr("Error in fetching details from server.");
      },
    });
  });
}





function GetDistrict() {
    $("#ddlEntryTaluka").empty().append($("<option></option>").val("").html("Select Taluka"));
    var State_Id = $("#ddlEntryState").val();
    GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", _pendingDistrictId, State_Id);
    _pendingDistrictId = "";
}

function GetTaluka() {
    var District_Id = $("#ddlEntryDistrict").val();
    GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", _pendingTalukaId, District_Id);
    _pendingTalukaId = "";
}
function GetBranch() {
  $("#txtEntryIFSCCode").text("");
  var Bank_Id = $("#ddlEntryBankName").val();
  GetMaster(
    "ddlEntryBranchName",
    "Select Branch Name",
    "GetBranch",
    "",
    Bank_Id
  );
}

function SetIFSCCode(Branch_Id) {
  if (Branch_Id == "") {
    var Branch_Id = $("#ddlEntryBranchName").val();
  }
  GetIFSCCode(Branch_Id, "txtEntryIFSCCode");
}

function CloseEntry() {
  GetSearchList();
  HideContentDiv();
}

function SaveEntry() {
  $("#btn_Save").prop("disabled", true);

  // Validation code
  var Retailer_Name = $("#txtEntryRetailerName").val().trim();

  var SalesArea_Id = $("#ddlEntrySalesArea").val();
    var Dealer_Id = $("#ddlEntryDealerName").val();
    var Route_Id = $("#txtEntrySalesRouteName").val();

  var Mobile_No = $("#txtEntryMobileNo").val().trim();
  var Landline = $("#txtEntryLandlineNo").val().trim();
  var Email_Id = $("#txtEntryEmailId").val().trim();
  var Contact_Person = $("#txtEntryContactPersonName").val().trim();

  var Address_Line_1_Text = $("#txtEntryAddress1").val().trim();
  var Address_Line_2_Text = $("#txtEntryAddress2").val().trim();
  var Address_Line_3_Text = $("#txtEntryAddress3").val().trim();
  var State_Id = $("#ddlEntryState").val();
  var District_Id = $("#ddlEntryDistrict").val();
  var Taluka_Id = $("#ddlEntryTaluka").val();
  var Pincode = $("#txtEntryPinCode").val().trim();

  var Bank_Id = $("#ddlEntryBankName").val();
  var Branch_Id = $("#ddlEntryBranchName").val();
  var Account_Name = $("#txtEntryAccountName").val().trim();
  var Account_No = $("#txtEntryAccountNo").val().trim();
  var IFSC_Code = $("#txtEntryIFSCCode").text();

  var Shop_License_No = $("#txtEntryShopLicenseNo").val().trim();
  var Pan_No = $("#txtEntryPanNo").val().trim();
  var MSME = $("#txtEntryMSME").val().trim();
  var FSSAILicense_No = $("#txtEntryFSSAILicenseNo").val().trim();
  var FSSAIValidityDate = $("#txtEntryFSSAIValidityDate").val();
  var GSTNo = $("#txtEntryGSTNo").val().trim();

  var ASME = $("#txtEntryASME").val().trim();
  var AadharNo = $("#txtEntryAadharNo").val().trim();

  var AgreementValidityPeriod = $("#txtEntryAgreementValidityPeriod").val();
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

  if (Retailer_Name == "") {
    IsValid = 0;
    $("#txtEntryRetailerName").addClass("is-invalid state-invalid");
  }
  if (SalesArea_Id == "") {
    IsValid = 0;
    $("#ddlEntrySalesArea").addClass("is-invalid state-invalid");
  }
  if (Dealer_Id == "") {
    IsValid = 0;
    $("#ddlEntryDealerName").addClass("is-invalid state-invalid");
  }
  if (Route_Id == "") {
    IsValid = 0;
      $("#txtEntrySalesRouteName").addClass("is-invalid state-invalid");
  }
  /*if (Pan_No == "" || Is_Valid_PanNO(Pan_No) == false) {
        IsValid = 0;
        $("#txtEntryPanNo").addClass("is-invalid state-invalid");
    }*/

  if (Email_Id != "" && Is_Valid_Email(Email_Id) == false) {
    IsValid = 0;
    $("#txtEntryEmailId").addClass("is-invalid state-invalid");
  }

  if (Mobile_No == "" || Is_Valid_MobileNo(Mobile_No) == false) {
    IsValid = 0;
    $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
  }
  if (Address_Line_1_Text == "") {
    IsValid = 0;
    $("#txtEntryAddress1").addClass("is-invalid state-invalid");
  }
  if (Address_Line_2_Text == "") {
    IsValid = 0;
    $("#txtEntryAddress2").addClass("is-invalid state-invalid");
  }
  if (Address_Line_3_Text == "") {
    IsValid = 0;
    $("#txtEntryAddress3").addClass("is-invalid state-invalid");
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
  if (Pincode == "" || Is_Valid_PINNO(Pincode) == false) {
    IsValid = 0;
    $("#txtEntryPinCode").addClass("is-invalid state-invalid");
  }

  if (Contact_Person == "" || Is_Valid_Name(Contact_Person) == false) {
    IsValid = 0;
    $("#txtEntryContactPersonName").addClass("is-invalid state-invalid");
  }
  /*
    if (Shop_License_No == "") {
        IsValid = 0;
        $("#txtEntryShopLicenseNo").addClass("is-invalid state-invalid");
    }*/
  /*
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
    */
  /*
    if (FSSAILicense_No == "" || Is_Valid_FSSAINO(FSSAILicense_No) == false) {
        IsValid = 0;
        $("#txtEntryFSSAILicenseNo").addClass("is-invalid state-invalid");
    }
    if (FSSAIValidityDate == "") {
        IsValid = 0;
        $("#txtEntryFSSAIValidityDate").addClass("is-invalid state-invalid");
    }
    if (GSTNo == "" || Is_Valid_GST(GSTNo) == false) {
        IsValid = 0;
        $("#txtEntryGSTNo").addClass("is-invalid state-invalid");
    }
    if (AgreementValidityPeriod == "") {
        IsValid = 0;
        $("#txtEntryAgreementValidityPeriod").addClass("is-invalid state-invalid");
    }*/

  if (IsValid == 0) {
    ShowEntryError("Invalid Input(s). Can't be saved.");
    return;
  } else {
    // Start Saving
    var APIEndPoint = "SaveRetailer";
    var url = "/Masters/Retailer";
    var Method_Name = "Create";
    var Retailer_Id = "";
    var Action_Name = $("#lblAction").html();
    if (Action_Name == "Edit") {
      Method_Name = "Update";
      Retailer_Id = $("#lblEntryId").html();
    }
    var Is_Deleted = 0;
    var Is_Approved = 1;
    var url = "/Masters/Retailer";
    var reqdata = {
      is_active: Is_Active,
      is_deleted: Is_Deleted,
      method_name: Method_Name,
      api_end_point: APIEndPoint,

      retailer_id: Retailer_Id,
      retailer_name: Retailer_Name,
      salesarea_id: SalesArea_Id,
      route_id: Route_Id,
      dealer_id: Dealer_Id,
      is_approved: Is_Approved,

      pan_no: Pan_No,
      msme: MSME,
      mobile_no: Mobile_No,
      landline_number: Landline,
      email_id: Email_Id,
      contact_person: Contact_Person,

      address_line_1_text: Address_Line_1_Text,
      address_line_2_text: Address_Line_2_Text,
      address_line_3_text: Address_Line_3_Text,
      state_id: State_Id,
      district_id: District_Id,
      taluka_id: Taluka_Id,
      pincode: Pincode,

      bank_id: Bank_Id,
      branch_id: Branch_Id,
      account_name: Account_Name,
      account_no: Account_No,
      ifsc_code: IFSC_Code,

      shop_license_no: Shop_License_No,
      fssai_license_no: FSSAILicense_No,
      fssai_licensevalidity_on: FSSAIValidityDate,
      agreement_validity_period: AgreementValidityPeriod,
      gst_no: GSTNo,
      is_agreemengst_certificate_photot_done: AgreementDoneFlag,

      pan_card_photo: "",
      shop_license_photo: "",
      cheque_leaf_photo: "",
      shop_name_photo: "",
      aadhar_photo: "",
      udyam_aadhar_photo: "",
      fssai_license_photo: "",
      "": "",

      asme: ASME,
      aadhar_no: AadharNo,
    };

    //Save
    $.ajax({
      type: "POST",
      url: url,
      contentType: "application/x-www-form-urlencoded; charset=UTF-8",
      data: reqdata,

      success: function (res) {
        var result = JSON.parse(res);
        // console.log("success", result);
        if (result[0].result_id == 1) {
          // Show Success Message
          ShowEntrySuccess("Retailer details saved successfully");
          $("#btn_Save").prop("disabled", false);
          ShowEditEntry(result[0].result_extra_key);
        } else {
          ShowEntryError("Error : " + result[0].result_description);
          $("#btn_Save").prop("disabled", false);
        }
      },
      error: function () {
        ShowEntryError("Error : Vehicle details not saved");
        $("#btn_Save").prop("disabled", false);
      },
    });
  }
  $("#btn_Save").prop("disabled", false);
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
  var Retailer_Id = $("#lblEntryId").html();
  var APIEndPoint = "SaveRetailer";
  var url = "/Masters/Retailer";
  var reqdata = {
    retailer_id: Retailer_Id,
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
        Show_Success_Toastr("Retailer details deleted successfully");
        CloseEntry();
      } else {
        ShowEntryError("Error : " + result[0].result_description);
      }
    },
    error: function () {
      ShowEntryError("Error : Retailer details not deleted");
    },
  });
}




function ChnageDealerName() {
    var Dealer_Id = $("#ddlEntryDealerName").val();
    GetMaster("ddlEntrySalesUser", "Select Sales User", "GetSalesUserbydealer", _pendingSalesUserId, Dealer_Id);
    _pendingSalesUserId = "";
}

function GetSalesRoute(routeId, salesAreaId) {
    GetMaster("txtEntrySalesRouteName", "Select Day", "GetRouteNameWSU", routeId || "", salesAreaId || "");
}