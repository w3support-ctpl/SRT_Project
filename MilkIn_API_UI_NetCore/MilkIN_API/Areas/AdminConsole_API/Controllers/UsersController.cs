using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;
using Org.BouncyCastle.Asn1.Ocsp;
using System.Configuration;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
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

        // Get & Search Farmer
        [HttpPost("GetFarmer", Name = "GetFarmer")]
        public IActionResult GetFarmer(ReqFarmer farmerSearch)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(farmerSearch.destination_name).ApiLog("Create", farmerSearch.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(farmerSearch), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Save Farmer
        [HttpPost("SaveFarmer", Name = "SaveFarmer")]
        public IActionResult SaveFarmer(ReqFarmer farmerSave)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(farmerSave.destination_name).ApiLog("Create", farmerSave.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(farmerSave), "500", e.Message);
                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Get & Search Agent
        [HttpPost("GetAgent", Name = "GetAgent")]
        public IActionResult GetAgent(ReqAgent agentSearch)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(agentSearch.destination_name).ApiLog("Create", agentSearch.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(agentSearch), "500", e.Message);
                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Save Agent
        [HttpPost("SaveAgent", Name = "SaveAgent")]
        public IActionResult SaveAgent(ReqAgent agentSave)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(agentSave.destination_name).ApiLog("Create", agentSave.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(agentSave), "500", e.Message);
                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Get & Search Driver
        [HttpPost("GetDriver", Name = "GetDriver")]
        public IActionResult GetDriver(ReqDriver driverSearch)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(driverSearch.destination_name).ApiLog("Create", driverSearch.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(driverSearch), "500", e.Message);
                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Save Driver
        [HttpPost("SaveDriver", Name = "SaveDriver")]
        public IActionResult SaveDriver(ReqDriver driverSave)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(driverSave.destination_name).ApiLog("Create", driverSave.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(driverSave), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Get & Search Chemist
        [HttpPost("GetChemist", Name = "GetChemist")]
        public IActionResult GetChemist(ReqChemist chemistSearch)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(chemistSearch.destination_name).ApiLog("Create", chemistSearch.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(chemistSearch), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Save Chemist
        [HttpPost("SaveChemist", Name = "SaveChemist")]
        public IActionResult SaveChemist(ReqChemist chemistSave)
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
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(chemistSave.destination_name).ApiLog("Create", chemistSave.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(chemistSave), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Get & Search User
        [HttpPost("GetUser", Name = "GetUser")]
        public IActionResult GetUser(ReqUser userSearch)
        {
            try
            {
                if (userSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResUser> res_Obj = new List<ResUser>();
                string destination_name = userSearch.destination_name + "";
                res_Obj = new UsersDAL(destination_name).GetUser(userSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(userSearch.destination_name).ApiLog("Create", userSearch.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(userSearch), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Save User
        [HttpPost("SaveUser", Name = "SaveUser")]
        public IActionResult SaveUser(ReqUser userSave)
        {
            try
            {
                if (userSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = userSave.destination_name + "";
                res_Obj = new UsersDAL(destination_name).SaveUser(userSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(userSave.destination_name).ApiLog("Create", userSave.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(userSave), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // Save User
        [HttpPost("SavePassword", Name = "SavePassword")]
        public IActionResult SavePassword(ReqChangePassword userPassword)
        {
            try
            {
                if (userPassword.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = userPassword.destination_name + "";
                res_Obj = new UsersDAL(destination_name).SavePassword(userPassword);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(userPassword.destination_name).ApiLog("Create", userPassword.org_id, "UsersController", currentUrl, JsonConvert.SerializeObject(userPassword), "500", e.Message);

                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

        // GetMaster Test
        [HttpGet("GetUserMaster", Name = "GetUserMaster")]
        public IActionResult GetUserMaster()
        {
            try
            {
                List<ResUser> res_Obj = new List<ResUser>();
                res_Obj = new UsersDAL("").GetUserMaster();

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                
                var ErrMsg = e.Message;

                // Handle the error and create a CommonOutput instance for the error case
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = -1, // Assuming result_id is an integer
                    result_description = $"Error: {e.Message}",
                    result_extra_key = ""
                };

                // Return the CommonOutput instance for the error case
                return Ok(new List<CommonOutput> { commonOutput });
            }
        }

    }
}
