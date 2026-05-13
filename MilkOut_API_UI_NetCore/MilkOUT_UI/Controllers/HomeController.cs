using Microsoft.AspNetCore.Mvc;
using MilkOUT_UI.DAL;
using MilkOUT_UI.Models;
using System.Diagnostics;

namespace MilkOUT_UI.Controllers
{
	public class HomeController : Controller
	{
		private readonly ILogger<HomeController> _logger;

		public HomeController(ILogger<HomeController> logger)
		{
			_logger = logger;
		}

		public IActionResult Index()
		{
			return View();
		}

		public IActionResult Privacy()
		{
			return View();
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}

		[HttpPost]
		public IActionResult GetMasterData(ReqMasterData masterData)
		{
			try
			{
                if (HttpContext.Session.GetString("SessionOrgId") == "" || HttpContext.Session.GetString("SessionOrgId") == null ||
                HttpContext.Session.GetString("SessionUserId") == "" || HttpContext.Session.GetString("SessionUserId") == null)
                {
                    return BadRequest();
                }
                if (masterData.method_name == "")
                {
                    return BadRequest();
                }
                if (masterData.method_name == "")
				{
					return BadRequest();
				}

				masterData.org_id = HttpContext.Session.GetString("SessionOrgId");
				masterData.user_id = HttpContext.Session.GetString("SessionUserId");

				List<MasterDetails> res_Obj = new List<MasterDetails>();
				res_Obj = new HomeDAL().GetMasterData(masterData);

				return Ok(res_Obj);
			}
			catch (Exception ex)
			{
				var ErrMsg = ex.Message;

				return StatusCode(500, ErrMsg);

			}
		}

		[HttpPost]
		public IActionResult GetMastersData(ReqMasterData masterData)
		{
			try
			{
                if (HttpContext.Session.GetString("SessionOrgId") == "" || HttpContext.Session.GetString("SessionOrgId") == null ||
                HttpContext.Session.GetString("SessionUserId") == "" || HttpContext.Session.GetString("SessionUserId") == null)
                {
                    return BadRequest();
                }
                if (masterData.method_name == "")
                {
                    return BadRequest();
                }
                if (masterData.method_name == "")
				{
					return BadRequest();
				}

				masterData.org_id = HttpContext.Session.GetString("SessionOrgId");
				masterData.user_id = HttpContext.Session.GetString("SessionUserId");

				List<MasterDetails> res_Obj = new List<MasterDetails>();
				res_Obj = new HomeDAL().GetMastersData(masterData);

				return Ok(res_Obj);
			}
			catch (Exception ex)
			{
				var ErrMsg = ex.Message;

				return StatusCode(500, ErrMsg);

			}
		}
	}
}