$(document).ready(function () {
    $("#ddlSearchDealer").select2();
    GetMaster("ddlSearchDealer", "Select Dealer", "GetDealer", "", "");

    // Create a style element for 
    const style = document.createElement('style');
    document.head.appendChild(style);
    style.sheet.insertRule('input::-webkit-inner-spin-button { -webkit-appearance: none; }', 0);


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
    $("#btn_Search").prop("disabled", true);
    ClearDataTable("tableSearch");
    // Get data from database and show in table

    var SearchPeriod = $("#txtSearchEntryPeriod").val();
    var SearchDealer_Id = "%" + $("#ddlSearchDealer").val() + "%";
    var Method_Name = "Get";
    var APIEndPoint = "GetDealerStock";
    var url = "/Secondary/DealerStock";
    var reqdata = {
        method_name: Method_Name,
        entry_period: SearchPeriod,
        dealer_id: SearchDealer_Id,
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
                Show_Error_Toastr("Data not found.");
                Hide_Loader();
                return;
            }
            // Fill data in table
            var TableHTML = "";
            var EditFlag;
            $.each(res, function (data, value) {
                EditFlag = value.is_locked;
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.dealerstock_id + "</td>";
                TableHTML += "<td>" + value.dealer_name + "</td>";
                TableHTML += "<td>" + value.entry_date + "</td>";
                TableHTML += "<td>" + value.month_year_name + "</td>";
                TableHTML += "<td>" + value.no_of_items + "</td>";
                TableHTML += "<td class='text-right' style='width: 40px; padding:8px 5px 8px 5px;'>";
                if (EditFlag == 0) {
                    // Edit
                    TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\''
                        + value.dealerstock_id + '\',\''
                        + value.dealer_id + '\',\''
                        + value.month_year
                        + '\');">';
                    TableHTML += '<i class="fa fa-pencil"></i>';
                    TableHTML += "</a>";
                    /*
                    // Delete
                    TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="ShowEditEntry(\'Delete\',\''
                        + value.dealerstock_id + '\',\''
                        + value.dealer_id + '\',\''
                        + value.month_id + '\',\''
                        + value.year_id
                        + '\');">';
                    TableHTML += '<i class="fa fa-trash"></i>';
                    TableHTML += "</a>";
                    */
                }
                else {
                    // View
                    TableHTML += '<a href="javascript:void(0);" class="btn btn-icon py-0" title="View" onclick="ShowEditEntry(\'View\',\''
                        + value.dealerstock_id + '\',\''
                        + value.dealer_id + '\',\''
                        + value.month_year
                        + '\');">';
                    TableHTML += '<i class="fa fa-eye"></i>';
                    TableHTML += "</a>";
                }
                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [5], "Dealer Stock");
            Hide_Loader();
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
        },
    });
    $("#btn_Search").prop("disabled", false);
    return;
}



function GetSearchProductList() {


    var Dealer_Id = $("#ddlEntryDealer").val();


    ClearDataTable("tableProducts_1");
    var APIEndPoint = "GetDealerStock";
    var Method_Name = "GetAllProductList";
    var url = "/Secondary/DealerStock";
    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        dealer_id: Dealer_Id
    };

    Show_Loader();

    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            var TableHTML = "";
            $.each(res, function (data, value) {
                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.product_id + "</td>";
                TableHTML += "<td>" + value.product_name + "</td>";
                TableHTML += "<td><input type='number' value='0' class='form-control' ";
                TableHTML += "pattern='^[0-9]+$' autocomplete='off' ></td> ";
                TableHTML += "</tr>";
            });
            $("#tableEntryProducts_1").html(TableHTML);
            // SetDataTable("tableProducts", [1], "Product Stock");
            // setTimeout(() => {
                SetPagingDataTable("tableProducts_1", [3], "Dealer Stock Product");
            // }, 100);
            Hide_Loader();
        },

        error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
        },
    });

}






function ShowAddEntry() {
    ShowContentDiv('Secondary', 'DealerStockAdd', '', function () {
        $("#lblAction").html("Add");
        $("#lblEntryId").html("");
        $("#ddlEntryDealer").select2();
        // set month - year
        // SetDate();

        // set to current monthtableProducts
        var nextdate = new Date(Date.now());
        var newdate = nextdate.toISOString().slice(0, 7);
        $("#txtEntryMonthYear").attr("min", newdate);
        $("#txtEntryMonthYear").val(newdate);


        $("#btn_Save").show();
        $("#divFooterDelete").hide();
        GetMaster("ddlEntryDealer", "Select Dealer", "GetDealer", "", "");

        // get products table
        //ClearDataTable("tableProducts");
        //var APIEndPoint = "GetDealerStock";
        //var Method_Name = "GetAllProductList";
        //var url = "/Secondary/DealerStock";
        //var reqdata = {
        //    method_name: Method_Name,
        //    api_end_point: APIEndPoint
        //};
        //$.ajax({
        //    type: "POST",
        //    url: url,
        //    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        //    data: reqdata,
        //    success: function (result) {
        //        var res = JSON.parse(result);
        //        var TableHTML = "";
        //        $.each(res, function (data, value) {
        //            TableHTML += "<tr>";
        //            TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
        //            TableHTML += "<td>" + value.product_id + "</td>";
        //            TableHTML += "<td>" + value.product_name + "</td>";
        //            TableHTML += "<td><input type='number' value='0' class='form-control' ";
        //            TableHTML += "pattern='^[0-9]+$' autocomplete='off' ></td> ";
        //            TableHTML += "</tr>";
        //        });
        //        $("#tableEntryProducts").html(TableHTML);
        //        SetDataTable("tableProducts", [1], "Product Stock");
        //    },

        //    error: function () {
        //        Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
        //    },
        //});
    });
    return;
}

// function ShowEditEntry(Action, DealerStock_Id, Dealer_Id, Month_Year) {
//     ShowContentDiv('Secondary', 'DealerStockEdit', '', function () {
//         $("#lblAction").html(Action);
//         $("#lblEntryId").html(DealerStock_Id);

//         $("#ddlEntryDealer").select2();
//         GetMaster("ddlEntryDealer", "Select Dealer", "GetDealer", Dealer_Id, "");
//         $("#txtEntryMonthYear").attr("min", Month_Year);
//         $("#txtEntryMonthYear").val(Month_Year);

//         var disabled = "";
//         // disable elements if Action is View
//         if (Action == "View") {
//             disabled = "disabled";
//             $("#ddlEntryDealer").prop("disabled", true);
//             $("#txtEntryMonthYear").prop("disabled", true);
//             $("#btn_Save").hide();
//             $("#divFooterDelete").hide();
//         }
//         else {
//             disabled = "";
//             $("#ddlEntryDealer").prop("disabled", false);
//             $("#txtEntryMonthYear").prop("disabled", false);
//             $("#btn_Save").show();
//             $("#divFooterDelete").show();
//         }

//         ClearDataTable("tableProducts");
//         var APIEndPoint = "GetDealerStock";
//         var Method_Name = "Get_One";
//         var url = "/Secondary/DealerStock";
//         var reqdata = {
//             method_name: Method_Name,
//             dealerstock_id: DealerStock_Id,
//             api_end_point: APIEndPoint
//         };
//         $.ajax({
//             type: "POST",
//             url: url,
//             contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//             data: reqdata,
//             success: function (result) {
//                 // console.log("1");
//                 // console.log(result);
//                 var res = JSON.parse(result);
//                 var TableHTML = "";
//                 var RowNo = 0;
//                 $.each(res, function (data, value) {
//                     TableHTML += "<tr>";
//                     TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
//                     TableHTML += "<td>" + value.product_id + "</td>";
//                     TableHTML += "<td>" + value.product_name + "</td>";
//                     TableHTML += "<td>" + value.quantity + "</td>";
//                     // TableHTML += "<td><input type='number' value='" + value.quantity + "' class='form-control' ";
//                     // TableHTML += "pattern='^[0-9]+$' autocomplete='off' " + disabled + "></td> ";
//                     // TableHTML += "</tr>";
//                 });
//                 $("#tableEntryProducts").html(TableHTML);
//                 // SetDataTable("tableProducts", [1], "Product Stock");
//                 setTimeout(() => {
//                     SetPagingDataTable("tableProducts", [3], "Dealer Stock Product");
//                 }, 100);
//             },
//             error: function () {
//                 Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
//             },
//         });
//     });
//     return;

// }

function ShowEditEntry(Action, DealerStock_Id, Dealer_Id, Month_Year) {
    ShowContentDiv('Secondary', 'DealerStockEdit', '', function () {
        $("#lblAction").html(Action);
        $("#lblEntryId").html(DealerStock_Id);

        $("#ddlEntryDealer").select2();
        GetMaster("ddlEntryDealer", "Select Dealer", "GetDealer", Dealer_Id, "");
        $("#txtEntryMonthYear").attr("min", Month_Year);
        $("#txtEntryMonthYear").val(Month_Year);

        var disabled = "";
        // disable elements if Action is View
        if (Action == "View") {
            disabled = "disabled";
            $("#ddlEntryDealer").prop("disabled", true);
            $("#txtEntryMonthYear").prop("disabled", true);
            $("#btn_Save").hide();
            $("#divFooterDelete").hide();
        }
        else {
            disabled = "";
            $("#ddlEntryDealer").prop("disabled", false);
            $("#txtEntryMonthYear").prop("disabled", false);
            $("#btn_Save").show();
            $("#divFooterDelete").show();
        }

        ClearDataTable("tableProducts_1");
        var APIEndPoint = "GetDealerStock";
        var Method_Name = "Get_One";
        var url = "/Secondary/DealerStock";
        var reqdata = {
            method_name: Method_Name,
            dealerstock_id: DealerStock_Id,
            api_end_point: APIEndPoint
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
                    Show_Error_Toastr("Data not found.");
                    Hide_Loader();
                    return;
                }
                var TableHTML = "";

                $.each(res, function (data, value) {
                    TableHTML += "<tr>";
                    TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                    TableHTML += "<td>" + value.product_id + "</td>";
                    TableHTML += "<td>" + value.product_name + "</td>";
                    // TableHTML += "<td>" + value.quantity + "</td>";
                    TableHTML += "<td><input type='number' value='" + value.quantity + "' class='form-control' ";
                    TableHTML += "pattern='^[0-9]+$' autocomplete='off' " + disabled + "></td> ";
                    TableHTML += "</tr>";
                });
                $("#tableEntryProducts_1").html(TableHTML);
                // SetDataTable("tableProducts", [1], "Product Stock");
                // setTimeout(() => {
                SetPagingDataTable("tableProducts_1", [3], "Dealer Stock Product");
                // }, 100);
                Hide_Loader();
            },
            error: function () {
                Hide_Loader();
                Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
            },
        });
    });
    return;

}

// function ShowEditEntry(Action, DealerStock_Id, Dealer_Id, Month_Year) {
//     console.log("1");
//     ShowContentDiv('Secondary', 'DealerStockEdit', '', function () {
//         $("#lblAction").html(Action);
//         $("#lblEntryId").html(DealerStock_Id);

//         $("#ddlEntryDealer").select2();
//         GetMaster("ddlEntryDealer", "Select Dealer", "GetDealer", Dealer_Id, "");
//         $("#txtEntryMonthYear").attr("min", Month_Year);
//         $("#txtEntryMonthYear").val(Month_Year);

//         var disabled = "";
//         // disable elements if Action is View
//         if (Action == "View") {
//             disabled = "disabled";
//             $("#ddlEntryDealer").prop("disabled", true);
//             $("#txtEntryMonthYear").prop("disabled", true);
//             $("#btn_Save").hide();
//             $("#divFooterDelete").hide();
//         }
//         else {
//             disabled = "";
//             $("#ddlEntryDealer").prop("disabled", false);
//             $("#txtEntryMonthYear").prop("disabled", false);
//             $("#btn_Save").show();
//             $("#divFooterDelete").show();
//         }

//         ClearDataTable("tableProducts");
//         var APIEndPoint = "GetDealerStock";
//         var Method_Name = "Get_One";
//         var url = "/Secondary/DealerStock";
//         var reqdata = {
//             method_name: Method_Name,
//             dealerstock_id: DealerStock_Id,
//             api_end_point: APIEndPoint
//         };
//         $.ajax({
//             type: "POST",
//             url: url,
//             contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//             data: reqdata,
//             success: function (result) {
//                 console.log("1");
//                 console.log(result);
//                 var res = JSON.parse(result);
//                 var TableHTML = "";
//                 var RowNo = 0;

//                 $.each(res, function (data, value) {

//                     if ((Action == "Edit")) {
//                         RowNo += 1;
//                         TableHTML += "<tr>";
//                         TableHTML += "<td style='width: 20px;'>" + (RowNo) + "</td>";
//                         TableHTML += "<td>" + value.product_id + "</td>";
//                         TableHTML += "<td>" + value.product_name + "</td>";
//                         TableHTML += "<td><input type='number' value='" + value.quantity + "' class='form-control' ";
//                         TableHTML += "pattern='^[0-9]+$' autocomplete='off' " + disabled + "></td> ";
//                         TableHTML += "</tr>";
//                     }else if ((Action == "View" && value.quantity == 0)) {
//                         RowNo += 1;
//                         TableHTML += "<tr>";
//                         TableHTML += "<td style='width: 20px;'>" + (RowNo) + "</td>";
//                         TableHTML += "<td>" + value.product_id + "</td>";
//                         TableHTML += "<td>" + value.product_name + "</td>";
//                         TableHTML += "<td><input type='number' value='" + value.quantity + "' class='form-control' ";
//                         TableHTML += "pattern='^[0-9]+$' autocomplete='off' " + disabled + "></td> ";
//                         TableHTML += "</tr>";
//                     }
//                 });
//                  debugger;
//                 $("#tableEntryProducts").html(TableHTML);
//                 SetPagingDataTable("tableProducts", [3], "Dealer Stock Product");
//             },
//             error: function () {
//                 Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
//             },
//         });
//     });
//     return;

// }

// function ShowEditEntry(Action, DealerStock_Id, Dealer_Id, Month_Year) {

//     ShowContentDiv('Secondary', 'DealerStockEdit', '', function () {

//         $("#lblAction").html(Action);
//         $("#lblEntryId").html(DealerStock_Id);

//         // Fix select2 re-init issue
//         if ($("#ddlEntryDealer").hasClass("select2-hidden-accessible")) {
//             $("#ddlEntryDealer").select2('destroy');
//         }
//         $("#ddlEntryDealer").select2();

//         GetMaster("ddlEntryDealer", "Select Dealer", "GetDealer", Dealer_Id, "");

//         $("#txtEntryMonthYear").attr("min", Month_Year).val(Month_Year);

//         let isView = (Action === "View");

//         $("#ddlEntryDealer").prop("disabled", isView);
//         $("#txtEntryMonthYear").prop("disabled", isView);
//         $("#btn_Save").toggle(!isView);
//         $("#divFooterDelete").toggle(!isView);

//         // Destroy DataTable properly
//         if ($.fn.DataTable.isDataTable('#tableProducts')) {
//             $('#tableProducts').DataTable().clear().destroy();
//         }

//         var url = "/Secondary/DealerStock";

//         $.ajax({
//             type: "POST",
//             url: url,
//             data: {
//                 method_name: "Get_One",
//                 dealerstock_id: DealerStock_Id,
//                 api_end_point: "GetDealerStock"
//             },
//             success: function (result) {

//                 let res;

//                 try {
//                     res = (typeof result === "string") ? JSON.parse(result) : result;
//                 } catch (e) {
//                     console.error("JSON Parse Error:", e);
//                     return;
//                 }

//                 let TableHTML = "";
//                 let RowNo = 0;

//                 if (!res || res.length === 0) {
//                     $("#tableEntryProducts").html("<tr><td colspan='4'>No Data Found</td></tr>");
//                     return;
//                 }

//                 $.each(res, function (i, value) {

//                     // FIX: Always show in View (remove quantity==0 condition)
//                     if (Action === "Edit" || Action === "View") {

//                         RowNo++;

//                         TableHTML += `
//                             <tr>
//                                 <td style="width:20px;">${RowNo}</td>
//                                 <td>${value.product_id}</td>
//                                 <td>${value.product_name}</td>
//                                 <td>
//                                     <input type="number" 
//                                            value="${value.quantity}" 
//                                            class="form-control"
//                                            ${isView ? "disabled" : ""}>
//                                 </td>
//                             </tr>`;
//                     }
//                 });

//                 // console.log(TableHTML);

//                 ClearDataTable("tableProducts");
//                 $("#tableEntryProducts").html(TableHTML);

//                 // Reinitialize DataTable AFTER HTML bind
//                 setTimeout(() => {
//                     SetPagingDataTable("tableProducts", [3], "Dealer Stock Product");
//                 }, 100);
//             },
//             error: function (xhr) {
//                 console.error(xhr);
//                 Show_Error_Toastr("Error in fetching details from server.");
//             }
//         });

//     });
// }

function SetDate() {
    // get month_id and year_id from db
    // set month+1 and if 12, then year + 1 and month=1

    var APIEndPoint = "GetDealerStock";
    var Method_Name = "GetMonthAndYear";
    var url = "/Secondary/DealerStock";
    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            var nextdate = new Date(res[0].month_year);
            nextdate.setMonth(nextdate.getMonth() + 1)
            var newdate = nextdate.toISOString().slice(0, 7);
            $("#txtEntryMonthYear").attr("min", newdate);
            $("#txtEntryMonthYear").val(newdate);
        },
        error: function () {
            Show_Error_Toastr("Error in fetching details from server.", res[0].result_description);
        },
    });
    return;
}

function SaveEntry() {
    $("#btn_Save").prop("disabled", true);
    var Dealer_Id = $("#ddlEntryDealer").val();
    var Month_Year = $("#txtEntryMonthYear").val();
    var sum = 0;
    // generating xml data
    var Product_Data = "<Products>";
    $("#tableProducts tbody tr").each(function () {
        sum += parseInt($(this).find("td:eq(3) input").val());
        Product_Data += "<ProductItem>";
        Product_Data += "<Product_Id>" + $(this).find("td:eq(1)").text() + "</Product_Id>";
        Product_Data += "<Quantity>" + $(this).find("td:eq(3) input").val() + "</Quantity>";
        Product_Data += "</ProductItem>";
    });
    Product_Data += "</Products>";


    var IsValid = 1;
    if (Dealer_Id == "") {
        IsValid = 0;
        $("#ddlEntryDealer").addClass("is-invalid state-invalid");
    }
    if (Month_Year == "") {
        IsValid = 0;
        $("#txtEntryMonthYear").addClass("is-invalid state-invalid");
    }
    if (sum <= 0) {
        IsValid = 0;
    }
    if (IsValid == 0) {
        ShowEntryError("Invalid Input(s). Can't be saved.");
        $("#btn_Save").prop("disabled", false);
        return;
    }
    else {
        // Start Saving
        var Is_Active = 1;
        var Is_Deleted = 0;

        var FullDate = Month_Year + '-01';



        var APIEndPoint = "SaveDealerStock";
        var Method_Name = "Create";
        var DealerStock_Id = "";
        var Action_Name = $("#lblAction").html();
        if (Action_Name == "Edit") {
            Method_Name = "Update";
            DealerStock_Id = $("#lblEntryId").html();
        }
        var url = "/Secondary/DealerStock";
        var reqdata = {
            method_name: Method_Name,
            api_end_point: APIEndPoint,
            is_active: Is_Active,
            is_deleted: Is_Deleted,
            dealerstock_id: DealerStock_Id,
            dealer_id: Dealer_Id,
            dealerstock_date: FullDate,
            product_data: Product_Data
        };
        $.ajax({
            type: "POST",
            url: url,
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            data: reqdata,
            success: function (res) {
                var result = JSON.parse(res);
                if (result[0].result_id == 1) {
                    ShowEntrySuccess("Dealer Stock " + result[0].result_description);
                    ShowEditEntry("Edit", result[0].result_extra_key, Dealer_Id, Month_Year);
                } else {
                    ShowEntryError("Error : " + result[0].result_description);
                }
            },
            error: function () {
                ShowEntryError("Error : Dealer Stock not saved");
            },
        });
        //$("#modelProductPhoto").modal("hide");
    }
    $("#btn_Save").prop("disabled", false);
}



function CloseEntry() {
    GetSearchList();
    HideContentDiv();
}



// delete Dealer Stock
function ShowDeleteEntry(DealerStock_Id) {
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
                SaveDeleteEntry(DealerStock_Id);
            }
        }
    );
}





function SaveDeleteEntry(DealerStock_Id) {
    // Write code to delete
    if (DealerStock_Id == "" || DealerStock_Id == null || DealerStock_Id == undefined) {
        DealerStock_Id = $("#lblEntryId").html();
    }
    var APIEndPoint = "SaveDealerStock";
    var url = "/Secondary/DealerStock";
    var reqdata = {
        dealerstock_id: DealerStock_Id,
        method_name: "Delete",
        api_end_point: APIEndPoint,
        request_for: "Header"
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
                Show_Success_Toastr("Dealer Stock details deleted successfully");
                CloseEntry();
            } else {
                ShowEntryError("Error : " + result[0].result_description);
            }
        },
        error: function () {
            ShowEntryError("Error : Dealer Stock details not deleted");
        },
    });
}