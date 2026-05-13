using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using MilkOUT_UI.DAL;

namespace MilkOUT_UI.Controllers
{
    public class DeliveryController : Controller
    {

        public IActionResult Index()
        {
            return View("Delivery");
        }
        public IActionResult ShowDelivery()
        {
            return PartialView("_DeliveryEntry");
        }

        [HttpPost]
        public IActionResult Delivery(ReqDelivery delivery)
        {
            try
            {
                if (delivery.method_name == null || delivery.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                delivery.org_id = HttpContext.Session.GetString("SessionOrgId");
                delivery.user_id = HttpContext.Session.GetString("SessionUserId");
                delivery.user_name = HttpContext.Session.GetString("SessionUserName");
                string res_Str = JsonConvert.SerializeObject(delivery);
                string APIEndPoint = "/v1/api/admin/delivery/" + delivery.api_end_point;
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
