

//using Microsoft.AspNetCore.Mvc;
//using MilkOUT_API.Areas.SalesApp_API.DAL;
//using Newtonsoft.Json;



//namespace MilkOUT_API.Areas.SalesApp_API.Controllers
//{
//    [Route("v1/api/sales/dealer/")]
//    [ApiController]
//    public class DeliveryController : Controller
//    {
//        private readonly ILogger<DeliveryController> _logger;

//        private readonly IConfiguration _configuration;

//        public DeliveryController(ILogger<DeliveryController> logger, IConfiguration configuration)
//        {
//            _logger = logger;
//            _configuration = configuration;

//        }


//        [HttpPost("GetSalesDelivery", Name = "GetSalesDelivery")]
//        public IActionResult GetSalesDelivery([FromBody] object reqObject)
//        {
//            try
//            {
//                if (reqObject == null)
//                {
//                    return BadRequest();
//                }
//                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
//                string destination_name = inputParam.Destination_Name;
//                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesDelivery_Get");

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


