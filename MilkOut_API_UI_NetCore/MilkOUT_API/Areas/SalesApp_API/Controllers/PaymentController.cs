

//using Microsoft.AspNetCore.Mvc;
//using MilkOUT_API.Areas.SalesApp_API.DAL;
//using Newtonsoft.Json;



//namespace MilkOUT_API.Areas.SalesApp_API.Controllers
//{
//    [Route("v1/api/sales/dealer/")]
//    [ApiController]
//    public class PaymentController : Controller
//    {
//        private readonly ILogger<PaymentController> _logger;

//        private readonly IConfiguration _configuration;

//        public PaymentController(ILogger<PaymentController> logger, IConfiguration configuration)
//        {
//            _logger = logger;
//            _configuration = configuration;

//        }


//        [HttpPost("SaveSalesPayment", Name = "SaveSalesPayment")]
//        public IActionResult GetSalesPayment([FromBody] object reqObject)
//        {
//            try
//            {
//                if (reqObject == null)
//                {
//                    return BadRequest();
//                }
//                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
//                string destination_name = inputParam.Destination_Name;
//                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesPayment_Get");

//                return Ok(res_Str);

//            }
//            catch (Exception e)
//            {
//                var ErrMsg = e.Message;

//                return StatusCode(500, ErrMsg);
//            }

//        }



//        [HttpPost("SaveSalesPayment", Name = "SaveSalesPayment")]
//        public IActionResult SaveSalesPayment([FromBody] object reqObject)
//        {
//            try
//            {
//                if (reqObject == null)
//                {
//                    return BadRequest();
//                }
//                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
//                string destination_name = inputParam.Destination_Name;
//                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesPayment_Set");

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


