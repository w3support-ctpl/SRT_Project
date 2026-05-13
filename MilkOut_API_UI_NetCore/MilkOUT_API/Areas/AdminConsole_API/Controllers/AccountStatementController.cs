using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/accountStatement/")]
    [ApiController]
    public class AccountStatementController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public AccountStatementController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }
        [HttpPost("GetAccountStatement", Name = "GetAccountStatement")]
        public IActionResult GetAccountStatement(ReqAccountStatement accountStatement)
        {
            try
            {
                if (accountStatement.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAccountStatement> res_Obj = new List<ResAccountStatement>();
                string destination_name = accountStatement.destination_name + "";
                // res_Obj = new AccountStatementDAL(destination_name).GetAccountStatement(AccountStatementSearch);

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
