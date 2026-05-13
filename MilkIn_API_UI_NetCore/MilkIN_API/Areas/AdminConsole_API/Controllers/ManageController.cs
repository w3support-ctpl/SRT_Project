using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using MilkIN_API.Middleware;
using Newtonsoft.Json;
using System.Configuration;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/manage/")]
    [ApiController]
    public class ManageController : Controller
    {
        private readonly ILogger<LoginController> _logger;
        private readonly IConfiguration _configuration;


        public ManageController(ILogger<LoginController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

        }


        /*----  ----    ----    ----    Material Issue To MCC Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMaterialIssueToMCC", Name = "GetMaterialIssueToMCC")]
        public IActionResult GetMaterialIssueToMCC(ReqMaterialIssueToMCC materialIssueToMCCSearch)
        {
            try
            {
                if (materialIssueToMCCSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMaterialIssueToMCC> res_Obj = new List<ResMaterialIssueToMCC>();
                string destination_name = materialIssueToMCCSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetMaterialIssueToMCC(materialIssueToMCCSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(materialIssueToMCCSearch.destination_name).ApiLog("Create", materialIssueToMCCSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(materialIssueToMCCSearch), "500", e.Message);

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

        [HttpPost("SaveMaterialIssueToMCC", Name = "SaveMaterialIssueToMCC")]
        public IActionResult SaveMaterialIssueToMCC(ReqMaterialIssueToMCC materialIssueToMCCSave)
        {
            try
            {
                if (materialIssueToMCCSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = materialIssueToMCCSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveMaterialIssueToMCC(materialIssueToMCCSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(materialIssueToMCCSave.destination_name).ApiLog("Create", materialIssueToMCCSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(materialIssueToMCCSave), "500", e.Message);

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


        /*----  ----    ----    ----    Material Return From MCC Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMaterialReturnFromMCC", Name = "GetMaterialReturnFromMCC")]
        public IActionResult GetMaterialReturnFromMCC(ReqMaterialReturnFromMCC materialReturnFromMCCSearch)
        {
            try
            {
                if (materialReturnFromMCCSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMaterialReturnFromMCC> res_Obj = new List<ResMaterialReturnFromMCC>();
                string destination_name = materialReturnFromMCCSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetMaterialReturnFromMCC(materialReturnFromMCCSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(materialReturnFromMCCSearch.destination_name).ApiLog("Create", materialReturnFromMCCSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(materialReturnFromMCCSearch), "500", e.Message);

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

        [HttpPost("SaveMaterialReturnFromMCC", Name = "SaveMaterialReturnFromMCC")]
        public IActionResult SaveMaterialReturnFromMCC(ReqMaterialReturnFromMCC materialReturnFromMCCSave)
        {
            try
            {
                if (materialReturnFromMCCSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = materialReturnFromMCCSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveMaterialReturnFromMCC(materialReturnFromMCCSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(materialReturnFromMCCSave.destination_name).ApiLog("Create", materialReturnFromMCCSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(materialReturnFromMCCSave), "500", e.Message);

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




        /*----  ----    ----    ----    Deductions Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetDeductions", Name = "GetDeductions")]
        public IActionResult GetDeductions(ReqDeductions deductionsSearch)
        {
            try
            {
                if (deductionsSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDeductions> res_Obj = new List<ResDeductions>();
                string destination_name = deductionsSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetDeductions(deductionsSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(deductionsSearch.destination_name).ApiLog("Create", deductionsSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(deductionsSearch), "500", e.Message);

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

        [HttpPost("SaveDeductions", Name = "SaveDeductions")]
        public IActionResult SaveDeductions(ReqDeductions deductionsSave)
        {
            try
            {
                if (deductionsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = deductionsSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveDeductions(deductionsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(deductionsSave.destination_name).ApiLog("Create", deductionsSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(deductionsSave), "500", e.Message);

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


        [HttpPost("SaveDeduction", Name = "SaveDeduction")]
        public IActionResult SaveDeduction(ReqDeductions deductionsSave)
        {
            try
            {
                if (deductionsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDeductions> res_Obj = new List<ResDeductions>();
                string destination_name = deductionsSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveDeduction(deductionsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(deductionsSave.destination_name).ApiLog("Create", deductionsSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(deductionsSave), "500", e.Message);

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

        /*----  ----    ----    ----    Incentive Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetIncentives", Name = "GetIncentivesAdmin")]
        public IActionResult GetIncentivesAdmin(ReqIncentives IncentivesSearch)
        {
            try
            {
                if (IncentivesSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResIncentives> res_Obj = new List<ResIncentives>();
                string destination_name = IncentivesSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetIncentives(IncentivesSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(IncentivesSearch.destination_name).ApiLog("Create", IncentivesSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(IncentivesSearch), "500", e.Message);

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

        [HttpPost("SaveIncentives", Name = "SaveIncentivesAdmin")]
        public IActionResult SaveIncentivesAdmin(ReqIncentives IncentivesSave)
        {
            try
            {
                if (IncentivesSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = IncentivesSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveIncentives(IncentivesSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(IncentivesSave.destination_name).ApiLog("Create", IncentivesSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(IncentivesSave), "500", e.Message);

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


        [HttpPost("SaveIncentive", Name = "SaveIncentiveAdmin")]
        public IActionResult SaveIncentiveAdmin(ReqIncentives IncentivesSave)
        {
            try
            {
                if (IncentivesSave.method_name == null)
                {
                    return BadRequest();
                }

                List<ResIncentives> res_Obj = new List<ResIncentives>();
                string destination_name = IncentivesSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveIncentive(IncentivesSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(IncentivesSave.destination_name).ApiLog("Create", IncentivesSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(IncentivesSave), "500", e.Message);


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

        /*----  ----    ----    ----    Complaints Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetComplaints", Name = "GetComplaints")]
        public IActionResult GetComplaints(ReqComplaints complaintsSearch)
        {
            try
            {
                if (complaintsSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResComplaints> res_Obj = new List<ResComplaints>();
                string destination_name = complaintsSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetComplaints(complaintsSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(complaintsSearch.destination_name).ApiLog("Create", complaintsSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(complaintsSearch), "500", e.Message);

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

        [HttpPost("SaveComplaints", Name = "SaveComplaints")]
        public IActionResult SaveComplaints(ReqComplaints complaintsSave)
        {
            try
            {
                if (complaintsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = complaintsSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveComplaints(complaintsSave);

                if (complaintsSave.display_flag == 1)
                {
                    if (res_Obj[0].result_description == "Resolved")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(complaintsSave.complaint_for_user_id, complaintsSave.org_id, complaintsSave.complaint_for, "ComplaintResolved");
                    }
                    if (res_Obj[0].result_description == "Opened")
                    {
                        new Notify(destination_name, _configuration).Send_Notification(complaintsSave.complaint_for_user_id, complaintsSave.org_id, complaintsSave.complaint_for, "ComplaintOpened");
                    }
                }



                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(complaintsSave.destination_name).ApiLog("Create", complaintsSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(complaintsSave), "500", e.Message);


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


        /*----  ----    ----    ----    Issue Empty Cans Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetIssueEmptyCans", Name = "GetIssueEmptyCans")]
        public IActionResult GetIssueEmptyCans(ReqIssueEmptyCans issueEmptyCansSearch)
        {
            try
            {
                if (issueEmptyCansSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResIssueEmptyCans> res_Obj = new List<ResIssueEmptyCans>();
                string destination_name = issueEmptyCansSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetIssueEmptyCans(issueEmptyCansSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(issueEmptyCansSearch.destination_name).ApiLog("Create", issueEmptyCansSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(issueEmptyCansSearch), "500", e.Message);


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

        [HttpPost("SaveIssueEmptyCans", Name = "SaveIssueEmptyCans")]
        public IActionResult SaveIssueEmptyCans(ReqIssueEmptyCans issueEmptyCansSave)
        {
            try
            {
                if (issueEmptyCansSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = issueEmptyCansSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveIssueEmptyCans(issueEmptyCansSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(issueEmptyCansSave.destination_name).ApiLog("Create", issueEmptyCansSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(issueEmptyCansSave), "500", e.Message);


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




        /*----  ----    ----    ----    Farmer Incentive Schemes Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetFarmerIncentiveSchemes", Name = "GetFarmerIncentiveSchemes")]
        public IActionResult GetFarmerIncentiveSchemes(ReqFarmerIncentiveSchemes farmerIncentiveSchemesSearch)
        {
            try
            {
                if (farmerIncentiveSchemesSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResFarmerIncentiveSchemes> res_Obj = new List<ResFarmerIncentiveSchemes>();
                string destination_name = farmerIncentiveSchemesSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetFarmerIncentiveSchemes(farmerIncentiveSchemesSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(farmerIncentiveSchemesSearch.destination_name).ApiLog("Create", farmerIncentiveSchemesSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(farmerIncentiveSchemesSearch), "500", e.Message);


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

        [HttpPost("SaveFarmerIncentiveSchemes", Name = "SaveFarmerIncentiveSchemes")]
        public IActionResult SaveFarmerIncentiveSchemes(ReqFarmerIncentiveSchemes farmerIncentiveSchemesSave)
        {
            try
            {
                if (farmerIncentiveSchemesSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = farmerIncentiveSchemesSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveFarmerIncentiveSchemes(farmerIncentiveSchemesSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(farmerIncentiveSchemesSave.destination_name).ApiLog("Create", farmerIncentiveSchemesSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(farmerIncentiveSchemesSave), "500", e.Message);

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




        /*----  ----    ----    ----    Agent Incentive Schemes Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetAgentIncentiveSchemes", Name = "GetAgentIncentiveSchemes")]
        public IActionResult GetAgentIncentiveSchemes(ReqAgentIncentiveSchemes agentIncentiveSchemesSearch)
        {
            try
            {
                if (agentIncentiveSchemesSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResAgentIncentiveSchemes> res_Obj = new List<ResAgentIncentiveSchemes>();
                string destination_name = agentIncentiveSchemesSearch.destination_name + "";
                res_Obj = new ManageDAL(destination_name).GetAgentIncentiveSchemes(agentIncentiveSchemesSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(agentIncentiveSchemesSearch.destination_name).ApiLog("Create", agentIncentiveSchemesSearch.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(agentIncentiveSchemesSearch), "500", e.Message);


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

        [HttpPost("SaveAgentIncentiveSchemes", Name = "SaveAgentIncentiveSchemes")]
        public IActionResult SaveAgentIncentiveSchemes(ReqAgentIncentiveSchemes agentIncentiveSchemesSave)
        {
            try
            {
                if (agentIncentiveSchemesSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = agentIncentiveSchemesSave.destination_name + "";
                res_Obj = new ManageDAL(destination_name).SaveAgentIncentiveSchemes(agentIncentiveSchemesSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(agentIncentiveSchemesSave.destination_name).ApiLog("Create", agentIncentiveSchemesSave.org_id, "ManageController", currentUrl, JsonConvert.SerializeObject(agentIncentiveSchemesSave), "500", e.Message);


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