
using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.FarmerApp_API.DAL;
using MilkIN_API.Areas.FarmerApp_API.Models;
using Newtonsoft.Json;
using System.Configuration;

namespace MilkIN_API.Areas.FarmerApp_API.Controllers
{
    [Route("v1/api/farmer/accountstatement/")]
    [ApiController]
    public class AccountStatementController : Controller
    {
        private readonly ILogger<AccountStatementController> _logger;

        private readonly IConfiguration _configuration;

        public AccountStatementController(ILogger<AccountStatementController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }

        [HttpPost("GetAccoutStatement", Name = "GetAccoutStatement")]
        public IActionResult GetAccoutStatement([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_FarmerAccount_Statement");

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
