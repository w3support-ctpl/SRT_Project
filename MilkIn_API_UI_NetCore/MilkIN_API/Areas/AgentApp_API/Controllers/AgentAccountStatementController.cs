using Dapper;
using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AgentApp_API.DAL;
using MilkIN_API.Areas.AgentApp_API.Models;
using MilkIN_API.Areas.AgentApp_API.SAP;
using Newtonsoft.Json;
using static MilkIN_API.Areas.AgentApp_API.DAL.CommonDAL;


namespace MilkIN_API.Areas.AgentApp_API.Controllers
{
    [Route("v1/api/agent/accountstatement/")]
    [ApiController]
    public class AgentAccountStatementController : Controller
    {
        private readonly ILogger<AgentAccountStatementController> _logger;

        private readonly IConfiguration _configuration;

        public AgentAccountStatementController(ILogger<AgentAccountStatementController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }

        [HttpPost("GetAccountStatement", Name = "GetAccountStatement")]
        public IActionResult GetAccountStatement([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }
                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_AdminAccountStatement_Get");

                var accountData = JsonConvert.DeserializeObject<List<dynamic>>(res_Str);
                string supplier = accountData[0].Supplier;
                string startDate = accountData[0].StartDate;
                string endDate = accountData[0].EndDate;

                var parameters = new 
                {
                    Method_Name = "Get",
                    Org_Id = inputParam.Org_Id,

                };

                string ReqParams = JsonConvert.SerializeObject(parameters);
                dynamic inputParamd = JsonConvert.DeserializeObject(ReqParams.ToString());
               

                string res_DestinationName = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParamd, "USP_AdminOrg_Get");

                var accountDataD = JsonConvert.DeserializeObject<List<dynamic>>(res_DestinationName);

                string connectionName = (string)accountDataD[0].ConnectionName;

                string res_output = new AccountStatementSAP(connectionName).GetAccountStatementSAP(supplier, startDate, endDate);


                return Ok(res_output);

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
