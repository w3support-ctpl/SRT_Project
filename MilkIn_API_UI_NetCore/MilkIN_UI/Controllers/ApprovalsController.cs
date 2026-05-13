using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.DAL;
using MilkIN_UI.Models;
using Newtonsoft.Json;

namespace MilkIN_UI.Controllers
{
    public class ApprovalsController : Controller
	{




        /*----  ----    ----    ----    Farmer Registration   ----    ----    ----    ----*/
        public IActionResult FarmerRegistration()
        {
            return View();
        }
        public IActionResult FarmerRegistrationAdd()
        {
            return PartialView("_FarmerRegistrationEntry");
        }
        [HttpPost]
        public IActionResult FarmerRegistration(ReqFarmerRegistration farmer)
        {
            try
            {
                if (farmer.method_name == null || farmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmer.user_id = HttpContext.Session.GetString("SessionUserId");
                farmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(farmer);
                string APIEndPoint = "/v1/api/admin/approvals/" + farmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        
        
        

        /*----  ----    ----    ----    Data Correction   ----    ----    ----    ----*/
        public IActionResult FarmerDataCorrection()
        {
            return View();
        }
        public IActionResult FarmerDataCorrectionEdit()
        {
            return PartialView("_FarmerDataCorrectionEntry");
        }
        public IActionResult AgentDataCorrection()
        {
            return View();
        }
        public IActionResult AgentDataCorrectionEdit()
        {
            return PartialView("_AgentDataCorrectionEntry");
        }
        [HttpPost]
        public IActionResult DataCorrection(ReqDataCorrection dataCorrection)
        {
            try
            {
                if (dataCorrection.method_name == null || dataCorrection.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                dataCorrection.org_id = HttpContext.Session.GetString("SessionOrgId");
                dataCorrection.user_id = HttpContext.Session.GetString("SessionUserId");
                dataCorrection.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(dataCorrection);
                string APIEndPoint = "/v1/api/admin/approvals/" + dataCorrection.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Correction L1   ----    ----    ----    ----*/

        public IActionResult CorrectionL1()
		{
			return View();
		}
		public IActionResult CorrectionL1Edit() {
			return PartialView("_CorrectionL1Entry");
		}
        [HttpPost]
        public IActionResult CorrectionL1(ReqCorrectionL1 correctionL1)
        {
            try
            {
                if (correctionL1.method_name == null || correctionL1.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                correctionL1.org_id = HttpContext.Session.GetString("SessionOrgId");
                correctionL1.user_id = HttpContext.Session.GetString("SessionUserId");
                correctionL1.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(correctionL1);
                string APIEndPoint = "/v1/api/admin/approvals/" + correctionL1.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Correction L2   ----    ----    ----    ----*/
        public IActionResult CorrectionL2()
		{
			return View();
		}
		public IActionResult CorrectionL2Edit()
		{
			return PartialView("_CorrectionL2Entry");
		}
        [HttpPost]
        public IActionResult CorrectionL2(ReqCorrectionL2 correctionL2)
        {
            try
            {
                if (correctionL2.method_name == null || correctionL2.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                correctionL2.org_id = HttpContext.Session.GetString("SessionOrgId");
                correctionL2.user_id = HttpContext.Session.GetString("SessionUserId");
                correctionL2.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(correctionL2);
                string APIEndPoint = "/v1/api/admin/approvals/" + correctionL2.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        /*----  ----    ----    ----    Farmer Service Request   ----    ----    ----    ----*/
        public IActionResult FarmerService()
		{
			return View();
		}
        public IActionResult FarmerServiceAdd()
		{
			return PartialView("_FarmerServiceEntry");
		}
        [HttpPost]
        public IActionResult FarmerService(ReqFarmerService farmer)
        {
            try
            {
                if (farmer.method_name == null || farmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmer.user_id = HttpContext.Session.GetString("SessionUserId");
                farmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(farmer);
                string APIEndPoint = "/v1/api/admin/approvals/" + farmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Agent Service Request   ----    ----    ----    ----*/
        public IActionResult AgentService()
		{
			return View();
		}
        public IActionResult AgentServiceAdd()
		{
			return PartialView("_AgentServiceEntry");
		}
        [HttpPost]
        public IActionResult AgentService(ReqAgentService agent)
        {
            try
            {
                if (agent.method_name == null || agent.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                agent.org_id = HttpContext.Session.GetString("SessionOrgId");
                agent.user_id = HttpContext.Session.GetString("SessionUserId");
                agent.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(agent);
                string APIEndPoint = "/v1/api/admin/approvals/" + agent.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Farmer Incentive   ----    ----    ----    ----*/
        public IActionResult FarmerIncentive()
        {
            return View();
        }
        public IActionResult FarmerIncentiveAdd()
        {
            return PartialView("_FarmerIncentiveEntry");
        }
        [HttpPost]
        public IActionResult FarmerIncentive(ReqFarmerIncentive farmer)
        {
            try
            {
                if (farmer.method_name == null || farmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmer.user_id = HttpContext.Session.GetString("SessionUserId");
                farmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(farmer);
                string APIEndPoint = "/v1/api/admin/approvals/" + farmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Farmer Incentive   ----    ----    ----    ----*/
        public IActionResult AgentIncentive()
		{
			return View();
		}
        public IActionResult AgentIncentiveAdd()
		{
			return PartialView("_AgentIncentiveEntry");
		}
        [HttpPost]
        public IActionResult AgentIncentive(ReqAgentIncentive farmer)
        {
            try
            {
                if (farmer.method_name == null || farmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmer.user_id = HttpContext.Session.GetString("SessionUserId");
                farmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(farmer);
                string APIEndPoint = "/v1/api/admin/approvals/" + farmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Farmer Orders   ----    ----    ----    ----*/
        public IActionResult FarmerOrders()
        {
            return View();
        }
        public IActionResult FarmerOrdersAdd()
        {
            return PartialView("_FarmerOrdersEntry");
        }
        [HttpPost]
        public IActionResult FarmerOrder(ReqFarmerOrder farmer)
        {
            try
            {
                if (farmer.method_name == null || farmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                farmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                farmer.user_id = HttpContext.Session.GetString("SessionUserId");
                farmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(farmer);
                string APIEndPoint = "/v1/api/admin/approvals/" + farmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Agent Orders   ----    ----    ----    ----*/
        public IActionResult AgentOrders()
        {
            return View();
        }
        public IActionResult AgentOrdersAdd()
        {
            return PartialView("_AgentOrdersEntry");
        }
        [HttpPost]
        public IActionResult AgentOrder(ReqAgentOrder agent)
        {
            try
            {
                if (agent.method_name == null || agent.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                agent.org_id = HttpContext.Session.GetString("SessionOrgId");
                agent.user_id = HttpContext.Session.GetString("SessionUserId");
                agent.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(agent);
                string APIEndPoint = "/v1/api/admin/approvals/" + agent.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Milk Collection Request   ----    ----    ----    ----*/
        public IActionResult CollectionRequest()
        {
            return View();
        }
        public IActionResult CollectionRequestAdd()
        {
            return PartialView("_CollectionRequestEntry");
        }
        [HttpPost]
        public IActionResult CollectionRequest(ReqCollectionRequest collectionRequest)
        {
            try
            {
                if (collectionRequest.method_name == null || collectionRequest.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                collectionRequest.org_id = HttpContext.Session.GetString("SessionOrgId");
                collectionRequest.user_id = HttpContext.Session.GetString("SessionUserId");
                collectionRequest.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(collectionRequest);
                string APIEndPoint = "/v1/api/admin/approvals/" + collectionRequest.api_end_point;
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
