using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using System.Text.Json;

namespace MilkOUT_UI.Controllers
{
    public class AccountStatementController : Controller
    {
      
        public IActionResult Index()
        {
            return View("AccountStatement");
        }

        
        public IActionResult AccountStatementAdd()
        {
           
            return PartialView("_AccountStatementEntry");
        }

        [HttpPost]
        public IActionResult AccountStatement(ReqAccountStatement accountStatement)
        {
            try
            {
                if (accountStatement.method_name == null || accountStatement.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                accountStatement.org_id = HttpContext.Session.GetString("SessionOrgId");
                accountStatement.user_id = HttpContext.Session.GetString("SessionUserId");
                accountStatement.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(accountStatement);
                string APIEndPoint = "/v1/api/admin/accountStatement/" + accountStatement.api_end_point;
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
