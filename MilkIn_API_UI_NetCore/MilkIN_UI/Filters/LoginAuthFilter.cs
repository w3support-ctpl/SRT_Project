using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Net;
using MilkIN_UI.Models;

namespace MilkIN_UI.Filters
{
    public class LoginAuthFilter : Attribute, IActionFilter
    {
        private readonly string currentMenu_Id;
        private readonly string currentUser_Action;

        public LoginAuthFilter(string Menu_Id, string User_Action)
        {
            this.currentMenu_Id = Menu_Id;
            this.currentUser_Action = User_Action;
        }

        public void OnActionExecuting(ActionExecutingContext context)
        {
            //Check if SessionUserId exists on or not. If not then redirect user to Login page
            var result = context.HttpContext.Session.GetString("SessionUserId");
            if (result == null)
            {
                context.Result = new RedirectToActionResult("Index", "Login", null);
            }

            // Check if User has Display access for the selected page
            List<UserMenu>? menuList = GetComplexData<List<UserMenu>>(context, "SessionUserMenuList");
            int User_Has_Access = 0;
            var AccessString = "";

            for (int i = 0; i < menuList?.Count; i++)
            {
                if (menuList[i].menu_id == currentMenu_Id)
                {
                    AccessString = menuList[i].display_flag.ToString() + menuList[i].add_flag.ToString() + menuList[i].edit_flag.ToString() + menuList[i].delete_flag.ToString();
                    // User has access to this page.  Now check the action
                    if (currentUser_Action == "Display" && menuList[i].display_flag == 1)
                    {
                        User_Has_Access = 1;
                    }
                    else if (currentUser_Action == "Data" && menuList[i].display_flag == 1)
                    {
                        User_Has_Access = 1;
                    }
                    else if (currentUser_Action == "Add" && menuList[i].add_flag == 1)
                    {
                        User_Has_Access = 1;
                    }
                    else if (currentUser_Action == "Edit" && menuList[i].edit_flag == 1)
                    {
                        User_Has_Access = 1;
                    }
                    else if (currentUser_Action == "Delete" && menuList[i].delete_flag == 1)
                    {
                        User_Has_Access = 1;
                    }
                    else
                    {
                        User_Has_Access = 0;
                    }
                    break;
                }
            }

            if (User_Has_Access == 0)
            {
                if (currentUser_Action == "Display")
                {
                    // Redirect user to unauthorised page
                    context.Result = new RedirectToActionResult("AccessError", "Home", null);
                }
                else
                {
                    context.HttpContext.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                }
            }

            if (currentUser_Action == "Display" || currentUser_Action == "Add" || currentUser_Action == "Edit")
            {
                // Return actionstring to View
                Controller? controller = context.Controller as Controller;
                if (controller != null)
                {
                    //injecting values in the ViewData
                    controller.ViewBag.AccessString = AccessString;
                }
            }

        }

        public static T? GetComplexData<T>(ActionExecutingContext context, string key)
        {
            var data = context.HttpContext.Session.GetString(key);
            if (data == null)
            {
                return default(T);
            }
            return JsonConvert.DeserializeObject<T>(data);
        }

        public void OnActionExecuted(ActionExecutedContext context)
        {

        }
    }
}
