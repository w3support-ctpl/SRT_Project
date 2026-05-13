using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/inquiry/")]
    [ApiController]
    public class InquiryController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public InquiryController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }
        
        
        [HttpPost("GetInquiry", Name = "GetInquiry")]
        public IActionResult GetInquiry(ReqInquiry inquirySearch)
        {
            try
            {
                if (inquirySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInquiry> res_Obj = new List<ResInquiry>();
                string destination_name = inquirySearch.destination_name + "";
                res_Obj = new InquiryDAL(destination_name).GetInquiry(inquirySearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("SaveInquiry", Name = "SaveInquiry")]
        public IActionResult SaveInquiry(ReqInquiry inquirySave)
        {
            try
            {
                if (inquirySave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = inquirySave.destination_name + "";
                res_Obj = new InquiryDAL(destination_name).SaveInquiry(inquirySave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }


        [HttpPost("GetInquiryProduct", Name = "GetInquiryProduct")]
        public IActionResult GetInquiryProduct(ReqInquiry inquirySearch)
        {
            try
            {
                if (inquirySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResProductMaster> res_Obj = new List<ResProductMaster>();
                string destination_name = inquirySearch.destination_name + "";
                res_Obj = new InquiryDAL(destination_name).GetInquiryProduct(inquirySearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





    }
}
