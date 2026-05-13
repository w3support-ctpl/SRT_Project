



using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.DriverApp_API.DAL;
//using MilkIN_API.Areas.FarmerApp_API.Models;
using static MilkIN_API.Areas.DriverApp_API.DAL.CommonDAL;
using MilkIN_API.Middleware;
using Newtonsoft.Json;
using System.Net.Http.Headers;

namespace MilkIN_API.Areas.DriverApp_API.Controllers
{
    [Route("v1/api/driver/managetrip/")]
    [ApiController]
    public class ManageTripController : Controller
    {
        private readonly ILogger<ManageTripController> _logger;

        private readonly IConfiguration _configuration;
        public ManageTripController(ILogger<ManageTripController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }


        [HttpPost("GetVehicleStatus", Name = "GetVehicleStatus")]
        public IActionResult GetVehicleStatus([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_DriverManageTrips");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis_Logs("Create", inputParam.org_id, "DriverAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons_Outputs commonOutput = new Commons_Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons_Outputs> { commonOutput });
            }

        }


        [HttpPost("ManageCurrentTrip", Name = "ManageCurrentTrip")]
        public IActionResult ManageCurrentTrip([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_DriverManageTrips");


                string Profile_Id = inputParam.Profile_Id;
                string Org_Id = inputParam.Org_Id;

                if (inputParam.Method_Name == "ReachedDairy")
                {
                    new Notify(destination_name, _configuration).Send_Notification(Profile_Id.ToString(), Org_Id.ToString(), "Agent", "ReachedDairy");

                }



                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis_Logs("Create", inputParam.org_id, "DriverAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons_Outputs commonOutput = new Commons_Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons_Outputs> { commonOutput });
            }

        }



        [HttpPost("CollectMilk", Name = "CollectMilk")]
        public IActionResult CollectMilk([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_DriverMilkCollect");


                string Profile_Id = inputParam.Profile_Id;
                string Org_Id = inputParam.Org_Id;

                new Notify(destination_name, _configuration).Send_Notification(Profile_Id.ToString(), Org_Id.ToString(), "Agent", "NextDestination");


                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis_Logs("Create", inputParam.org_id, "DriverAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons_Outputs commonOutput = new Commons_Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons_Outputs> { commonOutput });
            }

        }






        //[HttpPost("UploadImages", Name = "UploadImages")]
        //public IActionResult UploadImages([FromForm] ReqFileInput req)
        //{
        //    var uploadfilebasepath = _configuration.GetValue<string>("AppSettings:UploadFolderPath", "");
        //    var files = HttpContext.Request.Form.Files;
        //    long size = 0;
        //    var file = Request.Form.Files;
        //    var filename = ContentDispositionHeaderValue
        //    .Parse(files[0].ContentDisposition)
        //    .FileName
        //    .Trim('"');
        //    var Orgfilename = ContentDispositionHeaderValue
        //  .Parse(files[0].ContentDisposition)
        //  .FileName
        //  .Trim('"');

        //    size += files[0].Length;
        //    string FilePath;
        //    string Relative_FilePathname;
        //    string Document_Path = uploadfilebasepath + req.AppName + "/UserImage/";
        //    if (!Directory.Exists(Document_Path))
        //    {
        //        Directory.CreateDirectory(Document_Path);
        //    }
        //    Guid loGuid = Guid.NewGuid();
        //    filename = loGuid + "_" + filename;
        //    FilePath = uploadfilebasepath + req.AppName + "/UserImage/" + $@"{filename}";
        //    Relative_FilePathname = req.AppName + "/UserImage/" + $@"{filename}";
        //    size += files[0].Length;
        //    using (FileStream fs = System.IO.File.Create(FilePath))
        //    {
        //        files[0].CopyTo(fs);
        //        fs.Flush();
        //    }


        //    try
        //    {

        //        return Ok(new { status = 200, data = Relative_FilePathname, newfilename = filename, orginalfilename = Orgfilename, Relative_FilePath = Relative_FilePathname });
           
        //    }

        //    catch (Exception ex)
        //    {
        //        var ErrMsg = ex.Message;
        //        return Json(new { status = 500, data = ErrMsg });
        //    }
        //}













    }
}
