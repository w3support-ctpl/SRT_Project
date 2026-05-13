using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.DAL;
using MilkIN_UI.Filters;
using MilkIN_UI.Models;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Text.Json;


namespace MilkIN_UI.Controllers
{
	public class LocationController : Controller
	{
        [LoginAuthFilter("M029", "Display")]
        public IActionResult State()
		{
			return View();
		}

        [LoginAuthFilter("M029", "Add")]
        public IActionResult StateAdd()
		{
			return PartialView("_StateEntry");
		}

        [LoginAuthFilter("M029", "Display")]
        public IActionResult StateEdit()
		{
			return PartialView("_StateEntry");
		}

        [LoginAuthFilter("M030", "Display")]
        public IActionResult District()
		{
            return View();
		}

        [LoginAuthFilter("M030", "Add")]
        public IActionResult DistrictAdd()
		{
			return PartialView("_DistrictEntry");
		}

        [LoginAuthFilter("M030", "Display")]
        public IActionResult DistrictEdit()
		{
			return PartialView("_DistrictEntry");
		}

        [LoginAuthFilter("M032", "Display")]
        public IActionResult Village()
        {
            return View();
        }

        [LoginAuthFilter("M032", "Add")]
        public IActionResult VillageAdd()
        {
            return PartialView("_VillageEntry");
        }

        [LoginAuthFilter("M032", "Display")]
        public IActionResult VillageEdit()
        {
            return PartialView("_VillageEntry");
        }

        [LoginAuthFilter("M031", "Display")]
        public IActionResult Taluka()
		{
			return View();
		}

        [LoginAuthFilter("M031", "Add")]
        public IActionResult TalukaAdd()
		{
			return PartialView("_TalukaEntry");
		}

        [LoginAuthFilter("M031", "Display")]
        public IActionResult TalukaEdit()
		{
			return PartialView("_TalukaEntry");
		}


        [HttpPost]
        public IActionResult State(ReqState state)
        {
            try
            {
                if (state.method_name == null || state.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                state.org_id = HttpContext.Session.GetString("SessionOrgId");
                state.user_id = HttpContext.Session.GetString("SessionUserId");
                state.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(state);
                string APIEndPoint = "/v1/api/admin/location/" + state.api_end_point;
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
        public IActionResult District(ReqDistrict district)
        {
            try
            {
                if (district.method_name == null || district.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                district.org_id = HttpContext.Session.GetString("SessionOrgId");
                district.user_id = HttpContext.Session.GetString("SessionUserId");
                district.user_name = HttpContext.Session.GetString("SessionUserName");
     

                string res_Str = JsonConvert.SerializeObject(district);
                string APIEndPoint = "/v1/api/admin/location/" + district.api_end_point;
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
        public IActionResult Taluka(ReqTaluka taluka)
        {
            try
            {
                if (taluka.method_name == null || taluka.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                taluka.org_id = HttpContext.Session.GetString("SessionOrgId");
                taluka.user_id = HttpContext.Session.GetString("SessionUserId");
                taluka.user_name = HttpContext.Session.GetString("SessionUserName");
                
                string res_Str = JsonConvert.SerializeObject(taluka);
                string APIEndPoint = "/v1/api/admin/location/" + taluka.api_end_point;
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
        public IActionResult Village(ReqVillage village)
        {
            try
            {
                if (village.method_name == null || village.api_end_point == null)
                {
                    return BadRequest();
                }
                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                village.org_id = HttpContext.Session.GetString("SessionOrgId");
                village.user_id = HttpContext.Session.GetString("SessionUserId");
                village.user_name = HttpContext.Session.GetString("SessionUserName");
                
                string res_Str = JsonConvert.SerializeObject(village);
                string APIEndPoint = "/v1/api/admin/location/" + village.api_end_point;
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
