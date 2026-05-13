using MilkOUT_UI.Models;
using System.Net.Http.Headers;
using System.Net;
using System.Net.Http.Json;

namespace MilkOUT_UI.DAL
{
    public class MastersDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        public string API_URL = "";
        public string Destination_Name = "";
        public MastersDAL()
        {

            API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
            Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
        }

        //public ResAPICommonOutput SaveRetailer(ReqRetailerSave retailerSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    retailerSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqRetailerSave>("/v1/api/admin/master/SaveRetailer", retailerSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {
        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}

        //public ResAPICommonOutput GetRetailer(ReqRetailerSearch retailerSearch)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    retailerSearch.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqRetailerSearch>("/v1/api/admin/master/GetRetailer", retailerSearch);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}
        //public ResAPICommonOutput MCCSave(ReqMCCSave mccSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    mccSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqMCCSave>("/v1/api/admin/master/MCCSave", mccSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}

        //public ResAPICommonOutput MCCGet(ReqMCCGet mccGet)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    mccGet.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqMCCGet>("/v1/api/admin/master/MCCGet", mccGet);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}


        // Transporter
        //public ResAPICommonOutput TransporterSave(ReqTransporterSave transporterSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    transporterSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqTransporterSave>("/v1/api/admin/masters/TransporterSave", transporterSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}

        ////public ResAPICommonOutput GetSalesArea(ReqSalesAreaSearch salesareaSearch)
        ////{
        ////    ResAPICommonOutput resOut = new ResAPICommonOutput();
        ////    salesareaSearch.destination_name = Destination_Name;
        ////    try
        ////    {
        ////        using (var client = new HttpClient())
        ////        {
        ////            //Passing service base BaserURL
        ////            client.BaseAddress = new Uri(API_URL);
        ////            client.DefaultRequestHeaders.Clear();

        ////            //Define request data format
        ////            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        ////            //HTTP POST
        ////            var postTask = client.PostAsJsonAsync<ReqSalesAreaSearch>("/v1/api/admin/master/GetSalesArea", salesareaSearch);
        ////            postTask.Wait();

        ////            var result = postTask.Result;
        ////            if (result.IsSuccessStatusCode)
        ////            {

        ////                //Storing the response details recieved from web api
        ////                var response = result.Content.ReadAsStringAsync().Result;
        ////                resOut.ResponseCode = HttpStatusCode.OK;
        ////                resOut.ResponseMessage = "";
        ////                resOut.ResponseData = response;
        ////                return resOut;
        ////            }
        ////            else
        ////            {
        ////                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        ////                resOut.ResponseMessage = "Something went wrong";
        ////                resOut.ResponseData = "";
        ////                return resOut;

        ////            }


        ////        }
        ////    }
        ////    catch (Exception ex)
        ////    {

        ////        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        ////        resOut.ResponseMessage = ex.Message;
        ////        resOut.ResponseData = "";
        ////        return resOut;

        ////    }
        ////}
        ////// SaveSalesArea
        ////public ResAPICommonOutput SaveSalesArea(ReqSalesAreaSave salesAreaSave)
        ////{
        ////    ResAPICommonOutput resOut = new ResAPICommonOutput();
        ////    salesAreaSave.destination_name = Destination_Name;
        ////    try
        ////    {
        ////        using (var client = new HttpClient())
        ////        {
        ////            //Passing service base BaserURL
        ////            client.BaseAddress = new Uri(API_URL);
        ////            client.DefaultRequestHeaders.Clear();

        ////            //Define request data format
        ////            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        ////            //HTTP POST
        ////            var postTask = client.PostAsJsonAsync<ReqSalesAreaSave>("/v1/api/admin/master/SaveSalesArea", salesAreaSave);
        ////            postTask.Wait();

        ////            var result = postTask.Result;
        ////            if (result.IsSuccessStatusCode)
        ////            {
        ////                //Storing the response details recieved from web api
        ////                var response = result.Content.ReadAsStringAsync().Result;
        ////                resOut.ResponseCode = HttpStatusCode.OK;
        ////                resOut.ResponseMessage = "";
        ////                resOut.ResponseData = response;
        ////                return resOut;
        ////            }
        ////            else
        ////            {
        ////                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        ////                resOut.ResponseMessage = "Something went wrong";
        ////                resOut.ResponseData = "";
        ////                return resOut;

        ////            }


        ////        }
        ////    }
        ////    catch (Exception ex)
        ////    {

        ////        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        ////        resOut.ResponseMessage = ex.Message;
        ////        resOut.ResponseData = "";
        ////        return resOut;

        ////    }
        ////}

        //public ResAPICommonOutput RouteSave(ReqRouteSave routeSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    routeSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqRouteSave>("/v1/api/admin/masters/RouteSave", routeSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}


        //// Truck Sheet
        //public ResAPICommonOutput TruckSheetSave(ReqTruckSheetSave truckSheetSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    truckSheetSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqTruckSheetSave>("/v1/api/admin/masters/TruckSheetSave", truckSheetSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}

        //// Incentive Scheme
        //public ResAPICommonOutput IncentiveSchemeSave(ReqIncentiveSchemeSave incentiveSchemeSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    incentiveSchemeSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqIncentiveSchemeSave>("/v1/api/admin/masters/IncentiveSchemeSave", incentiveSchemeSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}

        //// Services Scheme
        //public ResAPICommonOutput ServicesSave(ReqServicesSave servicesSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    servicesSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqServicesSave>("/v1/api/admin/masters/ServicesSave", servicesSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}

        // Dealer

        //public ResAPICommonOutput SaveDealer(ReqDealerSave dealerSave)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    dealerSave.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqDealerSave>("/v1/api/admin/master/SaveDealer", dealerSave);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {
        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}

        //public ResAPICommonOutput GetDealer(ReqDealerSearch dealerSearch)
        //{
        //    ResAPICommonOutput resOut = new ResAPICommonOutput();
        //    dealerSearch.destination_name = Destination_Name;
        //    try
        //    {
        //        using (var client = new HttpClient())
        //        {
        //            //Passing service base BaserURL
        //            client.BaseAddress = new Uri(API_URL);
        //            client.DefaultRequestHeaders.Clear();

        //            //Define request data format
        //            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        //            //HTTP POST
        //            var postTask = client.PostAsJsonAsync<ReqDealerSearch>("/v1/api/admin/master/GetDealer", dealerSearch);
        //            postTask.Wait();

        //            var result = postTask.Result;
        //            if (result.IsSuccessStatusCode)
        //            {

        //                //Storing the response details recieved from web api
        //                var response = result.Content.ReadAsStringAsync().Result;
        //                resOut.ResponseCode = HttpStatusCode.OK;
        //                resOut.ResponseMessage = "";
        //                resOut.ResponseData = response;
        //                return resOut;
        //            }
        //            else
        //            {
        //                resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //                resOut.ResponseMessage = "Something went wrong";
        //                resOut.ResponseData = "";
        //                return resOut;

        //            }


        //        }
        //    }
        //    catch (Exception ex)
        //    {

        //        resOut.ResponseCode = HttpStatusCode.InternalServerError;
        //        resOut.ResponseMessage = ex.Message;
        //        resOut.ResponseData = "";
        //        return resOut;

        //    }
        //}




    }
}
