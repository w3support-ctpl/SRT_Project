



//using Microsoft.AspNetCore.Mvc;
//using MilkOUT_API.Areas.SalesApp_API.DAL;
//using Newtonsoft.Json;



//namespace MilkOUT_API.Areas.SalesApp_API.Controllers
//{
//    [Route("v1/api/sales/dealer/")]
//    [ApiController]
//    public class QuotationController : Controller
//    {
//        private readonly ILogger<QuotationController> _logger;

//        private readonly IConfiguration _configuration;

//        public QuotationController(ILogger<QuotationController> logger, IConfiguration configuration)
//        {
//            _logger = logger;
//            _configuration = configuration;

//        }


//        [HttpPost("GetSalesQuotation", Name = "GetSalesQuotation")]
//        public IActionResult GetSalesQuotation([FromBody] object reqObject)
//        {
//            try
//            {
//                if (reqObject == null)
//                {
//                    return BadRequest();
//                }
//                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
//                string destination_name = inputParam.Destination_Name;
//                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesQuotation_Get");

//                return Ok(res_Str);

//            }
//            catch (Exception e)
//            {
//                var ErrMsg = e.Message;

//                return StatusCode(500, ErrMsg);
//            }

//        }



//        [HttpPost("SaveSalesQuotation", Name = "SaveSalesQuotation")]
//        public IActionResult SaveSalesQuotation([FromBody] object reqObject)
//        {
//            try
//            {
//                if (reqObject == null)
//                {
//                    return BadRequest();
//                }
//                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
//                string destination_name = inputParam.Destination_Name;
//                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesQuotationSet");

//                return Ok(res_Str);

//            }
//            catch (Exception e)
//            {
//                var ErrMsg = e.Message;

//                return StatusCode(500, ErrMsg);
//            }

//        }











//    }
//}


