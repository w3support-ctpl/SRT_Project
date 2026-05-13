using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net;
using System.Net.Http.Headers;
using System.Text;

using System.Globalization;
using System.Text.Json;
using System.Xml.Linq;

namespace MilkOUT_API.Areas.AdminConsole_API.SAP
{
    public class PaymentSAP
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

        public PaymentSAP(string Destination)
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





        public string GetAllPayment( string formattedStartDate, string formattedEndDate, string dealerCode)
        {


 var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=Customer eq '" + dealerCode + "' and Ledger eq '0L' and ClearingJournalEntry eq '' and FinancialAccountType eq 'D' and PostingDate ge datetime'" + formattedStartDate + "' and PostingDate le datetime'" + formattedEndDate + "'");
            
            // var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=Customer eq '" + dealerCode + "' and AccountingDocumentType eq 'DZ' and Ledger eq '0L' and PostingDate ge datetime'" + formattedStartDate + "' and PostingDate le datetime'" + formattedEndDate + "'");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=Customer eq '" + dealerCode + "' and Ledger eq '0L' and ClearingJournalEntry eq '' and FinancialAccountType eq 'D' and PostingDate ge datetime'" + formattedStartDate + "' and PostingDate le datetime'" + formattedEndDate + "'");
                
                // HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_CUSTOMERLINEITEMS_CDS/YY1_CUSTOMERLINEITEMS?$filter=Customer eq '" + dealerCode + "' and AccountingDocumentType eq 'DZ' and Ledger eq '0L' and PostingDate ge datetime'" + formattedStartDate + "' and PostingDate le datetime'" + formattedEndDate + "'");
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



                    List<ResGetPaymentHeader> paymentHeader = new List<ResGetPaymentHeader>();

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
                                ResGetPaymentHeader res_Header = new ResGetPaymentHeader();
                                res_Header.AccountingDocument = res_obj[i]["AccountingDocument"];
                                res_Header.ReferenceDocument = res_obj[i]["ReferenceDocument"];
                                res_Header.Customer = res_obj[i]["Customer"];
                                res_Header.CustomerName = res_obj[i]["CustomerName"];
                                res_Header.GLAccount = res_obj[i]["GLAccount"];
                                res_Header.DebitCreditCode = res_obj[i]["DebitCreditCode"];
                                res_Header.AmountInBalanceTransacCrcy = res_obj[i]["AmountInBalanceTransacCrcy"];
                                res_Header.AmountInTransactionCurrency = res_obj[i]["AmountInTransactionCurrency"];
                                res_Header.AmountInCompanyCodeCurrency = res_obj[i]["AmountInCompanyCodeCurrency"];
                                res_Header.AmountInGlobalCurrency = res_obj[i]["AmountInGlobalCurrency"];
                                res_Header.BalanceTransactionCurrency = res_obj[i]["BalanceTransactionCurrency"];

                                string DocumentType = res_obj[i]["AccountingDocumentType"];

                                switch (DocumentType)
                                {
                                    case "KZ":
                                        res_Header.AccountingDocumentType = "Vendor Payment";
                                        break;
                                    case "KG":
                                        res_Header.AccountingDocumentType = "Vendor Credit memo";
                                        break;
                                    case "KR":
                                        res_Header.AccountingDocumentType = "Vendor Invoice";
                                        break;
                                    case "RE":
                                        res_Header.AccountingDocumentType = "invoice Gross";
                                        break;
                                    case "DZ":
                                        res_Header.AccountingDocumentType = "Customer payment";
                                        break;
                                    case "DG":
                                        res_Header.AccountingDocumentType = "Customer Credit memo";
                                        break;
                                    case "DR":
                                        res_Header.AccountingDocumentType = "Customer Invoice";
                                        break;
                                    case "RV":
                                        res_Header.AccountingDocumentType = "Billing Doc Transfer";
                                        break;
                                    default:
                                        res_Header.AccountingDocumentType = DocumentType;
                                        break;
                                }

                                DateTime? postingDate = null;
                                if (res_obj[i]["PostingDate"] != null && !string.IsNullOrEmpty(res_obj[i]["PostingDate"].ToString()))
                                {
                                    postingDate = DateTime.Parse(res_obj[i]["PostingDate"].ToString());
                                    res_Header.PostingDate = postingDate.Value.ToString("dd-MMM-yyyy");
                                }
                                else
                                {
                                    // Set a default value or an empty string as per your requirement
                                    res_Header.PostingDate = string.Empty; // or res_Header.PostingDate = "Default Date";
                                }

                                paymentHeader.Add(res_Header);
                            }
                        }


                        //invoiceItems = res_obj.ToList();




                    }


                    return JsonConvert.SerializeObject(paymentHeader);





                }


            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


        public string GetAccountStatementSAP( string formattedStartDate, string formattedEndDate,string supplier)
        {

            DateTime date_formattedStartDate = DateTime.Parse(formattedStartDate);
            DateTime date_formattedEndDate = DateTime.Parse(formattedEndDate);
        
            // Format the DateTime object into the desired format
            string result_formattedStartDate = date_formattedStartDate.ToString("yyyyMMdd");
            string result_formattedEndDate = date_formattedEndDate.ToString("yyyyMMdd");

           

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/bc/http/sap/ZACCOUNT_STATEMENT?companycode=1000&accounttype=D&supplier=" + supplier + "&postingsfrom=" + result_formattedStartDate + "&postingsto=" + result_formattedEndDate + "&!accountingdocumenttype=AB&glaccount=10303030");
            string resString;


         


            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/bc/http/sap/ZACCOUNT_STATEMENT?companycode=1000&accounttype=D&supplier=" + supplier + "&postingsfrom=" + result_formattedStartDate + "&postingsto=" + result_formattedEndDate + "&!accountingdocumenttype=AB&glaccount=10303030");
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



        public string GetAccountStatementSAPPDF( string formattedStartDate, string formattedEndDate,string supplier)
        {

            DateTime S_date = DateTime.Parse(formattedStartDate);
            string S_isoFormattedDate = S_date.ToString("yyyyMMdd");


            DateTime E_date = DateTime.Parse(formattedEndDate);
            string E_isoFormattedDate = E_date.ToString("yyyyMMdd");



            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/bc/http/sap/ZACCOUNT_STATEMENT?companycode=1000&accounttype=D&supplier=" + supplier + "&postingsfrom=" + S_isoFormattedDate + "&postingsto=" + E_isoFormattedDate + "&!accountingdocumenttype=AB&glaccount=10303030");
            string resString;





            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/bc/http/sap/ZACCOUNT_STATEMENT?companycode=1000&accounttype=D&supplier=" + supplier + "&postingsfrom=" + S_isoFormattedDate + "&postingsto=" + E_isoFormattedDate + "&!accountingdocumenttype=AB&glaccount=10303030");
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
