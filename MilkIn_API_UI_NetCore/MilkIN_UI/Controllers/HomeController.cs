using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.DAL;
using MilkIN_UI.Models;
using Newtonsoft.Json;
using System.Diagnostics;

namespace MilkIN_UI.Controllers
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

        public IActionResult AccessError()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
		}

		[HttpPost]
		public IActionResult MasterData(ReqMasterData masterData)
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

				masterData.org_id = HttpContext.Session.GetString("SessionOrgId");
				masterData.user_id = HttpContext.Session.GetString("SessionUserId");
                masterData.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(masterData);
				string APIEndPoint = "/v1/api/admin/home/" + masterData.api_end_point;
				string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
				return Ok(response);
			}
			catch (Exception ex)
			{
				var ErrMsg = ex.Message;

				return StatusCode(500, ErrMsg);

			}
		}

		[HttpPost]
		public IActionResult GetDashboard(ReqMasterData masterData)
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

				masterData.org_id = HttpContext.Session.GetString("SessionOrgId");
				masterData.user_id = HttpContext.Session.GetString("SessionUserId");
                masterData.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(masterData);
				string APIEndPoint = "/v1/api/admin/home/" + masterData.api_end_point;
				string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
				return Ok(response);
			}
			catch (Exception ex)
			{
				var ErrMsg = ex.Message;

				return StatusCode(500, ErrMsg);

			}
		}
	}
}