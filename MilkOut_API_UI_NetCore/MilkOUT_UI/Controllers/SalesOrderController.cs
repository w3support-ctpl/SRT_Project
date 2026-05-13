using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using MilkOUT_UI.DAL;


namespace MilkOUT_UI.Controllers
{
    public class SalesOrderController : Controller
    {
        public IActionResult Index()
        {
            return View("SalesOrder");
        }
    
        public IActionResult SalesOrderEdit()
        {
            return PartialView("_SalesOrderEntry");
        }

        [HttpPost]
        public IActionResult SalesOrder(ReqSalesOrder salesOrder)
        {
            try
            {
                if (salesOrder.method_name == null || salesOrder.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                salesOrder.org_id = HttpContext.Session.GetString("SessionOrgId");
                salesOrder.user_id = HttpContext.Session.GetString("SessionUserId");
                salesOrder.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(salesOrder);
                string APIEndPoint = "/v1/api/admin/salesorder/" + salesOrder.api_end_point;
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
