using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class CrateReceivefromDealerController : Controller
    {
        public IActionResult Index()
        {
            return View("CrateReceivefromDealer");
        }
        public IActionResult CrateReceivefromDealerAdd()
        {
            return PartialView("_CrateReceivefromDealerEntry");
        }
        public IActionResult CrateReceivefromDealerEdit()
        {
            return PartialView("_CrateReceivefromDealerEntry");
        }
        
    }
}
