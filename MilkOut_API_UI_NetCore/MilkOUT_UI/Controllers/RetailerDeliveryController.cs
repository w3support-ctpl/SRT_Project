using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class RetailerDeliveryController : Controller
    {
        public IActionResult Index()
        {
            return View("RetailerDelivery");
        }       
        public IActionResult RetailerDeliveryAdd()
        {
            return PartialView("_RetailerDeliveryEntry");
        }
        public IActionResult RetailerDeliveryEdit()
        {
            return PartialView("_RetailerDeliveryEntry");
        }
    }
}
