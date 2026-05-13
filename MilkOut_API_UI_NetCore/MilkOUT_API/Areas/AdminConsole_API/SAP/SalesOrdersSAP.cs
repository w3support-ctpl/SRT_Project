
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net;
using System.Net.Http.Headers;
using System.Text;

namespace MilkOUT_API.Areas.AdminConsole_API.SAP
{
    public class SalesOrderSAP
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

        public SalesOrderSAP(string Destination)
        {

            switch (Destination)
            {
                case "PRD": // Production
                    SAPUserName = "" + configuration.GetValue<string>("SAPPrdSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue<string>("SAPPrdSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue<string>("SAPPrdSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT": // UAT
                    SAPUserName = "" + configuration.GetValue<string>("SAPUatSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue<string>("SAPUatSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue<string>("SAPUatSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionUAT";
                    break;
                case "DEV": // UAT
                    SAPUserName = "" + configuration.GetValue<string>("SAPDevSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue<string>("SAPDevSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue<string>("SAPDevSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionDEV";
                    break;
                default: // DEV
                    SAPUserName = "" + configuration.GetValue<string>("SAPDevSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue<string>("SAPDevSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue<string>("SAPDevSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionDEV";
                    break;

            }
        }





        public string GetAllSalesOrder(string SalesGroup, string formattedStartDate, string formattedEndDate)
        {



            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?$filter=SalesOrderDate ge datetime'" + formattedStartDate + "' and SalesOrderDate le datetime'" + formattedEndDate + "' and SalesGroup    eq '" + SalesGroup + "'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?$filter=SalesOrderDate ge datetime'" + formattedStartDate + "' and SalesOrderDate le datetime'" + formattedEndDate + "' and SalesGroup    eq '" + SalesGroup + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
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
                                res_Header.soldtoparty = res_obj[i]["SoldToParty"];
                                // Concatenate SalesGroup, SalesOffice, SalesOrganization, DistributionChannel, and OrganizationDivision into SalesArea
                                res_Header.SalesArea = $"{res_Header.SalesGroup} - {res_Header.SalesOffice} - {res_Header.SalesOrganization} - {res_Header.DistributionChannel} - {res_Header.OrganizationDivision}";

                                DateTime? creationDate = null;
                                if (res_obj[i]["SalesOrderDate"] != null && !string.IsNullOrEmpty(res_obj[i]["SalesOrderDate"].ToString()))
                                {
                                    creationDate = DateTime.Parse(res_obj[i]["SalesOrderDate"].ToString());
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


        public string GetOneSalesOrderHeader(string SalesOrderId)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder('" + SalesOrderId + "')");
            string resString;

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder('" + SalesOrderId + "')");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
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

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })
                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);

                    List<ResGetSalesOrderHeader> salesOrderHeader = new List<ResGetSalesOrderHeader>();

                    if (jsonResponse.ContainsKey("d"))
                    {
                        var resOutput = jsonResponse["d"];

                        // Deserialize the object directly
                        ResGetSalesOrderHeader res_Header = new ResGetSalesOrderHeader
                        {
                            TotalNetAmount = resOutput["TotalNetAmount"]?.ToString() // Accessing TotalNetAmount property directly
                        };

                        salesOrderHeader.Add(res_Header);
                    }

                    return JsonConvert.SerializeObject(salesOrderHeader);
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;
            }
        }

        public string GetOneSalesOrderHeaderPartner(string SalesOrderId)
        {

            
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderHeaderPartner(SalesOrder='" + SalesOrderId + "',PartnerFunction='SE')");
            string resString;

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderHeaderPartner(SalesOrder='" + SalesOrderId + "',PartnerFunction='SE')");

                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
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

                string CSRFToken = resp.Headers.Get("x-csrf-token");
                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                // Post Method
                var cookieContainer = new CookieContainer();
                using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })
                using (var client1 = new HttpClient(handler))
                {
                    client1.BaseAddress = new Uri(SAPAPIURL);
                    client1.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    cookieContainer.Add(client1.BaseAddress, resp.Cookies);

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);

                    

                    return JsonConvert.SerializeObject(jsonResponse);
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;
            }
        }



        public string GetOneSalesOrderNew(string SalesOrderId)
        {

            //var resString;

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?$filter=SalesOrder eq '" + SalesOrderId + "'");
            //var resString;




            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?$filter=SalesOrder eq '" + SalesOrderId + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
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
                                res_Item.TaxAmount = res_obj[i]["TaxAmount"];
                                res_Item.Material = res_obj[i]["Material"];
                                res_Item.Subtotal1Amount = res_obj[i]["Subtotal1Amount"];

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

        public string GetOneSalesOrderPricing(string SalesOrderId)
        {

            //var resString;

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItemPrElement?$filter=SalesOrder eq '" + SalesOrderId + "' and ConditionAmount ne 0");
            //var resString;




            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItemPrElement?$filter=SalesOrder eq '" + SalesOrderId + "' and ConditionAmount ne 0");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
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

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    var resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);
                    List<ResGetSalesOrderItemPricing> salesOrderItems = new List<ResGetSalesOrderItemPricing>();

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
                                ResGetSalesOrderItemPricing res_Item = new ResGetSalesOrderItemPricing();
                                res_Item.SalesOrder = res_obj[i]["SalesOrder"];
                                res_Item.SalesOrderItem = res_obj[i]["SalesOrderItem"];
                                res_Item.ConditionType = res_obj[i]["ConditionType"];
                                res_Item.ConditionBaseValue = res_obj[i]["ConditionBaseValue"];
                                res_Item.ConditionRateValue = res_obj[i]["ConditionRateValue"];
                                res_Item.ConditionAmount = res_obj[i]["ConditionAmount"];
                                res_Item.ConditionCurrency = res_obj[i]["ConditionCurrency"];
                                res_Item.TransactionCurrency = res_obj[i]["TransactionCurrency"];

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

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder?expand=$format=json&$top=1");
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
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }



                    return $"{{\"salesOrder\": \"{salesOrder}\", \"code\": \"{code}\"}}";
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string SaveSalesOrderItemsNew(SalesOrderItems ReqObj, string Org_Id, string Method_Name)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem");
            string resString;
            string salesOrder = "";
            string code = "";
            

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem?expand=$format=json&$top=1");
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
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_SALES_ORDER_SRV", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }


                    return $"{{\"salesOrder\": \"{salesOrder}\", \"code\": \"{code}\"}}";

                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string DeleteSalesOrderItemsNews(string SalesOrderId, string SalesOrderItem, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Delete, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem(SalesOrder='" + SalesOrderId + "',SalesOrderItem='" + SalesOrderItem + "')");
            string resString;
            string salesOrder = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderItem(SalesOrder='" + SalesOrderId + "',SalesOrderItem='" + SalesOrderItem + "')");
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


        public string UpdateSalesOrderNew(SalesOrderHeader ReqObj, string SalesOrderId, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Patch, "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder('" + SalesOrderId + "')");
            string resString;
            string salesOrder = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrder('" + SalesOrderId + "')");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("etag", "Fetch");

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
                string IfMatch = resp.Headers.Get("etag");
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


        public string GetSalesOrderPDF(string SalesOrderId)
        {

           

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/bc/http/sap/ZRENDER_PDF?salesorder=" + SalesOrderId + "");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/bc/http/sap/ZRENDER_PDF?salesorder=" + SalesOrderId + "");
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




                    return resString;


                }
            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string GetSalesOrderSalesEmployee(string SalesOrderId)
        {


            string resString;
            string ReferenceBusinessPartner;
            string BusinessPartner = "";
            string BusinessPartnerName = "";
            string code = "";
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_ORDER_SRV/A_SalesOrderHeaderPartner(SalesOrder='"+SalesOrderId+"',PartnerFunction='SE')");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Accept", "application/json");

                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                try
                {
                    resp = (HttpWebResponse)req.GetResponse();

                    
                    using (var reader = new StreamReader(resp.GetResponseStream()))
                    {
                        var jsonResponse = JObject.Parse(reader.ReadToEnd());
                      

                        ReferenceBusinessPartner = jsonResponse["d"]["ReferenceBusinessPartner"].ToString();

                    }
                }
                catch (System.Net.WebException ex)
                {

                    BusinessPartner = "No Sales Person Assign";
                    BusinessPartnerName = "No Sales Person Assign";
                    code = "-1";
                     

                    return $"{{\"BusinessPartner\": \"{BusinessPartner}\",\"BusinessPartnerName\": \"{BusinessPartnerName}\", \"code\": \"{code}\"}}";
                }
                catch (Exception ex)
                {
                    BusinessPartner = "No Sales Person Assign";
                    BusinessPartnerName = "No Sales Person Assign";
                    code = "-1";
                     

                    return $"{{\"BusinessPartner\": \"{BusinessPartner}\",\"BusinessPartnerName\": \"{BusinessPartnerName}\", \"code\": \"{code}\"}}";

                }
                var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('"+ReferenceBusinessPartner+"')");

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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    // request1.Content = new StringContent(JsonConvert.SerializeObject(objPostData), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {


                    BusinessPartner = jsonResponse["d"]["BusinessPartner"].ToString();;
                    BusinessPartnerName = jsonResponse["d"]["BusinessPartnerName"].ToString();;
                    code = "1";
                     

                     

                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        BusinessPartner = "No Sales Person Assign";
                    BusinessPartnerName = "No Sales Person Assign";
                    code = "-1";
                     

                     
                    }
                    else
                    {
                        BusinessPartner = "No Sales Person Assign";
                    BusinessPartnerName = "No Sales Person Assign";
                    code = "-1";
                     


                    }

                   
                    return $"{{\"BusinessPartner\": \"{BusinessPartner}\",\"BusinessPartnerName\": \"{BusinessPartnerName}\", \"code\": \"{code}\"}}";

                }
            }
            catch (Exception ex)
            {

                BusinessPartner = "";
                    BusinessPartnerName = "";
                    code = "-1";
                     

                    return $"{{\"BusinessPartner\": \"{BusinessPartner}\",\"BusinessPartnerName\": \"{BusinessPartnerName}\", \"code\": \"{code}\"}}";


            }

        }


    }
}
