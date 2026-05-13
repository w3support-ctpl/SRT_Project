


using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.SalesApp_API.DAL;
using Newtonsoft.Json;



namespace MilkOUT_API.Areas.SalesApp_API.Controllers
{
   [Route("v1/api/sales/performance/")]
   [ApiController]
   public class PerformanceController : Controller
   {
       private readonly ILogger<PerformanceController> _logger;

       private readonly IConfiguration _configuration;

       public PerformanceController(ILogger<PerformanceController> logger, IConfiguration configuration)
       {
           _logger = logger;
           _configuration = configuration;

       }


       [HttpPost("GetPerformance", Name = "GetPerformance")]
       public IActionResult GetPerformance([FromBody] object reqObject)
       {
           try
           {
               if (reqObject == null)
               {
                   return BadRequest();
               }
               dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
               string destination_name = inputParam.Destination_Name;
               string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesUserPerformance_Get");

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

