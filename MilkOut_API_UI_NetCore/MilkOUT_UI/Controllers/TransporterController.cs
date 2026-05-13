using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using MilkOUT_UI.DAL;

namespace MilkOUT_UI.Controllers
{
    public class TransporterController : Controller
    {
        public IActionResult Route()
        {
            return View();
        }

        public IActionResult RouteAdd()
        {
            return PartialView("_RouteEntry");
        }

        public IActionResult RouteEdit()
        {
            return PartialView("_RouteEntry");
        }
        [HttpPost]
        public IActionResult Route(ReqRoute route)
        {
            try
            {
                if (route.method_name == null || route.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                route.org_id = HttpContext.Session.GetString("SessionOrgId");
                route.user_id = HttpContext.Session.GetString("SessionUserId");
                route.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(route);
                string APIEndPoint = "/v1/api/admin/transporter/" + route.api_end_point;
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
