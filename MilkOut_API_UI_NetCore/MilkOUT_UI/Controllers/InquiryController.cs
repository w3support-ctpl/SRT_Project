using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using MilkOUT_UI.DAL;

namespace MilkOUT_UI.Controllers
{
    public class InquiryController : Controller
    {
        public IActionResult Index()
        {
            return View("Inquiry");
        }
        public IActionResult Inquiry()
        {
            return View();
        }
        public IActionResult InquiryEntry()
        {
            return PartialView("_InquiryEntry");
        }
        public IActionResult InquiryViewEntry()
        {
            return PartialView("_InquiryViewEntry");
        }
        [HttpPost]
        public IActionResult Inquiry(ReqInquiry inquiry)
        {
            try
            {
                if (inquiry.method_name == null || inquiry.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                inquiry.org_id = HttpContext.Session.GetString("SessionOrgId");
                inquiry.user_id = HttpContext.Session.GetString("SessionUserId");
                inquiry.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(inquiry);
                string APIEndPoint = "/v1/api/admin/inquiry/" + inquiry.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
    }
}
