

using Dapper;
using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using MilkOUT_API.Areas.SalesApp_API.Models;
using MilkOUT_API.Areas.SalesApp_API.SAP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static MilkOUT_API.Middleware.Notify_Data;

namespace MilkOUT_API.Areas.SalesApp_API.Controllers
{
    [Route("v1/api/sales/order/")]
    [ApiController]
    public class OrderController : Controller
    {
        private readonly ILogger<OrderController> _logger;

        public OrderController(ILogger<OrderController> logger)
        {
            _logger = logger;
        }


        [HttpPost("GetSalesOrder", Name = "SGetSalesOrder")]
        public IActionResult GetSalesOrder(ReqSalesOrder salesorder)
        {
            try
            {
                if (salesorder.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = salesorder.destination_name + "";


                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = salesorder.org_id;
                req_Obj.dealer_id = salesorder.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new SalesOrderDAL(res_DestinationName[0].ConnectionName).GetAllSalesOrder(res_Obj[0].dealer_code, salesorder.formattedStartDate, salesorder.formattedEndDate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        [HttpPost("GetOneSalesOrder", Name = "SGetOneSalesOrder")]
        public IActionResult GetOneSalesOrder(ReqSalesOrder salesorder)
        {
            try
            {
                if (salesorder.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = salesorder.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new SalesOrderDAL(res_DestinationName[0].ConnectionName).GetOneSalesOrder(salesorder.salesorder_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("SSaveSalesOrder", Name = "SSaveSalesOrder")]
        public IActionResult SaveSalesOrder(ReqSalesOrderNew salesorder)
        {
            try
            {
                // Fetch necessary data
                string destination_name = salesorder.destination_name + "";
                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut { org_id = salesorder.org_id };
                List<ResOrgOutPut> res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                ReqGetDealer req_Obj = new ReqGetDealer
                {
                    org_id = salesorder.org_id,
                    dealer_id = salesorder.SoldToParty
                };
                List<ResGetDealer> res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                // Populate sales order parameters

                SalesOrder parameter = new SalesOrder();

                parameter.SalesOrderType = salesorder.SalesOrderType;
                parameter.SalesOrganization = salesorder.SalesOrganization;
                parameter.DistributionChannel = salesorder.DistributionChannel;
                parameter.OrganizationDivision = salesorder.OrganizationDivision;
                parameter.SalesGroup = salesorder.SalesGroup;
                parameter.SalesOffice = salesorder.SalesOffice;
                parameter.SalesDistrict = null;
                parameter.SoldToParty = res_Obj[0].dealer_code;
                parameter.CreationDate = "/Date(" + DateTime.Now.ToString("yyyyMMddHHmmss") + ")/"; ;
                parameter.CreatedByUser = "CB9980000016";
                parameter.LastChangeDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/"; 
                parameter.SenderBusinessSystemName = salesorder.SenderBusinessSystemName;
                parameter.ExternalDocumentID = salesorder.ExternalDocumentID;
                parameter.LastChangeDateTime = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()}+0000)/"; ;
                parameter.ExternalDocLastChangeDateTime = salesorder.ExternalDocLastChangeDateTime;
                parameter.PurchaseOrderByCustomer = salesorder.PurchaseOrderByCustomer;
                parameter.PurchaseOrderByShipToParty = salesorder.PurchaseOrderByShipToParty;
                parameter.CustomerPurchaseOrderType = salesorder.CustomerPurchaseOrderType;
                parameter.CustomerPurchaseOrderDate = salesorder.CustomerPurchaseOrderDate;
                parameter.SalesOrderDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                parameter.TotalNetAmount = salesorder.TotalNetAmount;
                parameter.OverallDeliveryStatus = "C";
                parameter.TotalBlockStatus = salesorder.TotalBlockStatus;
                parameter.OverallOrdReltdBillgStatus = salesorder.OverallOrdReltdBillgStatus;
                parameter.OverallSDDocReferenceStatus = salesorder.OverallSDDocReferenceStatus;
                parameter.TransactionCurrency = "INR";
                parameter.SDDocumentReason = salesorder.SDDocumentReason;
                parameter.PricingDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                parameter.PriceDetnExchangeRate = "1.00000";
                parameter.BillingPlan = salesorder.BillingPlan;
                parameter.RequestedDeliveryDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                parameter.ShippingCondition = salesorder.ShippingCondition;
                parameter.CompleteDeliveryIsDefined = salesorder.CompleteDeliveryIsDefined;
                parameter.ShippingType = salesorder.ShippingType;
                parameter.HeaderBillingBlockReason = salesorder.HeaderBillingBlockReason;
                parameter.DeliveryBlockReason = salesorder.DeliveryBlockReason;
                parameter.DeliveryDateTypeRule = salesorder.DeliveryDateTypeRule;
                parameter.IncotermsClassification = "CFR";
                parameter.IncotermsTransferLocation = salesorder.IncotermsTransferLocation;
                parameter.IncotermsLocation1 = salesorder.IncotermsLocation1;
                parameter.IncotermsLocation2 = salesorder.IncotermsLocation2;
                parameter.IncotermsVersion = salesorder.IncotermsVersion;
                parameter.CustomerPriceGroup = salesorder.CustomerPriceGroup;
                parameter.PriceListType = salesorder.PriceListType;
                parameter.CustomerPaymentTerms = "0001";
                parameter.PaymentMethod = salesorder.PaymentMethod;
                parameter.FixedValueDate = salesorder.FixedValueDate;
                parameter.AssignmentReference = salesorder.AssignmentReference;
                parameter.ReferenceSDDocument = salesorder.ReferenceSDDocument;
                parameter.ReferenceSDDocumentCategory = salesorder.ReferenceSDDocumentCategory;
                parameter.AccountingDocExternalReference = salesorder.AccountingDocExternalReference;
                parameter.CustomerAccountAssignmentGroup = "01";
                parameter.AccountingExchangeRate = "0.00000";
                parameter.CustomerGroup = salesorder.CustomerGroup;
                parameter.AdditionalCustomerGroup1 = salesorder.AdditionalCustomerGroup1;
                parameter.AdditionalCustomerGroup2 = salesorder.AdditionalCustomerGroup2;
                parameter.AdditionalCustomerGroup3 = salesorder.AdditionalCustomerGroup3;
                parameter.AdditionalCustomerGroup4 = salesorder.AdditionalCustomerGroup4;
                parameter.AdditionalCustomerGroup5 = salesorder.AdditionalCustomerGroup5;
                parameter.SlsDocIsRlvtForProofOfDeliv = salesorder.SlsDocIsRlvtForProofOfDeliv;
                parameter.CustomerTaxClassification1 = salesorder.CustomerTaxClassification1;
                parameter.CustomerTaxClassification2 = salesorder.CustomerTaxClassification2;
                parameter.CustomerTaxClassification3 = salesorder.CustomerTaxClassification3;
                parameter.CustomerTaxClassification4 = salesorder.CustomerTaxClassification4;
                parameter.CustomerTaxClassification5 = salesorder.CustomerTaxClassification5;
                parameter.CustomerTaxClassification6 = salesorder.CustomerTaxClassification6;
                parameter.CustomerTaxClassification7 = salesorder.CustomerTaxClassification7;
                parameter.CustomerTaxClassification8 = salesorder.CustomerTaxClassification8;
                parameter.CustomerTaxClassification9 = salesorder.CustomerTaxClassification9;
                parameter.TaxDepartureCountry = salesorder.TaxDepartureCountry;
                parameter.VATRegistrationCountry = salesorder.VATRegistrationCountry;
                parameter.SalesOrderApprovalReason = salesorder.SalesOrderApprovalReason;
                parameter.SalesDocApprovalStatus = salesorder.SalesDocApprovalStatus;
                parameter.OverallSDProcessStatus = "C";
                parameter.TotalCreditCheckStatus = "D";
                parameter.OverallTotalDeliveryStatus = "C";
                parameter.OverallSDDocumentRejectionSts = "a";
                parameter.BillingDocumentDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                parameter.ContractAccount = salesorder.ContractAccount;
                parameter.AdditionalValueDays = "0";
                parameter.CustomerPurchaseOrderSuplmnt = salesorder.CustomerPurchaseOrderSuplmnt;
                parameter.ServicesRenderedDate = salesorder.ServicesRenderedDate;
                parameter.to_Item = salesorder.to_Item;

                // Set SalesOrderItem and units for each item
                for (int i = 0; i < salesorder.to_Item.Count; i++)
                {
                    var SalesOrderItem = 100 * (i + 1);
                    parameter.to_Item[i].SalesOrderItem = SalesOrderItem.ToString();
                    parameter.to_Item[i].PricingDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                    parameter.to_Item[i].BillingDocumentDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";

                    switch (salesorder.to_Item[i].RequestedQuantityUnit)
                    {
                        case "BOX":
                            parameter.to_Item[i].RequestedQuantityUnit = "BOX";
                            parameter.to_Item[i].RequestedQuantitySAPUnit = "ZBX";
                            parameter.to_Item[i].RequestedQuantityISOUnit = "BX";
                            parameter.to_Item[i].OrderQuantityUnit = "BOX";
                            parameter.to_Item[i].OrderQuantitySAPUnit = "ZBX";
                            parameter.to_Item[i].OrderQuantityISOUnit = "BX";
                            break;
                        case "CRT":
                            parameter.to_Item[i].RequestedQuantityUnit = "CRT";
                            parameter.to_Item[i].RequestedQuantitySAPUnit = "KI";
                            parameter.to_Item[i].RequestedQuantityISOUnit = "CR";
                            parameter.to_Item[i].OrderQuantityUnit = "CRT";
                            parameter.to_Item[i].OrderQuantitySAPUnit = "KI";
                            parameter.to_Item[i].OrderQuantityISOUnit = "CR";
                            break;
                        case "L":
                            parameter.to_Item[i].RequestedQuantityUnit = "L";
                            parameter.to_Item[i].RequestedQuantitySAPUnit = "L";
                            parameter.to_Item[i].RequestedQuantityISOUnit = "LTR";
                            parameter.to_Item[i].OrderQuantityUnit = "L";
                            parameter.to_Item[i].OrderQuantitySAPUnit = "L";
                            parameter.to_Item[i].OrderQuantityISOUnit = "LTR";
                            break;
                        case "KG":
                            parameter.to_Item[i].RequestedQuantityUnit = "KG";
                            parameter.to_Item[i].RequestedQuantitySAPUnit = "KG";
                            parameter.to_Item[i].RequestedQuantityISOUnit = "KGM";
                            parameter.to_Item[i].OrderQuantityUnit = "KG";
                            parameter.to_Item[i].OrderQuantitySAPUnit = "KG";
                            parameter.to_Item[i].OrderQuantityISOUnit = "KGM";
                            break;
                        case "BAG":
                            parameter.to_Item[i].RequestedQuantityUnit = "BAG";
                            parameter.to_Item[i].RequestedQuantitySAPUnit = "BAG";
                            parameter.to_Item[i].RequestedQuantityISOUnit = "BG";
                            parameter.to_Item[i].OrderQuantityUnit = "BAG";
                            parameter.to_Item[i].OrderQuantitySAPUnit = "BAG";
                            parameter.to_Item[i].OrderQuantityISOUnit = "BG";
                            break;
                        case "EA":
                            parameter.to_Item[i].RequestedQuantityUnit = "EA";
                            parameter.to_Item[i].RequestedQuantitySAPUnit = "EA";
                            parameter.to_Item[i].RequestedQuantityISOUnit = "EA";
                            parameter.to_Item[i].OrderQuantityUnit = "EA";
                            parameter.to_Item[i].OrderQuantitySAPUnit = "EA";
                            parameter.to_Item[i].OrderQuantityISOUnit = "EA";
                            break;
                        default:
                            parameter.to_Item[i].RequestedQuantityUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.to_Item[i].RequestedQuantitySAPUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.to_Item[i].RequestedQuantityISOUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.to_Item[i].OrderQuantityUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.to_Item[i].OrderQuantitySAPUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.to_Item[i].OrderQuantityISOUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            break;
                    }
                }

                // Save the sales order
                string resString = new SalesOrderDAL(res_DestinationName[0].ConnectionName).SaveSalesOrder(parameter, salesorder.org_id);
                JObject jsonResponse = JObject.Parse(resString);

                if (jsonResponse["code"].ToString() == "1" && parameter.to_Item.Count > 1)
                {
                    // Save each sales order item if sales order save is successful
                    foreach (var item in parameter.to_Item.Skip(1))
                    {


                        SalesOrderItems itemParameter = new SalesOrderItems();

                        itemParameter.SalesOrder = jsonResponse["salesOrder"].ToString();
                        itemParameter.SalesOrderItem = item.SalesOrderItem;
                        itemParameter.Material = item.Material;
                        itemParameter.PricingDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                        itemParameter.RequestedQuantity = item.RequestedQuantity;
                        itemParameter.ConfdDelivQtyInOrderQtyUnit = item.ConfdDelivQtyInOrderQtyUnit;
                        itemParameter.BillingDocumentDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                        itemParameter.DeliveryDateQuantityIsFixed = item.DeliveryDateQuantityIsFixed;
                        itemParameter.SlsDocIsRlvtForProofOfDeliv = item.SlsDocIsRlvtForProofOfDeliv;
                        itemParameter.to_PricingElement = item.to_PricingElement;


                        string resStringItem = new SalesOrderDAL(destination_name).SaveSalesOrderItems(itemParameter, salesorder.org_id);
                        // Handle response for each item if needed
                    }
                }

                return Ok(resString);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;
                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("AddSalesOrderItems", Name = "AddSalesOrderItems")]
        public IActionResult AddSalesOrderItems([FromBody] object reqObject, string destination_name)
        {
            try
            {

                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());

                SalesOrderItems parameter = new SalesOrderItems();

                parameter.SalesOrder = inputParam.SalesOrder;
                parameter.SalesOrderItem = inputParam.SalesOrderItem;
                parameter.Material = inputParam.Material;
                parameter.PricingDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                parameter.RequestedQuantity = inputParam.RequestedQuantity;
                parameter.ConfdDelivQtyInOrderQtyUnit = inputParam.ConfdDelivQtyInOrderQtyUnit;
                parameter.BillingDocumentDate = $"/Date({new DateTimeOffset(DateTime.UtcNow.Date).ToUnixTimeMilliseconds()})/";
                parameter.DeliveryDateQuantityIsFixed = inputParam.DeliveryDateQuantityIsFixed;
                parameter.SlsDocIsRlvtForProofOfDeliv = inputParam.DeliveryDateQuantityIsFixed;
                parameter.to_PricingElement = inputParam.to_PricingElement;



                string resString = new SalesOrderDAL(destination_name).SaveSalesOrderItems(parameter, "C005");
                return Ok(resString);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }








        [HttpPost("SaveSalesOrderItems", Name = "SSaveSalesOrderItems")]
        public IActionResult SaveSalesOrderItems(ReqSalesOrderNew salesorder)
        {
            try
            {

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = salesorder.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;

                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                SalesOrderItems parameter = new SalesOrderItems();


                if (salesorder.to_Item.Count > 0)
                {

                    string resString = "";

                    for (int i = 0; i < salesorder.to_Item.Count; i++)
                    {

                        parameter.SalesOrder = salesorder.salesorder_id;
                        parameter.SalesOrderItem = salesorder.to_Item[i].SalesOrderItem;
                        parameter.Material = salesorder.to_Item[i].Material;
                        parameter.PricingDate = $"/Date({new DateTimeOffset(DateTime.UtcNow).ToUnixTimeMilliseconds()})/";
                        parameter.RequestedQuantity = salesorder.to_Item[i].RequestedQuantity;
                        parameter.ConfdDelivQtyInOrderQtyUnit = salesorder.to_Item[i].ConfdDelivQtyInOrderQtyUnit;
                        parameter.BillingDocumentDate = $"/Date({new DateTimeOffset(DateTime.UtcNow).ToUnixTimeMilliseconds()})/";
                        parameter.DeliveryDateQuantityIsFixed = salesorder.to_Item[i].DeliveryDateQuantityIsFixed;
                        parameter.SlsDocIsRlvtForProofOfDeliv = salesorder.to_Item[i].DeliveryDateQuantityIsFixed;
                        parameter.to_PricingElement = salesorder.to_Item[i].to_PricingElement;


                        // if (salesorder.to_Item[i].RequestedQuantityUnit == "BOX")
                        // {
                        //     parameter.RequestedQuantityUnit = "BOX";
                        //     parameter.RequestedQuantitySAPUnit = "ZBX";
                        //     parameter.RequestedQuantityISOUnit = "BX";
                        //     parameter.OrderQuantityUnit = "BOX";
                        //     parameter.OrderQuantitySAPUnit = "ZBX";
                        //     parameter.OrderQuantityISOUnit = "BX";
                        // }
                        // else if (salesorder.to_Item[i].RequestedQuantityUnit == "CRT")
                        // {
                        //     parameter.RequestedQuantityUnit = "CRT";
                        //     parameter.RequestedQuantitySAPUnit = "KI";
                        //     parameter.RequestedQuantityISOUnit = "CR";
                        //     parameter.OrderQuantityUnit = "CRT";
                        //     parameter.OrderQuantitySAPUnit = "KI";
                        //     parameter.OrderQuantityISOUnit = "CR";
                        // }
                        // else
                        // {
                        //     parameter.RequestedQuantityUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                        //     parameter.RequestedQuantitySAPUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                        //     parameter.RequestedQuantityISOUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                        //     parameter.OrderQuantityUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                        //     parameter.OrderQuantitySAPUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                        //     parameter.OrderQuantityISOUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                        // }

                        if (salesorder.to_Item[i].RequestedQuantityUnit == "BOX")
                        {
                            parameter.RequestedQuantityUnit = "BOX";
                            parameter.RequestedQuantitySAPUnit = "ZBX";
                            parameter.RequestedQuantityISOUnit = "BX";
                            parameter.OrderQuantityUnit = "BOX";
                            parameter.OrderQuantitySAPUnit = "ZBX";
                            parameter.OrderQuantityISOUnit = "BX";
                        }
                        else if (salesorder.to_Item[i].RequestedQuantityUnit == "CRT")
                        {
                            parameter.RequestedQuantityUnit = "CRT";
                            parameter.RequestedQuantitySAPUnit = "KI";
                            parameter.RequestedQuantityISOUnit = "CR";
                            parameter.OrderQuantityUnit = "CRT";
                            parameter.OrderQuantitySAPUnit = "KI";
                            parameter.OrderQuantityISOUnit = "CR";
                        }
                        else if (salesorder.to_Item[i].RequestedQuantityUnit == "L")
                        {
                            parameter.RequestedQuantityUnit = "L";
                            parameter.RequestedQuantitySAPUnit = "L";
                            parameter.RequestedQuantityISOUnit = "LTR";
                            parameter.OrderQuantityUnit = "L";
                            parameter.OrderQuantitySAPUnit = "L";
                            parameter.OrderQuantityISOUnit = "LTR";
                        }
                        else if (salesorder.to_Item[i].RequestedQuantityUnit == "KG")
                        {
                            parameter.RequestedQuantityUnit = "KG";
                            parameter.RequestedQuantitySAPUnit = "KG";
                            parameter.RequestedQuantityISOUnit = "KGM";
                            parameter.OrderQuantityUnit = "KG";
                            parameter.OrderQuantitySAPUnit = "KG";
                            parameter.OrderQuantityISOUnit = "KGM";
                        }
                        else if (salesorder.to_Item[i].RequestedQuantityUnit == "BAG")
                        {
                            parameter.RequestedQuantityUnit = "BAG";
                            parameter.RequestedQuantitySAPUnit = "BAG";
                            parameter.RequestedQuantityISOUnit = "BG";
                            parameter.OrderQuantityUnit = "BAG";
                            parameter.OrderQuantitySAPUnit = "BAG";
                            parameter.OrderQuantityISOUnit = "BG";
                        }
                        else if (salesorder.to_Item[i].RequestedQuantityUnit == "EA")
                        {
                            parameter.RequestedQuantityUnit = "EA";
                            parameter.RequestedQuantitySAPUnit = "EA";
                            parameter.RequestedQuantityISOUnit = "EA";
                            parameter.OrderQuantityUnit = "EA";
                            parameter.OrderQuantitySAPUnit = "EA";
                            parameter.OrderQuantityISOUnit = "EA";
                        }
                        else
                        {
                            parameter.RequestedQuantityUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.RequestedQuantitySAPUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.RequestedQuantityISOUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.OrderQuantityUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.OrderQuantitySAPUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                            parameter.OrderQuantityISOUnit = salesorder.to_Item[i].RequestedQuantityUnit;
                        }


                        resString = new SalesOrderDAL(res_DestinationName[0].ConnectionName).SaveSalesOrderItems(parameter, salesorder.org_id);

                        JObject jsonResponse = JObject.Parse(resString);


                    }
                    return Ok(resString);
                }


                return Ok("");


            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("DeleteSalesOrderItems", Name = "SDeleteSalesOrderItems")]
        public IActionResult DeleteSalesOrderItems(ReqSalesOrder salesorder)
        {
            try
            {
                if (salesorder.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = salesorder.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new SalesOrderDAL(res_DestinationName[0].ConnectionName).DeleteSalesOrderItems(salesorder.salesorder_id, salesorder.salesorderitem, salesorder.org_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("UpdateSalesOrder", Name = "SUpdateSalesOrder")]
        public IActionResult UpdateSalesOrder(ReqSalesOrderNew salesorder)
        {
            try
            {

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = salesorder.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;

                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = salesorder.org_id;
                req_Obj.dealer_id = salesorder.SoldToParty;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);




                SalesOrderHeader parameter = new SalesOrderHeader();

                parameter.SalesOrderType = salesorder.SalesOrderType;
                parameter.SalesOrganization = salesorder.SalesOrganization;
                parameter.DistributionChannel = salesorder.DistributionChannel;
                parameter.OrganizationDivision = salesorder.OrganizationDivision;
                parameter.SalesGroup = salesorder.SalesGroup;
                parameter.SalesOffice = salesorder.SalesOffice;
                parameter.SalesDistrict = salesorder.SalesDistrict;
                parameter.SoldToParty = res_Obj[0].dealer_code;
                parameter.PurchaseOrderByCustomer = salesorder.PurchaseOrderByCustomer;
                parameter.PurchaseOrderByShipToParty = salesorder.PurchaseOrderByShipToParty;
                parameter.CustomerPurchaseOrderType = salesorder.CustomerPurchaseOrderType;
                parameter.CustomerPurchaseOrderDate = salesorder.CustomerPurchaseOrderDate;
                parameter.SalesOrderDate = salesorder.SalesOrderDate;
                parameter.TransactionCurrency = salesorder.TransactionCurrency;
                parameter.SDDocumentReason = salesorder.SDDocumentReason;
                parameter.PricingDate = salesorder.PricingDate;
                parameter.PriceDetnExchangeRate = salesorder.PriceDetnExchangeRate;
                parameter.BillingPlan = salesorder.BillingPlan;
                parameter.RequestedDeliveryDate = salesorder.RequestedDeliveryDate;
                parameter.ShippingCondition = salesorder.ShippingCondition;
                parameter.CompleteDeliveryIsDefined = salesorder.CompleteDeliveryIsDefined;
                parameter.ShippingType = salesorder.ShippingType;
                parameter.HeaderBillingBlockReason = salesorder.HeaderBillingBlockReason;
                parameter.DeliveryBlockReason = salesorder.DeliveryBlockReason;
                parameter.DeliveryDateTypeRule = salesorder.DeliveryDateTypeRule;
                parameter.IncotermsClassification = salesorder.IncotermsClassification;
                parameter.IncotermsTransferLocation = salesorder.IncotermsTransferLocation;
                parameter.IncotermsLocation1 = salesorder.IncotermsLocation1;
                parameter.IncotermsLocation2 = salesorder.IncotermsLocation2;
                parameter.IncotermsVersion = salesorder.IncotermsVersion;
                parameter.CustomerPriceGroup = salesorder.CustomerPriceGroup;
                parameter.PriceListType = salesorder.PriceListType;
                parameter.CustomerPaymentTerms = salesorder.CustomerPaymentTerms;
                parameter.PaymentMethod = salesorder.PaymentMethod;
                parameter.FixedValueDate = salesorder.FixedValueDate;
                parameter.AssignmentReference = salesorder.AssignmentReference;
                parameter.ReferenceSDDocument = salesorder.ReferenceSDDocument;
                parameter.AccountingDocExternalReference = salesorder.AccountingDocExternalReference;
                parameter.CustomerAccountAssignmentGroup = salesorder.CustomerAccountAssignmentGroup;
                parameter.AccountingExchangeRate = salesorder.AccountingExchangeRate;
                parameter.CustomerGroup = salesorder.CustomerGroup;
                parameter.AdditionalCustomerGroup1 = salesorder.AdditionalCustomerGroup1;
                parameter.AdditionalCustomerGroup2 = salesorder.AdditionalCustomerGroup2;
                parameter.AdditionalCustomerGroup3 = salesorder.AdditionalCustomerGroup3;
                parameter.AdditionalCustomerGroup4 = salesorder.AdditionalCustomerGroup4;
                parameter.AdditionalCustomerGroup5 = salesorder.AdditionalCustomerGroup5;
                parameter.SlsDocIsRlvtForProofOfDeliv = salesorder.SlsDocIsRlvtForProofOfDeliv;
                parameter.CustomerTaxClassification1 = salesorder.CustomerTaxClassification1;
                parameter.CustomerTaxClassification2 = salesorder.CustomerTaxClassification2;
                parameter.CustomerTaxClassification3 = salesorder.CustomerTaxClassification3;
                parameter.CustomerTaxClassification4 = salesorder.CustomerTaxClassification4;
                parameter.CustomerTaxClassification5 = salesorder.CustomerTaxClassification5;
                parameter.CustomerTaxClassification6 = salesorder.CustomerTaxClassification6;
                parameter.CustomerTaxClassification7 = salesorder.CustomerTaxClassification7;
                parameter.CustomerTaxClassification8 = salesorder.CustomerTaxClassification8;
                parameter.CustomerTaxClassification9 = salesorder.CustomerTaxClassification9;
                parameter.TaxDepartureCountry = salesorder.TaxDepartureCountry;
                parameter.VATRegistrationCountry = salesorder.VATRegistrationCountry;
                parameter.BillingDocumentDate = salesorder.BillingDocumentDate;
                parameter.ContractAccount = salesorder.ContractAccount;
                parameter.AdditionalValueDays = salesorder.AdditionalValueDays;
                parameter.CustomerPurchaseOrderSuplmnt = salesorder.CustomerPurchaseOrderSuplmnt;
                parameter.ServicesRenderedDate = salesorder.ServicesRenderedDate;





                string resString = new SalesOrderDAL(res_DestinationName[0].ConnectionName).UpdateSalesOrder(parameter, salesorder.salesorder_id, salesorder.org_id);
                return Ok(resString);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetSalesOrderPDF", Name = "GetSalesOrderPDF")]
        public IActionResult GetSalesOrderPDF(ReqSalesOrder salesorder)
        {
            try
            {
                if (salesorder.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = salesorder.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).GetSalesOrderPDF(salesorder.salesorder_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

    }
}



