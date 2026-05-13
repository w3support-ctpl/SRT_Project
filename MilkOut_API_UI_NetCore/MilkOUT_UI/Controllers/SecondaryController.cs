using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using static MilkOUT_UI.Models.SecondaryModel;

namespace MilkOUT_UI.Controllers
{
    public class SecondaryController : Controller
    {
        /*----  ----    ----    ----    Retailer Order   ----    ----    ----    ----*/
        public IActionResult RetailerOrder()
        {
            return View();
        }
        public IActionResult RetailerOrderAdd()
        {
            return PartialView("_RetailerOrderEntry");
        }
        public IActionResult RetailerOrderEdit()
        {
            return PartialView("_RetailerOrderEntry");
        }
        [HttpPost]
        public IActionResult RetailerOrder(ReqRetailerOrder retailerOrder)
        {
            try
            {
                if (retailerOrder.method_name == null || retailerOrder.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                retailerOrder.org_id = HttpContext.Session.GetString("SessionOrgId");
                retailerOrder.user_id = HttpContext.Session.GetString("SessionUserId");
                retailerOrder.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(retailerOrder);
                string APIEndPoint = "/v1/api/admin/secondary/" + retailerOrder.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Dealer Stock   ----    ----    ----    ----*/
        public IActionResult DealerStock()
        {
            return View();
        }
        public IActionResult DealerStockAdd()
        {
            return PartialView("_DealerStockEntry");
        }

        public IActionResult DealerStockEdit()
        {
            return PartialView("_DealerStockEntry");
        }
        [HttpPost]
        public IActionResult DealerStock(ReqDealerStock dealerStock)
        {
            try
            {
                if (dealerStock.method_name == null || dealerStock.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                dealerStock.org_id = HttpContext.Session.GetString("SessionOrgId");
                dealerStock.user_id = HttpContext.Session.GetString("SessionUserId");
                dealerStock.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(dealerStock);
                string APIEndPoint = "/v1/api/admin/secondary/" + dealerStock.api_end_point;
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
