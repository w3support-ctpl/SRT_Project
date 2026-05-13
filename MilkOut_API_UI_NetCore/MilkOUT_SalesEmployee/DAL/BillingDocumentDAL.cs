using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using Dapper;
using Newtonsoft.Json.Linq;
using System.Data;
using MilkOUT_SalesEmployee.Models;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
using System.Configuration;

namespace MilkOUT_SalesEmployee.DAL
{
    internal class BillingDocumentDAL
    {
        private IDbConnection db;
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;

        IEnumerable<string> cookies = new List<string>();
        CookieContainer cookieJar = new CookieContainer();

        public BillingDocumentDAL(string _SAPUserName, string _SAPPassword, string _SAPAPIURL)
        {
            SAPUserName = _SAPUserName;
            SAPPassword = _SAPPassword;
            SAPAPIURL = _SAPAPIURL;
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public string GetBillingDocumentByDealer(SalesEmployeeModel ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_HEADERBILL_CDS/YY1_Headerbill?$filter=BillingDocumentDate ge datetime'" + ReqObj.BillingDocumentDate + "' and BillingDocumentDate le datetime'" + ReqObj.BillingDocumentDate + "' and SoldToParty eq '" + ReqObj.SoldToParty + "'");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_HEADERBILL_CDS/YY1_Headerbill?$filter=BillingDocumentDate ge datetime'" + ReqObj.BillingDocumentDate + "' and BillingDocumentDate le datetime'" + ReqObj.BillingDocumentDate + "' and SoldToParty eq '" + ReqObj.SoldToParty + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (System.Net.WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })

                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders
                        .Accept
                        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        JArray resultsArray = (JArray)jsonResponse["d"]["results"];

                        for (int i = 0; i < resultsArray.Count; i++)
                        {
                            // Extract BillingDocument from each result
                            string billingDocument = resultsArray[i]["BillingDocument"].ToString();

                            // Call your method to process each BillingDocument
                            string result = GetBillingDocumentByBillingDocument(billingDocument, Org_Id);
                        }
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                    }
                    else
                    {
                    }




                    return resString;
                }
            }
            catch (Exception ex)
            {

                return "Error: =" + ex.Message;

            }
        }

        public string GetBillingDocumentByBillingDocument(string BillingDocument, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_BILLINGDATA_CDS/YY1_BILLINGDATA?$filter=BillingDocument eq '" + BillingDocument + "'");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_BILLINGDATA_CDS/YY1_BILLINGDATA?$filter=BillingDocument eq '" + BillingDocument + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (System.Net.WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })

                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders
                        .Accept
                        .Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        var results = jsonResponse["d"]["results"];
                        foreach (var billingData in results)
                        {
                        var parameters = new DynamicParameters();
                        parameters.Add("var_Method_Name", "Create");
                        parameters.Add("var_Org_Id", Org_Id);

                        parameters.Add("var_BillingDocument", billingData["BillingDocument"].ToString());
                        parameters.Add("var_BillingDocumentItem", billingData["BillingDocumentItem"].ToString());
                        parameters.Add("var_BillingDocumentItemText", billingData["BillingDocumentItemText"].ToString());
                        parameters.Add("var_SalesDocumentItemCategory", billingData["SalesDocumentItemCategory"].ToString());
                        parameters.Add("var_SalesDocumentItemType", billingData["SalesDocumentItemType"].ToString());
                        parameters.Add("var_ReturnItemProcessingType", billingData["ReturnItemProcessingType"].ToString());
                        parameters.Add("var_CreatedByUser", billingData["CreatedByUser"].ToString());
                        parameters.Add("var_CreationDate", billingData["CreationDate"].ToString());
                        parameters.Add("var_CreationTime", billingData["CreationTime"].ToString());
                        parameters.Add("var_ReferenceLogicalSystem", billingData["ReferenceLogicalSystem"].ToString());
                        parameters.Add("var_OrganizationDivision", billingData["OrganizationDivision"].ToString());
                        parameters.Add("var_Division", billingData["Division"].ToString());
                        parameters.Add("var_SalesOffice", billingData["SalesOffice"].ToString());
                        parameters.Add("var_Material", billingData["Material"].ToString());
                        parameters.Add("var_Product", billingData["Product"].ToString());
                        parameters.Add("var_OriginallyRequestedMaterial", billingData["OriginallyRequestedMaterial"].ToString());
                        parameters.Add("var_InternationalArticleNumber", billingData["InternationalArticleNumber"].ToString());
                        parameters.Add("var_PricingReferenceMaterial", billingData["PricingReferenceMaterial"].ToString());
                        parameters.Add("var_Batch_1", billingData["Batch_1"].ToString());
                        parameters.Add("var_ProductHierarchyNode", billingData["ProductHierarchyNode"].ToString());
                        parameters.Add("var_MaterialGroup", billingData["MaterialGroup"].ToString());
                        parameters.Add("var_ProductGroup", billingData["ProductGroup"].ToString());
                        parameters.Add("var_Plant", billingData["Plant"].ToString());
                        parameters.Add("var_StorageLocation", billingData["StorageLocation"].ToString());
                        parameters.Add("var_PlantRegion", billingData["PlantRegion"].ToString());
                        parameters.Add("var_PlantCounty", billingData["PlantCounty"].ToString());
                        parameters.Add("var_PlantCity", billingData["PlantCity"].ToString());
                        parameters.Add("var_TransitPlant", billingData["TransitPlant"].ToString());
                        parameters.Add("var_BillingQuantity", billingData["BillingQuantity"].ToString());
                        parameters.Add("var_BillingQuantityUnit", billingData["BillingQuantityUnit"].ToString());
                        parameters.Add("var_BillingQuantityInBaseUnit", billingData["BillingQuantityInBaseUnit"].ToString());
                        parameters.Add("var_BaseUnit", billingData["BaseUnit"].ToString());
                        parameters.Add("var_BillingToBaseQuantityDnmntr", billingData["BillingToBaseQuantityDnmntr"].ToString());
                        parameters.Add("var_BillingToBaseQuantityNmrtr", billingData["BillingToBaseQuantityNmrtr"].ToString());
                        parameters.Add("var_ItemGrossWeight", billingData["ItemGrossWeight"].ToString());
                        parameters.Add("var_ItemNetWeight", billingData["ItemNetWeight"].ToString());
                        parameters.Add("var_ItemWeightUnit", billingData["ItemWeightUnit"].ToString());
                        parameters.Add("var_BillToPartyCountry", billingData["BillToPartyCountry"].ToString());
                        parameters.Add("var_BillToPartyRegion", billingData["BillToPartyRegion"].ToString());
                        parameters.Add("var_BillingPlanRule", billingData["BillingPlanRule"].ToString());
                        parameters.Add("var_BillingPlan", billingData["BillingPlan"].ToString());
                        parameters.Add("var_BillingPlanItem", billingData["BillingPlanItem"].ToString());
                        parameters.Add("var_NetAmount", billingData["NetAmount"].ToString());
                        parameters.Add("var_TransactionCurrency", billingData["TransactionCurrency"].ToString());
                        parameters.Add("var_GrossAmount", billingData["GrossAmount"].ToString());
                        parameters.Add("var_PricingDate", billingData["PricingDate"].ToString());
                        parameters.Add("var_PriceDetnExchangeRate", billingData["PriceDetnExchangeRate"].ToString());
                        parameters.Add("var_PricingScaleQuantityInBaseUnit", billingData["PricingScaleQuantityInBaseUnit"].ToString());
                        parameters.Add("var_TaxAmount", billingData["TaxAmount"].ToString());
                        parameters.Add("var_CostAmount", billingData["CostAmount"].ToString());
                        parameters.Add("var_Subtotal2Amount", billingData["Subtotal2Amount"].ToString());
                        parameters.Add("var_Subtotal3Amount", billingData["Subtotal3Amount"].ToString());
                        parameters.Add("var_Subtotal4Amount", billingData["Subtotal4Amount"].ToString());
                        parameters.Add("var_Subtotal1Amount", billingData["Subtotal1Amount"].ToString());
                        parameters.Add("var_Subtotal5Amount", billingData["Subtotal5Amount"].ToString());
                        parameters.Add("var_Subtotal6Amount", billingData["Subtotal6Amount"].ToString());
                        parameters.Add("var_StatisticalValueControl", billingData["StatisticalValueControl"].ToString());
                        parameters.Add("var_CashDiscountIsDeductible", billingData["CashDiscountIsDeductible"].ToString());
                        parameters.Add("var_CustomerConditionGroup1", billingData["CustomerConditionGroup1"].ToString());
                        parameters.Add("var_CustomerConditionGroup2", billingData["CustomerConditionGroup2"].ToString());
                        parameters.Add("var_CustomerConditionGroup3", billingData["CustomerConditionGroup3"].ToString());
                        parameters.Add("var_CustomerConditionGroup4", billingData["CustomerConditionGroup4"].ToString());
                        parameters.Add("var_CustomerConditionGroup5", billingData["CustomerConditionGroup5"].ToString());
                        parameters.Add("var_ManualPriceChangeType", billingData["ManualPriceChangeType"].ToString());
                        parameters.Add("var_MaterialPricingGroup", billingData["MaterialPricingGroup"].ToString());
                        parameters.Add("var_MainItemPricingRefMaterial", billingData["MainItemPricingRefMaterial"].ToString());
                        parameters.Add("var_MainItemMaterialPricingGroup", billingData["MainItemMaterialPricingGroup"].ToString());
                        parameters.Add("var_TimeSheetOvertimeCategory", billingData["TimeSheetOvertimeCategory"].ToString());
                        parameters.Add("var_PricingRelevance", billingData["PricingRelevance"].ToString());
                        parameters.Add("var_DepartureCountry", billingData["DepartureCountry"].ToString());
                        parameters.Add("var_ZeroVATRsn", billingData["ZeroVATRsn"].ToString());
                        parameters.Add("var_TaxCode", billingData["TaxCode"].ToString());
                        parameters.Add("var_TaxRateValidityStartDate", billingData["TaxRateValidityStartDate"].ToString());
                        parameters.Add("var_CountryOfOrigin", billingData["CountryOfOrigin"].ToString());
                        parameters.Add("var_RegionOfOrigin", billingData["RegionOfOrigin"].ToString());
                        parameters.Add("var_CommodityCode", billingData["CommodityCode"].ToString());
                        parameters.Add("var_EligibleAmountForCashDiscount", billingData["EligibleAmountForCashDiscount"].ToString());
                        parameters.Add("var_BusinessArea", billingData["BusinessArea"].ToString());
                        parameters.Add("var_ProfitCenter", billingData["ProfitCenter"].ToString());
                        parameters.Add("var_OrderID", billingData["OrderID"].ToString());
                        parameters.Add("var_ProfitabilitySegment_2", billingData["ProfitabilitySegment_2"].ToString());
                        parameters.Add("var_BillingPerformancePeriodEndDte", billingData["BillingPerformancePeriodEndDte"].ToString());
                        parameters.Add("var_ProfitabilitySegment", billingData["ProfitabilitySegment"].ToString());
                        parameters.Add("var_CostCenter", billingData["CostCenter"].ToString());
                        parameters.Add("var_OriginSDDocument", billingData["OriginSDDocument"].ToString());
                        parameters.Add("var_OriginSDDocumentItem", billingData["OriginSDDocumentItem"].ToString());
                        parameters.Add("var_PriceDetnExchangeRateDate", billingData["PriceDetnExchangeRateDate"].ToString());
                        parameters.Add("var_MatlAccountAssignmentGroup", billingData["MatlAccountAssignmentGroup"].ToString());
                        parameters.Add("var_ReferenceSDDocument", billingData["ReferenceSDDocument"].ToString());
                        parameters.Add("var_ReferenceSDDocumentItem", billingData["ReferenceSDDocumentItem"].ToString());
                        parameters.Add("var_ReferenceSDDocumentCategory", billingData["ReferenceSDDocumentCategory"].ToString());
                        parameters.Add("var_SalesDocument", billingData["SalesDocument"].ToString());
                        parameters.Add("var_SalesDocumentItem", billingData["SalesDocumentItem"].ToString());
                        parameters.Add("var_SalesSDDocumentCategory", billingData["SalesSDDocumentCategory"].ToString());
                        parameters.Add("var_HigherLevelItem", billingData["HigherLevelItem"].ToString());
                        parameters.Add("var_HigherLvlItmOfBatSpltItm", billingData["HigherLvlItmOfBatSpltItm"].ToString());
                        parameters.Add("var_BillingDocumentItemInPartSgmt", billingData["BillingDocumentItemInPartSgmt"].ToString());
                        parameters.Add("var_ExternalReferenceDocument", billingData["ExternalReferenceDocument"].ToString());
                        parameters.Add("var_ExternalReferenceDocumentItem", billingData["ExternalReferenceDocumentItem"].ToString());
                        parameters.Add("var_BillingDocExtReferenceDocItem", billingData["BillingDocExtReferenceDocItem"].ToString());
                        parameters.Add("var_PrelimBillingDocument", billingData["PrelimBillingDocument"].ToString());
                        parameters.Add("var_PrelimBillingDocumentItem", billingData["PrelimBillingDocumentItem"].ToString());
                        parameters.Add("var_SalesGroup", billingData["SalesGroup"].ToString());
                        parameters.Add("var_AdditionalCustomerGroup1", billingData["AdditionalCustomerGroup1"].ToString());
                        parameters.Add("var_AdditionalCustomerGroup2", billingData["AdditionalCustomerGroup2"].ToString());
                        parameters.Add("var_AdditionalCustomerGroup3", billingData["AdditionalCustomerGroup3"].ToString());
                        parameters.Add("var_AdditionalCustomerGroup4", billingData["AdditionalCustomerGroup4"].ToString());
                        parameters.Add("var_AdditionalCustomerGroup5", billingData["AdditionalCustomerGroup5"].ToString());
                        parameters.Add("var_SDDocumentReason", billingData["SDDocumentReason"].ToString());
                        parameters.Add("var_RebateBasisAmount", billingData["RebateBasisAmount"].ToString());
                        parameters.Add("var_VolumeRebateGroup", billingData["VolumeRebateGroup"].ToString());
                        parameters.Add("var_RetailPromotion", billingData["RetailPromotion"].ToString());
                        parameters.Add("var_ItemIsRelevantForCredit", billingData["ItemIsRelevantForCredit"].ToString());
                        parameters.Add("var_CreditRelatedPrice", billingData["CreditRelatedPrice"].ToString());
                        parameters.Add("var_SalesOrderSalesDistrict", billingData["SalesOrderSalesDistrict"].ToString());
                        parameters.Add("var_SalesOrderCustomerGroup", billingData["SalesOrderCustomerGroup"].ToString());
                        parameters.Add("var_SalesDeal", billingData["SalesDeal"].ToString());
                        parameters.Add("var_SalesPromotion", billingData["SalesPromotion"].ToString());
                        parameters.Add("var_SalesOrderCustomerPriceGroup", billingData["SalesOrderCustomerPriceGroup"].ToString());
                        parameters.Add("var_SalesOrderPriceListType", billingData["SalesOrderPriceListType"].ToString());
                        parameters.Add("var_SalesOrderSalesOrganization", billingData["SalesOrderSalesOrganization"].ToString());
                        parameters.Add("var_SalesOrderDistributionChannel", billingData["SalesOrderDistributionChannel"].ToString());
                        parameters.Add("var_SalesDocIsCreatedFromReference", billingData["SalesDocIsCreatedFromReference"].ToString());
                        parameters.Add("var_ShippingPoint", billingData["ShippingPoint"].ToString());
                        parameters.Add("var_ServiceDocumentType", billingData["ServiceDocumentType"].ToString());
                        parameters.Add("var_ServiceDocument", billingData["ServiceDocument"].ToString());
                        parameters.Add("var_ServiceDocumentItem", billingData["ServiceDocumentItem"].ToString());
                        parameters.Add("var_BusinessSolutionOrder", billingData["BusinessSolutionOrder"].ToString());
                        parameters.Add("var_BusinessSolutionOrderItem", billingData["BusinessSolutionOrderItem"].ToString());
                        parameters.Add("var_HigherLevelItemUsage", billingData["HigherLevelItemUsage"].ToString());
                        parameters.Add("var_BillingDocumentIsTemporary", billingData["BillingDocumentIsTemporary"].ToString());
                        parameters.Add("var_SDDocumentCategory", billingData["SDDocumentCategory"].ToString());
                        parameters.Add("var_BillingDocumentType", billingData["BillingDocumentType"].ToString());
                        parameters.Add("var_SalesOrganization", billingData["SalesOrganization"].ToString());
                        parameters.Add("var_DistributionChannel", billingData["DistributionChannel"].ToString());
                        parameters.Add("var_CustomerPriceGroup", billingData["CustomerPriceGroup"].ToString());
                        parameters.Add("var_CustomerGroup", billingData["CustomerGroup"].ToString());
                        parameters.Add("var_Country", billingData["Country"].ToString());
                        parameters.Add("var_Region", billingData["Region"].ToString());
                        parameters.Add("var_CityCode", billingData["CityCode"].ToString());
                        parameters.Add("var_SalesDistrict", billingData["SalesDistrict"].ToString());
                        parameters.Add("var_OverallSDProcessStatus", billingData["OverallSDProcessStatus"].ToString());
                        parameters.Add("var_OverallBillingStatus", billingData["OverallBillingStatus"].ToString());
                        parameters.Add("var_SoldToParty", billingData["SoldToParty"].ToString());
                        parameters.Add("var_PayerParty", billingData["PayerParty"].ToString());
                        parameters.Add("var_BillingDocumentDate", billingData["BillingDocumentDate"].ToString());
                        parameters.Add("var_CompanyCode", billingData["CompanyCode"].ToString());
                        parameters.Add("var_County", billingData["County"].ToString());
                        parameters.Add("var_CustomerRebateAgreement", billingData["CustomerRebateAgreement"].ToString());
                        parameters.Add("var_BillingDocumentCategory", billingData["BillingDocumentCategory"].ToString());
                        parameters.Add("var_PricingDocument", billingData["PricingDocument"].ToString());
                        parameters.Add("var_CancelledBillingDocument", billingData["CancelledBillingDocument"].ToString());
                        parameters.Add("var_ShipToParty", billingData["ShipToParty"].ToString());
                        parameters.Add("var_BillToParty", billingData["BillToParty"].ToString());
                        parameters.Add("var_SalesEmployee", billingData["SalesEmployee"].ToString());
                        parameters.Add("var_ResponsibleEmployee", billingData["ResponsibleEmployee"].ToString());
                        parameters.Add("var_Batch", billingData["Batch"].ToString());
                        parameters.Add("var_ShelfLifeExpirationDate", billingData["ShelfLifeExpirationDate"].ToString());
                        parameters.Add("var_ManufactureDate", billingData["ManufactureDate"].ToString());
                        parameters.Add("var_TotalTaxAmount", billingData["TotalTaxAmount"].ToString());


                        // Call stored procedure to insert the data into your database
                        var result = db.Execute("USP_BillingDocument_Set", parameters, commandType: CommandType.StoredProcedure);


                        }
                            

            
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                    }
                    else
                    {
                    }


                    return resString;
                }
            }
            catch (Exception ex)
            {

                return "Error: =" + ex.Message;

            }
        }
    }
}
