using System.Net.Http.Headers;
using System.Net;
using MilkOUT_UI.Models;
using System.Text.Json;

namespace MilkOUT_UI.DAL
{
	public class HomeDAL
	{
		private IConfigurationRoot configuration = new ConfigurationBuilder()
			.SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
			.AddJsonFile("appsettings.json")
			.Build();

		public string API_URL = "";
		public string Destination_Name = "";

		public HomeDAL()
		{

			API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
			Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
		}

		public List<MasterDetails> GetMasterData(ReqMasterData masterData)
		{
			List<MasterDetails> resOut = new List<MasterDetails>();
			masterData.destination_name = Destination_Name;
			try
			{
				using (var client = new HttpClient())
				{
					//Passing service base BaserURL
					client.BaseAddress = new Uri(API_URL);
					client.DefaultRequestHeaders.Clear();

					//Define request data format
					client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

					//HTTP POST
					var postTask = client.PostAsJsonAsync<ReqMasterData>("/v1/api/admin/home/GetMasterData", masterData);
					postTask.Wait();

					var result = postTask.Result;
					if (result.IsSuccessStatusCode)
					{
						//Storing the response details recieved from web api
						var response = result.Content.ReadAsStringAsync().Result;
						resOut = JsonSerializer.Deserialize<List<MasterDetails>>(response);
						return resOut;
					}
					else
					{
						return resOut;
					}


				}
			}
			catch (Exception ex)
			{
				return resOut;
			}
		}

		public List<MasterDetails> GetMastersData(ReqMasterData masterData)
		{
			List<MasterDetails> resOut = new List<MasterDetails>();
			masterData.destination_name = Destination_Name;
			try
			{
				using (var client = new HttpClient())
				{
					//Passing service base BaserURL
					client.BaseAddress = new Uri(API_URL);
					client.DefaultRequestHeaders.Clear();

					//Define request data format
					client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

					//HTTP POST
					var postTask = client.PostAsJsonAsync<ReqMasterData>("/v1/api/admin/home/GetMastersData", masterData);
					postTask.Wait();

					var result = postTask.Result;
					if (result.IsSuccessStatusCode)
					{
						//Storing the response details recieved from web api
						var response = result.Content.ReadAsStringAsync().Result;
						resOut = JsonSerializer.Deserialize<List<MasterDetails>>(response);
						return resOut;
					}
					else
					{
						return resOut;
					}


				}
			}
			catch (Exception ex)
			{
				return resOut;
			}
		}
	}
}
