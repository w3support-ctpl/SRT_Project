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
    internal class SAP_GRNPosting
    {
        private IDbConnection db;
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;

        IEnumerable<string> cookies = new List<string>();
        CookieContainer cookieJar = new CookieContainer();

        public SAP_GRNPosting(string _SAPUserName, string _SAPPassword, string _SAPAPIURL)
        {
            SAPUserName = _SAPUserName;
            SAPPassword = _SAPPassword;
            SAPAPIURL = _SAPAPIURL;
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public List<CommonOutput> SaveGoodsInwardPosting(ReqGoodsInwardPosting GoodsInwardPostingSave)
        {
            ReqSAPMilkBatch parameter = new ReqSAPMilkBatch();

            var parameterGoodsMovementCode = new DynamicParameters(new
            {

                var_Method_Name = "Get_GoodsMovementCode",
                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_Date = "",
                var_MilkCollectionDairy_Id = "",
                var_Entry_Id = "",
                var_TripDocument_Id = "",
            });

            var GoodsMovementCodeResult = this.db.Query<ReqSAPMilkBatchGoodsMovementCode>("USP_AdminMilkCollectionInSAP_Get", parameterGoodsMovementCode, commandType: CommandType.StoredProcedure).ToList();

            parameter.PostingDate = GoodsInwardPostingSave.search_period;
            /* parameter.PostingDate = "2023-11-15T00:00:00";      */
            parameter.MaterialDocumentHeaderText = "";
            parameter.ReferenceDocument = GoodsInwardPostingSave.milkcollectiondairy_id;
            parameter.GoodsMovementCode = GoodsMovementCodeResult[0].GoodsMovementCode;

            var parameterItem = new DynamicParameters(new
            {

                var_Method_Name = "Get_Quantity_SAP",
                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_Date = "",
                var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                var_Entry_Id = GoodsInwardPostingSave.entry_id,
                var_TripDocument_Id = GoodsInwardPostingSave.tripdocument_id,
            });

            parameter.to_MaterialDocumentItem = this.db.Query<ReqSAPMilkBatchItem>("USP_AdminMilkCollectionInSAP_Get", parameterItem, commandType: CommandType.StoredProcedure).ToList();

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = GoodsInwardPostingSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();
            var dynamic = SaveMilkBatch(parameter, GoodsInwardPostingSave.org_id);

            JObject jsonResponse = JObject.Parse(dynamic);


            if (jsonResponse.ContainsKey("d"))
            {
                // Extract MaterialDocumentYear and MaterialDocument
                string MaterialDocumentYear = jsonResponse["d"]["MaterialDocumentYear"].ToString();
                string MaterialDocument = jsonResponse["d"]["MaterialDocument"].ToString();


                var parameterItemCost = new DynamicParameters(new
                {

                    var_Method_Name = "Get_Quantity_SAPCost",
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_User_Id = GoodsInwardPostingSave.user_id,
                    var_Date = "",
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                    var_Entry_Id = GoodsInwardPostingSave.entry_id,
                    var_TripDocument_Id = GoodsInwardPostingSave.tripdocument_id,
                });

                var parameterItemCostData = this.db.Query<ReqSAPMilkBatchItemCost>("USP_AdminMilkCollectionInSAP_Get", parameterItemCost, commandType: CommandType.StoredProcedure).ToList();


                //TOTQTY

                ReqSAPMilkBatchHeader parameterQty = new ReqSAPMilkBatchHeader();

                parameterQty.Material = parameterItemCostData[0].Material;
                parameterQty.BatchIdentifyingPlant = "";
                parameterQty.Batch = parameterItemCostData[0].Batch;
                parameterQty.CharcInternalID = parameterItemCostData[0].CharcInternalID_TOTQTY;
                parameterQty.CharcValueDependency = "1";
                parameterQty.CharcFromNumericValue = parameterItemCostData[0].TOTQTY;

                SaveMilkBatchHeader(parameterQty, GoodsInwardPostingSave.org_id);

                //FAT

                ReqSAPMilkBatchHeader parameterFat = new ReqSAPMilkBatchHeader();

                parameterFat.Material = parameterItemCostData[0].Material;
                parameterFat.BatchIdentifyingPlant = "";
                parameterFat.Batch = parameterItemCostData[0].Batch;
                parameterFat.CharcInternalID = parameterItemCostData[0].CharcInternalID_FAT;
                parameterFat.CharcValueDependency = "1";
                parameterFat.CharcFromNumericValue = parameterItemCostData[0].Fat;

                SaveMilkBatchHeader(parameterFat, GoodsInwardPostingSave.org_id);


                //SNF

                ReqSAPMilkBatchHeader parameterSNF = new ReqSAPMilkBatchHeader();

                parameterSNF.Material = parameterItemCostData[0].Material;
                parameterSNF.BatchIdentifyingPlant = "";
                parameterSNF.Batch = parameterItemCostData[0].Batch;
                parameterSNF.CharcInternalID = parameterItemCostData[0].CharcInternalID_SNF;
                parameterSNF.CharcValueDependency = "1";
                parameterSNF.CharcFromNumericValue = parameterItemCostData[0].SNF;

                SaveMilkBatchHeader(parameterSNF, GoodsInwardPostingSave.org_id);


                //TOTFAT


                ReqSAPMilkBatchHeader parameterTOTFAT = new ReqSAPMilkBatchHeader();

                parameterTOTFAT.Material = parameterItemCostData[0].Material;
                parameterTOTFAT.BatchIdentifyingPlant = "";
                parameterTOTFAT.Batch = parameterItemCostData[0].Batch;
                parameterTOTFAT.CharcInternalID = parameterItemCostData[0].CharcInternalID_TOTFAT;
                parameterTOTFAT.CharcValueDependency = "1";
                parameterTOTFAT.CharcFromNumericValue = parameterItemCostData[0].TOTFAT;

                SaveMilkBatchHeader(parameterTOTFAT, GoodsInwardPostingSave.org_id);

                //TOTSNF

                ReqSAPMilkBatchHeader parameterTOTSNF = new ReqSAPMilkBatchHeader();

                parameterTOTSNF.Material = parameterItemCostData[0].Material;
                parameterTOTSNF.BatchIdentifyingPlant = "";
                parameterTOTSNF.Batch = parameterItemCostData[0].Batch;
                parameterTOTSNF.CharcInternalID = parameterItemCostData[0].CharcInternalID_TOTSNF;
                parameterTOTSNF.CharcValueDependency = "1";
                parameterTOTSNF.CharcFromNumericValue = parameterItemCostData[0].TOTSNF;

                SaveMilkBatchHeader(parameterTOTSNF, GoodsInwardPostingSave.org_id);

                //FATCOST

                ReqSAPMilkBatchHeader parameterFatCost = new ReqSAPMilkBatchHeader();

                parameterFatCost.Material = parameterItemCostData[0].Material;
                parameterFatCost.BatchIdentifyingPlant = "";
                parameterFatCost.Batch = parameterItemCostData[0].Batch;
                parameterFatCost.CharcInternalID = parameterItemCostData[0].CharcInternalID_FATCOST;
                parameterFatCost.CharcValueDependency = "1";
                parameterFatCost.CharcFromNumericValue = parameterItemCostData[0].FatCost;

                SaveMilkBatchHeader(parameterFatCost, GoodsInwardPostingSave.org_id);

                //SNFCOST

                ReqSAPMilkBatchHeader parameterSNFCost = new ReqSAPMilkBatchHeader();

                parameterSNFCost.Material = parameterItemCostData[0].Material;
                parameterSNFCost.BatchIdentifyingPlant = "";
                parameterSNFCost.Batch = parameterItemCostData[0].Batch;
                parameterSNFCost.CharcInternalID = parameterItemCostData[0].CharcInternalID_SNFCOST;
                parameterSNFCost.CharcValueDependency = "1";
                parameterSNFCost.CharcFromNumericValue = parameterItemCostData[0].SNFCost;

                SaveMilkBatchHeader(parameterSNFCost, GoodsInwardPostingSave.org_id);



                //SPGRYCOST

                ReqSAPMilkBatchHeader parameterSPGRYCost = new ReqSAPMilkBatchHeader();

                parameterSPGRYCost.Material = parameterItemCostData[0].Material;
                parameterSPGRYCost.BatchIdentifyingPlant = "";
                parameterSPGRYCost.Batch = parameterItemCostData[0].Batch;
                parameterSPGRYCost.CharcInternalID = parameterItemCostData[0].CharcInternalID_SPGRYCOST;
                parameterSPGRYCost.CharcValueDependency = "1";
                parameterSPGRYCost.CharcFromNumericValue = parameterItemCostData[0].SPGRYCost;

                SaveMilkBatchHeader(parameterSPGRYCost, GoodsInwardPostingSave.org_id);


                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = GoodsInwardPostingSave.method_name,
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_Entry_Id = "2", // Success 
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                    var_Year = MaterialDocumentYear,
                    var_SAP_Document_Id = MaterialDocument,
                    var_User_Id = GoodsInwardPostingSave.user_id,
                    var_User_Name = GoodsInwardPostingSave.user_name,
                });

                return this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = GoodsInwardPostingSave.method_name,
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_Entry_Id = "3",  // Error
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.milkcollectiondairy_id,
                    var_Year = "",
                    var_SAP_Document_Id = "",
                    var_User_Id = GoodsInwardPostingSave.user_id,
                    var_User_Name = GoodsInwardPostingSave.user_name,
                });

                this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

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
                    result_description = "SAP not Posted",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

        }

        public string SaveMilkBatch(ReqSAPMilkBatch ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
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

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;



                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "API_MATERIAL_DOCUMENT_SRV", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "API_MATERIAL_DOCUMENT_SRV", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }

                    return resString;
                }
            }
            catch (Exception ex)
            {

                return "Error: =" + ex.Message;

            }
        }

        public string SaveMilkBatchHeader(ReqSAPMilkBatchHeader ReqObj, string Org_Id)
        {
            //var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue?$format=json");

            //var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue(Material='"+ ReqObj.Material + "',BatchIdentifyingPlant='',Batch='"+ ReqObj.Batch + "',CharcInternalID='" + ReqObj.CharcInternalID + "',CharcValuePositionNumber='1')");

            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                //HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue?$format=json");

                //HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue(Material='" + ReqObj.Material + "',BatchIdentifyingPlant='',Batch='" + ReqObj.Batch + "',CharcInternalID='" + ReqObj.CharcInternalID + "',CharcValuePositionNumber='1')");

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_BATCH_SRV/BatchCharcValue");
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


                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;



                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "API_BATCH_SRV", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "API_BATCH_SRV", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
                    }

                    return resString;
                }
            }
            catch (Exception ex)
            {

                return "Error: =" + ex.Message;
            }
        }

        public List<CommonOutput> SaveCrateGRNPosting(ReqCrateGRNPosting GoodsInwardPostingSave)
        {
            ReqSAPGRNCrateBatch parameter = new ReqSAPGRNCrateBatch();

            var parameterGoodsMovementCode = new DynamicParameters(new
            {

                var_Method_Name = "Get_GoodsMovementCode",
                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_Date = "",
                var_MilkCollectionDairy_Id = "",
                var_Entry_Id = "",
                var_TripDocument_Id = "",
            });

            var GoodsMovementCodeResult = this.db.Query<ReqSAPMilkBatchGoodsMovementCode>("USP_AdminMilkCollectionInSAP_Get", parameterGoodsMovementCode, commandType: CommandType.StoredProcedure).ToList();

            parameter.PostingDate = GoodsInwardPostingSave.search_period;
            parameter.MaterialDocumentHeaderText = GoodsInwardPostingSave.batch_id;
            parameter.ReferenceDocument = GoodsInwardPostingSave.dealer_id;
            parameter.GoodsMovementCode = GoodsMovementCodeResult[0].GoodsMovementCode;

            var parameterItem = new DynamicParameters(new
            {

                var_Method_Name = "Get_CrateQuantity_SAP",
                var_Org_Id = GoodsInwardPostingSave.org_id,
                var_User_Id = GoodsInwardPostingSave.user_id,
                var_Date = "",
                var_MilkCollectionDairy_Id = GoodsInwardPostingSave.dealer_id,
                var_Entry_Id = GoodsInwardPostingSave.batch_id,
                var_TripDocument_Id = GoodsInwardPostingSave.dealer_id,
            });

            parameter.to_MaterialDocumentItem = this.db.Query<ReqSAPCrateBatchItem>("USP_AdminMilkCollectionInSAP_Get", parameterItem, commandType: CommandType.StoredProcedure).ToList();

            var parameterOrg = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = GoodsInwardPostingSave.org_id,
            });

            var parameterOrgData = this.db.Query<OrgOutPut>("USP_AdminOrg_Get", parameterOrg, commandType: CommandType.StoredProcedure).ToList();

            var Connection_Name = parameterOrgData[0].ConnectionName.ToString();
            var dynamic = SaveCrateBatchHeader(parameter, GoodsInwardPostingSave.org_id);

            JObject jsonResponse = JObject.Parse(dynamic);


            if (jsonResponse.ContainsKey("d"))
            {
                // Extract MaterialDocumentYear and MaterialDocument
                string MaterialDocumentYear = jsonResponse["d"]["MaterialDocumentYear"].ToString();
                string MaterialDocument = jsonResponse["d"]["MaterialDocument"].ToString();


                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = GoodsInwardPostingSave.method_name,
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_Entry_Id = "2", // Success 
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.dealer_id,
                    var_Year = MaterialDocumentYear,
                    var_SAP_Document_Id = MaterialDocument,
                    var_User_Id = GoodsInwardPostingSave.batch_id,
                    var_User_Name = GoodsInwardPostingSave.user_name,
                });

                return this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
            }
            else if (jsonResponse.ContainsKey("error"))
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = GoodsInwardPostingSave.method_name,
                    var_Org_Id = GoodsInwardPostingSave.org_id,
                    var_Entry_Id = "3",  // Error
                    var_MilkCollectionDairy_Id = GoodsInwardPostingSave.dealer_id,
                    var_Year = "",
                    var_SAP_Document_Id = "",
                    var_User_Id = GoodsInwardPostingSave.batch_id,
                    var_User_Name = GoodsInwardPostingSave.user_name,
                });

                this.db.Query<CommonOutput>("USP_AdminMilkCollectionInSAP_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

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
                    result_description = "SAP not Posted",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }
            return new List<CommonOutput>();
        }

        public string SaveCrateBatchHeader(ReqSAPGRNCrateBatch ReqObj, string Org_Id)
        {
            var request1 = new HttpRequestMessage(HttpMethod.Post, "sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
            string resString;


            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);

                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
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

                    // request1 = new HttpRequestMessage(HttpMethod.Post, "API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentHeader");
                    request1.Headers.Add("x-csrf-token", CSRFToken);
                    request1.Headers.Add("Authorization", "Basic " + svcCredentials);

                    request1.Content = new StringContent(JsonConvert.SerializeObject(ReqObj), Encoding.UTF8, "application/json");
                    var response1 = client1.Send(request1);
                    resString = response1.Content.ReadAsStringAsync().Result;



                    JObject jsonResponse = JObject.Parse(resString);

                    if (jsonResponse.ContainsKey("d"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "API_MATERIAL_DOCUMENT_SRV", request1, JsonConvert.SerializeObject(ReqObj), "200", resString);
                    }
                    else if (jsonResponse.ContainsKey("error"))
                    {
                        new SAP_Posting().SAPApiLog("Create", Org_Id, "API_MATERIAL_DOCUMENT_SRV", request1, JsonConvert.SerializeObject(ReqObj), "500", resString);
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
