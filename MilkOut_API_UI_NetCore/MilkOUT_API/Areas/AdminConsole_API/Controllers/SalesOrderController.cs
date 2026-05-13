using Dapper;
using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/salesorder/")]
    [ApiController]
    public class SalesOrderController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public SalesOrderController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }


        [HttpPost("GetSalesOrderNew", Name = "GetSalesOrderNew")]
        public IActionResult GetSalesOrderNew(ReqSalesOrder salesorder)
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


                //ReqGetDealer req_Obj = new ReqGetDealer();
                //req_Obj.org_id = salesorder.org_id;
                //req_Obj.dealer_id = salesorder.dealer_id;

                //res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).GetAllSalesOrder(salesorder.sales_area, salesorder.formattedStartDate, salesorder.formattedEndDate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetOneSalesOrderHeader", Name = "GetOneSalesOrderHeader")]
        public IActionResult GetOneSalesOrderHeader(ReqSalesOrder salesorder)
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


                //ReqGetDealer req_Obj = new ReqGetDealer();
                //req_Obj.org_id = salesorder.org_id;
                //req_Obj.dealer_id = salesorder.dealer_id;

                //res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).GetOneSalesOrderHeader(salesorder.salesorder_id);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetSalesOrderSalesEmployee", Name = "GetSalesOrderSalesEmployee")]
        public IActionResult GetSalesOrderSalesEmployee(ReqSalesOrder salesorder)
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


                //ReqGetDealer req_Obj = new ReqGetDealer();
                //req_Obj.org_id = salesorder.org_id;
                //req_Obj.dealer_id = salesorder.dealer_id;

                //res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).GetSalesOrderSalesEmployee(salesorder.salesorder_id);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetOneSalesOrderHeaderPartner", Name = "GetOneSalesOrderHeaderPartner")]
        public IActionResult GetOneSalesOrderHeaderPartner(ReqSalesOrder salesorder)
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


                //ReqGetDealer req_Obj = new ReqGetDealer();
                //req_Obj.org_id = salesorder.org_id;
                //req_Obj.dealer_id = salesorder.dealer_id;

                //res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).GetOneSalesOrderHeaderPartner(salesorder.salesorder_id);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("GetOneSalesOrderPDF", Name = "GetOneSalesOrderPDF")]
        public IActionResult GetOneSalesOrderPDF(ReqSalesOrder salesorder)
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


                //ReqGetDealer req_Obj = new ReqGetDealer();
                //req_Obj.org_id = salesorder.org_id;
                //req_Obj.dealer_id = salesorder.dealer_id;

                //res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

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




        [HttpPost("GetOneSalesOrderNew", Name = "GetOneSalesOrderNew")]
        public IActionResult GetOneSalesOrderNew(ReqSalesOrder salesorder)
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


                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).GetOneSalesOrderNew(salesorder.salesorder_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetOneSalesOrderPricing", Name = "GetOneSalesOrderPricing")]
        public IActionResult GetOneSalesOrderPricing(ReqSalesOrder salesorder)
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


                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).GetOneSalesOrderPricing(salesorder.salesorder_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("SaveSalesOrder", Name = "SaveSalesOrder")]
        public IActionResult SaveSalesOrder(ReqSalesOrderNew salesorder)
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




                SalesOrder parameter = new SalesOrder();

                parameter.SalesOrderType = salesorder.SalesOrderType;
                parameter.SalesOrganization = salesorder.SalesOrganization;
                parameter.DistributionChannel = salesorder.DistributionChannel;
                parameter.OrganizationDivision = salesorder.OrganizationDivision;
                parameter.SalesGroup = salesorder.SalesGroup;
                parameter.SalesOffice = salesorder.SalesOffice;
                parameter.SalesDistrict = salesorder.SalesDistrict;
                parameter.SoldToParty = salesorder.SoldToParty;
                parameter.CreationDate = salesorder.CreationDate;
                parameter.CreatedByUser = salesorder.CreatedByUser;
                parameter.LastChangeDate = salesorder.LastChangeDate;
                parameter.SenderBusinessSystemName = salesorder.SenderBusinessSystemName;
                parameter.ExternalDocumentID = salesorder.ExternalDocumentID;
                parameter.LastChangeDateTime = salesorder.LastChangeDateTime;
                parameter.ExternalDocLastChangeDateTime = salesorder.ExternalDocLastChangeDateTime;
                parameter.PurchaseOrderByCustomer = salesorder.PurchaseOrderByCustomer;
                parameter.PurchaseOrderByShipToParty = salesorder.PurchaseOrderByShipToParty;
                parameter.CustomerPurchaseOrderType = salesorder.CustomerPurchaseOrderType;
                parameter.CustomerPurchaseOrderDate = salesorder.CustomerPurchaseOrderDate;
                parameter.SalesOrderDate = salesorder.SalesOrderDate;
                parameter.TotalNetAmount = salesorder.TotalNetAmount;
                parameter.OverallDeliveryStatus = salesorder.OverallDeliveryStatus;
                parameter.TotalBlockStatus = salesorder.TotalBlockStatus;
                parameter.OverallOrdReltdBillgStatus = salesorder.OverallOrdReltdBillgStatus;
                parameter.OverallSDDocReferenceStatus = salesorder.OverallSDDocReferenceStatus;
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
                parameter.ReferenceSDDocumentCategory = salesorder.ReferenceSDDocumentCategory;
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
                parameter.SalesOrderApprovalReason = salesorder.SalesOrderApprovalReason;
                parameter.SalesDocApprovalStatus = salesorder.SalesDocApprovalStatus;
                parameter.OverallSDProcessStatus = salesorder.OverallSDProcessStatus;
                parameter.TotalCreditCheckStatus = salesorder.TotalCreditCheckStatus;
                parameter.OverallTotalDeliveryStatus = salesorder.OverallTotalDeliveryStatus;
                parameter.OverallSDDocumentRejectionSts = salesorder.OverallSDDocumentRejectionSts;
                parameter.BillingDocumentDate = salesorder.BillingDocumentDate;
                parameter.ContractAccount = salesorder.ContractAccount;
                parameter.AdditionalValueDays = salesorder.AdditionalValueDays;
                parameter.CustomerPurchaseOrderSuplmnt = salesorder.CustomerPurchaseOrderSuplmnt;
                parameter.ServicesRenderedDate = salesorder.ServicesRenderedDate;
                parameter.to_Item = salesorder.to_Item;

                if (salesorder.to_Item[0].RequestedQuantityUnit == "BOX")
                {
                    parameter.to_Item[0].RequestedQuantityUnit = "BOX";
                    parameter.to_Item[0].RequestedQuantitySAPUnit = "ZBX";
                    parameter.to_Item[0].RequestedQuantityISOUnit = "BX";
                    parameter.to_Item[0].OrderQuantityUnit = "BOX";
                    parameter.to_Item[0].OrderQuantitySAPUnit = "ZBX";
                    parameter.to_Item[0].OrderQuantityISOUnit = "BX";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "CRT")
                {
                    parameter.to_Item[0].RequestedQuantityUnit = "CRT";
                    parameter.to_Item[0].RequestedQuantitySAPUnit = "KI";
                    parameter.to_Item[0].RequestedQuantityISOUnit = "CR";
                    parameter.to_Item[0].OrderQuantityUnit = "CRT";
                    parameter.to_Item[0].OrderQuantitySAPUnit = "KI";
                    parameter.to_Item[0].OrderQuantityISOUnit = "CR";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "L")
                {
                    parameter.to_Item[0].RequestedQuantityUnit = "L";
                    parameter.to_Item[0].RequestedQuantitySAPUnit = "L";
                    parameter.to_Item[0].RequestedQuantityISOUnit = "LTR";
                    parameter.to_Item[0].OrderQuantityUnit = "L";
                    parameter.to_Item[0].OrderQuantitySAPUnit = "L";
                    parameter.to_Item[0].OrderQuantityISOUnit = "LTR";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "KG")
                {
                    parameter.to_Item[0].RequestedQuantityUnit = "KG";
                    parameter.to_Item[0].RequestedQuantitySAPUnit = "KG";
                    parameter.to_Item[0].RequestedQuantityISOUnit = "KGM";
                    parameter.to_Item[0].OrderQuantityUnit = "KG";
                    parameter.to_Item[0].OrderQuantitySAPUnit = "KG";
                    parameter.to_Item[0].OrderQuantityISOUnit = "KGM";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "BAG")
                {
                    parameter.to_Item[0].RequestedQuantityUnit = "BAG";
                    parameter.to_Item[0].RequestedQuantitySAPUnit = "BAG";
                    parameter.to_Item[0].RequestedQuantityISOUnit = "BG";
                    parameter.to_Item[0].OrderQuantityUnit = "BAG";
                    parameter.to_Item[0].OrderQuantitySAPUnit = "BAG";
                    parameter.to_Item[0].OrderQuantityISOUnit = "BG";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "EA")
                {
                    parameter.to_Item[0].RequestedQuantityUnit = "EA";
                    parameter.to_Item[0].RequestedQuantitySAPUnit = "EA";
                    parameter.to_Item[0].RequestedQuantityISOUnit = "EA";
                    parameter.to_Item[0].OrderQuantityUnit = "EA";
                    parameter.to_Item[0].OrderQuantitySAPUnit = "EA";
                    parameter.to_Item[0].OrderQuantityISOUnit = "EA";
                }
                else
                {
                    parameter.to_Item[0].RequestedQuantityUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.to_Item[0].RequestedQuantitySAPUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.to_Item[0].RequestedQuantityISOUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.to_Item[0].OrderQuantityUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.to_Item[0].OrderQuantitySAPUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.to_Item[0].OrderQuantityISOUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                }




                string resString = new SalesOrderSAP(res_DestinationName[0].ConnectionName).SaveSalesOrder(parameter, salesorder.org_id);
                return Ok(resString);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("SaveSalesOrderItemsNew", Name = "SaveSalesOrderItemsNew")]
        public IActionResult SaveSalesOrderItemsNew(ReqSalesOrderNew salesorder)
        {
            try
            {

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = salesorder.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesorder.org_id;

                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                SalesOrderItems parameter = new SalesOrderItems();

                parameter.SalesOrder = salesorder.salesorder_id;
                parameter.SalesOrderItem = salesorder.to_Item[0].SalesOrderItem;
                parameter.Material = salesorder.to_Item[0].Material;
                parameter.PricingDate = salesorder.to_Item[0].PricingDate;
                parameter.RequestedQuantity = salesorder.to_Item[0].RequestedQuantity;
                parameter.ConfdDelivQtyInOrderQtyUnit = salesorder.to_Item[0].ConfdDelivQtyInOrderQtyUnit;
                parameter.BillingDocumentDate = salesorder.to_Item[0].BillingDocumentDate;

                // parameter.RequestedQuantityUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                // parameter.RequestedQuantitySAPUnit = salesorder.to_Item[0].RequestedQuantitySAPUnit;

                parameter.DeliveryDateQuantityIsFixed = salesorder.to_Item[0].DeliveryDateQuantityIsFixed;
                parameter.SlsDocIsRlvtForProofOfDeliv = salesorder.to_Item[0].DeliveryDateQuantityIsFixed;
                parameter.to_PricingElement = salesorder.to_Item[0].to_PricingElement;

                // if (salesorder.to_Item[0].RequestedQuantityUnit == "BOX")
                // {
                //     parameter.RequestedQuantityUnit = "BOX";
                //     parameter.RequestedQuantitySAPUnit = "ZBX";
                //     parameter.RequestedQuantityISOUnit = "BX";
                //     parameter.OrderQuantityUnit = "BOX";
                //     parameter.OrderQuantitySAPUnit = "ZBX";
                //     parameter.OrderQuantityISOUnit = "BX";
                // }
                // else if (salesorder.to_Item[0].RequestedQuantityUnit == "CRT")
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
                //     parameter.RequestedQuantityUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                //     parameter.RequestedQuantitySAPUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                //     parameter.RequestedQuantityISOUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                //     parameter.OrderQuantityUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                //     parameter.OrderQuantitySAPUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                //     parameter.OrderQuantityISOUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                // }

                if (salesorder.to_Item[0].RequestedQuantityUnit == "BOX")
                {
                    parameter.RequestedQuantityUnit = "BOX";
                    parameter.RequestedQuantitySAPUnit = "ZBX";
                    parameter.RequestedQuantityISOUnit = "BX";
                    parameter.OrderQuantityUnit = "BOX";
                    parameter.OrderQuantitySAPUnit = "ZBX";
                    parameter.OrderQuantityISOUnit = "BX";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "CRT")
                {
                    parameter.RequestedQuantityUnit = "CRT";
                    parameter.RequestedQuantitySAPUnit = "KI";
                    parameter.RequestedQuantityISOUnit = "CR";
                    parameter.OrderQuantityUnit = "CRT";
                    parameter.OrderQuantitySAPUnit = "KI";
                    parameter.OrderQuantityISOUnit = "CR";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "L")
                {
                    parameter.RequestedQuantityUnit = "L";
                    parameter.RequestedQuantitySAPUnit = "L";
                    parameter.RequestedQuantityISOUnit = "LTR";
                    parameter.OrderQuantityUnit = "L";
                    parameter.OrderQuantitySAPUnit = "L";
                    parameter.OrderQuantityISOUnit = "LTR";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "KG")
                {
                    parameter.RequestedQuantityUnit = "KG";
                    parameter.RequestedQuantitySAPUnit = "KG";
                    parameter.RequestedQuantityISOUnit = "KGM";
                    parameter.OrderQuantityUnit = "KG";
                    parameter.OrderQuantitySAPUnit = "KG";
                    parameter.OrderQuantityISOUnit = "KGM";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "BAG")
                {
                    parameter.RequestedQuantityUnit = "BAG";
                    parameter.RequestedQuantitySAPUnit = "BAG";
                    parameter.RequestedQuantityISOUnit = "BG";
                    parameter.OrderQuantityUnit = "BAG";
                    parameter.OrderQuantitySAPUnit = "BAG";
                    parameter.OrderQuantityISOUnit = "BG";
                }
                else if (salesorder.to_Item[0].RequestedQuantityUnit == "EA")
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
                    parameter.RequestedQuantityUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.RequestedQuantitySAPUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.RequestedQuantityISOUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.OrderQuantityUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.OrderQuantitySAPUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                    parameter.OrderQuantityISOUnit = salesorder.to_Item[0].RequestedQuantityUnit;
                }


                string resString = new SalesOrderSAP(res_DestinationName[0].ConnectionName).SaveSalesOrderItemsNew(parameter, salesorder.org_id, salesorder.method_name);
                return Ok(resString);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("DeleteSalesOrderItemsNew", Name = "DeleteSalesOrderItemsNew")]
        public IActionResult DeleteSalesOrderItemsNew(ReqSalesOrder salesorder)
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


                string res_output = new SalesOrderSAP(res_DestinationName[0].ConnectionName).DeleteSalesOrderItemsNews(salesorder.salesorder_id, salesorder.salesorderitem, salesorder.org_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("UpdateSalesOrderNew", Name = "UpdateSalesOrderNew")]
        public IActionResult UpdateSalesOrderNew(ReqSalesOrderNew salesorder)
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
                parameter.SoldToParty = salesorder.SoldToParty;
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





                string resString = new SalesOrderSAP(res_DestinationName[0].ConnectionName).UpdateSalesOrderNew(parameter, salesorder.salesorder_id, salesorder.org_id);
                return Ok(resString);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetSalesOrderProduct", Name = "GetSalesOrderProduct")]
        public IActionResult GetSalesOrderProduct(ReqInquiry inquirySearch)
        {
            try
            {
                if (inquirySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResProductMaster> res_Obj = new List<ResProductMaster>();
                string destination_name = inquirySearch.destination_name + "";
                res_Obj = new OrderDAL(destination_name).GetSalesOrderProduct(inquirySearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


    }
}
