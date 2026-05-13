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

namespace MilkIN_API.Areas.AdminConsole_API.FleetX
{
    public class FleetX_Data
    {
       

        



        public string GetFleetXData(string FleetXId)
        {
            var client = new HttpClient();
            var request = new HttpRequestMessage(HttpMethod.Get, "https://api.fleetx.io/api/v1/dispatch/" + FleetXId);
            request.Headers.Add("Authorization", "bearer 7a1f59ae-5de5-4572-98b0-7cbb4a2b41d9");

            try
            {
                var response = client.SendAsync(request).Result;
                response.EnsureSuccessStatusCode();

                string resString = response.Content.ReadAsStringAsync().Result;

                // Process the response as needed

                return resString;
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
        }



    }
}
