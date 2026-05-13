//using System.Net.Http.Headers;
//using System.Net;
//using MilkIN_UI.Models;
//using System.Configuration;
//using System.Net.Http.Json;
//using System.Collections.Generic;

//namespace MilkIN_UI.DAL
//{
//    public class ApprovalsDAL
//    {
//        private IConfigurationRoot configuration = new ConfigurationBuilder()
//            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
//            .AddJsonFile("appsettings.json")
//            .Build();

//        public string API_URL = "";
//        public string Destination_Name = "";

//        public ApprovalsDAL()
//        {

//            API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
//            Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
//        }

//        public ResAPICommonOutput GetFarmerRegistration(ReqFarmerRegistrationSearch farmerregistrationSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            farmerregistrationSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqFarmerRegistrationSearch>("/v1/api/admin/approvals/GetFarmerRegistration", farmerregistrationSearch);
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

//        public ResAPICommonOutput SaveFarmerRegistration(ReqFarmerRegistrationSave farmerregistrationSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            farmerregistrationSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqFarmerRegistrationSave>("/v1/api/admin/approvals/SaveFarmerRegistration", farmerregistrationSave);
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


//        public ResAPICommonOutput GetFarmerService(ReqFarmerServiceSearch farmerserviceSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            farmerserviceSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqFarmerServiceSearch>("/v1/api/admin/approvals/GetFarmerService", farmerserviceSearch);
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

//        public ResAPICommonOutput SaveFarmerService(ReqFarmerServiceSave farmerserviceSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            farmerserviceSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqFarmerServiceSave>("/v1/api/admin/approvals/SaveFarmerService", farmerserviceSave);
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
