using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AgentApp_API.DAL;
using MilkIN_API.Areas.AgentApp_API.Models;
using Newtonsoft.Json;
using static MilkIN_API.Areas.AgentApp_API.DAL.CommonDAL;

namespace MilkIN_API.Areas.AgentApp_API.Controllers
{

    [Route("v1/api/agent/farmer/")]
    [ApiController]
    public class AgentFarmerServiceController : Controller
    {
        private readonly ILogger<AgentFarmerServiceController> _logger;

        private readonly IConfiguration _configuration;

        public AgentFarmerServiceController(ILogger<AgentFarmerServiceController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }

        [HttpPost("AgentFarmerGetService", Name = "AgentFarmerGetService")]
        public IActionResult AgentFarmerGetService([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_AgentFarmerService_Get");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(inputParam.destination_name, _configuration).ApiLogs("Create", inputParam.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Common____Output commonOutput = new Common____Output
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Common____Output> { commonOutput });
            }

        }

        [HttpPost("AgentFarmerSaveService", Name = "AgentFarmerSaveService")]
        public IActionResult AgentFarmerSaveService([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_AgentFarmerService_Set");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(inputParam.destination_name, _configuration).ApiLogs("Create", inputParam.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Common____Output commonOutput = new Common____Output
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Common____Output> { commonOutput });
            }

        }
    }
}





