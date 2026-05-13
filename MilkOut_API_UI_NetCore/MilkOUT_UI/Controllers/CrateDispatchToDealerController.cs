using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class CrateDispatchToDealerController : Controller
    {
        public IActionResult Index()
        {
            return View("CrateDispatchToDealer");
        }
        public IActionResult CrateDispatchToDealerAdd()
        {
            return PartialView("_CrateDispatchToDealerEntry");
        }
        public IActionResult CrateDispatchToDealerEdit()
        {
            return PartialView("_CrateDispatchToDealerEntry");
        }
    }
}
