using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/transactions/")]
    [ApiController]
    public class TransactionsController : Controller
    {
        private readonly ILogger<LoginController> _logger;
        public TransactionsController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }

        /*----  ----    ----    ----    RetailersAuthorization   ----    ----    ----    ----*/
        [HttpPost("SaveRetailersAuthorization", Name = "SaveRetailersAuthorization")]
        public IActionResult SaveRetailersAuthorization(ReqRetailersAuthorization retailersAuthorizationSave)
        {
            try
            {
                if (retailersAuthorizationSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = retailersAuthorizationSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveRetailersAuthorization(retailersAuthorizationSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetRetailersAuthorization", Name = "GetRetailersAuthorization")]
        public IActionResult GetRetailersAuthorization(ReqRetailersAuthorization retailersAuthorizationSearch)
        {
            try
            {
                if (retailersAuthorizationSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRetailersAuthorization> res_Obj = new List<ResRetailersAuthorization>();
                string destination_name = retailersAuthorizationSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetRetailersAuthorization(retailersAuthorizationSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        /*----  ----    ----    ----    SalesUserRoute   ----    ----    ----    ----*/
        [HttpPost("SaveSalesUserRoute", Name = "SaveSalesUserRoute")]
        public IActionResult SaveSalesUserRoute(ReqSalesUserRoute salesUserRouteSave)
        {
            try
            {
                if (salesUserRouteSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = salesUserRouteSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveSalesUserRoute(salesUserRouteSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetSalesUserRoute", Name = "GetSalesUserRoute")]
        public IActionResult GetSalesUserRoute(ReqSalesUserRoute salesUserRouteSearch)
        {
            try
            {
                if (salesUserRouteSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResSalesUserRoute> res_Obj = new List<ResSalesUserRoute>();
                string destination_name = salesUserRouteSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetSalesUserRoute(salesUserRouteSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Targets   ----    ----    ----    ----*/
        [HttpPost("SaveTargets", Name = "SaveTargets")]
        public IActionResult SaveTargets(ReqTargets targetsSave)
        {
            try
            {
                if (targetsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = targetsSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveTargets(targetsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetTargets", Name = "GetTargets")]
        public IActionResult GetTargets(ReqTargets targetsSearch)
        {
            try
            {
                if (targetsSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResTargets> res_Obj = new List<ResTargets>();
                string destination_name = targetsSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetTargets(targetsSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        /*----  ----    ----    ----    Complaints   ----    ----    ----    ----*/
        [HttpPost("SaveComplaints", Name = "SaveComplaints")]
        public IActionResult SaveComplaints(ReqComplaints complaintsSave)
        {
            try
            {
                if (complaintsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = complaintsSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveComplaints(complaintsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("SaveComplaintsRemarks", Name = "SaveComplaintsRemarks")]
        public IActionResult SaveComplaintsRemarks(ReqComplaints complaintsSave)
        {
            try
            {
                if (complaintsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = complaintsSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveComplaintsRemarks(complaintsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

         [HttpPost("SaveComplaintsStatus", Name = "SaveComplaintsStatus")]
        public IActionResult SaveComplaintsStatus(ReqComplaints complaintsSave)
        {
            try
            {
                if (complaintsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = complaintsSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveComplaintsStatus(complaintsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetComplaints", Name = "GetComplaints")]
        public IActionResult GetComplaints(ReqComplaints complaintsSearch)
        {
            try
            {
                if (complaintsSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResComplaints> res_Obj = new List<ResComplaints>();
                string destination_name = complaintsSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetComplaints(complaintsSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        /*----  ----    ----    ----    Crate Received   ----    ----    ----    ----*/
        [HttpPost("SaveCrateReceived", Name = "SaveCrateReceived")]
        public IActionResult SaveCrateReceived(ReqCrateReceived crateReceivedSave)
        {
            try
            {
                if (crateReceivedSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = crateReceivedSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveCrateReceived(crateReceivedSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetCrateReceived", Name = "GetCrateReceived")]
        public IActionResult GetCrateReceived(ReqCrateReceived crateReceivedSearch)
        {
            try
            {
                if (crateReceivedSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResCrateReceived> res_Obj = new List<ResCrateReceived>();
                string destination_name = crateReceivedSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetCrateReceived(crateReceivedSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("SaveGoodsInwardPosting", Name = "SaveGoodsInwardPosting")]
        public IActionResult SaveGoodsInwardPosting(ReqCrateReceived GoodsInwardPostingSave)
        {
            try
            {
                if (GoodsInwardPostingSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = GoodsInwardPostingSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveGoodsInwardPosting(GoodsInwardPostingSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        /*----  ----    ----    ----    Crate Received   ----    ----    ----    ----*/
        [HttpPost("SaveCrateDispatched", Name = "SaveCrateDispatched")]
        public IActionResult SaveCrateDispatched(ReqCrateDispatched crateDispatchedSave)
        {
            try
            {
                if (crateDispatchedSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = crateDispatchedSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveCrateDispatched(crateDispatchedSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetCrateDispatched", Name = "GetCrateDispatched")]
        public IActionResult GetCrateDispatched(ReqCrateDispatched crateDispatchedSearch)
        {
            try
            {
                if (crateDispatchedSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResCrateDispatched> res_Obj = new List<ResCrateDispatched>();
                string destination_name = crateDispatchedSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetCrateDispatched(crateDispatchedSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Notification   ----    ----    ----    ----*/
        [HttpPost("SaveNotification", Name = "SaveNotification")]
        public IActionResult SaveNotification(ReqNotification notificationSave)
        {
            try
            {
                if (notificationSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = notificationSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveNotification(notificationSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetNotification", Name = "GetNotification")]
        public IActionResult GetNotification(ReqNotification notificationSearch)
        {
            try
            {
                if (notificationSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResNotification> res_Obj = new List<ResNotification>();
                string destination_name = notificationSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetNotification(notificationSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }









        [HttpPost("GetCrateApproval", Name = "GetCrateApproval")]
        public IActionResult GetCrateApproval(ReqCrateApprove CrateApprove)
        {
            try
            {
                if (CrateApprove.method_name == null)
                {
                    return BadRequest();
                }

                List<ResCrateReceived> res_Obj = new List<ResCrateReceived>();
                string destination_name = CrateApprove.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetCrateApproval(CrateApprove);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        [HttpPost("SaveCrateApproval", Name = "SaveCrateApproval")]
        public IActionResult SaveCrateApproval(ReqCrateApprove CrateApprove)
        {
            try
            {
                if (CrateApprove.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = CrateApprove.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveCrateApproval(CrateApprove);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






                /*----  ----    ----    ----    Targets   ----    ----    ----    ----*/
        [HttpPost("SaveTarget", Name = "SaveTarget")]
        public IActionResult SaveTarget(ReqTargets targetsSave)
        {
            try
            {
                if (targetsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = targetsSave.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).SaveTarget(targetsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetTarget", Name = "GetTarget")]
        public IActionResult GetTarget(ReqTargets targetsSearch)
        {
            try
            {
                if (targetsSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResTargets> res_Obj = new List<ResTargets>();
                string destination_name = targetsSearch.destination_name + "";
                res_Obj = new TransactionsDAL(destination_name).GetTarget(targetsSearch);

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
