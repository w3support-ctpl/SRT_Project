using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.FarmerApp_API.Models;
using MilkIN_API.Areas.FarmerApp_API.DAL;
using Newtonsoft.Json;

namespace MilkIN_API.Areas.FarmerApp_API.Controllers
{
    [Route("v1/api/farmer/incentives/")]
    [ApiController]
    public class IncentivesController : Controller
    {
        private readonly ILogger<IncentivesController> _logger;

        private readonly IConfiguration _configuration;

        public IncentivesController(ILogger<IncentivesController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }


        [HttpPost("GetIncentive", Name = "GetIncentive")]
        public IActionResult GetIncentive([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_FarmerIncentiveScheme_Get");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis__Logs("Create", inputParam.org_id, "FarmerAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons__Outputs commonOutput = new Commons__Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons__Outputs> { commonOutput });
            }

        }

        [HttpPost("SaveIncentive", Name = "SaveIncentive")]
        public IActionResult SaveIncentive([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_FarmerIncentiveScheme_Set");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis__Logs("Create", inputParam.org_id, "FarmerAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons__Outputs commonOutput = new Commons__Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons__Outputs> { commonOutput });
            }

        }
   
    }
}
