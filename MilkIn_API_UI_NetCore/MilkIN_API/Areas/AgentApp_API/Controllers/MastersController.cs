using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AgentApp_API.DAL;
using MilkIN_API.Areas.AgentApp_API.Models;
using Newtonsoft.Json;
using static MilkIN_API.Areas.AgentApp_API.DAL.CommonDAL;

namespace MilkIN_API.Areas.AgentApp_API.Controllers
{
    [Route("v1/api/agent/master/")]
    [ApiController]
    public class MastersController : Controller
    {

        private readonly ILogger<MastersController> _logger;

        private readonly IConfiguration _configuration;

        public MastersController(ILogger<MastersController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }


        [HttpPost("GetMasters", Name = "GetMastersAgent")]
        public IActionResult GetMastersAgent(ReqAGMasterData master_data)
        {
            try
            {
                if (master_data.Method_Name == "")
                {
                    return BadRequest();
                }

                string destination_name = master_data.destination_name + "";
                List<AGMasterDetails> res_Obj = new List<AGMasterDetails>();
                res_Obj = new MastersDAL(destination_name, _configuration).GetMastersData(master_data);

                return Ok(res_Obj);

            }

            catch (Exception e)
            {

                
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(master_data.destination_name).ApiLogs("Create", master_data.Org_Id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(master_data), "500", e.Message);

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
