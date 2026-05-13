using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.FarmerApp_API.Models;
using MilkIN_API.Areas.FarmerApp_API.DAL;
using Newtonsoft.Json;
using MilkIN_API.Middleware;
using Org.BouncyCastle.Ocsp;
using System.Configuration;
using System.Net.Http.Headers;
using MilkIN_API.Areas.AdminConsole_API.Models;
using CommonOutput = MilkIN_API.Areas.FarmerApp_API.Models.CommonOutput;

namespace MilkIN_API.Areas.FarmerApp_API.Controllers
{
    [Route("v1/api/farmer/users/")]
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


        [HttpPost("SignUp", Name = "SignUp")]
        public IActionResult SignUp(ReqSignUp SignUp)
        {
            try
            {
                if (SignUp.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = SignUp.destination_name + "";
                res_Obj = new UsersDAL(destination_name, _configuration).SignUp(SignUp);



                if ((SignUp.method_name == "GenerateOTP" || SignUp.method_name == "ResendOTP" || SignUp.method_name == "ForgotPassword") && res_Obj[0].result_id.ToString() == "1")
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
                new CommonDAL(SignUp.destination_name, _configuration).Apis__Logs("Create", SignUp.org_id, "FarmerAPP", currentUrl, JsonConvert.SerializeObject(SignUp), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons__Outputs commonOutput = new Commons__Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons__Outputs> { commonOutput });
            }
        }


        [HttpPost("SignIn", Name = "SignIn")]
        public IActionResult SignIn(ReqSignIn SignIn)
        {
            try
            {
                if (SignIn.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmerDetails> res_Obj = new List<ResFarmerDetails>();
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
                new CommonDAL(SignIn.destination_name, _configuration).Apis__Logs("Create", SignIn.org_id, "FarmerAPP", currentUrl, JsonConvert.SerializeObject(SignIn), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons__Outputs commonOutput = new Commons__Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons__Outputs> { commonOutput });
            }
        }




        [HttpPost("SaveFarmer", Name = "SaveFarmerDetails")]
        public IActionResult SaveFarmerDetails(ReqSaveFarmer SaveFarmer)
        {
            try
            {
                if (SaveFarmer.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = SaveFarmer.destination_name + "";
                res_Obj = new UsersDAL(destination_name, _configuration).SaveFarmerDetails(SaveFarmer);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(SaveFarmer.destination_name, _configuration).Apis__Logs("Create", SaveFarmer.org_id, "FarmerAPP", currentUrl, JsonConvert.SerializeObject(SaveFarmer), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons__Outputs commonOutput = new Commons__Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons__Outputs> { commonOutput });
            }
        }



        [HttpPost("GetFarmerInfo", Name = "GetFarmerProfileInfo")]
        public IActionResult GetFarmerProfileInfo(ReqGetFarmer GetFarmer)
        {
            try
            {
                if (GetFarmer.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmerInfo> res_Obj = new List<ResFarmerInfo>();
                string destination_name = GetFarmer.destination_name + "";
                res_Obj = new UsersDAL(destination_name, _configuration).GetFarmerProfileInfo(GetFarmer);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
               
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(GetFarmer.destination_name, _configuration).Apis__Logs("Create", GetFarmer.org_id, "FarmerAPP", currentUrl, JsonConvert.SerializeObject(GetFarmer), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons__Outputs commonOutput = new Commons__Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons__Outputs> { commonOutput });
            }
        }



        [HttpPost("FarmerProfileCorrection", Name = "FarmerProfileCorrection")]
        public IActionResult FarmerProfileCorrection([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_FarmerProfileData_Correction");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Apis__Logs("Create", inputParam.org_id, "FarmerAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Commons__Outputs commonOutput = new Commons__Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Commons__Outputs> { commonOutput });
            }

        }







        //[HttpPost("UploadImages", Name = "farmerUploadImages")]
        //public IActionResult farmerUploadImages([FromForm] ReqFileInput req)
        //{
        //    var uploadfilebasepath = _configuration.GetValue<string>("AppSettings:UploadFolderPath", "");
        //    var files = HttpContext.Request.Form.Files;
        //    long size = 0;
        //    var file = Request.Form.Files;
        //    var filename = ContentDispositionHeaderValue
        //    .Parse(files[0].ContentDisposition)
        //    .FileName
        //    .Trim('"');
        //    var Orgfilename = ContentDispositionHeaderValue
        //  .Parse(files[0].ContentDisposition)
        //  .FileName
        //  .Trim('"');

        //    size += files[0].Length;
        //    string FilePath;
        //    string Relative_FilePathname;
        //    string Document_Path = uploadfilebasepath + req.AppName + "/UserImage/";
        //    if (!Directory.Exists(Document_Path))
        //    {
        //        Directory.CreateDirectory(Document_Path);
        //    }
        //    Guid loGuid = Guid.NewGuid();
        //    filename = loGuid + "_" + filename;
        //    FilePath = uploadfilebasepath + req.AppName + "/UserImage/" + $@"{filename}";
        //    Relative_FilePathname = req.AppName + "/UserImage/" + $@"{filename}";
        //    size += files[0].Length;
        //    using (FileStream fs = System.IO.File.Create(FilePath))
        //    {
        //        files[0].CopyTo(fs);
        //        fs.Flush();
        //    }


        //    try
        //    {

        //        return Ok(new { status = 200, data = Relative_FilePathname, newfilename = filename, orginalfilename = Orgfilename, Relative_FilePath = Relative_FilePathname });
        //    }
        //    catch (Exception ex)
        //    {
        //        var ErrMsg = ex.Message;
        //        return Json(new { status = 500, data = ErrMsg });
        //    }
        //}




    }

}
