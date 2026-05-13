
using Newtonsoft.Json;
using NuGet.Common;
using Org.BouncyCastle.Asn1.Ocsp;
using Org.BouncyCastle.Ocsp;
using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Xml.Linq;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using System.Data;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using MilkIN_API.Areas.AdminConsole_API.DAL;

namespace MilkIN_API.Areas.AdminConsole_API.SAP
{
    public class MasterSAP
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

        public MasterSAP(string Destination)
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

        

        public string SaveProductMaster(string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_PRODUCT_SRV/A_Product?$expand=to_Description,to_Plant&$filter=ProductType eq 'ZFG1' or ProductType eq 'ZFG2'or ProductType eq 'ZFG3' &$format=json&$top=999999999");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);



                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_PRODUCT_SRV/A_Product?$expand=to_Description,to_Plant&$filter=ProductType eq 'ZFG1' or ProductType eq 'ZFG2'or ProductType eq 'ZFG3' &$format=json&$top=1");
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


                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    // if (jsonResponse.ContainsKey("d"))
                    // {
                    //     new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "Product", request1, "", "200", resString);
                    // }
                    // else if (jsonResponse.ContainsKey("error"))
                    // {
                    //     new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "Product", request1, "", "500", resString);
                    // }


                    return resString;
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string SaveProductMasterUOM(string ProductCode)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_PRODUCT_SRV/A_ProductUnitsOfMeasure?$filter=" + ProductCode  );
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);



                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_PRODUCT_SRV/A_ProductUnitsOfMeasure?$filter=" + ProductCode);
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






        public string DownloaddealerRoute()
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustSalesPartnerFunc?$filter=PartnerFunction eq 'U3'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);



                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustSalesPartnerFunc?$filter=PartnerFunction eq 'U3'");
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



        public string GetPaymentTerm()
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_PAYMENTTERMS_CDS/YY1_PAYMENTTERMS?$filter=Language_1 eq 'EN'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);



                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_PAYMENTTERMS_CDS/YY1_PAYMENTTERMS?$filter=Language_1 eq 'EN'");
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





        public string DownloadAllRoute()
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner?$filter=BusinessPartnerGrouping eq 'ZTRP'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);



                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner?$filter=BusinessPartnerGrouping eq 'ZTRP'");
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



        public string GetNotificationCode()
        {
           
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_CODEGROUP_CDS/YY1_CodeGroup?$filter=Language_1 eq 'EN' and Language_2 eq 'EN'");
           
            string resString;

          

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);



                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_CODEGROUP_CDS/YY1_CodeGroup?$filter=Language_1 eq 'EN' and Language_2 eq 'EN'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                // req.Headers.Add("Cookie", "SAP_SESSIONID_ZAG_100=W1l7CpQfZ7KFaMTENaWNEf3nyxGI8hHurYgFzm6wHUs%3d; sap-usercontext=sap-client=100");
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













    }
}
