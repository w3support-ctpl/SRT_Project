using System.Data;
using System.Configuration;
using Dapper;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using MilkOUT_API.Middleware;

namespace MilkOUT_Jobs.DAL
{
    internal class Jobs_Milkout
    {
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;
        private string ConnectionName;
        private string Environment;
        private string OrgId;
        private IDbConnection db;
        public Jobs_Milkout()
        {

            OrgId = System.Configuration.ConfigurationManager.AppSettings["OrgId"].ToString();

            switch (Environment)
            {
                case "PRD": // Production
                    SAPUserName = "CTPLABAP_SRTPRD";
                    SAPPassword = "Password@#0987654321";
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    ConnectionName = "ConnectionUAT";
                    break;
                case "DEV": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    ConnectionName = "ConnectionDEV";
                    break;
                default: // DEV
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    ConnectionName = "ConnectionDEV";
                    break;

            }
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

        public void Main()
        {
            try
            {
                
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = "Received",
                    var_Org_Id = OrgId
                });


                dynamic resObj = this.db.Query<dynamic>("USP_SAdminDealerStock_Manage", parameters, commandType: CommandType.StoredProcedure).ToList();


            }
            catch (Exception ex)
            {
                Console.WriteLine("Error");
            }



            try
            {
 
                    using var _httpClient = new HttpClient();
                    _httpClient.BaseAddress = new Uri("https://api.fleetx.io/");


                    var apiKey = "1fd96414-8920-4127-b655-6e251dea98c1";
                    var endpoint = "api/v1/analytics/live";
                    _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");
                    HttpResponseMessage response = _httpClient.GetAsync(endpoint).Result;

                    if (response.IsSuccessStatusCode)
                    {
                        var responseContent = response.Content.ReadAsStringAsync().Result;

                        dynamic Data = JsonConvert.DeserializeObject(responseContent.ToString());

                        JObject jsonResponse = JObject.Parse(Data.ToString());

                        //XDocument xmlDocument = new XDocument(new XElement("Vehicle"));

                        var xmlDocument = "";

                        if (jsonResponse.ContainsKey("vehicles"))
                        {
                            for (int i = 0; i < Data.vehicles.Count; i++)
                            {


                                xmlDocument += "<Vehicledata><vehicleNumber>" + Data.vehicles[i].vehicleNumber + "</vehicleNumber>" +
                                               "<latitude>" + Data.vehicles[i].latitude + "</latitude>" +
                                               "<longitude>" + Data.vehicles[i].longitude + "</longitude>" +
                                                "<accountId>" + Data.vehicles[i].accountId + "</accountId>" +
                                               "<lastUpdatedAt>" + Data.vehicles[i].lastUpdatedAt + "</lastUpdatedAt></Vehicledata>";


                                //xmlDocument.Root.Add(Fleetxdata);

                            }


                            var parameters = new DynamicParameters(new
                            {
                                var_Method_Name = "SaveData",
                                var_XML_Data = "<Vehicle>" + xmlDocument + "</Vehicle>"
                            }); ;


                            var output = this.db.Query<dynamic>("USP_SAdminFleetxData_Set", parameters, commandType: CommandType.StoredProcedure).ToList();


                            new Notify("").Send_Notification("" , OrgId , "", "GetDealerDataFleetX");




                    }

                }
                    
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error");
                }



        }



    }
}


