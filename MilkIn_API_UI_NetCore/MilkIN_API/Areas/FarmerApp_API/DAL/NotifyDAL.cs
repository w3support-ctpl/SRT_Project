//using Dapper;
//using Microsoft.AspNetCore.Mvc;
//using Microsoft.AspNetCore.SignalR;
//using MySql.Data.MySqlClient;
//using Newtonsoft.Json;
//using System.Collections;
//using System.Data;
//using System.Net;
//using System.Text;


//namespace MilkIN_API.Areas.FarmerApp_API.DAL
//{
//    public class NotifyDAL
//    {

//        private readonly IConfiguration configuration;

//        private IDbConnection db;

//        public NotifyDAL(string Destination, IConfiguration configuration)
//        {
//            this.configuration = configuration;
//            string ConnectionName;
//            switch (Destination)
//            {
//                case "MIP":
//                    ConnectionName = "ConnectionPRD";
//                    break;
//                case "MIU":
//                    ConnectionName = "ConnectionUAT";
//                    break;
//                default:
//                    ConnectionName = "ConnectionDEV";
//                    break;

//            }
//            db = new MySqlConnection(configuration.GetConnectionString(ConnectionName));
//        }


//        public class TokenCollections
//        {
//            public List<string> device_ids = new List<string>();
//            public Notification notification = new Notification();
//            public Data data = new Data();
//        }

//        public class Notification
//        {
//            public string title { get; set; }

//            public string body { get; set; }

//        }
//        public class Data
//        {
//            public string? msg { get; set; }
//        }


//        public int Send_FireBase_Notification()
//        {

//            List<string> Token_List = new List<string> { "dz_-esqnT2i9z0tj6ZgXDv:APA91bG6VBc09GbOJkmFCGIIc7TBRGFTBEhZJev4bUnXkYZR8NfZjwjeqoVm9OpZq5MiAhZHvmI8mYnQuQ0bX-Np4x3SCVdwv_6rGUrpBIQVlraN26aQfGRfjve9WQaJHgcp0_7JUIny" };

//            try
//            {
//                string Response = "";
               
//                if (Token_List.Count > 0)
//                {
//                    int NoOfloop = Token_List.Count() / 999;

//                    for (int i = 0; i <= NoOfloop; i++)
//                    {
//                        TokenCollections TC= new TokenCollections();

//                        TC.device_ids = Token_List;
//                        TC.device_ids = Token_List.Skip(i * 999).Take(999).ToList();

//                        Notification notifination_header = new Notification();
//                        notifination_header.title = "Notification";
//                        notifination_header.body = "Notification_Text";

//                        Data notification_data = new Data();
//                        notification_data.msg = "mssssggg";

//                        TC.data = notification_data;
//                        TC.notification = notifination_header;

//                        var Test = JsonConvert.SerializeObject(TC);

//                        WebRequest request = WebRequest.Create("https://fcm.googleapis.com/fcm/send");

//                        request.Method = "POST";

//                        byte[] byteArray = Encoding.UTF8.GetBytes(Test);

//                        request.ContentType = "application/json";
//                        request.ContentLength = byteArray.Length;
//                        request.Headers.Add("Authorization", "key=AAAAXdj8ZpA:APA91bE5ED8jzxlvorbA5g2BfLiB_apf3YkT0YLpShN9qrpHekklz9kr6jtl3l1SBm89rvNbUZicIpuYjZETwq3hfzPssM8g3w9XQvl0NsyWP_y-r2hmvL9-XEtKmvAzSLHBIdepaVJp");


//                        Stream dataStream = request.GetRequestStream();
//                        dataStream.Write(byteArray, 0, byteArray.Length);
//                        dataStream.Close();

//                        using (WebResponse response = request.GetResponse())
//                        using (StreamReader stream = new StreamReader(response.GetResponseStream()))
//                        {
//                            Response = stream.ReadToEnd();
//                        }
//                    }
//                }

//               // Send_SignalR_Notification( Notification_Text, Notification_Type);

//                return 1;

//            }
//            catch (Exception ex)
//            {
//                return -1;
//            }

//        }


//        //public int Send_SignalR_Notification(string Notification_Text, string Notification_Type)
//        //{
//        //    _hubContext.Clients.All.SendAsync(Notification_Text, Notification_Type);

//        //    return 1;
//        //}


//    }
//}
