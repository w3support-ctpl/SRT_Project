
using Dapper;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Globalization;
using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Xml.Linq;

namespace MilkOUT_API.Areas.AdminConsole_API.SAP
{
    public class DebitMemoSAP
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

        public DebitMemoSAP(string Destination)
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





        public string GetAllDebitMemo(string SoldToParty, string formattedStartDate, string formattedEndDate)
        {

            //  DateTime S_parsedDate = DateTime.ParseExact(formattedStartDate, "dd-MM-yyyy hh:mm:ss tt", CultureInfo.InvariantCulture);

            // // Convert the DateTime object to the desired format
            // string S_isoFormattedDate = S_parsedDate.ToString("yyyy-MM-ddTHH:mm:ss");


            // DateTime E_parsedDate = DateTime.ParseExact(formattedEndDate, "dd-MM-yyyy hh:mm:ss tt", CultureInfo.InvariantCulture);

            // // Convert the DateTime object to the desired format
            // string E_isoFormattedDate = E_parsedDate.ToString("yyyy-MM-ddTHH:mm:ss");

            string S_isoFormattedDate = null; // Initialize the variable
            string E_isoFormattedDate = null; // Initialize the variable

            string[] formats = { "M/d/yyyy hh:mm:ss tt", "dd-MM-yyyy hh:mm:ss tt" };

            // Try to parse the input start date
            if (DateTime.TryParseExact(formattedStartDate, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime S_parsedDate))
            {
                // Convert the parsed DateTime to the desired format
                S_isoFormattedDate = S_parsedDate.ToString("yyyy-MM-ddTHH:mm:ss");
            }

            // Try to parse the input end date
            if (DateTime.TryParseExact(formattedEndDate, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime E_parsedDate))
            {
                // Convert the parsed DateTime to the desired format
                E_isoFormattedDate = E_parsedDate.ToString("yyyy-MM-ddTHH:mm:ss");
            }


            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_DEBIT_MEMO_REQUEST_SRV/A_DebitMemoRequest?$filter=DebitMemoRequestDate ge datetime'" + S_isoFormattedDate + "' and DebitMemoRequestDate le datetime'" + E_isoFormattedDate + "' and SoldToParty eq '" + SoldToParty + "'");
            string resString;

            

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_DEBIT_MEMO_REQUEST_SRV/A_DebitMemoRequest?$filter=DebitMemoRequestDate ge datetime'" + S_isoFormattedDate + "' and DebitMemoRequestDate le datetime'" + E_isoFormattedDate + "' and SoldToParty eq '" + SoldToParty + "'");
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

                    List<dynamic> DebitmemoHeader = new List<dynamic>();


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
                                //var parameters = new DynamicParameters(new
                                //{
                                //    DebitMemoRequest = res_obj[i]["DebitMemoRequest"]

                                //});

                                //DateTime creationDate ;
                                string formattedDate = "";

                                DateTime? creationDate = null;

                                if (res_obj[i]["DebitMemoRequestDate"] != null && !string.IsNullOrEmpty(res_obj[i]["DebitMemoRequestDate"].ToString()))
                                {
                                     //creationDate = DateTime.Parse(res_obj[i]["DebitMemoRequestDate"]);
                                     //formattedDate = creationDate.ToString("yyyy-MM-dd");

                                    creationDate = DateTime.Parse(res_obj[i]["DebitMemoRequestDate"].ToString());
                                    formattedDate = creationDate.Value.ToString("dd-MMM-yyyy");

                                }
                                else
                                {
                                    // Set a default value or an empty string as per your requirement
                                    formattedDate = string.Empty; // or res_Header.CreationDate = "Default Date";
                                }

                                var overallStatus = "";

                                string overallSdProcessStatus = res_obj[i]["OverallSDProcessStatus"].ToString();
                                switch (overallSdProcessStatus)
                                {
                                    case "B":
                                        overallStatus = "In Process";
                                        break;
                                    case "A":
                                        overallStatus = "Open";
                                        break;
                                    case "C":
                                        overallStatus = "Completed";
                                        break;
                                    default:
                                        overallStatus = overallSdProcessStatus; // Handle other cases as needed
                                        break;
                                }


                                dynamic jsonObject = new
                                {
                                    DebitMemoRequest = res_obj[i]["DebitMemoRequest"],
                                    DebitMemoRequestType = res_obj[i]["DebitMemoRequestType"],
                                    SoldToParty = res_obj[i]["SoldToParty"],
                                    PurchaseOrderByCustomer = res_obj[i]["PurchaseOrderByCustomer"],
                                    DebitMemoRequestDate= formattedDate,
                                    TotalNetAmount = res_obj[i]["TotalNetAmount"],
                                    TransactionCurrency  = res_obj[i]["TransactionCurrency"],
                                    OverallSDProcessStatus  = overallStatus

                                };


                                DebitmemoHeader.Add(jsonObject);
                            }
                        }

                    }


                    return JsonConvert.SerializeObject(DebitmemoHeader);

                }



                // return resString;

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }



        public string GetOneDebitMemo(string Debitrequest)
        {

            //var resString;

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_DEBIT_MEMO_REQUEST_SRV/A_DebitMemoRequest('" + Debitrequest + "')/to_Item");
        //var resString;

        


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_DEBIT_MEMO_REQUEST_SRV/A_DebitMemoRequest('" + Debitrequest + "')/to_Item");
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
                    List<dynamic> DebitmemoHeader = new List<dynamic>();


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
                                    DebitMemoRequestItem = res_obj[i]["DebitMemoRequestItem"],
                                    DebitMemoRequestItemText = res_obj[i]["DebitMemoRequestItemText"],
                                    Material = res_obj[i]["Material"],
                                    RequestedQuantity = res_obj[i]["RequestedQuantity"],
                                    RequestedQuantityUnit = res_obj[i]["RequestedQuantityUnit"],
                                    NetAmount = res_obj[i]["NetAmount"],
                                    MaterialGroup = res_obj[i]["MaterialGroup"]
                                };


                                DebitmemoHeader.Add(jsonObject);
                            }
                        }

                    }


                    return JsonConvert.SerializeObject(DebitmemoHeader);

                }



                // return resString;

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }






    }
}
