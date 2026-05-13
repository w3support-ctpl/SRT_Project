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
using MilIn_DayEnd_Jobs.Models;
using Newtonsoft.Json;
using MySql.Data.MySqlClient;
using System.Configuration;

namespace MilIn_DayEnd_Jobs.DAL
{
    internal class Materials
    {
        private IDbConnection db;
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;

        IEnumerable<string> cookies = new List<string>();
        CookieContainer cookieJar = new CookieContainer();

        public Materials(string _SAPUserName, string _SAPPassword, string _SAPAPIURL)
        {
            SAPUserName = _SAPUserName;
            SAPPassword = _SAPPassword;
            SAPAPIURL = _SAPAPIURL;
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public List<CommonOutput> SaveMaterials(ResMaterials materialsSave)
        {

            var dynamic = GetMasterIssue(materialsSave.org_id, "541", materialsSave.formatted_date);

            JObject jsonResponse = JObject.Parse(dynamic);


            var dynamic2 = GetMasterIssue(materialsSave.org_id, "542", materialsSave.formatted_date);

            JObject jsonResponse2 = JObject.Parse(dynamic2);

            if (jsonResponse.ContainsKey("d") || jsonResponse2.ContainsKey("d"))
            {
                var results = new { data = jsonResponse["d"]["results"], data2 = jsonResponse2["d"]["results"]};
                if (results != null)
                {
                    XDocument xmlDocument = new XDocument(new XElement("Material"));
                    foreach (var result in results.data)
                    {
                        string id = result["ID"].ToString();
                        string materialdocumentyear = result["MaterialDocumentYear"].ToString();
                        string materialdocument = result["MaterialDocument"].ToString();
                        string materialdocumentitem = result["MaterialDocumentItem"].ToString();
                        string material = result["Material"].ToString();
                        string plant = result["Plant"].ToString();
                        string storagelocation = result["StorageLocation"].ToString();
                        string postingdate = result["PostingDate"].ToString();
                        string supplier = result["Supplier"].ToString();
                        string goodsmovementtype = result["GoodsMovementType"].ToString();
                        string quantityinbaseunit = result["QuantityInBaseUnit"].ToString();
                        string materialbaseunit = result["MaterialBaseUnit"].ToString();
                        string supplierfullname = result["SupplierFullName"].ToString();


                        XElement productData = new XElement("MaterialData",
                        new XElement("ID", id),
                        new XElement("MaterialDocumentYear", materialdocumentyear),
                        new XElement("MaterialDocument", materialdocument),
                        new XElement("MaterialDocumentItem", materialdocumentitem),
                        new XElement("Material", material),
                        new XElement("Plant", plant),
                        new XElement("StorageLocation", storagelocation),
                        new XElement("PostingDate", postingdate),
                        new XElement("Supplier", supplier),
                        new XElement("GoodsMovementType", goodsmovementtype),
                        new XElement("QuantityInBaseUnit", quantityinbaseunit),
                        new XElement("MaterialBaseUnit", materialbaseunit),
                        new XElement("SupplierFullName", supplierfullname)
                    


                        );

                        xmlDocument.Root.Add(productData);
                    }
                    foreach (var result in results.data2)
                    {
                        string id = result["ID"].ToString();
                        string materialdocumentyear = result["MaterialDocumentYear"].ToString();
                        string materialdocument = result["MaterialDocument"].ToString();
                        string materialdocumentitem = result["MaterialDocumentItem"].ToString();
                        string material = result["Material"].ToString();
                        string plant = result["Plant"].ToString();
                        string storagelocation = result["StorageLocation"].ToString();
                        string postingdate = result["PostingDate"].ToString();
                        string supplier = result["Supplier"].ToString();
                        string goodsmovementtype = result["GoodsMovementType"].ToString();
                        string quantityinbaseunit = result["QuantityInBaseUnit"].ToString();
                        string materialbaseunit = result["MaterialBaseUnit"].ToString();
                        string supplierfullname = result["SupplierFullName"].ToString();


                        XElement productData = new XElement("MaterialData",
                        new XElement("ID", id),
                        new XElement("MaterialDocumentYear", materialdocumentyear),
                        new XElement("MaterialDocument", materialdocument),
                        new XElement("MaterialDocumentItem", materialdocumentitem),
                        new XElement("Material", material),
                        new XElement("Plant", plant),
                        new XElement("StorageLocation", storagelocation),
                        new XElement("PostingDate", postingdate),
                        new XElement("Supplier", supplier),
                        new XElement("GoodsMovementType", goodsmovementtype),
                        new XElement("QuantityInBaseUnit", quantityinbaseunit),
                        new XElement("MaterialBaseUnit", materialbaseunit),
                        new XElement("SupplierFullName", supplierfullname)
                    


                        );

                        xmlDocument.Root.Add(productData);
                    }

                    var parameters = new DynamicParameters(new
                    {
                        var_Method_Name = materialsSave.method_name,
                        var_Org_Id = materialsSave.org_id,
                        var_Date = materialsSave.date,
                        var_MaterialData = xmlDocument
                    });

                    return this.db.Query<CommonOutput>("USP_AdminMaterialIssues_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
                }
            }
            else if (jsonResponse.ContainsKey("error") || jsonResponse2.ContainsKey("error"))
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
                    result_description = "Material Not Getting From SAP",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance as a list with a single item
                return new List<CommonOutput> { commonOutput };


            }

            return new List<CommonOutput>();
        }

        public string GetMasterIssue(string Org_Id, string GoodsMovementType, string PostingDate)
        {


            var request1 = new HttpRequestMessage(HttpMethod.Get, "sap/opu/odata/sap/YY1_MATERIALDOCUMENTS54154_CDS/YY1_MaterialDocuments54154?$filter=GoodsMovementType eq '" + GoodsMovementType + "' and PostingDate eq datetime'" + PostingDate + "'and StorageLocation ne ''");
            string resString;




            try
            {
                // Get Method to fetch CSRF Token
                System.Net.NetworkCredential credentials = new System.Net.NetworkCredential(SAPUserName, SAPPassword);




                HttpWebRequest req = (HttpWebRequest)HttpWebRequest.Create(SAPAPIURL + "sap/opu/odata/sap/YY1_MATERIALDOCUMENTS54154_CDS/YY1_MaterialDocuments54154?$filter=GoodsMovementType eq '" + GoodsMovementType + "' and PostingDate eq datetime'" + PostingDate + "'and StorageLocation ne ''");
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
