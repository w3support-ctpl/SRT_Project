$(document).ready(function () {
    $('input[name="datefilter"]').daterangepicker({
        locale: {
            cancelLabel: "Clear",
        },
        startDate: moment(), // Set the startDate to 30 days ago
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








/* -----    -----      Search for data in database as per values provided       -----   ----- */
function GetSearchList() {

    ClearDataTable("tableSearch");
    // Get data from database and show in table
    var NotificationPeriod = $("#txtSearchNotificationPeriod").val();

    var Is_Valid = 1;

    if (NotificationPeriod == "") {
        Is_Valid = 0;
        $("#txtSearchNotificationPeriod").addClass("is-invalid state-invalid");
    }
    
    if (Is_Valid == 0) {
        Show_Error_Toastr("Can't search. Please provide all the required information.");
        return;
    }
    // disable search button to avoid multiple function calls
    $("#btn_Search").prop('disabled', true);
    var Method_Name = 'Get';
    var APIEndPoint = "GetNotification";
    var url = "/Transactions/Notification";
    // store data in object and send to the controller
    var reqdata = {
        "method_name": Method_Name,
        "notification_period": NotificationPeriod,
        "api_end_point": APIEndPoint,
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
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
                EditFlag = true;
                
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.notificationtype_name + "</td>";
                TableHTML += "<td>" + value.notification_message + "</td>";
                TableHTML += "<td>" + value.schedule_date + "</td>";
                TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                // if not locked, let the user edit the entry and give access to Edit & Delete functionality
                if (EditFlag == true) {
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Edit\" onclick=\"ShowEditEntry('Edit','" + value.notification_id + "')\">";
                    TableHTML += "<i class=\"fa fa-pencil\"></i>";
                    TableHTML += "</a>";

                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"Delete\" onclick=\"ShowDeleteEntry('" + value.notification_id + "')\">";
                    TableHTML += "<i class=\"fa fa-trash\"></i>";
                    TableHTML += "</a>";
                }
                else {
                    TableHTML += "<a href=\"javascript:void(0);\" class=\"btn btn-icon py-0\" title=\"View\" onclick=\"ShowEditEntry('View','" + value.notification_id + "')\">";
                    TableHTML += "<i class=\"fa fa-eye\"></i>";
                    TableHTML += "</a>";
                }
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });
            // assign the html string to table body present in the search page
            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [4], "Notification List");
            $("#btn_Search").prop('disabled', false);
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            $("#btn_Search").prop('disabled', false);
        }
    });
    // enable search button to let user make function calls
    $("#btn_Search").prop('disabled', false);
    return;
}








function ShowAddEntry() {
    ShowContentDiv('Transactions', 'NotificationAdd', '', function () {
        // Initialization Code
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        // $("#ddlEntrySalesArea").select2();
        $("#txtEntryScheduleDate").val(formattedDate);
        $("#txtEntryScheduleDate").attr("min", formattedDate);

        $("#ddlEntryNotificationFor").select2();
        $("#ddlEntryNotificationType").select2();

        GetMaster("ddlEntryNotificationFor", "Select Notification For", "GetNotificationFor", "", "");
        GetMaster("ddlEntryNotificationType", "Select Notification Type", "GetNotificationType", "", "");


        $("#lblEntryId").html("");
        $("#lblAction").html("Add");


        $("#divFooterDelete").hide();
    });
}

function CloseEntry() {
    GetSearchList();
    HideContentDiv();
}
function ShowEditEntry(Action, Notification_Id) {
    ShowContentDiv('Transactions', 'NotificationEdit', '', function () {
        // Initialization Code
       
        // $("#ddlEntrySalesArea").select2();
        

        $("#ddlEntryNotificationFor").select2();
        $("#ddlEntryNotificationType").select2();

        GetMaster("ddlEntryNotificationFor", "Select Notification For", "GetNotificationFor", "", "");
        GetMaster("ddlEntryNotificationType", "Select Notification Type", "GetNotificationType", "", "");

        $("#lblEntryId").html(Notification_Id);
        $("#lblAction").html(Action);




        var Method_Name = 'Get_One';
        var APIEndPoint = "GetInquiry";
        var url = "/Inquiry/Inquiry";
        // store data in object and send to the controller
        var reqdata = {
            "method_name": Method_Name,
            "salesinquiry": SalesInquiry,
            "api_end_point": APIEndPoint
        };
        $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,
            success: function (result) {
                var res = JSON.parse(result)[0];

                var currentDate = new Date();
                var formattedDate = currentDate.toISOString().slice(0, 10);
                $("#txtEntryScheduleDate").attr("min", formattedDate);

                $("#txtEntryScheduleDate").val(res.schedule_date);
                $("#txtEntryMessage").val(res.notification_message);
                $("#txtEntrySubject").val(res.notification_subject);

                GetMaster("ddlEntryNotificationFor", "Select Notification For", "GetNotificationFor", res.notificationfor_id, "");
                GetMaster("ddlEntryNotificationType", "Select Notification Type", "GetNotificationType", res.notificationtype_id, "");

                if (res.is_active == 1) {
                    $("#chkEntryStatus").prop("checked", true);
                }
                else {
                    $("#chkEntryStatus").prop("checked", false);
                }


                if (Action == "View") {
                    $("#txtEntryScheduleDate").prop("disabled", true);
                    $("#ddlEntryNotificationFor").prop("disabled", true);
                    $("#ddlEntryNotificationType").prop("disabled", true);
                    $("#txtEntryMessage").prop("disabled", true);
                    $("#txtEntrySubject").prop("disabled", true);
                    $("#chkEntryStatus").prop("disabled", true);

                }
                else {
                    $("#txtEntryScheduleDate").prop("disabled", false);
                    $("#ddlEntryNotificationFor").prop("disabled", false);
                    $("#ddlEntryNotificationType").prop("disabled", false);
                    $("#txtEntryMessage").prop("disabled", false);
                    $("#txtEntrySubject").prop("disabled", false);
                    $("#chkEntryStatus").prop("disabled", false);

                }

            },
            error: function () {
                Show_Error_Toastr("Error in fetching details from server.", res.result_description);
                $("#btn_Search").prop('disabled', false);
            }
        });




        $("#divFooterDelete").show();




    });
}

function SaveEntry() {
    // Validation code
    var NotificationFor_Id = $("#ddlEntryNotificationFor").val();
    var NotificationType_Id = $("#ddlEntryNotificationType").val();
    var Schedule_Date = $("#txtEntryScheduleDate").val();
    var Message = $("#txtEntryMessage").val();
    var Subject = $("#txtEntrySubject").val();


    var IsValid = 1;
    //var APIEndPoint = "SaveRetailer";

    //var url = "/Masters/Retailer";

    if (NotificationFor_Id == "") {
        IsValid = 0;
        $("#ddlEntryNotificationFor").addClass("is-invalid state-invalid");

    }
    if (NotificationType_Id == "") {
        IsValid = 0;
        $("#ddlEntryNotificationType").addClass("is-invalid state-invalid");

    }
    if (Message == "") {
        IsValid = 0;
        $("#txtEntryMessage").addClass("is-invalid state-invalid");

    }
    if (Subject == "") {
        IsValid = 0;
        $("#txtEntrySubject").addClass("is-invalid state-invalid");

    }
    if (Schedule_Date == "") {
        IsValid = 0;
        $("#txtEntryScheduleDate").addClass("is-invalid state-invalid");

    }
  
    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        return;
    }
    else {

        //Start Saving
        $("#btn_Save").prop('disabled', true);
        var Method_Name = 'Create';
        var Notification_Id = "";
        var Action_Name = $("#lblAction").html();
        if (Action_Name == 'Edit') {
            Method_Name = 'Update';
            Notification_Id = $("#lblEntryId").html();
        }
        var Is_Active = 1;
        if (document.getElementById("chkEntryStatus").checked == false) {
            Is_Active = 0;
        }
        var Is_Deleted = 0;
        var url = "/Transactions/Notification";
        var APIEndPoint = "SaveNotification";

        var reqdata = {
            "is_active": Is_Active,
            "is_deleted": Is_Deleted,
            "method_name": Method_Name,
            "api_end_point": APIEndPoint,

            "notification_id": Notification_Id,
            "notificationfor_id": NotificationFor_Id,
            "notificationtype_id": NotificationType_Id,
            "schedule_date": Schedule_Date,
            "notification_message": Message,
            "notification_subject": Subject
        };

        //Save
        return $.ajax({
            type: 'POST',
            url: url,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            data: reqdata,

            success: function (result) {
                var res = JSON.parse(result)[0];
                if (res.result_id == 1) {
                    // Show Success Message
                    $("#lblEntryId").html(res.result_extra_key);
                    $("#lblAction").html("Edit");
                    ShowEntrySuccess("Notification details saved successfully");
                    
                } else {
                    ShowEntryError("Error : " + res.result_description);
                    $("#btn_Save").prop('disabled', false);
                }
            },
            error: function () {
                Show_Error_Toastr("Error : Notification details not saved");
                $("#btn_Save").prop('disabled', false);
            }
        });

    }
    return;
}





function ShowDeleteEntry(Notification_Id) {

    swal(
        {
            title: "Are you sure?",
            text: "You won't be able to revert this!",
            icon: 'question',
            type: "warning",
            showCancelButton: true,
            confirmButtonText: "Yes, delete it!"
        }, function (result) {
            if (result == true) {
                SaveDeleteEntry(Notification_Id);
            }
        });

}

function SaveDeleteEntry(Notification_Id) {

    var APIEndPoint = "SaveNotification";
    var url = "/Transactions/Notification";

    var reqdata = {
        "notification_id": Notification_Id,
        "method_name": "Delete",
        "api_end_point": APIEndPoint
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result)[0];
            if (res.result_id == 1) {
                // Show Success Message
                Show_Success_Toastr("Notification details deleted successfully");
                CloseEntry();
            } else {
                Show_Error_Toastr("Error : " + res.result_description);
            }
        },
        error: function () {
            Show_Error_Toastr("Error : Notification details not deleted");
        }
    });
}

