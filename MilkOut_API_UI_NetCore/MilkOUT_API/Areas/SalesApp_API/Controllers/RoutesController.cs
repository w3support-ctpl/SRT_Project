


using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.SalesApp_API.DAL;
using Newtonsoft.Json;



namespace MilkOUT_API.Areas.SalesApp_API.Controllers
{
    [Route("v1/api/sales/routes/")]
    [ApiController]
    public class RoutesController : Controller
    {
        private readonly ILogger<RoutesController> _logger;

        private readonly IConfiguration _configuration;

        public RoutesController(ILogger<RoutesController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }


        [HttpPost("SalesUserRoutes", Name = "SalesUserRoutes")]
        public IActionResult SalesUserRoutes([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }

                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                string res_Str = new CommonDAL(destination_name, _configuration).RunDBQuery(inputParam, "USP_SalesUserRoutes_Get");

                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }




        [HttpPost("GetFleetxData", Name = "GetFleetxData")]
        public IActionResult GetFleetxData()
        {
            try
            {
                //if (reqObject == null)
                //{
                //    return BadRequest();
                //}

                //dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = "";


                string res_Str =  new CommonDAL(destination_name, _configuration).GetFleetxData();

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

