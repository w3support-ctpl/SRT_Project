using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using System.Text.Json;

namespace MilkOUT_UI.Controllers
{
	public class UsersController : Controller
	{
		public IActionResult Farmer()
		{
			return View();
		}

		public IActionResult FarmerAdd()
		{
			return PartialView("_FarmerEntry");
		}

		public IActionResult FarmerEdit()
		{
			return PartialView("_FarmerEntry");
		}

		public IActionResult Agent()
		{
			return View();
		}

		public IActionResult AgentAdd()
		{
			return PartialView("_AgentEntry");
		}

		public IActionResult AgentEdit()
		{
			return PartialView("_AgentEntry");
		}

		public IActionResult Driver()
		{
			return View();
		}

		public IActionResult DriverAdd()
		{
			return PartialView("_DriverEntry");
		}

		public IActionResult DriverEdit()
		{
			return PartialView("_DriverEntry");
		}

		public IActionResult User()
		{
			return View();
		}

		public IActionResult UserAdd()
		{
			return PartialView("_UserEntry");
		}

		public IActionResult UserEdit()
		{
			return PartialView("_UserEntry");
		}

		public IActionResult Chemist()
		{
			return View();
		}

		public IActionResult ChemistAdd()
		{
			return PartialView("_ChemistEntry");
		}

		public IActionResult ChemistEdit()
		{
			return PartialView("_ChemistEntry");
		}

        [HttpPost]
        public IActionResult SaveFarmer(ReqFarmerSave farmerSave)
        {
            try
            {
                if (farmerSave.method_name == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmerSave.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmerSave.user_id = HttpContext.Session.GetString("SessionUserId");
                farmerSave.user_name = HttpContext.Session.GetString("SessionUserName");

                res_Obj = new UsersDAL().SaveFarmer(farmerSave);
                if (res_Obj.ResponseCode == System.Net.HttpStatusCode.OK)
                {
                    List<ResJSCommonOutput>? res_Common = JsonSerializer.Deserialize<List<ResJSCommonOutput>>(res_Obj.ResponseData);
                    return Ok(res_Common);
                }
                else
                {
                    // Invalid Farmer Credentials
                    return StatusCode(500, "Invalid Farmer Credentials");
                }

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost]
        public IActionResult SaveAgent(ReqAgentSave agentSave)
        {
            try
            {
                if (agentSave.method_name == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                agentSave.org_id = HttpContext.Session.GetString("SessionOrgId");
                agentSave.user_id = HttpContext.Session.GetString("SessionUserId");
                agentSave.user_name = HttpContext.Session.GetString("SessionUserName");

                res_Obj = new UsersDAL().SaveAgent(agentSave);
                if (res_Obj.ResponseCode == System.Net.HttpStatusCode.OK)
                {
                    List<ResJSCommonOutput>? res_Common = JsonSerializer.Deserialize<List<ResJSCommonOutput>>(res_Obj.ResponseData);
                    return Ok(res_Common);
                }
                else
                {
                    // Invalid Agent Credentials
                    return StatusCode(500, "Invalid Agent Credentials");
                }

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost]
        public IActionResult SaveDriver(ReqDriverSave driverSave)
        {
            try
            {
                if (driverSave.method_name == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                driverSave.org_id = HttpContext.Session.GetString("SessionOrgId");
                driverSave.user_id = HttpContext.Session.GetString("SessionUserId");
                driverSave.user_name = HttpContext.Session.GetString("SessionUserName");

                res_Obj = new UsersDAL().SaveDriver(driverSave);
                if (res_Obj.ResponseCode == System.Net.HttpStatusCode.OK)
                {
                    List<ResJSCommonOutput>? res_Common = JsonSerializer.Deserialize<List<ResJSCommonOutput>>(res_Obj.ResponseData);
                    return Ok(res_Common);
                }
                else
                {
                    // Invalid Driver Credentials
                    return StatusCode(500, "Invalid Driver Credentials");
                }

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost]
        public IActionResult SaveChemist(ReqChemistSave chemistSave)
        {
            try
            {
                if (chemistSave.method_name == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                chemistSave.org_id = HttpContext.Session.GetString("SessionOrgId");
                chemistSave.user_id = HttpContext.Session.GetString("SessionUserId");
                chemistSave.user_name = HttpContext.Session.GetString("SessionUserName");

                res_Obj = new UsersDAL().SaveChemist(chemistSave);
                if (res_Obj.ResponseCode == System.Net.HttpStatusCode.OK)
                {
                    List<ResJSCommonOutput>? res_Common = JsonSerializer.Deserialize<List<ResJSCommonOutput>>(res_Obj.ResponseData);
                    return Ok(res_Common);
                }
                else
                {
                    // Invalid Chemist Credentials
                    return StatusCode(500, "Invalid Chemist Credentials");
                }

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost]
        public IActionResult GetOfficeUser(ReqUserSearch userSearch)
        {
            try
            {
                if (userSearch.method_name == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                userSearch.org_id = HttpContext.Session.GetString("SessionOrgId");
                userSearch.user_id = HttpContext.Session.GetString("SessionUserId");
                userSearch.user_name = HttpContext.Session.GetString("SessionUserName");

                res_Obj = new UsersDAL().GetOfficeUser(userSearch);
                if (res_Obj.ResponseCode == System.Net.HttpStatusCode.OK)
                {
                    List<ResJSCommonOutput>? res_Common = JsonSerializer.Deserialize<List<ResJSCommonOutput>>(res_Obj.ResponseData);
                    return Ok(res_Common);
                }
                else
                {
                    // Invalid User Credentials
                    return StatusCode(500, "Invalid User Credentials");
                }

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost]
        public IActionResult SaveOfficeUser(ReqUserSave userSave)
        {
            try
            {
                if (userSave.method_name == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                userSave.org_id = HttpContext.Session.GetString("SessionOrgId");
                userSave.user_id = HttpContext.Session.GetString("SessionUserId");
                userSave.user_name = HttpContext.Session.GetString("SessionUserName");

                res_Obj = new UsersDAL().SaveUser(userSave);
                if (res_Obj.ResponseCode == System.Net.HttpStatusCode.OK)
                {
                    List<ResJSCommonOutput>? res_Common = JsonSerializer.Deserialize<List<ResJSCommonOutput>>(res_Obj.ResponseData);
                    return Ok(res_Common);
                }
                else
                {
                    // Invalid User Credentials
                    return StatusCode(500, "Invalid User Credentials");
                }

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
    }
}
