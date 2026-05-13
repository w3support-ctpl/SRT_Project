using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class SalesPersonRouteController : Controller
    {
        public IActionResult Index()
        {
            return View("SalesPersonRoute");
        }
        public IActionResult SalesPersonRouteAdd()
        {
            return PartialView("_SalesPersonRouteEntry");
        }
        public IActionResult SalesPersonRouteEdit()
        {
            return PartialView("_SalesPersonRouteEntry");
        }
    }
}
