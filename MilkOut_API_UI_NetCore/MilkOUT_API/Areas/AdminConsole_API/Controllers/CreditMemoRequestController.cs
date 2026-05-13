using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/creditMemoRequest/")]
    [ApiController]
    public class CreditMemoRequestController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public CreditMemoRequestController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }





        //[HttpPost("GetCreditMemoRequest", Name = "GetCreditMemoRequest")]
        //public IActionResult GetCreditMemoRequest(ReqCreditMemoRequest creditMemoRequest)
        //{
        //    try
        //    {
        //        if (creditMemoRequest.method_name == null)
        //        {
        //            return BadRequest();
        //        }

        //        List<ResCreditMemoRequest> res_Obj = new List<ResCreditMemoRequest>();
        //        string destination_name = creditMemoRequest.destination_name + "";
        //        // res_Obj = new CreditMemoRequestDAL(destination_name).GetCreditMemoRequest(CreditMemoRequestSearch);

        //        return Ok();

        //    }
        //    catch (Exception e)
        //    {
        //        var ErrMsg = e.Message;

        //        return StatusCode(500, ErrMsg);
        //    }
        //}
        //[HttpPost("SaveCreditMemoRequest", Name = "SaveCreditMemoRequest")]
        //public IActionResult SaveCreditMemoRequest(ReqCreditMemoRequest creditMemoRequestSave)
        //{
        //    try
        //    {
        //        if (creditMemoRequestSave.method_name == null)
        //        {
        //            return BadRequest();
        //        }

        //        List<CommonOutput> res_Obj = new List<CommonOutput>();
        //        string destination_name = creditMemoRequestSave.destination_name + "";
        //        // res_Obj = new SecondaryDAL(destination_name).SaveCreditMemoRequest(creditMemoRequestSave);
        //        return Ok();

        //    }
        //    catch (Exception e)
        //    {
        //        var ErrMsg = e.Message;

        //        return StatusCode(500, ErrMsg);
        //    }
        //}




        [HttpPost("GetCreditMemoRequest", Name = "GetCreditMemoRequest")]
        public IActionResult GetCreditMemoRequest([FromBody] object reqObject)
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


                


                string res_output = new CreditMemoSAP(res_DestinationName[0].ConnectionName).GetAllCreditMemoSAP(res_Obj[0].dealer_code.ToString(), inputParam.StartDate.ToString(), inputParam.EndDate.ToString());


                return Ok(res_output);



            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("GetOneCreditMemoRequest", Name = "GetOneCreditMemoRequest")]
        public IActionResult GetOneCreditMemoRequest([FromBody] object reqObject)
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


                string res_output = new CreditMemoSAP(res_DestinationName[0].ConnectionName).GetOneCreditMemo(inputParam.CreditMemoRequest.ToString());


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
