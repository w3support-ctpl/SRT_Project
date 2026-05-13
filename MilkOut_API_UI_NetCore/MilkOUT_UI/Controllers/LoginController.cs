using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using System.Text.Json;

namespace MilkOUT_UI.Controllers
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
                        HttpContext.Session.SetString("SessionMobileNo", resUserDetails[0].mobile_no + "");
						HttpContext.Session.SetString("SessionEmailId", resUserDetails[0].email_id + "");
                        HttpContext.Session.SetString("SessionUserMenu", userMenu);
                        /*
                        if(resUserDetails[0].is_passwordreset == 1) { 
                            return RedirectToAction("Login", "ChangePassword");
                        }*/

                        return Ok(resUserDetails[0].is_passwordreset);
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
            HttpContext.Session.Remove("SessionUserMenu");
            HttpContext.Session.Remove("SessionMobileNo");
            HttpContext.Session.Remove("SessionEmailId");

            return RedirectToAction("Index", "Login");
        }

        public IActionResult ChangePassword()
        {
            return PartialView("_ChangePassword");
        }

        [HttpPost]
        public IActionResult Change_Password(ReqLogin login)
        {
            try
            {
                if (login.login_password == "")
                {
                    return BadRequest();
                }

                login.org_id = HttpContext.Session.GetString("SessionOrgId");
                login.login_name = HttpContext.Session.GetString("SessionUserId");


                ResAPICommonOutput resOut = new LoginDAL().Login(login);

                if (resOut.ResponseCode == System.Net.HttpStatusCode.OK)
                {
                    List<UserDetails>? resUserDetails = JsonSerializer.Deserialize<List<UserDetails>>(resOut.ResponseData);
                    if (resUserDetails.Count > 0)
                    {
                        return Ok(resUserDetails[0].is_passwordreset);
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
    }
}
