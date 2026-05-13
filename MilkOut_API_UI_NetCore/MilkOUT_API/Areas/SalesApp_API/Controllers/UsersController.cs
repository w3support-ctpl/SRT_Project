using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.SalesApp_API.DAL;
using MilkOUT_API.Middleware;
using Newtonsoft.Json;



namespace MilkOUT_API.Areas.SalesApp_API.Controllers
{
    [Route("v1/api/sales/user/")]
    
    [ApiController]
    public class UsersController : Controller
    {
        private readonly ILogger<UsersController> _logger;


        private readonly IConfiguration _configuration;

        public UsersController(ILogger<UsersController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }

        [HttpPost("SignIn", Name = "UserSignin")]
        public IActionResult UserSignin([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());


                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name,_configuration).RunDBQuery(inputParam, "USP_SalesSign_In");

                dynamic inputParam2 = JsonConvert.DeserializeObject(res_Str);

                if ((inputParam.method_name == "GenerateOTP" ||
             inputParam.method_name == "ResendOTP" ||
             inputParam.method_name == "ForgotPassword") &&
             inputParam2[0].Result_Id == "1")
                {
                    string Sms_Msg = inputParam2[0].Sms_Msg.ToString();
                    string Mobile_No = inputParam2[0].Mobile_No.ToString();

                    new Notify_Data(destination_name).Send_SMS_Message(Sms_Msg, Mobile_No, "1107170177764556262");

                    inputParam2[0].Mobile_No = "";
                    inputParam2[0].Sms_Msg = "";
                }


                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }


        [HttpPost("DashBoard", Name = "SalesDashboard")]
        public IActionResult SalesDashboard([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesUser_Dashboard");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }


        [HttpPost("ProfilePhoto", Name = "ProfilePhoto")]
        public IActionResult ProfilePhoto([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesUserProfile");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }


        [HttpPost("Get", Name = "Get")]
        public IActionResult Get([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "Get");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }






    }
}

