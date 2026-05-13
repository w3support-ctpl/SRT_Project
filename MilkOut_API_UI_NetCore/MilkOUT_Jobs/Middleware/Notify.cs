using Microsoft.Extensions.Configuration;
using MilkOUT_Jobs.DAL;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using System.Collections;
using System.Data;
using System.Net;
using System.Text;


namespace MilkOUT_API.Middleware
{
    public class Notify
    {

        private readonly IConfiguration configuration;

        private IDbConnection db;


        public Notify(string Destination)
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


        public class Parameters
        {
            public string Method_Name { get; set; }
            public string Org_Id { get; set; }
            public string Profile_Id { get; set; }
            public string User_Type { get; set; }
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
                string res_Str = new JobCommonDAL(destination_name).RunDBQuery(inputParam, "USP_SDeviceToken_Get");

                dynamic Response = JsonConvert.DeserializeObject(res_Str.ToString());

                var Token_List = Response.ToObject<List<dynamic>>();


                Send_FireBase_Notification(Token_List);

                return 1;

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;


                return 1;
            }

        }

        public int Send_FireBase_Notification(List<dynamic> Token_List)
        {
            ArrayList Response_Array = new ArrayList();

            try
            {
                string Response = "";

                List<string> GCMTokens = new List<string>();
                for (int i = 0; i < Token_List.Count; i++)
                {
                    GCMTokens.Add(Token_List[i].Device_Id.ToString() + "");
                }

                if (GCMTokens.Count > 0)
                {
                    int NoOfloop = GCMTokens.Count() / 999;

                    for (int i = 0; i <= NoOfloop; i++)
                    {
                        GCMTokenCollections GTC = new GCMTokenCollections();

                        GTC.registration_ids = GCMTokens;
                        GTC.registration_ids = GCMTokens.Skip(i * 999).Take(999).ToList();

                        Notification d = new Notification();
                        d.title = Token_List[i].Notification_Title.ToString();
                        d.body = Token_List[i].Notification_Text.ToString();

                        Data dt = new Data();
                        dt.Type = "Notification";

                        GTC.data = dt;
                        GTC.notification = d;

                        var Test = JsonConvert.SerializeObject(GTC);

                        WebRequest request = WebRequest.Create("https://fcm.googleapis.com/fcm/send");

                        request.Method = "POST";

                        byte[] byteArray = Encoding.UTF8.GetBytes(Test);

                        request.ContentType = "application/json";
                        request.ContentLength = byteArray.Length;
                        request.Headers.Add("Authorization", "key=AAAA_0C0c2s:APA91bGDTIrg-K3LqLRZNnUn-hCYqMT48ovNCsbLrp1w3OYYac292VXhGC4tHug2LH2cTTQxaNYVlE2x1cvjKX042iX-rGHVpPW95WMJfxs6Upb1azktek8iATRo2yLS63XmAznUvOrq");


                        Stream dataStream = request.GetRequestStream();
                        dataStream.Write(byteArray, 0, byteArray.Length);
                        dataStream.Close();

                        using (WebResponse response = request.GetResponse())
                        using (StreamReader stream = new StreamReader(response.GetResponseStream()))
                        {
                            Response = stream.ReadToEnd();
                        }
                    }
                }

                return 1;

            }
            catch (Exception ex)
            {
                return -1;
            }

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




    }



}
