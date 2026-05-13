

using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.DriverApp_API.DAL;
using static MilkIN_API.Areas.DriverApp_API.DAL.CommonDAL;
using MilkIN_API.Middleware;
using Newtonsoft.Json;


namespace MilkIN_API.Areas.DriverApp_API.Controllers
{
    [Route("v1/api/driver/upcomingtrip/")]
    [ApiController]
    public class UpcomingTripController : Controller
    {
        private readonly ILogger<UpcomingTripController> _logger;

        private readonly IConfiguration _configuration;
        public UpcomingTripController(ILogger<UpcomingTripController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        [HttpPost("GetUpcomingTrip", Name = "GetUpcomingTrip")]
        public IActionResult GetUpcomingTrip([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_DriverUpcomingTrip_Get");

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


        [HttpPost("StartTrip", Name = "StartTrip")]
        public IActionResult StartTrip([FromBody] object reqObject)
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


                if (inputParam.Method_Name == "StartTrip")
                {

                    string Profile_Id = inputParam.Profile_Id;
                    string Org_Id = inputParam.Org_Id;

                    new Notify(destination_name, _configuration).Send_Notification(Profile_Id.ToString(), Org_Id.ToString(), "Agent", "StartTrip");

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










    }
}
