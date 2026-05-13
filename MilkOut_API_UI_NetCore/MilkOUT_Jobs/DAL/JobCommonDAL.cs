using Dapper;
using Microsoft.Extensions.Configuration;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MySql.Data.MySqlClient;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;


namespace MilkOUT_Jobs.DAL
{
    public class JobCommonDAL
    {
        private readonly IConfiguration configuration;

        private IDbConnection db;

        public JobCommonDAL(string Destination)
        {
            this.configuration = configuration;
            string ConnectionName;
            switch (Destination)
            {
                case "MIP":
                    ConnectionName = "ConnectionPRD";
                    break;
                case "MIU":
                    ConnectionName = "ConnectionUAT";
                    break;
                default:
                    ConnectionName = "ConnectionDEV";
                    break;

            }

            db = new MySqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);

        }



        public string RunDBQuery(dynamic InputParam, string StoredProcName)
        {
            DynamicParameters parameters = new DynamicParameters();

            // Convert input string to object
            // dynamic inputParam = JsonConvert.DeserializeObject(InputParam);

            foreach (var parameter in InputParam)
            {
                string paramName = "Var_" + parameter.Name;
                string paramValue = parameter.Value;

                parameters.Add(paramName, paramValue);
            }

            // Get response in dynamic object
            dynamic resObj = this.db.Query<dynamic>(StoredProcName, parameters, commandType: CommandType.StoredProcedure).ToList();

            // Convert response to string and return
            return JsonConvert.SerializeObject(resObj);
        }



        public string GetFleetxData()
        {


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


                        var output = this.db.Query<CommonOutput>("USP_SAdminFleetxData_Set", parameters, commandType: CommandType.StoredProcedure).ToList();

                    }

                    return JsonConvert.SerializeObject(responseContent);
                }
                else
                {
                    return $"Failed to call API. Status code: {response.StatusCode}";
                }
            }
            catch (Exception ex)
            {
                return $"An error occurred: {ex.Message}";
            }


        }












    }

}
