using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/home/")]
    [ApiController]
    public class HomeController : Controller
    {
        private readonly IJwtBuilder _jwtBuilder;
        private readonly ILogger<LoginController> _logger;

        public HomeController(ILogger<LoginController> logger, IJwtBuilder jwtBuilder)
        {
            _logger = logger;
            _jwtBuilder = jwtBuilder;
        }

        [HttpPost("GetMasterData", Name = "GetMasterData")]
        public IActionResult GetMasterData([FromBody] ReqMasterData masterData)
        {
            try
            {
                if (masterData == null)
                {
                    return BadRequest();
                }

                List<MasterDetails> res_Obj = new List<MasterDetails>();

                string Destination_Name = masterData.destination_name + "";
                res_Obj = new HomeDAL(Destination_Name).GetMasterData(masterData);
                return Ok(res_Obj);

            }
            catch (Exception ex)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(masterData.destination_name).ApiLog("Create", masterData.org_id, "HomeController", currentUrl, JsonConvert.SerializeObject(masterData), "500", ex.Message);


                _logger.LogError($"Error : {ex.Message}");
                return StatusCode(500, ex.Message);
            }

        }

        [HttpPost("GetMastersData", Name = "GetMastersData")]
        public IActionResult GetMastersData([FromBody] ReqMasterData masterData)
        {
            try
            {
                if (masterData == null)
                {
                    return BadRequest();
                }

                List<MasterDetails> res_Obj = new List<MasterDetails>();

                string Destination_Name = masterData.destination_name + "";
                res_Obj = new HomeDAL(Destination_Name).GetMastersData(masterData);
                return Ok(res_Obj);

            }
            catch (Exception ex)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(masterData.destination_name).ApiLog("Create", masterData.org_id, "HomeController", currentUrl, JsonConvert.SerializeObject(masterData), "500", ex.Message);


                _logger.LogError($"Error : {ex.Message}");
                return StatusCode(500, ex.Message);
            }

        }


        [HttpPost("GetAdminDashboard", Name = "GetAdminDashboard")]
        public IActionResult GetAdminDashboard([FromBody] ReqDashboard dashboardData)
        {
            try
            {
                if (dashboardData == null)
                {
                    return BadRequest();
                }

                List<DashboardDetails> res_Obj = new List<DashboardDetails>();

                string Destination_Name = dashboardData.destination_name + "";
                res_Obj = new HomeDAL(Destination_Name).GetAdminDashboard(dashboardData);
                return Ok(res_Obj);

            }
            catch (Exception ex)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(dashboardData.destination_name).ApiLog("Create", dashboardData.org_id, "HomeController", currentUrl, JsonConvert.SerializeObject(dashboardData), "500", ex.Message);


                _logger.LogError($"Error : {ex.Message}");
                return StatusCode(500, ex.Message);
            }

        }

        [HttpPost("SaveRate", Name = "SaveRate")]
        public IActionResult SaveUser(ReqMasterData rateSave)
        {
            try
            {
                if (rateSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = rateSave.destination_name + "";
                res_Obj = new HomeDAL(destination_name).SaveRate(rateSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(rateSave.destination_name).ApiLog("Create", rateSave.org_id, "HomeController", currentUrl, JsonConvert.SerializeObject(rateSave), "500", e.Message);


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
