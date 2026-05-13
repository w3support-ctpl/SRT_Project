using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/transporter/")]
    [ApiController]
    public class TransporterController : Controller
    {
        private readonly ILogger<TransporterController> _logger;
        public TransporterController(ILogger<TransporterController> logger)
        {
            _logger = logger;
        }

        [HttpPost("GetRoute", Name = "GetRoute")]
        public IActionResult GetRoute(ReqRoute routeSearch)
        {
            try
            {
                if (routeSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRoute> res_Obj = new List<ResRoute>();
                string destination_name = routeSearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetRoute(routeSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {



                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(routeSearch.destination_name).ApiLog("Create", routeSearch.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(routeSearch), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("SaveRoute", Name = "SaveRoute")]
        public IActionResult SaveRoute(ReqRoute routeSave)
        {
            try
            {
                if (routeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = routeSave.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).SaveRoute(routeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(routeSave.destination_name).ApiLog("Create", routeSave.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(routeSave), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("GetRouteItem", Name = "GetRouteItem")]
        public IActionResult GetRouteItem(ReqRouteItem routeItemSearch)
        {
            try
            {
                if (routeItemSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRouteItem> res_Obj = new List<ResRouteItem>();
                string destination_name = routeItemSearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetRouteItem(routeItemSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(routeItemSearch.destination_name).ApiLog("Create", routeItemSearch.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(routeItemSearch), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("SaveRouteItem", Name = "SaveRouteItem")]
        public IActionResult SaveRouteItem(ReqRouteItem routeItemSave)
        {
            try
            {
                if (routeItemSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = routeItemSave.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).SaveRouteItem(routeItemSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(routeItemSave.destination_name).ApiLog("Create", routeItemSave.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(routeItemSave), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }


        [HttpPost("GetVehicleSheet", Name = "GetVehicleSheet")]
        public IActionResult GetVehicleSheet(ReqVehicleSheet vehicleSheetSearch)
        {
            try
            {
                if (vehicleSheetSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResVehicleSheet> res_Obj = new List<ResVehicleSheet>();
                string destination_name = vehicleSheetSearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetVehicleSheet(vehicleSheetSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(vehicleSheetSearch.destination_name).ApiLog("Create", vehicleSheetSearch.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(vehicleSheetSearch), "500", e.Message);


                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("SaveVehicleSheet", Name = "SaveVehicleSheet")]
        public IActionResult SaveVehicleSheet(ReqVehicleSheet vehicleSheetSave)
        {
            try
            {
                if (vehicleSheetSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = vehicleSheetSave.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).SaveVehicleSheet(vehicleSheetSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(vehicleSheetSave.destination_name).ApiLog("Create", vehicleSheetSave.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(vehicleSheetSave), "500", e.Message);


                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("GetManageTrip", Name = "GetManageTrip")]
        public IActionResult GetManageTrip(ReqManageTrip manageTripSearch)
        {
            try
            {
                if (manageTripSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResManageTrip> res_Obj = new List<ResManageTrip>();
                string destination_name = manageTripSearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetManageTrip(manageTripSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(manageTripSearch.destination_name).ApiLog("Create", manageTripSearch.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(manageTripSearch), "500", e.Message);


                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("GetSetManageTrip", Name = "GetSetManageTrip")]
        public IActionResult GetSetManageTrip(ReqManageTrip manageTripSearch)
        {
            try
            {
                if (manageTripSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResManageTrip> res_Obj = new List<ResManageTrip>();
                string destination_name = manageTripSearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetSetManageTrip(manageTripSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(manageTripSearch.destination_name).ApiLog("Create", manageTripSearch.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(manageTripSearch), "500", e.Message);


                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("SaveManageTrip", Name = "SaveManageTrip")]
        public IActionResult SaveManageTrip(ReqManageTrip manageTripSave)
        {
            try
            {
                if (manageTripSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = manageTripSave.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).SaveManageTrip(manageTripSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(manageTripSave.destination_name).ApiLog("Create", manageTripSave.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(manageTripSave), "500", e.Message);


                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }



        [HttpPost("GetSurvey", Name = "GetSurvey")]
        public IActionResult GetSurvey(ReqSurvey surveySearch)
        {
            try
            {
                if (surveySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResSurvey> res_Obj = new List<ResSurvey>();
                string destination_name = surveySearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetSurvey(surveySearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(surveySearch.destination_name).ApiLog("Create", surveySearch.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(surveySearch), "500", e.Message);


                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("SaveSurvey", Name = "SaveSurvey")]
        public IActionResult SaveSurvey(ReqSurvey surveySave)
        {
            try
            {
                if (surveySave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = surveySave.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).SaveSurvey(surveySave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(surveySave.destination_name).ApiLog("Create", surveySave.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(surveySave), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }



        [HttpPost("GetDieselUpload", Name = "GetDieselUpload")]
        public IActionResult GetDieselUpload(ReqDieselUpload dieselUploadSearch)
        {
            try
            {
                if (dieselUploadSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDieselUpload> res_Obj = new List<ResDieselUpload>();
                string destination_name = dieselUploadSearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetDieselUpload(dieselUploadSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(dieselUploadSearch.destination_name).ApiLog("Create", dieselUploadSearch.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(dieselUploadSearch), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        [HttpPost("SaveDieselUpload", Name = "SaveDieselUpload")]
        public IActionResult SaveDieselUpload(ReqDieselUpload dieselUploadSave)
        {
            try
            {
                if (dieselUploadSave.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDieselUpload> res_Obj = new List<ResDieselUpload>();
                string destination_name = dieselUploadSave.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).SaveDieselUpload(dieselUploadSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(dieselUploadSave.destination_name).ApiLog("Create", dieselUploadSave.org_id, "TransporterController", currentUrl, JsonConvert.SerializeObject(dieselUploadSave), "500", e.Message);


                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }



    }
}
