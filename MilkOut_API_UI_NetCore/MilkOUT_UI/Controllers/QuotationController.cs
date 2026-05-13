using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using MilkOUT_UI.DAL;


namespace MilkOUT_UI.Controllers
{
    public class QuotationController : Controller
    {
        public IActionResult Index()
        {
            return View("Quotation");
        }
        public IActionResult ShowOptionQuotation()
        {
            return PartialView("_QuotationEntry");
        }
        [HttpPost]
        public IActionResult Quotation(ReqQuotation quotation)
        {
            try
            {
                if (quotation.method_name == null || quotation.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                quotation.org_id = HttpContext.Session.GetString("SessionOrgId");
                quotation.user_id = HttpContext.Session.GetString("SessionUserId");
                quotation.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(quotation);
                string APIEndPoint = "/v1/api/admin/quotation/" + quotation.api_end_point;
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
