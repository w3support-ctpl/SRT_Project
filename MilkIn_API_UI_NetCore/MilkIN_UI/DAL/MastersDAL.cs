//using MilkIN_UI.Models;
//using System.Net.Http.Headers;
//using System.Net;
//using System.Net.Http.Json;

//namespace MilkIN_UI.DAL
//{
//    public class MastersDAL
//    {
//        private IConfigurationRoot configuration = new ConfigurationBuilder()
//            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
//            .AddJsonFile("appsettings.json")
//            .Build();

//        public string API_URL = "";
//        public string Destination_Name = "";
//        public MastersDAL()
//        {

//            API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
//            Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
//        }


//        public ResAPICommonOutput SaveMCC(ReqMCCSave mccSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            mccSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqMCCSave>("/v1/api/admin/master/SaveMCC", mccSave);
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

//        public ResAPICommonOutput GetMCC(ReqMCCSearch mccSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            mccSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqMCCSearch>("/v1/api/admin/master/GetMCC", mccSearch);
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


//        // Transporter Save
//        public ResAPICommonOutput SaveTransporter(ReqTransporterSave transporterSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            transporterSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqTransporterSave>("/v1/api/admin/master/SaveTransporter", transporterSave);
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

//        // Transporter Get
//        public ResAPICommonOutput GetTransporter(ReqTransporterSearch transporterSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            transporterSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqTransporterSearch>("/v1/api/admin/master/GetTransporter", transporterSearch);
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

//        // Vehicle
//        public ResAPICommonOutput SaveVehicle(ReqVehicleSave vehicleSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            vehicleSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqVehicleSave>("/v1/api/admin/master/SaveVehicle", vehicleSave);
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

//        public ResAPICommonOutput GetVehicle(ReqVehicleSearch vehicleSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            vehicleSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqVehicleSearch>("/v1/api/admin/master/GetVehicle", vehicleSearch);
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

//        // Route
//        public ResAPICommonOutput SaveRoute(ReqRouteSave routeSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            routeSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqRouteSave>("/v1/api/admin/master/SaveRoute", routeSave);
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

//        // Route Get
//        public ResAPICommonOutput GetRoute(ReqRouteSearch routeSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            routeSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqRouteSearch>("/v1/api/admin/master/GetRoute", routeSearch);
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

//        // Route Item Save
//        public ResAPICommonOutput SaveRouteItem(ReqRouteItemSave routeItemSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            routeItemSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqRouteItemSave>("/v1/api/admin/master/SaveRouteItem", routeItemSave);
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

//        // Route Item Get
//        public ResAPICommonOutput GetRouteItem(ReqRouteItemSearch routeItemSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            routeItemSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqRouteItemSearch>("/v1/api/admin/master/GetRouteItem", routeItemSearch);
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

//        // Truck Sheet
//        public ResAPICommonOutput SaveTruckSheet(ReqTruckSheetSave truckSheetSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            truckSheetSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqTruckSheetSave>("/v1/api/admin/master/SaveTruckSheet", truckSheetSave);
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
//        // Truck Sheet Get
//        public ResAPICommonOutput GetTruckSheet(ReqTruckSheetSearch truckSheetSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            truckSheetSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqTruckSheetSearch>("/v1/api/admin/master/GetTruckSheet", truckSheetSearch);
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

//        // Incentive Scheme
//        public ResAPICommonOutput SaveIncentiveScheme(ReqIncentiveSchemeSave incentiveSchemeSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            incentiveSchemeSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqIncentiveSchemeSave>("/v1/api/admin/master/SaveIncentiveScheme", incentiveSchemeSave);
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

//        // Incentive Scheme Get
//        public ResAPICommonOutput GetIncentiveScheme(ReqIncentiveSchemeSearch incentiveSchemeSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            incentiveSchemeSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqIncentiveSchemeSearch>("/v1/api/admin/master/GetIncentiveScheme", incentiveSchemeSearch);
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

//        // Services Save
//        public ResAPICommonOutput SaveServices(ReqServicesSave servicesSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            servicesSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqServicesSave>("/v1/api/admin/master/SaveServices", servicesSave);
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
//        // Services Get
//        public ResAPICommonOutput GetServices(ReqServicesSearch servicesSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            servicesSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqServicesSearch>("/v1/api/admin/master/GetServices", servicesSearch);
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

//        // Material Get
//        public ResAPICommonOutput GetMaterial(ReqMaterialSearch materialSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            materialSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqMaterialSearch>("/v1/api/admin/master/GetMaterial", materialSearch);
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
//        public ResAPICommonOutput SaveRole(ReqRoleSave roleSave)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            roleSave.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqRoleSave>("/v1/api/admin/master/SaveRole", roleSave);
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

//        public ResAPICommonOutput GetRole(ReqRoleSearch roleSearch)
//        {
//            ResAPICommonOutput resOut = new ResAPICommonOutput();
//            roleSearch.destination_name = Destination_Name;
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
//                    var postTask = client.PostAsJsonAsync<ReqRoleSearch>("/v1/api/admin/master/GetRole", roleSearch);
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
