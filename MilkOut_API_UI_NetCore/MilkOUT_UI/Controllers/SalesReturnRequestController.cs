using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using Newtonsoft.Json;

namespace MilkOUT_UI.Controllers
{
    public class SalesReturnRequestController : Controller
    {
        public IActionResult Index()
        {
            return View("SalesReturnRequest");
        }
        public IActionResult SalesReturnRequestAdd()
        {
            return PartialView("_SalesReturnRequestEntry");
        }
        public IActionResult SalesReturnRequestEdit()
        {
            return PartialView("_SalesReturnRequestEntry");
        }

        [HttpPost]
        public IActionResult SalesReturn(ReqSalesReturn salesReturn)
        {
            try
            {
                if (salesReturn.method_name == null || salesReturn.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                salesReturn.org_id = HttpContext.Session.GetString("SessionOrgId");
                salesReturn.user_id = HttpContext.Session.GetString("SessionUserId");
                salesReturn.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(salesReturn);
                string APIEndPoint = "/v1/api/admin/salesReturn/" + salesReturn.api_end_point;
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
