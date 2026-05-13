$(document).ready(function () {

    $("#ddlSearchSalesUserName").select2();
    $("#ddlSearchApprovalStatus").select2();

    GetMaster("ddlSearchSalesUserName", "Select Sales User", "GetSalesUser", "", "");
    GetMaster("ddlSearchApprovalStatus", "Select Approval Status", "GetApprovedStatus", 0, "");

    $('input[name="datefilter"]').daterangepicker({
        locale: {
            cancelLabel: "Clear",
        },
        startDate: moment().subtract(30, 'days'), // Set the startDate to 30 days ago
        endDate: moment(), // Set the endDate to the current date
        ranges: {
            'Today': [moment(), moment()],
            'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
            'Last 7 Days': [moment().subtract(6, 'days'), moment()],
            'Last 30 Days': [moment().subtract(29, 'days'), moment()],
            'This Month': [moment().startOf('month'), moment().endOf('month')],
            'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        }
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

function GetSearchList(e) {
    ClearDataTable("tableSearch");
    // Get data from database and show in table

    var SearchSalesUser_Id = "%" + $("#ddlSearchSalesUserName").val() + "%";
    var SearchApprovalStatus_Id = $("#ddlSearchApprovalStatus").val();
    var SearchRequestPeriod = $("#txtSearchRequestPeriod").val();
    if (SearchApprovalStatus_Id == "") {
        $("#ddlSearchApprovalStatus").addClass("is-invalid state-invalid");
        return;
    }
    var Method_Name = 'Get';
    var APIEndPoint = "GetRetailersAuthorization";
    var url = "/Transactions/RetailersAuthorization";

    var reqdata = {
        "method_name": Method_Name,
        "salesuser_id": SearchSalesUser_Id,
        "approvalstatus_id": SearchApprovalStatus_Id,
        "request_period": SearchRequestPeriod,
        "api_end_point": APIEndPoint
    };
    $("#btn_Search").prop('disabled', true);

    Show_Loader();
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            if (res.length == 0) {
                Hide_Loader();
                Show_Error_Toastr("Data not found.");
                $("#btn_Search").prop('disabled', false);
                return;
            }
            // Fill data in table
            var TableHTML = "";
            var EditFlag = false; // IsEditAllowed($("#lblAS").html());

            $.each(res, function (data, value) {
                var Approved_Status;
                EditFlag = false;
                if (value.is_approved == 1) {
                    Approved_Status = "Approved";
                }
                else if (value.is_approved == 0) {
                    Approved_Status = "Pending";
                    EditFlag = true;
                }
                else {
                    Approved_Status = "Rejected";
                }

                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.retailer_name + "</td>";
                TableHTML += "<td>" + value.dealer_name + "</td>";
                TableHTML += "<td>" + value.salesuser_name + "</td>";
                TableHTML += "<td>" + value.salesarea_name + "</td>";
                TableHTML += "<td>" + Approved_Status + "</td>";
                TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";

                if (EditFlag == true) {

                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowApprovalEntry('Edit','" + value.retailer_id + "')\">";
                    TableHTML += "<i class=\"fa fa-pencil\"></i>";
                    TableHTML += "</a>";
                }
                else {
                    TableHTML += "" + value.approved_on ?? "" + "";
                    // View
                    /*
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"View\" onclick=\"ShowApproveEntry('View','" + value.retailer_id + "')\">";
                    TableHTML += "<i class=\"fa fa-eye\"></i>";
                    TableHTML += "</a>";
                    */
                }
                TableHTML += "</td>";
                TableHTML += "</tr>";

            });

            $("#tableData").html(TableHTML);

            SetDataTable("tableSearch", [6], "Retailers Authorization");
            $("#btn_Search").prop('disabled', false);

            Hide_Loader();
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            $("#btn_Search").prop('disabled', false);
        }
    });
    $("#btn_Search").prop('disabled', false);
    return;
}
function ShowApprovalEntry(Action, Retailer_Id) {
    ShowContentDiv('Transactions', 'RetailersAuthorizationEdit', '', function () {
        $("#ddlEntryApprovalStatus").select2();
        $("#ddlEntrySalesArea").select2();
        $("#ddlEntryDealerName").select2();
        $("#ddlEntryState").select2();
        $("#ddlEntryDistrict").select2();
        $("#ddlEntryTaluka").select2();
        $("#ddlEntrySalesUser").select2();
        $("#ddlEntryBankName").select2();
        $("#ddlEntryBranchName").select2();

        $("#lblEntryId").html(Retailer_Id);
        $("#lblAction").html(Action);


        $('#ddlEntryApprovalStatus').on("change", function () {
            var selectedValue = $(this).val();
            var selectedWord = "Yes, Reject it!";
            if (selectedValue == 0) {
                selectedWord = "Yes, Keep it Pending!";
            }


            if (selectedValue != "") {
                if (!(selectedValue == 1)) {
                    swal(
                        {
                            title: "Are you sure?",
                            text: "You won't be able to revert this!",
                            icon: "question",
                            type: "warning",
                            showCancelButton: true,
                            confirmButtonText: selectedWord,
                        },
                        function (result) {
                            if (result == true) {
                                GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", selectedValue, "");
                            }
                        }
                    );
                }
                if ($("#ddlEntryApprovalStatus").find(":selected").val() != 0) {
                    $("#btn_Save").show();
                } else {
                    $("#btn_Save").hide();
                }
            }
        });


        var Method_Name = 'Get_One';
        var APIEndPoint = "GetRetailersAuthorization";
        var url = "/Transactions/RetailersAuthorization";
        var reqdata = {
            "method_name": Method_Name,
            "retailer_id": Retailer_Id,
            "api_end_point": APIEndPoint
        };
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);
                if (res.length == 0) {
                    Show_Error_Toastr("Data not found.");
                    return;
                }

                $("#txtEntryRetailerName").val(res[0].retailer_name);
                $("#txtEntryContactPersonName").val(res[0].contact_person);
                $("#txtEntryMobileNo").val(res[0].mobile_no);
                $("#txtEntryEmailId").val(res[0].email_id);

                $("#txtEntryAddress1").val(res[0].address_line_1_text);
                $("#txtEntryAddress2").val(res[0].address_line_2_text);
                $("#txtEntryPinCode").val(res[0].pincode);

                $("#txtEntryAccountName").val(res[0].account_name);
                $("#txtEntryAccountNo").val(res[0].account_no);
                SetIFSCCode(res[0].branch_id);

                $("#txtEntryShopLicenseNo").val(res[0].shop_license_no);
                $("#txtEntryPanNo").val(res[0].pan_no);
                $("#txtEntryShopLatitude").val(res[0].shoplatitude);
                $("#txtEntryShopLongitude").val(res[0].shoplongtitude);
                $("#txtEntryFSSAILicenseNo").val(res[0].fssai_license_no);
                $("#txtEntryFSSAIValidityDate").val(res[0].fssai_licensevalidity_on);
                $("#txtEntryGSTNo").val(res[0].gst_no);
                $("#txtEntryAgreementValidityPeriod").val(res[0].agreement_validity_period);
                $("#txtEntrySecurityDepositAmount").val(res[0].securitydepositamount);
                $("#txtEntryRemarks").val(res[0].approval_remarks);

                GetMaster("ddlEntryApprovalStatus", "Select Approval Status", "GetApprovedStatus", res[0].is_approved, "");
                GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", res[0].dealer_id, "");
                GetMaster("ddlEntrySalesUser", "Select Sales User", "GetSalesUser", res[0].salesuser_id, "");
                GetMaster("ddlEntrySalesArea", "Select Sales Group", "GetSalesArea", res[0].salesarea_id, "")
                GetMaster("ddlEntryState", "Select State", "GetState", res[0].state_id, "");
                GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", res[0].district_id, res[0].state_id);
                GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", res[0].taluka_id, res[0].district_id);
                GetMaster("ddlEntryBankName", "Select Bank", "GetBank", res[0].bank_id, "");
                GetMaster("ddlEntryBranchName", "Select Branch", "GetBranch", res[0].branch_id, res[0].bank_id);

                if (res[0].is_active == 1) {
                    $('#chkEntryStatus').prop("checked", true);
                }
                else {
                    $('#chkEntryStatus').prop("checked", false);
                }
                if (res[0].is_agreement_done == 1) {
                    $('#chkAgreementDoneFlag').prop("checked", true);
                }
                else {
                    $('#chkAgreementDoneFlag').prop("checked", false);
                }

                $('input[name="datefilter"]').daterangepicker({
                    locale: {
                        cancelLabel: "Clear",
                    },
                    startDate: moment().subtract(30, 'days'), // Set the startDate to 30 days ago
                    endDate: moment(), // Set the endDate to the current date
                    ranges: {
                        'Today': [moment(), moment()],
                        'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                        'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                        'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                        'This Month': [moment().startOf('month'), moment().endOf('month')],
                        'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
                    }
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
            }
        });
    });


}


function SaveEntry() {
    $("#btn_Save").prop('disabled', true);

    // Validation code
    var ApprovalStatus_Id = $("#ddlEntryApprovalStatus").val();
    var Approval_Remarks = $("#txtEntryRemarks").val().trim();

    var Retailer_Name = $("#txtEntryRetailerName").val().trim();

    var SalesArea_Id = $("#ddlEntrySalesArea").val();
    var Dealer_Id = $("#ddlEntryDealerName").val();
    var SalesUser_Id = $("#ddlEntrySalesUser").val();


    var Mobile_No = $("#txtEntryMobileNo").val().trim();
    var Email_Id = $("#txtEntryEmailId").val().trim();
    var Contact_Person = $("#txtEntryContactPersonName").val().trim();

    var Address_Line_1_Text = $("#txtEntryAddress1").val().trim();
    var Address_Line_2_Text = $("#txtEntryAddress2").val().trim();
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


    if (ApprovalStatus_Id == "") {
        IsValid = 0;
        $("#ddlEntryApprovalStatus").addClass("is-invalid state-invalid");
    }
    if (Approval_Remarks == "") {
        IsValid = 0;
        $("#txtEntryRemarks").addClass("is-invalid state-invalid");
    }
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
    if (SalesUser_Id == "") {
        IsValid = 0;
        $("#ddlEntrySalesUser").addClass("is-invalid state-invalid");
    }
    if (Pan_No == "" || Is_Valid_PanNO(Pan_No) == false) {
        IsValid = 0;
        $("#txtEntryPanNo").addClass("is-invalid state-invalid");
    }

    if ((Email_Id != "") && Is_Valid_Email(Email_Id) == false) {
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
    if (Shop_License_No == "") {
        IsValid = 0;
        $("#txtEntryShopLicenseNo").addClass("is-invalid state-invalid");
    }
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
    if (FSSAILicense_No == "" || Is_Valid_FSSAINO(FSSAILicense_No) == false) {
        IsValid = 0;
        $("#txtEntryFSSAILicenseNo").addClass("is-invalid state-invalid");
    }
    if (FSSAIValidityDate == "") {
        IsValid = 0;
        $("#txtEntryFSSAIValidityDate").addClass("is-invalid state-invalid");
    }
    if (GSTNo == "") {
        IsValid = 0;
        $("#txtEntryGSTNo").addClass("is-invalid state-invalid");
    }
    if (AgreementValidityPeriod == "") {
        IsValid = 0;
        $("#txtEntryAgreementValidityPeriod").addClass("is-invalid state-invalid");
    }

    if (IsValid == 0) {
        Show_Error_Toastr("Invalid Input(s). Can't be saved.");
        return;
    }
    else {
        // Start Saving
        var APIEndPoint = "SaveRetailersAuthorization";
        var Method_Name = 'Create';
        var Retailer_Id = "";
        var Action_Name = $("#lblAction").html();
        if (Action_Name == 'Edit') {
            Method_Name = 'Update';
            Retailer_Id = $("#lblEntryId").html();
        }
        var Is_Deleted = 0;
        var url = "/Transactions/RetailersAuthorization";
        var reqdata = {
            "is_active": Is_Active,
            "is_deleted": Is_Deleted,
            "method_name": Method_Name,
            "api_end_point": APIEndPoint,

            "is_approved": ApprovalStatus_Id,
            "approval_remarks": Approval_Remarks,

            "retailer_id": Retailer_Id,
            "retailer_name": Retailer_Name,
            "salesarea_id": SalesArea_Id,
            "salesuser_id": SalesUser_Id,
            "dealer_id": Dealer_Id,

            "pan_no": Pan_No,
            "mobile_no": Mobile_No,
            "email_id": Email_Id,
            "contact_person": Contact_Person,

            address_line_1_text: Address_Line_1_Text,
            address_line_2_text: Address_Line_2_Text,
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
            is_agreement_done: AgreementDoneFlag,

            "pan_card_photo": "",
            "shop_license_photo": "",
            "cheque_leaf_photo": "",
            "shop_name_photo": "",
            "aadhar_photo": "",
            "udyam_aadhar_photo": "",
            "fssai_license_photo": "",
            "gst_certificate_photo": ""
        };

        //Save
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,

            success: function (res) {
                var result = JSON.parse(res);
                if (result[0].result_id == 1) {
                    // Show Success Message
                    Show_Success_Toastr("Retailer " + result[0].result_description);
                    $("#btn_Save").prop('disabled', false);
                    CloseEntry();
                } else {
                    Show_Error_Toastr("Error : " + result[0].result_description);
                    $("#btn_Save").prop('disabled', false);
                }

            },
            error: function () {
                Show_Error_Toastr("Error : Retailer details not saved");
                $("#btn_Save").prop('disabled', false);
            }
        });
    }
    $("#btn_Save").prop('disabled', false);
    return;
}

function GetDistrict() {
    //Empty All Childeren/Dependent DDLs
    $("#ddlEntryTaluka").empty().append($("<option></option>").val("").html("Select Taluka"));

    var State_Id = $("#ddlEntryState").val();
    GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", "", State_Id);
}

function GetTaluka() {
    // Empty All Children/Dependent DDls

    var District_Id = $("#ddlEntryDistrict").val();
    GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", "", District_Id);

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


