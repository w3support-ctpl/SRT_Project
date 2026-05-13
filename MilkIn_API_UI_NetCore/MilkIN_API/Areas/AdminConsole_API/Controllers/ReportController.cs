using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/report/")]
    [ApiController]
    public class ReportController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public ReportController(ILogger<LoginController> logger)
        {
            _logger = logger;

        }

        [HttpPost("GetMilkReport", Name = "GetMilkReport")]
        public IActionResult GetMilkReport([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new ReportDAL(destination_name).RunDBQuery(inputParam, "USP_AdminReportMilkCollection");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL("").ApiLog("Create", "", "ReportController", currentUrl, JsonConvert.SerializeObject(reqObject), "500", e.Message);

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

        [HttpPost("GetInvoiceReport", Name = "GetInvoiceReport")]
        public IActionResult GetInvoiceReport([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new ReportDAL(destination_name).RunDBQuery(inputParam, "USP_AdminReportProcInvoice");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL("").ApiLog("Create", "", "ReportController", currentUrl, JsonConvert.SerializeObject(reqObject), "500", e.Message);

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
