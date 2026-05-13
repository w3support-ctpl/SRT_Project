$(document).ready(function () {

    $("#ddlSearchUserRole").select2();

    GetMaster("ddlSearchUserRole", "Select User Role", "GetUserRole", "", "");

    SetDataTable("tableSearch", [6], "User");

    GetSearchList('1');
});

function GetSearchList(e) {
   // Get data from database and show in table
    $('#tableData').empty();

    var Method_Name = "Get";
    var OfficeUser_Name = $("#txtSearchUserName").val();
    var Role_Id = $("#ddlSearchUserRole").val();

    var url = "/Users/GetOfficeUser";
    var reqdata = {
        "method_name": Method_Name,
        "officeuser_name": OfficeUser_Name,
        "role_id": Role_Id
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            //const Response_Data = JSON.parse(result);
            var Row_Html = "";
            var Row_Count = 1;
            if (result.length > 0) {
                $.each(Response_Data, function (data, value) {
                    Card_Html += "<tr>";
                    Card_Html += "<td class='text-left'>" + Row_Count + "</td>";
                    Card_Html += "<td class='text-left'>" + value.userName + "</td>";
                    Card_Html += "<td class='text-left'>" + value.mobile_No + "</td>";
                    Card_Html += "<td class='text-left'>" + value.email_Id + "</td>";
                    Card_Html += "<td class='text-left'>" + value.user_Role + "</td>";
                    Card_Html += "<td class='text-left'>" + value.status + "</td>";

                    Card_Html += "<td class='text-right' style='width: 50px; padding: 8px 5px 8px 5px;'>" + "<span> <a href='../Users/GetOfficeUser?OID=" + window.btoa(value.officeuser_Id) + "' title='User'><i class='fa fa-pencil-square-o fa-lg' aria-hidden='true'></i></a></span>" + "</td >";
                    Card_Html += "</tr>";
                });

                $('#tableData').html(Card_Html);
            }
            else {
                    Show_Error_Toastr("Error : User details not accessed");
                }
            }       
    });

    ShowEntrySuccess("User details show successfully");
}

function ShowAddEntry() {
    ShowContentDiv("Users", "UserAdd", "", function () {
        // Initialization Code
        $("#ddlEntryUserRole").select2();
        $("#divFooterActions").hide();

        $("#lblEntryId").html("");
        $("#lblAction").html("Add");

        GetMaster("ddlEntryUserRole", "Select User Role", "GetUserRole", "", "");
    });
}

function ShowEditEntry(User_Id) {
    ShowContentDiv("Users", "UserEdit", "", function () {
        // Initialization Code
        $("#ddlEntryUserRole").select2();

        $("#lblEntryId").html(User_Id);
        $("#lblAction").html("Edit");

        GetMaster("ddlEntryUserRole", "Select User Role", "GetUserRole", "", "");
    });
}

function CloseEntry() {
    HideContentDiv();
}

function SaveEntry() {
    // Validation code
    var UserName = $("#txtEntryUserName").val();
    var JoiningDate = $("#txtEntryJoiningDate").val();
    var MobileNo = $("#txtEntryMobileNo").val();
    var UserRole = $("#ddlEntryUserRole").val();
    var EmailID = $("#txtEntryEmailID").val();
       
    if (UserName == "") {
        ShowEntryError("Enter User Name");
        return;
    }

    if (JoiningDate == "") {
        ShowEntryError("Select Joining Date");
        return;
    }

    if (MobileNo == "") {
        ShowEntryError("Enter Mobile No");
        return;
    }

    if (UserRole == "") {
        ShowEntryError("Enter User Role");
        return;
    }

    if (EmailID == "") {
        ShowEntryError("Enter Email");
        return;
    }

    // Start Saving
    $("#btn_Save").prop('disabled', true);

    // Save
    var Method_Name = 'Create';
    var OfficeUser_Id = '';
    var Action_Name = $("#lblAction").html();
    if (Action_Name == 'Edit') {
        Method_Name = 'Update';
        OfficeUser_Id = $("#lblEntryId").html();
    }

    var OfficeUser_Name = $('#txtEntryUserName').val();
    var User_Role = $('#ddlEntryUserRole').val();
    var Joining_Date = $('#txtEntryJoiningDate').val();
    var Mobile_No = $('#txtEntryMobileNo').val();
    var Email_ID = $('#txtEntryEmailID').val();
    var Pan_No = $('#txtEntryPanNo').val();
    var Aadhar_No = $('#txtEntryAadharNo').val();
   
    var Is_Active = 1;
    if (document.getElementById('chkEntryStatus').checked == false) {
        Is_Active = 0;
    }
    var Is_Deleted = 0;

    var url = "/Users/SaveOfficeUser";
    var reqdata = {
        "method_name": Method_Name,
        "officeuser_id": OfficeUser_Id,
        "officeuser_name": OfficeUser_Name,
        "user_role": User_Role,
        "mobile_no": Mobile_No,
        "joining_date": Joining_Date,
        "email_id": Email_ID,
        "pan_no": Pan_No,
        "aadhar_no": Aadhar_No,
        "is_active": Is_Active,
        "is_deleted": Is_Deleted,
    };
    $.ajax({
        type: 'POST',
        url: url,
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        data: reqdata,
        success: function (result) {
            if (result[0].result_Id == 1) {
                // Show Success Message
                Show_Success_Toastr("User details saved successfully");

                GetSearchList();
                CloseEntry();

            } else {
                Show_Error_Toastr("Error : " + result[0].result_Description);
                $("#btn_Save").prop('disabled', false);
            }

        },
        error: function () {
            Show_Error_Toastr("Error : User details not saved");
            $("#btn_Save").prop('disabled', false);
        }
    });



    ShowEntrySuccess("User details saved successfully");
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
    var User_Id = $("#lblEntryId").html();
    // In success do following things
    Show_Success_Toastr("User entry blocked successfully");
    CloseEntry();
    GetSearchList();
}
