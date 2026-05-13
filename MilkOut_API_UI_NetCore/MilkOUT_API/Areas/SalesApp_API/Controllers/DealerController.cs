
using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.SalesApp_API.DAL;
using Newtonsoft.Json;


namespace MilkOUT_API.Areas.SalesApp_API.Controllers
{
    [Route("v1/api/sales/dealers/")]
    [ApiController]
    public class DealerController : Controller
    {
        private readonly ILogger<DealerController> _logger;

        private readonly IConfiguration _configuration;

        public DealerController(ILogger<DealerController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }


        [HttpPost("SalesDealers", Name = "SalesDealers")]
        public IActionResult SalesDealers([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }

                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesDealers");

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

