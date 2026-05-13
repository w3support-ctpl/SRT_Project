using System.Net;
using System.Net.Http.Headers;
using System.Text;

namespace MilkIN_UI.DAL
{
	public class CommonDAL
	{
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();



        public string API_URL = "";
        public string Destination_Name = "";
        public CommonDAL()
        {

            API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
            Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
        }

        public string CallAPI(string APIEndPoint, string ReqObjStr)
        {
            //ReqObjStr.destination_name = Destination_Name;
            try
            {
                string BaseURL = API_URL;
                if (BaseURL == null || BaseURL == "")
                {
                    return "{\"responseCode\":500,\"responseMessage\":\"Error\",\"responseData\":\"BaseURL not found\"}";
                }

                if (APIEndPoint == null || APIEndPoint == "")
                {
                    return "{\"responseCode\":500,\"responseMessage\":\"Error\",\"responseData\":\"APIEndPoint not found\"}";
                }

                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(12000);
                    
                    //Passing service base BaserURL
                    client.BaseAddress = new Uri(BaseURL);
                    client.DefaultRequestHeaders.Clear();

                    //Define request data format
                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                    //HTTP POST
                    var postData = new StringContent(ReqObjStr, Encoding.UTF8, "application/json");
                    var postTask = client.PostAsync(APIEndPoint, postData);
                    postTask.Wait();

                    var result = postTask.Result;
                    if (result.IsSuccessStatusCode)
                    {
                        var response = result.Content.ReadAsStringAsync().Result;
                        return response;
                    }
                    else
                    {
                        return "{\"responseCode\":400,\"responseMessage\":\"Error\",\"responseData\":\"Something went wrong\"}";
                    }
                }
            }
            catch (Exception ex)
            {
                return "{\"responseCode\":500,\"responseMessage\":\"Error\",\"responseData\":\"" + ex.Message + "\"}";
            }
        }

    }
}
