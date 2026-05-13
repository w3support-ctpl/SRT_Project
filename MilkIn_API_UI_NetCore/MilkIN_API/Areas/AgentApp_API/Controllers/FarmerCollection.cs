


using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.FarmerApp_API.DAL;
using Newtonsoft.Json;
using System.Configuration;
using static MilkIN_API.Areas.FarmerApp_API.DAL.CommonDAL;

namespace MilkIN_API.Areas.FarmerApp_API.Controllers
{
    [Route("v1/api/agent/farmer/")]
    [ApiController]
    public class FarmerCollection : Controller
    {
        private readonly ILogger<CollectionController> _logger;

        private readonly IConfiguration _configuration;

        public FarmerCollection(ILogger<CollectionController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        [HttpPost("FarmerCollection", Name = "AgFarmerCollection")]
        public IActionResult AgFarmerCollection([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.destination_name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_AgentFarmerCollection_Get");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(inputParam.destination_name, _configuration).Apis__Logs("Create", inputParam.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Common_Output commonOutput = new Common_Output
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Common_Output> { commonOutput });
            }

        }


    }
}
