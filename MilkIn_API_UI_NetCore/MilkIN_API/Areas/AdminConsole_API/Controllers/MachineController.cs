using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;
using Org.BouncyCastle.Asn1.Ocsp;
using System.Configuration;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/machine/")]
    [ApiController]
    public class MachineController : Controller
    {
        private readonly ILogger<MachineController> _logger;

        public MachineController(ILogger<MachineController> logger)
        {
            _logger = logger;

        }

        // Get & Search Farmer
        
        // Save Agent
        [HttpPost("SaveMachine", Name = "SaveMachine")]
        public IActionResult SaveMachine(ReqMachine machineSave)
        {
            try
            {
                if (machineSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = machineSave.destination_name + "";
                res_Obj = new MachineDAL(destination_name).SaveMachine(machineSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(machineSave.destination_name).ApiLog("Create", machineSave.org_id, "MachineController", currentUrl, JsonConvert.SerializeObject(machineSave), "500", e.Message);
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
