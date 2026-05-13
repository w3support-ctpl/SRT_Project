var _pendingSalesUserId = '';
var _pendingDealerId = '';
var rid = '';
$(document).ready(function () { GetSearchList('') });

/* -----    -----      Search for data in database as per values provided       -----   ----- */
function GetSearchList(e) {
    // Disable search button
    $("#btn_Search").prop("disabled", true);

    // Clear existing table content
    if ($.fn.DataTable.isDataTable('#tableSearch')) {
        $('#tableSearch').DataTable().clear().destroy();
    }

    var SearchText = "%" + $("#txtSearchText").val() + "%";
    var Method_Name = "GetAll";
    var APIEndPoint = "GetRouteSU";
    var url = "/Masters/Route";

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
            var res = typeof result === 'string' ? JSON.parse(result) : result;
            if (!res || res.length == 0) {
                Show_Error_Toastr("Data not found.");
                $("#btn_Search").prop("disabled", false);
                return;
            }

            // 2. Build Headers (Count: 8 Columns | Indices: 0-7)
            var TableHTML = "<thead><tr>";
            TableHTML += "<th style='width: 20px;'>#</th>"; // 0
            TableHTML += "<th>Route Name</th>";            // 1
          
            TableHTML += "<th>Work Status</th>";           // 3
            TableHTML += "<th>Retailers</th>";             // 4
            TableHTML += "<th>Remarks</th>";               // 5
            TableHTML += "<th>Status</th>";                // 6
            TableHTML += "<th style='width: 40px;'>Action</th>"; // 7
            TableHTML += "</tr></thead><tbody>";

            // 3. Build Body (Must have exactly 8 <td> tags)
            $.each(res, function (index, value) {
                var Active_Status = (value.is_Active === true || value.is_Active == 1) ? "Active" : "In-active";
                var Working_Label = (value.working_Status == "1") ? "Working" : "Off";

                TableHTML += "<tr>";
                TableHTML += "<td>" + (index + 1) + "</td>"; // 0
                TableHTML += "<td>" + (value.route_Name || "---") + "</td>"; // 1
              
                TableHTML += "<td>" + Working_Label + "</td>"; // 3
                TableHTML += "<td>" + (value.total_Retailers || 0) + "</td>"; // 4
                TableHTML += "<td>" + (value.remarks || "") + "</td>"; // 5
                TableHTML += "<td>" + Active_Status + "</td>"; // 6
                TableHTML += "<td class='text-center'>"; // 7
                TableHTML += '  <a href="javascript:void(0);" title="Edit" onclick="ShowEditEntry(\'' + value.route_Id + '\')">';
                TableHTML += '      <i class="fa fa-pencil text-primary"></i>';
                TableHTML += '  </a>';
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            TableHTML += "</tbody>";

            // 4. Inject into Table
            $("#tableSearch").html(TableHTML);

            // 4. Initialize DataTables
            SetDataTable_Master(
                "tableSearch",
                [],                     // no hidden columns
                "Route Master List",
                [],
                [1, 2, 3, 4, 5, 6]           // all data columns except serial number
            );
            $("#btn_Search").prop("disabled", false);
        },
        error: function () {
            Show_Error_Toastr("Error fetching details.");
            $("#btn_Search").prop("disabled", false);
        }
    });
}

/* -----    -----      Show Entry Page with blank values for new entry       -----   ----- */
function ShowAddEntry() {
    $("#btn_Add").prop("disabled", false);
    rid = '';
    ShowContentDiv("Masters", "RouteAdd", "", function () {
        // Initialization Code
        $("#divSalesPersonRouteList").hide();
        // to clear input field errors whenever user pastes any text in the input fields
        ClearInputFieldError();

        // setting span text values to perform operations like Create/Update(Edit)
        $("#lblEntryId").html("");
        $("#lblAction").html("Add");
        $("#divFooterDelete").hide();

        // setting drop downs
        $("#ddlEntryRouteRole").select2();
        $("#ddlEntrySalesArea").select2();
        $("#ddlEntryDealerName").select2();
        $("#ddlEntryReportingTo").select2();
        $("#ddlEntryState").select2();
        $("#ddlEntryDistrict").select2();
        $("#ddlEntryTaluka").select2();
      
        // $("#ddlEntryVillage").select2();
        GetMaster("ddlEntryDealerName", "Select Dealer Name", "GetDealer", "", "");
        GetMaster("ddlEntrySalesArea", "Select Sales Area", "GetSalesArea", "", "");
        // setting drop down values
        GetMaster(
            "ddlEntryRouteRole",
            "Select Sales User Role",
            "GetRouteRole",
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
 

        // show/hide reporting to ddl on sales user role change
        $("#ddlEntryRouteRole").on("change", function () {
            if ($("#ddlEntryRouteRole").find(":selected").val() == "C044002") {
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
    $("#btn_Add").prop("disabled", false);
    return;
}

/* -----    -----
 * Extract single record from database based on Sales User Id
 * and assign it's values to input fields in the Entry Page
 *        -----   ----- */
function ShowEditEntry(Route_Id) {
    ShowContentDiv("Masters", "RouteEdit", "", function () {
        // Initialization Code
        $("#lblEntryId").html(Route_Id);
        rid = Route_Id;
        $("#lblAction").html("Edit");
       
        $("#divFooterDelete").show();

        // setting drop downs
        $("#ddlEntrySalesArea").select2();
        $("#ddlEntryDealerName").select2();
        $("#ddlEntryRouteDay").select2();
      
        // $("#ddlEntryVillage").select2();

        var Method_Name = "GetById";
        var APIEndPoint = "GetRouteSU";
        var url = "/Masters/Route";
        var reqdata = {
            method_name: Method_Name,
            Route_id: Route_Id,
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
                // debugger;
                // 1. Set Hidden ID and Labels
                $("#lblEntryId").text(res[0].route_Id);
                $("#lblRouteHeader").text("Edit Route: " + res[0].route_Name);

                // 2. Set Input Fields
                $("#txtEntryRouteName").val(res[0].route_Name);
                $("#txtEntryRemarks").val(res[0].remarks);

                // 3. Set Status Checkboxes
                // Active Status
                if (res[0].is_Active == 1) {
                    $("#chkEntryStatus").prop("checked", true);
                } else {
                    $("#chkEntryStatus").prop("checked", false);
                }

                // Working Day Status
                if (res[0].working_Status == 1) {
                    $("#chkWorkingStatus").prop("checked", true);
                } else {
                    $("#chkWorkingStatus").prop("checked", false);
                }

                // 4. Set Dropdown Values
                // Sales Organization
                GetMaster("ddlEntryRouteDay", "Select Day", "GetRouteDay", res[0].routeDay_Id||"", "");
                GetMaster(
                    "ddlEntrySalesArea",
                    "Select Sales Group",
                    "GetSalesArea",
                    res[0].salesArea_Id,
                    ""
                );
                GetMaster(
                    "ddlEntryDealerName",
                    "Select Dealer",
                    "GetDealerBySalesGroup",
                    res[0].dealer_Id,
                    res[0].salesArea_Id
                );
                _pendingDealerId = res[0].dealer_Id;
                _pendingSalesUserId = res[0].salesArea_Id;


                // 5. Show Delete Option (Since we are in Edit mode)
                $("#divFooterDelete").show();

                // Note: If you are using Select2 for your dropdowns,
                // the .trigger('change') ensures the UI updates correctly.
            },
            error: function () {
                Show_Error_Toastr("Error in fetching details from server.");
            },
        });
    });
}

function CloseEntry() {
    GetSearchList('');
    HideContentDiv();
}

/* -----    -----
 * Validate inserted data and if valid, send it to the controller
 * to save in the database table.
 *        -----   ----- */
/**
 * Saves the Route Entry details to the server.
 */
function SaveEntry() {
    // 1. Reset alert visibility
    $("#divEntrySuccess, #divEntryError").hide();

    // 2. Fetch Values from HTML IDs
    var entryId = $("#lblEntryId").text().trim();
    var SalesArea_Id = $("#ddlEntrySalesArea").val();
    var Dealer_Id = $("#ddlEntryDealerName").val();
    var routeName = $("#txtEntryRouteName").val().trim();
    var routeDayId = $("#ddlEntryRouteDay").val();
    var isWorkingDay = $("#chkWorkingStatus").is(":checked") ? "1" : "0";
    var isActive = $("#chkEntryStatus").is(":checked") ? 1 : 0;
    var remarks = $("#txtEntryRemarks").val().trim();

    // --- NEW: Fetch Selected Retailers List ---
    var selectedRetailers = [];
    $(".chkRetailer:checked").each(function () {
        // Find the hidden ID in the same row
        var rId = $(this).closest("tr").find(".retailer-id").text().trim();
        if (rId !== "") {
            selectedRetailers.push({
                retailer_id: rId
            });
        }
    });

    // 3. Validation
    var isValid = true;
    $(".is-invalid").removeClass("is-invalid state-invalid"); // Reset previous errors

    if (SalesArea_Id == "" || SalesArea_Id == null) {
        isValid = false;
        $("#ddlEntrySalesArea").addClass("is-invalid state-invalid");
    }
    if (Dealer_Id == "" || Dealer_Id == null) {
        isValid = false;
        $("#ddlEntryDealerName").addClass("is-invalid state-invalid");
    }
    if (routeName === "") {
        isValid = false;
        $("#txtEntryRouteName").addClass("is-invalid");
    }
    if (selectedRetailers.length === 0) {
        isValid = false;
        Show_Error_Toastr("Please select at least one retailer.");
    }

    if (!isValid) {
        if (selectedRetailers.length > 0) Show_Error_Toastr("Please fill in all required fields.");
        return;
    }

    // 4. Prepare Request Data Object
    var reqdata = {
        method_name: "Save",
        api_end_point: "SaveRouteSU",
        entry_id: entryId,
        sales_area_id: SalesArea_Id,
        route_name: routeName,
        salesarea_id: SalesArea_Id,
        dealer_id: Dealer_Id,
        route_day_id: routeDayId,
        working_status: isWorkingDay,
        is_active: isActive,
        remarks: remarks,
        // Convert the array to a JSON string for the backend to parse
        retailer_list: JSON.stringify(selectedRetailers)
    };

    // 5. AJAX Call
    $.ajax({
        type: "POST",
        url: "/Masters/Route",
        data: reqdata,
        beforeSend: function () {
            $("#btn_Save").addClass("btn-loading").prop("disabled", true);
        },
        success: function (response) {
            $("#btn_Save").removeClass("btn-loading").prop("disabled", false);
            var res_output = JSON.parse(response);

            // Extract the first object from the returned list
            var result = (res_output && res_output.length > 0) ? res_output[0] : null;

            if (result != null && result.result_id == 1) {
                // SUCCESS CASE
                $("#divEntrySuccess").text(result.result_description).fadeIn().delay(3000).fadeOut();
                Show_Success_Toastr(result.result_description);
                rid = result.result_extra_key;

                // Refresh list and close form
                if (typeof GetList === "function") GetList();
                CloseEntry();
            }
            else if (result != null && result.result_id == -1) {
                // ERROR CASE
                $("#divEntryError").text(result.result_description).show();
                Show_Error_Toastr(result.result_description);
            }
            else {
                Show_Error_Toastr("Invalid response from server.");
            }
        },
        error: function () {
            $("#btn_Save").removeClass("btn-loading").prop("disabled", false);
            Show_Error_Toastr("Error saving route details.");
        }
    });
}

/**
 * Clears the invalid CSS state when user interacts with fields
 */

/**
 * Resets the form and hides the entry card
 */

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
    var Route_Id = $("#lblEntryId").html();
    var APIEndPoint = "SaveRoute";
    var url = "/Masters/Route";
    var Method_Name = "Delete";
    var reqdata = {
        Route_id: Route_Id,
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
    //Empty All Childeren/Dependent DDLs
    $("#ddlEntryTaluka")
        .empty()
        .append($("<option></option>").val("").html("Select Taluka"));
    // $("#ddlEntryVillage").empty().append($("<option></option>").val("").html("Select City"));
    var State_Id = $("#ddlEntryState").val();
    GetMaster("ddlEntryDistrict", "Select District", "GetDistrict", "", State_Id);
}

// Get a list of talka in the selected district. Called when District Dropdown value is changed
function GetTaluka() {
    // Empty All Children/Dependent DDls
    // $("#ddlEntryVillage").empty().append($("<option></option>").val("").html("Select City"));
    var District_Id = $("#ddlEntryDistrict").val();
    GetMaster("ddlEntryTaluka", "Select Taluka", "GetTaluka", "", District_Id);
}

// Get a list of villages in the selected taluka. Called when Taluka Dropdown value is changed
function GetVillage() {
    var Taluka_Id = $("#ddlEntryTaluka").val();
    // GetMaster("ddlEntryVillage", "Select City", "GetVillage", "", Taluka_Id);
}

function GetSalesPersonRouteList(Route_Id) {
    ClearDataTable("tableSearchEntry");

    var Method_Name = "Get";
    var APIEndPoint = "GetRouteRoute";
    var url = "/Transactions/RouteRoute";
    var reqdata = {
        method_name: Method_Name,
        Route_id: Route_Id,
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
                        value.Route_id +
                        "', '" +
                        value.Route_name +
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
    Route_Id,
    Route_Name,
    Working_Status,
    RouteDay_Name,
    Remarks,
    Route_Name
) {
    $("#lblActionSalesPersonRouteRoute_Id").html(Route_Id);
    $("#lblActionSalesPersonRouteRoute_Id").html(Route_Id);
    $("#lblActionSalesPersonRouteRoute_Name").html(Route_Name);
    $("#lblActionSalesPersonRouteWorking_Status").html(Working_Status);
    $("#lblActionSalesPersonRouteRouteDay_Name").html(RouteDay_Name);
    $("#lblActionSalesPersonRouteRemarks").html(Remarks);
    $("#lblActionSalesPersonRouteRoute_Name").html(Route_Name);

    $("#modelEntrySalesPersonRoute")
        .modal({
            backdrop: "static",
        })
        .modal("show");

    ClearDataTable("tableSalesPersonRouteEntryModal");
    var Method_Name = "Get_One";
    var APIEndPoint = "GetRouteRoute";
    var url = "/Transactions/RouteRoute";
    var reqdata = {
        method_name: Method_Name,
        Route_id: Route_Id,
        route_id: Route_Id,
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
    var routename = $("#lblActionSalesPersonRouteRoute_Name").html();

    // Start Saving
    $("#btn_Save").prop("disabled", true);
    var Method_Name = "Update";
    var Route_Id = $("#lblActionSalesPersonRouteRoute_Id").html();
    // var Action_Name = $("#lblAction").html();
    var Route_Id = $("#lblActionSalesPersonRouteRoute_Id").html();
    var Is_Active = 1;
    var Is_Deleted = 0;
    var APIEndPoint = "SaveRouteRoute";
    var url = "/Transactions/RouteRoute";
    var reqdata = {
        is_active: Is_Active,
        is_deleted: Is_Deleted,
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        route_id: Route_Id,
        Route_id: Route_Id,
        remarks: Remarks,
        working_status: Working_Status,
        total_retailers: Total_Retailers,
        retailer_list: RetailerList,
        routeday_id: Day,
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
                GetSalesPersonRouteList(Route_Id);
            } else {
                ShowEntryError("Error : " + result[0].result_description);
                $("#modelEntrySalesPersonRoute").modal("hide");
                GetSalesPersonRouteList(Route_Id);
            }
        },
        error: function () {
            ShowEntryError("Error : Sales Area details not saved");
            $("#modelEntrySalesPersonRoute").modal("hide");
            GetSalesPersonRouteList(Route_Id);
        },
    });
}
function changeEntrySalesArea() {
    var SalesArea_Id = $("#ddlEntrySalesArea").val();
    GetMaster("ddlEntryDealerName", "Select Dealer", "GetDealerBySalesGroup", _pendingDealerId, SalesArea_Id);
    _pendingDealerId = "";
}
function GetRetailerList() {
    // 1. Clear existing table properly
    ClearDataTable("tableRetailerList");

    var SalesArea_Id = $("#ddlEntrySalesArea").val();
    var Dealer_Id = $("#ddlEntryDealerName").val();
    var Method_Name = "Get_Retailer";
    var APIEndPoint = "GetSalesUserRoute";
    var url = "/Transactions/SalesUserRoute";
    var reqdata = {
        method_name: Method_Name,
        salesarea_id: SalesArea_Id,
        dealer_id: Dealer_Id,
        rid,
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

            if (!res || res.length == 0) {
                Hide_Loader();
                // Clear body so user doesn't see old data if no results found
                $("#tableEntryRetailerList").html("");
                Show_Error_Toastr("Retailers not found.");
                return;
            }

            // 2. COLUMN SYNC: Header must have same count as Body
            // We have 3 columns: Checkbox, Hidden ID, and Name.
            var HeaderHTML = "<tr>";
            HeaderHTML += '<th class="text-center" style="width: 20px;">';
            HeaderHTML += '    <label class="custom-control custom-checkbox">';
            HeaderHTML += '        <input type="checkbox" id="selectAllRetailers" class="custom-control-input" />';
            HeaderHTML += '        <label for="selectAllRetailers" class="custom-control-label"></label>';
            HeaderHTML += '    </label>';
            HeaderHTML += '</th>';
            HeaderHTML += '<th hidden></th>'; // CRITICAL: Hidden header to match hidden ID column
            HeaderHTML += '<th>Retailer Name</th>';
            HeaderHTML += "</tr>";

            $("#tableRetailerList thead").html(HeaderHTML);

            var TableHTML = "";
            $.each(res, function (data, value) {
                var isChecked = value.is_locked == 1 ? "checked" : "";

                TableHTML += "<tr>";
                // Column 1: Checkbox
                TableHTML += '<td class="text-center">';
                TableHTML += '    <label class="custom-control custom-checkbox">';
                TableHTML += '        <input type="checkbox" id="retailer' + (data + 1) + '" class="custom-control-input chkRetailer" ' + isChecked + ' />';
                TableHTML += '        <label for="retailer' + (data + 1) + '" class="custom-control-label text-dark"></label>';
                TableHTML += '    </label>';
                TableHTML += '</td>';

                // Column 2: Hidden ID
                TableHTML += "<td hidden class='retailer-id'>" + value.retailer_id + "</td>";

                // Column 3: Name
                TableHTML += "<td>" + value.retailer_name + "</td>";
                TableHTML += "</tr>";
            });

            $("#tableEntryRetailerList").html(TableHTML);

            // 3. Re-initialize Select All Logic
            $("#selectAllRetailers").on("change", function () {
                $(".chkRetailer").prop("checked", $(this).is(":checked"));
            });

            // 4. Call Filter/Initializer
            // Ensure column definitions [1] in SetDataTable_Filter matches your visible columns
            SetDataTable_Filter(
                "tableRetailerList",
                [2], // Usually this is the index of searchable columns
                "Sales User Route Retailer List"
            );

            Hide_Loader();
        },
        error: function (xhr, status, error) {
            Hide_Loader();
            Show_Error_Toastr("Error in fetching details.", error);
        },
    });
}