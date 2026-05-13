//using System.Net.Http.Headers;
//using System.Net;
//using MilkIN_UI.Models;
//using System.Configuration;
//using System.Net.Http.Json;
//using System.Data;

//namespace MilkIN_UI.DAL
//{
//	public class RateDAL
//	{
//        private IConfigurationRoot configuration = new ConfigurationBuilder()
//            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
//            .AddJsonFile("appsettings.json")
//            .Build();



//        public string API_URL = "";
//        public string Destination_Name = "";

//        public RateDAL()
//        {
//            API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
//            Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
//        }

//        public ResAPICommonOutput GetSNFSlab(ReqSNFSlabSearch SNFSlabSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            SNFSlabSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqSNFSlabSearch>("/v1/api/admin/rate/GetSNFSlab", SNFSlabSearch);
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

//        public ResAPICommonOutput SaveSNFSlab(ReqSNFSlabSave SNFSlabSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            SNFSlabSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqSNFSlabSave>("/v1/api/admin/rate/SaveSNFSlab", SNFSlabSave);
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

//        public ResAPICommonOutput GetFatSlab(ReqFatSlabSearch FatSlabSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            FatSlabSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqFatSlabSearch>("/v1/api/admin/rate/GetFatSlab", FatSlabSearch);
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

//        public ResAPICommonOutput SaveFatSlab(ReqFatSlabSave FatSlabSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            FatSlabSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqFatSlabSave>("/v1/api/admin/rate/SaveFatSlab", FatSlabSave);
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

//        public ResAPICommonOutput GetDiesel(ReqDieselSearch DieselSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            DieselSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqDieselSearch>("/v1/api/admin/rate/GetDiesel", DieselSearch);
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

//        public ResAPICommonOutput SaveDiesel(ReqDieselSave DieselSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            DieselSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqDieselSave>("/v1/api/admin/rate/SaveDiesel", DieselSave);
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

//        public ResAPICommonOutput SaveMilk(ReqMilkSave milkSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            milkSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqMilkSave>("/v1/api/admin/rate/SaveMilk", milkSave);
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

//        public ResAPICommonOutput GetMilk(ReqMilkSearch milkSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            milkSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqMilkSearch>("/v1/api/admin/rate/GetMilk", milkSearch);
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

