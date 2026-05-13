var _pendingDistrictId = "";
var _pendingTalukaId = "";
$(document).ready(function () { });

/* -----    -----      Search for data in database as per values provided       -----   ----- */
function GetSearchList(e) {
    // disable search button to avoid multiple function calls
    $("#btn_Search").prop("disabled", true);
    ClearDataTable("tableSearch");
    // Get data from database and show in table
    var SearchText = "%" + $("#txtSearchText").val() + "%";
    var Method_Name = "Get_V2";
    var APIEndPoint = "GetSalesUser";
    var url = "/Masters/SalesUser";
    // store data in object and send to the controller
    var reqdata = {
        method_name: Method_Name,
        search_text: SearchText,
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
                Show_Error_Toastr("Data not found.");
                return;
            }
            // extract values and create an html string to assign to html table
            var TableHTML = "";
            var EditFlag = true;

            $.each(res, function (data, value) {
                var Active_Status;
                if (value.is_active == 0) {
                    Active_Status = "In-active";
                } else {
                    Active_Status = "Active";
                }
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";

                TableHTML += "<td>" + value.sap_bp_partner_code + "</td>";
                TableHTML += "<td>" + value.salesuser_name + "</td>";
                TableHTML += "<td>" + value.salesemployee + "</td>";
                TableHTML += "<td>" + value.salesuser_code + "</td>";
                TableHTML += "<td>" + value.salesuserrole_name + "</td>";
                TableHTML += "<td>" + value.reportingto_name + "</td>";
                TableHTML += "<td>" + (value.route_name ? value.route_name :'' )  + "</td>";
                TableHTML += "<td>" + value.mobile_no + "</td>";
                TableHTML += "<td>" + value.email_id + "</td>";
                // TableHTML += "<td>" + value.birth_date + "</td>";
                TableHTML += "<td>" + value.joining_date + "</td>";
                TableHTML += "<td>" + value.address_text + "</td>";
                TableHTML += "<td>" + value.state_name + "</td>";
                TableHTML += "<td>" + value.district_name + "</td>";
                TableHTML += "<td>" + value.taluka_name + "</td>";
                TableHTML += "<td>" + value.village_id + "</td>";
                TableHTML += "<td>" + value.pincode + "</td>";
                TableHTML += "<td>" + value.pan_no + "</td>";
                TableHTML += "<td>" + value.aadhar_no + "</td>";
                TableHTML += "<td>" + value.bank_name + "</td>";
                TableHTML += "<td>" + value.account_no + "</td>";
                TableHTML += "<td>" + value.ifsc_code + "</td>";
                TableHTML += "<td>" + value.account_name + "</td>";
                TableHTML += "<td>" + Active_Status + "</td>";
                TableHTML +=
                    "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                // if not locked, let the user edit the entry and give access to Edit & Delete functionality
                if (EditFlag == true) {
                    TableHTML +=
                        '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'' +
                        value.salesuser_id +
                        "')\">";
                    TableHTML += '<i class="fa fa-pencil"></i>';
                    TableHTML += "</a>";
                }
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });
            // assign the html string to table body present in the search page
            $("#tableData").html(TableHTML);
            // SetDataTable("tableSearch", [8], "Sales User List");

            SetDataTable_Master(
                "tableSearch",
                [24],
                "Sales User List",
                [4, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21],
                [
                    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                    21,
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
        },
    });
    // enable search button to let user make function calls
    $("#btn_Search").prop("disabled", false);
    return;
}

/* -----    -----      Show Entry Page with blank values for new entry       -----   ----- */
function ShowAddEntry() {
    $("#btn_Add").prop("disabled", false);
    ShowContentDiv("Masters", "SalesUserAdd", "", function () {
        // Initialization Code
        $("#divSalesPersonRouteList").hide();
        // to clear input field errors whenever user pastes any text in the input fields
        ClearInputFieldError();

        // setting span text values to perform operations like Create/Update(Edit)
        $("#lblEntryId").html("");
        $("#lblAction").html("Add");
        $("#divFooterDelete").hide();

        // setting drop downs
        $("#ddlEntrySalesUserRole").select2();
        $("#ddlEntryReportingTo").select2();
        $("#ddlEntryState").select2();
        $("#ddlEntryDistrict").select2();
        $("#ddlEntryTaluka").select2();
        $("#ddlEntrySalesArea").select2();
        $("#txtEntrySalesRouteName").select2();
        // $("#ddlEntryVillage").select2();
        GetMaster(
            "ddlEntrySalesArea",
            "Select Sales Group",
            "GetSalesArea",
            "",
            ""
        );


        // $("#ddlEntrySalesArea").off("change").on("change", function () {
        //     GetSalesRoute("", $("#ddlEntrySalesArea").val() || "");
        // })

        // setting drop down values
        GetMaster(
            "ddlEntrySalesUserRole",
            "Select Sales User Role",
            "GetSalesUserRole",
            "",
            ""
        );
        GetMaster(
            "ddlEntryReportingTo",
            "Select Reporting Sales User",
            "GetAreaSalesManager",
            "",
            ""
        );
        GetMaster("ddlEntryState", "Select State", "GetState", "", "");

        // show/hide reporting to ddl on sales user role change
        $("#ddlEntrySalesUserRole").on("change", function () {
            if ($("#ddlEntrySalesUserRole").find(":selected").val() == "C044002") {
                $("#divReportingTo").hide();
            } else {
                $("#divReportingTo").show();
            }
        });

        $("#txtEntryPanNo").on("input", function () {
            // Convert the input value to uppercase and set it back to the input
            var inputValue = $(this).val();
            var uppercaseValue = inputValue.toUpperCase();
            $(this).val(uppercaseValue);
        });
    });
    $("#btn_Add").prop("disabled", false);
    return;
}

/* -----    -----
 * Extract single record from database based on Sales User Id
 * and assign it's values to input fields in the Entry Page
 *        -----   ----- */
function ShowEditEntry(SalesUser_Id) {
    ShowContentDiv("Masters", "SalesUserEdit", "", function () {
        // Initialization Code
        $("#lblEntryId").html(SalesUser_Id);
        GetSalesPersonRouteList(SalesUser_Id);
        $("#lblAction").html("Edit");
        $("#divSalesPersonRouteList").show();
        $("#divFooterDelete").show();

        // setting drop downs
        $("#ddlEntrySalesUserRole").select2();
        $("#ddlEntryReportingTo").select2();
        $("#ddlEntryState").select2();
        $("#ddlEntryDistrict").select2();
        $("#ddlEntryTaluka").select2();
        $("#ddlEntrySalesUserRole").select2();
        $("#txtEntrySalesRouteName").select2();
        $("#ddlEntrySalesArea").select2();
        // $("#ddlEntryVillage").select2();

        var Method_Name = "Get_One";
        var APIEndPoint = "GetSalesUser";
        var url = "/Masters/SalesUser";
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
                if (res.length == 0) {
                    Show_Error_Toastr("Data Not Found");
                    CloseEntry();
                    return;
                }
                $("#txtEntrySAPBPPartnerCode").val(res[0].sap_bp_partner_code);
                $("#txtEntrySalesUserName").val(res[0].salesuser_name);
                $("#txtEntryMobileNo").val(res[0].mobile_no);
                $("#txtEntryJoiningDate").val(res[0].joining_date);
                $("#txtEntryEmailID").val(res[0].email_id);
                $("#txtEntryPanNo").val(res[0].pan_no);
                $("#txtEntryAadharNo").val(res[0].aadhar_no);
                $("#txtEntrySalesEmployee").val(res[0].salesemployee);
                $("#txtEntryAddress").val(res[0].address_text);
                $("#ddlEntryVillage").val(res[0].village_id);
                $("#txtEntryPassword").val(res[0].login_password);
                if (res[0].is_active == 1) {
                    $("#chkEntryStatus").prop("checked", true);
                } else {
                    $("#chkEntryStatus").prop("checked", false);
                }

                if (res[0].online_app_flag == "0") {
                    $("#chkOnlineAppFlag").prop("checked", false);
                } else {
                    $("#chkOnlineAppFlag").prop("checked", true);
                }
                GetMaster(
                    "ddlEntrySalesArea",
                    "Select Sales Group",
                    "GetSalesArea",
                    res[0].salesarea_id || "",
                    ""
                );
                // $("#ddlEntrySalesArea").off("change").on("change", function () {
                //     GetSalesRoute(res[0].route_id || "", res[0].salesarea_id || $("#ddlEntrySalesArea").val() || "");
                // })

                // setting drop down values
                GetMaster(
                    "ddlEntrySalesUserRole",
                    "Select Sales User Role",
                    "GetSalesUserRole",
                    res[0].salesuserrole_id,
                    ""
                );
                GetMaster(
                    "ddlEntryReportingTo",
                    "Select Reporting Sales User",
                    "GetAreaSalesManager",
                    res[0].reportingto_id,
                    ""
                );
                _pendingDistrictId = res[0].district_id;
                _pendingTalukaId = res[0].taluka_id;

                GetMaster("ddlEntryState", "Select State", "GetState", res[0].state_id, "");


                // GetMaster("ddlEntryVillage", "Select City", "GetVillage", res[0].village_id, res[0].taluka_id);

                // show/hide reporting to ddl
                if (res[0].salesuserrole_id == "C044002") {
                    $("#divReportingTo").hide();
                } else {
                    $("#divReportingTo").show();
                }
                $("#txtEntryPanNo").on("input", function () {
                    // Convert the input value to uppercase and set it back to the input
                    var inputValue = $(this).val();
                    var uppercaseValue = inputValue.toUpperCase();
                    $(this).val(uppercaseValue);
                });

                // show/hide reporting to ddl on sales user role change
                $("#ddlEntrySalesUserRole").on("change", function () {
                    if (
                        $("#ddlEntrySalesUserRole").find(":selected").val() == "C044002"
                    ) {
                        $("#divReportingTo").hide();
                    } else {
                        $("#divReportingTo").show();
                    }
                });
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

/* -----    -----
 * Validate inserted data and if valid, send it to the controller
 * to save in the database table.
 *        -----   ----- */
function SaveEntry() {
    $("#btn_Save").prop("disabled", true);

    // assigning input values to variables
    var SAP_BP_Partner_Code = $("#txtEntrySAPBPPartnerCode").val().trim();
    var SalesUserName = $("#txtEntrySalesUserName").val().trim();
    var Mobile_No = $("#txtEntryMobileNo").val().trim();
    var Joining_Date = $("#txtEntryJoiningDate").val();
    var EmailId = $("#txtEntryEmailID").val().trim();
    var ReportingTo_Id = $("#ddlEntryReportingTo").val();
    var SalesUserRole_Id = $("#ddlEntrySalesUserRole").val();
    var PanNo = $("#txtEntryPanNo").val().trim();
    var AadharNo = $("#txtEntryAadharNo").val().trim();
    var State_Id = $("#ddlEntryState").val();
    var District_Id = $("#ddlEntryDistrict").val();
    var Taluka_Id = $("#ddlEntryTaluka").val();
    var Village_Id = $("#ddlEntryVillage").val();
    var Address_Text = $("#txtEntryAddress").val().trim();
    var Password = $("#txtEntryPassword").val().trim();
    var salesarea_id = $("#ddlEntrySalesArea").val().trim();
  
    var SalesEmployee = $("#txtEntrySalesEmployee").val().trim();

    var OnlineFlag = 0;
    if ($("#chkOnlineAppFlag").prop("checked")) {
        OnlineFlag = 1;
    }
    var IsValid = 1;
    // validating inserted values
    if (
        SAP_BP_Partner_Code == "" ||
        SAP_BP_Partner_Code == null ||
        SAP_BP_Partner_Code == undefined ||
        Is_AlphaNumeric(SAP_BP_Partner_Code) == false
    ) {
        IsValid = 0;
        $("#txtEntrySAPBPPartnerCode").addClass("is-invalid state-invalid");
    }
    if (Password == "" || Password == null || Password == undefined) {
        IsValid = 0;
        $("#txtEntryPassword").addClass("is-invalid state-invalid");
    }
    if (
        SalesUserName == "" ||
        SalesUserName == null ||
        SalesUserName == undefined ||
        Is_Valid_Name(SalesUserName) == false
    ) {
        IsValid = 0;
        $("#txtEntrySalesUserName").addClass("is-invalid state-invalid");
    }
    if (
        SalesUserRole_Id == "" ||
        SalesUserRole_Id == null ||
        SalesUserRole_Id == undefined
    ) {
        IsValid = 0;
        $("#ddlEntrySalesUserRole").addClass("is-invalid state-invalid");
    }
    // if role is sales user, then Area Sales Manager must be selected
    if (SalesUserRole_Id == "C044001") {
        if (
            ReportingTo_Id == "" ||
            ReportingTo_Id == null ||
            ReportingTo_Id == undefined
        ) {
            IsValid = 0;
            $("#ddlEntryReportingTo").addClass("is-invalid state-invalid");
        }
    }

    if (
        Mobile_No == "" ||
        Mobile_No == null ||
        Mobile_No == undefined ||
        Is_Valid_MobileNo(Mobile_No) == false ||
        Mobile_No <= 0
    ) {
        IsValid = 0;
        $("#txtEntryMobileNo").addClass("is-invalid state-invalid");
    }
    if (Joining_Date == "" || Joining_Date == null || Joining_Date == undefined) {
        IsValid = 0;
        $("#txtEntryJoiningDate").addClass("is-invalid state-invalid");
    }
    if (EmailId != "") {
        if (
            EmailId == null ||
            EmailId == undefined ||
            Is_Valid_Email(EmailId) == false
        ) {
            IsValid = 0;
            $("#txtEntryEmailID").addClass("is-invalid state-invalid");
        }
    }

    if (
        PanNo == "" ||
        PanNo == null ||
        PanNo == undefined ||
        Is_Valid_PanNO(PanNo) == false
    ) {
        IsValid = 0;
        $("#txtEntryPanNo").addClass("is-invalid state-invalid");
    }
    if (
        AadharNo == "" ||
        AadharNo == null ||
        AadharNo == undefined ||
        Is_Valid_AadharNo(AadharNo) == false
    ) {
        IsValid = 0;
        $("#txtEntryAadharNo").addClass("is-invalid state-invalid");
    }
    // if (
    //   SalesEmployee == "" ||
    //   SalesEmployee == null ||
    //   SalesEmployee == undefined
    // ) {
    //   IsValid = 0;
    //   $("#txtEntrySalesEmployee").addClass("is-invalid state-invalid");
    // }
    if (State_Id == "" || State_Id == null || State_Id == undefined) {
        IsValid = 0;
        $("#ddlEntryState").addClass("is-invalid state-invalid");
    }
    if (District_Id == "" || District_Id == null || District_Id == undefined) {
        IsValid = 0;
        $("#ddlEntryDistrict").addClass("is-invalid state-invalid");
    }
    if (Taluka_Id == "" || Taluka_Id == null || Taluka_Id == undefined) {
        IsValid = 0;
        $("#ddlEntryTaluka").addClass("is-invalid state-invalid");
    }
    if (Village_Id == "" || Village_Id == null || Village_Id == undefined) {
        IsValid = 0;
        $("#ddlEntryVillage").addClass("is-invalid state-invalid");
    }
    if (Address_Text == "" || Address_Text == null || Address_Text == undefined) {
        IsValid = 0;
        $("#txtEntryAddress").addClass("is-invalid state-invalid");
    }
    if (salesarea_id == "" || salesarea_id == null || salesarea_id == undefined) {
        IsValid = 0;
        $("#ddlEntrySalesArea").addClass("is-invalid state-invalid");
    }
    if (IsValid == 0) {
        Show_Error_Toastr("Invalid Input(s). Can't be saved.");
        return;
    } else {
        // Start Saving if valid date is inserted
        var Method_Name = "Create";
        var SalesUser_Id = "";
        var Action_Name = $("#lblAction").html();
        if (Action_Name == "Edit") {
            Method_Name = "Update";
            SalesUser_Id = $("#lblEntryId").html();
        }
        var Is_Active = 0;
        if ($("#chkEntryStatus").is(":checked") == true) {
            Is_Active = 1;
        }
        var Is_Deleted = 0;
        var APIEndPoint = "SaveSalesUser";
        var url = "/Masters/SalesUser";
        var reqdata = {
            is_active: Is_Active,
            is_deleted: Is_Deleted,
            method_name: Method_Name,
            api_end_point: APIEndPoint,

            salesuser_id: SalesUser_Id,
            sap_bp_partner_code: SAP_BP_Partner_Code,
            salesuser_name: SalesUserName,
            mobile_no: Mobile_No,
            joining_date: Joining_Date,
            email_id: EmailId,
            reportingto_id: ReportingTo_Id,
            salesuserrole_id: SalesUserRole_Id,
            pan_no: PanNo,
            aadhar_no: AadharNo,
            state_id: State_Id,
            district_id: District_Id,
            taluka_id: Taluka_Id,
            village_id: Village_Id,
            address_text: Address_Text,
            online_app_flag: OnlineFlag,
            salesemployee: SalesEmployee,
            login_password: Password,
            salesarea_id
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
                    ShowEntrySuccess("Sales User details saved successfully");
                    ShowEditEntry(result[0].result_extra_key);
                    //$("#lblEntryId").html(result[0].result_extra_key);
                    //$("#lblAction").html("Edit");
                    //$("#divFooterDelete").show();
                    $("#btn_Save").prop("disabled", false);
                } else {
                    ShowEntryError("Error : " + result[0].result_description);
                    $("#btn_Save").prop("disabled", false);
                }
            },
            error: function () {
                Show_Error_Toastr("Error : Sales User details not saved");
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
    var SalesUser_Id = $("#lblEntryId").html();
    var APIEndPoint = "SaveSalesUser";
    var url = "/Masters/SalesUser";
    var Method_Name = "Delete";
    var reqdata = {
        salesuser_id: SalesUser_Id,
        method_name: Method_Name,
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
                Show_Success_Toastr("Sales User details deleted successfully");
                CloseEntry();
            } else {
                ShowEntryError("Error : " + result[0].result_description);
            }
        },
        error: function () {
            ShowEntryError("Error : Sales User details not deleted");
        },
    });
}

// Get a list of districts in the selected state. Called when State Dropdown value is changed


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

function GetVillage() {
    var Taluka_Id = $("#ddlEntryTaluka").val();
    //GetMaster("ddlEntryVillage", "Select City", "GetVillage", "", Taluka_Id);
}

function GetSalesPersonRouteList(SalesUser_Id) {
    ClearDataTable("tableSearchEntry");

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
                        '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowSalesPersonRouteEntry(\'' +
                        value.route_id +
                        "', '" +
                        value.routeday_id +
                        "', '" +
                        value.salesuser_id +
                        "', '" +
                        value.salesuser_name +
                        "','" +
                        value.working_status +
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

            $("#tableDataEntry").html(TableHTML);
            SetDataTable("tableSearchEntry", [5], "Sales User Route");
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

function ShowSalesPersonRouteEntry(
    Route_Id,
    RouteDay_id,
    SalesUser_Id,
    SalesUser_Name,
    Working_Status,
    RouteDay_Name,
    Remarks,
    Route_Name
) {
    $("#lblActionSalesPersonRouteRoute_Id").html(Route_Id);
    $("#lblActionSalesPersonRouteSalesUser_Id").html(SalesUser_Id);
    $("#lblActionSalesPersonRouteSalesUser_Name").html(SalesUser_Name);
    $("#lblActionSalesPersonRouteWorking_Status").html(Working_Status);
    $("#lblActionSalesPersonRouteRouteDay_Name").html(RouteDay_Name);
    $("#lblActionSalesPersonRouteRemarks").html(Remarks);
    $("#lblActionSalesPersonRouteRoute_Name").html(Route_Name);
    $("#lblActionSalesPersonRouteRouteDay_id").html(RouteDay_id);

    $("#modelEntrySalesPersonRoute")
        .modal({
            backdrop: "static",
        })
        .modal("show");

    ClearDataTable("tableSalesPersonRouteEntryModal");
    var Method_Name = "Get_One";
    var APIEndPoint = "GetSalesUserRoute";
    var url = "/Transactions/SalesUserRoute";
    var reqdata = {
        method_name: Method_Name,
        salesuser_id: SalesUser_Id,
        route_id: `["` + Route_Id + `"]`,
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
            if (res.length == 0) {
                Hide_Loader();
                Show_Error_Toastr("Retailers not found.");
                return;
            }
            var TableHTML = "";
            var EditFlag = 1;
            var checked = "";

            $.each(res, function (data, value) {
                if (value.is_locked == 1) {
                    checked = "checked";
                } else {
                    checked = "";
                }
                TableHTML += "<tr>";

                TableHTML += '<td class="text-center" style="width: 20px;">';
                TableHTML += '<label class="custom-control custom-checkbox">';
                TableHTML +=
                    '<input type="checkbox" id="retailer' +
                    (data + 1) +
                    '" class="custom-control-input" ' +
                    checked +
                    " />";
                TableHTML +=
                    '<label for="retailer' +
                    (data + 1) +
                    '" class="custom-control-label text-dark"></label>';
                TableHTML += "</label>";
                TableHTML += "</td>";
                TableHTML += "<td hidden>" + value.retailer_id + "</td>";
                TableHTML += "<td>" + value.retailer_name + "</td>";
                //TableHTML += "<td>" + value.salesarea_name + "</td>";
                TableHTML += "</tr>";
            });

            $("#tableDataSalesPersonRouteEntry").html(TableHTML);
            // SetDataTable("tableSalesPersonRouteEntryModal", [1], "Sales User Route Retailer List");

            SetDataTable_Filter(
                "tableSalesPersonRouteEntryModal",
                [1],
                "Sales User Route Retailer List"
            );

            Hide_Loader();
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

function SaveSalesPersonRoute() {
    // Validation code
    var Remarks = $("#lblActionSalesPersonRouteRemarks").html();
    var Working_Status = $("#lblActionSalesPersonRouteWorking_Status").html();

    // store table data in an xml string
    var RetailerList = "<RetailerList>";
    var Total_Retailers = 0;
    $("#tableSalesPersonRouteEntryModal tbody tr").each(function () {
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

    var Day = $("#lblActionSalesPersonRouteRouteDay_Name").html();
    var DayId = $("#lblActionSalesPersonRouteRouteDay_id").html();
    var routename = $("#lblActionSalesPersonRouteRoute_Name").html();

    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Update";
    var Route_Id = $("#lblActionSalesPersonRouteRoute_Id").html();
    // var Action_Name = $("#lblAction").html();
    var SalesUser_Id = $("#lblActionSalesPersonRouteSalesUser_Id").html();
    var Is_Active = 1;
    var Is_Deleted = 0;
    var APIEndPoint = "SaveSalesUserRoute";
    var url = "/Transactions/SalesUserRoute";
    var reqdata = {
        is_active: Is_Active,
        is_deleted: Is_Deleted,
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        route_id: Route_Id,
        salesuser_id: SalesUser_Id,
        remarks: Remarks,
        working_status: Working_Status,
        total_retailers: Total_Retailers,
        retailer_list: RetailerList,
        routeday_id: DayId,
        route_name: routename,
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
                $("#modelEntrySalesPersonRoute").modal("hide");
                GetSalesPersonRouteList(SalesUser_Id);
            } else {
                ShowEntryError("Error : " + result[0].result_description);
                $("#modelEntrySalesPersonRoute").modal("hide");
                GetSalesPersonRouteList(SalesUser_Id);
            }
        },
        error: function () {
            ShowEntryError("Error : Sales Area details not saved");
            $("#modelEntrySalesPersonRoute").modal("hide");
            GetSalesPersonRouteList(SalesUser_Id);
        },
    });
}

function GetSalesRoute(routeId, salesAreaId) {

    GetMaster("txtEntrySalesRouteName", "Select Day", "GetRouteNameWSU", routeId || "", salesAreaId || "");
}

function ShowDayReOpenEntry() {

    ClearDataTable("tableEntryModal");
    $("#modalEntry")
        .modal({
            backdrop: "static",
        })
        .modal("show");

    var Method_Name = "Get";
    var APIEndPoint = "GetSalesUserReOpen";
    var url = "/Masters/SalesUser";

    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
    };

    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            var TableHTML = "";
            var Row_No = 0;
            $.each(res, function (data, value) {

                var Active_Status;
                if (value.status == 1) {
                    Active_Status = "Start Day";
                } else {
                    Active_Status = "End Day";
                }

                Row_No = Row_No + 1;

                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + Row_No + "</td>";
                TableHTML += "<td>" + value.salesuser_name + "</td>";
                TableHTML += "<td>" + value.route_name + "</td>";

                TableHTML += "<td>" + value.routeday_name + "</td>";
                TableHTML += "<td>" + value.start_time + "</td>";
                TableHTML += "<td>" + value.end_time + "</td>";
                TableHTML += "<td>" + value.date + "</td>";
                TableHTML += "<td>" + Active_Status + "</td>";

                TableHTML +=
                    "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                // if not locked, let the user edit the entry and give access to Edit & Delete functionality

                TableHTML +=
                    '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Day ReOpen" onclick="ShowReOpenDayEntry(\'' +
                    value.entry_id +
                    "')\">";
                TableHTML += '<i class="fa fa-backward"></i>';
                TableHTML += "</a>";

                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableEntryModalData").html(TableHTML);

            SetDataTable("tableEntryModal", [8], "ReOpen");
        },
        error: function () {
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description
            );
        },
    });
}


function ShowReOpenDayEntry(entry_id) {
    swal(
        {
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: "question",
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, Reopen Day it!",
        },
        function (result) {
            if (result == true) {
                ShowEditReOpenDayEntry(entry_id);
            }
        }
    );
}

function ShowEditReOpenDayEntry(entry_id) {

    var Method_Name = "Update";

    var APIEndPoint = "SaveSalesUserReOpen";
    var url = "/Masters/SalesUser";
    var reqdata = {
        entry_id: entry_id,
        method_name: Method_Name,
        api_end_point: APIEndPoint,
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
                Show_Success_Toastr("Sales User Day ReOpen details saved successfully");
                ShowDayReOpenEntry();

            } else {
                Show_Error_Toastr("Error : " + result[0].result_description);

            }
        },
        error: function () {
            Show_Error_Toastr("Error : Sales User Day ReOpen details not saved");

        },
    });


}