

using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/debitmemo/")]
    [ApiController]
    public class DebitMemoRequestController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public DebitMemoRequestController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }


        [HttpPost("GetDebitMemoRequest", Name = "GetDebitMemoRequest")]
        public IActionResult GetDebitMemoRequest([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }


                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = inputParam.org_id;
                req_Obj.dealer_id = inputParam.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = inputParam.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new DebitMemoSAP(res_DestinationName[0].ConnectionName).GetAllDebitMemo(res_Obj[0].dealer_code.ToString(), inputParam.StartDate.ToString(), inputParam.EndDate.ToString());


                return Ok(res_output);

             

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        [HttpPost("GetOneDebitMemoRequest", Name = "GetOneDebitMemoRequest")]
        public IActionResult GetOneDebitMemoRequest([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }


                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = inputParam.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new DebitMemoSAP(res_DestinationName[0].ConnectionName).GetOneDebitMemo(inputParam.DebitMemoRequest.ToString());


                return Ok(res_output);



            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




    }
}

