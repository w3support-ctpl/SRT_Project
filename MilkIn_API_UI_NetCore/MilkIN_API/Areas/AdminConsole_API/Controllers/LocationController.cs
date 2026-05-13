using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/location/")]
    [ApiController]
    public class LocationController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public LocationController(ILogger<LoginController> logger)
        {
            _logger = logger;

        }

        [HttpPost("GetState", Name = "GetState")]
        public IActionResult GetState(ReqState stateSearch)
        {
            try
            {
                if (stateSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResState> res_Obj = new List<ResState>();
                string destination_name = stateSearch.destination_name + "";
                res_Obj = new LocationDAL(destination_name).GetState(stateSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(stateSearch.destination_name).ApiLog("Create", stateSearch.org_id, "LocationController", currentUrl, JsonConvert.SerializeObject(stateSearch), "500", e.Message);

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

        [HttpPost("GetDistrict", Name = "GetDistrict")]
        public IActionResult GetDistrict(ReqDistrict districtSearch)
        {
            try
            {
                if (districtSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDistrict> res_Obj = new List<ResDistrict>();
                string destination_name = districtSearch.destination_name + "";
                res_Obj = new LocationDAL(destination_name).GetDistrict(districtSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(districtSearch.destination_name).ApiLog("Create", districtSearch.org_id, "LocationController", currentUrl, JsonConvert.SerializeObject(districtSearch), "500", e.Message);

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

        [HttpPost("SaveDistrict", Name = "SaveDistrict")]
        public IActionResult SaveDistrict(ReqDistrict districtSave)
        {
            try
            {
                if (districtSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = districtSave.destination_name + "";
                res_Obj = new LocationDAL(destination_name).SaveDistrict(districtSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(districtSave.destination_name).ApiLog("Create", districtSave.org_id, "LocationController", currentUrl, JsonConvert.SerializeObject(districtSave), "500", e.Message);

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

        [HttpPost("GetTaluka", Name = "GetTaluka")]
        public IActionResult GetTaluka(ReqTaluka talukaSearch)
        {
            try
            {
                if (talukaSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResTaluka> res_Obj = new List<ResTaluka>();
                string destination_name = talukaSearch.destination_name + "";
                res_Obj = new LocationDAL(destination_name).GetTaluka(talukaSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(talukaSearch.destination_name).ApiLog("Create", talukaSearch.org_id, "LocationController", currentUrl, JsonConvert.SerializeObject(talukaSearch), "500", e.Message);

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

        [HttpPost("SaveTaluka", Name = "SaveTaluka")]
        public IActionResult SaveTaluka(ReqTaluka talukaSave)
        {
            try
            {
                if (talukaSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = talukaSave.destination_name + "";
                res_Obj = new LocationDAL(destination_name).SaveTaluka(talukaSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(talukaSave.destination_name).ApiLog("Create", talukaSave.org_id, "LocationController", currentUrl, JsonConvert.SerializeObject(talukaSave), "500", e.Message);

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

        [HttpPost("GetVillage", Name = "GetVillage")]
        public IActionResult GetVillage(ReqVillage villageSearch)
        {
            try
            {
                if (villageSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResVillage> res_Obj = new List<ResVillage>();
                string destination_name = villageSearch.destination_name + "";
                res_Obj = new LocationDAL(destination_name).GetVillage(villageSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(villageSearch.destination_name).ApiLog("Create", villageSearch.org_id, "LocationController", currentUrl, JsonConvert.SerializeObject(villageSearch), "500", e.Message);

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

        [HttpPost("SaveVillage", Name = "SaveVillage")]
        public IActionResult SaveVillage(ReqVillage villageSave)
        {
            try
            {
                if (villageSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = villageSave.destination_name + "";
                res_Obj = new LocationDAL(destination_name).SaveVillage(villageSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(villageSave.destination_name).ApiLog("Create", villageSave.org_id, "LocationController", currentUrl, JsonConvert.SerializeObject(villageSave), "500", e.Message);

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
