
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NuGet.Common;
using Org.BouncyCastle.Asn1.Ocsp;
using Org.BouncyCastle.Ocsp;
using System.Collections.Generic;
using System.Data;
using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Xml.Linq;
using static MilkOUT_API.Middleware.Notify_Data;

namespace MilkIN_API.Areas.AdminConsole_API.SAP
{
    public class RateSAP
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

        public RateSAP(string Destination)
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

        public string GetProductRateByDealer(ReqProductRate ReqObj)
        {


            string resString;
            string ConditionRecord;
            string ConditionRateValue = "";
            string ConditionQuantityUnit = "";
            string ConditionQuantity = "";
            string code = "";
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType eq 'PPR0' and Customer eq '" + ReqObj.dealer_code + "' and Material eq '" + ReqObj.product_code + "'");
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
                        ConditionRecord = jsonResponse["d"]["results"][0]["ConditionRecord"].ToString();

                    }
                }
                catch (System.Net.WebException ex)
                {
                    ConditionRateValue = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                    ConditionQuantityUnit = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                    ConditionQuantity = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                    code = "-1";

                    return $"{{\"ConditionRateValue\": \"{ConditionRateValue}\",\"ConditionQuantityUnit\": \"{ConditionQuantityUnit}\",\"ConditionQuantity\": \"{ConditionQuantity}\", \"code\": \"{code}\"}}";
                }
                catch (Exception ex)
                {
                    ConditionRateValue = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                    ConditionQuantityUnit = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                    ConditionQuantity = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                    code = "-1";

                    return $"{{\"ConditionRateValue\": \"{ConditionRateValue}\",\"ConditionQuantityUnit\": \"{ConditionQuantityUnit}\",\"ConditionQuantity\": \"{ConditionQuantity}\", \"code\": \"{code}\"}}";

                }
                var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgConditionRecord?$filter=ConditionRecord eq '" + ConditionRecord + "'");

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
                        ConditionRateValue = jsonResponse["d"]["results"][0]["ConditionRateValue"].ToString();
                        ConditionQuantityUnit = jsonResponse["d"]["results"][0]["ConditionQuantityUnit"].ToString();
                        ConditionQuantity = jsonResponse["d"]["results"][0]["ConditionQuantity"].ToString();
                        code = "1";

                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        ConditionRateValue = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                        ConditionQuantityUnit = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                        ConditionQuantity = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                        code = "-1";
                    }
                    else
                    {
                        ConditionRateValue = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                        ConditionQuantityUnit = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                        ConditionQuantity = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                        code = "-1";

                    }

                    return $"{{\"ConditionRateValue\": \"{ConditionRateValue}\",\"ConditionQuantityUnit\": \"{ConditionQuantityUnit}\",\"ConditionQuantity\": \"{ConditionQuantity}\", \"code\": \"{code}\"}}";

                }
            }
            catch (Exception ex)
            {

                ConditionRateValue = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                ConditionQuantityUnit = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                ConditionQuantity = "Rate is not available for the selected product (Product Number: " + ReqObj.product_code + " ) and the selected dealer (Dealer Number: " + ReqObj.dealer_code + " ).";
                code = "-1";

                return $"{{\"ConditionRateValue\": \"{ConditionRateValue}\",\"ConditionQuantityUnit\": \"{ConditionQuantityUnit}\",\"ConditionQuantity\": \"{ConditionQuantity}\", \"code\": \"{code}\"}}";


            }

        }

        public string GetProductRateByDealerNew(ReqProductRate ReqObj)
        {
            string ConditionRateValue = "";
            string ConditionQuantityUnit = "";
            string ConditionQuantity = "";
            string code = "-1";

            string customerGroup = "";
            string customerPriceGroup = "";
            string priceListType = "";

            try
            {
                string bpApi = $"sap/opu/odata/sap/API_BUSINESS_PARTNER/A_CustomerSalesArea(Customer='{ReqObj.dealer_code}',SalesOrganization='{ReqObj.sales_organization}',DistributionChannel='{ReqObj.distribution_channel}',Division='{ReqObj.division}')";
                NetworkCredential credentials =
                    new NetworkCredential(SAPUserName, SAPPassword);

                CookieContainer cookieJar = new CookieContainer();

                HttpWebRequest bpReq = (HttpWebRequest)WebRequest.Create(SAPAPIURL + bpApi);
                bpReq.Credentials = credentials;
                bpReq.Method = "GET";
                bpReq.Headers.Add("x-csrf-token", "Fetch");
                bpReq.Headers.Add("Accept", "application/json");
                bpReq.CookieContainer = cookieJar;

                using (HttpWebResponse bpResp = (HttpWebResponse)bpReq.GetResponse())
                using (StreamReader reader = new StreamReader(bpResp.GetResponseStream()))
                {
                    JObject bpJson = JObject.Parse(reader.ReadToEnd());
                    if (bpJson["d"] != null)
                    {
                        customerGroup = bpJson["d"]["CustomerGroup"]?.ToString() ?? "";
                        customerPriceGroup = bpJson["d"]["CustomerPriceGroup"]?.ToString() ?? "";
                        priceListType = bpJson["d"]["PriceListType"]?.ToString() ?? "";
                    }
                }

            }
            catch
            {
                customerGroup = "";
                customerPriceGroup = "";
                priceListType = "";

            }

            customerGroup = string.IsNullOrEmpty(customerGroup) ? "" : customerGroup;
            customerPriceGroup = string.IsNullOrEmpty(customerPriceGroup) ? "" : customerPriceGroup;
            priceListType = string.IsNullOrEmpty(priceListType) ? "" : priceListType;



            try
            {
                NetworkCredential credentials =
                    new NetworkCredential(SAPUserName, SAPPassword);

                CookieContainer cookieJar = new CookieContainer();

                // STEP 1: API priority list
                List<string> apiFilters = new List<string>
        {
            $"sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType eq 'PPR0' and Material eq '{ReqObj.product_code}' and SalesOrganization eq '{ReqObj.sales_organization}' and DistributionChannel eq '{ReqObj.distribution_channel}' and Customer eq '{ReqObj.dealer_code}'",

            $"sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType eq 'PPR0' and Material eq '{ReqObj.product_code}' and SalesOrganization eq '{ReqObj.sales_organization}' and DistributionChannel eq '{ReqObj.distribution_channel}' and CustomerPriceGroup eq '{customerPriceGroup}'",

            $"sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType eq 'PPR0' and Material eq '{ReqObj.product_code}' and SalesOrganization eq '{ReqObj.sales_organization}' and DistributionChannel eq '{ReqObj.distribution_channel}' and CustomerGroup eq '{customerGroup}' and PriceListType eq '{priceListType}'",

            $"sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType eq 'PPR0' and Material eq '{ReqObj.product_code}' and SalesOrganization eq '{ReqObj.sales_organization}' and DistributionChannel eq '{ReqObj.distribution_channel}' and CustomerGroup eq '{customerGroup}'",

            $"sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgCndnRecdValidity?$filter=ConditionType eq 'PPR0' and Material eq '{ReqObj.product_code}' and SalesOrganization eq '{ReqObj.sales_organization}' and DistributionChannel eq '{ReqObj.distribution_channel}'"
        };

                string selectedConditionRecord = "";
                string CSRFToken = "";
                DateTime today = DateTime.Today;

                // STEP 2: Loop APIs (STOP once valid record found)
                foreach (string api in apiFilters)
                {
                    HttpWebRequest req =
                        (HttpWebRequest)WebRequest.Create(SAPAPIURL + api);

                    req.Credentials = credentials;
                    req.Method = "GET";
                    req.Headers.Add("x-csrf-token", "Fetch");
                    req.Headers.Add("Accept", "application/json");
                    req.CookieContainer = cookieJar;

                    try
                    {
                        using (HttpWebResponse resp = (HttpWebResponse)req.GetResponse())
                        using (StreamReader reader = new StreamReader(resp.GetResponseStream()))
                        {
                            CSRFToken = resp.Headers["x-csrf-token"];

                            JObject json = JObject.Parse(reader.ReadToEnd());
                            JArray results = (JArray)json["d"]?["results"];

                            Console.WriteLine(req.Address.AbsoluteUri);

                            if (results != null && results.Count > 0)
                            {

                                foreach (var r in results)
                                {
                                    string conditionRecord = r["ConditionRecord"]?.ToString();
                                    DateTime ConditionValidityStartDate = DateTime.Parse(r["ConditionValidityStartDate"]?.ToString());
                                    DateTime ConditionValidityEndDate = DateTime.Parse(r["ConditionValidityEndDate"]?.ToString());

                                    //Console.WriteLine((r["ConditionValidityEndDate"]));

                                    Console.WriteLine("---- SAP Record ----");
                                    Console.WriteLine($"Record: {conditionRecord} : StartDate {ConditionValidityStartDate} : EndDate {ConditionValidityEndDate}");


                                }

                                var validRecord = results
                                    .Select(r => new
                                    {
                                        ConditionRecord = r["ConditionRecord"]?.ToString(),
                                        ValidTo = DateTime.Parse(r["ConditionValidityEndDate"]?.ToString())
                                    })
                                    .Where(r => r.ValidTo >= today)
                                    .OrderByDescending(r => r.ValidTo)
                                    .FirstOrDefault();

                                if (validRecord != null)
                                {
                                    selectedConditionRecord = validRecord.ConditionRecord;

                                    break; // 🚀 STOP checking next APIs
                                }
                            }
                        }
                    }
                    catch
                    {
                        // Ignore API error and continue
                    }
                }

                // STEP 3: No record found
                if (string.IsNullOrEmpty(selectedConditionRecord))
                    return NoRateResponse(ReqObj);

                // STEP 4: Call rate API
                string auth =
                    Convert.ToBase64String(
                        Encoding.ASCII.GetBytes(SAPUserName + ":" + SAPPassword));

                HttpClientHandler handler =
                    new HttpClientHandler { CookieContainer = cookieJar };

                using (HttpClient client = new HttpClient(handler))
                {
                    client.BaseAddress = new Uri(SAPAPIURL);
                    client.DefaultRequestHeaders.Accept.Add(
                        new MediaTypeWithQualityHeaderValue("application/json"));

                    HttpRequestMessage request =
                        new HttpRequestMessage(
                            HttpMethod.Get,
                            $"sap/opu/odata/sap/API_SLSPRICINGCONDITIONRECORD_SRV/A_SlsPrcgConditionRecord?$filter=ConditionRecord eq '{selectedConditionRecord}'");

                    request.Headers.Add("Authorization", "Basic " + auth);
                    request.Headers.Add("x-csrf-token", CSRFToken);

                    HttpResponseMessage response = client.Send(request);

                    string resString = response.Content.ReadAsStringAsync().Result;
                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse["d"]?["results"]?.Any() == true)
                    {
                        var r = jsonResponse["d"]["results"][0];

                        ConditionRateValue = r["ConditionRateValue"]?.ToString();
                        ConditionQuantityUnit = r["ConditionQuantityUnit"]?.ToString();
                        ConditionQuantity = r["ConditionQuantity"]?.ToString();
                        code = "1";
                    }
                    else
                    {
                        return NoRateResponse(ReqObj);
                    }
                }

                return $"{{\"ConditionRateValue\":\"{ConditionRateValue}\"," +
                       $"\"ConditionQuantityUnit\":\"{ConditionQuantityUnit}\"," +
                       $"\"ConditionQuantity\":\"{ConditionQuantity}\"," +
                       $"\"code\":\"{code}\"}}";
            }
            catch
            {
                return NoRateResponse(ReqObj);
            }
        }

        private string NoRateResponse(ReqProductRate ReqObj)
        {
            string msg =
                $"Rate is not available for the selected product (Product Number: {ReqObj.product_code}) " +
                $"and the selected dealer (Dealer Number: {ReqObj.dealer_code}).";

            return $"{{\"ConditionRateValue\":\"{msg}\"," +
                   $"\"ConditionQuantityUnit\":\"{msg}\"," +
                   $"\"ConditionQuantity\":\"{msg}\"," +
                   $"\"code\":\"-1\"}}";
        }




    }
}
