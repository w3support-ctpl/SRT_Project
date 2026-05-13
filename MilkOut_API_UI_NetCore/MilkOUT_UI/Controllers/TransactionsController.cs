using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using Newtonsoft.Json;

namespace MilkOUT_UI.Controllers
{
    public class TransactionsController : Controller
    {

        /* -----    ----    ----    Retailers Authorization    ----    ----    ----- */
        public IActionResult RetailersAuthorization()
        {
            return View();
        }
        public IActionResult RetailersAuthorizationAdd()
        {
            return PartialView("_RetailersAuthorizationEntry");
        }
        public IActionResult RetailersAuthorizationEdit()
        {
            return PartialView("_RetailersAuthorizationEntry");
        }
        [HttpPost]
        public IActionResult RetailersAuthorization(ReqRetailersAuthorization retailersAuthorization)
        {
            try
            {
                if (retailersAuthorization.method_name == null || retailersAuthorization.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                retailersAuthorization.org_id = HttpContext.Session.GetString("SessionOrgId");
                retailersAuthorization.user_id = HttpContext.Session.GetString("SessionUserId");
                retailersAuthorization.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(retailersAuthorization);
                string APIEndPoint = "/v1/api/admin/transactions/" + retailersAuthorization.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        /* -----    ----    ----    Sales User Route    ----    ----    ----- */

        public IActionResult SalesUserRoute()
        {
            return View();
        }
        public IActionResult SalesUserRouteAdd()
        {
            return PartialView("_SalesUserRouteEntry");
        }
        public IActionResult SalesUserRouteEdit()
        {
            return PartialView("_SalesUserRouteEntry");
        }
        [HttpPost]
        public IActionResult SalesUserRoute(ReqSalesUserRoute salesUserRoute)
        {
            try
            {
                if (salesUserRoute.method_name == null || salesUserRoute.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                salesUserRoute.org_id = HttpContext.Session.GetString("SessionOrgId");
                salesUserRoute.user_id = HttpContext.Session.GetString("SessionUserId");
                salesUserRoute.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(salesUserRoute);
                string APIEndPoint = "/v1/api/admin/transactions/" + salesUserRoute.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        /* -----    ----    ----    Targets    ----    ----    ----- */

        public IActionResult Targets()
        {
            return View();
        }
        public IActionResult TargetsAdd()
        {
            return PartialView("_TargetsEntry");
        }
        public IActionResult TargetsEdit()
        {
            return PartialView("_TargetsEntry");
        }
        public IActionResult TargetsEntry()
        {
            return PartialView("_TargetsEntrys");
        }
        [HttpPost]
        public IActionResult Targets(ReqTargets targets)
        {
            try
            {
                if (targets.method_name == null || targets.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                targets.org_id = HttpContext.Session.GetString("SessionOrgId");
                targets.user_id = HttpContext.Session.GetString("SessionUserId");
                targets.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(targets);
                string APIEndPoint = "/v1/api/admin/transactions/" + targets.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }








        /* -----    ----    ----    Complaints    ----    ----    ----- */

        public IActionResult Complaints()
        {
            return View();
        }
        public IActionResult ComplaintsAdd()
        {
            return PartialView("_ComplaintsEntry");
        }
        public IActionResult ComplaintsEdit()
        {
            return PartialView("_ComplaintsEntry");
        }
        [HttpPost]
        public IActionResult Complaints(ReqComplaints complaints)
        {
            try
            {
                if (complaints.method_name == null || complaints.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                complaints.org_id = HttpContext.Session.GetString("SessionOrgId");
                complaints.user_id = HttpContext.Session.GetString("SessionUserId");
                complaints.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(complaints);
                string APIEndPoint = "/v1/api/admin/transactions/" + complaints.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        /* -----    ----    ----    CrateReceived    ----    ----    ----- */

        public IActionResult CrateReceived()
        {
            return View();
        }
        public IActionResult CrateReceivedAdd()
        {
            return PartialView("_CrateReceivedEntry");
        }
        public IActionResult CrateReceivedEdit()
        {
            return PartialView("_CrateReceivedEntry");
        }
        [HttpPost]
        public IActionResult CrateReceived(ReqCrateReceived crateReceived)
        {
            try
            {
                if (crateReceived.method_name == null || crateReceived.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                crateReceived.org_id = HttpContext.Session.GetString("SessionOrgId");
                crateReceived.user_id = HttpContext.Session.GetString("SessionUserId");
                crateReceived.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(crateReceived);
                string APIEndPoint = "/v1/api/admin/transactions/" + crateReceived.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }








        /* -----    ----    ----    Crate Dispatched to Dealer    ----    ----    ----- */

        public IActionResult CrateDispatched()
        {
            return View();
        }
        public IActionResult CrateDispatchedAdd()
        {
            return PartialView("_CrateDispatchedEntry");
        }
        public IActionResult CrateDispatchedEdit()
        {
            return PartialView("_CrateDispatchedEntry");
        }
        [HttpPost]
        public IActionResult CrateDispatched(ReqCrateDispatched crateDispatched)
        {
            try
            {
                if (crateDispatched.method_name == null || crateDispatched.api_end_point == null)
                {
                    return BadRequest();
                }


                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                crateDispatched.org_id = HttpContext.Session.GetString("SessionOrgId");
                crateDispatched.user_id = HttpContext.Session.GetString("SessionUserId");
                crateDispatched.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(crateDispatched);
                string APIEndPoint = "/v1/api/admin/transactions/" + crateDispatched.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }












        public IActionResult CrateApprove()
        {
            return View();
        }
        public IActionResult CrateApproveEdit()
        {
            return PartialView("_CrateApproveEntry");
        }
        [HttpPost]
        public IActionResult CrateApprove(ReqCrateApprove CrateApprove)
        {
            try
            {
                if (CrateApprove.method_name == null || CrateApprove.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                CrateApprove.org_id = HttpContext.Session.GetString("SessionOrgId");
                CrateApprove.user_id = HttpContext.Session.GetString("SessionUserId");
                CrateApprove.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(CrateApprove);
                string APIEndPoint = "/v1/api/admin/transactions/" + CrateApprove.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }








        /* -----    ----    ----    Notification    ----    ----    ----- */

        public IActionResult Notification()
        {
            return View();
        }
        public IActionResult NotificationAdd()
        {
            return PartialView("_NotificationEntry");
        }
        public IActionResult NotificationEdit()
        {
            return PartialView("_NotificationEntry");
        }
        [HttpPost]
        public IActionResult Notification(ReqNotification notification)
        {
            try
            {
                if (notification.method_name == null || notification.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                notification.org_id = HttpContext.Session.GetString("SessionOrgId");
                notification.user_id = HttpContext.Session.GetString("SessionUserId");
                notification.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(notification);
                string APIEndPoint = "/v1/api/admin/transactions/" + notification.api_end_point;
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
