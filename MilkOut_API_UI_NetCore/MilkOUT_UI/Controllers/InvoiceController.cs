using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using System.Text.Json;

namespace MilkOUT_UI.Controllers
{
    public class InvoiceController : Controller
    {
      
        public IActionResult Index()
        {
            return View("Invoice");
        }

        
        public IActionResult InvoiceAdd()
        {
           
            return PartialView("_InvoiceEntry");
        }

        public IActionResult InvoiceSalesReturn()
        {

            return PartialView("_InvoiceSalesReturn");
        }







        [HttpPost]
        public IActionResult Invoice(ReqInvoice invoice)
        {
            try
            {
                if (invoice.method_name == null || invoice.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoice.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoice.user_id = HttpContext.Session.GetString("SessionUserId");
                invoice.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoice);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoice.api_end_point;
                var response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        [HttpPost]
        public IActionResult CustomerReturn(ReqNewHeader invoice)
        {
            try
            {
                if (invoice.method_name == null || invoice.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoice.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoice.user_id = HttpContext.Session.GetString("SessionUserId");
                invoice.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoice);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoice.api_end_point;
                var response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
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
                string APIEndPoint = "/v1/api/admin/invoice/" + inputParam.api_end_point;
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
