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
using MilkOUT_DayEnd_Jobs.Models;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
using System.Configuration;

namespace MilkOUT_DayEnd_Jobs.DAL
{
    internal class SAP_Masters
    {
        private IDbConnection db;
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;

        IEnumerable<string> cookies = new List<string>();
        CookieContainer cookieJar = new CookieContainer();

        public SAP_Masters(string _SAPUserName, string _SAPPassword, string _SAPAPIURL)
        {
            SAPUserName = _SAPUserName;
            SAPPassword = _SAPPassword;
            SAPAPIURL = _SAPAPIURL;
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public List<CommonOutput> SaveDealerSalesArea(ReqDealerSalesArea DealerSalesAreaSave)
        {
            ReqDealerSalesAreaData parameter = new ReqDealerSalesAreaData();


            parameter.org_id = DealerSalesAreaSave.org_id;
            parameter.dealer_code = DealerSalesAreaSave.dealer_code;
            parameter.dealerdata = DealerSalesAreaSave.dealerdata;


            var dynamic = SaveDealerMasterSalesArea(parameter.org_id, parameter.dealer_code, parameter.dealerdata);



            CommonOutput commonOutput = new CommonOutput
            {
                result_id = 1, // Assuming result_id is an integer
                result_description = "SAP not Posted",
                result_extra_key = ""
            };

            // Return the CommonOutput instance as a list with a single item
            return new List<CommonOutput> { commonOutput };


        }


        public string SaveDealerMasterSalesArea(string Org_Id, string Dealer_Code, string DealerData)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('" + Dealer_Code + "')/to_CustomerSalesArea");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BUSINESS_PARTNER/A_Customer('" + Dealer_Code + "')/to_CustomerSalesArea");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);


                    if (jsonResponse.ContainsKey("d"))
                    {
                        CommonOutput = SaveSAPDealerSalesArea("SaveDealer", Org_Id, resString, DealerData);

                    }

                }

                return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public List<CommonOutput> SaveSAPDealerSalesArea(string method, string org_id, string resString, string DealerDatastr)
        {

            JObject jsonResponse = JObject.Parse(resString);

            if (jsonResponse.ContainsKey("d"))
            {
                var results = jsonResponse["d"]["results"];

                var rescount = results.Count();

                if (results != null)
                {

                    XDocument xmlDocument = new XDocument(new XElement("Dealer"));
                    foreach (var result in results)
                    {
                        String DealerCode = result["Customer"].ToString();
                        String SalesOrganization = result["SalesOrganization"].ToString();
                        String DistributionChannel = result["DistributionChannel"].ToString();
                        String Division = result["Division"].ToString();
                        String SalesGroup = result["SalesGroup"].ToString();

                        XElement DealerData = new XElement("DealerData",
                            new XElement("DealerCode", DealerCode),
                            new XElement("SalesOrganization", SalesOrganization),
                            new XElement("DistributionChannel", DistributionChannel),
                            new XElement("Division", Division),
                            new XElement("SalesGroup", SalesGroup)
                        );

                        xmlDocument.Root.Add(DealerData);
                    }

                    var parameters = new DynamicParameters(new
                    {
                        var_Method_Name = method,
                        var_Org_Id = org_id,
                        var_XML_Data = xmlDocument
                    });



                    var output = this.db.Query<CommonOutput>("USP_SAdminDealerSalesGroup_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


                    // Return the CommonOutput instance as a list with a single item
                    return output;

                }
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = jsonResponse["error"]["message"]["value"].ToString(),
                    result_extra_key = jsonResponse["error"]["code"].ToString()
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Sales Area Not Getting From SAP",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

            return new List<CommonOutput>();

        }


        public List<CommonOutput> SaveRetailerOrder(ReqRetailerOrder retailerOrderSave)
        {

            var parameters = new DynamicParameters(new
            {
                var_Org_Id = retailerOrderSave.org_id,
                var_Method_Name = "Closed",
                var_User_Id = "",
                var_User_Name = "",
                var_RetailerOrder_Id = retailerOrderSave.retailerorder_id,
                var_RetailerOrderItem_Id = "",
                var_Retailer_Id = "",
                var_Dealer_Id = "",
                var_SalesUser_Id = "",
                var_Remarks = "",
                var_Product_Id = "",
                var_UOM = "",
                var_Quantity = 0,
                var_Request_For = "Header",
                var_Is_Active = 1,
                var_Is_Deleted = 0
            });

            return this.db.Query<CommonOutput>("USP_SAdminRetailerOrder_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



        }

        public List<CommonOutput> SaveDealerCrateDump(ReqDealerCrateDump DealerCrateDumpSave)
        {
            ReqDealerCrateDump parameter = new ReqDealerCrateDump();


            parameter.org_id = DealerCrateDumpSave.org_id;
            parameter.dealer_code = DealerCrateDumpSave.dealer_code;
            parameter.dealerdata = DealerCrateDumpSave.dealerdata;

            parameter.formattedstartdate = DealerCrateDumpSave.formattedstartdate;
            parameter.formattedenddate = DealerCrateDumpSave.formattedenddate;



            var dynamic = SaveDealerMasterCrateDump(parameter.org_id, parameter.dealer_code, parameter.dealerdata, parameter.formattedstartdate, parameter.formattedenddate);



            CommonOutput commonOutput = new CommonOutput
            {
                result_id = 1, // Assuming result_id is an integer
                result_description = "Posted",
                result_extra_key = ""
            };

            // Return the CommonOutput instance as a list with a single item
            return new List<CommonOutput> { commonOutput };


        }

        public string SaveDealerMasterCrateDump(string Org_Id, string Dealer_Code, string DealerData, string formattedStartDate, string formattedEndDate)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_CRATE_CDS/YY1_CRATE?$filter=Customer eq '" + Dealer_Code + "' and PostingDate ge datetime'" + formattedStartDate + "' and PostingDate  le datetime'" + formattedEndDate + "'");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_CRATE_CDS/YY1_CRATE?$filter=Customer eq '" + Dealer_Code + "' and PostingDate ge datetime'" + formattedStartDate + "' and PostingDate  le datetime'" + formattedEndDate + "'");
                HttpWebResponse resp;

                req.Credentials = credentials;
                req.Method = "GET";
                req.Headers.Add("x-csrf-token", "Fetch");
                this.cookieJar = new CookieContainer();
                req.CookieContainer = this.cookieJar;

                List<CommonOutput> CommonOutput = new List<CommonOutput>();


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

                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);


                    var response1 = client1.Send(request1);

                    resString = response1.Content.ReadAsStringAsync().Result;

                    JObject jsonResponse = JObject.Parse(resString);


                    if (jsonResponse.ContainsKey("d"))
                    {
                        CommonOutput = SaveSAPDealerCrateDump("SaveDealer", Org_Id, resString, DealerData);

                    }

                }

                return JsonConvert.SerializeObject(CommonOutput);

            }

            catch (Exception ex)
            {
                return "Error: =" + ex.Message;

            }
        }

        public List<CommonOutput> SaveSAPDealerCrateDump(string method, string org_id, string resString, string DealerDatastr)
        {

            JObject jsonResponse = JObject.Parse(resString);

            if (jsonResponse.ContainsKey("d"))
            {
                var results = jsonResponse["d"]["results"];

                var rescount = results.Count();

                if (results != null)
                {

                    // XDocument xmlDocument = new XDocument(new XElement("Dealer"));
                    foreach (var result in results)
                    {
                        var xmlDocument = "";

                        String Customer = result["Customer"].ToString();
                        String PostingDate = result["PostingDate"].ToString();
                        String QuantityInBaseUnit = result["QuantityInBaseUnit"].ToString();
                        String Material = result["Material"].ToString();
                        String GoodsMovementType = result["GoodsMovementType"].ToString();

                        // XElement DealerData = new XElement("DealerData",
                        //     new XElement("Customer", Customer),
                        //     new XElement("PostingDate", PostingDate),
                        //     new XElement("QuantityInBaseUnit", QuantityInBaseUnit),
                        //     new XElement("Material", Material)
                        // );

                        // xmlDocument.Root.Add(DealerData);

                        DateTime parsedDate = DateTime.ParseExact(PostingDate, "dd-MM-yyyy HH:mm:ss",
                                          System.Globalization.CultureInfo.InvariantCulture);

                        // Convert to desired format
                        string formattedDate = parsedDate.ToString("yyyy-MM-dd HH:mm:ss");


                        xmlDocument += "<DealerData><Customer>" + Customer + "</Customer>" +
                                           "<PostingDate>" + formattedDate + "</PostingDate>" +
                                           "<QuantityInBaseUnit>" + QuantityInBaseUnit + "</QuantityInBaseUnit>" +
                                           "<GoodsMovementType>" + GoodsMovementType + "</GoodsMovementType>" +
                                           "<Material>" + Material + "</Material></DealerData>";

                        var XML_Data = "<Dealer>" + xmlDocument + "</Dealer>";


                        var parameters = new DynamicParameters(new
                        {
                            var_Method_Name = method,
                            var_Org_Id = org_id,
                            var_XML_Data = XML_Data
                        });



                        var output = this.db.Query<CommonOutput>("Crate_Dump", parameters, commandType: CommandType.StoredProcedure).ToList();
                    }

                    // var parameters = new DynamicParameters(new
                    // {
                    //     var_Method_Name = method,
                    //     var_Org_Id = org_id,
                    //     var_XML_Data = xmlDocument
                    // });



                    // var output = this.db.Query<CommonOutput>("Crate_Dump", parameters, commandType: CommandType.StoredProcedure).ToList();


                    // Return the CommonOutput instance as a list with a single item
                    // return output;
                    CommonOutput commonOutput = new CommonOutput
                    {
                        result_id = 1, // Assuming result_id is an integer
                        result_description = "Downloaded",
                        result_extra_key = ""
                    };

                    // Return the CommonOutput instance as a list with a single item
                    return new List<CommonOutput> { commonOutput };

                }
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = jsonResponse["error"]["message"]["value"].ToString(),
                    result_extra_key = jsonResponse["error"]["code"].ToString()
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };
            }
            else
            {

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = "Sales Area Not Getting From SAP",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

            return new List<CommonOutput>();

        }

    }
}
