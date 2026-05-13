using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.DAL;
using MilkIN_UI.Filters;
using MilkIN_UI.Models;
using Newtonsoft.Json;
using System.Text.Json;

namespace MilkIN_UI.Controllers
{
    public class RateController : Controller
    {
        [LoginAuthFilter("M009", "Display")]
        public IActionResult Milk()
        {
            return View();
        }

        [LoginAuthFilter("M009", "Add")]
        public IActionResult MilkAdd()
		{
			return PartialView("_MilkEntry");
		}

        [LoginAuthFilter("M009", "Display")]
        public IActionResult MilkEdit()
		{
			return PartialView("_MilkEntry");
		}
        
        [HttpPost]
        public IActionResult MilkRate(ReqMilkRate milkRate)
        {
            try
            {
                if (milkRate.method_name == null || milkRate.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkRate.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkRate.user_id = HttpContext.Session.GetString("SessionUserId");
                milkRate.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkRate);
                string APIEndPoint = "/v1/api/admin/rate/" + milkRate.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost]
        public IActionResult MilkRateItem(ReqMilkRateItem milkRateItem)
        {
            try
            {
                if (milkRateItem.method_name == null || milkRateItem.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkRateItem.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkRateItem.user_id = HttpContext.Session.GetString("SessionUserId");
                milkRateItem.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkRateItem);
                string APIEndPoint = "/v1/api/admin/rate/" + milkRateItem.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost]
        public IActionResult MilkRateMCC(ReqMilkRateMCC milkRateMCC)
        {
            try
            {
                if (milkRateMCC.method_name == null || milkRateMCC.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkRateMCC.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkRateMCC.user_id = HttpContext.Session.GetString("SessionUserId");
                milkRateMCC.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkRateMCC);
                string APIEndPoint = "/v1/api/admin/rate/" + milkRateMCC.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        
        public IActionResult MilkMCCEntry()
        {
            return PartialView("_MilkMCCEntry");
        }
        public IActionResult MilkRateView()
        {
            return PartialView("_MilkRateView"); ;
        }
        public IActionResult MilkRateMCCView()
        {
            return PartialView("_MilkRateMCCView"); ;
        }
        [HttpPost]
        public IActionResult MilkRateView(ReqMilkRate milkRate)
        {
            try
            {
                if (milkRate.method_name == null || milkRate.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkRate.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkRate.user_id = HttpContext.Session.GetString("SessionUserId");
                milkRate.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkRate);
                string APIEndPoint = "/v1/api/admin/rate/" + milkRate.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M015", "Display")]
        public IActionResult Freight()
        {
            return View();
        }

        [LoginAuthFilter("M015", "Add")]
        public IActionResult FreightAdd()
        {
            return PartialView("_FreightEntry");
        }

        [LoginAuthFilter("M015", "Display")]
        public IActionResult FreightEdit()
        {
            return PartialView("_FreightEntry");
        }
        [HttpPost]
        public IActionResult Freight(ReqFreight freight)
        {
            try
            {
                if (freight.method_name == null || freight.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                freight.org_id = HttpContext.Session.GetString("SessionOrgId");
                freight.user_id = HttpContext.Session.GetString("SessionUserId");
                freight.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(freight);
                string APIEndPoint = "/v1/api/admin/rate/" + freight.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost]
        public IActionResult Slab(ReqSlab slab)
        {
            try
            {
                if (slab.method_name == null || slab.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                slab.org_id = HttpContext.Session.GetString("SessionOrgId");
                slab.user_id = HttpContext.Session.GetString("SessionUserId");
                slab.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(slab);
                string APIEndPoint = "/v1/api/admin/rate/" + slab.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M051", "Display")]
        public IActionResult SNFSlab()
        {
            return View();
        }

        [LoginAuthFilter("M051", "Add")]
        public IActionResult SNFSlabAdd()
        {
            return PartialView("_SNFSlabEntry");
        }

        [LoginAuthFilter("M051", "Display")]
        public IActionResult SNFSlabEdit()
        {
            return PartialView("_SNFSlabEntry");
        }

        [LoginAuthFilter("M052", "Display")]
        public IActionResult FatSlab()
        {
            return View();
        }

        [LoginAuthFilter("M052", "Add")]
        public IActionResult FatSlabAdd()
        {
            return PartialView("_FatSlabEntry");
        }

        [LoginAuthFilter("M052", "Display")]
        public IActionResult FatSlabEdit()
        {
            return PartialView("_FatSlabEntry");
        }

        [LoginAuthFilter("M053", "Display")]
        public IActionResult Diesel()
        {
            return View();
        }

        [LoginAuthFilter("M053", "Add")]
        public IActionResult DieselAdd()
        {
            return PartialView("_DieselEntry");
        }

        [LoginAuthFilter("M053", "Display")]
        public IActionResult DieselEdit()
        {
            return PartialView("_DieselEntry");
        }
        [HttpPost]
        public IActionResult Diesel(ReqDiesel diesel)
        {
            try
            {
                if (diesel.method_name == null || diesel.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                diesel.org_id = HttpContext.Session.GetString("SessionOrgId");
                diesel.user_id = HttpContext.Session.GetString("SessionUserId");
                diesel.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(diesel);
                string APIEndPoint = "/v1/api/admin/rate/" + diesel.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M011", "Display")]
        public IActionResult MCCCommission()
        {
            return View();
        }

        [LoginAuthFilter("M011", "Add")]
        public IActionResult MCCCommissionAdd()
        {
            return PartialView("_MCCCommissionEntry");
        }

        [LoginAuthFilter("M011", "Display")]
        public IActionResult MCCCommissionEdit()
        {
            return PartialView("_MCCCommissionEntry");
        }
        public IActionResult MCCCommissionMCCEntry()
        {
            return PartialView("_MCCCommissionMCCEntry");
        }
        public IActionResult MCCCommissionAssignMCCEntry()
        {
            return PartialView("_MCCCommissionAssignMCCEntry");
        }
        [HttpPost]
        public IActionResult MCCCommission(ReqMCCCommission mccCommission)
        {
            try
            {
                if (mccCommission.method_name == null || mccCommission.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                mccCommission.org_id = HttpContext.Session.GetString("SessionOrgId");
                mccCommission.user_id = HttpContext.Session.GetString("SessionUserId");
                mccCommission.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(mccCommission);
                string APIEndPoint = "/v1/api/admin/rate/" + mccCommission.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);


            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost]
        public IActionResult MCCCommissionItem(ReqMCCCommissionItem mccCommissionItem)
        {
            try
            {
                if (mccCommissionItem.method_name == null || mccCommissionItem.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                mccCommissionItem.org_id = HttpContext.Session.GetString("SessionOrgId");
                mccCommissionItem.user_id = HttpContext.Session.GetString("SessionUserId");
                mccCommissionItem.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(mccCommissionItem);
                string APIEndPoint = "/v1/api/admin/rate/" + mccCommissionItem.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);


            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost]
        public IActionResult MCCCommissionMCC(ReqMCCCommissionMCC mccCommissionMCC)
        {
            try
            {
                if (mccCommissionMCC.method_name == null || mccCommissionMCC.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                mccCommissionMCC.org_id = HttpContext.Session.GetString("SessionOrgId");
                mccCommissionMCC.user_id = HttpContext.Session.GetString("SessionUserId");
                mccCommissionMCC.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(mccCommissionMCC);
                string APIEndPoint = "/v1/api/admin/rate/" + mccCommissionMCC.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);


            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M065", "Display")]
        public IActionResult FatSNFRatio()
        {
            return View();
        }

        [LoginAuthFilter("M065", "Add")]
        public IActionResult FatSNFRatioAdd()
        {
            return PartialView("_FatSNFRatioEntry");
        }

        [LoginAuthFilter("M065", "Display")]
        public IActionResult FatSNFRatioEdit()
        {
            return PartialView("_FatSNFRatioEntry");
        }
        [HttpPost]
        public IActionResult FatSNFRatio(ReqFatSNFRatio fatSNFRatio)
        {
            try
            {
                if (fatSNFRatio.method_name == null || fatSNFRatio.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                fatSNFRatio.org_id = HttpContext.Session.GetString("SessionOrgId");
                fatSNFRatio.user_id = HttpContext.Session.GetString("SessionUserId");
                fatSNFRatio.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(fatSNFRatio);
                string APIEndPoint = "/v1/api/admin/rate/" + fatSNFRatio.api_end_point;
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
