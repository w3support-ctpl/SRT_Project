using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Security.Cryptography;
using System.Data;
using Dapper;
using Newtonsoft.Json;
using MilkOUT_SalesEmployee.Models;
using MySql.Data.MySqlClient;

namespace MilkOUT_SalesEmployee.DAL
{
    internal class SalesEmployeeDAL
    {
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;
        private string ConnectionName;
        private string Environment;
        private string OrgId;
        private IDbConnection db;

        public SalesEmployeeDAL()
        {

            OrgId = System.Configuration.ConfigurationManager.AppSettings["OrgId"].ToString();
            Environment = System.Configuration.ConfigurationManager.AppSettings["SAPEnvironment"].ToString();

            switch (Environment)
            {
                case "PRD": // Production
                    SAPUserName = "CTPLABAP_SRTPRD";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my409033-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my407919-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionUAT";
                    break;
                case "DEV": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my406966-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionDEV";
                    break;
                default: // DEV
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my406966-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionDEV";
                    break;

            }
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public void Main()
        {
            try
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = "Get_Dealer",
                    var_Org_Id = OrgId
                });

                List<SalesEmployeeModel> PendingDealerList = new List<SalesEmployeeModel>();
                PendingDealerList = this.db.Query<SalesEmployeeModel>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

                Console.WriteLine(PendingDealerList.Count + " Dealer Found");

                for (int i = 0; i < PendingDealerList.Count; i++)
                {
                    new BillingDocumentDAL(SAPUserName, SAPPassword, SAPAPIURL).GetBillingDocumentByDealer(PendingDealerList[i], OrgId);
                    Console.WriteLine("Dealer Entry " + i + " Posted");
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in finding new Dealer records");
            }


            try
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = "Update",
                    var_Org_Id = OrgId,
                    var_BillingDocument = "",
                    var_BillingDocumentItem = "",
                    var_BillingDocumentItemText = "",
                    var_SalesDocumentItemCategory = "",
                    var_SalesDocumentItemType = "",
                    var_ReturnItemProcessingType = "",
                    var_CreatedByUser = "",
                    var_CreationDate = "",
                    var_CreationTime = "",
                    var_ReferenceLogicalSystem = "",
                    var_OrganizationDivision = "",
                    var_Division = "",
                    var_SalesOffice = "",
                    var_Material = "",
                    var_Product = "",
                    var_OriginallyRequestedMaterial = "",
                    var_InternationalArticleNumber = "",
                    var_PricingReferenceMaterial = "",
                    var_Batch_1 = "",
                    var_ProductHierarchyNode = "",
                    var_MaterialGroup = "",
                    var_ProductGroup = "",
                    var_Plant = "",
                    var_StorageLocation = "",
                    var_PlantRegion = "",
                    var_PlantCounty = "",
                    var_PlantCity = "",
                    var_TransitPlant = "",
                    var_BillingQuantity = "",
                    var_BillingQuantityUnit = "",
                    var_BillingQuantityInBaseUnit = "",
                    var_BaseUnit = "",
                    var_BillingToBaseQuantityDnmntr = "",
                    var_BillingToBaseQuantityNmrtr = "",
                    var_ItemGrossWeight = "",
                    var_ItemNetWeight = "",
                    var_ItemWeightUnit = "",
                    var_BillToPartyCountry = "",
                    var_BillToPartyRegion = "",
                    var_BillingPlanRule = "",
                    var_BillingPlan = "",
                    var_BillingPlanItem = "",
                    var_NetAmount = "",
                    var_TransactionCurrency = "",
                    var_GrossAmount = "",
                    var_PricingDate = "",
                    var_PriceDetnExchangeRate = "",
                    var_PricingScaleQuantityInBaseUnit = "",
                    var_TaxAmount = "",
                    var_CostAmount = "",
                    var_Subtotal2Amount = "",
                    var_Subtotal3Amount = "",
                    var_Subtotal4Amount = "",
                    var_Subtotal1Amount = "",
                    var_Subtotal5Amount = "",
                    var_Subtotal6Amount = "",
                    var_StatisticalValueControl = "",
                    var_CashDiscountIsDeductible = "",
                    var_CustomerConditionGroup1 = "",
                    var_CustomerConditionGroup2 = "",
                    var_CustomerConditionGroup3 = "",
                    var_CustomerConditionGroup4 = "",
                    var_CustomerConditionGroup5 = "",
                    var_ManualPriceChangeType = "",
                    var_MaterialPricingGroup = "",
                    var_MainItemPricingRefMaterial = "",
                    var_MainItemMaterialPricingGroup = "",
                    var_TimeSheetOvertimeCategory = "",
                    var_PricingRelevance = "",
                    var_DepartureCountry = "",
                    var_ZeroVATRsn = "",
                    var_TaxCode = "",
                    var_TaxRateValidityStartDate = "",
                    var_CountryOfOrigin = "",
                    var_RegionOfOrigin = "",
                    var_CommodityCode = "",
                    var_EligibleAmountForCashDiscount = "",
                    var_BusinessArea = "",
                    var_ProfitCenter = "",
                    var_OrderID = "",
                    var_ProfitabilitySegment_2 = "",
                    var_BillingPerformancePeriodEndDte = "",
                    var_ProfitabilitySegment = "",
                    var_CostCenter = "",
                    var_OriginSDDocument = "",
                    var_OriginSDDocumentItem = "",
                    var_PriceDetnExchangeRateDate = "",
                    var_MatlAccountAssignmentGroup = "",
                    var_ReferenceSDDocument = "",
                    var_ReferenceSDDocumentItem = "",
                    var_ReferenceSDDocumentCategory = "",
                    var_SalesDocument = "",
                    var_SalesDocumentItem = "",
                    var_SalesSDDocumentCategory = "",
                    var_HigherLevelItem = "",
                    var_HigherLvlItmOfBatSpltItm = "",
                    var_BillingDocumentItemInPartSgmt = "",
                    var_ExternalReferenceDocument = "",
                    var_ExternalReferenceDocumentItem = "",
                    var_BillingDocExtReferenceDocItem = "",
                    var_PrelimBillingDocument = "",
                    var_PrelimBillingDocumentItem = "",
                    var_SalesGroup = "",
                    var_AdditionalCustomerGroup1 = "",
                    var_AdditionalCustomerGroup2 = "",
                    var_AdditionalCustomerGroup3 = "",
                    var_AdditionalCustomerGroup4 = "",
                    var_AdditionalCustomerGroup5 = "",
                    var_SDDocumentReason = "",
                    var_RebateBasisAmount = "",
                    var_VolumeRebateGroup = "",
                    var_RetailPromotion = "",
                    var_ItemIsRelevantForCredit = "",
                    var_CreditRelatedPrice = "",
                    var_SalesOrderSalesDistrict = "",
                    var_SalesOrderCustomerGroup = "",
                    var_SalesDeal = "",
                    var_SalesPromotion = "",
                    var_SalesOrderCustomerPriceGroup = "",
                    var_SalesOrderPriceListType = "",
                    var_SalesOrderSalesOrganization = "",
                    var_SalesOrderDistributionChannel = "",
                    var_SalesDocIsCreatedFromReference = "",
                    var_ShippingPoint = "",
                    var_ServiceDocumentType = "",
                    var_ServiceDocument = "",
                    var_ServiceDocumentItem = "",
                    var_BusinessSolutionOrder = "",
                    var_BusinessSolutionOrderItem = "",
                    var_HigherLevelItemUsage = "",
                    var_BillingDocumentIsTemporary = "",
                    var_SDDocumentCategory = "",
                    var_BillingDocumentType = "",
                    var_SalesOrganization = "",
                    var_DistributionChannel = "",
                    var_CustomerPriceGroup = "",
                    var_CustomerGroup = "",
                    var_Country = "",
                    var_Region = "",
                    var_CityCode = "",
                    var_SalesDistrict = "",
                    var_OverallSDProcessStatus = "",
                    var_OverallBillingStatus = "",
                    var_SoldToParty = "",
                    var_PayerParty = "",
                    var_BillingDocumentDate = "",
                    var_CompanyCode = "",
                    var_County = "",
                    var_CustomerRebateAgreement = "",
                    var_BillingDocumentCategory = "",
                    var_PricingDocument = "",
                    var_CancelledBillingDocument = "",
                    var_ShipToParty = "",
                    var_BillToParty = "",
                    var_SalesEmployee = "",
                    var_ResponsibleEmployee = "",
                    var_Batch = "",
                    var_ShelfLifeExpirationDate = "",
                    var_ManufactureDate = "",
                    var_TotalTaxAmount = ""

                });

                var result = db.Query("USP_BillingDocument_Set", parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
                Console.WriteLine("Stored Procedure executed successfully");

            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in finding Rate");
            }



            // try
            // {
            //     var parameters = new DynamicParameters(new
            //     {
            //         var_Method_Name = "Get_Billing_Document",
            //         var_Org_Id = OrgId
            //     });

            //     List<SalesEmployeeModel> PendingDealerList = new List<SalesEmployeeModel>();
            //     PendingDealerList = this.db.Query<SalesEmployeeModel>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            //     Console.WriteLine(PendingDealerList.Count + " Dealer Found");

            //     for (int i = 0; i < PendingDealerList.Count; i++)
            //     {
            //         new BillingDocumentDAL(SAPUserName, SAPPassword, SAPAPIURL).GetBillingDocumentByDealer(PendingDealerList[i], OrgId);


            //     var parameterss = new DynamicParameters(new
            //     {
            //         var_Method_Name = "Update_V2",
            //         var_Org_Id = OrgId,
            //         var_BillingDocument = "",
            //         var_BillingDocumentItem = "",
            //         var_BillingDocumentItemText = "",
            //         var_SalesDocumentItemCategory = "",
            //         var_SalesDocumentItemType = "",
            //         var_ReturnItemProcessingType = "",
            //         var_CreatedByUser = "",
            //         var_CreationDate = PendingDealerList[i].BillingDocumentDate,
            //         var_CreationTime = "",
            //         var_ReferenceLogicalSystem = "",
            //         var_OrganizationDivision = "",
            //         var_Division = "",
            //         var_SalesOffice = "",
            //         var_Material = "",
            //         var_Product = "",
            //         var_OriginallyRequestedMaterial = "",
            //         var_InternationalArticleNumber = "",
            //         var_PricingReferenceMaterial = "",
            //         var_Batch_1 = "",
            //         var_ProductHierarchyNode = "",
            //         var_MaterialGroup = "",
            //         var_ProductGroup = "",
            //         var_Plant = "",
            //         var_StorageLocation = "",
            //         var_PlantRegion = "",
            //         var_PlantCounty = "",
            //         var_PlantCity = "",
            //         var_TransitPlant = "",
            //         var_BillingQuantity = "",
            //         var_BillingQuantityUnit = "",
            //         var_BillingQuantityInBaseUnit = "",
            //         var_BaseUnit = "",
            //         var_BillingToBaseQuantityDnmntr = "",
            //         var_BillingToBaseQuantityNmrtr = "",
            //         var_ItemGrossWeight = "",
            //         var_ItemNetWeight = "",
            //         var_ItemWeightUnit = "",
            //         var_BillToPartyCountry = "",
            //         var_BillToPartyRegion = "",
            //         var_BillingPlanRule = "",
            //         var_BillingPlan = "",
            //         var_BillingPlanItem = "",
            //         var_NetAmount = "",
            //         var_TransactionCurrency = "",
            //         var_GrossAmount = "",
            //         var_PricingDate = "",
            //         var_PriceDetnExchangeRate = "",
            //         var_PricingScaleQuantityInBaseUnit = "",
            //         var_TaxAmount = "",
            //         var_CostAmount = "",
            //         var_Subtotal2Amount = "",
            //         var_Subtotal3Amount = "",
            //         var_Subtotal4Amount = "",
            //         var_Subtotal1Amount = "",
            //         var_Subtotal5Amount = "",
            //         var_Subtotal6Amount = "",
            //         var_StatisticalValueControl = "",
            //         var_CashDiscountIsDeductible = "",
            //         var_CustomerConditionGroup1 = "",
            //         var_CustomerConditionGroup2 = "",
            //         var_CustomerConditionGroup3 = "",
            //         var_CustomerConditionGroup4 = "",
            //         var_CustomerConditionGroup5 = "",
            //         var_ManualPriceChangeType = "",
            //         var_MaterialPricingGroup = "",
            //         var_MainItemPricingRefMaterial = "",
            //         var_MainItemMaterialPricingGroup = "",
            //         var_TimeSheetOvertimeCategory = "",
            //         var_PricingRelevance = "",
            //         var_DepartureCountry = "",
            //         var_ZeroVATRsn = "",
            //         var_TaxCode = "",
            //         var_TaxRateValidityStartDate = "",
            //         var_CountryOfOrigin = "",
            //         var_RegionOfOrigin = "",
            //         var_CommodityCode = "",
            //         var_EligibleAmountForCashDiscount = "",
            //         var_BusinessArea = "",
            //         var_ProfitCenter = "",
            //         var_OrderID = "",
            //         var_ProfitabilitySegment_2 = "",
            //         var_BillingPerformancePeriodEndDte = "",
            //         var_ProfitabilitySegment = "",
            //         var_CostCenter = "",
            //         var_OriginSDDocument = "",
            //         var_OriginSDDocumentItem = "",
            //         var_PriceDetnExchangeRateDate = "",
            //         var_MatlAccountAssignmentGroup = "",
            //         var_ReferenceSDDocument = "",
            //         var_ReferenceSDDocumentItem = "",
            //         var_ReferenceSDDocumentCategory = "",
            //         var_SalesDocument = "",
            //         var_SalesDocumentItem = "",
            //         var_SalesSDDocumentCategory = "",
            //         var_HigherLevelItem = "",
            //         var_HigherLvlItmOfBatSpltItm = "",
            //         var_BillingDocumentItemInPartSgmt = "",
            //         var_ExternalReferenceDocument = "",
            //         var_ExternalReferenceDocumentItem = "",
            //         var_BillingDocExtReferenceDocItem = "",
            //         var_PrelimBillingDocument = "",
            //         var_PrelimBillingDocumentItem = "",
            //         var_SalesGroup = "",
            //         var_AdditionalCustomerGroup1 = "",
            //         var_AdditionalCustomerGroup2 = "",
            //         var_AdditionalCustomerGroup3 = "",
            //         var_AdditionalCustomerGroup4 = "",
            //         var_AdditionalCustomerGroup5 = "",
            //         var_SDDocumentReason = "",
            //         var_RebateBasisAmount = "",
            //         var_VolumeRebateGroup = "",
            //         var_RetailPromotion = "",
            //         var_ItemIsRelevantForCredit = "",
            //         var_CreditRelatedPrice = "",
            //         var_SalesOrderSalesDistrict = "",
            //         var_SalesOrderCustomerGroup = "",
            //         var_SalesDeal = "",
            //         var_SalesPromotion = "",
            //         var_SalesOrderCustomerPriceGroup = "",
            //         var_SalesOrderPriceListType = "",
            //         var_SalesOrderSalesOrganization = "",
            //         var_SalesOrderDistributionChannel = "",
            //         var_SalesDocIsCreatedFromReference = "",
            //         var_ShippingPoint = "",
            //         var_ServiceDocumentType = "",
            //         var_ServiceDocument = "",
            //         var_ServiceDocumentItem = "",
            //         var_BusinessSolutionOrder = "",
            //         var_BusinessSolutionOrderItem = "",
            //         var_HigherLevelItemUsage = "",
            //         var_BillingDocumentIsTemporary = "",
            //         var_SDDocumentCategory = "",
            //         var_BillingDocumentType = "",
            //         var_SalesOrganization = "",
            //         var_DistributionChannel = "",
            //         var_CustomerPriceGroup = "",
            //         var_CustomerGroup = "",
            //         var_Country = "",
            //         var_Region = "",
            //         var_CityCode = "",
            //         var_SalesDistrict = "",
            //         var_OverallSDProcessStatus = "",
            //         var_OverallBillingStatus = "",
            //         var_SoldToParty = "",
            //         var_PayerParty = "",
            //         var_BillingDocumentDate = "",
            //         var_CompanyCode = "",
            //         var_County = "",
            //         var_CustomerRebateAgreement = "",
            //         var_BillingDocumentCategory = "",
            //         var_PricingDocument = "",
            //         var_CancelledBillingDocument = "",
            //         var_ShipToParty = "",
            //         var_BillToParty = "",
            //         var_SalesEmployee = "",
            //         var_ResponsibleEmployee = "",
            //         var_Batch = "",
            //         var_ShelfLifeExpirationDate = "",
            //         var_ManufactureDate = "",
            //         var_TotalTaxAmount = ""

            //     });

            //     var result = db.Query("USP_BillingDocument_Set", parameterss, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();
            //     Console.WriteLine("Stored Procedure executed successfully");


            //         Console.WriteLine("Dealer Entry " + i + " Posted");
            //     }

            // }
            // catch (Exception ex)
            // {
            //     Console.WriteLine("Error in finding new Dealer records");
            // }

        }



    }
}
