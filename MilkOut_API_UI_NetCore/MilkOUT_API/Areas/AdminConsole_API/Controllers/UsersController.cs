using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/users/")]
    [ApiController]
    public class UsersController : Controller
    {
        private readonly ILogger<UsersController> _logger;

        public UsersController(ILogger<UsersController> logger)
        {
            _logger = logger;

        }

        [HttpPost("GetFarmer", Name = "GetFarmer")]
        public IActionResult GetFarmer(UsersModel.ReqFarmerSearch farmerSearch)
        {
            try
            {
                if (farmerSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmer> res_Obj = new List<ResFarmer>();
                string destination_name = farmerSearch.destination_name + "";
                res_Obj = new UsersDAL(destination_name).GetFarmer(farmerSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("SaveFarmer", Name = "SaveFarmer")]
        public IActionResult SaveFarmer(UsersModel.ReqFarmerSave farmerSave)
        {
            try
            {
                if (farmerSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = farmerSave.destination_name + "";
                res_Obj = new UsersDAL(destination_name).SaveFarmer(farmerSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetAgent", Name = "GetAgent")]
        public IActionResult GetAgent(UsersModel.ReqAgentSearch agentSearch)
        {
            try
            {
                if (agentSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgent> res_Obj = new List<ResAgent>();
                string destination_name = agentSearch.destination_name + "";
                res_Obj = new UsersDAL(destination_name).GetAgent(agentSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("SaveAgent", Name = "SaveAgent")]
        public IActionResult SaveAgent(UsersModel.ReqAgentSave agentSave)
        {
            try
            {
                if (agentSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = agentSave.destination_name + "";
                res_Obj = new UsersDAL(destination_name).SaveAgent(agentSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetDriver", Name = "GetDriver")]
        public IActionResult GetDriver(UsersModel.ReqDriverSearch driverSearch)
        {
            try
            {
                if (driverSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDriver> res_Obj = new List<ResDriver>();
                string destination_name = driverSearch.destination_name + "";
                res_Obj = new UsersDAL(destination_name).GetDriver(driverSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("SaveDriver", Name = "SaveDriver")]
        public IActionResult SaveDriver(UsersModel.ReqDriverSave driverSave)
        {
            try
            {
                if (driverSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = driverSave.destination_name + "";
                res_Obj = new UsersDAL(destination_name).SaveDriver(driverSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetChemist", Name = "GetChemist")]
        public IActionResult GetChemist(UsersModel.ReqChemistSearch chemistSearch)
        {
            try
            {
                if (chemistSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResChemist> res_Obj = new List<ResChemist>();
                string destination_name = chemistSearch.destination_name + "";
                res_Obj = new UsersDAL(destination_name).GetChemist(chemistSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("SaveChemist", Name = "SaveChemist")]
        public IActionResult SaveChemist(UsersModel.ReqChemistSave chemistSave)
        {
            try
            {
                if (chemistSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = chemistSave.destination_name + "";
                res_Obj = new UsersDAL(destination_name).SaveChemist(chemistSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        /*
        [HttpPost("GetOfficeUser", Name = "GetOfficeUser")]
        public IActionResult GetOfficeUser(UsersModel.ReqUserSearch userSearch)
        {
            try
            {
                if (userSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResUser> res_Obj = new List<ResUser>();
                string destination_name = userSearch.destination_name + "";
                res_Obj = new UsersDAL(destination_name).GetOfficeUser(userSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("SaveOfficeUser", Name = "SaveOfficeUser")]
        public IActionResult SaveOfficeUser(UsersModel.ReqUserSave userSave)
        {
            try
            {
                if (userSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = userSave.destination_name + "";
                res_Obj = new UsersDAL(destination_name).SaveOfficeUser(userSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        */
    }
}
