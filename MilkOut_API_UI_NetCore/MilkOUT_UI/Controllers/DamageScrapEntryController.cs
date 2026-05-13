using Microsoft.AspNetCore.Mvc;

namespace MilkOUT_UI.Controllers
{
    public class DamageScrapEntryController : Controller
    {
        public IActionResult Index()
        {
            return View("RetailerDamageScrap");
        }
        public IActionResult RetailerDamage_ScrapAdd()
        {
            return PartialView("_RetailerDamageORScrapEntry");
        }

        public IActionResult RetailerDamage_ScrapEdit()
        {
            return PartialView("_RetailerDamageORScrapEntry");
        }
    }
}
