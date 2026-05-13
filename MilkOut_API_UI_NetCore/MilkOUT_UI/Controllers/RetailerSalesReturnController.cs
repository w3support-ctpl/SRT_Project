using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class RetailerSalesReturnController : Controller
    {
        public IActionResult Index()
        {
            return View("RetailerSalesReturn");
        }
        public IActionResult RetailerSalesReturnAdd()
        {
            return PartialView("_RetailerSalesReturnEntry");
        }

        public IActionResult RetailerSalesReturnEdit()
        {
            return PartialView("_RetailerSalesReturnEntry");
        }
    }
}
