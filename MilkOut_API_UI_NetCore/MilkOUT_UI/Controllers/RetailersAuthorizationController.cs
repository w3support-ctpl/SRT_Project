using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class RetailersAuthorizationController : Controller
    {
        public IActionResult Index()
        {
            return View("RetailersAuthorization");
        }
        public IActionResult RetailersAuthorizationAdd()
        {
            return PartialView("_RetailersAuthorizationEntry");
        }
        public IActionResult RetailersAuthorizationEdit()
        {
            return PartialView("_RetailersAuthorizationEntry");
        }
    }
}
