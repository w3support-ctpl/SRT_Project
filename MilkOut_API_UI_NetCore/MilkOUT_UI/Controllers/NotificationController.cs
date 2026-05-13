using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class NotificationController : Controller
    {
        public IActionResult Index()
        {
            return View("Notification");
        }
        public IActionResult NotificationAdd()
        {
            return PartialView("_NotificationEntry");
        }

        public IActionResult NotificationEdit()
        {
            return PartialView("_NotificationEntry");
        }
    }
}
