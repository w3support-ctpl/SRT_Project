using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Middleware;
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

namespace MilkOUT_API.Areas.AdminConsole_API.FleetX
{
    public class FleetX_Data
    {
       

        




        public string GetFleetXData()
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
                    return "Error: Access token not received.";
                }

                // Step 2: Use the access token
                var request_1 = new HttpRequestMessage(HttpMethod.Get, "https://api.fleetx.io/api/v1/analytics/live");
                request_1.Headers.Add("Authorization", "Bearer " + accessToken);

                var response = client.SendAsync(request_1).GetAwaiter().GetResult();
                response.EnsureSuccessStatusCode();

                string resString = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();

                JObject jsonResponse = JObject.Parse(resString);
                List<MasterDetails> masterData = new List<MasterDetails>();

                var vehicles = jsonResponse["vehicles"];
                if (vehicles != null)
                {
                    foreach (var vehicle in vehicles)
                    {
                        string vehicleNumber = vehicle["vehicleNumber"]?.ToString() ?? string.Empty;

                        masterData.Add(new MasterDetails
                        {
                            item_id = vehicleNumber,
                            item_value = vehicleNumber
                        });
                    }
                }

                return JsonConvert.SerializeObject(masterData);
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }





    }
}
