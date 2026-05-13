

using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using MilkOUT_API.Filter;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/crate/")]
    [ApiController]
    //[AuthenticationFilter]
    public class IssueCrateController : Controller
    {
        private readonly ILogger<IssueCrateController> _logger;
        public IssueCrateController(ILogger<IssueCrateController> logger)
        {
            _logger = logger;
        }



        [HttpPost("IssueCrate", Name = "IssueCrate")]
        public IActionResult IssueCrate(IssueCrateModel IssueCrateModel)
        {
            try
            {
                if (IssueCrateModel == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_obj = new List<CommonOutput>();
                string destination_name = "";
                res_obj = new IssueCrateDAL(destination_name).IssueCrate(IssueCrateModel);
                return Ok(res_obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("SaveIssueCrate", Name = "SaveIssueCrate")]
        public IActionResult SaveIssueCrate(IssueCrateModel IssueCrateModel)
        {
            try
            {
                if (IssueCrateModel == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_obj = new List<CommonOutput>();
                string destination_name = "";
                res_obj = new IssueCrateDAL(destination_name).SaveIssueCrate(IssueCrateModel);
                return Ok(res_obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetCrateStock", Name = "GetCrateStock")]
        public IActionResult GetCrateStock(Reqcratestock Cratestock)
        {
            try
            {
                if (Cratestock == null)
                {
                    return BadRequest();
                }


                string destination_name = "";
                string res_obj = new IssueCrateDAL(destination_name).GetCrateStock(Cratestock);

                return Ok(res_obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("IssueCrateTime", Name = "IssueCrateTime")]
        public IActionResult IssueCrateTime(IssueCrateModel IssueCrateModel)
        {
            try
            {
                if (IssueCrateModel == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_obj = new List<CommonOutput>();
                string destination_name = "";
                res_obj = new IssueCrateDAL(destination_name).IssueCrateTime(IssueCrateModel);
                return Ok(res_obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



    }


}
