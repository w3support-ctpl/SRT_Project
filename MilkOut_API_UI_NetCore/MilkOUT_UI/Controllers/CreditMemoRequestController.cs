using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using MilkOUT_UI.DAL;

namespace MilkOUT_UI.Controllers
{
    public class CreditMemoRequestController : Controller
    {
        public IActionResult Index()
        {
            return View("CreditMemoRequest");
        }

        public IActionResult CreditMemoRequestView()
        {
            return PartialView("_CreditMemoRequestEntry");
        }

        [HttpPost]

        public IActionResult CreditMemoRequest([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }


                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;
                ResAPICommonOutput res_Obj = new ResAPICommonOutput();

                inputParam.org_id = HttpContext.Session.GetString("SessionOrgId");

                string res_Str = JsonConvert.SerializeObject(inputParam);
                string APIEndPoint = "/v1/api/admin/creditMemoRequest/" + inputParam.api_end_point;
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
