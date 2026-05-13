
using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.ChemistApp_API.DAL;
using Newtonsoft.Json;
using static MilkIN_API.Areas.ChemistApp_API.DAL.CommonDAL;

namespace MilkIN_API.Areas.ChemistApp_API.Controllers
{
    [Route("v1/api/chemist/survey/")]
    [ApiController]
    public class SurveyController : Controller
    {
        private readonly ILogger<SurveyController> _logger;

        private readonly IConfiguration _configuration;

        public SurveyController(ILogger<SurveyController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }


        [HttpPost("ManageSurvey", Name = "ManageSurvey")]
        public IActionResult ManageSurvey([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_ChemistSurvey");

                return Ok(res_Str);

            }
            catch (Exception e)
            {

                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new CommonDAL(destination_name, _configuration).Api_Logs("Create", inputParam.org_id, "ChemistAPP", currentUrl, JsonConvert.SerializeObject(inputParam), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                Common_Outputs commonOutput = new Common_Outputs
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<Common_Outputs> { commonOutput });
            }
        }



    }
}


