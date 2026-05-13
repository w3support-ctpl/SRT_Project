using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using MilkIN_UI.DAL;
using MilkIN_UI.Models;
using Newtonsoft.Json;
namespace MilkIN_UI.Controllers
{
    public class ManageController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
        /*----  ----    ----    ----    Deductions   ----    ----    ----    ----*/

        public IActionResult Deductions()
        {
            return View();
        }
        public IActionResult DeductionsEdit()
        {
            return PartialView("_DeductionsEntry");
        }
        public IActionResult DeductionsAdd()
        {
            return PartialView("_DeductionsAddEntry");
        }
        public IActionResult DeductionsAddEdit()
        {
            return PartialView("_DeductionsAddEditEntry");
        }

        [HttpPost]
        public IActionResult Deductions(ReqDeductions deductions)
        {
            try
            {
                if (deductions.method_name == null || deductions.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                deductions.org_id = HttpContext.Session.GetString("SessionOrgId");
                deductions.user_id = HttpContext.Session.GetString("SessionUserId");
                deductions.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(deductions);
                string APIEndPoint = "/v1/api/admin/manage/" + deductions.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Incentives   ----    ----    ----    ----*/

        public IActionResult Incentives()
        {
            return View();
        }
        public IActionResult IncentivesEdit()
        {
            return PartialView("_IncentivesEntry");
        }
        public IActionResult IncentivesAdd()
        {
            return PartialView("_IncentivesAddEntry");
        }
        public IActionResult IncentivesAddEdit()
        {
            return PartialView("_IncentivesAddEditEntry");
        }

        [HttpPost]
        public IActionResult Incentives(ReqIncentives Incentives)
        {
            try
            {
                if (Incentives.method_name == null || Incentives.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                Incentives.org_id = HttpContext.Session.GetString("SessionOrgId");
                Incentives.user_id = HttpContext.Session.GetString("SessionUserId");
                Incentives.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(Incentives);
                string APIEndPoint = "/v1/api/admin/manage/" + Incentives.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Farmer Incentive Schemes   ----    ----    ----    ----*/

        public IActionResult FarmerIncentiveSchemes()
        {
            return View();
        }

        public IActionResult FarmerIncentiveSchemesAdd()
        {
            return PartialView("_FarmerIncentiveSchemesEntry");
        }

        public IActionResult FarmerIncentiveSchemesEdit()
        {
            return PartialView("_FarmerIncentiveSchemesEntry");
        }

        [HttpPost]
        public IActionResult FarmerIncentiveSchemes(ReqFarmerIncentiveSchemes farmerIncentiveSchemes)
        {
            try
            {
                if (farmerIncentiveSchemes.method_name == null || farmerIncentiveSchemes.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmerIncentiveSchemes.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmerIncentiveSchemes.user_id = HttpContext.Session.GetString("SessionUserId");
                farmerIncentiveSchemes.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(farmerIncentiveSchemes);
                string APIEndPoint = "/v1/api/admin/manage/" + farmerIncentiveSchemes.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Agent Incentive Schemes   ----    ----    ----    ----*/

        public IActionResult AgentIncentiveSchemes()
        {
            return View();
        }

        public IActionResult AgentIncentiveSchemesAdd()
        {
            return PartialView("_AgentIncentiveSchemesEntry");
        }

        public IActionResult AgentIncentiveSchemesEdit()
        {
            return PartialView("_AgentIncentiveSchemesEntry");
        }
        [HttpPost]
        public IActionResult AgentIncentiveSchemes(ReqAgentIncentiveSchemes agentIncentiveSchemes)
        {
            try
            {
                if (agentIncentiveSchemes.method_name == null || agentIncentiveSchemes.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                agentIncentiveSchemes.org_id = HttpContext.Session.GetString("SessionOrgId");
                agentIncentiveSchemes.user_id = HttpContext.Session.GetString("SessionUserId");
                agentIncentiveSchemes.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(agentIncentiveSchemes);
                string APIEndPoint = "/v1/api/admin/manage/" + agentIncentiveSchemes.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Material Issue to MCC   ----    ----    ----    ----*/

        public IActionResult MaterialIssueToMCC()
        {
            return View();
        }

        public IActionResult MaterialIssueToMCCAdd()
        {
            return PartialView("_MaterialIssueToMCCEntry");
        }

        public IActionResult MaterialIssueToMCCEdit()
        {
            return PartialView("_MaterialIssueToMCCEntry");
        }

        [HttpPost]
        public IActionResult MaterialIssueToMCC(ReqMaterialIssueToMCC materialIssueToMCC)
        {
            try
            {
                if (materialIssueToMCC.method_name == null || materialIssueToMCC.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                materialIssueToMCC.org_id = HttpContext.Session.GetString("SessionOrgId");
                materialIssueToMCC.user_id = HttpContext.Session.GetString("SessionUserId");
                materialIssueToMCC.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(materialIssueToMCC);
                string APIEndPoint = "/v1/api/admin/manage/" + materialIssueToMCC.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Material Return from MCC   ----    ----    ----    ----*/

        public IActionResult MaterialReturnFromMCC()
        {
            return View();
        }

        public IActionResult MaterialReturnFromMCCAdd()
        {
            return PartialView("_MaterialReturnFromMCCEntry");
        }

        public IActionResult MaterialReturnFromMCCEdit()
        {
            return PartialView("_MaterialReturnFromMCCEntry");
        }

        [HttpPost]
        public IActionResult MaterialReturnFromMCC(ReqMaterialReturnFromMCC materialReturnFromMCC)
        {
            try
            {
                if (materialReturnFromMCC.method_name == null || materialReturnFromMCC.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                materialReturnFromMCC.org_id = HttpContext.Session.GetString("SessionOrgId");
                materialReturnFromMCC.user_id = HttpContext.Session.GetString("SessionUserId");
                materialReturnFromMCC.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(materialReturnFromMCC);
                string APIEndPoint = "/v1/api/admin/manage/" + materialReturnFromMCC.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        /*----  ----    ----    ----    Complaints   ----    ----    ----    ----*/

        public IActionResult Complaints()
        {
            return View();
        }

        public IActionResult ComplaintsAdd()
        {
            return PartialView("_ComplaintsEntry");
        }

        public IActionResult ComplaintsEdit()
        {
            return PartialView("_ComplaintsEntry");
        }
        
        [HttpPost]
        public IActionResult Complaints(ReqComplaints complaints)
        {
            try
            {
                if (complaints.method_name == null || complaints.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                complaints.org_id = HttpContext.Session.GetString("SessionOrgId");
                complaints.user_id = HttpContext.Session.GetString("SessionUserId");
                complaints.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(complaints);
                string APIEndPoint = "/v1/api/admin/manage/" + complaints.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        /*----  ----    ----    ----    Remote Calibration   ----    ----    ----    ----*/

        public IActionResult RemoteCalibration()
        {
            return View();
        }

        public IActionResult RemoteCalibrationAdd()
        {
            return PartialView("_RemoteCalibrationEntry");
        }

        public IActionResult RemoteCalibrationEdit()
        {
            return PartialView("_RemoteCalibrationEntry");
        }


        /*----  ----    ----    ----    Issue Empty Cans   ----    ----    ----    ----*/

        public IActionResult IssueEmptyCans()
        {
            return View();
        }
        public IActionResult IssueEmptyCansAdd()
        {
            return PartialView("_IssueEmptyCansEntry");
        }
        public IActionResult IssueEmptyCansEdit()
        {
            return PartialView("_IssueEmptyCansEntry");
        }
        [HttpPost]
        public IActionResult IssueEmptyCans(ReqIssueEmptyCans issueEmptyCans)
        {
            try
            {
                if (issueEmptyCans.method_name == null || issueEmptyCans.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                issueEmptyCans.org_id = HttpContext.Session.GetString("SessionOrgId");
                issueEmptyCans.user_id = HttpContext.Session.GetString("SessionUserId");
                issueEmptyCans.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(issueEmptyCans);
                string APIEndPoint = "/v1/api/admin/manage/" + issueEmptyCans.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


    }
}
