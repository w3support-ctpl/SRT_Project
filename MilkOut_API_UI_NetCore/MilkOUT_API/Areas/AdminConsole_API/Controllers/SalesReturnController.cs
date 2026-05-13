using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/salesReturn/")]
    [ApiController]
    public class SalesReturnController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public SalesReturnController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }
        
        
        
        
        
        [HttpPost("GetSalesReturn", Name = "GetSalesReturn")]
        public IActionResult GetSalesReturn(ReqSalesReturn salesReturn)
        {
            try
            {
                if (salesReturn.method_name == null)
                {
                    return BadRequest();
                }

                List<ResSalesReturn> res_Obj = new List<ResSalesReturn>();
                string destination_name = salesReturn.destination_name + "";
                // res_Obj = new SalesReturnDAL(destination_name).GetSalesReturn(SalesReturnSearch);

                return Ok();

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("SaveSalesReturn", Name = "SaveSalesReturn")]
        public IActionResult SaveSalesReturn(ReqSalesReturn salesReturnSave)
        {
            try
            {
                if (salesReturnSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = salesReturnSave.destination_name + "";
                // res_Obj = new SecondaryDAL(destination_name).SaveSalesReturn(salesReturnSave);
                return Ok();

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
    }
}
