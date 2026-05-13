using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AdminConsole_API.Models;
using MilkIN_API.Middleware;
using MySqlX.XDevAPI;
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

namespace MilkIN_API.Areas.AdminConsole_API.SAP
{
    public class BusinessPartnerSAP
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

        public BusinessPartnerSAP(string Destination)
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

        public string SaveBusinessPartner(ReqSAPBusinessPartner ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner");
            string resString;





            ReqSAPBusinessPartner parameter = new ReqSAPBusinessPartner();
            parameter.BusinessPartner = ReqObj.BusinessPartner;
            parameter.AcademicTitle = ReqObj.AcademicTitle;
            parameter.FormOfAddress = ReqObj.FormOfAddress;
            parameter.BusinessPartnerGrouping = ReqObj.BusinessPartnerGrouping;
            parameter.BusinessPartnerCategory = ReqObj.BusinessPartnerCategory;
            parameter.OrganizationBPName1 = ReqObj.OrganizationBPName1;
            parameter.OrganizationBPName2 = ReqObj.OrganizationBPName2;
            parameter.OrganizationBPName3 = ReqObj.OrganizationBPName3;
            parameter.OrganizationBPName4 = ReqObj.OrganizationBPName4;
            parameter.SearchTerm1 = ReqObj.SearchTerm1;
            parameter.AuthorizationGroup = ReqObj.AuthorizationGroup;
            parameter.LegalForm = ReqObj.LegalForm;
            parameter.BusinessPartnerType = ReqObj.BusinessPartnerType;
            parameter.BusinessPartnerIsBlocked = ReqObj.BusinessPartnerIsBlocked;
            parameter.to_BusinessPartnerAddress = ReqObj.to_BusinessPartnerAddress;
            parameter.to_BuPaIdentification = ReqObj.to_BuPaIdentification;
            parameter.to_BusinessPartnerRole = ReqObj.to_BusinessPartnerRole;
            parameter.to_BusinessPartnerBank = ReqObj.to_BusinessPartnerBank;
            parameter.to_Supplier = ReqObj.to_Supplier;






            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner");
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
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_BUSINESS_PARTNER", request1, JsonConvert.SerializeObject(parameter), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_BUSINESS_PARTNER", request1, JsonConvert.SerializeObject(parameter), "500", resString);
                    }


                    return resString;
                }
            }
            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }


         public string SaveBusinessPartnerTest(BusinessPartner_List ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner");
            string resString;

            BusinessPartner_List parameter = new BusinessPartner_List();
        
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner");
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
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_BUSINESS_PARTNER", request1, JsonConvert.SerializeObject(parameter), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new CommonSAPDAL(ConnectionName, configuration).SAPApiLog("Create", Org_Id, "API_BUSINESS_PARTNER", request1, JsonConvert.SerializeObject(parameter), "500", resString);
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
