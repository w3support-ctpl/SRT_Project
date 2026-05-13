using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using Dapper;
using Newtonsoft.Json.Linq;
using System.Data;
using MilkIn_SAPPosting.Models;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
using System.Configuration;

namespace MilkIn_SAPPosting.DAL
{
    internal class SAP_BPPosting
    {
        private IDbConnection db;
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;

        IEnumerable<string> cookies = new List<string>();
        CookieContainer cookieJar = new CookieContainer();

        public SAP_BPPosting(string _SAPUserName, string _SAPPassword, string _SAPAPIURL)
        {
            SAPUserName = _SAPUserName;
            SAPPassword = _SAPPassword;
            SAPAPIURL = _SAPAPIURL;
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public int SaveBusinessPartnerHeader(ReqBusinessParterList ReqObj)
        {
            int BPFlag, BankFlag, ContactFlag, IdFlag,NameFlag;

            // Update Address Name
            NameFlag = SaveBPName(ReqObj);

            // Update Address Details
            BPFlag = SaveBPAddress(ReqObj);

            // Update Bank Details
            BankFlag = SaveBPBankDetails(ReqObj);

            // Update Contact Details
            ContactFlag = SaveBPContactDetails(ReqObj);

            // Update Identification Details
            IdFlag = SaveBPIdentiDetails(ReqObj);

            // Update Final Status in MilkIn
            if (NameFlag == 1 && BPFlag == 1 && BankFlag == 1 && ContactFlag == 1 && IdFlag == 1)
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = "SetFlag",
                    var_Org_Id = ReqObj.Org_Id,
                    var_BusinessPartner_Type = ReqObj.BPType,
                    var_BusinessPartner_Id = ReqObj.User_Id,
                    var_SAP_Code = ReqObj.SAP_Code,
                    var_Status = "2",     // Success 
                    var_Param1 = "",
                    var_Parem2 = ""

                });

                this.db.Query<CommonOutput>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            }
            else
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = "SetFlag",
                    var_Org_Id = ReqObj.Org_Id,
                    var_BusinessPartner_Type = ReqObj.BPType,
                    var_BusinessPartner_Id = ReqObj.User_Id,
                    var_SAP_Code = ReqObj.SAP_Code,
                    var_Status = "3",     // Error 
                    var_Param1 = "",
                    var_Parem2 = ""

                });

                this.db.Query<CommonOutput>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
            }

            return 1;
        }

        public int SaveBPName(ReqBusinessParterList ReqObj)
        {
            // Get Business Partner Address details
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_BPName",
                var_Org_Id = ReqObj.Org_Id,
                var_BusinessPartner_Type = ReqObj.BPType,
                var_BusinessPartner_Id = ReqObj.User_Id,
                var_SAP_Code = ReqObj.SAP_Code,
                var_Status = "",
                var_Param1 = "",
                var_Parem2 = ""
            });

            List<ResBusinessPartnerName> BPNameList = new List<ResBusinessPartnerName>();
            BPNameList = this.db.Query<ResBusinessPartnerName>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            if (BPNameList.Count == 0)
            {
                return 0;   // Name details not found for updating
            }

            ResBusinessPartnerName objPostData = BPNameList[0];

            // var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress");
            string resString;
            string AddressID;
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('" + ReqObj.SAP_Code + "')/to_BusinessPartnerAddress");
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
                        AddressID = jsonResponse["d"]["results"][0]["AddressID"].ToString();

                    }
                }
                catch (System.Net.WebException ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", req.RequestUri, JsonConvert.SerializeObject(objPostData), "500", ex.Message);
                    return 0;
                }
                catch (Exception ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", req.RequestUri, JsonConvert.SerializeObject(objPostData), "500", ex.Message);
                    return 0;
                }
                var request1 = new HttpRequestMessage(HttpMethod.Patch, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='" + ReqObj.SAP_Code + "',AddressID='" + AddressID + "')");

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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(objPostData), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;

                    if (string.IsNullOrEmpty(resString))
                    {
                        new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", request1, JsonConvert.SerializeObject(objPostData), "200", resString);
                    }
                    else
                    {

                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", request1, JsonConvert.SerializeObject(objPostData), "200", resString);
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", request1, JsonConvert.SerializeObject(objPostData), "500", resString);
                        }

                    }

                    return 1;
                }
            }
            catch (Exception ex)
            {

                return 0;

            }

        }


       public int SaveBPContactDetails(ReqBusinessParterList ReqObj)
        {
            // Get Business Partner Address details
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_BPMobile",
                var_Org_Id = ReqObj.Org_Id,
                var_BusinessPartner_Type = ReqObj.BPType,
                var_BusinessPartner_Id = ReqObj.User_Id,
                var_SAP_Code = ReqObj.SAP_Code,
                var_Status = "",
                var_Param1 = "",
                var_Parem2 = ""
            });

            List<ResBusinessPartnerMobile> BPNameList = new List<ResBusinessPartnerMobile>();
            BPNameList = this.db.Query<ResBusinessPartnerMobile>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            if (BPNameList.Count == 0)
            {
                return 0;   // Name details not found for updating
            }

            ResBusinessPartnerMobile objPostData = BPNameList[0];

            // var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress");
            string resString;
            string AddressID;
            string Person;
            string OrdinalNumber;
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('" + ReqObj.SAP_Code + "')/to_AddressIndependentPhone");
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
                        AddressID = jsonResponse["d"]["results"][0]["AddressID"].ToString();
                        Person = jsonResponse["d"]["results"][0]["Person"].ToString();
                        OrdinalNumber = jsonResponse["d"]["results"][0]["OrdinalNumber"].ToString();

                    }
                }
                catch (System.Net.WebException ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_AddressPhoneNumber", req.RequestUri, JsonConvert.SerializeObject(objPostData), "500", ex.Message);
                    return 0;
                }
                catch (Exception ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_AddressPhoneNumber", req.RequestUri, JsonConvert.SerializeObject(objPostData), "500", ex.Message);
                    return 0;
                }
                var request1 = new HttpRequestMessage(HttpMethod.Patch, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_AddressPhoneNumber(AddressID='"+ AddressID +"',Person='" +Person +"',OrdinalNumber='"+OrdinalNumber+"')");

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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(objPostData), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;

                    if (string.IsNullOrEmpty(resString))
                    {
                        new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_AddressPhoneNumber", request1, JsonConvert.SerializeObject(objPostData), "200", resString);
                    }
                    else
                    {

                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_AddressPhoneNumber", request1, JsonConvert.SerializeObject(objPostData), "200", resString);
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_AddressPhoneNumber", request1, JsonConvert.SerializeObject(objPostData), "500", resString);
                        }

                    }

                    return 1;
                }
            }
            catch (Exception ex)
            {

                return 0;

            }

        }


        public int SaveBPAddress(ReqBusinessParterList ReqObj)
        {
            // Get Business Partner Address details
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_BPAddress",
                var_Org_Id = ReqObj.Org_Id,
                var_BusinessPartner_Type = ReqObj.BPType,
                var_BusinessPartner_Id = ReqObj.User_Id,
                var_SAP_Code = ReqObj.SAP_Code,
                var_Status = "",
                var_Param1 = "",
                var_Parem2 = ""
            });

            List<ResBusinessPartnerAddress> BPAddressList = new List<ResBusinessPartnerAddress>();
            BPAddressList = this.db.Query<ResBusinessPartnerAddress>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            if (BPAddressList.Count == 0)
            {
                return 0;   // Address details not found for updating
            }

            ResBusinessPartnerAddress objPostData = BPAddressList[0];

            // var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress");
            string resString;
            string AddressID;
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('" + ReqObj.SAP_Code + "')/to_BusinessPartnerAddress");
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
                        AddressID = jsonResponse["d"]["results"][0]["AddressID"].ToString();

                    }
                }
                catch (System.Net.WebException ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", req.RequestUri, JsonConvert.SerializeObject(objPostData), "500", ex.Message);
                    return 0;
                }
                catch (Exception ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", req.RequestUri, JsonConvert.SerializeObject(objPostData), "500", ex.Message);
                    return 0;
                }
                var request1 = new HttpRequestMessage(HttpMethod.Patch, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerAddress(BusinessPartner='" + ReqObj.SAP_Code + "',AddressID='" + AddressID + "')");

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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(objPostData), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;

                    if (string.IsNullOrEmpty(resString))
                    {
                        new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", request1, JsonConvert.SerializeObject(objPostData), "200", resString);
                    }
                    else
                    {

                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", request1, JsonConvert.SerializeObject(objPostData), "200", resString);
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerAddress", request1, JsonConvert.SerializeObject(objPostData), "500", resString);
                        }

                    }

                    return 1;
                }
            }
            catch (Exception ex)
            {

                return 0;

            }

        }

        public int SaveBPBankDetails(ReqBusinessParterList ReqObj)
        {

            // Get Business Partner Address details
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_BPBank",
                var_Org_Id = ReqObj.Org_Id,
                var_BusinessPartner_Type = ReqObj.BPType,
                var_BusinessPartner_Id = ReqObj.User_Id,
                var_SAP_Code = ReqObj.SAP_Code,
                var_Status = "",
                var_Param1 = "",
                var_Parem2 = ""
            });

            List<ResBusinessPartnerBank> BPAddressList = new List<ResBusinessPartnerBank>();
            BPAddressList = this.db.Query<ResBusinessPartnerBank>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            if (BPAddressList.Count == 0)
            {
                return 0;   // Address details not found for updating
            }

            ResBusinessPartnerBank objPostData = BPAddressList[0];

            //var request1 = (HttpRequestMessage)null;
            string resString;
            string BankIdentification;
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('" + ReqObj.SAP_Code + "')/to_BusinessPartnerBank");
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
                        BankIdentification = jsonResponse["d"]["results"][0]["BankIdentification"].ToString();
                    }
                }
                catch (System.Net.WebException ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", req.RequestUri, JsonConvert.SerializeObject(objPostData), "500", ex.Message);
                    return 0;
                }
                catch (Exception ex)
                {
                    // Create new Bank Details
                    //new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", req.RequestUri, JsonConvert.SerializeObject(ReqObj), "500", ex.Message);
                    return CreateBPBankDetails(ReqObj);
                }

                var request1 = new HttpRequestMessage(HttpMethod.Patch, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartnerBank(BusinessPartner='" + ReqObj.SAP_Code + "',BankIdentification='" + BankIdentification + "')");

                objPostData.BankIdentification = BankIdentification;

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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(objPostData), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;


                    if (string.IsNullOrEmpty(resString))
                    {
                        new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else
                    {
                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", request1, JsonConvert.SerializeObject(objPostData), "200", resString);
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", request1, JsonConvert.SerializeObject(objPostData), "500", resString);
                        }
                    }



                    return 1;
                }
            }
            catch (Exception ex)
            {

                return 0;

            }
        }

        public int SaveBPIdentiDetails(ReqBusinessParterList ReqObj)
        {
            // Get Business Partner Address details
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_BPIdentification",
                var_Org_Id = ReqObj.Org_Id,
                var_BusinessPartner_Type = ReqObj.BPType,
                var_BusinessPartner_Id = ReqObj.User_Id,
                var_SAP_Code = ReqObj.SAP_Code,
                var_Status = "",
                var_Param1 = "",
                var_Parem2 = ""
            });

            List<ResBusinessPartnerIdentification> BPIdentificationList = new List<ResBusinessPartnerIdentification>();
            BPIdentificationList = this.db.Query<ResBusinessPartnerIdentification>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            if (BPIdentificationList.Count == 0)
            {
                return 0;   
            }

            for (int i = 0; i < BPIdentificationList.Count; i++)
            {
                ResBusinessPartnerIdentification objPostData = BPIdentificationList[i];

                DeleteBPIdentificationDetails(objPostData, ReqObj.Org_Id);
                CreateBPIdentificationDetails(objPostData, ReqObj.Org_Id);
            }

            

            return 1;

        }


        public int CreateBPBankDetails(ReqBusinessParterList ReqObj)
        {

            // Get Business Partner Address details
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get_BPBank",
                var_Org_Id = ReqObj.Org_Id,
                var_BusinessPartner_Type = ReqObj.BPType,
                var_BusinessPartner_Id = ReqObj.User_Id,
                var_SAP_Code = ReqObj.SAP_Code,
                var_Status = "",
                var_Param1 = "",
                var_Parem2 = ""
            });

            List<ResBusinessPartnerBank> BPAddressList = new List<ResBusinessPartnerBank>();
            BPAddressList = this.db.Query<ResBusinessPartnerBank>("USP_AdminBusinessPartnerInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

            if (BPAddressList.Count == 0)
            {
                return 0;   // Address details not found for updating
            }

            ResBusinessPartnerBank objPostData = BPAddressList[0];
            objPostData.BankIdentification = "0001";

            //var request1 = (HttpRequestMessage)null;
            string resString;

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('" + ReqObj.SAP_Code + "')/to_BusinessPartnerBank");
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
                    }
                }
                catch (System.Net.WebException ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", req.RequestUri, JsonConvert.SerializeObject(ReqObj), "500", ex.Message);
                    return 0;
                }
                catch (Exception ex)
                {
                    new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", req.RequestUri, JsonConvert.SerializeObject(ReqObj), "500", ex.Message);
                    return 0;
                }

                var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner(BusinessPartner='" + ReqObj.SAP_Code + "')/to_BusinessPartnerBank");

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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(objPostData), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;


                    if (string.IsNullOrEmpty(resString))
                    {
                        new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else
                    {
                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            new SAP_Posting().SAPApiLog("Create", ReqObj.Org_Id, "A_BusinessPartnerBank", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                        }
                    }



                    return 1;
                }
            }
            catch (Exception ex)
            {

                return 0;

            }
        }

        public int DeleteBPIdentificationDetails(ResBusinessPartnerIdentification ReqObj, string Org_Id)
        {
            string resString;
            string BusinessPartner;
            string BPIdentificationType;
            string BPIdentificationNumber;
            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('" + ReqObj.BusinessPartner + "')/to_BuPaIdentification?$filter=BPIdentificationType eq '" + ReqObj.BPIdentificationType + "'");
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
                        BusinessPartner = jsonResponse["d"]["results"][0]["BusinessPartner"].ToString();
                        BPIdentificationType = jsonResponse["d"]["results"][0]["BPIdentificationType"].ToString();
                        BPIdentificationNumber = jsonResponse["d"]["results"][0]["BPIdentificationNumber"].ToString();

                    }
                }
                catch (System.Net.WebException ex)
                {
                    new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", req.RequestUri, JsonConvert.SerializeObject(ReqObj), "500", ex.Message);
                    return 0;
                }
                catch (Exception ex)
                {
                    new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", req.RequestUri, JsonConvert.SerializeObject(ReqObj), "500", ex.Message);
                    return 0;
                }
                var request1 = new HttpRequestMessage(HttpMethod.Delete, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BuPaIdentification(BusinessPartner='" + BusinessPartner + "',BPIdentificationType='" + BPIdentificationType + "',BPIdentificationNumber='" + BPIdentificationNumber + "')");

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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;

                    if (string.IsNullOrEmpty(resString))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else
                    {

                        JObject jsonResponse = JObject.Parse(resString);

                        if (jsonResponse.ContainsKey("d"))
                        {
                            new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                        }
                        else if (jsonResponse.ContainsKey("error"))
                        {
                            new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                        }

                    }

                    return 1;
                }
            }
            catch (Exception ex)
            {

                return 0;

            }
        }

        public int CreateBPIdentificationDetails(ResBusinessPartnerIdentification ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BuPaIdentification");
            string resString;

            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner('" + ReqObj.BusinessPartner + "')/to_BuPaIdentification");
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
                     new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", req.RequestUri, JsonConvert.SerializeObject(ReqObj), "500", ex.Message);
                    return 0;
                }
                catch (Exception ex)
                {
                     new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", req.RequestUri, JsonConvert.SerializeObject(ReqObj), "500", ex.Message);
                    return 0;
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

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;


                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                       new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                         new SAP_Posting().SAPApiLog("Create", Org_Id, "A_BuPaIdentification", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }


                    return 1;
                }
            }
            catch (Exception ex)
            {
               return 0;

            }
        }


    }
}
