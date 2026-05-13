
using Microsoft.AspNetCore.Mvc;
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
    public class InvoiceSAP
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

        public InvoiceSAP(string Destination)
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





        public string GetAllInvoice(string startDate, string endDate, string dealerCode)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_HEADERBILL_CDS/YY1_Headerbill?$filter=BillingDocumentDate ge datetime'" + startDate + "'" + " and BillingDocumentDate le datetime'" + endDate + "'  and SoldToParty eq '" + dealerCode + "'");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_HEADERBILL_CDS/YY1_Headerbill?$filter=BillingDocumentDate ge datetime'" + startDate + "'" + " and BillingDocumentDate le datetime'" + endDate + "'  and SoldToParty eq '" + dealerCode + "'");
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
                    List<ResGetInvoice> invoice = new List<ResGetInvoice>();

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
                                ResGetInvoice res_Item = new ResGetInvoice();

                                res_Item.BillingDocument = res_obj[i]["BillingDocument"];

                                DateTime? creationDate = null;
                                if (res_obj[i]["BillingDocumentDate"] != null && !string.IsNullOrEmpty(res_obj[i]["BillingDocumentDate"].ToString()))
                                {
                                    creationDate = DateTime.Parse(res_obj[i]["BillingDocumentDate"].ToString());
                                    res_Item.BillingDocumentDate = creationDate.Value.ToString("dd-MMM-yyyy");
                                }
                                else
                                {
                                    // Set a default value or an empty string as per your requirement
                                    res_Item.BillingDocumentDate = string.Empty; // or res_Header.CreationDate = "Default Date";
                                }


                                res_Item.CustomerPaymentTerms = res_obj[i]["CustomerPaymentTerms"];
                                res_Item.TransactionCurrency = res_obj[i]["TransactionCurrency"];
                                res_Item.TotalNetAmount = res_obj[i]["TotalNetAmount"];
                                res_Item.DocumentReferenceID = res_obj[i]["DocumentReferenceID"];
                                res_Item.TotalTaxAmount = res_obj[i]["TotalTaxAmount"];

                                string DocumentType = res_obj[i]["BillingDocumentType"];

                                switch (DocumentType)
                                {
                                    case "CBFD":
                                        res_Item.BillingDocumentType = "Delivery Free of Charge";
                                        break;
                                    case "CBGO":
                                        res_Item.BillingDocumentType = "Return Packaging";
                                        break;
                                    case "CBII":
                                        res_Item.BillingDocumentType = "Invoice Increase Request";
                                        break;
                                    case "CBRE":
                                        res_Item.BillingDocumentType = "Credit Return";
                                        break;
                                    case "CCFU":
                                        res_Item.BillingDocumentType = "Consignment Fillup";
                                        break;
                                    case "CCIS":
                                        res_Item.BillingDocumentType = "Consignment Issue";
                                        break;
                                    case "DR":
                                        res_Item.BillingDocumentType = "Debit Note";
                                        break;
                                    case "CR":
                                        res_Item.BillingDocumentType = "Credit Note";
                                        break;
                                    case "CBAR":
                                        res_Item.BillingDocumentType = "Standard Return";
                                        break;
                                    case "OR":
                                        res_Item.BillingDocumentType = "Order";
                                        break;
                                    case "F2":
                                        res_Item.BillingDocumentType = "Invoice";
                                        break;
                                    default:
                                        res_Item.BillingDocumentType = res_obj[i]["BillingDocumentType"];
                                        break;
                                }


                                invoice.Add(res_Item);
                            }
                        }

                    }

                    return JsonConvert.SerializeObject(invoice);

                }

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }




        public string GetOneInvoice(string invoice_no)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_BILLINGDATA_CDS/YY1_BILLINGDATA?$filter=BillingDocument eq '" + invoice_no + "'");
            //var resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_BILLINGDATA_CDS/YY1_BILLINGDATA?$filter=BillingDocument eq '" + invoice_no + "'");
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
                    List<ResGetInvoiceItem> invoiceItems = new List<ResGetInvoiceItem>();

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
                                ResGetInvoiceItem res_Item = new ResGetInvoiceItem();
                                res_Item.Material = res_obj[i]["Material"];
                                res_Item.BillingDocument = res_obj[i]["BillingDocument"];
                                res_Item.BillingDocumentItem = res_obj[i]["BillingDocumentItem"];
                                res_Item.BillingDocumentItemText = res_obj[i]["BillingDocumentItemText"];
                                res_Item.Plant = res_obj[i]["Plant"];
                                res_Item.ItemWeightUnit = res_obj[i]["BillingQuantityUnit"];
                                res_Item.NetAmount = res_obj[i]["NetAmount"];
                                res_Item.TaxAmount = res_obj[i]["TaxAmount"];

                                res_Item.BillingDocumentDate = res_obj[i]["BillingDocumentDate"];
                                res_Item.BillingQuantity = res_obj[i]["BillingQuantity"];
                                res_Item.ReferenceSDDocument = res_obj[i]["ReferenceSDDocument"];

                                res_Item.SalesOrganization = res_obj[i]["SalesOrganization"];
                                res_Item.DistributionChannel = res_obj[i]["DistributionChannel"];
                                res_Item.OrganizationDivision = res_obj[i]["OrganizationDivision"];
                                res_Item.SalesGroup = res_obj[i]["SalesGroup"];
                                res_Item.SalesOffice = res_obj[i]["SalesOffice"];
                                res_Item.SoldToParty = res_obj[i]["SoldToParty"];

                                invoiceItems.Add(res_Item);


                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }


                    return JsonConvert.SerializeObject(invoiceItems);







                }



            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string GetOneInvoicePricing(string invoice_no)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BILLING_DOCUMENT_SRV/A_BillingDocumentItemPrcgElmnt?$filter=BillingDocument eq '" + invoice_no + "'");
            //var resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BILLING_DOCUMENT_SRV/A_BillingDocumentItemPrcgElmnt?$filter=BillingDocument eq '" + invoice_no + "'");
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
                    List<ResGetInvoicePricing> invoiceItems = new List<ResGetInvoicePricing>();

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
                                ResGetInvoicePricing res_Item = new ResGetInvoicePricing();


                                res_Item.BillingDocument = res_obj[i]["BillingDocument"];
                                res_Item.BillingDocumentItem = res_obj[i]["BillingDocumentItem"];
                                res_Item.ConditionRateValue = res_obj[i]["ConditionRateValue"];
                                res_Item.ConditionType = res_obj[i]["ConditionType"];
                                res_Item.ConditionAmount = res_obj[i]["ConditionAmount"];
                                res_Item.ConditionBaseValue = res_obj[i]["ConditionBaseValue"];

                                invoiceItems.Add(res_Item);


                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }



                    return JsonConvert.SerializeObject(invoiceItems);







                }



            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string SaveCustomerReturn(Roots ReqObj)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_CUSTOMER_RETURN_SRV/A_CustomerReturn");
            string resString;
            string CustomerReturn = "";
            string code = "";

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_CUSTOMER_RETURN_SRV/A_CustomerReturn");
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
                        CustomerReturn = jsonResponse["d"]["CustomerReturn"].ToString();

                        code = "1";

                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        CustomerReturn = jsonResponse["error"]["message"]["value"].ToString();
                        code = "-1";
                    }
                    else
                    {
                        // No data found
                        CustomerReturn = "No data found";
                        code = "0"; // No data code
                    }




                    return $"{{\"CustomerReturn\": \"{CustomerReturn}\", \"code\": \"{code}\"}}";
                }
            }
            catch (Exception ex)
            {

                return "Error: =" + ex.Message;

            }
        }





        public string SaveCreditMemoReturn([FromBody] object ReqObj)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_CREDIT_MEMO_REQUEST_SRV/A_CreditMemoRequest");
            string resString;
            string CustomerReturn = "";
            string code = "";


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_CREDIT_MEMO_REQUEST_SRV/A_CreditMemoRequest");
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
                        CustomerReturn = jsonResponse["d"]["CreditMemoRequest"].ToString();

                        code = "1";

                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        CustomerReturn = jsonResponse["error"]["message"]["value"].ToString();
                        code = "-1";
                    }
                    else
                    {
                        // No data found
                        CustomerReturn = "No data found";
                        code = "0"; // No data code
                    }




                    return $"{{\"CustomerReturn\": \"{CustomerReturn}\", \"code\": \"{code}\"}}";
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string GetInvoicePDF(string InvoiceId)
        {



            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BILLING_DOCUMENT_SRV/GetPDF?BillingDocument='" + InvoiceId + "'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BILLING_DOCUMENT_SRV/GetPDF?BillingDocument='" + InvoiceId + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                // req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
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
                    // client1.DefaultRequestHeaders
                    //     .Accept
                    //     .Add(new MediaTypeWithQualityHeaderValue("application/json"));

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

        // public string GetQRCodeAmount(string InvoiceId)
        // {
        // 	var request1 = new HttpRequestMessage(HttpMethod.Get,
        // 		"sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=ReferenceDocument eq '" + InvoiceId + "'");
        // 	string resString;

        // 	try
        // 	{
        // 		// Get Method to fetch CSRF Token
        // 		System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

        // 		HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(
        // 			SAPAPIURL + "sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=ReferenceDocument eq '" + InvoiceId + "'");
        // 		HttpWebResponse resp;

        // 		req.Credentials = credentials;
        // 		req.Method = "GET";
        // 		req.Headers.Add("x-csrf-token", "Fetch");
        // 		req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=xxxx; sap-usercontext=sap-client=100");
        // 		this.cookieJar = new CookieContainer();
        // 		req.CookieContainer = this.cookieJar;

        // 		try
        // 		{
        // 			resp = (HttpWebResponse)req.GetResponse();
        // 		}
        // 		catch (System.Net.WebException ex)
        // 		{
        // 			return ex.Message.ToString();
        // 		}

        // 		string CSRFToken = resp.Headers.Get("x-csrf-token");
        // 		string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

        // 		// Post Method
        // 		var cookieContainer = new CookieContainer();
        // 		using (var handler = new HttpClientHandler() { CookieContainer = cookieContainer })
        // 		using (var client1 = new HttpClient(handler))
        // 		{
        // 			client1.BaseAddress = new Uri(SAPAPIURL);
        // 			client1.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        // 			cookieContainer.Add(client1.BaseAddress, resp.Cookies);

        // 			request1.Headers.Add("x-csrf-token", CSRFToken);
        // 			request1.Headers.Add("Authorization", "Basic " + svcCredentials);

        // 			var response1 = client1.Send(request1);
        // 			resString = response1.Content.ReadAsStringAsync().Result;

        // 			JObject jsonResponse = JObject.Parse(resString);

        // 			List<QRCodeAmount> qr_amount = new List<QRCodeAmount>();

        // 			if (jsonResponse.ContainsKey("d"))
        // 			{
        // 				var resOutput = jsonResponse["d"]["results"] as JArray;
        // 				if (resOutput != null)
        // 				{
        // 					foreach (var item in resOutput)
        // 					{
        // 						qr_amount.Add(new QRCodeAmount
        // 						{
        // 							AmountInBalanceTransacCrcy = item["AmountInBalanceTransacCrcy"]?.ToString()
        // 						});
        // 					}
        // 				}

        // 				return JsonConvert.SerializeObject(qr_amount);
        // 			}

        // 			return "No data found"; // ✅ ensures return in all cases
        // 		}
        // 	}
        // 	catch (Exception ex)
        // 	{
        // 		return "Error: =" + ex.Message;
        // 	}
        // }

        public string GetQRCodeAmount(string InvoiceId)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get,
                "sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=ReferenceDocument eq '" + InvoiceId + "'");
            string resString;

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(
                    SAPAPIURL + "sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=ReferenceDocument eq '" + InvoiceId + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=xxxx; sap-usercontext=sap-client=100");
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

                    //Console.WriteLine(resString);

                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        var resOutput = jsonResponse["d"]["results"] as JArray;
                        if (resOutput != null && resOutput.Count > 0)
                        {
                            decimal totalAmount = 0;
                            string customer = resOutput[0]["Customer"]?.ToString();
                            string upiId = "SRTM86" + customer + "@hdfcbank";
                            string payeeName = upiId;
                            string note = resOutput[0]["ReferenceDocument"]?.ToString();

                            // foreach (var item in resOutput)
                            // {
                            // 	string amountStr = item["AmountInBalanceTransacCrcy"]?.ToString();
                            // 	 Console.WriteLine(amountStr);
                            // 	if (string.IsNullOrWhiteSpace(amountStr)) amountStr = "0";

                            // 	decimal amount;
                            // 	if (decimal.TryParse(amountStr, out amount))
                            // 	{
                            // 		totalAmount += amount;
                            // 	}
                            // }

                            foreach (var item in resOutput)
                            {
                                string financialAccountType = item["FinancialAccountType"]?.ToString();
                                string ledger = item["Ledger"]?.ToString();
                                string clearingJournalEntry = item["ClearingJournalEntry"]?.ToString();

                                // Apply conditions
                                if (financialAccountType == "D" &&
                                    ledger == "0L" &&
                                    string.IsNullOrWhiteSpace(clearingJournalEntry))
                                {
                                    string amountStr = item["AmountInCompanyCodeCurrency"]?.ToString();
                                    //Console.WriteLine(amountStr);

                                    if (string.IsNullOrWhiteSpace(amountStr)) amountStr = "0";

                                    decimal amount;
                                    if (decimal.TryParse(amountStr, out amount))
                                    {
                                        totalAmount += amount;
                                    }
                                }
                            }


                            string upiUrl = $"upi://pay?pa={Uri.EscapeDataString(upiId)}&pn={Uri.EscapeDataString(payeeName)}&am={totalAmount}&cu=INR&tn={Uri.EscapeDataString(note)}";
                            
							var result = new
							{
								customer = customer,
								upiId = upiId,
								upiUrl = upiUrl,
								payeeName = payeeName,
								note = note,
								amount = totalAmount,
								isPay = totalAmount == 0 ? 2 : 1
							};

                            return JsonConvert.SerializeObject(result);
                        }
                    }

                    var result_1 = new
                    {
                        customer = "",
                        upiId = "",
                        upiUrl = "",
                        payeeName = "",
                        note = "",
                        amount = 0,
                        isPay = 0,
                    };

                    return JsonConvert.SerializeObject(result_1);
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;
            }
        }







    }
}
