




//using Microsoft.AspNetCore.Mvc;
//using MilkOUT_API.Areas.SalesApp_API.DAL;
//using Newtonsoft.Json;



//namespace MilkOUT_API.Areas.SalesApp_API.Controllers
//{
//    [Route("v1/api/sales/dealer/")]
//    [ApiController]
//    public class DeliveryReturnController : Controller
//    {
//        private readonly ILogger<DeliveryReturnController> _logger;

//        private readonly IConfiguration _configuration;

//        public DeliveryReturnController(ILogger<DeliveryReturnController> logger, IConfiguration configuration)
//        {
//            _logger = logger;
//            _configuration = configuration;

//        }


//        [HttpPost("GetDeliveryReturn", Name = "GetDeliveryReturn")]
//        public IActionResult GetDeliveryReturn([FromBody] object reqObject)
//        {
//            try
//            {
//                if (reqObject == null)
//                {
//                    return BadRequest();
//                }
//                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
//                string destination_name = inputParam.Destination_Name;
//                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesDeliveryReturn_Get");

//                return Ok(res_Str);

//            }
//            catch (Exception e)
//            {
//                var ErrMsg = e.Message;

//                return StatusCode(500, ErrMsg);
//            }

//        }



//        [HttpPost("SaveDeliveryReturn", Name = "SaveDeliveryReturn")]
//        public IActionResult SaveDeliveryReturn([FromBody] object reqObject)
//        {
//            try
//            {
//                if (reqObject == null)
//                {
//                    return BadRequest();
//                }
//                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
//                string destination_name = inputParam.Destination_Name;
//                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesDeliveryReturn_Set");

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


