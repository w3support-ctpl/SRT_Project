using System.Net.Http.Headers;
using System.Net;
using MilkOUT_UI.Models;
using System.Configuration;
using System.Net.Http.Json;

namespace MilkOUT_UI.DAL
{
    public class UsersDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        public string API_URL = "";
        public string Destination_Name = "";
        public UsersDAL()
        {

            API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
            Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
        }


        public ResAPICommonOutput SaveFarmer(ReqFarmerSave farmerSave)
        {
            ResAPICommonOutput resOut = new ResAPICommonOutput();
            farmerSave.destination_name = Destination_Name;
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
                    var postTask = client.PostAsJsonAsync<ReqFarmerSave>("/v1/api/admin/users/SaveFarmer", farmerSave);
                    postTask.Wait();

                    var result = postTask.Result;
                    if (result.IsSuccessStatusCode)
                    {

                        //Storing the response details recieved from web api
                        var response = result.Content.ReadAsStringAsync().Result;
                        resOut.ResponseCode = HttpStatusCode.OK;
                        resOut.ResponseMessage = "";
                        resOut.ResponseData = response;
                        return resOut;
                    }
                    else
                    {
                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
                        resOut.ResponseMessage = "Something went wrong";
                        resOut.ResponseData = "";
                        return resOut;

                    }


                }
            }
            catch (Exception ex)
            {

                resOut.ResponseCode = HttpStatusCode.InternalServerError;
                resOut.ResponseMessage = ex.Message;
                resOut.ResponseData = "";
                return resOut;

            }
        }

        public ResAPICommonOutput SaveAgent(ReqAgentSave agentSave)
        {
            ResAPICommonOutput resOut = new ResAPICommonOutput();
            agentSave.destination_name = Destination_Name;
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
                    var postTask = client.PostAsJsonAsync<ReqAgentSave>("/v1/api/admin/users/SaveFarmer", agentSave);
                    postTask.Wait();

                    var result = postTask.Result;
                    if (result.IsSuccessStatusCode)
                    {

                        //Storing the response details recieved from web api
                        var response = result.Content.ReadAsStringAsync().Result;
                        resOut.ResponseCode = HttpStatusCode.OK;
                        resOut.ResponseMessage = "";
                        resOut.ResponseData = response;
                        return resOut;
                    }
                    else
                    {
                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
                        resOut.ResponseMessage = "Something went wrong";
                        resOut.ResponseData = "";
                        return resOut;

                    }


                }
            }
            catch (Exception ex)
            {

                resOut.ResponseCode = HttpStatusCode.InternalServerError;
                resOut.ResponseMessage = ex.Message;
                resOut.ResponseData = "";
                return resOut;

            }
        }

        public ResAPICommonOutput SaveDriver(ReqDriverSave driverSave)
        {
            ResAPICommonOutput resOut = new ResAPICommonOutput();
            driverSave.destination_name = Destination_Name;
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
                    var postTask = client.PostAsJsonAsync<ReqDriverSave>("/v1/api/admin/users/SaveDriver", driverSave);
                    postTask.Wait();

                    var result = postTask.Result;
                    if (result.IsSuccessStatusCode)
                    {

                        //Storing the response details recieved from web api
                        var response = result.Content.ReadAsStringAsync().Result;
                        resOut.ResponseCode = HttpStatusCode.OK;
                        resOut.ResponseMessage = "";
                        resOut.ResponseData = response;
                        return resOut;
                    }
                    else
                    {
                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
                        resOut.ResponseMessage = "Something went wrong";
                        resOut.ResponseData = "";
                        return resOut;

                    }


                }
            }
            catch (Exception ex)
            {

                resOut.ResponseCode = HttpStatusCode.InternalServerError;
                resOut.ResponseMessage = ex.Message;
                resOut.ResponseData = "";
                return resOut;

            }
        }

        public ResAPICommonOutput SaveChemist(ReqChemistSave chemistSave)
        {
            ResAPICommonOutput resOut = new ResAPICommonOutput();
            chemistSave.destination_name = Destination_Name;
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
                    var postTask = client.PostAsJsonAsync<ReqChemistSave>("/v1/api/admin/users/SaveChemist", chemistSave);
                    postTask.Wait();

                    var result = postTask.Result;
                    if (result.IsSuccessStatusCode)
                    {

                        //Storing the response details recieved from web api
                        var response = result.Content.ReadAsStringAsync().Result;
                        resOut.ResponseCode = HttpStatusCode.OK;
                        resOut.ResponseMessage = "";
                        resOut.ResponseData = response;
                        return resOut;
                    }
                    else
                    {
                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
                        resOut.ResponseMessage = "Something went wrong";
                        resOut.ResponseData = "";
                        return resOut;

                    }


                }
            }
            catch (Exception ex)
            {

                resOut.ResponseCode = HttpStatusCode.InternalServerError;
                resOut.ResponseMessage = ex.Message;
                resOut.ResponseData = "";
                return resOut;

            }
        }

        public ResAPICommonOutput GetOfficeUser(ReqUserSearch userSearch)
        {
            ResAPICommonOutput resOut = new ResAPICommonOutput();
            userSearch.destination_name = Destination_Name;
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
                    var postTask = client.PostAsJsonAsync<ReqUserSearch>("/v1/api/admin/users/GetOfficeUser", userSearch);
                    postTask.Wait();

                    var result = postTask.Result;
                    if (result.IsSuccessStatusCode)
                    {

                        //Storing the response details recieved from web api
                        var response = result.Content.ReadAsStringAsync().Result;
                        resOut.ResponseCode = HttpStatusCode.OK;
                        resOut.ResponseMessage = "";
                        resOut.ResponseData = response;
                        return resOut;
                    }
                    else
                    {
                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
                        resOut.ResponseMessage = "Something went wrong";
                        resOut.ResponseData = "";
                        return resOut;

                    }


                }
            }
            catch (Exception ex)
            {

                resOut.ResponseCode = HttpStatusCode.InternalServerError;
                resOut.ResponseMessage = ex.Message;
                resOut.ResponseData = "";
                return resOut;

            }
        }

        public ResAPICommonOutput SaveUser(ReqUserSave userSave)
        {
            ResAPICommonOutput resOut = new ResAPICommonOutput();
            userSave.destination_name = Destination_Name;
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
                    var postTask = client.PostAsJsonAsync<ReqUserSave>("/v1/api/admin/users/SaveUser", userSave);
                    postTask.Wait();

                    var result = postTask.Result;
                    if (result.IsSuccessStatusCode)
                    {

                        //Storing the response details recieved from web api
                        var response = result.Content.ReadAsStringAsync().Result;
                        resOut.ResponseCode = HttpStatusCode.OK;
                        resOut.ResponseMessage = "";
                        resOut.ResponseData = response;
                        return resOut;
                    }
                    else
                    {
                        resOut.ResponseCode = HttpStatusCode.InternalServerError;
                        resOut.ResponseMessage = "Something went wrong";
                        resOut.ResponseData = "";
                        return resOut;

                    }


                }
            }
            catch (Exception ex)
            {

                resOut.ResponseCode = HttpStatusCode.InternalServerError;
                resOut.ResponseMessage = ex.Message;
                resOut.ResponseData = "";
                return resOut;

            }
        }
    }
}
