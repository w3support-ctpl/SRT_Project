using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using Newtonsoft.Json;
using System.Text.Json;


namespace MilkOUT_UI.Controllers
{
    public class MastersController : Controller
    {

        /*----  ----    ----    ----    Retailer   ----    ----    ----    ----*/
        public IActionResult Retailer()
        {
            return View();
        }
        public IActionResult RetailerAdd()
        {
            return PartialView("_RetailerEntry");
        }
        public IActionResult RetailerEdit()
        {
            return PartialView("_RetailerEntry");
        }
        [HttpPost]
        public IActionResult Retailer(ReqRetailer retailer)
        {
            try
            {
                if (retailer.method_name == null|| retailer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                retailer.org_id = HttpContext.Session.GetString("SessionOrgId");
                retailer.user_id = HttpContext.Session.GetString("SessionUserId");
                retailer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(retailer);
                string APIEndPoint = "/v1/api/admin/master/" + retailer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        public IActionResult DownloadDealer(ReqDownloadDealer DownloadDealer)
        {
            try
            {
                if (DownloadDealer.method_name == null || DownloadDealer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                DownloadDealer.org_id = HttpContext.Session.GetString("SessionOrgId");

                string res_Str = JsonConvert.SerializeObject(DownloadDealer);
                string APIEndPoint = "v1/api/admin/sapmaster/" + DownloadDealer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        /*----  ----    ----    ----    Dealer   ----    ----    ----    ----*/
        public IActionResult Dealer()
        {
            return View();
        }
        public IActionResult DealerAdd()
        {
            return PartialView("_DealerEntry");
        }
        public IActionResult DealerEdit()
        {
            return PartialView("_DealerEntry");
        }
        [HttpPost]
        public IActionResult Dealer(ReqDealer dealer)
        {
            try
            {
                if (dealer.method_name == null || dealer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                dealer.org_id = HttpContext.Session.GetString("SessionOrgId");
                dealer.user_id = HttpContext.Session.GetString("SessionUserId");
                dealer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(dealer);
                string APIEndPoint = "/v1/api/admin/master/" + dealer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        /*----  ----    ----    ----    Sales Area   ----    ----    ----    ----*/

        public IActionResult SalesGroup()
        {
            return View();
        }
        public IActionResult SalesGroupAdd()
        {
            return PartialView("_SalesGroupEntry");
        }
        public IActionResult SalesGroupEdit()
        {
            return PartialView("_SalesGroupEntry");
        }
        [HttpPost]
        public IActionResult SalesGroup(ReqSalesGroup salesArea)
        {
            try
            {
                if (salesArea.method_name == null || salesArea.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                salesArea.org_id = HttpContext.Session.GetString("SessionOrgId");
                salesArea.user_id = HttpContext.Session.GetString("SessionUserId");
 
                string res_Str = JsonConvert.SerializeObject(salesArea);
                string APIEndPoint = "/v1/api/admin/master/" + salesArea.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Sales User   ----    ----    ----    ----*/

        public IActionResult SalesUser()
        {
            return View();
        }
        public IActionResult SalesUserAdd()
        {
            return PartialView("_SalesUserEntry");
        }
        public IActionResult SalesUserEdit()
        {
            return PartialView("_SalesUserEntry");
        }
        [HttpPost]
        public IActionResult SalesUser(ReqSalesUser salesUser)
        {
            try
            {
                if (salesUser.method_name == null || salesUser.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                salesUser.org_id = HttpContext.Session.GetString("SessionOrgId");
                salesUser.user_id = HttpContext.Session.GetString("SessionUserId");
                salesUser.user_name = HttpContext.Session.GetString("SessionUserName");


                string res_Str = JsonConvert.SerializeObject(salesUser);
                string APIEndPoint = "/v1/api/admin/master/" + salesUser.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        /*----  ----    ----    ----    Complaint Type   ----    ----    ----    ----*/

        public IActionResult ComplaintType()
        {
            return View();
        }
        public IActionResult ComplaintTypeAdd()
        {
            return PartialView("_ComplaintTypeEntry");
        }
        public IActionResult ComplaintTypeEdit()
        {
            return PartialView("_ComplaintTypeEntry");
        }
        [HttpPost]
        public IActionResult ComplaintType(ReqComplaintType complaintType)
        {
            try
            {
                if (complaintType.method_name == null || complaintType.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                complaintType.org_id = HttpContext.Session.GetString("SessionOrgId");
                complaintType.user_id = HttpContext.Session.GetString("SessionUserId");
                complaintType.user_name = HttpContext.Session.GetString("SessionUserName");


                string res_Str = JsonConvert.SerializeObject(complaintType);
                string APIEndPoint = "/v1/api/admin/master/" + complaintType.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        /*----  ----    ----    ----    Product   ----    ----    ----    ----*/
        public IActionResult Product()
        {
            return View();
        }
        [HttpPost]
        public IActionResult Product(ReqProduct product)
        {
            try
            {
                if (product.method_name == null || product.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                product.org_id = HttpContext.Session.GetString("SessionOrgId");
                product.user_id = HttpContext.Session.GetString("SessionUserId");
                product.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(product);
                string APIEndPoint = "/v1/api/admin/master/" + product.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }





        public IActionResult ProductUOM(Reqproductuom product)
        {
            try
            {
                if (product.method_name == null || product.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                product.org_id = HttpContext.Session.GetString("SessionOrgId");

                string res_Str = JsonConvert.SerializeObject(product);
                string APIEndPoint = "/v1/api/admin/master/" + product.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }



        

       public IActionResult DownloadRoute([FromBody] object reqObject)
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
                string APIEndPoint = "v1/api/admin/master/" + inputParam.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        //public IActionResult ProductUOM([FromBody] object reqObject)
        //{
        //    try
        //    {
        //        if (reqObject == null)
        //        {
        //            return BadRequest();
        //        }


        //        dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
        //        string destination_name = inputParam.Destination_Name;
        //        ResAPICommonOutput res_Obj = new ResAPICommonOutput();

        //        inputParam.org_id = HttpContext.Session.GetString("SessionOrgId");

        //        string res_Str = JsonConvert.SerializeObject(inputParam);
        //        string APIEndPoint = "/v1/api/admin/master/" + inputParam.api_end_point;
        //        string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
        //        return Ok(response);

        //    }
        //    catch (Exception e)
        //    {
        //        var ErrMsg = e.Message;

        //        return StatusCode(500, ErrMsg);
        //    }
        //}








        /*----  ----    ----    ----    Role   ----    ----    ----    ----*/
        public IActionResult Role()
        {
            return View();
        }

        public IActionResult RoleAdd()
        {
            return PartialView("_RoleEntry");
        }

        public IActionResult RoleEdit()
        {
            return PartialView("_RoleEntry");
        }

        [HttpPost]
        public IActionResult Role(ReqRole role)
        {
            try
            {
                if (role.method_name == null || role.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                role.org_id = HttpContext.Session.GetString("SessionOrgId");
                role.user_id = HttpContext.Session.GetString("SessionUserId");
                role.user_name = HttpContext.Session.GetString("SessionUserName");
                role.application_id = "MO";

                string res_Str = JsonConvert.SerializeObject(role);
                string APIEndPoint = "/v1/api/admin/master/" + role.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        /*----  ----    ----    ----    Office User   ----    ----    ----    ----*/

        public IActionResult OfficeUsers()
        {
            return View();
        }

        public IActionResult OfficeUsersAdd()
        {
            return PartialView("_OfficeUsersEntry");
        }

        public IActionResult OfficeUsersEdit()
        {
            return PartialView("_OfficeUsersEntry");
        }


        // Get & Save User
        [HttpPost]
        public IActionResult OfficeUsers(ReqOfficeUsers user)
        {
            try
            {
                if (user.method_name == null || user.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                user.org_id = HttpContext.Session.GetString("SessionOrgId");
                user.user_id = HttpContext.Session.GetString("SessionUserId");
                user.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(user);
                string APIEndPoint = "/v1/api/admin/master/" + user.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        public IActionResult MasterSync()
        {
            return View();
        }
        [HttpPost]
        public IActionResult MasterSync([FromBody] object reqObject)
        {

            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }


                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;

                inputParam.org_id = HttpContext.Session.GetString("SessionOrgId");

                string res_Str = JsonConvert.SerializeObject(inputParam);
                string APIEndPoint = "v1/api/admin/master/" + inputParam.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }


        }


        /*----  ----    ----    ----    Route   ----    ----    ----    ----*/

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
        public IActionResult Route(ReqRouteSU Route)
        {
            try
            {
                if (Route.method_name == null || Route.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                Route.org_id = HttpContext.Session.GetString("SessionOrgId");
                Route.user_id = HttpContext.Session.GetString("SessionUserId");
                Route.user_name = HttpContext.Session.GetString("SessionUserName");


                string res_Str = JsonConvert.SerializeObject(Route);
                string APIEndPoint = "/v1/api/admin/master/" + Route.api_end_point;
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
