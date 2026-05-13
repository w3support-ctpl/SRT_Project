using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.Models;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using Newtonsoft.Json;


namespace MilkOUT_UI.Controllers
{
    public class ReportController : Controller
    {
        public IActionResult CrateRegister()
        {

            return View();
        }


        public IActionResult CrateRegisterReport()
        {
            return PartialView("_CrateRegister");
        }

        [HttpPost]
        public IActionResult GetDealerStockReport(ReqDealerStockReport reqObj)
        {
            try
            {
                if (reqObj.method_name == null || reqObj.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                reqObj.org_id = HttpContext.Session.GetString("SessionOrgId");
                reqObj.user_id = HttpContext.Session.GetString("SessionUserId");
                reqObj.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(reqObj);
                string APIEndPoint = "/v1/api/admin/report/" + reqObj.api_end_point;
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
