//using System.Net.Http.Headers;
//using System.Net;
//using MilkIN_UI.Models;
//using System.Configuration;
//using System.Net.Http.Json;
//using System.Data;


//namespace MilkIN_UI.DAL
//{
//	public class LocationDAL
//	{
//		private IConfigurationRoot configuration = new ConfigurationBuilder()
//			.SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
//			.AddJsonFile("appsettings.json")
//			.Build();

       

//        public string API_URL = "";
//		public string Destination_Name = "";
//		public LocationDAL()
//		{

//			API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
//			Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
//		}

//        public ResAPICommonOutput GetState(ReqStateSearch stateSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            stateSearch.destination_name = Destination_Name;
//            try
//            {
//                using (var client = new HttpClient())
//                {
//                    //Passing service base BaserURL
//                    client.BaseAddress = new Uri(API_URL);
//                    client.DefaultRequestHeaders.Clear();

//                    //Define request data format
//                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


//                    //HTTP POST
//                    var postTask = client.PostAsJsonAsync<ReqStateSearch>("/v1/api/admin/location/GetState", stateSearch);
//                    postTask.Wait();

//                    var result = postTask.Result;
//                    if (result.IsSuccessStatusCode)
//                    {

//                        //Storing the response details recieved from web api
//                        var response = result.Content.ReadAsStringAsync().Result;
//                        resOut.ResponseCode = HttpStatusCode.OK;
//                        resOut.ResponseMessage = "";
//                        resOut.ResponseData = response;
//                        return resOut;
//                    }
//                    else
//                    {
//                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                        resOut.ResponseMessage = "Something went wrong";
//                        resOut.ResponseData = "";
//                        return resOut;

//                    }

//                }
//            }
//            catch (Exception ex)
//            {

//                resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                resOut.ResponseMessage = ex.Message;
//                resOut.ResponseData = "";
//                return resOut;

//            }
//        }

//        public ResAPICommonOutput GetDistrict(ReqDistrictSearch districtSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            districtSearch.destination_name = Destination_Name;
//            try
//            {
//                using (var client = new HttpClient())
//                {
//                    //Passing service base BaserURL
//                    client.BaseAddress = new Uri(API_URL);
//                    client.DefaultRequestHeaders.Clear();

//                    //Define request data format
//                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


//                    //HTTP POST
//                    var postTask = client.PostAsJsonAsync<ReqDistrictSearch>("/v1/api/admin/location/GetDistrict", districtSearch);
//                    postTask.Wait();

//                    var result = postTask.Result;
//                    if (result.IsSuccessStatusCode)
//                    {

//                        //Storing the response details recieved from web api
//                        var response = result.Content.ReadAsStringAsync().Result;
//                        resOut.ResponseCode = HttpStatusCode.OK;
//                        resOut.ResponseMessage = "";
//                        resOut.ResponseData = response;
//                        return resOut;
//                    }
//                    else
//                    {
//                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                        resOut.ResponseMessage = "Something went wrong";
//                        resOut.ResponseData = "";
//                        return resOut;

//                    }

//                }
//            }
//            catch (Exception ex)
//            {

//                resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                resOut.ResponseMessage = ex.Message;
//                resOut.ResponseData = "";
//                return resOut;

//            }
//        }
//        public ResAPICommonOutput SaveDistrict(ReqDistrictSave districtSave)
//		{
//			ResAPICommonOutput resOut = new ResAPICommonOutput();
//			districtSave.destination_name = Destination_Name;
//			try
//			{
//				using (var client = new HttpClient())
//				{
//					//Passing service base BaserURL
//					client.BaseAddress = new Uri(API_URL);
//					client.DefaultRequestHeaders.Clear();

//					//Define request data format
//					client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

//					//HTTP POST
//					var postTask = client.PostAsJsonAsync<ReqDistrictSave>("/v1/api/admin/location/SaveDistrict", districtSave);
//					postTask.Wait();

//					var result = postTask.Result;
//					if (result.IsSuccessStatusCode)
//					{

//						//Storing the response details recieved from web api
//						var response = result.Content.ReadAsStringAsync().Result;
//						resOut.ResponseCode = HttpStatusCode.OK;
//						resOut.ResponseMessage = "";
//						resOut.ResponseData = response;
//						return resOut;
//					}
//					else
//					{
//						resOut.ResponseCode = HttpStatusCode.InternalServerError;
//						resOut.ResponseMessage = "Something went wrong";
//						resOut.ResponseData = "";
//						return resOut;

//					}


//				}
//			}
//			catch (Exception ex)
//			{

//				resOut.ResponseCode = HttpStatusCode.InternalServerError;
//				resOut.ResponseMessage = ex.Message;
//				resOut.ResponseData = "";
//				return resOut;

//			}
//		}

//        public ResAPICommonOutput GetTaluka(ReqTalukaSearch talukaSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            talukaSearch.destination_name = Destination_Name;
//            try
//            {
//                using (var client = new HttpClient())
//                {
//                    //Passing service base BaserURL
//                    client.BaseAddress = new Uri(API_URL);
//                    client.DefaultRequestHeaders.Clear();

//                    //Define request data format
//                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


//                    //HTTP POST
//                    var postTask = client.PostAsJsonAsync<ReqTalukaSearch>("/v1/api/admin/location/GetTaluka", talukaSearch);
//                    postTask.Wait();

//                    var result = postTask.Result;
//                    if (result.IsSuccessStatusCode)
//                    {

//                        //Storing the response details recieved from web api
//                        var response = result.Content.ReadAsStringAsync().Result;
//                        resOut.ResponseCode = HttpStatusCode.OK;
//                        resOut.ResponseMessage = "";
//                        resOut.ResponseData = response;
//                        return resOut;
//                    }
//                    else
//                    {
//                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                        resOut.ResponseMessage = "Something went wrong";
//                        resOut.ResponseData = "";
//                        return resOut;

//                    }

//                }
//            }
//            catch (Exception ex)
//            {

//                resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                resOut.ResponseMessage = ex.Message;
//                resOut.ResponseData = "";
//                return resOut;

//            }
//        }
//        public ResAPICommonOutput SaveTaluka(ReqTalukaSave talukaSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            talukaSave.destination_name = Destination_Name;
//            try
//            {
//                using (var client = new HttpClient())
//                {
//                    //Passing service base BaserURL
//                    client.BaseAddress = new Uri(API_URL);
//                    client.DefaultRequestHeaders.Clear();

//                    //Define request data format
//                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

//                    //HTTP POST
//                    var postTask = client.PostAsJsonAsync<ReqTalukaSave>("/v1/api/admin/location/SaveTaluka", talukaSave);
//                    postTask.Wait();

//                    var result = postTask.Result;
//                    if (result.IsSuccessStatusCode)
//                    {

//                        //Storing the response details recieved from web api
//                        var response = result.Content.ReadAsStringAsync().Result;
//                        resOut.ResponseCode = HttpStatusCode.OK;
//                        resOut.ResponseMessage = "";
//                        resOut.ResponseData = response;
//                        return resOut;
//                    }
//                    else
//                    {
//                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                        resOut.ResponseMessage = "Something went wrong";
//                        resOut.ResponseData = "";
//                        return resOut;

//                    }


//                }
//            }
//            catch (Exception ex)
//            {

//                resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                resOut.ResponseMessage = ex.Message;
//                resOut.ResponseData = "";
//                return resOut;

//            }
//        }

//        public ResAPICommonOutput GetVillage(ReqVillageSearch villageSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            villageSearch.destination_name = Destination_Name;
//            try
//            {
//                using (var client = new HttpClient())
//                {
//                    //Passing service base BaserURL
//                    client.BaseAddress = new Uri(API_URL);
//                    client.DefaultRequestHeaders.Clear();

//                    //Define request data format
//                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


//                    //HTTP POST
//                    var postTask = client.PostAsJsonAsync<ReqVillageSearch>("/v1/api/admin/location/GetVillage", villageSearch);
//                    postTask.Wait();

//                    var result = postTask.Result;
//                    if (result.IsSuccessStatusCode)
//                    {

//                        //Storing the response details recieved from web api
//                        var response = result.Content.ReadAsStringAsync().Result;
//                        resOut.ResponseCode = HttpStatusCode.OK;
//                        resOut.ResponseMessage = "";
//                        resOut.ResponseData = response;
//                        return resOut;
//                    }
//                    else
//                    {
//                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                        resOut.ResponseMessage = "Something went wrong";
//                        resOut.ResponseData = "";
//                        return resOut;

//                    }

//                }
//            }
//            catch (Exception ex)
//            {

//                resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                resOut.ResponseMessage = ex.Message;
//                resOut.ResponseData = "";
//                return resOut;

//            }
//        }

//        public ResAPICommonOutput SaveVillage(ReqVillageSave villageSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            villageSave.destination_name = Destination_Name;
//            try
//            {
//                using (var client = new HttpClient())
//                {
//                    //Passing service base BaserURL
//                    client.BaseAddress = new Uri(API_URL);
//                    client.DefaultRequestHeaders.Clear();

//                    //Define request data format
//                    client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

//                    //HTTP POST
//                    var postTask = client.PostAsJsonAsync<ReqVillageSave>("/v1/api/admin/location/SaveVillage", villageSave);
//                    postTask.Wait();

//                    var result = postTask.Result;
//                    if (result.IsSuccessStatusCode)
//                    {

//                        //Storing the response details recieved from web api
//                        var response = result.Content.ReadAsStringAsync().Result;
//                        resOut.ResponseCode = HttpStatusCode.OK;
//                        resOut.ResponseMessage = "";
//                        resOut.ResponseData = response;
//                        return resOut;
//                    }
//                    else
//                    {
//                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                        resOut.ResponseMessage = "Something went wrong";
//                        resOut.ResponseData = "";
//                        return resOut;

//                    }


//                }
//            }
//            catch (Exception ex)
//            {

//                resOut.ResponseCode = HttpStatusCode.InternalServerError;
//                resOut.ResponseMessage = ex.Message;
//                resOut.ResponseData = "";
//                return resOut;

//            }
//        }
//    }
//}
