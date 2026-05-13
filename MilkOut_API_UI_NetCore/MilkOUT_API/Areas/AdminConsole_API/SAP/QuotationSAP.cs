
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Globalization;
using System.Net;
using System.Net.Http.Headers;
using System.Text;

namespace MilkOUT_API.Areas.AdminConsole_API.SAP
{
    public class QuotationSAP
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

        public QuotationSAP(string Destination)
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





        public string GetAllQuotation(string SoldToParty, string formattedStartDate, string formattedEndDate)
        {



            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_QUOTATION_SRV/A_SalesQuotation?$filter=SalesQuotationDate ge datetime'" + formattedStartDate + "' and SalesQuotationDate le datetime'" + formattedEndDate + "' and SoldToParty eq '" + SoldToParty + "'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_QUOTATION_SRV/A_SalesQuotation?$filter=SalesQuotationDate ge datetime'" + formattedStartDate + "' and SalesQuotationDate le datetime'" + formattedEndDate + "' and SoldToParty eq '" + SoldToParty + "'");
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



                    List<ResGetQuotationHeader> quotationHeader = new List<ResGetQuotationHeader>();

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
                                ResGetQuotationHeader res_Header = new ResGetQuotationHeader();
                                res_Header.SalesQuotation = res_obj[i]["SalesQuotation"];
                                // res_Header.PurchaseOrderByCustomer = res_obj[i]["PurchaseOrderByCustomer"];
                                res_Header.TotalNetAmount = res_obj[i]["TotalNetAmount"];
                                res_Header.TransactionCurrency = res_obj[i]["TransactionCurrency"];
                                res_Header.SalesQuotationType = res_obj[i]["SalesQuotationType"];

                                DateTime? creationDate = null;

                                DateTime? bindingPeriodValidityEndDate = null;

                                DateTime? purchaseOrderByCustomer = null;
                                res_Header.PurchaseOrderByCustomer = res_obj[i]["PurchaseOrderByCustomer"].ToString();

                                //if (!string.IsNullOrEmpty(purchaseDateStr) && DateTime.TryParseExact(purchaseDateStr, "MM/dd/yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime purchaseDate))
                                //{
                                //    purchaseOrderByCustomer = purchaseDate;
                                //    res_Header.PurchaseOrderByCustomer = purchaseOrderByCustomer.Value.ToString("dd-MMM-yyyy");
                                //}
                                //else
                                //{
                                //    // Set a default value or an empty string as per your requirement
                                //    res_Header.PurchaseOrderByCustomer = string.Empty; // or res_Header.PurchaseOrderByCustomer = "Default Date";
                                //}

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

                                if (res_obj[i]["BindingPeriodValidityEndDate"] != null && !string.IsNullOrEmpty(res_obj[i]["BindingPeriodValidityEndDate"].ToString()))
                                {
                                    bindingPeriodValidityEndDate = DateTime.Parse(res_obj[i]["BindingPeriodValidityEndDate"].ToString());
                                    res_Header.BindingPeriodValidityEndDate = bindingPeriodValidityEndDate.Value.ToString("dd-MMM-yyyy");
                                }
                                else
                                {
                                    // Set a default value or an empty string as per your requirement
                                    res_Header.BindingPeriodValidityEndDate = string.Empty; // or res_Header.CreationDate = "Default Date";
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
                                quotationHeader.Add(res_Header);
                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }


                    return JsonConvert.SerializeObject(quotationHeader);




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



        public string GetOneQuotation(string QuotationId)
        {

            //var resString;

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_SALES_QUOTATION_SRV/A_SalesQuotation('" + QuotationId + "')/to_Item");
            //var resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_SALES_QUOTATION_SRV/A_SalesQuotation('" + QuotationId + "')/to_Item");
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
                    List<ResGetQuotationItem> quotationItems = new List<ResGetQuotationItem>();

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
                                ResGetQuotationItem res_Item = new ResGetQuotationItem();
                                res_Item.SalesQuotationItem = res_obj[i]["SalesQuotationItem"];
                                res_Item.SalesQuotationItemText = res_obj[i]["SalesQuotationItemText"];
                                res_Item.RequestedQuantity = res_obj[i]["RequestedQuantity"];
                                res_Item.SalesQuotationItemCategory = res_obj[i]["SalesQuotationItemCategory"];
                                res_Item.NetAmount = res_obj[i]["NetAmount"];
                                res_Item.ItemNetWeight = res_obj[i]["ItemNetWeight"];
                                res_Item.TransactionCurrency = res_obj[i]["TransactionCurrency"];
                                res_Item.ItemWeightUnit = res_obj[i]["ItemWeightUnit"];
                                res_Item.RequestedQuantityUnit = res_obj[i]["RequestedQuantityUnit"];


                                quotationItems.Add(res_Item);
                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }


                    return JsonConvert.SerializeObject(quotationItems);







                }



            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public string GetQuotationPDF(string QuotationId)
        {

           

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/bc/http/sap/ZSD_QUOTATION_PDF?salesquotation=" + QuotationId + "");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/bc/http/sap/ZSD_QUOTATION_PDF?salesquotation=" + QuotationId + "");
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







    }
}
