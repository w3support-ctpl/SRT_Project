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
    public class DealerMasterSAP
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

        public DealerMasterSAP(string Destination)
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




        public string SaveDealerMaster(string Org_Id, string DealerData)
        {
            // Console.WriteLine(DealerData);
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_DEALERV2_CDS/YY1_DEALERV2?$filter=CustomerAccountGroup eq 'ZALL' or CustomerAccountGroup eq 'ZIBS' or CustomerAccountGroup eq 'ZOTR' or CustomerAccountGroup eq 'ZPLR'");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_DEALERV2_CDS/YY1_DEALERV2?$filter=CustomerAccountGroup eq 'ZALL' or CustomerAccountGroup eq 'ZIBS' or CustomerAccountGroup eq 'ZOTR' or CustomerAccountGroup eq 'ZPLR'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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


                    if (jsonResponse.ContainsKey("d"))
                    {
                        CommonOutput = new CommonSAPDAL(ConnectionName, configuration).SaveSAPDealerMaster("SaveDealer", Org_Id, resString, DealerData);

                    }

                }

                return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string SaveDealerCrateLimit(string Org_Id, string DealerData)
        {
            // Deserialize DealerData into a strongly typed list
            var dealers = JsonConvert.DeserializeObject<List<Dealer>>(DealerData);
            StringBuilder finalResult = new StringBuilder();

            foreach (var dealer in dealers)
            {
                //Console.WriteLine("Processing Dealer Code: " + dealer.Dealer_Code);

                var request1 = new HttpRequestMessage(HttpMethod.Get,
                    $"sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{dealer.Dealer_Code}')/to_BuPaIdentification");

                try
                {
                    // Get CSRF Token
                    System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);
                    HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(
                        SAPAPIURL + $"sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('{dealer.Dealer_Code}')/to_BuPaIdentification");

                    req.Credentials = credentials;
                    req.Method = "GET";
                    req.Headers.Add("x-csrf-token", "Fetch");
                    req.Headers.Add("Cookie",
                        "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");

                    this.cookieJar = new CookieContainer();
                    req.CookieContainer = this.cookieJar;

                    List<CommonOutput> CommonOutput = new List<CommonOutput>();


                    HttpWebResponse resp;
                    try
                    {
                        resp = (HttpWebResponse)req.GetResponse();
                    }
                    catch (System.Net.WebException ex)
                    {
                        finalResult.AppendLine($"Dealer {dealer.Dealer_Code} Error: {ex.Message}");
                        continue;
                    }

                    string CSRFToken = resp.Headers.Get("x-csrf-token");
                    string svcCredentials = Convert.ToBase64String(
                        ASCIIEncoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

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
                        var resString = response1.Content.ReadAsStringAsync().Result;

                        //Console.WriteLine($"Dealer {dealer.Dealer_Code} Response: {resString}");
                        //finalResult.AppendLine($"Dealer {dealer.Dealer_Code} Response: {resString}");

                        var jsonResponse = JsonConvert.DeserializeObject<SapResponse>(resString);

                        // Pick only BPIdentificationType = "ZCRATE"
                        var crateRecord = jsonResponse?.d?.results?
                            .FirstOrDefault(r => r.BPIdentificationType == "ZCRATE");

                        if (crateRecord != null)
                        {
                            // Console.WriteLine($"Dealer {dealer.Dealer_Code} - Crate Limit: {crateRecord.BPIdentificationNumber}");
                            //finalResult.AppendLine($"Dealer {dealer.Dealer_Code} - Crate Limit: {crateRecord.BPIdentificationNumber}");
                            CommonOutput = new CommonSAPDAL(ConnectionName, configuration).SaveSAPDealerCrateLimit("Update", Org_Id, dealer.Dealer_Code, crateRecord.BPIdentificationNumber);
                        }
                        else
                        {
                            // Console.WriteLine($"Dealer {dealer.Dealer_Code} - No Crate Limit found.");
                            //finalResult.AppendLine($"Dealer {dealer.Dealer_Code} - No Crate Limit found.");
                        }
                    }
                }
                catch (Exception ex)
                {
                    //finalResult.AppendLine($"Dealer {dealer.Dealer_Code} Error: {ex.Message}");
                }
            }

            return finalResult.ToString();
        }

        // Helper class for deserialization
        // Helper classes for SAP JSON mapping
        public class SapResponse
        {
            public SapData d { get; set; }
        }

        public class SapData
        {
            public List<SapResult> results { get; set; }
        }

        public class SapResult
        {
            public string BusinessPartner { get; set; }
            public string BPIdentificationType { get; set; }
            public string BPIdentificationNumber { get; set; }
        }

        public class Dealer
        {
            public string Dealer_Code { get; set; }
        }

        public string GetDealerMasterSecurityDeposit(string DealerData)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_GLACCOUNTLINEITEM/GLAccountLineItem?$filter=GLAccount eq '10303030' and Ledger eq '0L' and BusinessTransactionType eq 'RFPI' and Customer eq '" + DealerData + "'");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_GLACCOUNTLINEITEM/GLAccountLineItem?$filter=GLAccount eq '10303030' and Ledger eq '0L' and BusinessTransactionType eq 'RFPI' and Customer eq '" + DealerData + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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

                    // JObject jsonResponse = JObject.Parse(resString);

                    return resString;


                }

                // return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string SaveDealerMasterSalesArea(string Org_Id, string Dealer_Code, string DealerData)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('" + Dealer_Code + "')/to_CustomerSalesArea");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('" + Dealer_Code + "')/to_CustomerSalesArea");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                //req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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


                    if (jsonResponse.ContainsKey("d"))
                    {
                        CommonOutput = new CommonSAPDAL(ConnectionName, configuration).SaveSAPDealerSalesArea("SaveDealer", Org_Id, resString, DealerData);

                    }

                }

                return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string SaveDealerMasterSalesAreaAll(string Org_Id, string DealerData)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea?$format=json&$top=999999999");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea?$format=json&$top=1");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                //req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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


                    if (jsonResponse.ContainsKey("d"))
                    {
                        CommonOutput = new CommonSAPDAL(ConnectionName, configuration).SaveSAPDealerSalesArea("SaveDealer", Org_Id, resString, DealerData);

                    }

                }

                return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string GetAll(string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_BILLINGDATA_CDS/YY1_BILLINGDATA?$filter=SoldToParty eq '700000'");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_BILLINGDATA_CDS/YY1_BILLINGDATA?$filter=SoldToParty eq '700000'");
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



                    //if (jsonResponse.ContainsKey("value"))
                    //{
                    //    new CommonSAPDAL(ConnectionName).SaveSAPDealerMaster("SaveDealer", Org_Id, resString);
                    //}






                }

                return resString;

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string SaveMasterSalesArea(string Org_Id, string SalesAreaData)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/ZSB_SALESGROUP1/zsalesgroup");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/ZSB_SALESGROUP1/zsalesgroup?expand=$format=json&$top=1");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                //req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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


                    if (jsonResponse.ContainsKey("d"))
                    {
                        CommonOutput = new CommonSAPDAL(ConnectionName, configuration).SaveSAPSalesArea("SaveSalesArea", Org_Id, resString, SalesAreaData);

                    }

                }

                return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string SaveMasterSalesAreaItem(string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/ZSB_SALESGROUP1/zsalesgroup");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/ZSB_SALESGROUP1/zsalesgroup?expand=$format=json&$top=1");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                //req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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


                    if (jsonResponse.ContainsKey("d"))
                    {
                        CommonOutput = new CommonSAPDAL(ConnectionName, configuration).SaveSAPSalesAreaItem("SaveSalesArea", Org_Id, resString);

                    }

                }

                return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


    }
}
