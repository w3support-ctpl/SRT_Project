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
    public class PaymentTermsSAP
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

        public PaymentTermsSAP(string Destination)
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





        public string GetPaymentTerms()
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



                    List<ResGetPaymentTermsHeader> paymentTermsHeader = new List<ResGetPaymentTermsHeader>();

                    if (jsonResponse.ContainsKey("d"))
                    {
                        var resOutput = jsonResponse["d"]["results"];

                        dynamic res_obj = JsonConvert.DeserializeObject(resOutput.ToString());

                        int res_Cnt = res_obj.Count;


                        if (res_Cnt > 0)
                        {
                            for (int i = 0; i < res_Cnt; i++)
                            {
                                ResGetPaymentTermsHeader res_Header = new ResGetPaymentTermsHeader();
                                res_Header.PaymentTerms = res_obj[i]["PaymentTerms"];
                                res_Header.CustomerPaymentTermsName = res_obj[i]["CustomerPaymentTermsName"];

                                paymentTermsHeader.Add(res_Header);
                            }
                        }

                    }


                    return JsonConvert.SerializeObject(paymentTermsHeader);


                }


            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        


    }
}
