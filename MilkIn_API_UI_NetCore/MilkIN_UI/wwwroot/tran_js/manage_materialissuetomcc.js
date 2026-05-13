$(document).ready(function () {

    $("#ddlSearchMCCName").select2();

    GetMaster("ddlSearchMCCName", "Select MCC Name", "GetMCC", "", "");
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
    var APIEndPoint = "GetMaterialIssueToMCC";
    var Method_Name = "GetMaterial";
    var url = "/Manage/MaterialIssueToMCC";
    var Search_MCC_Id = "%" + $("#ddlSearchMCCName").val() + "%";
    var Search_Date = $("#txtSearchDeliveryPeriod").val();



    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        search_id: Search_MCC_Id,
        issuestocks_date: Search_Date
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            var EditFlag = 1;
            var TableHTML = "";

            $.each(res, function (data, value) {
                EditFlag = value.is_driveraccepted;
                var Active_Status;
                if (value.is_active == 0) {
                    Active_Status = "In-active";
                } else {
                    Active_Status = "Active";
                }
                TableHTML += "<tr>";
                TableHTML += "<td style = 'width: 20px'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.issuedate + "</td>";
                TableHTML += "<td>" + value.issuestocks_id + "</td>";
                TableHTML += "<td>" + value.mcc_name + "</td>";
                TableHTML += "<td>" + Active_Status + "</td>";
                TableHTML += "<td class='text-right'>";
                // EditFlag = value.is_locked;
                if (EditFlag == 0) {
                    TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick=\'ShowEditEntry("Edit", "' + value.issuestocks_id + '","' + value.created_on + '","' + value.mcc_id + '","' + value.vehicle_id + '","' + value.vehicle_number + '","' + value.driver_id + '","' + value.driver_name + '", "' + value.drivermobile_no + '", "' + value.is_driveraccepted + '")\'>';
                    TableHTML += '<i class="fa fa-pencil"></i>';
                    TableHTML += "</a>";
                }
                else {
                    TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick=\'ShowEditEntry("View", "' + value.issuestocks_id + '","' + value.created_on + '","' + value.mcc_id + '","' + value.vehicle_id + '","' + value.vehicle_number + '","' + value.driver_id + '","' + value.driver_name + '", "' + value.drivermobile_no + '", "' + value.is_driveraccepted + '")\'>';
                    TableHTML += '<i class="fa fa-eye"></i>';
                    TableHTML += "</a>";
                }

                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [5], "Material Issue to MCC");
        },
        error: function () {
            Show_Error_Toastr("Error in fetching Material Issue To MCC details.");
        },
    });

}


function ShowAddEntry() {
    ShowContentDiv("Manage", "MaterialIssueToMCCAdd", "", function () {


        $("#lblEntryId").html("");
        $("#lblAction").html("Add");
        $("#txtEntryDeliveryDate").val(new Date().toDateInputValue());

        // Initialization Code
        $("#ddlEntryMCCName").select2();
        $("#ddlEntryVehicleNo").select2();
        $("#ddlEntryDriverId").select2();

        GetMaster("ddlEntryMCCName", "Select MCC Name", "GetMCC", "", "");
        GetMaster("ddlEntryVehicleNo", "Select Vehicle No", "GetVehicle", "", "");
        GetMaster("ddlEntryDriverId", "Select Driver", "GetDriver", "", "");

        // Add OTHER option to the dropdown lists
        $('#ddlEntryVehicleNo').append($('<option></option>').val('other').html('Other'));
        $('#ddlEntryDriverId').append($('<option></option>').val('other').html('Other'));

        // show text boxes if OTHER is selected
        $("#ddlEntryVehicleNo").on("change", function () {
            if ($("#ddlEntryVehicleNo").find(":selected").val() == "other") {
                $("#divEntryVehicleNo").show();
            } else {
                $("#divEntryVehicleNo").hide();
                $("#txtEntryVehicleNo").val($("#ddlEntryVehicleNo").find(":selected").html());
            }
        });

        // show text boxes if OTHER is selected
        $("#ddlEntryDriverId").on("change", function () {
            if ($("#ddlEntryDriverId").find(":selected").val() == "other") {
                $("#divEntryDriverName").show();
            } else {
                $("#divEntryDriverName").hide();
                $("#txtEntryDriverName").val($("#ddlEntryDriverId").find(":selected").html());

            }
        });

    });
}

function ShowEditEntry(Action, IssueStocks_Id, IssueDate, MCC_Id, Vehicle_Id, Vehicle_No, Driver_Id, Driver_Name, MobileNo, Is_DriverAccepted) {
    ShowContentDiv("Manage", "MaterialIssueToMCCEdit", "", function () {
        // Initialization Code

        $("#txtEntryDeliveryDate").prop("disabled", true);
        $("#txtEntryVehicleNo").prop("disabled", true);
        $("#txtEntryDriverName").prop("disabled", true);
        $("#txtEntryMobileNo").prop("disabled", true);
        $("#ddlEntryMCCName").prop("disabled", true);
        $("#ddlEntryVehicleNo").prop("disabled", true);
        $("#ddlEntryDriverId").prop("disabled", true);
        $("#txtEntryDeliveryNo").prop("disabled", true);

        $("#txtEntryDeliveryNo").val(IssueStocks_Id);

        $("#lblEntryId").html(IssueStocks_Id);
        $("#lblAction").html(Action);

        $("#divMaterialList").show();
        $("#txtEntryDeliveryDate").val(IssueDate);
        $("#txtEntryVehicleNo").val(Vehicle_No);
        $("#txtEntryDriverName").val(Driver_Name);
        $("#txtEntryMobileNo").val(MobileNo);

        $("#ddlEntryMCCName").select2();
        $("#ddlEntryVehicleNo").select2();
        $("#ddlEntryDriverId").select2();

        GetMaster("ddlEntryMCCName", "Select MCC Name", "GetMCC", MCC_Id, "");
        if (Vehicle_Id == "other") {
            $("#divEntryVehicleNo").show();
            $("#ddlEntryVehicleNo").val("other").html("Other");
        }
        else {
            GetMaster("ddlEntryVehicleNo", "Select Vehicle No", "GetVehicle", Vehicle_Id, "");
        }
        if (Driver_Id == "other") {
            $("#divEntryDriverName").show();
            $("#ddlEntryDriverId").val("other").html("Other");
        }
        else {
            GetMaster("ddlEntryDriverId", "Select Driver", "GetDriver", Driver_Id, "");
        }

        // Add OTHER option to the dropdown lists
        $('#ddlEntryVehicleNo').append($('<option></option>').val('other').html('Other'));
        $('#ddlEntryDriverId').append($('<option></option>').val('other').html('Other'));

        // show text boxes if OTHER is selected
        $("#ddlEntryVehicleNo").on("change", function () {
            if ($("#ddlEntryVehicleNo").find(":selected").val() == "other") {
                $("#divEntryVehicleNo").show();
            } else {
                $("#divEntryVehicleNo").hide();
                $("#txtEntryVehicleNo").val($("#ddlEntryVehicleNo").find(":selected").html());
            }
        });

        // show text boxes if OTHER is selected
        $("#ddlEntryDriverId").on("change", function () {
            if ($("#ddlEntryDriverId").find(":selected").val() == "other") {
                $("#divEntryDriverName").show();
            } else {
                $("#divEntryDriverName").hide();
                $("#txtEntryDriverName").val($("#ddlEntryDriverId").find(":selected").html());

            }
        });

        var APIEndPoint = "GetMaterialIssueToMCC";
        var Method_Name = "Get_One";
        var disabled = "";
        $("#btn_Save").prop("hidden", false);
        if (Action == "View") {
            disabled = "disabled";
            $("#btn_Save").prop("hidden", true);
        }
        var url = "/Manage/MaterialIssueToMCC";
        var reqdata = {
            method_name: Method_Name,
            issuestocks_id: IssueStocks_Id,
            api_end_point: APIEndPoint,
            mcc_id: MCC_Id
        };
        $.ajax({
            type: "POST",
            url: url,
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result);
                ClearDataTable("tableMaterialList");
                var TableHTML = "";
                checked = "";
                RowNo = 0;
                $.each(res, function (data, value) {
                    if (value.is_delivered == 1) {
                        checked = "checked";
                    }
                    else {
                        checked = "";
                    }

                    TableHTML += "<tr>";

                    if (Is_DriverAccepted == 1) {
                        if (value.is_delivered == 1) {
                            RowNo += 1;
                            TableHTML += '<td>' + RowNo + '</td>';
                            TableHTML += "<td hidden>" + value.order_for_user_id + "</td>";
                            TableHTML += '<td>' + value.order_for + '</td>';
                            TableHTML += '<td>' + value.farmer_agent_name + '</td>';
                            TableHTML += "<td>" + value.order_type + "</td>";
                            TableHTML += "<td hidden>" + value.order_id + "</td>";
                            TableHTML += "<td hidden>" + value.material_id + "</td>";
                            TableHTML += "<td>" + value.material_name + "</td>";
                            TableHTML += "<td>" + value.quantity + "</td>";
                        }
                    }
                    else {
                        TableHTML += '<td class="text-center">';
                        TableHTML += '<label class="custom-control custom-checkbox">';
                        TableHTML += '<input type="checkbox" class="custom-control-input" id="' +
                            "material" + (data + 1) + '" ' + checked + " />";
                        TableHTML += '<label for="material' + (data + 1) + '" class="custom-control-label text-dark"></label>';
                        TableHTML += "</label>";
                        TableHTML += "</td>";

                        TableHTML += "<td hidden>" + value.order_for_user_id + "</td>";
                        TableHTML += '<td>' + value.order_for + '</td>';
                        TableHTML += '<td>' + value.farmer_agent_name + '</td>';
                        TableHTML += "<td>" + value.order_type + "</td>";
                        TableHTML += "<td hidden>" + value.order_id + "</td>";
                        TableHTML += "<td hidden>" + value.material_id + "</td>";
                        TableHTML += "<td>" + value.material_name + "</td>";
                        TableHTML += "<td>" + value.quantity + "</td>";
                    }
                    TableHTML += "</tr>";

                    
                });
                ClearDataTable("tableMaterialList");
                $("#tableEntryMaterialList").append(TableHTML);
                SetDataTable("tableMaterialList", [8], "Issue Empty Cans");
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

function SaveEntry() {
    // Validation code
    var MCC_Id = $('#ddlEntryMCCName').val();
    var Vehicle_Id = $('#ddlEntryVehicleNo').val();
    var VehicleNo = $("#txtEntryVehicleNo").val();
    var Driver_Id = $("#ddlEntryDriverId").val();
    var DriverName = $("#txtEntryDriverName").val();
    var DeliveryDate = $("#txtEntryDeliveryDate").val();
    var Mobile_No = $("#txtEntryMobileNo").val();

    var IsValid = 1;

    if (MCC_Id == "") {
        IsValid = 0;
        $("#ddlEntryMCCName").addClass("is-invalid state-invalid");
    }

    if (Vehicle_Id == "") {
        IsValid = 0;
        $("#ddlEntryVehicleNo").addClass("is-invalid state-invalid");
    }
    if (Vehicle_Id == "other" && VehicleNo == "") {
        IsValid = 0;
        $("#txtEntryVehicleNo").addClass("is-invalid state-invalid");
    }
    if (Driver_Id == "") {
        IsValid = 0;
        $("#ddlEntryDriverId").addClass("is-invalid state-invalid");
    }
    if (Driver_Id == "other" && DriverName == "") {
        IsValid = 0;
        $("#txtEntryDriverName").addClass("is-invalid state-invalid");
    }
    if (DeliveryDate == "") {
        IsValid = 0;
        $("#txtEntryDeliveryDate").addClass("is-invalid state-invalid");
    }

    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }
    else {
        // Start Saving
        $("#btn_Save").prop("disabled", true);
        var APIEndPoint = "SaveMaterialIssueToMCC";
        var Method_Name = "Create";
        var IssueStocks_Id = "";
        var Action_Name = $("#lblAction").html();
        var xmlData = "";
        if (Action_Name == "Edit") {
            Method_Name = "Update";
            IssueStocks_Id = $("#lblEntryId").html();

            // Getting Table values and converting it to XML

            xmlData += "<D>";

            $("#tableMaterialList tbody tr").each(function () {
                checked = 0;
                if ($(this).find("td:eq(0) input").prop("checked") == true) {
                    checked = 1;
                }
                xmlData += "<R><ProfileId>" + $(this).find("td:eq(1)").text() + "</ProfileId>";
                xmlData += "<MaterialId>" + $(this).find("td:eq(6)").text() + "</MaterialId>";
                xmlData += "<OrderId>" + $(this).find("td:eq(5)").text() + "</OrderId>";
                xmlData += "<MCC>" + MCC_Id + "</MCC>";
                xmlData += "<IsDelivered>" + checked + "</IsDelivered>";
                xmlData += "<ProfileType>" + $(this).find("td:eq(2)").text() +"</ProfileType>";
                xmlData += "<MaterialQty>" + $(this).find("td:eq(8)").text() + "</MaterialQty>";
                xmlData += "<DeliveryId>" + IssueStocks_Id + "</DeliveryId></R>";

                /*
                     if ($(this).find("td:eq(0) input").prop("checked") == true) {
                    checked = 1;
                    xmlData += "<R><ProfileId>" + $(this).find("td:eq(1)").text() + "</ProfileId>";
                    xmlData += "<MaterialId>" + $(this).find("td:eq(4)").text() + "</MaterialId>";
                    xmlData += "<OrderId>" + $(this).find("td:eq(3)").text() + "</OrderId>";
                    xmlData += "<MCC>" + MCC_Id + "</MCC>";
                    xmlData += "<IsDelivered>" + MCC_Id + "</IsDelivered>";
                    xmlData += "<ProfileType>MCC</ProfileType>";
                    xmlData += "<MaterialQty>" + $(this).find("td:eq(6)").text() + "</MaterialQty></R>";
                }
                
                */
            });
            xmlData += "</D>";
        }
        var Is_Active = 1;
        var Is_Deleted = 0;
        var url = "/Manage/MaterialIssueToMCC";
        var reqdata = {
            is_active: Is_Active,
            is_deleted: Is_Deleted,
            method_name: Method_Name,
            api_end_point: APIEndPoint,
            issuestocks_id: IssueStocks_Id,
            mcc_id: MCC_Id,
            vehicle_id: Vehicle_Id,
            vehicle_no: VehicleNo,
            driver_id: Driver_Id,
            driver_name: DriverName,
            issuestocks_date: DeliveryDate,
            drivermobile_no: Mobile_No,
            xmldata: xmlData,
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
                    $("#lblEntryId").html(result[0].result_extra_key);
                    $("#lblAction").html("Edit");
                    ShowEntrySuccess("Material Issue to MCC saved successfully");
                    ShowEditEntry("Edit",
                        result[0].result_extra_key,
                        DeliveryDate,
                        MCC_Id,
                        Vehicle_Id,
                        VehicleNo,
                        Driver_Id,
                        DriverName,
                        Mobile_No
                    );
                } else {
                    ShowEntryError("Error : " + result[0].result_description);
                }
            },
            error: function () {
                Show_Error_Toastr("Error : Material Issue To MCC details not saved");
            },
        });
        $("#btn_Save").prop("disabled", false);
    }
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
    //var Agent_Id = $("#lblEntryId").html();
    //var Is_Deleted = 1;

    //var APIEndPoint = "SaveAgent";
    //var url = "/Users/Agent";
    //var reqdata = {
    //    "agent_id": Agent_Id,
    //    "is_deleted": Is_Deleted,
    //    "method_name": "Delete",
    //    "api_end_point": APIEndPoint,
    //};
    //$.ajax({
    //    type: 'POST',
    //    url: url,
    //    contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
    //    data: reqdata,
    //    success: function (res) {
    //        var result = JSON.parse(res);
    //        if (result[0].result_id == 1) {
    //            // Show Success Message
    //            ShowEntrySuccess("Agent details deleted successfully");

    //            GetSearchList();
    //            CloseEntry();

    //        } else {

    //            Show_Error_Toastr("Error : " + result[0].result_description);
    //        }
    //    },
    //    error: function () {
    //        Show_Error_Toastr("Error : Agent details not deleted");
    //    }
    //});
}


function OpenModal(action) {
    $('#modelEntryMaterial').modal('show')
    $('#ddlEntryMaterialName').select2();
    $("#lblActionMaterial").html(action);
    if (action == 'Add') {
        $("#AddEditMaterial").text("Add Entry");
    }
    else if (action == 'Edit') {
        $("#AddEditMaterial").text("Edit Entry");
    }
}

$("#modelEntryMaterial").on("hidden.bs.modal", function (e) {

    $("#lblActionMaterial").html('');
    $("#AddEditMaterial").text('');
});


Date.prototype.toDateInputValue = function () {
    var local = new Date(this);
    local.setMinutes(this.getMinutes() - this.getTimezoneOffset());
    return local.toJSON().slice(0, 10);
};
