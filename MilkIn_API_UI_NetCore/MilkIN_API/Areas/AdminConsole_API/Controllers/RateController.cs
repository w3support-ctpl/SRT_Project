using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/rate/")]
    [ApiController]
    public class RateController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public RateController(ILogger<LoginController> logger)
        {
            _logger = logger;

        }

        /*----  ----    ----    ----    Slab Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetSlab", Name = "GetSlab")]
        public IActionResult GetSlab(ReqSlab slabSearch)
        {
            try
            {

                if (slabSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResSlab> res_Obj = new List<ResSlab>();
                string destination_name = slabSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetSlab(slabSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(slabSearch.destination_name).ApiLog("Create", slabSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(slabSearch), "500", e.Message);

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

        [HttpPost("SaveSlab", Name = "SaveSlab")]
        public IActionResult SaveSlab(ReqSlab slabSave)
        {
            try
            {
                if (slabSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = slabSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveSlab(slabSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(slabSave.destination_name).ApiLog("Create", slabSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(slabSave), "500", e.Message);

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

        /*----  ----    ----    ----    Diesel Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetDiesel", Name = "GetDiesel")]
        public IActionResult GetDiesel(ReqDiesel dieselSearch)
        {
            try
            {

                if (dieselSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDiesel> res_Obj = new List<ResDiesel>();
                string destination_name = dieselSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetDiesel(dieselSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(dieselSearch.destination_name).ApiLog("Create", dieselSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(dieselSearch), "500", e.Message);

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

        [HttpPost("SaveDiesel", Name = "SaveDiesel")]
        public IActionResult SaveDiesel(ReqDiesel dieselSave)
        {
            try
            {
                if (dieselSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = dieselSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveDiesel(dieselSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(dieselSave.destination_name).ApiLog("Create", dieselSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(dieselSave), "500", e.Message);

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

        /*----  ----    ----    ----    Milk Rate Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMilkRate", Name = "GetMilkRate")]
        public IActionResult GetMilkRate(ReqMilkRate milkRateSearch)
        {
            try
            {
                if (milkRateSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkRate> res_Obj = new List<ResMilkRate>();
                string destination_name = milkRateSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetMilkRate(milkRateSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkRateSearch.destination_name).ApiLog("Create", milkRateSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(milkRateSearch), "500", e.Message);

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

        [HttpPost("SaveMilkRate", Name = "SaveMilkRate")]
        public IActionResult SaveMilkRate(ReqMilkRate milkRateSave)
        {
            try
            {
                if (milkRateSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkRateSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveMilkRate(milkRateSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkRateSave.destination_name).ApiLog("Create", milkRateSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(milkRateSave), "500", e.Message);

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

        /*----  ----    ----    ----    Milk Rate Item Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMilkRateItem", Name = "GetMilkRateItem")]
        public IActionResult GetMilkRateItem(ReqMilkRateItem milkRateItemSearch)
        {
            try
            {
                if (milkRateItemSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkRateItem> res_Obj = new List<ResMilkRateItem>();
                string destination_name = milkRateItemSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetMilkRateItem(milkRateItemSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkRateItemSearch.destination_name).ApiLog("Create", milkRateItemSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(milkRateItemSearch), "500", e.Message);

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

        [HttpPost("SaveMilkRateItem", Name = "SaveMilkRateItem")]
        public IActionResult SaveMilkRateItem(ReqMilkRateItem milkRateItemSave)
        {
            try
            {
                if (milkRateItemSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkRateItemSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveMilkRateItem(milkRateItemSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkRateItemSave.destination_name).ApiLog("Create", milkRateItemSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(milkRateItemSave), "500", e.Message);

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

        /*----  ----    ----    ----    Milk Rate MCC Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMilkRateMCC", Name = "GetMilkRateMCC")]
        public IActionResult GetMilkRateMCC(ReqMilkRateMCC milkRateMCCSearch)
        {
            try
            {
                if (milkRateMCCSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkRateMCC> res_Obj = new List<ResMilkRateMCC>();
                string destination_name = milkRateMCCSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetMilkRateMCC(milkRateMCCSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkRateMCCSearch.destination_name).ApiLog("Create", milkRateMCCSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(milkRateMCCSearch), "500", e.Message);

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

        [HttpPost("SaveMilkRateMCC", Name = "SaveMilkRateMCC")]
        public IActionResult SaveMilkRateMCC(ReqMilkRateMCC milkRateMCCSave)
        {
            try
            {
                if (milkRateMCCSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkRateMCCSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveMilkRateMCC(milkRateMCCSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkRateMCCSave.destination_name).ApiLog("Create", milkRateMCCSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(milkRateMCCSave), "500", e.Message);

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

        /*----  ----    ----    ----    MCC Commission Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMCCCommission", Name = "GetMCCCommission")]
        public IActionResult GetMCCCommission(ReqMCCCommission mccCommissionSearch)
        {
            try
            {
                if (mccCommissionSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMCCCommission> res_Obj = new List<ResMCCCommission>();
                string destination_name = mccCommissionSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetMCCCommission(mccCommissionSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccCommissionSearch.destination_name).ApiLog("Create", mccCommissionSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(mccCommissionSearch), "500", e.Message);

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

        [HttpPost("SaveMCCCommission", Name = "SaveMCCCommission")]
        public IActionResult SaveMCCCommission(ReqMCCCommission mccCommissionSave)
        {
            try
            {
                if (mccCommissionSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = mccCommissionSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveMCCCommission(mccCommissionSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccCommissionSave.destination_name).ApiLog("Create", mccCommissionSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(mccCommissionSave), "500", e.Message);

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

        /*----  ----    ----    ----    MCC Commission Item Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMCCCommissionItem", Name = "GetMCCCommissionItem")]
        public IActionResult GetMCCCommissionItem(ReqMCCCommissionItem mccCommissionItemSearch)
        {
            try
            {
                if (mccCommissionItemSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMCCCommissionItem> res_Obj = new List<ResMCCCommissionItem>();
                string destination_name = mccCommissionItemSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetMCCCommissionItem(mccCommissionItemSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccCommissionItemSearch.destination_name).ApiLog("Create", mccCommissionItemSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(mccCommissionItemSearch), "500", e.Message);

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

        [HttpPost("SaveMCCCommissionItem", Name = "SaveMCCCommissionItem")]
        public IActionResult SaveMCCCommissionItem(ReqMCCCommissionItem mccCommissionItemSave)
        {
            try
            {
                if (mccCommissionItemSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = mccCommissionItemSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveMCCCommissionItem(mccCommissionItemSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccCommissionItemSave.destination_name).ApiLog("Create", mccCommissionItemSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(mccCommissionItemSave), "500", e.Message);

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

        /*----  ----    ----    ----    MCC Commission MCC Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMCCCommissionMCC", Name = "GetMCCCommissionMCC")]
        public IActionResult GetMCCCommissionMCC(ReqMCCCommissionMCC mccCommissionMCCSearch)
        {
            try
            {
                if (mccCommissionMCCSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMCCCommissionMCC> res_Obj = new List<ResMCCCommissionMCC>();
                string destination_name = mccCommissionMCCSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetMCCCommissionMCC(mccCommissionMCCSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccCommissionMCCSearch.destination_name).ApiLog("Create", mccCommissionMCCSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(mccCommissionMCCSearch), "500", e.Message);

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

        [HttpPost("SaveMCCCommissionMCC", Name = "SaveMCCCommissionMCC")]
        public IActionResult SaveMCCCommissionMCC(ReqMCCCommissionMCC mccCommissionMCCSave)
        {
            try
            {
                if (mccCommissionMCCSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = mccCommissionMCCSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveMCCCommissionMCC(mccCommissionMCCSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccCommissionMCCSave.destination_name).ApiLog("Create", mccCommissionMCCSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(mccCommissionMCCSave), "500", e.Message);

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

        /*----  ----    ----    ----    Freight Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetFreight", Name = "GetFreight")]
        public IActionResult GetFreight(ReqFreight freightSearch)
        {
            try
            {

                if (freightSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFreight> res_Obj = new List<ResFreight>();
                string destination_name = freightSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetFreight(freightSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(freightSearch.destination_name).ApiLog("Create", freightSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(freightSearch), "500", e.Message);

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

        [HttpPost("SaveFreight", Name = "SaveFreight")]
        public IActionResult SaveFreight(ReqFreight freightSave)
        {
            try
            {
                if (freightSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = freightSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveFreight(freightSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(freightSave.destination_name).ApiLog("Create", freightSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(freightSave), "500", e.Message);

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

        /*----  ----    ----    ----    Fat SNF Ratio Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetFatSNFRatio", Name = "GetFatSNFRatio")]
        public IActionResult GetFatSNFRatio(ReqFatSNFRatio fatSNFRatioSearch)
        {
            try
            {

                if (fatSNFRatioSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFatSNFRatio> res_Obj = new List<ResFatSNFRatio>();
                string destination_name = fatSNFRatioSearch.destination_name + "";
                res_Obj = new RateDAL(destination_name).GetFatSNFRatio(fatSNFRatioSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(fatSNFRatioSearch.destination_name).ApiLog("Create", fatSNFRatioSearch.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(fatSNFRatioSearch), "500", e.Message);

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

        [HttpPost("SaveFatSNFRatio", Name = "SaveFatSNFRatio")]
        public IActionResult SaveFatSNFRatio(ReqFatSNFRatio fatSNFRatioSave)
        {
            try
            {
                if (fatSNFRatioSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = fatSNFRatioSave.destination_name + "";
                res_Obj = new RateDAL(destination_name).SaveFatSNFRatio(fatSNFRatioSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {


                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(fatSNFRatioSave.destination_name).ApiLog("Create", fatSNFRatioSave.org_id, "RateController", currentUrl, JsonConvert.SerializeObject(fatSNFRatioSave), "500", e.Message);

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
