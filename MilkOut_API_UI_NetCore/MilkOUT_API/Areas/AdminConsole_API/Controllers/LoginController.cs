using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/user/")]
    [ApiController]
    public class LoginController : Controller
    {
        private readonly IJwtBuilder _jwtBuilder;
        private readonly ILogger<LoginController> _logger;

        public LoginController(ILogger<LoginController> logger, IJwtBuilder jwtBuilder)
        {
            _logger = logger;
            _jwtBuilder = jwtBuilder;
        }


        [HttpPost("Login", Name = "Login")]
        public IActionResult Login([FromBody] ReqLogin login)
        {
            try
            {
                if (login == null)
                {
                    return BadRequest();
                }

                List<UserDetails> res_Obj = new List<UserDetails>();
                string destination_name = login.destination_name + "";
                res_Obj = new LoginDAL(destination_name).Login(login);


                if (res_Obj.Count > 0)
                {
                    // Valid User Credentials
                    if (login.method_name == "AdminUser")
                    {
                        // Get Role
                        res_Obj[0].usermenu = new LoginDAL(destination_name).GetUserMenu(res_Obj[0].role_id + "", res_Obj[0].org_id + "");
                        res_Obj[0].token = _jwtBuilder.GetToken(res_Obj[0].user_id + "");
                    }
                    return Ok(res_Obj);
                }
                else
                {
                    // Invalid User Credentials
                    _logger.LogError($"Error : Invalid User Credentials");
                    return StatusCode(500, "Invalid User Credentials");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error : {ex.Message}");
                return StatusCode(500, ex.Message);
            }
        }

    }
}
