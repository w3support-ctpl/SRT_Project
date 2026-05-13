using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AdminConsole_API.Models;
using MilkIN_API.Middleware;
using MySqlX.XDevAPI;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NuGet.Common;
using Org.BouncyCastle.Asn1.Ocsp;
using Org.BouncyCastle.Ocsp;
using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Xml.Linq;


namespace MilkIN_API.Areas.AdminConsole_API.SAP
{
    public class CollectionSAP
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

        public CollectionSAP(string Destination)
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

        public string SaveMilkBatch(ReqSAPMilkBatch ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;



                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_MATERIAL_DOCUMENT_SRV", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_MATERIAL_DOCUMENT_SRV", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }

                    return resString;
                }
            }
            catch (Exception ex)
            {

                return "Error: =" + ex.Message;

            }
        }



        public string SaveMilkBatchHeader(ReqSAPMilkBatchHeader ReqObj, string Org_Id)
        {
            //var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue?$format=json");

            //var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue(Material='"+ ReqObj.Material + "',BatchIdentifyingPlant='',Batch='"+ ReqObj.Batch + "',CharcInternalID='" + ReqObj.CharcInternalID + "',CharcValuePositionNumber='1')");

            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                //HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue?$format=json");

                //HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue(Material='" + ReqObj.Material + "',BatchIdentifyingPlant='',Batch='" + ReqObj.Batch + "',CharcInternalID='" + ReqObj.CharcInternalID + "',CharcValuePositionNumber='1')");

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue");
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
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_BATCH_SRV", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_BATCH_SRV", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }

                    return resString;
                }
            }
            catch (Exception ex)
            {

                return "Error: =" + ex.Message;
            }
        }

        // public string SaveMilkSOAP(ReqSAPMilkSOAP ReqObj, string Org_Id)
        // {
        //     var request = new HttpRequestMessage(HttpMethod.Post, "bc/srt/scs_ext/sap/journalentrycreaterequestconfi");




        //     try
        //     {
        //         var CreationDateTime = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
        //         var CurrentDate = DateTime.Now.ToString("yyyy-MM-dd");

        //         var client = new HttpClient();
        //         System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

        //         HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "bc/srt/scs_ext/sap/journalentrycreaterequestconfi");

        //         req.Headers.Add("SOAPAction", "http://sap.com/xi/SAPSCORE/SFIN/JournalEntryCreateRequestConfirmation_In/JournalEntryCreateRequestConfirmation_InRequest");
        //         req.Headers.Add("Authorization", "Basic Q1RQTEFCQVBfU1JUOlBhc3N3b3JkQCMwOTg3NjU0MzIx");
        //         // request.Credentials = credentials;
        //         req.Headers.Add("Cookie", "sap-usercontext=sap-client=100");


        //         var content = new StringContent(ReqObj.xmlData, null, "text/xml");

        //         req.Content = content;
        //         var response = client.Send(req);
        //         response.EnsureSuccessStatusCode();





        //         XDocument xmlDoc = XDocument.Parse(response.Content.ReadAsStringAsync().Result);

        //         // Convert the XML to JSON
        //         string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

        //         // Deserialize the JSON to a JObject
        //         JObject json = JObject.Parse(jsonResponse);

        //         string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();


        //         if (severityCode == "1" || severityCode == "3")
        //         {
        //             new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "SOAP", request, JsonConvert.SerializeObject(ReqObj), "200", response.Content.ReadAsStringAsync().Result);
        //         }
        //         else if (severityCode == "3")
        //         {
        //             new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "SOAP", request, JsonConvert.SerializeObject(ReqObj), "500", response.Content.ReadAsStringAsync().Result);
        //         }


        //         return response.Content.ReadAsStringAsync().Result;



        //     }
        //     catch (Exception ex)
        //     {

        //         return "Error: =" + ex.Message;
        //     }
        // }


        public string SaveMilkSOAP(ReqSAPMilkSOAP ReqObj, string Org_Id)
        {
            var request = new HttpRequestMessage(HttpMethod.Post, "sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi");
            try
            {
                var CreationDateTime = DateTime.Now.ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");
                var CurrentDate = DateTime.Now.ToString("yyyy-MM-dd");

                string svcCredentials = Convert.ToBase64String(ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                var client = new HttpClient();
                client.DefaultRequestHeaders.Add("SOAPAction", "http://sap.com/xi/SAPSCORE/SFIN/JournalEntryCreateRequestConfirmation_In/JournalEntryCreateRequestConfirmation_InRequest");
                client.DefaultRequestHeaders.Add("Authorization", "Basic " + svcCredentials);

                //client.DefaultRequestHeaders.Add("Cookie", "sap-usercontext=sap-client=100");

                var content = new StringContent(ReqObj.xmlData, Encoding.UTF8, "text/xml");

                var response = client.PostAsync(SAPAPIURL + "sap/bc/srt/scs_ext/sap/journalentrycreaterequestconfi", content).Result;
                response.EnsureSuccessStatusCode();

                XDocument xmlDoc = XDocument.Parse(response.Content.ReadAsStringAsync().Result);

                // Convert the XML to JSON
                string jsonResponse = JsonConvert.SerializeXNode(xmlDoc);

                // Deserialize the JSON to a JObject
                JObject json = JObject.Parse(jsonResponse);

                string severityCode = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["Log"]["MaximumLogItemSeverityCode"]?.ToString();

                string AccountingDocument = json["soap-env:Envelope"]["soap-env:Body"]["n0:JournalEntryBulkCreateConfirmation"]["JournalEntryCreateConfirmation"]["JournalEntryCreateConfirmation"]["AccountingDocument"]?.ToString();

                if (severityCode == "1" || severityCode == "2" || AccountingDocument != "0000000000")
                {
                    new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "SOAP", request, JsonConvert.SerializeObject(ReqObj), "200", response.Content.ReadAsStringAsync().Result);
                }
                else if (severityCode == "3" || AccountingDocument == "0000000000")
                {
                    new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "SOAP", request, JsonConvert.SerializeObject(ReqObj), "500", response.Content.ReadAsStringAsync().Result);
                }

                return response.Content.ReadAsStringAsync().Result;
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }


        public string SaveMilkSOAPJson(ReqSAPMilkSOAPIncome ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice");
            string resString;

            ReqSAPMilkSOAPIncome parameter = new ReqSAPMilkSOAPIncome();
            parameter.FiscalYear = ReqObj.FiscalYear;
            parameter.CompanyCode = ReqObj.CompanyCode;
            parameter.DocumentDate = ReqObj.DocumentDate;
            parameter.PostingDate = ReqObj.PostingDate;
            parameter.CreationDate = ReqObj.CreationDate;
            parameter.SupplierInvoiceIDByInvcgParty = ReqObj.SupplierInvoiceIDByInvcgParty;
            parameter.InvoicingParty = ReqObj.InvoicingParty;
            parameter.DocumentCurrency = ReqObj.DocumentCurrency;
            parameter.InvoiceGrossAmount = ReqObj.InvoiceGrossAmount;
            parameter.PaymentTerms = ReqObj.PaymentTerms;
            parameter.AccountingDocumentType = ReqObj.AccountingDocumentType;
            parameter.SupplierInvoiceStatus = ReqObj.SupplierInvoiceStatus;
            parameter.TaxIsCalculatedAutomatically = ReqObj.TaxIsCalculatedAutomatically;
            parameter.BusinessPlace = ReqObj.BusinessPlace;
            parameter.BusinessSectionCode = ReqObj.BusinessSectionCode;
            parameter.SuplrInvcIsCapitalGoodsRelated = ReqObj.SuplrInvcIsCapitalGoodsRelated;
            parameter.TaxDeterminationDate = ReqObj.TaxDeterminationDate;
            parameter.TaxReportingDate = ReqObj.TaxReportingDate;
            parameter.TaxFulfillmentDate = ReqObj.TaxFulfillmentDate;
            parameter.InvoiceReceiptDate = ReqObj.InvoiceReceiptDate;
            parameter.IsEUTriangularDeal = ReqObj.IsEUTriangularDeal;
            parameter.RetentionDueDate = ReqObj.RetentionDueDate;
            parameter.IsReversal = ReqObj.IsReversal;
            parameter.IsReversed = ReqObj.IsReversed;
            parameter.SupplierPostingLineItemText = ReqObj.SupplierPostingLineItemText;
            parameter.to_SupplierInvoiceItemGLAcct = ReqObj.to_SupplierInvoiceItemGLAcct;


            if (double.Parse(ReqObj.InvoiceGrossAmount) < 0)      // Amount to be deducted for Gain Loss is more than MPPI
            {
                parameter.SupplierInvoiceIsCreditMemo = "2";
            }
            else
            {
                parameter.to_SupplierInvoiceWhldgTax = ReqObj.to_SupplierInvoiceWhldgTax;
                parameter.SupplierInvoiceIsCreditMemo = ReqObj.SupplierInvoiceIsCreditMemo;
            }

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SUPPLIERINVOICE_PROCESS_SRV/A_SupplierInvoice");
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

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_BUSINESS_PARTNER/A_BusinessPartner");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(parameter), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    
                    if (jsonResponse.ContainsKey("d"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "SOAP", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "SOAP", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
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
