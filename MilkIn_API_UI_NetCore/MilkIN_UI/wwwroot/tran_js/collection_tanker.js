$(document).ready(function () {
   
    $("#ddlSearchVehicleNo").select2();
    //GetSearchList();
});


/*  ----    ----    ----    Get Tanker data and assign it to the table on Search Page    ----    ----    ----    ----    */
function GetSearchList(e) {
    ClearDataTable("tableSearch");
    // Get Tanker data from database and show in the table on Search page
    var APIEndPoint = "GetTanker";
    var Method_Name = 'Get';
    var url = "/Collection/Tanker";
    var reqdata = {
        "method_name": Method_Name,
        "api_end_point": APIEndPoint,
        "vehicletype": "tanker"
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);

            // show message if there is no data to show
            if (res.length == 0) {
                Show_Error_Toastr("Data not found.");
                return;
            }

            // Fill data in table
            var TableHTML = "";
            var EditFlag = 1; // IsEditAllowed($("#lblAS").html());

            $.each(res, function (data, value) {
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.vehicle_no + "</td>";
                TableHTML += "<td>" + value.route_name + "</td>";
                TableHTML += "<td>" + value.collectionshift_name + "</td>";
                TableHTML += "<td>" + value.end_time + "</td>";
                TableHTML += "<td>" + value.weight + "</td>";
                TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                EditFlag = value.is_locked;
                if (EditFlag == 0) {
                    var action = "Edit";
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowEntry('" + action + "','" + value.vehicle_id + "', '" + value.milkcollectiondairy_id + "','" + value.tripdocument_id + "');\">";
                    TableHTML += "<i class=\"fa fa-pencil\"></i>";
                    TableHTML += "</a>";
                }
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [6], "Tanker");
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
        }
    });
}




/*  ----    ----    ----    Open Modal to select Vehicle No    ----    ----    ----    ----    */
function OpenModal() {
    $("#modelEntryVehicle").modal({
        backdrop: 'static',
    }).modal("show");

    // Set vehicle drop down
    // val = vehicle id
    // name = trip document id
    // html = vehicle no
    $("#ddlSearchVehicleNo").empty().append($("<option></option>").val("").html("Select Tanker No").attr("name", ""));
    var APIEndPoint = "GetTanker"
    var url = "/Collection/Tanker";
    var reqdata = {
        "method_name": "Get_Vehicle",
        "api_end_point": APIEndPoint,
        "vehicletype": "tanker"
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (res) {
            var result = JSON.parse(res);

            $.each(result, function (data, value) {
                $("#ddlSearchVehicleNo").append($("<option></option>").val(value.vehicle_id + "," + value.tripdocument_id).html(value.vehicle_no));
            });
            $("#ddlSearchVehicleNo").val("");
        },
        error: function () {
            Show_Error_Toastr("Error in fetching data");
        }
    });
}




/*  ----    ----    ----    Operation to perform when modal hides    ----    ----    ----    ----    */
$("#modelEntryVehicle").on("hidden.bs.modal", function (e) {
    ResetInputFields();
});




/*  ----    ----    ----    Open Entry page and assign values based on Add/Edit action    ----    ----    ----    ----    */
function ShowEntry(Action, VehicleId, MilkCollectionDairyId, TripDocumentId) {
    if (Action == "Add" && $("#ddlSearchVehicleNo").val() == "") {
        return;
    }
    ShowContentDiv("Collection", "TankerAdd", "", function () {

        $("#lblEntryId").html(MilkCollectionDairyId);
        $("#lblAction").html(Action);


        // Edit
        if (Action == "Edit") {
            // global variables - can be used throuout the program.
            Vehicle_Id = VehicleId;
            MilkCollectionDairy_Id = MilkCollectionDairyId;
            TripDocument_Id = TripDocumentId;

            // hide Save button on MCC Entry page
            $("#btn_Save").hide();

        }
        // Add
        else {
            var temp = $("#ddlSearchVehicleNo").val().split(",");
            // Global Variables - can be used anywhere in the program
            Vehicle_Id = temp[0];
            TripDocument_Id = temp[1];
            MilkCollectionDairy_Id = "";
            $("#modelEntryVehicle").modal("hide");

            // Show Save Button on MCC Entry page
            $("#btn_Save").show();


        }


        var APIEndPoint = "GetTanker";
        var Method_Name = 'Get_One';
        var url = "/Collection/Tanker";
        var reqdata = {
            "method_name": Method_Name,
            "vehicle_id": Vehicle_Id,
            "api_end_point": APIEndPoint,
        };
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);

                // Setting Input Field Values
                $("#txtEntryTankerNo").val(res[0].vehicle_no);
                $("#txtEntryRouteName").val(res[0].route_name);
                $("#txtEntryShift").val(res[0].collectionshift_name);
                $("#txtEntryTime").val(res[0].end_time);
                GetMCCList(Vehicle_Id, TripDocument_Id);
            },
            error: function () {
                Show_Error_Toastr("Error in fetching details from server.");
            }
        });
    });
}





/*  ----    ----    ----    Hide the Entry Page    ----    ----    ----    ----    */
function CloseEntry() {
    HideContentDiv();
}




/*  ----    ----    ----    Hide the MCC Entry Page and Show Entry Page    ----    ----    ----    ----    */
function CloseMCCEntry() {
    $("#divSearch").hide();
    $("#divMCCEntry").hide();
    $("#divContent").show();
}




/*  ----    ----    ----    Save Milk Collection - Tanker record. Is called from MCC Entry Page    ----    ----    ----    ----    */
function SaveEntry() {
    $("#btn_Save").prop('disabled', true);
    var APIEndPoint = "SaveTanker";
    var Method_Name = 'Create';
    var Action_Name = $("#lblAction").html();
    MilkCollectionDairy_Id = "";
    if (Action_Name == 'Edit') {
        Method_Name = 'Update';
        MilkCollectionDairy_Id = $("#lblEntryId").html();
    }

    var url = "/Collection/Tanker";
    var reqdata = {
        "method_name": Method_Name,
        "api_end_point": APIEndPoint,
        "milkcollectiondairy_id": MilkCollectionDairy_Id,
        "tripdocument_id": TripDocument_Id,
        "mcccollectionshift_id": MCCCollectionShift_Id,
        "mcc_id": MCC_Id,
        "vehicle_id": Vehicle_Id,
        "milktype_id": MilkType_Id,
        "milkstatus_id": MilkStatus_Id
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
                $("#lblEntryId").html(result[0].result_extra_key);
                $("#lblAction").html("Edit");
                $("#btn_Save").hide();
                ShowEntrySuccess("MCC Collection - Tanker details saved successfully");
                GetMilkQuantityList();
                $("#divQuantityList").show();
                GetMilkQualityList();
                $("#divQualityList").show();
            } else {
                ShowEntryError("Error : " + result[0].result_description);
            }

        },
        error: function () {
            Show_Error_Toastr("Error : Tanker details not saved");
        }
    });
    $("#btn_Save").prop('disabled', false);
}




/*  ----    ----    ----    Openig MCC Entry Page and Assigning Input fields values & Assiging Quantity & Quality Tables    ----    ----    ----    ----    */
function ShowMCCEntry(Action, mcc_id, mcc_name, milkcollectiondairy_id, mcccollectionshift_id, created_on) {
    // global variables
    MCC_Id = mcc_id;
    MCCCollectionShift_Id = mcccollectionshift_id;
    MCC_Name = mcc_name;
    MilkCollectionDairy_Id = milkcollectiondairy_id;
    CreatedOn = created_on;

    // Hide Add button for  VIEW
    if (Action == "View") {
        $("#btnAddQuantity").hide();
        $("#btnAddQuality").hide();
    }
    // Show Add Button for EDIT
    else {
        $("#btnAddQuantity").show();
        $("#btnAddQuality").show();
    }

    // Setting and displaying MCC Entry Page
    $.ajax({
        url: "/Collection/TankerMCCEntry",
        success: function (result) {
            if (result.trim() != "") {
                // Hiding Tanker Entry and Displaying Tanker MCC Entry
                $("#divContent").hide();
                $("#divMCCEntry").html(result);
                //$("#divMCCList").hide();
                $("#divMCCEntry").show();

                // Setting up Modal Dropdowns
                $("#ddlEntryQualityMilkStatus").select2();
                $("#ddlEntryQuantityMilkStatus").select2();
                $("#ddlEntryQuantityMilkType").select2();
                GetMaster("ddlEntryQualityMilkStatus", "Select Milk Status", "GetMilkStatus", "", "");
                GetMaster("ddlEntryQuantityMilkStatus", "Select Milk Status", "GetMilkStatus", "", "");
                GetMaster("ddlEntryQuantityMilkType", "Select Milk Type", "GetMilkType", "", "")

                // Setting Input Field values of main section
                $("#txtMCCEntryTankerNo").val($("#txtEntryTankerNo").val());
                $("#txtMCCEntryRouteName").val($("#txtEntryRouteName").val());
                $("#txtMCCEntryShift").val($("#txtEntryShift").val());
                $("#txtMCCEntryTime").val($("#txtEntryTime").val());

                $("#txtMCCEntryBMCName").val(MCC_Name);
                $("#txtMCCEntryCollectionDate").val(CreatedOn);

                // Show hide Quantity & Quality section based on action
                if ($("#lblAction").html() == "Add") {
                    $("#divQuantityList").hide();
                    $("#divQualityList").hide();
                }
                else {
                    GetMilkQuantityList();
                    GetMilkQualityList();
                    $("#divQuantityList").show();
                    $("#divQualityList").show();
                }


                // Assign input field values for section - Details Entered by MCC Agent
                var APIEndPoint = "GetTanker";
                var Method_Name = 'Get_AgentEntry';
                var url = "/Collection/Tanker";
                var reqdata = {
                    "method_name": Method_Name,
                    "api_end_point": APIEndPoint,
                    "vehicle_id": Vehicle_Id,
                    "mcc_id": MCC_Id,
                    "mcccollectionshift_id": MCCCollectionShift_Id
                };
                $.ajax({
                    type: 'POST',
                    url: url,
                    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
                    data: reqdata,
                    success: function (result) {
                        var res = JSON.parse(result);
                        
                        $("#txtEntryMCCAgentMilkType").val(res[0].milktype_name);
                        $("#txtEntryMCCAgentMilkStatus").val(res[0].milkstatus_name);
                        $("#txtEntryMCCAgentWeight").val(res[0].weight);
                        $("#txtEntryMCCAgentLiters").val(res[0].quantity_ltr);
                        $("#txtEntryMCCAgentSNF").val(res[0].snf);
                        $("#txtEntryMCCAgentFat").val(res[0].fat);

                        MilkType_Id = res[0].milktype_id;
                        MilkStatus_Id = res[0].milkstatus_id;
                    },
                    error: function (result) {
                        Show_Error_Toastr("Error in fetching details from server.");
                    }
                });


                // Assign input field values for section - Details Entered by Route Chemist
                var APIEndPoint = "GetTanker";
                var Method_Name = 'Get_ChemistEntry';
                var url = "/Collection/Tanker";
                var reqdata = {
                    "method_name": Method_Name,
                    "api_end_point": APIEndPoint,
                    "vehicle_id": Vehicle_Id,
                    "mcc_id": MCC_Id,
                    "mcccollectionshift_id": MCCCollectionShift_Id,
                };
                $.ajax({
                    type: 'POST',
                    url: url,
                    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
                    data: reqdata,
                    success: function (result) {
                        var res = JSON.parse(result);

                        $("#txtEntryRouteChemistMilkStatus").val(res[0].milkstatus_name);
                        $("#txtEntryRouteChemistSNF").val(res[0].snf);
                        $("#txtEntryRouteChemistFat").val(res[0].fat);
                        $("#txtEntryRouteChemistCompartment").val(res[0].quantity_ltr);

                        Chemist_Id = res[0].chemist_id;
                    },
                    error: function (result) {
                        Show_Error_Toastr("Error in fetching details from server.");
                    }
                });
            }
        },
        error: function (result) {
            if (result.status == "401") {
                Show_Error_Toastr("You are not authorized to perform this transaction");
            }
        },
    });
}





/*  ----    ----    ----    Open Modal for Quantity of Milk at Dairy    ----    ----    ----    ----    */
function OpenQuantityModal(action) {
    ResetInputFields();
    $("#modelEntryQuantityTanker").modal({
        backdrop: 'static',
    }).modal("show");
    $("#lblActionQuantity").html(action);
    if (action == "Add") {
        $("#AddEditQuantityTanker").text("Add Quantity Details");
    } else if (action == "Edit") {
        $("#AddEditQuantityTanker").text("Edit Quantity Details");
    }
}




/*  ----    ----    ----    Resetting Modal Input Fields on Modal Close/Hide    ----    ----    ----    ----    */
$("#modelEntryQuantityTanker").on("hidden.bs.modal", function (e) {
    $("#lblActionQuantity").html("");
    $("#AddEditQuantityTanker").text("");
    ResetInputFields();
});




/*  ----    ----    ----    Open modal to enter Quality of Milk at Dairy    ----    ----    ----    ----    */
function OpenQualityModal(action) {
    ResetInputFields();
    $("#modelEntryQualityTanker").modal({
        backdrop: 'static',
    }).modal("show");
    $("#lblActionQuality").html(action);
    if (action == "Add") {
        $("#AddEditQualityTanker").text("Add Quality Details");
    } else if (action == "Edit") {
        $("#AddEditQualityTanker").text("Edit Quality Details");
    }
}




/*  ----    ----    ----    Resetting Modal Input Fields on Modal Close/Hide    ----    ----    ----    ----    */
$("#modelEntryQualityTanker").on("hidden.bs.modal", function (e) {
    $("#lblActionQuality").html("");
    $("#AddEditQualityTanker").text("");
    ResetInputFields();
});






/*  ----    ----    ----    Save Milk Quantity at Dairy    ----    ----    ----    ----    */
function SaveMilkQuantity() {
    var QuantityMilkType_Id = $("#ddlEntryQuantityMilkType").val();
    var QuantityMilkStatus_Id = $("#ddlEntryQuantityMilkStatus").val();
    var QuantityWeight = $("#txtEntryQuantityWeight").val();

    var IsValid = 1;

    if (QuantityMilkType_Id == "") {
        IsValid = 0;
        $("#ddlEntryQuantityMilkType").addClass("is-invalid state-invalid");

    }
    if (QuantityMilkStatus_Id == "") {
        IsValid = 0;
        $("#ddlEntryQuantityMilkStatus").addClass("is-invalid state-invalid");

    }
    if (QuantityWeight == "") {
        IsValid = 0;
        $("#txtEntryQuantityWeight").addClass("is-invalid state-invalid");

    }
    if (IsValid == 0) {
        Show_Error_Toastr("Invalid Input(s). Can't be saved.");
        return;
    }
    else {
        // Start Saving
        $("#btnQuantitySave").prop('disabled', true);
        var APIEndPoint = "SaveTankerQuantity";
        var Method_Name = 'Create';
        MilkCollectionDairy_Id = $("#lblEntryId").html();
        var Entry_Id = "";
        var Action_Name = $("#lblActionQuantity").html();
        if (Action_Name == 'Edit') {
            Method_Name = 'Update';
            Entry_Id = $("#lblQuantityId").html();
        }
        var Is_Active = 1;
        var Is_Deleted = 0;
        var url = "/Collection/TankerQuantity";
        var reqdata = {
            "is_active": Is_Active,
            "is_deleted": Is_Deleted,
            "method_name": Method_Name,
            "api_end_point": APIEndPoint,

            "milkcollectiondairy_id": MilkCollectionDairy_Id,
            "entry_id": Entry_Id,
            "milkstatus_id": QuantityMilkStatus_Id,
            "milktype_id": QuantityMilkType_Id,
            "weight": QuantityWeight,
            "tripdocument_id": TripDocument_Id,
            "mcc_id": MCC_Id,
            "mcccollectionshift_id": MCCCollectionShift_Id
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
                    $("#lblQuantityId").html(result[0].result_extra_key);
                    $("#lblActionQuantity").html("Edit");
                    $("#modelEntryQuantityTanker").modal("hide");
                    GetMilkQuantityList();
                    ShowItemSuccess("Quantity details saved successfully");
                } else {
                    $("#modelEntryQuantityTanker").modal("hide");
                    ShowItemError("Error : " + result[0].result_description);
                }
            },
            error: function (res) {
                $("#modelEntryQuantityTanker").modal("hide");
                ShowItemError("Error : Quantity details not saved");
            }
        });
        $("#btnQuantitySave").prop('disabled', false);
    }
    return;
}




/*  ----    ----    ----    Save Milk Quality at Dairy    ----    ----    ----    ----    */
function SaveMilkQuality() {
    var QualitySampleNo = $("#txtEntryQualitySampleNo").val();
    var QualityMilkStatus_Id = $("#ddlEntryQualityMilkStatus").val();
    var QualitySNF = $("#txtEntryQualitySNF").val();
    var QualityFat = $("#txtEntryQualityFat").val();

    var IsValid = 1;
    if (QualityMilkStatus_Id == "") {
        IsValid = 0;
        $("#ddlEntryQualityMilkStatus").addClass("is-invalid state-invalid");

    }
    if (QualitySampleNo == "") {
        IsValid = 0;
        $("#txtEntryQualitySampleNo").addClass("is-invalid state-invalid");

    }
    if (QualitySNF == "") {
        IsValid = 0;
        $("#txtEntryQualitySNF").addClass("is-invalid state-invalid");

    }
    if (QualityFat == "") {
        IsValid = 0;
        $("#txtEntryQualityFat").addClass("is-invalid state-invalid");
    }
    if (IsValid == 0) {
        Show_Error_Toastr("Invalid Input(s). Can't be saved.");
        return;
    }
    else {
        // Start Saving
        $("#btnQualitySave").prop('disabled', true);
        var APIEndPoint = "SaveTankerQuality";
        var Method_Name = 'Create';
        var MilkCollectionDairy_Id = $("#lblEntryId").html();
        var Entry_Id = "";
        var Action_Name = $("#lblActionQuality").html();
        if (Action_Name == 'Edit') {
            Method_Name = 'Update';
            Entry_Id = $("#lblQualityId").html();
        }
        var Is_Active = 1;
        var Is_Deleted = 0;
        var url = "/Collection/TankerQuality";
        var reqdata = {
            "is_active": Is_Active,
            "is_deleted": Is_Deleted,
            "method_name": Method_Name,
            "api_end_point": APIEndPoint,

            "milkcollectiondairy_id": MilkCollectionDairy_Id,
            "entry_id": Entry_Id,
            "milkstatus_id": QualityMilkStatus_Id,
            "sample_no": QualitySampleNo,
            "snf": QualitySNF,
            "fat": QualityFat,
            "milkcollectiondairy_id": MilkCollectionDairy_Id,
            "tripdocument_id": TripDocument_Id,
            "mcc_id": MCC_Id,
            "mcccollectionshift_id": MCCCollectionShift_Id
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
                    $("#lblQualityId").html(result[0].result_extra_key);
                    $("#lblActionQuality").html("Edit");
                    $("#modelEntryQualityTanker").modal("hide");
                    GetMilkQualityList();
                    ShowItemSuccess("Quality details saved successfully");
                } else {
                    $("#modelEntryQualityTanker").modal("hide");
                    ShowItemError("Error : " + result[0].result_description);
                }
            },
            error: function () {
                $("#modelEntryQualityTanker").modal("hide");
                ShowItemError("Error : Quality details not saved");
            }
        });
        $("#btnQualitySave").prop('disabled', false);
    }
    return;
}




/*  ----    ----    ----    Set and Display Milk Quantity Table    ----    ----    ----    ----    */
function GetMilkQuantityList() {
    var Method_Name = 'Get';
    var APIEndPoint = "GetTankerQuantity";
    var url = "/Collection/TankerQuantity";
    var MilkCollectionDairy_Id = $("#lblEntryId").html();
    var reqdata = {
        "method_name": Method_Name,
        "milkcollectiondairy_id": MilkCollectionDairy_Id,
        "api_end_point": APIEndPoint,
        "mcccollectionshift_id": MCCCollectionShift_Id,
        "mcc_id": MCC_Id,
        "tripdocument_id": TripDocument_Id
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);

            // Fill data in table
            var TableHTML = "";
            var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
            var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());

            $.each(res, function (data, value) {
                //EditFlag = DeleteFlag = value.is_locked;
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.milktype_name + "</td>";
                TableHTML += "<td>" + value.milkstatus_name + "</td>";
                TableHTML += "<td>" + value.weight + "</td>";
                TableHTML += "<td>" + value.liters + "</td>";
                TableHTML += "<td>" + value.start_time + "</td>";
                TableHTML += "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
                if (EditFlag == 1) {
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowQuantityEditEntry('" + value.entry_id + "');\">";
                    TableHTML += "<i class=\"fa fa-pencil\"></i>";
                    TableHTML += "</a>";
                }
                if (DeleteFlag == 1) {
                    TableHTML += "| <a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"SaveQuantityDeleteEntry('" + value.entry_id + "');\">";
                    TableHTML += "<i class=\"fa fa-trash\"></i>";
                    TableHTML += "</a>";
                }
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });
            ClearDataTable("tableMilkQuantityList");
            $("#tableEntryQuantity").html(TableHTML);
            SetDataTable("tableMilkQuantityList", [6], "Milk Quantity at Dairy");
        },
        error: function () {
            ShowItemError("Error in fetching details from server.", res[0].result_description);
        }
    });
    return;
}




/*  ----    ----    ----    Set and Display Milk Quality Table    ----    ----    ----    ----    */
function GetMilkQualityList() {
    var Method_Name = 'Get';
    var APIEndPoint = "GetTankerQuality";
    var url = "/Collection/TankerQuality";
    var MilkCollectionDairy_Id = $("#lblEntryId").html();
    var reqdata = {
        "method_name": Method_Name,
        "milkcollectiondairy_id": MilkCollectionDairy_Id,
        "api_end_point": APIEndPoint,
        "mcccollectionshift_id": MCCCollectionShift_Id,
        "mcc_id": MCC_Id,
        "tripdocument_id": TripDocument_Id
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);

            // Fill data in table
            var TableHTML = "";
            var EditFlag = 1; // IsEditAllowed($("#lblAS").html());
            var DeleteFlag = 1; // IsDelAllowed($("#lblAS").html());

            $.each(res, function (data, value) {
                //EditFlag = DeleteFlag = value.is_locked;
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.sample_no + "</td>";
                TableHTML += "<td>" + value.milkstatus_name + "</td>";
                TableHTML += "<td>" + value.snf + "</td>";
                TableHTML += "<td>" + value.fat + "</td>";
                TableHTML += "<td class='text-right' style='width: 90px; padding:8px 5px 8px 5px;'>";
                if (EditFlag == 1) {
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowQualityEditEntry('" + value.entry_id + "');\">";
                    TableHTML += "<i class=\"fa fa-pencil\"></i>";
                    TableHTML += "</a>";
                }
                if (DeleteFlag == 1) {
                    TableHTML += "| <a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"SaveQualityDeleteEntry('" + value.entry_id + "');\">";
                    TableHTML += "<i class=\"fa fa-trash\"></i>";
                    TableHTML += "</a>";
                }
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });
            ClearDataTable("tableMilkQualityList");
            $("#tableEntryQuality").html(TableHTML);
            SetDataTable("tableMilkQualityList", [5], "Milk Quality at Dairy");
        },
        error: function () {
            ShowItemError("Error in fetching details from server.", res[0].result_description);
        }
    });
    return;
}




/*  ----    ----    ----    Set input fields to Edit Milk Quantity at dairy    ----    ----    ----    ----    */
function ShowQuantityEditEntry(Entry_Id) {
    $("#lblQuantityId").html(Entry_Id);
    var Method_Name = 'Get_One';
    var APIEndPoint = "GetTankerQuantity";
    var url = "/Collection/TankerQuantity";
    var reqdata = {
        "method_name": Method_Name,
        "entry_id": Entry_Id,
        "api_end_point": APIEndPoint,
        "milkcollectiondairy_id": MilkCollectionDairy_Id
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            OpenQuantityModal("Edit");
            $("#lblQuantityId").html(res[0].entry_id);
            GetMaster("ddlEntryQuantityMilkStatus", "Select Milk Status", "GetMilkStatus", res[0].milkstatus_id, "");
            GetMaster("ddlEntryQuantityMilkType", "Select Milk Type", "GetMilkType", res[0].milktype_id, "")
            $("#txtEntryQuantityWeight").val(res[0].weight);
        },
        error: function () {
            ShowItemError("Error in fetching details from server.", res[0].result_description);
        }
    });
}




/*  ----    ----    ----    Delete Record for Milk Quantity at Dairy    ----    ----    ----    ----    */
function SaveQuantityDeleteEntry(Entry_Id) {
    MilkCollectionDairy_Id = $("#lblEntryId").html();
    var APIEndPoint = "SaveTankerQuantity";
    var url = "/Collection/TankerQuantity";
    var reqdata = {
        "method_name": "Delete",
        "entry_id": Entry_Id,
        "milkcollectiondairy_id": MilkCollectionDairy_Id,
        "api_end_point": APIEndPoint
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
                // Show Success Message
                ShowItemSuccess("Quantity details deleted successfully");
                GetMilkQuantityList(MilkCollectionDairy_Id);
            } else {
                ShowItemError("Error : " + result[0].result_description);
            }
        },
        error: function () {
            ShowItemError("Error : Quantity details not deleted");
        }
    });
}




/*  ----    ----    ----    Set input fields to Edit Milk Quantity at dairy    ----    ----    ----    ----    */
function ShowQualityEditEntry(Entry_Id) {
    $("#lblQualityId").html(Entry_Id);
    var Method_Name = 'Get_One';
    var APIEndPoint = "GetTankerQuality";
    var url = "/Collection/TankerQuality";
    var reqdata = {
        "method_name": Method_Name,
        "entry_id": Entry_Id,
        "api_end_point": APIEndPoint,
        "milkcollectiondairy_id": MilkCollectionDairy_Id

    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            OpenQualityModal("Edit");
            $("#lblQualityId").html(res[0].entry_id);
            GetMaster("ddlEntryQualityMilkStatus", "Select Milk Status", "GetMilkStatus", res[0].milkstatus_id, "");
            $("#txtEntryQualitySampleNo").val(res[0].sampleno);
            $("#txtEntryQualitySNF").val(res[0].snf);
            $("#txtEntryQualityFat").val(res[0].fat);
        },
        error: function () {
            ShowItemError("Error in fetching details from server.", res[0].result_description);
        }
    });
}




/*  ----    ----    ----    Delete Record for Milk Quality at Dairy    ----    ----    ----    ----    */
function SaveQualityDeleteEntry(Entry_Id) {
    MilkCollectionDairy_Id = $("#lblEntryId").html();
    var APIEndPoint = "SaveTankerQuality";
    var url = "/Collection/TankerQuality";
    var reqdata = {
        "method_name": "Delete",
        "entry_id": Entry_Id,
        "milkcollectiondairy_id": MilkCollectionDairy_Id,
        "api_end_point": APIEndPoint
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (res) {
            var result = JSON.parse(res);
            if (result[0].result_id == 1) {
                // Show Success Message
                ShowItemSuccess("Quality details deleted successfully");
                GetMilkQualityList();
            } else {
                ShowItemError("Error : " + result[0].result_description);
            }
        },
        error: function () {
            ShowItemError("Error : Quality details not deleted");
        }
    });
}

function ResetInputFields() {
    $("modal input, select").val("");
}