

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
    public class DeliverySAP
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

        public DeliverySAP(string Destination)
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





        public string GetAllDeliveries(string startDate, string endDate, string dealerCode)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader?$filter=ActualGoodsMovementDate ge datetime'" + startDate + "'" + " and ActualGoodsMovementDate le datetime'" + endDate + "'  and SoldToParty eq '" + dealerCode + "'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader?$filter=ActualGoodsMovementDate ge datetime'" + startDate + "'" + " and ActualGoodsMovementDate le datetime'" + endDate + "'  and SoldToParty eq '" + dealerCode + "'");
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
                    List<ResDelivery> Delivery = new List<ResDelivery>();

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
                                ResDelivery res_Item = new ResDelivery();

                                res_Item.DeliveryDocument = res_obj[i]["DeliveryDocument"];

                                if (res_obj[i]["ActualGoodsMovementDate"] != null && !string.IsNullOrEmpty(res_obj[i]["ActualGoodsMovementDate"].ToString()))
                                {
                                    DateTime? ActualGoodsMovementDate = null;
                                    ActualGoodsMovementDate = DateTime.Parse(res_obj[i]["ActualGoodsMovementDate"].ToString());
                                    res_Item.ActualGoodsMovementDate = ActualGoodsMovementDate.Value.ToString("dd-MMM-yyyy");
                                }
                                else
                                {
                                    // Set a default value or an empty string as per your requirement
                                    res_Item.ActualGoodsMovementDate = string.Empty; // or res_Header.CreationDate = "Default Date";
                                }

                                res_Item.ShipToParty = res_obj[i]["ShipToParty"];
                                res_Item.SoldToParty = res_obj[i]["SoldToParty"];
                                res_Item.OrderID = res_obj[i]["OrderID"];
                                res_Item.TransportationGroup = res_obj[i]["TransportationGroup"];
                                res_Item.CreatedByUser = res_obj[i]["CreatedByUser"];
                                // res_Item.CreationDate = res_obj[i]["CreationDate"];
                                DateTime? creationDate = null;
                                if (res_obj[i]["CreationDate"] != null && !string.IsNullOrEmpty(res_obj[i]["CreationDate"].ToString()))
                                {
                                    creationDate = DateTime.Parse(res_obj[i]["CreationDate"].ToString());
                                    res_Item.CreationDate = creationDate.Value.ToString("dd-MMM-yyyy");
                                }
                                else
                                {
                                    // Set a default value or an empty string as per your requirement
                                    res_Item.CreationDate = string.Empty; // or res_Header.CreationDate = "Default Date";
                                }
                                string overallGoodsMovementStatus = res_obj[i]["OverallGoodsMovementStatus"].ToString();
                                switch (overallGoodsMovementStatus)
                                {
                                    case "B":
                                        res_Item.OverallGoodsMovementStatus = "Partially Processed";
                                        break;
                                    case "A":
                                        res_Item.OverallGoodsMovementStatus = "Not Yet Processed";
                                        break;
                                    case "C":
                                        res_Item.OverallGoodsMovementStatus = "Completely Processed";
                                        break;
                                    case "":
                                        res_Item.OverallGoodsMovementStatus = "Not Relevant";
                                        break;
                                    default:
                                        res_Item.OverallGoodsMovementStatus = overallGoodsMovementStatus; // Handle other cases as needed
                                        break;
                                }

                                Delivery.Add(res_Item);
                            }
                        }

                    }

                    return JsonConvert.SerializeObject(Delivery);

                }

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string GetOneDelivery(string Delivery_no)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryItem?$filter=DeliveryDocument eq'" + Delivery_no + "'");
            //var resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryItem?$filter=DeliveryDocument eq'" + Delivery_no + "'");
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
                    List<ResDeliveryitem> Delivery = new List<ResDeliveryitem>();

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
                                var  originalDeliveryQuantity = res_obj[i]["OriginalDeliveryQuantity"];
                                
                                    if (originalDeliveryQuantity != null && originalDeliveryQuantity.ToString() != "" && Convert.ToDecimal(originalDeliveryQuantity) > 0)
                                    {
                                    ResDeliveryitem res_Item = new ResDeliveryitem();
                                    res_Item.Material = res_obj[i]["Material"];
                                        res_Item.BillingDocument = res_obj[i]["DeliveryDocument"];
                                        res_Item.BillingDocumentItem = res_obj[i]["DeliveryDocumentItem"];
                                        res_Item.BillingDocumentItemText = res_obj[i]["DeliveryDocumentItemText"];
                                        res_Item.Plant = res_obj[i]["Plant"];
                                        res_Item.ItemWeightUnit = res_obj[i]["DeliveryQuantityUnit"];
                                        res_Item.NetAmount = res_obj[i]["ItemNetWeight"];
                                        res_Item.ReferenceSDDocument = res_obj[i]["ReferenceSDDocument"];
                                        res_Item.BillingDocumentDate = res_obj[i]["Batch"];
                                        res_Item.BillingQuantity = res_obj[i]["OriginalDeliveryQuantity"];
                                    Delivery.Add(res_Item);
                                }
                                
                                
                            }
                        }

                        // dynamic resobj = GetDeliverydata(Delivery_no);


                    }

                    return JsonConvert.SerializeObject(Delivery);

                }
            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string GetDeliverydata(string Delivery_no)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('" + Delivery_no + "')/to_DeliveryDocumentText");
            //var resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('" + Delivery_no + "')/to_DeliveryDocumentText");
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
                    List<dynamic> Delivery = new List<dynamic>();


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
                                dynamic jsonObject = new
                                {
                                    TextElementDescription = res_obj[i]["TextElementDescription"],
                                    TextElementText = res_obj[i]["TextElementText"]

                                };

                                Delivery.Add(jsonObject);
                            }
                        }


                    }


                    return JsonConvert.SerializeObject(Delivery);

                }
            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string GetSalesOrderByDelivery(string Delivery_no)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('" + Delivery_no + "')/to_DeliveryDocumentItem");
            //var resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryHeader('" + Delivery_no + "')/to_DeliveryDocumentItem");
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
                    List<ResDeliveryitem> Delivery = new List<ResDeliveryitem>();


                    if (jsonResponse.ContainsKey("d"))
                    {
                        var resOutput = jsonResponse["d"]["results"];

                        // Deserialize the JSON array
                        var resItems = JsonConvert.DeserializeObject<List<ResDeliveryitem>>(resOutput.ToString());

                        // Group by unique combinations of ReferenceSDDocument and ReferenceSDDocumentItem
                        var groupedItems = resItems.GroupBy(item => new { item.ReferenceSDDocument })
                                                   .Select(group => group.First())
                                                   .ToList();

                        // Add the grouped items to the Delivery list
                        Delivery.AddRange(groupedItems);
                    }
                    return JsonConvert.SerializeObject(Delivery);

                }
            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string GetSalesOrderByInvoice(string Delivery_no)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryItem(DeliveryDocument='" + Delivery_no + "',DeliveryDocumentItem='000010')/to_DocumentFlow");
            //var resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_OUTBOUND_DELIVERY_SRV;v=0002/A_OutbDeliveryItem(DeliveryDocument='" + Delivery_no + "',DeliveryDocumentItem='000010')/to_DocumentFlow");
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
                    List<ResDeliveryitem> Delivery = new List<ResDeliveryitem>();


                    Dictionary<string, string> subsequentDocumentCategoryMap = new Dictionary<string, string>
                    {
                        { "A", "Inquiry" },
                        { "B", "Quotation" },
                        { "C", "Order" },
                        { "D", "Item Proposal" },
                        { "E", "Scheduling Agreement" },
                        { "F", "Scheduling Agreement with External Service Agent" },
                        { "G", "Contract" },
                        { "H", "Returns" },
                        { "I", "Order Without Charge" },
                        { "J", "Delivery" },
                        { "K", "Credit Memo Request" },
                        { "L", "Debit Memo Request" },
                        { "M", "Invoice" },
                        { "N", "Invoice Cancellation" },
                        { "O", "Credit Memo" },
                        { "P", "Debit Memo" },
                        { "Q", "WMS Transfer Order" },
                        { "R", "Goods Movement" },
                        { "S", "Credit Memo Cancellation" },
                        { "T", "Returns Delivery for Order" },
                        { "U", "Pro Forma Invoice" },
                        { "V", "Purchase Order" },
                        { "W", "Independent Regts Plan" },
                        { "X", "Handling Unit" },
                        { "Y", "Rebate Agreement" }
                    };

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
                                ResDeliveryitem res_Item = new ResDeliveryitem();
                                res_Item.BillingDocument = res_obj[i]["Subsequentdocument"];

                                

                                 string SubsequentDocumentCategory = res_obj[i]["SubsequentDocumentCategory"]?.ToString();

                                // Map the SubsequentDocumentCategory to its name
                                if (subsequentDocumentCategoryMap.TryGetValue(SubsequentDocumentCategory, out string categoryName))
                                {
                                    res_Item.BillingDocumentItemText = categoryName; // Assign the mapped name
                                }
                                else
                                {
                                    res_Item.BillingDocumentItemText = SubsequentDocumentCategory; // Use the original value if not found
                                }



                                Delivery.Add(res_Item);
                            }
                        }

                        // dynamic resobj = GetDeliverydata(Delivery_no);


                    }
                    return JsonConvert.SerializeObject(Delivery);

                }
            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

         public string GetDeliveryPDF(string DeliveryId)
        {

           

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/bc/http/sap/zdelivery_http?deliverydocument="+DeliveryId+"");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/bc/http/sap/zdelivery_http?deliverydocument="+DeliveryId+"");
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
