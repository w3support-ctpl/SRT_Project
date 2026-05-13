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
    [Route("v1/api/admin/quotation/")]
    [ApiController]
    public class QuotationController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public QuotationController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }


        [HttpPost("GetQuotation", Name = "GetQuotation")]
        public IActionResult GetQuotation(ReqQuotation quotation)
        {
            try
            {
                if (quotation.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();



                string destination_name = quotation.destination_name + "";


                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = quotation.org_id;
                req_Obj.dealer_id = quotation.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = quotation.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new QuotationSAP(res_DestinationName[0].ConnectionName).GetAllQuotation(res_Obj[0].dealer_code, quotation.formattedStartDate, quotation.formattedEndDate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        [HttpPost("GetOneQuotation", Name = "GetOneQuotation")]
        public IActionResult GetOneQuotation(ReqQuotation quotation)
        {
            try
            {
                if (quotation.method_name == null)
                {
                    return BadRequest();
                }



                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = quotation.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = quotation.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new QuotationSAP(res_DestinationName[0].ConnectionName).GetOneQuotation(quotation.quotation_id);

                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("GetOneQuotationPDF", Name = "GetOneQuotationPDF")]
        public IActionResult GetOneQuotationPDF(ReqQuotation quotation)
        {
            try
            {
                if (quotation.method_name == null)
                {
                    return BadRequest();
                }



                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();
                string destination_name = quotation.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = quotation.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new QuotationSAP(res_DestinationName[0].ConnectionName).GetQuotationPDF(quotation.quotation_id);

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
