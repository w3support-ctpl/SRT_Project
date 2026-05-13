using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Routing;
using MilkIN_UI.DAL;
using MilkIN_UI.Filters;
using MilkIN_UI.Models;
using Newtonsoft.Json;
//using Newtonsoft.Json;
using System.Text.Json;


namespace MilkIN_UI.Controllers
{
    public class MastersController : Controller
    {
        [LoginAuthFilter("M019", "Display")]
        public IActionResult MCC()
        {
            return View();
        }

        [LoginAuthFilter("M019", "Add")]
        public IActionResult MCCAdd()
        {
            return PartialView("_MCCEntry");
        }

        [LoginAuthFilter("M019", "Display")]
        public IActionResult MCCEdit()
        {
            return PartialView("_MCCEntry");
        }

        [HttpPost]
        public IActionResult MCC(ReqMCC mcc)
        {
            try
            {
                if (mcc.method_name == null || mcc.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                mcc.org_id = HttpContext.Session.GetString("SessionOrgId");
                mcc.user_id = HttpContext.Session.GetString("SessionUserId");
                mcc.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(mcc);
                string APIEndPoint = "/v1/api/admin/master/" + mcc.api_end_point;
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
        public IActionResult PaymentSettings(ReqPaymentSettings paymentSettings)
        {
            try
            {
                if (paymentSettings.method_name == null || paymentSettings.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                paymentSettings.org_id = HttpContext.Session.GetString("SessionOrgId");
                paymentSettings.user_id = HttpContext.Session.GetString("SessionUserId");
                paymentSettings.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(paymentSettings);
                string APIEndPoint = "/v1/api/admin/master/" + paymentSettings.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M018", "Display")]
        public IActionResult Transporter()
        {
            return View();
        }

        [LoginAuthFilter("M018", "Add")]
        public IActionResult TransporterAdd()
        {
            return PartialView("_TransporterEntry");
        }

        [LoginAuthFilter("M018", "Display")]
        public IActionResult TransporterEdit()
        {
            return PartialView("_TransporterEntry");
        }

        [HttpPost]
        public IActionResult Transporter(ReqTransporter transporter)
        {
            try
            {
                if (transporter.method_name == null || transporter.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                transporter.org_id = HttpContext.Session.GetString("SessionOrgId");
                transporter.user_id = HttpContext.Session.GetString("SessionUserId");
                transporter.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(transporter);
                string APIEndPoint = "/v1/api/admin/master/" + transporter.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M013", "Display")]
        public IActionResult Vehicle()
        {
            return View();
        }

        [LoginAuthFilter("M013", "Add")]
        public IActionResult VehicleAdd()
        {
            return PartialView("_VehicleEntry");
        }

        [LoginAuthFilter("M013", "Display")]
        public IActionResult VehicleEdit()
        {
            return PartialView("_VehicleEntry");
        }

        [HttpPost]
        public IActionResult Vehicle(ReqVehicle vehicle)
        {
            try
            {
                if (vehicle.method_name == null || vehicle.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                vehicle.org_id = HttpContext.Session.GetString("SessionOrgId");
                vehicle.user_id = HttpContext.Session.GetString("SessionUserId");
                vehicle.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(vehicle);
                string APIEndPoint = "/v1/api/admin/master/" + vehicle.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [LoginAuthFilter("M008", "Display")]
        public IActionResult Role()
        {
            return View();
        }

        [LoginAuthFilter("M008", "Add")]
        public IActionResult RoleAdd()
        {
            return PartialView("_RoleEntry");
        }

        [LoginAuthFilter("M008", "Display")]
        public IActionResult RoleEdit()
        {
            return PartialView("_RoleEntry");
        }

        [HttpPost]
        public IActionResult Role(ReqRole role)
        {
            try
            {
                if (role.method_name == null || role.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                role.org_id = HttpContext.Session.GetString("SessionOrgId");
                role.user_id = HttpContext.Session.GetString("SessionUserId");
                role.user_name = HttpContext.Session.GetString("SessionUserName");
                role.application_id = "MI";

                string res_Str = JsonConvert.SerializeObject(role);
                string APIEndPoint = "/v1/api/admin/master/" + role.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [LoginAuthFilter("M016", "Display")]
        public IActionResult Services()
        {
            return View();
        }

        [LoginAuthFilter("M016", "Add")]
        public IActionResult ServicesAdd()
        {
            return PartialView("_ServicesEntry");
        }

        [LoginAuthFilter("M016", "Display")]
        public IActionResult ServicesEdit()
        {
            return PartialView("_ServicesEntry");
        }
        [HttpPost]
        public IActionResult Services(ReqServices services)
        {
            try
            {
                if (services.method_name == null || services.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                services.org_id = HttpContext.Session.GetString("SessionOrgId");
                services.user_id = HttpContext.Session.GetString("SessionUserId");
                services.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(services);
                string APIEndPoint = "/v1/api/admin/master/" + services.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M017", "Display")]
        public IActionResult Facilities()
        {
            return View();
        }

        [LoginAuthFilter("M017", "Add")]
        public IActionResult FacilitiesAdd()
        {
            return PartialView("_FacilitiesEntry");
        }

        [LoginAuthFilter("M017", "Display")]
        public IActionResult FacilitiesEdit()
        {
            return PartialView("_FacilitiesEntry");
        }

        [LoginAuthFilter("M021", "Display")]
        public IActionResult Material()
        {
            return View();
        }

        [LoginAuthFilter("M021", "Add")]
        public IActionResult MaterialAdd()
        {
            return PartialView("_MaterialEntry");
        }

        [LoginAuthFilter("M021", "Display")]
        public IActionResult MaterialEdit()
        {
            return PartialView("_MaterialEntry");
        }
        // GET Material
        [HttpPost]
        public IActionResult Material(ReqMaterial material)
        {
            try
            {
                if (material.method_name == null || material.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                material.org_id = HttpContext.Session.GetString("SessionOrgId");
                material.user_id = HttpContext.Session.GetString("SessionUserId");
                material.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(material);
                string APIEndPoint = "/v1/api/admin/master/" + material.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }

        [LoginAuthFilter("M010", "Display")]
        public IActionResult IncentiveScheme()
        {
            return View();
        }

        [LoginAuthFilter("M010", "Add")]
        public IActionResult IncentiveSchemeAdd()
        {
            return PartialView("_IncentiveSchemeEntry");
        }

        [LoginAuthFilter("M010", "Display")]
        public IActionResult IncentiveSchemeEdit()
        {
            return PartialView("_IncentiveSchemeEntry");
        }

        // Save Incentive Scheme
        [HttpPost]
        public IActionResult IncentiveScheme(ReqIncentiveScheme incentiveScheme)
        {
            try
            {
                if (incentiveScheme.method_name == null || incentiveScheme.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                incentiveScheme.org_id = HttpContext.Session.GetString("SessionOrgId");
                incentiveScheme.user_id = HttpContext.Session.GetString("SessionUserId");
                incentiveScheme.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(incentiveScheme);
                string APIEndPoint = "/v1/api/admin/master/" + incentiveScheme.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        // GET IncentiveScheme
        [HttpPost]
        public IActionResult GetIncentiveScheme(ReqIncentiveScheme incentiveSchemeSearch)
        {
            try
            {
                if (incentiveSchemeSearch.method_name == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                incentiveSchemeSearch.org_id = HttpContext.Session.GetString("SessionOrgId");
                incentiveSchemeSearch.user_id = HttpContext.Session.GetString("SessionUserId");
                incentiveSchemeSearch.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(incentiveSchemeSearch);
                string APIEndPoint = "/v1/api/admin/master/" + incentiveSchemeSearch.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }

        }

        [LoginAuthFilter("M055", "Display")]
        public IActionResult Bank()
        {
            return View();
        }

        [LoginAuthFilter("M055", "Add")]
        public IActionResult BankAdd()
        {
            return PartialView("_BankEntry");
        }

        [LoginAuthFilter("M055", "Display")]
        public IActionResult BankEdit()
        {
            return PartialView("_BankEntry");
        }

        [HttpPost]
        public IActionResult Bank(ReqBank bank)
        {
            try
            {
                if (bank.method_name == null || bank.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                bank.org_id = HttpContext.Session.GetString("SessionOrgId");
                bank.user_id = HttpContext.Session.GetString("SessionUserId");
                bank.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(bank);
                string APIEndPoint = "/v1/api/admin/master/" + bank.api_end_point;
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
        public IActionResult BankBranch(ReqBankBranch bankBranch)
        {
            try
            {
                if (bankBranch.method_name == null || bankBranch.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                bankBranch.org_id = HttpContext.Session.GetString("SessionOrgId");
                bankBranch.user_id = HttpContext.Session.GetString("SessionUserId");
                bankBranch.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(bankBranch);
                string APIEndPoint = "/v1/api/admin/master/" + bankBranch.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M054", "Display")]
        public IActionResult Product()
        {
            return View();
        }
        [HttpPost]
        public IActionResult Product(ReqProduct product)
        {
            try
            {
                if (product.method_name == null || product.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                product.org_id = HttpContext.Session.GetString("SessionOrgId");
                product.user_id = HttpContext.Session.GetString("SessionUserId");
                product.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(product);
                string APIEndPoint = "/v1/api/admin/master/" + product.api_end_point;
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
