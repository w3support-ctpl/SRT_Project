using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.DriverApp_API.DAL;
using static MilkIN_API.Areas.DriverApp_API.DAL.CommonDAL;
using MilkIN_API.Middleware;
using Newtonsoft.Json;


namespace MilkIN_API.Areas.DriverApp_API.Controllers
{
    [Route("v1/api/driver/users/")]
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

        [HttpPost("DriverSignIn", Name = "DriverSignIn")]
        public IActionResult DriverSignIn([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_DriverSign_In");


                dynamic res_Obj = JsonConvert.DeserializeObject(res_Str.ToString());


                if ((inputParam.Method_Name == "GenerateOTP" || inputParam.Method_Name == "ResendOTP" || inputParam.Method_Name == "ForgotPassword") && res_Obj[0].Result_Id.ToString() == "1")
                {

                    new Notify(destination_name, _configuration).Send_SMS_Message(res_Obj[0].Sms_Msg.ToString(), res_Obj[0].Mobile_No.ToString(), "1107170177764556262");

                    res_Obj[0].Mobile_No = "";
                    res_Obj[0].Sms_Msg = "";

                }

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis_Logs("Create", inputParam.org_id, "DriverAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons_Outputs commonOutput = new Commons_Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons_Outputs> { commonOutput });
            }

        }



        [HttpPost("GetProfileInfo", Name = "GetProfileInfo")]
        public IActionResult GetProfileInfo([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_DriverProfile_Get");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis_Logs("Create", inputParam.org_id, "DriverAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons_Outputs commonOutput = new Commons_Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons_Outputs> { commonOutput });
            }

        }


        [HttpPost("UploadImages", Name = "UploadImages")]
        public IActionResult UploadImages([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }

                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_DriverProfile_Set");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis_Logs("Create", inputParam.org_id, "DriverAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons_Outputs commonOutput = new Commons_Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons_Outputs> { commonOutput });
            }

        }





    }
}
