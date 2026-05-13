using Dapper;
using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/payment/")]
    [ApiController]
    public class PaymentController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public PaymentController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }


        [HttpPost("GetPaymentTerms", Name = "GetPaymentTerms")]
        public IActionResult GetPaymentTerms(ReqPayment paymentTerms)
        {
            try
            {
                if (paymentTerms.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = paymentTerms.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = paymentTerms.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new PaymentTermsSAP(res_DestinationName[0].ConnectionName).GetPaymentTerms();
                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        
        [HttpPost("GetPayment", Name = "GetPayment")]
        public IActionResult GetPayment(ReqPayment paymentTerms)
        {
            try
            {
                if (paymentTerms.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = paymentTerms.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = paymentTerms.org_id;
                req_Obj.dealer_id = paymentTerms.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = paymentTerms.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_Output = new PaymentSAP(res_DestinationName[0].ConnectionName).GetAllPayment(paymentTerms.start_date, paymentTerms.end_date, res_Obj[0].dealer_code);


                return Ok(res_Output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetPaymentPDF", Name = "GetPaymentPDF")]
        public IActionResult GetPaymentPDF(ReqPayment paymentTerms)
        {
            try
            {
                if (paymentTerms.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = paymentTerms.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = paymentTerms.org_id;
                req_Obj.dealer_id = paymentTerms.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = paymentTerms.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_Output = new PaymentSAP(res_DestinationName[0].ConnectionName).GetAccountStatementSAP(paymentTerms.start_date, paymentTerms.end_date, res_Obj[0].dealer_code);


                return Ok(res_Output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("GetAccountStatementSAPPDF", Name = "GetAccountStatementSAPPDF")]
        public IActionResult GetAccountStatementSAPPDF(ReqPayment paymentTerms)
        {
            try
            {
                if (paymentTerms.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = paymentTerms.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = paymentTerms.org_id;
                req_Obj.dealer_id = paymentTerms.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = paymentTerms.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                string res_Output = new PaymentSAP(res_DestinationName[0].ConnectionName).GetAccountStatementSAPPDF(paymentTerms.start_date, paymentTerms.end_date, res_Obj[0].dealer_code);


                // return Ok(res_Output);


                 


                        return Ok(new
                                    {
                                        status = 200,
                                        result_description = res_Output
                                    });

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



    }
}
