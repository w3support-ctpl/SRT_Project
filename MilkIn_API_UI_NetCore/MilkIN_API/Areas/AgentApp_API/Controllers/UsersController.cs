using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using MilkIN_API.Areas.AgentApp_API.DAL;
using MilkIN_API.Areas.AgentApp_API.Models;
using MilkIN_API.Middleware;
using Newtonsoft.Json;
using static MilkIN_API.Areas.AgentApp_API.DAL.CommonDAL;

namespace MilkIN_API.Areas.AgentApp_API.Controllers
{
    [Route("v1/api/agent/users/")]
    [ApiController]
    public class UsersController : Controller
    {

        private readonly ILogger<UsersController> _logger;

        private readonly  IConfiguration _configuration;



        public UsersController(ILogger<UsersController> logger , IConfiguration configuration )
        {
            _logger = logger;
            _configuration = configuration;

        }



        [HttpPost("AGSignIn", Name = "AgentSignIn")]
        public IActionResult AgentSignIn(ReqAgentSignIn SignIn)
        {
            try
            {
                if (SignIn.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgentDetails> res_Obj = new List<ResAgentDetails>();
                string destination_name = SignIn.destination_name + "";
                res_Obj = new UsersDAL(destination_name, _configuration).SignIn(SignIn);


                if (res_Obj.Count > 0)
                {

                    return Ok(res_Obj);
                }
                else
                {

                    return StatusCode(500, "Invalid User Credentials");
                }



            }
            catch (Exception e)
            {
                
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(SignIn.destination_name).ApiLogs("Create", SignIn.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(SignIn), "500", e.Message);

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




        [HttpPost("AGSignInv2", Name = "AgentSignInv2")]
        public IActionResult AgentSignInv2(ReqAgentSignIn SignIn)
        {
            try
            {
                if (SignIn.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgentDetails> res_Obj = new List<ResAgentDetails>();
                string destination_name = SignIn.destination_name + "";
                res_Obj = new UsersDAL(destination_name, _configuration).SignInv2(SignIn);


                if (res_Obj.Count > 0)
                {

                    return Ok(res_Obj);
                }
                else
                {

                    return StatusCode(500, "Invalid User Credentials");
                }



            }
            catch (Exception e)
            {
                
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(SignIn.destination_name).ApiLogs("Create", SignIn.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(SignIn), "500", e.Message);

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



        [HttpPost("AGVerify", Name = "AgentVerification")]
        public IActionResult AgentVerification(ReqAgentVerify AgentVerify)
        {
            try
            {
                if (AgentVerify.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = AgentVerify.destination_name + "";
                res_Obj = new UsersDAL(destination_name, _configuration).AgentVerify(AgentVerify);

                if ((AgentVerify.method_name == "GenerateOTP" || AgentVerify.method_name == "ResendOTP" || AgentVerify.method_name == "ForgotPassword") && res_Obj[0].result_id.ToString() == "1")
                {

                    new Notify(destination_name, _configuration).Send_SMS_Message(res_Obj[0].sms_msg, res_Obj[0].mobile_no, "1107170177764556262");

                    res_Obj[0].mobile_no = "";
                    res_Obj[0].sms_msg = "";

                }


                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(AgentVerify.destination_name).ApiLogs("Create", AgentVerify.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(AgentVerify), "500", e.Message);

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


        [HttpPost("SaveAgent", Name = "SaveAgentDetails")]
        public IActionResult SaveAgentDetails(ReqSaveAgent SaveAgent)
        {
            try
            {
                if (SaveAgent.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = SaveAgent.destination_name + "";
                res_Obj = new UsersDAL(destination_name, _configuration).SaveAgentDetails(SaveAgent);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(SaveAgent.destination_name).ApiLogs("Create", SaveAgent.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(SaveAgent), "500", e.Message);

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


        [HttpPost("GetAgentInfo", Name = "GetAgentProfileInfo")]
        public IActionResult GetAgentProfileInfo(ReqGetAgent GetAgent)
        {
            try
            {
                if (GetAgent.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgentInfo> res_Obj = new List<ResAgentInfo>();
                string destination_name = GetAgent.destination_name + "";

               // new Notify(destination_name, _configuration).Send_SMS_Message("Hello Nitesh, Your account has been approved for S R Thorat Dairy Farmer App. Kindly use below Mobile Number and Password for login to Farmer App. Mobile No : 1234567890 Password : Abc@1234" , "9167679636" , "");

                res_Obj = new UsersDAL(destination_name, _configuration).GetAgentProfileInfo(GetAgent);


                return Ok(res_Obj);

            }
            catch (Exception e)
            {
               
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(GetAgent.destination_name).ApiLogs("Create", GetAgent.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(GetAgent), "500", e.Message);

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



        [HttpPost("AgentProfileCorrection", Name = "AgentProfileCorrection")]
        public IActionResult AgentProfileCorrection([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_AgentProfileData_Correction");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(inputParam.destination_name, _configuration).ApiLogs("Create", inputParam.org_id, "AgentAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

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
