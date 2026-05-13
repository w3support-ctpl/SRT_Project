using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using MilkIN_API.Middleware;
using Newtonsoft.Json;
using System.Configuration;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/approvals/")]
    [ApiController]
    public class ApprovalsController : Controller
    {
        private readonly ILogger<ApprovalsController> _logger;
        private readonly IConfiguration _configuration;

        public ApprovalsController(ILogger<ApprovalsController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }





        /*----  ----    ----    ----    Farmer Registration   ----    ----    ----    ----*/
        [HttpPost("GetFarmerRegistration", Name = "GetFarmerRegistration")]
        public IActionResult GetFarmerRegistration(ReqFarmerRegistration farmerSearch)
        {
            try
            {
                if (farmerSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmerRegistration> res_Obj = new List<ResFarmerRegistration>();
                string destination_name = farmerSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetFarmerRegistration(farmerSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(farmerSearch.destination_name).ApiLog("Create", farmerSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(farmerSearch), "500", e.Message);

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
        [HttpPost("SaveFarmerRegistration", Name = "SaveFarmerRegistration")]
        public IActionResult SaveFarmerRegistration(ReqFarmerRegistration farmerSave)
        {
            try
            {
                if (farmerSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = farmerSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveFarmerRegistration(farmerSave);

                if (res_Obj[0].result_description == "Approved" || res_Obj[0].result_description == "Update")
                {
                    new Notify(destination_name, _configuration).Send_Notification(res_Obj[0].result_extra_key, farmerSave.org_id, "Farmer", "FarmerRegistrationRequestApproved");
                }
                if (res_Obj[0].result_description == "Rejected" || res_Obj[0].result_description != "Update")
                {
                    new Notify(destination_name, _configuration).Send_Notification(res_Obj[0].result_extra_key, farmerSave.org_id, "Farmer", "FarmerRegistrationRequestRejected");
                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(farmerSave.destination_name).ApiLog("Create", farmerSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(farmerSave), "500", e.Message);

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






        /*----  ----    ----    ----    Farmer Service Request   ----    ----    ----    ----*/
        [HttpPost("GetFarmerService", Name = "GetFarmerService")]
        public IActionResult GetFarmerService(ReqFarmerService serviceSearch)
        {
            try
            {
                if (serviceSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmerService> res_Obj = new List<ResFarmerService>();
                string destination_name = serviceSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetFarmerService(serviceSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSearch.destination_name).ApiLog("Create", serviceSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSearch), "500", e.Message);

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
        [HttpPost("SaveFarmerService", Name = "SaveFarmerService")]
        public IActionResult SaveFarmerService(ReqFarmerService serviceSave)
        {
            try
            {
                if (serviceSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = serviceSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveFarmerService(serviceSave);

                //if (res_Obj[0].result_description == "Approved")
                //{
                //    new Notify(destination_name, _configuration).Send_Notification(serviceSave.requestfor_id, serviceSave.org_id, "Farmer", "FarmerServiceRequestApproved");
                //}
                //if (res_Obj[0].result_description == "Rejected")
                //{
                //    new Notify(destination_name, _configuration).Send_Notification(serviceSave.requestfor_id, serviceSave.org_id, "Farmer", "FarmerServiceRequestRejected");
                //}

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSave.destination_name).ApiLog("Create", serviceSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSave), "500", e.Message);

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







        /*----  ----    ----    ----    Agent Service Request   ----    ----    ----    ----*/
        [HttpPost("GetAgentService", Name = "GetAgentService")]
        public IActionResult GetAgentService(ReqAgentService serviceSearch)
        {
            try
            {
                if (serviceSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgentService> res_Obj = new List<ResAgentService>();
                string destination_name = serviceSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetAgentService(serviceSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSearch.destination_name).ApiLog("Create", serviceSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSearch), "500", e.Message);

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
        [HttpPost("SaveAgentService", Name = "SaveAgentService")]
        public IActionResult SaveAgentService(ReqAgentService serviceSave)
        {
            try
            {
                if (serviceSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = serviceSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveAgentService(serviceSave);


                if (res_Obj[0].result_description == "Approved")
                {
                    new Notify(destination_name, _configuration).Send_Notification(serviceSave.requestfor_id, serviceSave.org_id, "Agent", "AgentServiceRequestApproved");
                }
                if (res_Obj[0].result_description == "Rejected")
                {
                    new Notify(destination_name, _configuration).Send_Notification(serviceSave.requestfor_id, serviceSave.org_id, "Agent", "AgentServiceRequestRejected");
                }



                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSave.destination_name).ApiLog("Create", serviceSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSave), "500", e.Message);

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







        /*----  ----    ----    ----    Farmer Incentive Request   ----    ----    ----    ----*/

        // Get & Search Farmer Incentive Request
        [HttpPost("GetFarmerIncentive", Name = "GetFarmerIncentive")]
        public IActionResult GetFarmerIncentive(ReqFarmerIncentive incentiveSearch)
        {
            try
            {
                if (incentiveSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmerIncentive> res_Obj = new List<ResFarmerIncentive>();
                string destination_name = incentiveSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetFarmerIncentive(incentiveSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSearch.destination_name).ApiLog("Create", incentiveSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(incentiveSearch), "500", e.Message);
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

        [HttpPost("SaveFarmerIncentive", Name = "SaveFarmerIncentive")]
        public IActionResult SaveFarmerIncentive(ReqFarmerIncentive incentiveSave)
        {
            try
            {
                if (incentiveSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = incentiveSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveFarmerIncentive(incentiveSave);

                if (res_Obj[0].result_description == "Approved")
                {
                    new Notify(destination_name, _configuration).Send_Notification(incentiveSave.requestfor_id, incentiveSave.org_id, "Farmer", "FarmerIncentiveRequestApproved");
                }
                if (res_Obj[0].result_description == "Rejected")
                {
                    new Notify(destination_name, _configuration).Send_Notification(incentiveSave.requestfor_id, incentiveSave.org_id, "Farmer", "FarmerIncentiveRequestRejected");
                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSave.destination_name).ApiLog("Create", incentiveSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(incentiveSave), "500", e.Message);

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






        /*----  ----    ----    ----    Agent Service Request   ----    ----    ----    ----*/
        [HttpPost("GetAgentIncentive", Name = "GetAgentIncentive")]
        public IActionResult GetAgentIncentive(ReqAgentIncentive incentiveSearch)
        {
            try
            {
                if (incentiveSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgentIncentive> res_Obj = new List<ResAgentIncentive>();
                string destination_name = incentiveSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetAgentIncentive(incentiveSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSearch.destination_name).ApiLog("Create", incentiveSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(incentiveSearch), "500", e.Message);

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
        [HttpPost("SaveAgentIncentive", Name = "SaveAgentIncentive")]
        public IActionResult SaveAgentIncentive(ReqAgentIncentive incentiveSave)
        {
            try
            {
                if (incentiveSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = incentiveSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveAgentIncentive(incentiveSave);


                if (res_Obj[0].result_description == "Approved")
                {
                    new Notify(destination_name, _configuration).Send_Notification(incentiveSave.requestfor_id, incentiveSave.org_id, "Agent", "AgentIncentiveRequestApproved");
                }
                if (res_Obj[0].result_description == "Rejected")
                {
                    new Notify(destination_name, _configuration).Send_Notification(incentiveSave.requestfor_id, incentiveSave.org_id, "Agent", "AgentIncentiveRequestRejected");
                }



                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSave.destination_name).ApiLog("Create", incentiveSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(incentiveSave), "500", e.Message);

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







        /*----  ----    ----    ----    Milk Collection Request   ----    ----    ----    ----*/
        [HttpPost("GetCollectionRequest", Name = "GetCollectionRequest")]
        public IActionResult GetCollectionRequest(ReqCollectionRequest requestSearch)
        {
            try
            {
                if (requestSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResCollectionRequest> res_Obj = new List<ResCollectionRequest>();
                string destination_name = requestSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetCollectionRequest(requestSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(requestSearch.destination_name).ApiLog("Create", requestSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(requestSearch), "500", e.Message);

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
        [HttpPost("SaveCollectionRequest", Name = "SaveCollectionRequest")]
        public IActionResult SaveCollectionRequest(ReqCollectionRequest requestSave)
        {
            try
            {
                if (requestSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = requestSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveCollectionRequest(requestSave);

                if (res_Obj[0].result_description == "Approved")
                {
                    new Notify(destination_name, _configuration).Send_Notification(requestSave.agent_id, requestSave.org_id, "Agent", "CollectionRequestApproved");
                }
                if (res_Obj[0].result_description == "Rejected")
                {
                    new Notify(destination_name, _configuration).Send_Notification(requestSave.agent_id, requestSave.org_id, "Agent", "CollectionRequestRejected");
                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(requestSave.destination_name).ApiLog("Create", requestSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(requestSave), "500", e.Message);

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







        /*----  ----    ----    ----    Correction L1   ----    ----    ----    ----*/
        [HttpPost("GetCorrectionL1", Name = "GetCorrectionL1")]
        public IActionResult GetCorrectionL1(ReqCorrectionL1 correctionL1Search)
        {
            try
            {
                if (correctionL1Search.method_name == null)
                {
                    return BadRequest();
                }

                List<ResCorrectionL1> res_Obj = new List<ResCorrectionL1>();
                string destination_name = correctionL1Search.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetCorrectionL1(correctionL1Search);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(correctionL1Search.destination_name).ApiLog("Create", correctionL1Search.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(correctionL1Search), "500", e.Message);

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
        [HttpPost("SaveCorrectionL1", Name = "SaveCorrectionL1")]
        public IActionResult SaveCorrectionL1(ReqCorrectionL1 correctionL1Save)
        {
            try
            {
                if (correctionL1Save.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = correctionL1Save.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveCorrectionL1(correctionL1Save);

                if (res_Obj[0].result_id == 1)
                {
                    if (res_Obj[0].result_description == "Approved")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(correctionL1Save.agent_id, correctionL1Save.org_id, "Agent", "CorrectionRequestApproved");
                    }
                    if (res_Obj[0].result_description == "Rejected")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(correctionL1Save.agent_id, correctionL1Save.org_id, "Agent", "CorrectionRequestRejected");
                    }
                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(correctionL1Save.destination_name).ApiLog("Create", correctionL1Save.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(correctionL1Save), "500", e.Message);

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







        /*----  ----    ----    ----    Correction L2   ----    ----    ----    ----*/
        [HttpPost("GetCorrectionL2", Name = "GetCorrectionL2")]
        public IActionResult GetCorrectionL2(ReqCorrectionL2 correctionL2Search)
        {
            try
            {
                if (correctionL2Search.method_name == null)
                {
                    return BadRequest();
                }

                List<ResCorrectionL2> res_Obj = new List<ResCorrectionL2>();
                string destination_name = correctionL2Search.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetCorrectionL2(correctionL2Search);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(correctionL2Search.destination_name).ApiLog("Create", correctionL2Search.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(correctionL2Search), "500", e.Message);

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
        [HttpPost("SaveCorrectionL2", Name = "SaveCorrectionL2")]
        public IActionResult SaveCorrectionL2(ReqCorrectionL2 correctionL2Save)
        {
            try
            {
                if (correctionL2Save.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = correctionL2Save.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveCorrectionL2(correctionL2Save);

                if (res_Obj[0].result_id == 1)
                {
                    // if (res_Obj[0].result_description == "Approved")
                    // {
                    //     new Notify(destination_name, _configuration).Send_Notification(correctionL2Save.agent_id, correctionL2Save.org_id, "Agent", "CorrectionRequestApproved");
                    // }
                    // if (res_Obj[0].result_description == "Rejected")
                    // {
                    //     new Notify(destination_name, _configuration).Send_Notification(correctionL2Save.agent_id, correctionL2Save.org_id, "Agent", "CorrectionRequestRejected");
                    // }

                    if (res_Obj[0].result_description == "Approved")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(res_Obj[0].result_extra_key, correctionL2Save.org_id, "Farmer", "CorrectionRequestApproved");
                        new Notify(destination_name, _configuration).Send_Notification(res_Obj[0].result_extra_key, correctionL2Save.org_id, "Agent", "CorrectionRequestApproved");
                    }
                    if (res_Obj[0].result_description == "Rejected")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(res_Obj[0].result_extra_key, correctionL2Save.org_id, "Farmer", "CorrectionRequestRejected");
                        new Notify(destination_name, _configuration).Send_Notification(res_Obj[0].result_extra_key, correctionL2Save.org_id, "Agent", "CorrectionRequestRejected");
                    }
                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(correctionL2Save.destination_name).ApiLog("Create", correctionL2Save.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(correctionL2Save), "500", e.Message);

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








        /*----  ----    ----    ----    Date Correction   ----    ----    ----    ----*/
        [HttpPost("GetDataCorrection", Name = "GetDataCorrection")]
        public IActionResult GetDataCorrection(ReqDataCorrection dataCorrectionSearch)
        {
            try
            {
                if (dataCorrectionSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDataCorrection> res_Obj = new List<ResDataCorrection>();
                string destination_name = dataCorrectionSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetDataCorrection(dataCorrectionSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
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
        [HttpPost("SaveDataCorrection", Name = "SaveDataCorrection")]
        public IActionResult SaveDataCorrection(ReqDataCorrection dataCorrectionSave)
        {
            try
            {
                if (dataCorrectionSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = dataCorrectionSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveDataCorrection(dataCorrectionSave);

                if (res_Obj[0].result_id == 1)
                {
                    if (res_Obj[0].result_description == "Approved")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(dataCorrectionSave.request_for_user_id, dataCorrectionSave.org_id, dataCorrectionSave.request_for, "DataCorrectionRequestApproved");
                    }
                    if (res_Obj[0].result_description == "Rejected")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(dataCorrectionSave.request_for_user_id, dataCorrectionSave.org_id, dataCorrectionSave.request_for, "DataCorrectionRequestRejected");
                    }
                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(dataCorrectionSave.destination_name).ApiLog("Create", dataCorrectionSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(dataCorrectionSave), "500", e.Message);

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






        /*----  ----    ----    ----    Farmer Orders   ----    ----    ----    ----*/
        [HttpPost("GetFarmerOrder", Name = "GetFarmerOrder")]
        public IActionResult GetFarmerOrder(ReqFarmerOrder serviceSearch)
        {
            try
            {
                if (serviceSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmerOrder> res_Obj = new List<ResFarmerOrder>();
                string destination_name = serviceSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetFarmerOrder(serviceSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSearch.destination_name).ApiLog("Create", serviceSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSearch), "500", e.Message);

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
        [HttpPost("SaveFarmerOrder", Name = "SaveFarmerOrder")]
        public IActionResult SaveFarmerOrder(ReqFarmerOrder serviceSave)
        {
            try
            {
                if (serviceSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = serviceSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveFarmerOrder(serviceSave);

                if (res_Obj[0].result_description == "Approved")
                {
                    new Notify(destination_name, _configuration).Send_Notification(serviceSave.orderfor_id, serviceSave.org_id, "Farmer", "FarmerOrderRequestApproved");
                }
                if (res_Obj[0].result_description == "Rejected")
                {
                    new Notify(destination_name, _configuration).Send_Notification(serviceSave.orderfor_id, serviceSave.org_id, "Farmer", "FarmerOrderRequestRejected");
                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSave.destination_name).ApiLog("Create", serviceSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSave), "500", e.Message);

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





        /*----  ----    ----    ----    Agent Orders   ----    ----    ----    ----*/
        [HttpPost("GetAgentOrder", Name = "GetAgentOrder")]
        public IActionResult GetAgentOrder(ReqAgentOrder serviceSearch)
        {
            try
            {
                if (serviceSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgentOrder> res_Obj = new List<ResAgentOrder>();
                string destination_name = serviceSearch.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).GetAgentOrder(serviceSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSearch.destination_name).ApiLog("Create", serviceSearch.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSearch), "500", e.Message);
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
        [HttpPost("SaveAgentOrder", Name = "SaveAgentOrder")]
        public IActionResult SaveAgentOrder(ReqAgentOrder serviceSave)
        {
            try
            {
                if (serviceSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = serviceSave.destination_name + "";
                res_Obj = new ApprovalsDAL(destination_name).SaveAgentOrder(serviceSave);


                if (res_Obj[0].result_description == "Approved")
                {
                    new Notify(destination_name, _configuration).Send_Notification(serviceSave.orderfor_id, serviceSave.org_id, "Agent", "AgentOrderRequestApproved");
                }
                if (res_Obj[0].result_description == "Rejected")
                {
                    new Notify(destination_name, _configuration).Send_Notification(serviceSave.orderfor_id, serviceSave.org_id, "Agent", "AgentOrderRequestRejected");
                }



                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(serviceSave.destination_name).ApiLog("Create", serviceSave.org_id, "ApprovalsController", currentUrl, JsonConvert.SerializeObject(serviceSave), "500", e.Message);

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

