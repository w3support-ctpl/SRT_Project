using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.DAL;
using MilkIN_UI.Models;
using System.Text.Json;

namespace MilkIN_UI.Controllers
{
	public class LoginController : Controller
	{
		public IActionResult Index()
		{
			return View();
		}

		[HttpPost]
		public IActionResult Login(ReqLogin login)
		{
			try
			{
				if (login.login_name == null || login.login_password == "")
				{
					return BadRequest();
				}

				ResAPICommonOutput resOut = new LoginDAL().Login(login);

				if (resOut.ResponseCode == System.Net.HttpStatusCode.OK)
				{
					List<UserDetails>? resUserDetails = JsonSerializer.Deserialize<List<UserDetails>>(resOut.ResponseData);
					if (resUserDetails.Count > 0)
					{
						// Get User Menu
						string userMenu = new LoginDAL().GetUserMenu(resUserDetails[0].usermenu);

						// Set Session Variable Values
						HttpContext.Session.SetString("SessionOrgId", resUserDetails[0].org_id + "");
						HttpContext.Session.SetString("SessionOrgName", resUserDetails[0].org_name + "");
						HttpContext.Session.SetString("SessionUserId", resUserDetails[0].user_id + "");
						HttpContext.Session.SetString("SessionUserName", resUserDetails[0].user_name + "");
						HttpContext.Session.SetString("SessionToken", resUserDetails[0].token + "");
						HttpContext.Session.SetString("SessionRoleId", resUserDetails[0].role_id + "");
						HttpContext.Session.SetString("SessionRoleName", resUserDetails[0].role_name + "");
						HttpContext.Session.SetInt32("SessionIsPasswordReset", resUserDetails[0].is_passwordreset);
						HttpContext.Session.SetString("SessionTruckCollectionFirstQty", resUserDetails[0].truckcollection_firstqty + "");
						HttpContext.Session.SetString("SessionTankerCollectionFirstQty", resUserDetails[0].tankercollection_firstqty + "");
						HttpContext.Session.SetString("SessionMobileNo", resUserDetails[0].mobile_no + "");
						HttpContext.Session.SetString("SessionEmailId", resUserDetails[0].email_id + "");
						HttpContext.Session.SetString("SessionUserMenu", userMenu);
                        HttpContext.Session.SetString("SessionUserMenuList", JsonSerializer.Serialize(resUserDetails[0].usermenu));

                        return Ok();
					}
					else
					{
						// Invalid User Credentials
						return StatusCode(500, "Invalid User Credentials");
					}
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

		public IActionResult LogOut()
		{

			HttpContext.Session.Remove("SessionOrgId");
			HttpContext.Session.Remove("SessionOrgName");
			HttpContext.Session.Remove("SessionUserId");
			HttpContext.Session.Remove("SessionUserName");
			HttpContext.Session.Remove("SessionToken");
			HttpContext.Session.Remove("SessionRoleId");
			HttpContext.Session.Remove("SessionRoleName");
			HttpContext.Session.Remove("SessionIsPasswordReset");
			HttpContext.Session.Remove("SessionTruckCollectionFirstQty");
			HttpContext.Session.Remove("SessionTankerCollectionFirstQty");
			HttpContext.Session.Remove("SessionUserMenu");
			HttpContext.Session.Remove("SessionMobileNo");
			HttpContext.Session.Remove("SessionEmailId");
            HttpContext.Session.Remove("SessionUserMenuList");

            return RedirectToAction("Index", "Login");
			
		}

		public IActionResult ForgotPassword()
		{
			return PartialView("_ForgotPassword");
		}

        
    }
}
