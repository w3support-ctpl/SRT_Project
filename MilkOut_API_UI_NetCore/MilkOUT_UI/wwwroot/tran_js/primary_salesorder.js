$(document).ready(function () {
    $("#ddlSearchDealerName").select2();
    $("#ddlSearchSalesArea").select2();
    GetMaster("ddlSearchDealerName", "Select Dealer Name", "GetDealer", "", ""); // Topmost Section
    // SetDataTable("tableSearch", [6], "Dealer");

    const style = document.createElement("style");
    document.head.appendChild(style);
    style.sheet.insertRule(
        "input::-webkit-inner-spin-button { -webkit-appearance: none; }",
        0,
    );

    GetMaster(
        "ddlSearchSalesArea",
        "Select Sales Group",
        "GetSalesAreaforSaleOrder",
        "",
        "",
    );

    getalldealers();

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
    var ProdutList = [];
    var Dealerlist = [];
    var productitemcount = 0;
    var orderstatus = "";
    getproducts();
});

async function getalldealers() {
    Dealerlist = [];

    var url = "/Home/GetMasterData";
    var reqdata = {
        Method_Name: "GetAllDealers",
        ParentField_Id: "",
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            Dealerlist = result;
        },
        error: function () {
            Show_Error_Toastr("Error in fetching master data");
        },
    });
}

function getproducts() {
    ProdutList = [];

    var Method_Name = "Get_SalesProduct";
    var APIEndPoint = "GetSalesOrderProduct";
    var url = "/SalesOrder/SalesOrder";
    // store data in object and send to the controller
    var reqdata = {
        method_name: Method_Name,
        salesinquiry: "",
        api_end_point: APIEndPoint,
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (result) {
            var res = JSON.parse(result);
            ProdutList = res;
        },
        error: function () { },
    });
}

function changeSalesAreaname() {
    var SalesAreaName = $("#ddlEntrySalesAreaName").val();
    // Split the SalesAreaName string into individual parts
    var parts = SalesAreaName.split(" - ");

    // Assign each part to corresponding variables
    var SalesGroup = parts[0];
    var SalesOffice = parts[1];
    var SalesOrganization = parts[2];
    var DistributionChannel = parts[3];
    var OrganizationDivision = parts[4];

    GetMaster(
        "ddlEntryItemCode",
        "Select Sales Group",
        "GetProductOndivision",
        "",
        OrganizationDivision,
    );

    //GetMaster("ddlEntryItemCode", "Select Item", "GetProductsCode", "", "");
}

function GetSearchList(e) {
    ClearDataTable("tableSearch");
    // Get data from database and show in table
    // Validate Data
    $("#tableData").empty();
    //var Dealer_Id = $("#ddlSearchDealerName").val();

    var salesarea = $("#ddlSearchSalesArea").val();

    var dateRange = $("#txtSearchOrderDate").val();

    // Split the date range string into start and end date strings
    var dateArray = dateRange.split(" - ");
    var startDateString = dateArray[0];
    var endDateString = dateArray[1];

    // Parse the dates using Date object
    var startDate = new Date(startDateString);
    var endDate = new Date(endDateString);

    startDate.setDate(startDate.getDate() + 1);

    // Adjust the endDate to consider the end of the day
    endDate.setDate(endDate.getDate() + 1); // Increment the day by 1 to include the end date
    endDate.setHours(0, 0, 0, 0);

    // Format the dates as per your requirement
    var formattedStartDate = startDate.toISOString().split("T")[0] + "T00:00:00";
    var formattedEndDate = endDate.toISOString().split("T")[0] + "T00:00:00";

    var IsValid = 1;
    if (salesarea == "") {
        $("#ddlSearchSalesArea").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (dateRange == "") {
        $("#txtSearchOrderDate").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (IsValid == 0) {
        Show_Error_Toastr("Invalid data. Can't search.");
        return;
    }
    $("#btn_Search").prop("disabled", true);
    var Method_Name = "Get";
    var APIEndPoint = "GetSalesOrderNew";

    var url = "/SalesOrder/SalesOrder";

    var reqdata = {
        method_name: Method_Name,
        dealer_id: "",
        sales_area: salesarea,
        formattedStartDate: formattedStartDate,
        formattedEndDate: formattedEndDate,
        //   "search_period": dateRange,
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

            var res_output = JSON.parse(res);

            if (res_output.length == 0) {
                Hide_Loader();
                Show_Error_Toastr("Data not found.");

                //   $("#btn_Search").prop('disabled', false);
                return;
            }
            // Fill data in table
            var TableHTML = "";

            $.each(res_output, function (data, value) {
                var Dealername = "";

                for (let i = 0; i < Dealerlist.length; i++) {
                    if (Dealerlist[i].item_id == value.soldtoparty) {
                        Dealername = Dealerlist[i].item_value;
                    }
                }

                TableHTML += "<tr>";
                TableHTML += "<td style='width: 20px;'>" + (data + 1) + "</td>";
                TableHTML += "<td>" + value.SalesOrder + "</td>";

                TableHTML += "<td>" + value.CreationDate + "</td>";
                TableHTML += "<td>" + Dealername + "</td>";

                // TableHTML += "<td>" + value.TotalNetAmount + "</td>";
                TableHTML += "<td>" + value.TransactionCurrency + "</td>";
                TableHTML += "<td>" + value.OverallSDProcessStatus + "</td>";
                // if (EditFlag == 0) {
                TableHTML +=
                    "<td class='text-right' style='width: 80px; padding:8px 5px 8px 5px;'>";
                TableHTML +=
                    '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowEditEntry(\'Edit\',\'' +
                    value.SalesOrder +
                    "', '" +
                    value.CreationDate +
                    "', '" +
                    value.PurchaseOrderByCustomer +
                    "', '" +
                    value.SalesGroup +
                    "', '" +
                    value.SalesArea +
                    "', '" +
                    value.soldtoparty +
                    "', '" +
                    value.OverallSDProcessStatus +
                    "')\">";
                TableHTML += '<i class="fa fa-pencil"></i>';
                TableHTML += "</a>";

                TableHTML +=
                    '| <a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowPDFEntry(\'' +
                    value.SalesOrder +
                    '\')"><i class="fa fa-file-pdf-o"></i></a>';

                TableHTML += "</td>";
                TableHTML += "</tr>";
            });

            $("#tableData").html(TableHTML);
            SetDataTable("tableSearch", [6], "Sales Order");
            $("#btn_Search").prop("disabled", false);

            Hide_Loader();
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description,
            );
            $("#btn_Search").prop("disabled", false);
        },
    });
    $("#btn_Search").prop("disabled", false);
    return;
}

function SaveEntryItemDetails() {
    $("#btn_SaveItemDetails").prop("disabled", false);
    var Action = $("#lblItemDetailsAction").html();

    var RequestedQuantityUnit = $("#txtModalUOM").val();

    if (
        RequestedQuantityUnit == "" ||
        RequestedQuantityUnit == null ||
        RequestedQuantityUnit == undefined
    ) {
        $("#txtModalUOM").addClass("is-invalid state-invalid");
        return;
    }

    if (Action == "Add") {
        var SalesOrder_Id = $("#lblEntryId").html();
        if (
            SalesOrder_Id == "" ||
            SalesOrder_Id == null ||
            SalesOrder_Id == undefined
        ) {
            // var tDate = new Date();
            // var date = new Date(tDate);
            var ItemCode = $("#ddlEntryItemCode").val();
            var ItemRate = $("#txtModalRate").val();
            var Quantity = $("#txtEntryQuantity").val();
            var IsValid = 1;
            if (ItemCode == "" || ItemCode == null || ItemCode == undefined) {
                $("#ddlEntryItemCode").addClass("is-invalid state-invalid");
                IsValid = 0;
            }
            if (
                Quantity == "" ||
                Quantity == null ||
                Quantity == undefined
                // ||
                // Is_Valid_Float(Quantity)
            ) {
                $("#txtEntryQuantity").addClass("is-invalid state-invalid");
                IsValid = 0;
            }
            if (IsValid == 0) {
                // Show_Error_Toastr("Invalid data. Can't search.");
                return;
            }
            Show_Loader();
            $("#btn_SaveItemDetails").prop("disabled", true);

            var SalesAreaName = $("#ddlEntrySalesAreaName").val();
            var PurchaseOrderByCustomer = $("#txtEntryCustomerReference").val();

            // Split the SalesAreaName string into individual parts
            var parts = SalesAreaName.split(" - ");

            // Assign each part to corresponding variables
            var SalesGroup = parts[0];
            var SalesOffice = parts[1];
            var SalesOrganization = parts[2];
            var DistributionChannel = parts[3];
            var OrganizationDivision = parts[4];

            var ndate = $("#txtEntryOrderDate").val();

            var date = new Date(ndate);

            var tunixTimeStamp = Math.floor(date.getTime());
            var unixTimeStamp = "/Date(" + tunixTimeStamp + ")/";
            var unixTimeStamps = "/Date(" + tunixTimeStamp + "+0000)/";

            var currentDate = new Date(ndate);
            var year = currentDate.getFullYear();
            var month = ("0" + (currentDate.getMonth() + 1)).slice(-2); // Months are 0-based, so add 1
            var day = ("0" + currentDate.getDate()).slice(-2);
            var hours = ("0" + currentDate.getHours()).slice(-2);
            var minutes = ("0" + currentDate.getMinutes()).slice(-2);
            var seconds = ("0" + currentDate.getSeconds()).slice(-2);
            var formattedDate = year + month + day + hours + minutes + seconds;
            var formattedDateSet = "/Date(" + formattedDate + ")/";

            var Dealer_Id = $("#ddlDealerName").val();
            var RequestedQuantityUnit = $("#txtModalUOM").val();

            // var RequestedQuantityUnit = "";
            var RequestedQuantitySAPUnit = "";
            var RequestedQuantityISOUnit = "";
            var OrderQuantityUnit = "";
            var OrderQuantitySAPUnit = "";
            var OrderQuantityISOUnit = "";

            if (RequestedQuantityUnit == "BOX") {
                RequestedQuantityUnit = "BOX";
                RequestedQuantitySAPUnit = "ZBX";
                RequestedQuantityISOUnit = "BX";
                OrderQuantityUnit = "BOX";
                OrderQuantitySAPUnit = "ZBX";
                OrderQuantityISOUnit = "BX";
            }
            if (RequestedQuantityUnit == "CRT") {
                RequestedQuantityUnit = "CRT";
                RequestedQuantitySAPUnit = "KI";
                RequestedQuantityISOUnit = "CR";
                OrderQuantityUnit = "CRT";
                OrderQuantitySAPUnit = "KI";
                OrderQuantityISOUnit = "CR";
            } else {
                RequestedQuantityUnit = RequestedQuantityUnit;
                RequestedQuantitySAPUnit = RequestedQuantityUnit;
                RequestedQuantityISOUnit = RequestedQuantityUnit;
                OrderQuantityUnit = RequestedQuantityUnit;
                OrderQuantitySAPUnit = RequestedQuantityUnit;
                OrderQuantityISOUnit = RequestedQuantityUnit;
            }

            var APIEndPoint = "SaveSalesOrder";
            var Method_Name = "Save";
            var url = "/SalesOrder/SalesOrder";

            var reqdata = {
                method_name: "Create",
                api_end_point: APIEndPoint,
                SalesOrderType: "OR",
                SalesOrganization: SalesOrganization,
                DistributionChannel: DistributionChannel,
                OrganizationDivision: OrganizationDivision,
                SalesGroup: SalesGroup,
                SalesOffice: SalesOffice,
                SalesDistrict: " ",
                SoldToParty: Dealer_Id,
                CreationDate: formattedDateSet,
                CreatedByUser: "CB9980000016",
                LastChangeDate: unixTimeStamp,
                SenderBusinessSystemName: " ",
                ExternalDocumentID: " ",
                LastChangeDateTime: unixTimeStamps,
                PurchaseOrderByCustomer: PurchaseOrderByCustomer,
                PurchaseOrderByShipToParty: " ",
                CustomerPurchaseOrderType: " ",
                SalesOrderDate: unixTimeStamp,
                TotalNetAmount: "",
                OverallDeliveryStatus: "C",
                TotalBlockStatus: " ",
                OverallOrdReltdBillgStatus: " ",
                OverallSDDocReferenceStatus: " ",
                TransactionCurrency: "INR",
                SDDocumentReason: " ",
                PricingDate: unixTimeStamp,
                PriceDetnExchangeRate: "1.00000",
                BillingPlan: " ",
                RequestedDeliveryDate: unixTimeStamp,
                /* ShippingCondition: "01",*/
                CompleteDeliveryIsDefined: false,
                ShippingType: " ",
                HeaderBillingBlockReason: " ",
                DeliveryBlockReason: " ",
                DeliveryDateTypeRule: " ",
                IncotermsClassification: "CFR",
                IncotermsTransferLocation: "",
                IncotermsLocation1: "",
                IncotermsLocation2: " ",
                IncotermsVersion: " ",
                CustomerPriceGroup: " ",
                PriceListType: " ",
                CustomerPaymentTerms: "0001",
                PaymentMethod: " ",
                AssignmentReference: " ",
                ReferenceSDDocument: " ",
                ReferenceSDDocumentCategory: " ",
                AccountingDocExternalReference: " ",
                CustomerAccountAssignmentGroup: "01",
                AccountingExchangeRate: "0.00000",
                CustomerGroup: " ",
                AdditionalCustomerGroup1: " ",
                AdditionalCustomerGroup2: " ",
                AdditionalCustomerGroup3: " ",
                AdditionalCustomerGroup4: " ",
                AdditionalCustomerGroup5: " ",
                SlsDocIsRlvtForProofOfDeliv: false,
                CustomerTaxClassification1: " ",
                CustomerTaxClassification2: " ",
                CustomerTaxClassification3: " ",
                CustomerTaxClassification4: " ",
                CustomerTaxClassification5: " ",
                CustomerTaxClassification6: " ",
                CustomerTaxClassification7: " ",
                CustomerTaxClassification8: " ",
                CustomerTaxClassification9: " ",
                TaxDepartureCountry: " ",
                VATRegistrationCountry: " ",
                SalesOrderApprovalReason: " ",
                SalesDocApprovalStatus: " ",
                OverallSDProcessStatus: "C",
                TotalCreditCheckStatus: "D",
                OverallTotalDeliveryStatus: "C",
                OverallSDDocumentRejectionSts: "a",
                BillingDocumentDate: unixTimeStamp,
                ContractAccount: " ",
                AdditionalValueDays: "0",
                CustomerPurchaseOrderSuplmnt: " ",
                to_Item: [
                    {
                        SalesOrderItem: "10",
                        Material: ItemCode,
                        PricingDate: unixTimeStamp,
                        RequestedQuantity: Quantity,
                        RequestedQuantityUnit: RequestedQuantityUnit,
                        RequestedQuantitySAPUnit: RequestedQuantitySAPUnit,
                        RequestedQuantityISOUnit: RequestedQuantityISOUnit,
                        OrderQuantityUnit: OrderQuantityUnit,
                        OrderQuantitySAPUnit: OrderQuantitySAPUnit,
                        OrderQuantityISOUnit: OrderQuantityISOUnit,
                        ConfdDelivQtyInOrderQtyUnit: Quantity,
                        BillingDocumentDate: unixTimeStamp,
                        DeliveryDateQuantityIsFixed: false,
                        SlsDocIsRlvtForProofOfDeliv: false,
                        to_PricingElement: [
                            {
                                SalesOrderItem: "10",
                                ConditionType: "PPR0",
                                ConditionRateValue: ItemRate,
                            },
                        ],
                    },
                ],
            };

            $.ajax({
                type: "POST",
                url: url,
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                data: reqdata,
                success: function (res) {
                    var result = JSON.parse(res);

                    var set_result = JSON.parse(result);
                    if (set_result.code == 1) {
                        Hide_Loader();
                        $("#modelEntryItem")
                            // .modal({
                            //   backdrop: "static",
                            // })
                            .modal("hide");
                        $("#btn_SaveItemDetails").prop("disabled", false);
                        var currentDate = new Date();
                        var formattedDate = currentDate.toISOString().slice(0, 10);

                        ShowEditEntry(
                            "Edit",
                            set_result.salesOrder,
                            $("#txtEntryOrderDate").val(),
                            $("#txtEntryCustomerReference").val(),
                            SalesGroup,
                            SalesAreaName,
                            Dealer_Id,
                            "",
                        );
                    } else {
                        Hide_Loader();
                        $("#modelEntryItem")
                            // .modal({
                            //   backdrop: "static",
                            // })
                            .modal("hide");
                        $("#btn_SaveItemDetails").prop("disabled", false);
                        Show_Error_Toastr("Error :" + set_result.salesOrder);
                    }
                },
                error: function () {
                    Hide_Loader();
                    $("#modelEntryItem")
                        // .modal({
                        //   backdrop: "static",
                        // })
                        .modal("hide");
                    $("#btn_SaveItemDetails").prop("disabled", false);
                    Show_Error_Toastr("Error : Sales Order details not found");
                },
            });
        } else {
            var SalesAreaName = $("#ddlEntrySalesAreaName").val();
            var PurchaseOrderByCustomer = $("#txtEntryCustomerReference").val();

            // Split the SalesAreaName string into individual parts
            var parts = SalesAreaName.split(" - ");

            // Assign each part to corresponding variables
            var SalesGroup = parts[0];
            var SalesOffice = parts[1];
            var SalesOrganization = parts[2];
            var DistributionChannel = parts[3];
            var OrganizationDivision = parts[4];

            var date = new Date();
            var tunixTimeStamp = Math.floor(date.getTime());
            var unixTimeStamp = "/Date(" + tunixTimeStamp + ")/";
            var unixTimeStamps = "/Date(" + tunixTimeStamp + "+0000)/";

            var currentDate = new Date();
            var year = currentDate.getFullYear();
            var month = ("0" + (currentDate.getMonth() + 1)).slice(-2); // Months are 0-based, so add 1
            var day = ("0" + currentDate.getDate()).slice(-2);
            var hours = ("0" + currentDate.getHours()).slice(-2);
            var minutes = ("0" + currentDate.getMinutes()).slice(-2);
            var seconds = ("0" + currentDate.getSeconds()).slice(-2);
            var formattedDate = year + month + day + hours + minutes + seconds;
            var formattedDateSet = "/Date(" + formattedDate + ")/";

            var Dealer_Id = $("#ddlSearchDealerName").val();
            var SalesOrder_Id = $("#lblEntryId").html();

            var Dealer_Id = $("#ddlSearchDealerName").val();
            var RequestedQuantityUnit = $("#txtModalUOM").val();

            var RequestedQuantitySAPUnit = "";
            var RequestedQuantityISOUnit = "";
            var OrderQuantityUnit = "";
            var OrderQuantitySAPUnit = "";
            var OrderQuantityISOUnit = "";

            if (RequestedQuantityUnit == "BOX") {
                RequestedQuantityUnit = "BOX";
                RequestedQuantitySAPUnit = "ZBX";
                RequestedQuantityISOUnit = "BX";
                OrderQuantityUnit = "BOX";
                OrderQuantitySAPUnit = "ZBX";
                OrderQuantityISOUnit = "BX";
            }
            if (RequestedQuantityUnit == "CRT") {
                RequestedQuantityUnit = "CRT";
                RequestedQuantitySAPUnit = "KI";
                RequestedQuantityISOUnit = "CR";
                OrderQuantityUnit = "CRT";
                OrderQuantitySAPUnit = "KI";
                OrderQuantityISOUnit = "CR";
            } else {
                RequestedQuantityUnit = RequestedQuantityUnit;
                RequestedQuantitySAPUnit = RequestedQuantityUnit;
                RequestedQuantityISOUnit = RequestedQuantityUnit;
                OrderQuantityUnit = RequestedQuantityUnit;
                OrderQuantitySAPUnit = RequestedQuantityUnit;
                OrderQuantityISOUnit = RequestedQuantityUnit;
            }

            var APIEndPoint = "SaveSalesOrderItemsNew";
            var Method_Name = "Save";
            var url = "/SalesOrder/SalesOrder";
            var ItemCode = $("#ddlEntryItemCode").val();
            var ItemRate = $("#txtModalRate").val();
            var Quantity = $("#txtEntryQuantity").val();
            var IsValid = 1;
            if (ItemCode == "" || ItemCode == null || ItemCode == undefined) {
                $("#ddlEntryItemCode").addClass("is-invalid state-invalid");
                IsValid = 0;
            }
            if (
                Quantity == "" ||
                Quantity == null ||
                Quantity == undefined
                // ||
                // Is_Valid_Float(Quantity)
            ) {
                $("#txtEntryQuantity").addClass("is-invalid state-invalid");
                IsValid = 0;
            }
            if (IsValid == 0) {
                // Show_Error_Toastr("Invalid data. Can't search.");
                return;
            }
            Show_Loader();
            $("#btn_SaveItemDetails").prop("disabled", true);

            var itemcount = $("#lblItemCount").html();
            if (itemcount == "") {
                itemcount = 0;
            }

            var Dealer_code = $("#ddlDealerName").val();

            var reqdata = {
                // method_name: "Update",
                method_name: "Create",
                salesorder_id: SalesOrder_Id,
                api_end_point: APIEndPoint,
                SalesOrderType: "OR",
                SalesOrganization: SalesOrganization,
                DistributionChannel: DistributionChannel,
                OrganizationDivision: OrganizationDivision,
                SalesGroup: SalesGroup,
                SalesOffice: SalesOffice,
                SalesDistrict: " ",
                SoldToParty: "",
                CreationDate: formattedDateSet,
                CreatedByUser: "CB9980000016",
                LastChangeDate: unixTimeStamp,
                SenderBusinessSystemName: " ",
                ExternalDocumentID: " ",
                LastChangeDateTime: unixTimeStamps,
                PurchaseOrderByCustomer: PurchaseOrderByCustomer,
                PurchaseOrderByShipToParty: " ",
                CustomerPurchaseOrderType: " ",
                SalesOrderDate: unixTimeStamp,
                TotalNetAmount: "",
                OverallDeliveryStatus: "C",
                TotalBlockStatus: " ",
                OverallOrdReltdBillgStatus: " ",
                OverallSDDocReferenceStatus: " ",
                TransactionCurrency: "INR",
                SDDocumentReason: " ",
                PricingDate: unixTimeStamp,
                PriceDetnExchangeRate: "1.00000",
                BillingPlan: " ",
                RequestedDeliveryDate: unixTimeStamp,
                /* ShippingCondition: "01",*/
                CompleteDeliveryIsDefined: false,
                ShippingType: " ",
                HeaderBillingBlockReason: " ",
                DeliveryBlockReason: " ",
                DeliveryDateTypeRule: " ",
                IncotermsClassification: "CFR",
                IncotermsTransferLocation: "",
                IncotermsLocation1: "",
                IncotermsLocation2: " ",
                IncotermsVersion: " ",
                CustomerPriceGroup: " ",
                PriceListType: " ",
                CustomerPaymentTerms: "0001",
                PaymentMethod: " ",
                AssignmentReference: " ",
                ReferenceSDDocument: " ",
                ReferenceSDDocumentCategory: " ",
                AccountingDocExternalReference: " ",
                CustomerAccountAssignmentGroup: "01",
                AccountingExchangeRate: "0.00000",
                CustomerGroup: " ",
                AdditionalCustomerGroup1: " ",
                AdditionalCustomerGroup2: " ",
                AdditionalCustomerGroup3: " ",
                AdditionalCustomerGroup4: " ",
                AdditionalCustomerGroup5: " ",
                SlsDocIsRlvtForProofOfDeliv: false,
                CustomerTaxClassification1: " ",
                CustomerTaxClassification2: " ",
                CustomerTaxClassification3: " ",
                CustomerTaxClassification4: " ",
                CustomerTaxClassification5: " ",
                CustomerTaxClassification6: " ",
                CustomerTaxClassification7: " ",
                CustomerTaxClassification8: " ",
                CustomerTaxClassification9: " ",
                TaxDepartureCountry: " ",
                VATRegistrationCountry: " ",
                SalesOrderApprovalReason: " ",
                SalesDocApprovalStatus: " ",
                OverallSDProcessStatus: "C",
                TotalCreditCheckStatus: "D",
                OverallTotalDeliveryStatus: "C",
                OverallSDDocumentRejectionSts: "a",
                BillingDocumentDate: unixTimeStamp,
                ContractAccount: " ",
                AdditionalValueDays: "0",
                CustomerPurchaseOrderSuplmnt: " ",
                to_Item: [
                    {
                        SalesOrderItem: parseInt(itemcount) + 10,
                        Material: ItemCode,
                        PricingDate: unixTimeStamp,
                        RequestedQuantity: Quantity,
                        RequestedQuantityUnit: RequestedQuantityUnit,
                        RequestedQuantitySAPUnit: RequestedQuantitySAPUnit,
                        RequestedQuantityISOUnit: RequestedQuantityISOUnit,
                        OrderQuantityUnit: OrderQuantityUnit,
                        OrderQuantitySAPUnit: OrderQuantitySAPUnit,
                        OrderQuantityISOUnit: OrderQuantityISOUnit,
                        ConfdDelivQtyInOrderQtyUnit: Quantity,
                        BillingDocumentDate: unixTimeStamp,
                        DeliveryDateQuantityIsFixed: false,
                        SlsDocIsRlvtForProofOfDeliv: false,
                        to_PricingElement: [
                            {
                                SalesOrderItem: parseInt(itemcount) + 10,
                                ConditionType: "PPR0",
                                ConditionRateValue: ItemRate,
                            },
                        ],
                    },
                ],
            };

            $.ajax({
                type: "POST",
                url: url,
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                data: reqdata,
                success: function (res) {
                    var result = JSON.parse(res);

                    var set_result = JSON.parse(result);
                    if (set_result.code == 1) {
                        getalldealers();

                        Hide_Loader();
                        $("#modelEntryItem")
                            // .modal({
                            //   backdrop: "static",
                            // })
                            .modal("hide");
                        $("#btn_SaveItemDetails").prop("disabled", false);
                        var currentDate = new Date();
                        var formattedDate = currentDate.toISOString().slice(0, 10);

                        ShowEditEntry(
                            "Edit",
                            set_result.salesOrder,
                            $("#txtEntryOrderDate").val(),
                            $("#txtEntryCustomerReference").val(),
                            SalesGroup,
                            SalesAreaName,
                            Dealer_code,
                            "",
                        );
                    } else {
                        Hide_Loader();
                        $("#modelEntryItem")
                            // .modal({
                            //   backdrop: "static",
                            // })
                            .modal("hide");
                        $("#btn_SaveItemDetails").prop("disabled", false);
                        Show_Error_Toastr("Error :" + set_result.salesOrder);
                        ShowSalesOrderItemTable(SalesOrder_Id);
                    }
                },
                error: function () {
                    Hide_Loader();
                    $("#modelEntryItem")
                        // .modal({
                        //   backdrop: "static",
                        // })
                        .modal("hide");
                    $("#btn_SaveItemDetails").prop("disabled", false);
                    Show_Error_Toastr("Error : Sales Order details not found");
                },
            });
        }
    }

    if (Action == "Edit") {
        var count = $("#lblItemDetailsEntryId").html();
        var SalesAreaName = $("#ddlEntrySalesAreaName").val();
        var PurchaseOrderByCustomer = $("#txtEntryCustomerReference").val();

        // Split the SalesAreaName string into individual parts
        var parts = SalesAreaName.split(" - ");

        // Assign each part to corresponding variables
        var SalesGroup = parts[0];
        var SalesOffice = parts[1];
        var SalesOrganization = parts[2];
        var DistributionChannel = parts[3];
        var OrganizationDivision = parts[4];

        var date = new Date();
        var tunixTimeStamp = Math.floor(date.getTime());
        var unixTimeStamp = "/Date(" + tunixTimeStamp + ")/";
        var unixTimeStamps = "/Date(" + tunixTimeStamp + "+0000)/";

        var currentDate = new Date();
        var year = currentDate.getFullYear();
        var month = ("0" + (currentDate.getMonth() + 1)).slice(-2); // Months are 0-based, so add 1
        var day = ("0" + currentDate.getDate()).slice(-2);
        var hours = ("0" + currentDate.getHours()).slice(-2);
        var minutes = ("0" + currentDate.getMinutes()).slice(-2);
        var seconds = ("0" + currentDate.getSeconds()).slice(-2);
        var formattedDate = year + month + day + hours + minutes + seconds;
        var formattedDateSet = "/Date(" + formattedDate + ")/";

        var Dealer_Id = $("#ddlSearchDealerName").val();
        var SalesOrder_Id = $("#lblEntryId").html();

        var Dealer_Id = $("#ddlSearchDealerName").val();
        var RequestedQuantityUnit = $("#txtModalUOM").val();

        var RequestedQuantitySAPUnit = "";
        var RequestedQuantityISOUnit = "";
        var OrderQuantityUnit = "";
        var OrderQuantitySAPUnit = "";
        var OrderQuantityISOUnit = "";

        if (RequestedQuantityUnit == "BOX") {
            RequestedQuantityUnit = "BOX";
            RequestedQuantitySAPUnit = "ZBX";
            RequestedQuantityISOUnit = "BX";
            OrderQuantityUnit = "BOX";
            OrderQuantitySAPUnit = "ZBX";
            OrderQuantityISOUnit = "BX";
        }
        if (RequestedQuantityUnit == "CRT") {
            RequestedQuantityUnit = "CRT";
            RequestedQuantitySAPUnit = "KI";
            RequestedQuantityISOUnit = "CR";
            OrderQuantityUnit = "CRT";
            OrderQuantitySAPUnit = "KI";
            OrderQuantityISOUnit = "CR";
        } else {
            RequestedQuantityUnit = RequestedQuantityUnit;
            RequestedQuantitySAPUnit = RequestedQuantityUnit;
            RequestedQuantityISOUnit = RequestedQuantityUnit;
            OrderQuantityUnit = RequestedQuantityUnit;
            OrderQuantitySAPUnit = RequestedQuantityUnit;
            OrderQuantityISOUnit = RequestedQuantityUnit;
        }

        var APIEndPoint = "SaveSalesOrderItemsNew";
        var Method_Name = "Save";
        var url = "/SalesOrder/SalesOrder";
        var ItemCode = $("#ddlEntryItemCode").val();
        var ItemRate = $("#txtModalRate").val();
        var Quantity = $("#txtEntryQuantity").val();
        var IsValid = 1;
        if (ItemCode == "" || ItemCode == null || ItemCode == undefined) {
            $("#ddlEntryItemCode").addClass("is-invalid state-invalid");
            IsValid = 0;
        }
        if (
            Quantity == "" ||
            Quantity == null ||
            Quantity == undefined
            // ||
            // Is_Valid_Float(Quantity)
        ) {
            $("#txtEntryQuantity").addClass("is-invalid state-invalid");
            IsValid = 0;
        }
        if (IsValid == 0) {
            // Show_Error_Toastr("Invalid data. Can't search.");
            return;
        }

        Show_Loader();
        $("#btn_SaveItemDetails").prop("disabled", true);

        if (isNaN(Quantity) || Quantity < 0) {
            Show_Error_Toastr("Please Enter Valid Quantity");
            return;
        }

        var Dealer_Id = $("#ddlDealerName").val();

        var APIEndPoint = "DeleteSalesOrderItemsNew";
        var Method_Name = "Save";
        var url = "/SalesOrder/SalesOrder";
        var SalesOrder_Id = $("#lblEntryId").html();

        var reqdata = {
            method_name: Method_Name,
            api_end_point: APIEndPoint,
            salesorderitem: count,
            salesorder_id: SalesOrder_Id,
        };

        $.ajax({
            type: "POST",
            url: url,
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            data: reqdata,
            success: function (res) {
                var result = JSON.parse(res);
                var set_result = JSON.parse(result);

                if (set_result.code == 1) {
                    var APIEndPointitem = "SaveSalesOrderItemsNew";

                    var reqdata = {
                        // method_name: "Update",
                        method_name: "Create",
                        salesorder_id: SalesOrder_Id,
                        api_end_point: APIEndPointitem,
                        SalesOrderType: "OR",
                        SalesOrganization: SalesOrganization,
                        DistributionChannel: DistributionChannel,
                        OrganizationDivision: OrganizationDivision,
                        SalesGroup: SalesGroup,
                        SalesOffice: SalesOffice,
                        SalesDistrict: " ",
                        SoldToParty: "",
                        CreationDate: formattedDateSet,
                        CreatedByUser: "CB9980000016",
                        LastChangeDate: unixTimeStamp,
                        SenderBusinessSystemName: " ",
                        ExternalDocumentID: " ",
                        LastChangeDateTime: unixTimeStamps,
                        PurchaseOrderByCustomer: PurchaseOrderByCustomer,
                        PurchaseOrderByShipToParty: " ",
                        CustomerPurchaseOrderType: " ",
                        SalesOrderDate: unixTimeStamp,
                        TotalNetAmount: "",
                        OverallDeliveryStatus: "C",
                        TotalBlockStatus: " ",
                        OverallOrdReltdBillgStatus: " ",
                        OverallSDDocReferenceStatus: " ",
                        TransactionCurrency: "INR",
                        SDDocumentReason: " ",
                        PricingDate: unixTimeStamp,
                        PriceDetnExchangeRate: "1.00000",
                        BillingPlan: " ",
                        RequestedDeliveryDate: unixTimeStamp,
                        /* ShippingCondition: "01",*/
                        CompleteDeliveryIsDefined: false,
                        ShippingType: " ",
                        HeaderBillingBlockReason: " ",
                        DeliveryBlockReason: " ",
                        DeliveryDateTypeRule: " ",
                        IncotermsClassification: "CFR",
                        IncotermsTransferLocation: "",
                        IncotermsLocation1: "",
                        IncotermsLocation2: " ",
                        IncotermsVersion: " ",
                        CustomerPriceGroup: " ",
                        PriceListType: " ",
                        CustomerPaymentTerms: "0001",
                        PaymentMethod: " ",
                        AssignmentReference: " ",
                        ReferenceSDDocument: " ",
                        ReferenceSDDocumentCategory: " ",
                        AccountingDocExternalReference: " ",
                        CustomerAccountAssignmentGroup: "01",
                        AccountingExchangeRate: "0.00000",
                        CustomerGroup: " ",
                        AdditionalCustomerGroup1: " ",
                        AdditionalCustomerGroup2: " ",
                        AdditionalCustomerGroup3: " ",
                        AdditionalCustomerGroup4: " ",
                        AdditionalCustomerGroup5: " ",
                        SlsDocIsRlvtForProofOfDeliv: false,
                        CustomerTaxClassification1: " ",
                        CustomerTaxClassification2: " ",
                        CustomerTaxClassification3: " ",
                        CustomerTaxClassification4: " ",
                        CustomerTaxClassification5: " ",
                        CustomerTaxClassification6: " ",
                        CustomerTaxClassification7: " ",
                        CustomerTaxClassification8: " ",
                        CustomerTaxClassification9: " ",
                        TaxDepartureCountry: " ",
                        VATRegistrationCountry: " ",
                        SalesOrderApprovalReason: " ",
                        SalesDocApprovalStatus: " ",
                        OverallSDProcessStatus: "C",
                        TotalCreditCheckStatus: "D",
                        OverallTotalDeliveryStatus: "C",
                        OverallSDDocumentRejectionSts: "a",
                        BillingDocumentDate: unixTimeStamp,
                        ContractAccount: " ",
                        AdditionalValueDays: "0",
                        CustomerPurchaseOrderSuplmnt: " ",
                        to_Item: [
                            {
                                SalesOrderItem: count,
                                Material: ItemCode,
                                PricingDate: unixTimeStamp,
                                RequestedQuantity: Quantity,
                                RequestedQuantityUnit: RequestedQuantityUnit,
                                RequestedQuantitySAPUnit: RequestedQuantitySAPUnit,
                                RequestedQuantityISOUnit: RequestedQuantityISOUnit,
                                OrderQuantityUnit: OrderQuantityUnit,
                                OrderQuantitySAPUnit: OrderQuantitySAPUnit,
                                OrderQuantityISOUnit: OrderQuantityISOUnit,
                                ConfdDelivQtyInOrderQtyUnit: Quantity,
                                BillingDocumentDate: unixTimeStamp,
                                DeliveryDateQuantityIsFixed: false,
                                SlsDocIsRlvtForProofOfDeliv: false,
                                to_PricingElement: [
                                    {
                                        SalesOrderItem: count,
                                        ConditionType: "PPR0",
                                        ConditionRateValue: ItemRate,
                                    },
                                ],
                            },
                        ],
                    };
                    $.ajax({
                        type: "POST",
                        url: url,
                        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                        data: reqdata,
                        success: function (res) {
                            var result = JSON.parse(res);

                            var set_result = JSON.parse(result);
                            if (set_result.code == 1) {
                                Hide_Loader();
                                $("#modelEntryItem")
                                    // .modal({
                                    //   backdrop: "static",
                                    // })
                                    .modal("hide");
                                $("#btn_SaveItemDetails").prop("disabled", false);
                                var currentDate = new Date();
                                var formattedDate = currentDate.toISOString().slice(0, 10);

                                ShowEditEntry(
                                    "Edit",
                                    set_result.salesOrder,
                                    $("#txtEntryOrderDate").val(),
                                    $("#txtEntryCustomerReference").val(),
                                    SalesGroup,
                                    SalesAreaName,
                                    Dealer_Id,
                                    "",
                                );
                            } else {
                                Hide_Loader();
                                $("#modelEntryItem")
                                    // .modal({
                                    //   backdrop: "static",
                                    // })
                                    .modal("hide");
                                $("#btn_SaveItemDetails").prop("disabled", false);
                                Show_Error_Toastr("Error :" + set_result.salesOrder);
                                ShowSalesOrderItemTable(SalesOrder_Id);
                            }
                        },
                        error: function () {
                            Hide_Loader();
                            $("#modelEntryItem")
                                // .modal({
                                //   backdrop: "static",
                                // })
                                .modal("hide");
                            $("#btn_SaveItemDetails").prop("disabled", false);
                            Show_Error_Toastr("Error : Sales Order details not found");
                        },
                    });
                }
            },
            error: function () {
                Hide_Loader();

                Show_Error_Toastr("Error : Sales Order Item details not delete");
            },
        });
    }
}

/*      ------      ------      ------      ------      ------      -----       -----       -----       */

function chnageSalesArea() { }

function ChangeDealer() {
    var delaerId = $("#ddlDealerName").val();

    GetMaster(
        "ddlEntrySalesAreaName",
        "Select Sales Area Name",
        "GetSalesAreaName",
        "",
        delaerId,
    );
}

function ShowAddEntry() {
    //var Dealer_Id = $("#ddlSearchDealerName").val();
    //if (Dealer_Id == "" || Dealer_Id == null || Dealer_Id == undefined) {
    //  $("#ddlSearchDealerName").addClass("is-invalid state-invalid");
    //  //return;
    //}
    //var SalesArea = $("#lblSalesArea").html();
    //if (SalesArea == "" || SalesArea == null || SalesArea == undefined) {
    //  Show_Error_Toastr("Error : Sales Area is not Maintained in this Dealer.");
    //  //return;
    //}

    var SalesArea = $("#ddlSearchSalesArea").val();

    if (SalesArea == "" || SalesArea == null || SalesArea == undefined) {
        $("#ddlSearchSalesArea").addClass("is-invalid state-invalid");
        return;
    }

    ShowContentDiv("SalesOrder", "SalesOrderEdit", "", function () {
        var currentDate = new Date();
        var formattedDate = currentDate.toISOString().slice(0, 10);
        $("#txtEntryOrderDate").val(formattedDate);
        $("#ddlEntryItemCode").select2();
        $("#btn_Save").hide();
        $("#ddlEntrySalesArea").select2();
        $("#ddlEntrySalesAreaName").select2();

        $("#lblEntryId").html(""); //No id first
        $("#lblAction").html("Add");

        $("#divFooterDelete").hide();

        GetMaster(
            "ddlEntrySalesArea",
            "Select Sales Group",
            "GetSalesAreaforSaleOrder",
            SalesArea,
            "",
        );

        $("#ddlDealerName").select2();

        //GetMaster(
        //    "ddlDealerName",
        //    "Select Dealer",
        //    "GetAllDealers",
        //    "",
        //    ""
        //);

        GetMaster(
            "ddlDealerName",
            "Select Dealer",
            "getDealersalesgroup",
            "",
            SalesArea,
        );

        var delaerId = $("#ddlDealerName").val();

        GetMaster(
            "ddlEntrySalesAreaName",
            "Select Sales Area Name",
            "GetSalesAreaName",
            "",
            delaerId,
        );

        $("#ddlEntrySalesArea").prop("disabled", true);
        // getproducts();
    });
}
function GetItemDetailsList() {
    var action = $("#lblAction").html();
    if (action == "Edit") {
        var SalesOrder_Id = $("#lblEntryId").html();
        ShowSalesOrderItemTable(SalesOrder_Id);
    }
}

function ShowEditEntry(
    action,
    SalesOrder_Id,
    CreationDate,
    PurchaseOrderByCustomer,
    SalesGroup,
    SalesArea,
    DealerCode,
    Status,
) {
    orderstatus = Status;

    ShowContentDiv("SalesOrder", "SalesOrderEdit", "", function () {
        $("#ddlEntrySalesArea").select2();
        $("#ddlEntryItemCode").select2();
        $("#ddlDealerName").select2();

        if (action == "ADD") {
            $("#lblAction").html("ADD");
            var currentDate = new Date();
            var formattedDate = currentDate.toISOString().slice(0, 10);

            $("#txtEntryOrderDate").val(formattedDate);
            $("#btn_Save").hide();

            GetMaster("ddlDealerName", "Select Dealer", "GetAllDealers", "", "");
        }

        if (Status == "Completed") {
            $("#ddlEntrySalesArea").prop("disabled", true);
            $("#ddlEntrySalesAreaName").prop("disabled", true);
            $("#ddlDealerName").prop("disabled", true);
            $("#btn_Save").hide();
            $("#btn_itemsave").hide();

            $("#txtEntryOrderNumber").val(SalesOrder_Id);
            $("#txtEntryCustomerReference").val(PurchaseOrderByCustomer);

            const date = new Date(CreationDate);

            const currentDate = new Date(date);

            currentDate.setDate(currentDate.getDate() + 1);

            const formattedDatez = currentDate.toString();

            const formattedDate = new Date(formattedDatez)
                .toISOString()
                .split("T")[0];

            $("#txtEntryOrderDate").val(formattedDate);

            for (let i = 0; i < Dealerlist.length; i++) {
                if (Dealerlist[i].item_id == DealerCode) {
                    GetMaster(
                        "ddlDealerName",
                        "Select Dealer",
                        "GetAllDealers",
                        DealerCode,
                        "",
                    );
                }
            }

            GetMaster(
                "ddlEntrySalesArea",
                "Select Sales Group",
                "GetSalesAreaforSaleOrder",
                SalesGroup,
                "",
            );

            $("#ddlEntrySalesArea").prop("disabled", true);

            $("#ddlEntrySalesAreaName").select2();

            var delaerId = $("#ddlDealerName").val();

            GetMaster(
                "ddlEntrySalesAreaName",
                "Select Sales Area Name",
                "GetSalesAreaName",
                SalesArea,
                DealerCode,
            );
            ShowSalesOrderItemTable(SalesOrder_Id);
            // GetOneSalesOrderHeader(SalesOrder_Id);
        }

        if (action == "Edit" && Status != "Completed") {
            $("#btn_Save").show();
            $("#lblAction").html("Edit");
            $("#lblEntryId").html(SalesOrder_Id); //for updating the record
            $("#txtEntryOrderNumber").val(SalesOrder_Id);

            const date = new Date(CreationDate);

            const currentDate = new Date(date);

            currentDate.setDate(currentDate.getDate() + 1);

            const formattedDatez = currentDate.toString();

            const formattedDate = new Date(formattedDatez)
                .toISOString()
                .split("T")[0];

            $("#txtEntryOrderDate").val(formattedDate);

            $("#txtEntryCustomerReference").val(PurchaseOrderByCustomer);
            $("#ddlEntrySalesArea").select2();
            var SalesAreaName = $("#lblSalesArea").html();
            $("#ddlDealerName").select2();
            //GetMaster(
            //  "ddlEntrySalesArea",
            //  "Select Sales Group",
            //  "GetSalesAreaCode",
            //  SalesGroup,
            //  SalesAreaName
            //  );

            $("#ddlEntrySalesArea").prop("disabled", true);
            $("#ddlEntrySalesAreaName").prop("disabled", true);
            $("#ddlDealerName").prop("disabled", true);

            GetMaster(
                "ddlDealerName",
                "Select Dealer",
                "GetAllDealers",
                DealerCode,
                "",
            );

            for (let i = 0; i < Dealerlist.length; i++) {
                if (Dealerlist[i].item_id == DealerCode) {
                    GetMaster(
                        "ddlDealerName",
                        "Select Dealer",
                        "GetAllDealers",
                        DealerCode,
                        "",
                    );
                }
            }

            GetMaster(
                "ddlEntrySalesArea",
                "Select Sales Group",
                "GetSalesAreaforSaleOrder",
                SalesGroup,
                "",
            );

            $("#ddlEntrySalesArea").prop("disabled", true);

            $("#ddlEntrySalesAreaName").select2();

            var delaerId = $("#ddlDealerName").val();

            GetMaster(
                "ddlEntrySalesAreaName",
                "Select Sales Area Name",
                "GetSalesAreaName",
                SalesArea,
                DealerCode,
            );
            ShowSalesOrderItemTable(SalesOrder_Id);
            // GetOneSalesOrderHeader(SalesOrder_Id);
        }
        // getproducts();
        $("#divFooterDelete").show();
    });
}

function CloseEntry() {
    GetSearchList();
    HideContentDiv();
}

function SaveEntry() {
    var SalesArea = $("#ddlEntrySalesArea").val();
    var SalesAreaName = $("#ddlEntrySalesAreaName").val();
    var IsValid = 1;
    if (SalesArea == "" || SalesArea == null || SalesArea == undefined) {
        $("#ddlEntrySalesArea").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (
        SalesAreaName == "" ||
        SalesAreaName == null ||
        SalesAreaName == undefined
    ) {
        $("#ddlEntrySalesAreaName").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (IsValid == 0) {
        // Show_Error_Toastr("Invalid data. Can't search.");
        return;
    }
    Show_Loader();
    var PurchaseOrderByCustomer = $("#txtEntryCustomerReference").val();
    // Split the SalesAreaName string into individual parts
    var parts = SalesAreaName.split(" - ");

    // Assign each part to corresponding variables
    var SalesGroup = parts[0];
    var SalesOffice = parts[1];
    var SalesOrganization = parts[2];
    var DistributionChannel = parts[3];
    var OrganizationDivision = parts[4];

    var ndate = $("#txtEntryOrderDate").val();

    var date = new Date(ndate);
    var tunixTimeStamp = Math.floor(date.getTime());
    var unixTimeStamp = "/Date(" + tunixTimeStamp + ")/";
    var unixTimeStamps = "/Date(" + tunixTimeStamp + "+0000)/";

    var currentDate = new Date();
    var year = currentDate.getFullYear();
    var month = ("0" + (currentDate.getMonth() + 1)).slice(-2); // Months are 0-based, so add 1
    var day = ("0" + currentDate.getDate()).slice(-2);
    var hours = ("0" + currentDate.getHours()).slice(-2);
    var minutes = ("0" + currentDate.getMinutes()).slice(-2);
    var seconds = ("0" + currentDate.getSeconds()).slice(-2);
    var formattedDate = year + month + day + hours + minutes + seconds;
    var formattedDateSet = "/Date(" + formattedDate + ")/";
    var SalesOrder_Id = $("#lblEntryId").html();
    var Dealer_Id = $("#ddlDealerName").val();

    var APIEndPoint = "UpdateSalesOrderNew";
    var Method_Name = "Save";

    var url = "/SalesOrder/SalesOrder";

    var reqdata = {
        method_name: Method_Name,
        salesorder_id: SalesOrder_Id,
        api_end_point: APIEndPoint,
        SalesOrderType: "OR",
        SalesOrganization: SalesOrganization,
        DistributionChannel: DistributionChannel,
        OrganizationDivision: OrganizationDivision,
        SalesGroup: SalesGroup,
        SalesOffice: SalesOffice,
        SalesDistrict: " ",
        SoldToParty: Dealer_Id,
        CreationDate: formattedDateSet,
        CreatedByUser: "CB9980000016",
        LastChangeDate: unixTimeStamp,
        SenderBusinessSystemName: " ",
        ExternalDocumentID: " ",
        LastChangeDateTime: unixTimeStamps,
        PurchaseOrderByCustomer: PurchaseOrderByCustomer,
        PurchaseOrderByShipToParty: " ",
        CustomerPurchaseOrderType: " ",
        SalesOrderDate: unixTimeStamp,
        TotalNetAmount: "",
        OverallDeliveryStatus: "C",
        TotalBlockStatus: " ",
        OverallOrdReltdBillgStatus: " ",
        OverallSDDocReferenceStatus: " ",
        TransactionCurrency: "INR",
        SDDocumentReason: " ",
        PricingDate: unixTimeStamp,
        PriceDetnExchangeRate: "1.00000",
        BillingPlan: " ",
        RequestedDeliveryDate: unixTimeStamp,
        /*ShippingCondition: "01",*/
        CompleteDeliveryIsDefined: false,
        ShippingType: " ",
        HeaderBillingBlockReason: " ",
        DeliveryBlockReason: " ",
        DeliveryDateTypeRule: " ",
        IncotermsClassification: "CFR",
        IncotermsTransferLocation: "",
        IncotermsLocation1: "",
        IncotermsLocation2: " ",
        IncotermsVersion: " ",
        CustomerPriceGroup: " ",
        PriceListType: " ",
        CustomerPaymentTerms: "0001",
        PaymentMethod: " ",
        AssignmentReference: " ",
        ReferenceSDDocument: " ",
        ReferenceSDDocumentCategory: " ",
        AccountingDocExternalReference: " ",
        CustomerAccountAssignmentGroup: "01",
        AccountingExchangeRate: "0.00000",
        CustomerGroup: " ",
        AdditionalCustomerGroup1: " ",
        AdditionalCustomerGroup2: " ",
        AdditionalCustomerGroup3: " ",
        AdditionalCustomerGroup4: " ",
        AdditionalCustomerGroup5: " ",
        SlsDocIsRlvtForProofOfDeliv: false,
        CustomerTaxClassification1: " ",
        CustomerTaxClassification2: " ",
        CustomerTaxClassification3: " ",
        CustomerTaxClassification4: " ",
        CustomerTaxClassification5: " ",
        CustomerTaxClassification6: " ",
        CustomerTaxClassification7: " ",
        CustomerTaxClassification8: " ",
        CustomerTaxClassification9: " ",
        TaxDepartureCountry: " ",
        VATRegistrationCountry: " ",
        SalesOrderApprovalReason: " ",
        SalesDocApprovalStatus: " ",
        OverallSDProcessStatus: "C",
        TotalCreditCheckStatus: "D",
        OverallTotalDeliveryStatus: "C",
        OverallSDDocumentRejectionSts: "a",
        BillingDocumentDate: unixTimeStamp,
        ContractAccount: " ",
        AdditionalValueDays: "0",
        CustomerPurchaseOrderSuplmnt: " ",
        to_Item: [
            {
                SalesOrderItem: "",
                Material: "",
                PricingDate: "",
                RequestedQuantity: "",
                ConfdDelivQtyInOrderQtyUnit: "",
                BillingDocumentDate: "",
                DeliveryDateQuantityIsFixed: false,
                SlsDocIsRlvtForProofOfDeliv: false,
                to_PricingElement: [
                    {
                        SalesOrderItem: "",
                        ConditionType: "PPR0",
                        ConditionRateValue: "",
                    },
                ],
            },
        ],
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (res) {
            var result = JSON.parse(res);

            var set_result = JSON.parse(result);
            if (set_result.code == 1) {
                Hide_Loader();
                ShowEditEntry(
                    "Edit",
                    set_result.salesOrder,
                    $("#txtEntryOrderDate").val(),
                    $("#txtEntryCustomerReference").val(),
                    SalesGroup,
                    SalesAreaName,
                    Dealer_Id,
                    "",
                );
            } else {
                Hide_Loader();
                Show_Error_Toastr("Error :" + set_result.salesOrder);
            }
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr("Error : Sales Order details not saved");
        },
    });
}

function SaveDeleteEntryRouteItem(SalesOrderItem) {
    var Dealer_Id = $("#ddlDealerName").val();

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
                // SaveDeleteEntry();
                Show_Loader();
                var APIEndPoint = "DeleteSalesOrderItemsNew";
                var Method_Name = "Save";
                var url = "/SalesOrder/SalesOrder";
                var SalesOrder_Id = $("#lblEntryId").html();
                var reqdata = {
                    method_name: Method_Name,
                    api_end_point: APIEndPoint,
                    salesorderitem: SalesOrderItem,
                    salesorder_id: SalesOrder_Id,
                };
                $.ajax({
                    type: "POST",
                    url: url,
                    contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                    data: reqdata,
                    success: function (res) {
                        Hide_Loader();
                        var result = JSON.parse(res);

                        var set_result = JSON.parse(result);
                        if (set_result.code == 1) {
                            Hide_Loader();

                            ShowEditEntry(
                                "Edit",
                                set_result.salesOrder,
                                $("#txtEntryOrderDate").val(),
                                $("#txtEntryCustomerReference").val(),
                                $("#ddlEntrySalesArea").val(),
                                $("#ddlEntrySalesAreaName").val(),
                                Dealer_Id,
                                "",
                            );
                        } else {
                            Hide_Loader();

                            Show_Error_Toastr("Error :" + set_result.salesOrder);
                        }
                    },
                    error: function () {
                        Hide_Loader();

                        Show_Error_Toastr("Error : Sales Order Item details not delete");
                    },
                });
            }
        },
    );
}

function ShowSalesOrderItemTable(SalesOrder) {
    var setTotalNetAmount;
    var APIEndPoint_1 = "GetOneSalesOrderHeader";
    var Method_Name_1 = "Get_One";
    var url_1 = "/SalesOrder/SalesOrder";
    var reqdata_1 = {
        method_name: Method_Name_1,
        salesorder_id: SalesOrder,
        api_end_point: APIEndPoint_1,
    };
    Show_Loader();

    $.ajax({
        type: "POST",
        url: url_1,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata_1,
        success: function (result) {
            var res = JSON.parse(result);

            var res_output = JSON.parse(res);

            if (res_output.length == 0) {
                Hide_Loader();
                Show_Error_Toastr("Data not found.");
                setTotalNetAmount = 0;
            }
            setTotalNetAmount = res_output[0].TotalNetAmount;

            ClearDataTable("tableItemDetailsList");
            var APIEndPoint = "GetOneSalesOrderNew";
            var Method_Name = "Get_One";
            var url = "/SalesOrder/SalesOrder";
            var reqdata = {
                method_name: Method_Name,
                salesorder_id: SalesOrder,
                api_end_point: APIEndPoint,
            };
            $.ajax({
                type: "POST",
                url: url,
                contentType: "application/x-www-form-urlencoded; charset=UTF-8",
                data: reqdata,
                success: function (result) {
                    var res = JSON.parse(result);
                    var res_output = JSON.parse(res);

                    // Fill data in table
                    $("#lblItemCount").html("");
                    var TableHTML = "";
                    var Row_No = 0;
                    var itemCount = res_output.length;

                    var productitemcount = 0;

                    for (var i = 0; i < res_output.length; i++) {
                        if (productitemcount < parseInt(res_output[i].SalesOrderItem)) {
                            $("#lblItemCount").html(parseInt(res_output[i].SalesOrderItem));
                        }
                    }

                    //$("#lblItemCount").html(itemCount + 1);

                    var toatalQuantity = 0;
                    var totalAmount = 0;

                    var totalNetAmount = 0;

                    $.each(res_output, function (data, value) {
                        var flag = false;

                        if (
                            value.Material == "860025" ||
                            value.Material == "860024" ||
                            value.Material == "860023" ||
                            value.Material == "860022" ||
                            value.Material == "860022"
                        ) {
                            flag = true;
                        } else {
                            toatalQuantity =
                                toatalQuantity + parseFloat(value.RequestedQuantity);

                            totalAmount = totalAmount + parseFloat(value.NetAmount);
                        }

                        totalNetAmount += parseFloat(
                            (
                                parseFloat(value.NetAmount) + parseFloat(value.TaxAmount)
                            ).toFixed(2),
                        );

                        Row_No = Row_No + 1;
                        TableHTML += "<tr>";
                        //TableHTML += "<td '>" + "" + "</td>";
                        TableHTML +=
                            "<td style=width: 85px;>" + value.SalesOrderItem + "</td>";

                        if (flag == true) {
                            TableHTML +=
                                "<td>" +
                                value.SalesOrderItemText +
                                " " +
                                "<span class='text-red'>( RP )</span></td>";
                        } else {
                            TableHTML += "<td>" + value.SalesOrderItemText + "</td>";
                        }

                        TableHTML += "<td>" + value.RequestedQuantity + "</td>";
                        TableHTML += "<td>" + value.RequestedQuantityUnit + "</td>";
                        TableHTML += "<td>" + value.NetAmount + "</td>";
                        TableHTML += "<td>" + value.TaxAmount + "</td>";
                        TableHTML +=
                            "<td>" +
                            (
                                parseFloat(value.NetAmount) + parseFloat(value.TaxAmount)
                            ).toFixed(2);
                        ("</td>");
                        TableHTML +=
                            '<td class="text-right" style="width: 160px; padding: 5px 3px 5px 3px;">';

                        if (orderstatus == "Completed") {
                            TableHTML +=
                                '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit">';
                            TableHTML += "Completed";
                            TableHTML += "</a>";
                        } else {
                            TableHTML +=
                                '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Edit" onclick="ShowRouteItemEditEntry(\'' +
                                value.SalesOrderItem +
                                "', '" +
                                value.RequestedQuantity +
                                "', '" +
                                value.Material +
                                "', '" +
                                value.RequestedQuantityUnit +
                                "', '" +
                                value.SalesOrderItemText +
                                "', '" +
                                parseFloat(
                                    value.Subtotal1Amount / value.RequestedQuantity,
                                ).toFixed(2) +
                                "')\">";
                            TableHTML += '<i class="fa fa-pencil"></i>';
                            TableHTML += "</a>";

                            TableHTML +=
                                '<a href="javascript:void(0);" class="btn btn-icon py-0" title="Delete" onclick="SaveDeleteEntryRouteItem(\'' +
                                value.SalesOrderItem +
                                "')\">";
                            TableHTML += '<i class="fa fa-trash"></i>';
                            TableHTML += "</a>";
                        }

                        TableHTML += "</td>";
                        TableHTML += "</tr>";
                    });

                    if (res_output.length > 0) {
                        TableHTML += "<tr>";
                        //TableHTML += "<td style='width: 20px;'>" + ""+ "</td>";
                        TableHTML +=
                            "<td style='width: 85px;' class='font-weight-bold' >" +
                            "TOTAL" +
                            "<span class='text-red'>*</span></td>";
                        TableHTML += "<td>" + "----" + "</td>";
                        TableHTML +=
                            '<td class="font-weight-bold">' + toatalQuantity + "</td>";
                        TableHTML += "<td>" + "----" + "</td>";
                        TableHTML +=
                            '<td class="font-weight-bold">' + setTotalNetAmount + "</td>";
                        TableHTML += "<td>" + "----" + "</td>";
                        TableHTML += "<td>" + totalNetAmount.toFixed(2) + "</td>";
                        TableHTML += '<td class="text-right">' + "----" + "</td>";
                    }

                    $("#tableEntryItemDetails").html(TableHTML);

                    //  SetDataTableorder("tableItemDetailsList", [5], "Sales Order Item");

                    //$('#tableItemDetailsList').DataTable({
                    //    "order": [[1, "desc"]] // Sort by the second column (Item Id) in descending order
                    //});

                    // $("#btn_Save_Item").prop("disabled", false);
                    // $("#modelEntryRoute").modal("hide");
                },
                error: function () {
                    ShowItemError(
                        "Error in fetching details from server.",
                        res[0].result_description,
                    );
                    // $("#btn_Save_Item").prop("disabled", false);
                },
            });

            Hide_Loader();
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description,
            );
        },
    });

    return;
}

function GetSalesAreaName() {
    $("#ddlEntrySalesAreaName")
        .empty()
        .append($("<option></option>").val("").html("Select Sales Area Name"));
    var SalesArea = $("#ddlEntrySalesArea").val();

    var delaerId = $("#ddlDealerName").val();

    GetMaster(
        "ddlEntrySalesAreaName",
        "Select Sales Area Name",
        "GetSalesAreaName",
        "",
        delaerId,
    );

    //GetMaster(
    //    "ddlDealerName",
    //    "Select Dealer",
    //    "getDealersalesgroup",
    //    "",
    //    SalesArea
    //);
}

function ShowRouteItemEditEntry(
    SalesOrderItem,
    RequestedQuantity,
    Material,
    RequestedQuantityUnit,
    SalesOrderItemText,
    Rate,
) {
    //GetMaster("ddlEntryItemCode", "Select Item", "GetProductsCode", Material, "");

    // $("#lblItemCheckUOM").html(RequestedQuantityUnit);
    // $("#lblItemCheckRate").html(Rate);

    var Dealer_Id = $("#ddlDealerName").val();

    var SalesAreaName = $("#ddlEntrySalesAreaName").val();

    var parts = SalesAreaName.split(" - ");

    // Assign each part to corresponding variables
    var SalesGroup = parts[0];
    var SalesOffice = parts[1];
    var SalesOrganization = parts[2];
    var DistributionChannel = parts[3];
    var OrganizationDivision = parts[4];

    GetRateCheckerNew(
        Dealer_Id,
        Material,
        SalesOrganization,
        DistributionChannel,
        OrganizationDivision,
    );

    // GetRateChecker(Dealer_Id, Material);

    var SalesAreaName = $("#ddlEntrySalesAreaName").val();
    // Split the SalesAreaName string into individual parts
    var parts = SalesAreaName.split(" - ");

    var OrganizationDivision = parts[4];
    GetMaster(
        "ddlEntryItemCode",
        "Select Product Item",
        "GetProductOndivision",
        Material,
        OrganizationDivision,
    );
    $("#lblItemDetailsAction").html("Edit");

    $("#ddlEntryItemCode").select2();
    $("#txtModalUOM").select2();

    $("#lblItemDetailsEntryId").html(SalesOrderItem);
    $("#modelEntryItem")
        .modal({
            backdrop: "static",
        })
        .modal("show");

    // OnChnageSelectSalesUser();
    $("#txtEntryQuantity").val(RequestedQuantity);
    // $("#txtModalUOM").val(RequestedQuantityUnit);
    GetMaster(
        "txtModalUOM",
        "Select UOM",
        "GetUOM",
        RequestedQuantityUnit,
        Material,
    );
    // $("#txtModalRate").val(Rate);

    var selecteitem = $("#ddlEntryItemCode option:selected").text();

    if (selecteitem == "") {
        var newOption = $("<option>").text(SalesOrderItemText).val(SalesOrderItem);

        // Append the new option to the select element
        $("#ddlEntryItemCode").append(newOption);
    }
}

function ShowItemDetailsModal(Action, Item_Id) {
    var SalesArea = $("#ddlEntrySalesArea").val();
    var SalesAreaName = $("#ddlEntrySalesAreaName").val();
    var IsValid = 1;
    if (SalesArea == "" || SalesArea == null || SalesArea == undefined) {
        $("#ddlEntrySalesArea").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (
        SalesAreaName == "" ||
        SalesAreaName == null ||
        SalesAreaName == undefined
    ) {
        $("#ddlEntrySalesAreaName").addClass("is-invalid state-invalid");
        IsValid = 0;
    }
    if (IsValid == 0) {
        // Show_Error_Toastr("Invalid data. Can't search.");
        return;
    }
    $("#modelEntryItem")
        .modal({
            backdrop: "static",
        })
        .modal("show");
    // OnChnageSelectSalesUser();
    $("#ddlEntryItemCode").select2();
    if (Action == "Add") {
        var SalesAreaName = $("#ddlEntrySalesAreaName").val();
        // Split the SalesAreaName string into individual parts
        var parts = SalesAreaName.split(" - ");

        var OrganizationDivision = parts[4];

        GetMaster(
            "ddlEntryItemCode",
            "Select Product Item",
            "GetProductOndivision",
            "",
            OrganizationDivision,
        );
        $("#txtModalRate").val("");
        $("#txtModalCheckUOM").val("");
        $("#txtEntryRate").val("");
        $("#txtEntryQuantity").val("");
        $("#txtEntryUOM").val("");
        $("#txtEntryPrice").val("");
        $("#txtModalUOM").val("");
        $("#txtModalUOM").select2();
        $("#lblItemDetailsAction").html("Add");
        $("#lblItemDetailsEntryId").html("");
        // $("#lblItemCheckUOM").html("");
        // $("#lblItemCheckRate").html("");
    }
}

function GetProductUOMtList() {
    $("#txtModalUOM")
        .empty()
        .append($("<option></option>").val("").html("All UOM"));
    var Product_Id = $("#ddlEntryItemCode").val();
    // $("#txtModalRate").val("");

    GetMaster("txtModalUOM", "Select UOM", "GetUOM", "", Product_Id);
}

function OnChnageSelectSalesUser() {
    var ProductId = $("#ddlEntryItemCode").val();
    $("#txtModalUOM").val("");

    for (var i = 0; i <= ProdutList.length; i++) {
        if (ProdutList[i].item_id == ProductId) {
            $("#txtModalUOM").val(ProdutList[i].item_unit);
            return;
        }
    }
}

function OnChnageUOM() {
    // var Rate = $("#lblItemCheckRate").html();
    // var OutPut_Unit = $("#txtModalUOM").val();
    // var InPut_Unit = $("#lblItemCheckUOM").html();
    // let calculatedRate = RateCalculator(InPut_Unit, OutPut_Unit, Rate);
    // $("#txtModalRate").val(calculatedRate);
}

function getSalesAreaCode() {
    var Dealer_Id = $("#ddlSearchDealerName").val();

    var Method_Name = "Get_SalesArea_Code";
    var APIEndPoint = "GetSalesOrderProduct";
    var url = "/SalesOrder/SalesOrder";
    // store data in object and send to the controller
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

            if (res.length > 0) {
                $("#lblSalesArea").html(res[0].item_id);
            } else {
                $("#lblSalesArea").html(""); // Data not found, set to empty string
            }
        },
        error: function () { },
    });
}

function GetRate() {
    var Product_Id = $("#ddlEntryItemCode").val();
    var Dealer_Id = $("#ddlDealerName").val();
    var SalesAreaName = $("#ddlEntrySalesAreaName").val();

    var parts = SalesAreaName.split(" - ");

    // Assign each part to corresponding variables
    var SalesGroup = parts[0];
    var SalesOffice = parts[1];
    var SalesOrganization = parts[2];
    var DistributionChannel = parts[3];
    var OrganizationDivision = parts[4];

    // GetRateChecker(Dealer_Id, Product_Id);
    GetRateCheckerNew(
        Dealer_Id,
        Product_Id,
        SalesOrganization,
        DistributionChannel,
        OrganizationDivision,
    );
}

function GetRateChecker(Dealer_Id, Product_Id) {
    Show_Loader();
    var APIEndPoint = "GetProductRateByDealerCode";
    var Method_Name = "Get";
    var url = "/Masters/Product";

    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        dealer_code: Dealer_Id,
        product_code: Product_Id,
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (res) {
            var result = JSON.parse(res);
            var set_result = JSON.parse(result);

            if (set_result.code == 1) {
                Hide_Loader();

                $("#txtModalRate").val(set_result.ConditionRateValue);
                $("#txtModalCheckUOM").val(set_result.ConditionQuantityUnit);
            } else {
                Hide_Loader();
                // $("#lblItemCheckUOM").html(0);
                // $("#lblItemCheckRate").html(0);
                $("#txtModalRate").val(" - ");
                $("#txtModalCheckUOM").val(" - ");
                Show_Error_Toastr("Error :" + set_result.ConditionRateValue);
            }
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description,
            );
        },
    });
}
function GetRateCheckerNew(
    Dealer_Id,
    Product_Id,
    SalesOrganization,
    DistributionChannel,
    Division,
) {
    Show_Loader();
    var APIEndPoint = "GetProductRateByDealerCodeNew";
    var Method_Name = "Get";
    var url = "/Masters/Product";

    var reqdata = {
        method_name: Method_Name,
        api_end_point: APIEndPoint,
        dealer_code: Dealer_Id,
        product_code: Product_Id,
        sales_organization: SalesOrganization,
        distribution_channel: DistributionChannel,
        division: Division,
    };
    $.ajax({
        type: "POST",
        url: url,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata,
        success: function (res) {
            var result = JSON.parse(res);
            var set_result = JSON.parse(result);

            if (set_result.code == 1) {
                Hide_Loader();

                $("#txtModalRate").val(set_result.ConditionRateValue);
                $("#txtModalCheckUOM").val(set_result.ConditionQuantityUnit);
            } else {
                Hide_Loader();
                // $("#lblItemCheckUOM").html(0);
                // $("#lblItemCheckRate").html(0);
                $("#txtModalRate").val(" - ");
                $("#txtModalCheckUOM").val(" - ");
                Show_Error_Toastr("Error :" + set_result.ConditionRateValue);
            }
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description,
            );
        },
    });
}
// function RateCalculator(InPut_Unit, OutPut_Unit, Rate) {
//   switch (InPut_Unit) {
//     case "L":
//       switch (OutPut_Unit) {
//         case "L":
//           return Rate;
//         case "KG":
//           return parseFloat(Rate * 1.0295).toFixed(2);
//         case "CRT":
//           return parseFloat(Rate * 10).toFixed(2);
//         case "EA":
//           return Rate;
//         default:
//           Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
//           return Rate;
//       }
//     case "KG":
//       switch (OutPut_Unit) {
//         case "KG":
//           return Rate;
//         case "L":
//           return parseFloat(Rate / 1.0295).toFixed(2);
//         default:
//           Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
//           return Rate;
//       }
//     case "BOX":
//       switch (OutPut_Unit) {
//         case "BOX":
//           return Rate;
//         default:
//           Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
//           return Rate;
//       }
//     case "CRT":
//       switch (OutPut_Unit) {
//         case "CRT":
//           return Rate;
//         case "L":
//           return parseFloat(Rate / 10).toFixed(2);
//         default:
//           Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
//           return Rate;
//       }
//     case "EA":
//       switch (OutPut_Unit) {
//         case "EA":
//           return Rate;
//         case "L":
//           return Rate;
//         case "KG":
//           return parseFloat(Rate * 1.0295).toFixed(2);
//         case "CRT":
//           return parseFloat(Rate * 10).toFixed(2);
//         default:
//           Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
//           return Rate;
//       }
//     default:
//       Show_Error_Toastr("Invalid Unit");
//       return Rate;
//   }
// }

function RateCalculator(InPut_Unit, OutPut_Unit, Rate) {
    switch (InPut_Unit) {
        case "L":
            switch (OutPut_Unit) {
                case "L":
                    return Rate;
                case "KG":
                    return parseFloat(Rate * 1.0295).toFixed(2);
                case "CRT":
                    return parseFloat(Rate * 10).toFixed(2);
                case "EA":
                    return Rate;
                case "BOX":
                    return Rate; // Not Maintain
                default:
                    Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
                    return Rate;
            }
        case "KG":
            switch (OutPut_Unit) {
                case "L":
                    return parseFloat(Rate / 1.0295).toFixed(2);
                case "KG":
                    return Rate;
                case "CRT":
                    return Rate; // Not Maintain
                case "EA":
                    return parseFloat(Rate / 1.0295).toFixed(2);
                case "BOX":
                    return Rate; // Not Maintain
                default:
                    Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
                    return Rate;
            }
        case "BOX":
            switch (OutPut_Unit) {
                case "L":
                    return Rate; // Not Maintain
                case "KG":
                    return Rate; // Not Maintain
                case "CRT":
                    return Rate; // Not Maintain
                case "EA":
                    return Rate; // Not Maintain
                case "BOX":
                    return Rate;
                default:
                    Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
                    return Rate;
            }
        case "CRT":
            switch (OutPut_Unit) {
                case "L":
                    return parseFloat(Rate / 10).toFixed(2);
                case "KG":
                    return Rate; // Not Maintain
                case "CRT":
                    return Rate;
                case "EA":
                    return parseFloat(Rate / 10).toFixed(2);
                case "BOX":
                    return Rate; // Not Maintain

                default:
                    Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
                    return Rate;
            }
        case "EA":
            switch (OutPut_Unit) {
                case "L":
                    return Rate;
                case "KG":
                    return parseFloat(Rate * 1.0295).toFixed(2);
                case "CRT":
                    return parseFloat(Rate * 10).toFixed(2);
                case "EA":
                    return Rate;
                case "BOX":
                    return Rate; // Not Maintain

                default:
                    Show_Error_Toastr(`Invalid Unit '${OutPut_Unit}'`);
                    return Rate;
            }
        default:
            Show_Error_Toastr("Invalid Unit");
            return Rate;
    }
}

// function GetOneSalesOrderHeader(SalesOrder) {
//   var setTotalNetAmount;
//   var APIEndPoint_1 = "GetOneSalesOrderHeader";
//   var Method_Name_1 = "Get_One";
//   var url_1 = "/SalesOrder/SalesOrder";
//   var reqdata_1 = {
//     method_name: Method_Name_1,
//     salesorder_id: SalesOrder,
//     api_end_point: APIEndPoint_1,
//   };
//   Show_Loader();

//   $.ajax({
//     type: "POST",
//     url: url_1,
//     contentType: "application/x-www-form-urlencoded; charset=UTF-8",
//     data: reqdata_1,
//     success: function (result) {
//       var res = JSON.parse(result);

//       var res_output = JSON.parse(res);

//       if (res_output.length == 0) {
//         Hide_Loader();
//         Show_Error_Toastr("Data not found.");
//         setTotalNetAmount = 0;
//       }
//       setTotalNetAmount = res_output[0].TotalNetAmount;

//       Hide_Loader();
//     },
//     error: function () {
//       Hide_Loader();
//       Show_Error_Toastr(
//         "Error in fetching details from server.",
//         res[0].result_description
//       );
//     },
//   });
// }

function ShowSalesOrderItemPricingTable() {
    ClearDataTable("tableItemDetailsPricing");
    var SalesOrder = $("#lblEntryId").html();
    var APIEndPoint_1 = "GetOneSalesOrderPricing";
    var Method_Name_1 = "Get_One";
    var url_1 = "/SalesOrder/SalesOrder";
    var reqdata_1 = {
        method_name: Method_Name_1,
        salesorder_id: SalesOrder,
        api_end_point: APIEndPoint_1,
    };
    Show_Loader();

    $.ajax({
        type: "POST",
        url: url_1,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata_1,
        success: function (result) {
            var res = JSON.parse(result);

            var res_output = JSON.parse(res);

            if (res_output.length == 0) {
                Hide_Loader();
                Show_Error_Toastr("Data not found.");

                //   $("#btn_Search").prop('disabled', false);
                return;
            }
            // Fill data in table
            var TableHTML = "";

            $.each(res_output, function (data, value) {
                TableHTML += "<tr>";
                TableHTML +=
                    "<td style='width: 85px;'>" + value.SalesOrderItem + "</td>";
                TableHTML += "<td>" + value.ConditionType + "</td>";

                TableHTML += "<td>" + value.ConditionBaseValue + "</td>";

                TableHTML += "<td>" + value.ConditionRateValue + "</td>";
                TableHTML += "<td>" + value.ConditionAmount + "</td>";
                TableHTML += "<td>" + value.TransactionCurrency + "</td>";

                TableHTML += "</tr>";
            });

            $("#tableItemDetailsPricing").html(TableHTML);

            Hide_Loader();
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description,
            );
        },
    });

    return;
}

function ShowPDFEntry(SalesOrder) {
    var APIEndPoint_1 = "GetOneSalesOrderPDF";
    var Method_Name_1 = "Get_One";
    var url_1 = "/SalesOrder/SalesOrder";
    var reqdata_1 = {
        method_name: Method_Name_1,
        salesorder_id: SalesOrder,
        api_end_point: APIEndPoint_1,
    };
    Show_Loader();

    $.ajax({
        type: "POST",
        url: url_1,
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        data: reqdata_1,
        success: function (result) {
            // var res = JSON.parse(result);
            // console.log(res);

            try {
                var res = JSON.parse(result);

                if (res) {
                    var base64String = res;

                    // Convert base64 string to a byte array
                    var byteCharacters = atob(base64String);
                    var byteNumbers = new Array(byteCharacters.length);
                    for (var i = 0; i < byteCharacters.length; i++) {
                        byteNumbers[i] = byteCharacters.charCodeAt(i);
                    }

                    var byteArray = new Uint8Array(byteNumbers);
                    var blob = new Blob([byteArray], { type: "application/pdf" });

                    // Create a Blob URL and open in a new tab
                    var blobURL = URL.createObjectURL(blob);
                    window.open(blobURL, "_blank");
                } else {
                    Show_Error_Toastr("Invalid PDF data received.");
                }
            } catch (error) {
                Show_Error_Toastr("Error processing PDF response.");
            }
            Hide_Loader();
        },
        error: function () {
            Hide_Loader();
            Show_Error_Toastr(
                "Error in fetching details from server.",
                res[0].result_description,
            );
        },
    });

    return;
}
