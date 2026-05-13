using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/secondary/")]
    [ApiController]
    public class SecondaryController : Controller
    {
        private readonly ILogger<LoginController> _logger;
        public SecondaryController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }

        /*----  ----    ----    ----    RetailerOrderOrder   ----    ----    ----    ----*/
        [HttpPost("SaveRetailerOrder", Name = "SaveRetailerOrder")]
        public IActionResult SaveRetailerOrder(ReqRetailerOrder retailerOrderSave)
        {
            try
            {
                if (retailerOrderSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = retailerOrderSave.destination_name + "";
                res_Obj = new SecondaryDAL(destination_name).SaveRetailerOrder(retailerOrderSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetRetailerOrder", Name = "GetRetailerOrder")]
        public IActionResult GetRetailerOrder(ReqRetailerOrder retailerOrderSearch)
        {
            try
            {
                if (retailerOrderSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRetailerOrder> res_Obj = new List<ResRetailerOrder>();
                string destination_name = retailerOrderSearch.destination_name + "";
                res_Obj = new SecondaryDAL(destination_name).GetRetailerOrder(retailerOrderSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("SaveRetailerOrders", Name = "SaveRetailerOrders")]
        public IActionResult SaveRetailerOrders(ReqRetailerOrder retailerOrderSave)
        {
            try
            {
                if (retailerOrderSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = retailerOrderSave.destination_name + "";
                res_Obj = new SecondaryDAL(destination_name).SaveRetailerOrders(retailerOrderSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        /*----  ----    ----    ----    DealerStockOrder   ----    ----    ----    ----*/
        [HttpPost("SaveDealerStock", Name = "SaveDealerStock")]
        public IActionResult SaveDealerStock(ReqDealerStock dealerStockSave)
        {
            try
            {
                if (dealerStockSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = dealerStockSave.destination_name + "";
                res_Obj = new SecondaryDAL(destination_name).SaveDealerStock(dealerStockSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetDealerStock", Name = "GetDealerStock")]
        public IActionResult GetDealerStock(ReqDealerStock dealerStockSearch)
        {
            try
            {
                if (dealerStockSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDealerStock> res_Obj = new List<ResDealerStock>();
                string destination_name = dealerStockSearch.destination_name + "";
                res_Obj = new SecondaryDAL(destination_name).GetDealerStock(dealerStockSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }








    }
}
