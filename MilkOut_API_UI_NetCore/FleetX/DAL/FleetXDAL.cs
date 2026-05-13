using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Security.Cryptography;
using System.Data;
using Dapper;
using Newtonsoft.Json;
using MilkOUT_FleetX.Models;
using MySql.Data.MySqlClient;

using Microsoft.AspNetCore.Mvc;
using MySqlX.XDevAPI;
using Org.BouncyCastle.Asn1.Ocsp;
using Org.BouncyCastle.Ocsp;
using System.Net;
using System.Net.Http.Headers;
using System.Xml.Linq;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using Google.Apis.Auth.OAuth2;
using Google.Apis.Util;


namespace MilkOUT_FleetX.DAL
{
    internal class FleetXDAL
    {
        private string SAPUserName;
        private string SAPPassword;
        private string SAPAPIURL;
        private string ConnectionName;
        private string Environment;
        private string OrgId;
        private IDbConnection db;

        public FleetXDAL()
        {

            OrgId = System.Configuration.ConfigurationManager.AppSettings["OrgId"].ToString();
            Environment = System.Configuration.ConfigurationManager.AppSettings["SAPEnvironment"].ToString();

            switch (Environment)
            {
                case "PRD": // Production
                    SAPUserName = "CTPLABAP_SRTPRD";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my409033-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my407919-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionUAT";
                    break;
                case "DEV": // UAT
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my406966-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionDEV";
                    break;
                default: // DEV
                    SAPUserName = "CTPLABAP_SRT";
                    SAPPassword = "Password@#0987654321";
                    SAPAPIURL = "https://my406966-api.s4hana.cloud.sap/";
                    ConnectionName = "ConnectionDEV";
                    break;

            }
            db = new MySqlConnection(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
        }

         private const string FcmEndpoint = "https://fcm.googleapis.com/v1/projects/srt-notifications/messages:send";


        public void Main()
        {
            try
            {
                var parameters = new DynamicParameters(new
                {
                    var_Method_Name = "Get_FleetX",
                    var_Org_Id = OrgId
                });

                List<FleetXModel> PendingDealerList = new List<FleetXModel>();
                PendingDealerList = this.db.Query<FleetXModel>("USP_AdminSAP_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

                Console.WriteLine(PendingDealerList.Count + " FleetX Found");

                for (int i = 0; i < PendingDealerList.Count; i++)
                {
                    new FleetXDAL().FleetX_API(PendingDealerList[i]);
               
                    Console.WriteLine("FleetX Entry " + i + " Posted");
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in finding new FleetX records");
            }


        }
        
        public List<CommonOutput> FleetX_APIs(FleetXModel fleetXModel)
        {
            

             CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1,
                    result_description = "FleetX Posted",
                    result_extra_key = "FleetX Posted"
                };

                return new List<CommonOutput> { commonOutput };

        }


        public List<CommonOutput> FleetX_API(FleetXModel fleetXModel)
        {
            try
            {
                using var client = new HttpClient();

                // Step 1: Get the Bearer Token
                var loginRequest = new HttpRequestMessage(HttpMethod.Post, "https://api.fleetx.io/api/v1/login");
                loginRequest.Headers.Add("Authorization", "Basic ZmxlZXR4OnNlY3JldA==");

                var content = new MultipartFormDataContent
                {
                    { new StringContent("Puja+11117@fleetx.io"), "username" },
                    { new StringContent("lVOk7iG0@"), "password" },
                    { new StringContent("password"), "grant_type" }
                };
                loginRequest.Content = content;

                var loginResponse = client.SendAsync(loginRequest).Result;
                loginResponse.EnsureSuccessStatusCode();

                string loginresString = loginResponse.Content.ReadAsStringAsync().Result;

                JObject loginData = JObject.Parse(loginresString);
                
                string accessToken = loginData.ContainsKey("access_token") ? loginData["access_token"].ToString() : null;

                if (string.IsNullOrEmpty(accessToken))
                {

                    return new List<CommonOutput>
                    {
                        new CommonOutput
                        {
                            result_id = 0,
                            result_description = "Error: Access token not received.",
                            result_extra_key = ""
                        }
                    };
                }

                // Step 2: Use the access token
                var request_1 = new HttpRequestMessage(HttpMethod.Get, "https://api.fleetx.io/api/v1/analytics/live/byNumber/" + fleetXModel.Vehicle_No);
                request_1.Headers.Add("Authorization", "Bearer " + accessToken);

                var response = client.SendAsync(request_1).GetAwaiter().GetResult();
                response.EnsureSuccessStatusCode();

                string resString = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
                var data = JsonConvert.DeserializeObject<dynamic>(resString);

                double currentLat = (double)data.latitude;
                double currentLng = (double)data.longitude;

                if (!string.IsNullOrEmpty(fleetXModel.ShopLatitude) && !string.IsNullOrEmpty(fleetXModel.ShopLongitude))
                {
                    double shopLat = Convert.ToDouble(fleetXModel.ShopLatitude);
                    double shopLng = Convert.ToDouble(fleetXModel.ShopLongitude);

                    // Calculate distance in KM
                    double distance = GetDistanceInKm(currentLat, currentLng, shopLat, shopLng);

                    // Estimate time in minutes assuming average speed of 40 km/h
                    double estimatedMinutes = (distance / 40.0) * 60.0;

                    // Console.WriteLine($"Distance: {distance} km, Estimated Time: {estimatedMinutes} min");

                    if (estimatedMinutes < 10)
                    {
                        // Trigger Firebase Notification
                        // string message = $"Vehicle {fleetXModel.Vehicle_No} is approx {Math.Round(estimatedMinutes)} mins away from shop.";


                        string message = $"Dear {fleetXModel.User_Name}, vehicle {fleetXModel.Vehicle_No} is approximately {Math.Round(estimatedMinutes)} minutes away from your shop.";



                        
                        SendMessageAsync(fleetXModel.Device_Id ?? "", message,fleetXModel.Org_Id,fleetXModel.Route_Id,fleetXModel.Entry_Id).Wait();


                        
                        
                    }
                }

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1,
                    result_description = "FleetX Posted",
                    result_extra_key = "FleetX Posted"
                };

                return new List<CommonOutput> { commonOutput };
            }
            catch (Exception ex)
            {
                return new List<CommonOutput>
                {
                    new CommonOutput
                    {
                        result_id = 0,
                        result_description = "Error: " + ex.Message,
                        result_extra_key = ""
                    }
                };
            }
        }



        public async Task SendMessageAsync(string Device_Id,string body,string Org_Id,string Route_Id,string Entry_Id)
        {

            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Update_Notify",
                var_Org_Id = Org_Id,
                var_Route_Id = Route_Id,
                var_Route_Name = "",
                var_Vehicle_No = "",
                var_Is_Active = 1,
                var_Is_Deleted = 0,
                var_CreatedBy_Id = "",
                var_CreatedBy_Name = "",
                var_Entry_Id = Entry_Id,
                var_User_Id = "",
                var_Type = "",
                var_Title = "FleetX Vehicle Proximity Alert",
                var_Body = body,

            });

            var result = db.Query("USP_SAdminfleetx_Set", parameters, commandType: CommandType.StoredProcedure, commandTimeout: 0).ToList();

            
            var httpClient = new HttpClient();

            // Load the service account JSON file
            GoogleCredential credential = GoogleCredential
                // .FromFile(@"C:\Users\ADMIN\Documents\GitHub\New folder (2)\MilkOut_API_UI_NetCore\MilkOUT_API\srt-notifications-firebase-adminsdk-jpcrq-2acfa721cf.json")

                .FromFile(@"C:\SRTApps\Notifications\srt-notifications-firebase-adminsdk-jpcrq-2acfa721cf.json")

                .CreateScoped("https://www.googleapis.com/auth/firebase.messaging");

            // Get the access token for the request
            var token = await credential.UnderlyingCredential.GetAccessTokenForRequestAsync();

            // Set the authorization header with the access token
            httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

                var messagePayload = new
                {
                    message = new
                    {
                        token = Device_Id,  // Use the actual device token
                        notification = new
                        {
                            title = "FleetX Vehicle Proximity Alert",
                            body = body,
                        }
                    }
                };

                var jsonPayload = JsonConvert.SerializeObject(messagePayload);

                var content = new StringContent(jsonPayload, System.Text.Encoding.UTF8, "application/json");

                // Send the HTTP request
                var response = await httpClient.PostAsync(FcmEndpoint, content);

                }

        private double GetDistanceInKm(double lat1, double lon1, double lat2, double lon2)
        {
            var R = 6371; // Radius of the earth in km
            var dLat = DegreesToRadians(lat2 - lat1);
            var dLon = DegreesToRadians(lon2 - lon1);
            var a =
                Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            var distance = R * c; // Distance in km
            return distance;
        }

        private double DegreesToRadians(double deg)
        {
            return deg * (Math.PI / 180);
        }




    }
}
