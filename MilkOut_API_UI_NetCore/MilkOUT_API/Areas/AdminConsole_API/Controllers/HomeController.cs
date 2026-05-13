using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
	[Route("v1/api/admin/home/")]
	[ApiController]
	public class HomeController : Controller
	{
		private readonly IJwtBuilder _jwtBuilder;
		private readonly ILogger<LoginController> _logger;

		public HomeController(ILogger<LoginController> logger, IJwtBuilder jwtBuilder)
		{
			_logger = logger;
			_jwtBuilder = jwtBuilder;
		}

		[HttpPost("GetMasterData", Name = "GetMasterData")]
		public IActionResult GetMasterData([FromBody] ReqMasterData masterData)
		{
            try
			{
				if (masterData == null)
				{
					return BadRequest();
				}

				List<MasterDetails> res_Obj = new List<MasterDetails>();

				string Destination_Name = masterData.destination_name + "";
				res_Obj = new HomeDAL(Destination_Name).GetMasterData(masterData);
				return Ok(res_Obj);

			}
			catch (Exception ex)
			{
				_logger.LogError($"Error : {ex.Message}");
				return StatusCode(500, ex.Message);
			}

		}

		[HttpPost("GetMastersData", Name = "GetMastersData")]
		public IActionResult GetMastersData([FromBody] ReqMasterData masterData)
		{
            try
			{
				if (masterData == null)
				{
					return BadRequest();
				}

				List<MasterDetails> res_Obj = new List<MasterDetails>();

				string Destination_Name = masterData.destination_name + "";
				res_Obj = new HomeDAL(Destination_Name).GetMastersData(masterData);
				return Ok(res_Obj);

			}
			catch (Exception ex)
			{
				_logger.LogError($"Error : {ex.Message}");
				return StatusCode(500, ex.Message);
			}

		}

	}
}
