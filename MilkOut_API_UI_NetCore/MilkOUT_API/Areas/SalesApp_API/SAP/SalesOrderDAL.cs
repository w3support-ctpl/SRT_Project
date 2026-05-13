using Dapper;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.SalesApp_API.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Net;
using System.Net.Http.Headers;
using System.Text;

namespace MilkOUT_API.Areas.SalesApp_API.SAP
{
    public class SalesOrderDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;
        private string ConnectionName;

        IEnumerable<string> cookies = new List<string>();
        CookieContainer cookieJar = new CookieContainer();

        public SalesOrderDAL(string Destination)
        {

            switch (Destination)
            {
                case "PRD": // Production
                    SAPUserName = "" + configuration.GetValue("SAPPrdSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPPrdSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPPrdSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT": // UAT
                    SAPUserName = "" + configuration.GetValue("SAPUatSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPUatSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPUatSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionUAT";
                    break;
                case "DEV": // UAT
                    SAPUserName = "" + configuration.GetValue("SAPDevSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPDevSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPDevSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionDEV";
                    break;
                default: // DEV
                    SAPUserName = "" + configuration.GetValue("SAPDevSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPDevSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPDevSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionDEV";
                    break;

            }
        }





        public string GetAllSalesOrder(string dealer_code, string formattedStartDate, string formattedEndDate)
        {



            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?$filter=SalesOrderDate ge datetime'" + formattedStartDate + "' and SalesOrderDate le datetime'" + formattedEndDate + "' and SoldToParty  eq '" + dealer_code + "'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?$filter=SalesOrderDate ge datetime'" + formattedStartDate + "' and SalesOrderDate le datetime'" + formattedEndDate + "' and SoldToParty  eq '" + dealer_code + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();


                }
                catch (WebException ex)
                {

                    return ex.Message.ToString();
                }



                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);



                    List<ResGetSalesOrderHeader> salesOrderHeader = new List<ResGetSalesOrderHeader>();

                    if (jsonResponse.ContainsKey("d"))
                    {
                        var resOutput = jsonResponse["d"]["results"];

                        // int rescount = resOutput.Count;

                        dynamic res_obj = JsonConvert.DeserializeObject(resOutput.ToString());

                        int res_Cnt = res_obj.Count;


                        if (res_Cnt > 0)
                        {
                            for (int i = 0; i < res_Cnt; i++)
                            {
                                ResGetSalesOrderHeader res_Header = new ResGetSalesOrderHeader();
                                res_Header.SalesOrder = res_obj[i]["SalesOrder"];
                                res_Header.PurchaseOrderByCustomer = res_obj[i]["PurchaseOrderByCustomer"];
                                res_Header.TotalNetAmount = res_obj[i]["TotalNetAmount"];
                                res_Header.TransactionCurrency = res_obj[i]["TransactionCurrency"];
                                res_Header.SalesGroup = res_obj[i]["SalesGroup"];
                                res_Header.SalesOffice = res_obj[i]["SalesOffice"];
                                res_Header.SalesOrganization = res_obj[i]["SalesOrganization"];
                                res_Header.DistributionChannel = res_obj[i]["DistributionChannel"];
                                res_Header.OrganizationDivision = res_obj[i]["OrganizationDivision"];
                                // Concatenate SalesGroup, SalesOffice, SalesOrganization, DistributionChannel, and OrganizationDivision into SalesArea
                                res_Header.SalesArea = $"{res_Header.SalesGroup} - {res_Header.SalesOffice} - {res_Header.SalesOrganization} - {res_Header.DistributionChannel} - {res_Header.OrganizationDivision}";

                                DateTime? creationDate = null;
                                if (res_obj[i]["CreationDate"] != null && !string.IsNullOrEmpty(res_obj[i]["CreationDate"].ToString()))
                                {
                                    creationDate = DateTime.Parse(res_obj[i]["CreationDate"].ToString());
                                    res_Header.CreationDate = creationDate.Value.ToString("dd-MMM-yyyy");
                                }
                                else
                                {
                                    // Set a default value or an empty string as per your requirement
                                    res_Header.CreationDate = string.Empty; // or res_Header.CreationDate = "Default Date";
                                }
                                string overallSdProcessStatus = res_obj[i]["OverallSDProcessStatus"].ToString();
                                switch (overallSdProcessStatus)
                                {
                                    case "B":
                                        res_Header.OverallSDProcessStatus = "In Process";
                                        break;
                                    case "A":
                                        res_Header.OverallSDProcessStatus = "Open";
                                        break;
                                    case "C":
                                        res_Header.OverallSDProcessStatus = "Completed";
                                        break;
                                    default:
                                        res_Header.OverallSDProcessStatus = overallSdProcessStatus; // Handle other cases as needed
                                        break;
                                }
                                salesOrderHeader.Add(res_Header);
                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }


                    return JsonConvert.SerializeObject(salesOrderHeader);




                    //if (jsonResponse.ContainsKey("value"))
                    //{
                    //    new CommonSAPDAL(ConnectionName).SaveSAPDealerMaster("SaveDealer", Org_Id, resString);
                    //}






                }

                // return resString;

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string GetOneSalesOrder(string SalesOrderId)
        {

            //var resString;

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?$filter=SalesOrder eq '" + SalesOrderId + "'");
            //var resString;




            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?$filter=SalesOrder eq '" + SalesOrderId + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();


                }
                catch (WebException ex)
                {

                    return ex.Message.ToString();
                }



                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    var resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);
                    List<ResGetSalesOrderItem> salesOrderItems = new List<ResGetSalesOrderItem>();

                    if (jsonResponse.ContainsKey("d"))
                    {
                        var resOutput = jsonResponse["d"]["results"];

                        // int rescount = resOutput.Count;

                        dynamic res_obj = JsonConvert.DeserializeObject(resOutput.ToString());

                        int res_Cnt = res_obj.Count;


                        if (res_Cnt > 0)
                        {
                            for (int i = 0; i < res_Cnt; i++)
                            {
                                ResGetSalesOrderItem res_Item = new ResGetSalesOrderItem();
                                res_Item.SalesOrderItem = res_obj[i]["SalesOrderItem"];
                                res_Item.SalesOrderItemText = res_obj[i]["SalesOrderItemText"];
                                res_Item.RequestedQuantity = res_obj[i]["RequestedQuantity"];
                                res_Item.RequestedQuantityUnit = res_obj[i]["RequestedQuantityUnit"];
                                res_Item.NetAmount = res_obj[i]["NetAmount"];
                                res_Item.Material = res_obj[i]["Material"];
                                res_Item.TaxAmount = res_obj[i]["TaxAmount"];
                                res_Item.Rate = (float.Parse(res_obj[i]["Subtotal1Amount"].ToString()) / float.Parse(res_obj[i]["RequestedQuantity"].ToString())).ToString("F2");

                                salesOrderItems.Add(res_Item);
                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }


                    return JsonConvert.SerializeObject(salesOrderItems);




                }



            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string SaveSalesOrder(SalesOrder ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder");
            string resString;
            string salesOrder = "";
            string code = "";


            SalesOrder parameter = new SalesOrder();

            parameter.SalesOrderType = ReqObj.SalesOrderType;
            parameter.SalesOrganization = ReqObj.SalesOrganization;
            parameter.DistributionChannel = ReqObj.DistributionChannel;
            parameter.OrganizationDivision = ReqObj.OrganizationDivision;
            parameter.SalesGroup = ReqObj.SalesGroup;
            parameter.SalesOffice = ReqObj.SalesOffice;
            parameter.SalesDistrict = ReqObj.SalesDistrict;
            parameter.SoldToParty = ReqObj.SoldToParty;
            parameter.CreationDate = ReqObj.CreationDate;
            parameter.CreatedByUser = ReqObj.CreatedByUser;
            parameter.LastChangeDate = ReqObj.LastChangeDate;
            parameter.SenderBusinessSystemName = ReqObj.SenderBusinessSystemName;
            parameter.ExternalDocumentID = ReqObj.ExternalDocumentID;
            parameter.LastChangeDateTime = ReqObj.LastChangeDateTime;
            parameter.ExternalDocLastChangeDateTime = ReqObj.ExternalDocLastChangeDateTime;
            parameter.PurchaseOrderByCustomer = ReqObj.PurchaseOrderByCustomer;
            parameter.PurchaseOrderByShipToParty = ReqObj.PurchaseOrderByShipToParty;
            parameter.CustomerPurchaseOrderType = ReqObj.CustomerPurchaseOrderType;
            parameter.CustomerPurchaseOrderDate = ReqObj.CustomerPurchaseOrderDate;
            parameter.SalesOrderDate = ReqObj.SalesOrderDate;
            parameter.TotalNetAmount = ReqObj.TotalNetAmount;
            parameter.OverallDeliveryStatus = ReqObj.OverallDeliveryStatus;
            parameter.TotalBlockStatus = ReqObj.TotalBlockStatus;
            parameter.OverallOrdReltdBillgStatus = ReqObj.OverallOrdReltdBillgStatus;
            parameter.OverallSDDocReferenceStatus = ReqObj.OverallSDDocReferenceStatus;
            parameter.TransactionCurrency = ReqObj.TransactionCurrency;
            parameter.SDDocumentReason = ReqObj.SDDocumentReason;
            parameter.PricingDate = ReqObj.PricingDate;
            parameter.PriceDetnExchangeRate = ReqObj.PriceDetnExchangeRate;
            parameter.BillingPlan = ReqObj.BillingPlan;
            parameter.RequestedDeliveryDate = ReqObj.RequestedDeliveryDate;
            parameter.ShippingCondition = ReqObj.ShippingCondition;
            parameter.CompleteDeliveryIsDefined = ReqObj.CompleteDeliveryIsDefined;
            parameter.ShippingType = ReqObj.ShippingType;
            parameter.HeaderBillingBlockReason = ReqObj.HeaderBillingBlockReason;
            parameter.DeliveryBlockReason = ReqObj.DeliveryBlockReason;
            parameter.DeliveryDateTypeRule = ReqObj.DeliveryDateTypeRule;
            parameter.IncotermsClassification = ReqObj.IncotermsClassification;
            parameter.IncotermsTransferLocation = ReqObj.IncotermsTransferLocation;
            parameter.IncotermsLocation1 = ReqObj.IncotermsLocation1;
            parameter.IncotermsLocation2 = ReqObj.IncotermsLocation2;
            parameter.IncotermsVersion = ReqObj.IncotermsVersion;
            parameter.CustomerPriceGroup = ReqObj.CustomerPriceGroup;
            parameter.PriceListType = ReqObj.PriceListType;
            parameter.CustomerPaymentTerms = ReqObj.CustomerPaymentTerms;
            parameter.PaymentMethod = ReqObj.PaymentMethod;
            parameter.FixedValueDate = ReqObj.FixedValueDate;
            parameter.AssignmentReference = ReqObj.AssignmentReference;
            parameter.ReferenceSDDocument = ReqObj.ReferenceSDDocument;
            parameter.ReferenceSDDocumentCategory = ReqObj.ReferenceSDDocumentCategory;
            parameter.AccountingDocExternalReference = ReqObj.AccountingDocExternalReference;
            parameter.CustomerAccountAssignmentGroup = ReqObj.CustomerAccountAssignmentGroup;
            parameter.AccountingExchangeRate = ReqObj.AccountingExchangeRate;
            parameter.CustomerGroup = ReqObj.CustomerGroup;
            parameter.AdditionalCustomerGroup1 = ReqObj.AdditionalCustomerGroup1;
            parameter.AdditionalCustomerGroup2 = ReqObj.AdditionalCustomerGroup2;
            parameter.AdditionalCustomerGroup3 = ReqObj.AdditionalCustomerGroup3;
            parameter.AdditionalCustomerGroup4 = ReqObj.AdditionalCustomerGroup4;
            parameter.AdditionalCustomerGroup5 = ReqObj.AdditionalCustomerGroup5;
            parameter.SlsDocIsRlvtForProofOfDeliv = ReqObj.SlsDocIsRlvtForProofOfDeliv;
            parameter.CustomerTaxClassification1 = ReqObj.CustomerTaxClassification1;
            parameter.CustomerTaxClassification2 = ReqObj.CustomerTaxClassification2;
            parameter.CustomerTaxClassification3 = ReqObj.CustomerTaxClassification3;
            parameter.CustomerTaxClassification4 = ReqObj.CustomerTaxClassification4;
            parameter.CustomerTaxClassification5 = ReqObj.CustomerTaxClassification5;
            parameter.CustomerTaxClassification6 = ReqObj.CustomerTaxClassification6;
            parameter.CustomerTaxClassification7 = ReqObj.CustomerTaxClassification7;
            parameter.CustomerTaxClassification8 = ReqObj.CustomerTaxClassification8;
            parameter.CustomerTaxClassification9 = ReqObj.CustomerTaxClassification9;
            parameter.TaxDepartureCountry = ReqObj.TaxDepartureCountry;
            parameter.VATRegistrationCountry = ReqObj.VATRegistrationCountry;
            parameter.SalesOrderApprovalReason = ReqObj.SalesOrderApprovalReason;
            parameter.SalesDocApprovalStatus = ReqObj.SalesDocApprovalStatus;
            parameter.OverallSDProcessStatus = ReqObj.OverallSDProcessStatus;
            parameter.TotalCreditCheckStatus = ReqObj.TotalCreditCheckStatus;
            parameter.OverallTotalDeliveryStatus = ReqObj.OverallTotalDeliveryStatus;
            parameter.OverallSDDocumentRejectionSts = ReqObj.OverallSDDocumentRejectionSts;
            parameter.BillingDocumentDate = ReqObj.BillingDocumentDate;
            parameter.ContractAccount = ReqObj.ContractAccount;
            parameter.AdditionalValueDays = ReqObj.AdditionalValueDays;
            parameter.CustomerPurchaseOrderSuplmnt = ReqObj.CustomerPurchaseOrderSuplmnt;
            parameter.ServicesRenderedDate = ReqObj.ServicesRenderedDate;

            parameter.to_Item = ReqObj.to_Item.Take(1).ToList();

            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?$format=json&$top=1");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        salesOrder = jsonResponse["d"]["SalesOrder"].ToString();

                        code = "1";

                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        salesOrder = jsonResponse["error"]["message"]["value"].ToString();
                        code = "-1";
                    }
                    else
                    {
                        // No data found
                        salesOrder = "No data found";
                        code = "0"; // No data code
                    }

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV_APP", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV_APP", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }




                    return $"{{\"salesOrder\": \"{salesOrder}\", \"code\": \"{code}\"}}";
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string SaveSalesOrderItems(SalesOrderItems ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem");
            string resString;
            string salesOrder = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?$format=json&$top=1");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        salesOrder = jsonResponse["d"]["SalesOrder"].ToString();

                        code = "1";

                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        salesOrder = jsonResponse["error"]["message"]["value"].ToString();
                        code = "-1";
                    }
                    else
                    {
                        // No data found
                        salesOrder = "No data found";
                        code = "0"; // No data code
                    }

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV_APP", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV_APP", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }


                    return $"{{\"salesOrder\": \"{salesOrder}\", \"code\": \"{code}\"}}";

                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string DeleteSalesOrderItems(string SalesOrderId, string SalesOrderItem, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Delete, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem(SalesOrder='" + SalesOrderId + "',SalesOrderItem='" + SalesOrderItem + "')");
            string resString;
            string salesOrder = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem(SalesOrder='" + SalesOrderId + "',SalesOrderItem='" + SalesOrderItem + "')");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    // request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    if (string.IsNullOrEmpty(resString))
                    {
                        // If the response is empty, set salesOrder to SalesOrderId and code to "1"
                        salesOrder = SalesOrderId;
                        code = "1"; // No data code
                    }
                    else
                    {
                        // If there is a response, parse it
                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            salesOrder = jsonResponse["d"]["SalesOrder"].ToString();
                            code = "1";
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            salesOrder = jsonResponse["error"]["message"]["value"].ToString();
                            code = "-1";
                        }
                        else
                        {
                            // No data found
                            salesOrder = "No data found";
                            code = "0"; // No data code
                        }
                    }



                    return $"{{\"salesOrder\": \"{salesOrder}\", \"code\": \"{code}\"}}";
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string UpdateSalesOrder(SalesOrderHeader ReqObj, string SalesOrderId, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Patch, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder('" + SalesOrderId + "')");
            string resString;
            string salesOrder = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder('" + SalesOrderId + "')");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("etag", "Fetch");

                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (WebException ex)
                {

                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {

                    return ex.Message.ToString();
                }


                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string IfMatch = resp.Headers.Get("etag");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("if-match", IfMatch);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;



                    if (string.IsNullOrEmpty(resString))
                    {
                        // If the response is empty, set salesOrder to SalesOrderId and code to "1"
                        salesOrder = SalesOrderId;
                        code = "1"; // No data code
                    }
                    else
                    {
                        // If there is a response, parse it
                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            salesOrder = jsonResponse["d"]["SalesOrder"].ToString();
                            code = "1";
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            salesOrder = jsonResponse["error"]["message"]["value"].ToString();
                            code = "-1";
                        }
                        else
                        {
                            // No data found
                            salesOrder = "No data found";
                            code = "0"; // No data code
                        }
                    }



                    return $"{{\"salesOrder\": \"{salesOrder}\", \"code\": \"{code}\"}}";
                }

            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string SaveNotificationSAP(NotificationHeader ReqObj, string Org_Id)
        {

            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata4/sap/api_qualitynotification/srvd_a2x/sap/qualitynotification/0001/QualityNotification");
            string resString;
            string qualitynotification = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata4/sap/api_qualitynotification/srvd_a2x/sap/qualitynotification/0001/QualityNotification?expand=$format=json&$top=1");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");

                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();
                }
                catch (WebException ex)
                {
                    return ex.Message.ToString();
                }
                catch (Exception ex)
                {
                    return ex.Message.ToString();
                }

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);
                    //Console.WriteLine(jsonResponse);
                    if (jsonResponse.ContainsKey("QualityNotification"))
                    {
                        // Access the 'QualityNotification' field
                        qualitynotification = jsonResponse["QualityNotification"].ToString();
                        code = "1";
                    }
                    else
                    {
                        // No data found
                        qualitynotification = "No data found";
                        code = "0"; // No data code
                    }

                    if (jsonResponse.ContainsKey("QualityNotification"))
                    {
                       
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "QualityNotification", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "QualityNotification", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }

                


                    return $"{{\"qualitynotification\": \"{qualitynotification}\", \"code\": \"{code}\"}}";
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string GetNotificationSAP(string QualityNotificationId)
        {

            //var resString;

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata4/sap/api_qualitynotification/srvd_a2x/sap/qualitynotification/0001/QualityNotification?$filter=QualityNotification eq '" + QualityNotificationId + "'");
            //var resString;


            // Console.WriteLine(QualityNotificationId);

            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata4/sap/api_qualitynotification/srvd_a2x/sap/qualitynotification/0001/QualityNotification?$filter=QualityNotification eq '" + QualityNotificationId + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                cookieJar = new CookieContainer();
                req.CookieContainer = cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();


                }
                catch (WebException ex)
                {

                    return ex.Message.ToString();
                }



                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    var resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);
                    List<ResQualityNotification> qualityNotification = new List<ResQualityNotification>();
                    //   Console.WriteLine(request1);
                    // Console.WriteLine(jsonResponse);
                    if (jsonResponse.ContainsKey("value"))
                    {
                        var resOutput = jsonResponse["value"];

                        // int rescount = resOutput.Count;

                        dynamic res_obj = JsonConvert.DeserializeObject(resOutput.ToString());

                        int res_Cnt = res_obj.Count;


                        if (res_Cnt > 0)
                        {
                            for (int i = 0; i < res_Cnt; i++)
                            {
                                ResQualityNotification res_Header = new ResQualityNotification();
                                res_Header.QualityNotification = res_obj[i]["QualityNotification"];
                                res_Header.NotifProcessingPhase = res_obj[i]["NotifProcessingPhase"];

                                string DocumentType = res_obj[i]["NotifProcessingPhase"];

                                switch (DocumentType)
                                {
                                    case "1":
                                        res_Header.NotifProcessingPhaseText = "Outstanding";
                                        break;
                                    case "2":
                                        res_Header.NotifProcessingPhaseText = "Postpone";
                                        break;
                                    case "3":
                                        res_Header.NotifProcessingPhaseText = "In process";
                                        break;
                                    case "4":
                                        res_Header.NotifProcessingPhaseText = "Completed";
                                        break;
                                    default:
                                        res_Header.NotifProcessingPhaseText = DocumentType;
                                        break;
                                }


                                qualityNotification.Add(res_Header);
                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }


                    return JsonConvert.SerializeObject(qualityNotification);




                }



            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }




    }
}
