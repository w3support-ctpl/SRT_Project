using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class ComplaintsController : Controller
    {
        public IActionResult Index()
        {
            return View("Complaints");
        }
        public IActionResult ComplaintsAdd()
        {
            return PartialView("_ComplaintsEntry");
        }
        public IActionResult ComplaintsEdit()
        {
            return PartialView("_ComplaintsEntry");
        }
    }
}
