using Dapper;
using MilkIN_API.Areas.AgentApp_API.DAL;
using MilkIN_API.Areas.AgentApp_API.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Net;
using System.Net.Http.Headers;
using System.Text;

namespace MilkIN_API.Areas.AgentApp_API.SAP
{
    public class AccountStatementSAP
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

        public AccountStatementSAP(string Destination)
        {

            switch (Destination)
            {
                case "PRD": // Production
                    SAPUserName = "" + configuration.GetValue("SAPPrdSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPPrdSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPPrdSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT": // UAT
                    SAPUserName = "" + configuration.GetValue("SAPUatSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPUatSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPUatSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionUAT";
                    break;
                case "DEV": // UAT
                    SAPUserName = "" + configuration.GetValue("SAPDevSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPDevSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPDevSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionDEV";
                    break;
                default: // DEV
                    SAPUserName = "" + configuration.GetValue("SAPDevSettings:SAPUserName", "");
                    SAPPassword = "" + configuration.GetValue("SAPDevSettings:SAPPassword", "");
                    SAPAPIURL = "" + configuration.GetValue("SAPDevSettings:SAPAPIURL", "");
                    ConnectionName = "ConnectionDEV";
                    break;

            }
        }





        public string GetAccountStatementSAP(string supplier, string formattedStartDate, string formattedEndDate)
        {

           

            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/bc/http/sap/ZACCOUNT_STATEMENT?companycode=1000&accounttype=K&Supplier=" + supplier + "&postingsfrom=" + formattedStartDate + "&postingsto=" + formattedEndDate + "&!specialglindicator=H");
            string resString;



            try
            {
                // Get Method to fetch CSRF Token
                NetworkCredential credentials = new NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(SAPAPIURL + "sap/bc/http/sap/ZACCOUNT_STATEMENT?companycode=1000&accounttype=K&Supplier=" + supplier + "&postingsfrom=" + formattedStartDate + "&postingsto=" + formattedEndDate + "&!specialglindicator=H?expand=$format=json&$top=1");
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
