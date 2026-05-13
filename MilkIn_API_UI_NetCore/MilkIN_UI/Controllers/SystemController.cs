using Microsoft.AspNetCore.Mvc;
using YourNamespace.Services;

namespace YourNamespace.Controllers
{
    public class SystemController : Controller
    {
        private static readonly SystemUsageService _usageService = new SystemUsageService();

        public IActionResult Monitor()
        {
            return View();
        }

        [HttpGet]
        public IActionResult CpuUsage()
        {
            var cpu = _usageService.GetCpuUsage();
            return Json(new { cpuUsage = cpu });
        }
    }
}
