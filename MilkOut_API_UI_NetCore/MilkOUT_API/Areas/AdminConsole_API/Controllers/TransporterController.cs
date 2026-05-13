using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.FleetX;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/transporter/")]
    [ApiController]
    public class TransporterController : Controller
    {
        private readonly ILogger<LoginController> _logger;
        public TransporterController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }

        [HttpPost("SaveRoute", Name = "SaveRoute")]
        public IActionResult SaveRoute(ReqRoute routeSave)
        {
            try
            {
                if (routeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = routeSave.destination_name + "";

                res_Obj = new TransporterDAL(destination_name).SaveRoute(routeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetRoute", Name = "GetRoute")]
        public IActionResult GetRoute(ReqRoute routeSearch)
        {
            try
            {
                if (routeSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRoute> res_Obj = new List<ResRoute>();
                string destination_name = routeSearch.destination_name + "";
                res_Obj = new TransporterDAL(destination_name).GetRoute(routeSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetFleetXDatas", Name = "GetFleetXDatas")]
        public IActionResult GetFleetXDatas(ReqRoute routeSearch)
        {
            try
            {

                string resString = new FleetX_Data().GetFleetXData();
                return Ok(resString);

            }
            catch (Exception e)
            {
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
