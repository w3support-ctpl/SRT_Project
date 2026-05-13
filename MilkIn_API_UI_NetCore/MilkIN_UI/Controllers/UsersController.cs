using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.DAL;
using MilkIN_UI.Filters;
using MilkIN_UI.Models;
using Newtonsoft.Json;
using System.Text.Json;

namespace MilkIN_UI.Controllers
{
	public class UsersController : Controller
	{
        [LoginAuthFilter("M003", "Display")]
        public IActionResult Farmer()
		{
			return View();
		}

        [LoginAuthFilter("M003", "Add")]
        public IActionResult FarmerAdd()
		{
			return PartialView("_FarmerEntry");
		}

        [LoginAuthFilter("M003", "Display")]
        public IActionResult FarmerEdit()
		{
			return PartialView("_FarmerEntry");
		}

        // Get & Save Farmer
        [HttpPost]
        public IActionResult Farmer(ReqFarmer farmer)
        {
            try
            {
                if (farmer.method_name == null || farmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmer.user_id = HttpContext.Session.GetString("SessionUserId");
                farmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(farmer);
                string APIEndPoint = "/v1/api/admin/users/" + farmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M004", "Display")]
        public IActionResult Agent()
		{
			return View();
		}

        [LoginAuthFilter("M004", "Add")]
        public IActionResult AgentAdd()
		{
			return PartialView("_AgentEntry");
		}

        [LoginAuthFilter("M004", "Display")]
        public IActionResult AgentEdit()
		{
			return PartialView("_AgentEntry");
		}

        // Get & Save Agent
        [HttpPost]
        public IActionResult Agent(ReqAgent agent)
        {
            try
            {
                if (agent.method_name == null || agent.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                agent.org_id = HttpContext.Session.GetString("SessionOrgId");
                agent.user_id = HttpContext.Session.GetString("SessionUserId");
                agent.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(agent);
                string APIEndPoint = "/v1/api/admin/users/" + agent.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M005", "Display")]
        public IActionResult Driver()
		{
			return View();
		}

        [LoginAuthFilter("M005", "Add")]
        public IActionResult DriverAdd()
		{
			return PartialView("_DriverEntry");
		}

        [LoginAuthFilter("M005", "Display")]
        public IActionResult DriverEdit()
		{
			return PartialView("_DriverEntry");
		}

        // Get & Save Driver
        [HttpPost]
        public IActionResult Driver(ReqDriver driver)
        {
            try
            {
                if (driver.method_name == null || driver.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                driver.org_id = HttpContext.Session.GetString("SessionOrgId");
                driver.user_id = HttpContext.Session.GetString("SessionUserId");
                driver.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(driver);
                string APIEndPoint = "/v1/api/admin/users/" + driver.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M006", "Display")]
        public IActionResult Chemist()
		{
			return View();
		}

        [LoginAuthFilter("M006", "Add")]
        public IActionResult ChemistAdd()
		{
			return PartialView("_ChemistEntry");
		}

        [LoginAuthFilter("M006", "Display")]
        public IActionResult ChemistEdit()
		{
			return PartialView("_ChemistEntry");
		}

        // Get & Save Chemist
        [HttpPost]
        public IActionResult Chemist(ReqChemist chemist)
        {
            try
            {
                if (chemist.method_name == null || chemist.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                chemist.org_id = HttpContext.Session.GetString("SessionOrgId");
                chemist.user_id = HttpContext.Session.GetString("SessionUserId");
                chemist.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(chemist);
                string APIEndPoint = "/v1/api/admin/users/" + chemist.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M007", "Display")]
        public IActionResult User()
        {
            return View();
        }

        [LoginAuthFilter("M007", "Add")]
        public IActionResult UserAdd()
        {
            return PartialView("_UserEntry");
        }

        [LoginAuthFilter("M007", "Display")]
        public IActionResult UserEdit()
        {
            return PartialView("_UserEntry");
        }

 
        // Get & Save User
        [HttpPost]
        public IActionResult User(ReqUser user)
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
                string APIEndPoint = "/v1/api/admin/users/" + user.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost]
        public IActionResult ChangePassword(ReqChangePassword reqObj)
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
                string APIEndPoint = "/v1/api/admin/users/" + reqObj.api_end_point;
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
