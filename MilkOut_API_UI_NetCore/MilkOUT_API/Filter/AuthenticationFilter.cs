using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Configuration;
using NuGet.Protocol;

namespace MilkOUT_API.Filter
{
    public class AuthenticationFilter : Attribute, IAuthorizationFilter
    {

        public void OnAuthorization(AuthorizationFilterContext context)
        {
            var MyConfig = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();
            var AppName = MyConfig.GetValue<string>("AppSettings:key");
            string isAjaxCall = context.HttpContext.Request.Headers["x-api-key"];
            if (isAjaxCall != AppName)
            {
                context.Result = new JsonResult(new { message = "Unauthorized" }) { StatusCode = StatusCodes.Status401Unauthorized };
            }
            if (isAjaxCall == null) { 
                context.Result = new JsonResult(new { message = "Unauthorized" }) { StatusCode = StatusCodes.Status401Unauthorized };

            }

        }

    }
}
