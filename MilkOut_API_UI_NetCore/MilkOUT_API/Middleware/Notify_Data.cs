using Microsoft.Extensions.Configuration;
using MilkOUT_API.Areas.SalesApp_API.DAL;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using System.Collections;
using System.Data;
using System.Net;
using System.Text;
using Google.Apis.Auth.OAuth2;
using Google.Apis.Util;
using System;
using System.Threading.Tasks;
using System.Net.Http;
using System.Net.Http.Headers;



namespace MilkOUT_API.Middleware
{
    public class Notify_Data
    {

        private readonly IConfiguration configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        private const string FcmEndpoint = "https://fcm.googleapis.com/v1/projects/srt-notifications/messages:send";


        public Notify_Data(string Destination)
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
            db = new MySqlConnection(configuration.GetConnectionString(ConnectionName));
        }

        public class GCMTokenCollections
        {
            public List<string> registration_ids = new List<string>();
            public Notification notification = new Notification();
            public Data data = new Data();
        }

        public class Notification
        {
            public string title { get; set; }
            public string body { get; set; }

        }

         public class Data
        {
            public string? Type { get; set; }
        }



        public string Send_SMS_Message(string Message, string MobileNo, string TEMPID)
        {

            var ApiUrl = "https://onlysms.co.in/api/sms.aspx?UserID=thorat&UserPass=t123&MobileNo=" + MobileNo + "&GSMID=SRTMPL&PEID=1101360960000029590&Message=" + Message + "&TEMPID=" + TEMPID + "&UNICODE=TEXT";
            var responseString = "";
            var request = (HttpWebRequest)WebRequest.Create(ApiUrl);
            request.Method = "GET";
            request.ContentType = "application/json";

            using (var response1 = request.GetResponse())
            {
                using (var reader = new StreamReader(response1.GetResponseStream()))
                {
                    responseString = reader.ReadToEnd();
                }
            }
            return responseString;

        }

        public int Send_Notification(string Profile_Id, string Org_Id, string User_Type, string Method_Name)
        {

            try
            {

                var parameters = new
                {
                    Method_Name = Method_Name,
                    Org_Id,
                    Profile_Id,
                    User_Type,
                };

                string ReqParams = JsonConvert.SerializeObject(parameters);

                dynamic inputParam = JsonConvert.DeserializeObject(ReqParams.ToString());


                string destination_name = "";
                string res_Str = new CommonDAL(destination_name, configuration).RunDBQuery(inputParam, "USP_DeviceToken_Get");

                dynamic Response = JsonConvert.DeserializeObject(res_Str.ToString());

                var Token_List = Response.ToObject<List<dynamic>>();


                SendMessageAsync(Token_List);

                // Send_FireBase_Notification(Token_List);

                return 1;

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;


                return 1;
            }

        }

        // public int Send_FireBase_Notification(List<dynamic> Token_List)
        // {
        //    ArrayList Response_Array = new ArrayList();

        //    try
        //    {
        //        string Response = "";

        //        List<string> GCMTokens = new List<string>();
        //        for (int i = 0; i < Token_List.Count; i++)
        //        {
        //            GCMTokens.Add(Token_List[i].Device_Id.ToString() + "");
        //        }

        //        if (GCMTokens.Count > 0)
        //        {
        //            int NoOfloop = GCMTokens.Count() / 999;

        //            for (int i = 0; i <= NoOfloop; i++)
        //            {
        //                GCMTokenCollections GTC = new GCMTokenCollections();

        //                GTC.registration_ids = GCMTokens;
        //                GTC.registration_ids = GCMTokens.Skip(i * 999).Take(999).ToList();

        //                Notification d = new Notification();
        //                d.title = Token_List[i].Notification_Title.ToString();
        //                d.body = Token_List[i].Notification_Text.ToString();

        //                Data dt = new Data();
        //                dt.Type = "Notification";

        //                GTC.data = dt;
        //                GTC.notification = d;

        //                var Test = JsonConvert.SerializeObject(GTC);

        //                WebRequest request = WebRequest.Create("https://fcm.googleapis.com/v1/projects/{1:1096302228331:android:ebcd93401a354d43ea522e}/messages:send");

        //                request.Method = "POST";

        //                byte[] byteArray = Encoding.UTF8.GetBytes(Test);

        //                request.ContentType = "application/json";
        //                request.ContentLength = byteArray.Length;
        //                request.Headers.Add("Authorization", "key=AAAA_0C0c2s:APA91bGDTIrg-K3LqLRZNnUn-hCYqMT48ovNCsbLrp1w3OYYac292VXhGC4tHug2LH2cTTQxaNYVlE2x1cvjKX042iX-rGHVpPW95WMJfxs6Upb1azktek8iATRo2yLS63XmAznUvOrq");


        //                Stream dataStream = request.GetRequestStream();
        //                dataStream.Write(byteArray, 0, byteArray.Length);
        //                dataStream.Close();

        //                using (WebResponse response = request.GetResponse())
        //                using (StreamReader stream = new StreamReader(response.GetResponseStream()))
        //                {
        //                    Response = stream.ReadToEnd();
        //                }
        //            }
        //        }

        //        return 1;

        //    }
        //    catch (Exception ex)
        //    {
        //        return -1;
        //    }

        // }



        // public async Task<int> Send_FireBase_Notification(List<dynamic> Token_List)
        // {
        //     ArrayList Response_Array = new ArrayList();
        //     try
        //     {
        //         string Response = "";

        //         List<string> GCMTokens = new List<string>();
        //         for (int i = 0; i < Token_List.Count; i++)
        //         {
        //             GCMTokens.Add(Token_List[i].Device_Id.ToString() + "");
        //         }

        //         if (GCMTokens.Count > 0)
        //         {
        //             int NoOfloop = GCMTokens.Count() / 999;

        //             for (int i = 0; i <= NoOfloop; i++)
        //             {
        //                 GCMTokenCollections GTC = new GCMTokenCollections();

        //                 GTC.registration_ids = GCMTokens.Skip(i * 999).Take(999).ToList();

        //                 Notification d = new Notification();
        //                 d.title = Token_List[i].Notification_Title.ToString();
        //                 d.body = Token_List[i].Notification_Text.ToString();

        //                 Data dt = new Data();
        //                 dt.Type = "Notification";

        //                 GTC.data = dt;
        //                 GTC.notification = d;

        //                 var Test = JsonConvert.SerializeObject(GTC);

        //                 // Get the OAuth access token
        //                 string accessToken = await GetAccessToken();

        //                 WebRequest request = WebRequest.Create("https://fcm.googleapis.com/v1/projects/{1:1096302228331:android:ebcd93401a354d43ea522e}/messages:send");

        //                 request.Method = "POST";

        //                 byte[] byteArray = Encoding.UTF8.GetBytes(Test);

        //                 request.ContentType = "application/json";
        //                 request.ContentLength = byteArray.Length;

        //                 // Use Bearer token in the Authorization header
        //                 request.Headers.Add("Authorization", "Bearer " + accessToken);

        //                 Stream dataStream = request.GetRequestStream();
        //                 dataStream.Write(byteArray, 0, byteArray.Length);
        //                 dataStream.Close();

        //                 using (WebResponse response = request.GetResponse())
        //                 using (StreamReader stream = new StreamReader(response.GetResponseStream()))
        //                 {
        //                     Response = stream.ReadToEnd();
        //                 }
        //             }
        //         }

        //         return 1;

        //     }
        //     catch (Exception ex)
        //     {
        //         // Log or handle the exception
        //         return -1;
        //     }
        // }


    // public async Task SendMessageAsync(string message,List<dynamic> Token_List)
    // {
    //     var httpClient = new HttpClient();

    //     // Load the service account JSON file
    //     GoogleCredential credential = GoogleCredential
    //         .FromFile(@"C:\Users\ADMIN\Documents\GitHub\New folder (2)\MilkOut_API_UI_NetCore\MilkOUT_API\srt-notifications-firebase-adminsdk-jpcrq-2acfa721cf.json")
    //         .CreateScoped("https://www.googleapis.com/auth/firebase.messaging");

    //     // Get the access token for the request
    //     var token = await credential.UnderlyingCredential.GetAccessTokenForRequestAsync();

    //     // Set the authorization header with the access token
    //     httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

    //     // Create the message payload
    //     var messagePayload = new
    //     {
    //         message = new
    //         {
    //             token = Token_List[0].Device_Id.ToString(),  // Use the actual device token
    //             notification = new
    //             {
    //                 title = "Account Disabled",
    //                 body = message,
    //             }
    //         }
    //     };

    //     var jsonPayload = JsonConvert.SerializeObject(messagePayload);

    //     var content = new StringContent(jsonPayload, System.Text.Encoding.UTF8, "application/json");

    //     // Send the HTTP request
    //     var response = await httpClient.PostAsync(FcmEndpoint, content);

    //     if (response.IsSuccessStatusCode)
    //     {
    //         Console.WriteLine("Message sent successfully");
    //     }
    //     else
    //     {
    //         var responseContent = await response.Content.ReadAsStringAsync();
    //         Console.WriteLine($"Error sending message: {responseContent}");
    //     }
    // }
        
    // }

// public async Task SendMessageAsync(string message, List<dynamic> Token_List)
// {
//     var httpClient = new HttpClient();

//     // Load the service account JSON file
//     GoogleCredential credential = GoogleCredential
//         .FromFile(@"C:\Users\ADMIN\Documents\GitHub\New folder (2)\MilkOut_API_UI_NetCore\MilkOUT_API\srt-notifications-firebase-adminsdk-jpcrq-2acfa721cf.json")
//         .CreateScoped("https://www.googleapis.com/auth/firebase.messaging");

//     // Get the access token for the request
//     var token = await credential.UnderlyingCredential.GetAccessTokenForRequestAsync();

//     // Set the authorization header with the access token
//     httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

//     // Loop through each token in the Token_List
//     foreach (var tokenItem in Token_List)
//     {
//         // Create the message payload
//         var messagePayload = new
//         {
//             message = new
//             {
//                 token = tokenItem.Device_Id.ToString(),  // Use the actual device token
//                 notification = new
//                 {
//                     title = "Account Disabled",
//                     body = message,
//                 }
//             }
//         };

//         var jsonPayload = JsonConvert.SerializeObject(messagePayload);

//         var content = new StringContent(jsonPayload, System.Text.Encoding.UTF8, "application/json");

//         // Send the HTTP request
//         var response = await httpClient.PostAsync(FcmEndpoint, content);

//         if (response.IsSuccessStatusCode)
//         {
//             Console.WriteLine($"Message sent successfully to {tokenItem.Device_Id}");
//         }
//         else
//         {
//             var responseContent = await response.Content.ReadAsStringAsync();
//             Console.WriteLine($"Error sending message to {tokenItem.Device_Id}: {responseContent}");
//         }
//     }
// }

public async Task SendMessageAsync(List<dynamic> Token_List)
{
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

    // Loop through each token in the Token_List
    foreach (var tokenItem in Token_List)
    {
        // Create the message payload
        var messagePayload = new
        {
            message = new
            {
                token = tokenItem.Device_Id.ToString(),  // Use the actual device token
                notification = new
                {
                    title = tokenItem.Notification_Title.ToString(),
                    body = tokenItem.Notification_Text.ToString(),
                }
            }
        };

        var jsonPayload = JsonConvert.SerializeObject(messagePayload);

        var content = new StringContent(jsonPayload, System.Text.Encoding.UTF8, "application/json");

        // Send the HTTP request
        var response = await httpClient.PostAsync(FcmEndpoint, content);

        if (response.IsSuccessStatusCode)
        {
            Console.WriteLine($"Message sent successfully to {tokenItem.Device_Id}");
        }
        else
        {
            var responseContent = await response.Content.ReadAsStringAsync();
            Console.WriteLine($"Error sending message to {tokenItem.Device_Id}: {responseContent}");
        }
    }
}





    }}
