using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Newtonsoft.Json;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/master/")]
    [ApiController]
    public class MastersController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public MastersController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }

        [HttpPost("GetMCC", Name = "GetMCC")]
        public IActionResult GetMCC(ReqMCC mccSearch)
        {
            try
            {
                if (mccSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMCC> res_Obj = new List<ResMCC>();
                string destination_name = mccSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetMCC(mccSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccSearch.destination_name).ApiLog("Create", mccSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(mccSearch), "500", e.Message);

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

        [HttpPost("SaveMCC", Name = "SaveMCC")]
        public IActionResult SaveMCC(ReqMCC mccSave)
        {
            try
            {
                if (mccSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = mccSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveMCC(mccSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(mccSave.destination_name).ApiLog("Create", mccSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(mccSave), "500", e.Message);

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


        [HttpPost("GetPaymentSettings", Name = "GetPaymentSettings")]
        public IActionResult GetPaymentSettings(ReqPaymentSettings paymentSettingsSearch)
        {
            try
            {
                if (paymentSettingsSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResPaymentSettings> res_Obj = new List<ResPaymentSettings>();
                string destination_name = paymentSettingsSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetPaymentSettings(paymentSettingsSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(paymentSettingsSearch.destination_name).ApiLog("Create", paymentSettingsSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(paymentSettingsSearch), "500", e.Message);

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

        [HttpPost("SavePaymentSettings", Name = "SavePaymentSettings")]
        public IActionResult SavePaymentSettings(ReqPaymentSettings paymentSettingsSave)
        {
            try
            {
                if (paymentSettingsSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = paymentSettingsSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SavePaymentSettings(paymentSettingsSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(paymentSettingsSave.destination_name).ApiLog("Create", paymentSettingsSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(paymentSettingsSave), "500", e.Message);

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


        [HttpPost("GetTransporter", Name = "GetTransporter")]
        public IActionResult GetTransporter(ReqTransporter transporterSearch)
        {
            try
            {
                if (transporterSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResTransporter> res_Obj = new List<ResTransporter>();
                string destination_name = transporterSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetTransporter(transporterSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(transporterSearch.destination_name).ApiLog("Create", transporterSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(transporterSearch), "500", e.Message);

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

        [HttpPost("SaveTransporter", Name = "SaveTransporter")]
        public IActionResult SaveTransporter(ReqTransporter transporterSave)
        {
            try
            {
                if (transporterSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = transporterSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveTransporter(transporterSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(transporterSave.destination_name).ApiLog("Create", transporterSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(transporterSave), "500", e.Message);

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
        [HttpPost("GetVehicle", Name = "GetVehicle")]
        public IActionResult GetVehicle(ReqVehicle vehicleSearch)
        {
            try
            {
                if (vehicleSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResVehicle> res_Obj = new List<ResVehicle>();
                string destination_name = vehicleSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetVehicle(vehicleSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(vehicleSearch.destination_name).ApiLog("Create", vehicleSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(vehicleSearch), "500", e.Message);

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

        [HttpPost("SaveVehicle", Name = "SaveVehicle")]
        public IActionResult SaveVehicle(ReqVehicle vehicleSave)
        {
            try
            {
                if (vehicleSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = vehicleSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveVehicle(vehicleSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(vehicleSave.destination_name).ApiLog("Create", vehicleSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(vehicleSave), "500", e.Message);

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



        [HttpPost("GetMaterial", Name = "GetMaterial")]
        public IActionResult GetMaterial(ReqMaterial materialSearch)
        {
            try
            {
                if (materialSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMaterial> res_Obj = new List<ResMaterial>();
                string destination_name = materialSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetMaterial(materialSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(materialSearch.destination_name).ApiLog("Create", materialSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(materialSearch), "500", e.Message);

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

        [HttpPost("SaveMaterial", Name = "SaveMaterial")]
        public IActionResult SaveMaterial(ReqMaterial materialSave)
        {
            try
            {
                if (materialSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = materialSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveMaterial(materialSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(materialSave.destination_name).ApiLog("Create", materialSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(materialSave), "500", e.Message);

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


        [HttpPost("GetMastersProduct", Name = "GetMastersProduct")]
        public IActionResult GetProduct(ReqProduct productSearch)
        {
            try
            {
                if (productSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResProduct> res_Obj = new List<ResProduct>();
                string destination_name = productSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetProduct(productSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(productSearch.destination_name).ApiLog("Create", productSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(productSearch), "500", e.Message);

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
        [HttpPost("SaveMasterProduct", Name = "SaveMasterProduct")]
        public IActionResult SaveProduct(ReqProduct productSave)
        {
            try
            {
                if (productSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = productSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveProduct(productSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(productSave.destination_name).ApiLog("Create", productSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(productSave), "500", e.Message);

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



        [HttpPost("SaveProductMasterSAP", Name = "SaveProductMasterSAP")]
        public IActionResult SaveProductMasterSAP(ReqProduct productSave)
        {
            try
            {
                if (productSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = productSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveSAPProductMaster(productSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(productSave.destination_name).ApiLog("Create", productSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(productSave), "500", e.Message);

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


        [HttpPost("SaveMaterialMasterSAP", Name = "SaveMaterialMasterSAP")]
        public IActionResult SaveMaterialMasterSAP(ReqMaterial materialSave)
        {
            try
            {
                if (materialSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = materialSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveSAPMaterialMaster(materialSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(materialSave.destination_name).ApiLog("Create", materialSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(materialSave), "500", e.Message);

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


        [HttpPost("GetIncentiveScheme", Name = "GetIncentiveScheme")]
        public IActionResult GetIncentiveScheme(ReqIncentiveScheme incentiveSchemeSearch)
        {
            try
            {
                if (incentiveSchemeSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResIncentiveScheme> res_Obj = new List<ResIncentiveScheme>();
                string destination_name = incentiveSchemeSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetIncentiveScheme(incentiveSchemeSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSchemeSearch.destination_name).ApiLog("Create", incentiveSchemeSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(incentiveSchemeSearch), "500", e.Message);

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

        [HttpPost("SaveIncentiveScheme", Name = "SaveIncentiveScheme")]
        public IActionResult SaveIncentiveScheme(ReqIncentiveScheme incentiveSchemeSave)
        {
            try
            {
                if (incentiveSchemeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = incentiveSchemeSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveIncentiveScheme(incentiveSchemeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSchemeSave.destination_name).ApiLog("Create", incentiveSchemeSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(incentiveSchemeSave), "500", e.Message);

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

        [HttpPost("GetIncentiveSchemeMCC", Name = "GetIncentiveSchemeMCC")]
        public IActionResult GetIncentiveSchemeMCC(ReqIncentiveScheme incentiveSchemeSearch)
        {
            try
            {
                if (incentiveSchemeSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResIncentiveScheme> res_Obj = new List<ResIncentiveScheme>();
                string destination_name = incentiveSchemeSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetIncentiveSchemeMCC(incentiveSchemeSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSchemeSearch.destination_name).ApiLog("Create", incentiveSchemeSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(incentiveSchemeSearch), "500", e.Message);

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

        [HttpPost("SaveIncentiveSchemeMCC", Name = "SaveIncentiveSchemeMCC")]
        public IActionResult SaveIncentiveSchemeMCC(ReqIncentiveScheme incentiveSchemeSave)
        {
            try
            {
                if (incentiveSchemeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = incentiveSchemeSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveIncentiveSchemeMCC(incentiveSchemeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(incentiveSchemeSave.destination_name).ApiLog("Create", incentiveSchemeSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(incentiveSchemeSave), "500", e.Message);

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



        [HttpPost("GetServices", Name = "GetServices")]
        public IActionResult GetServices(ReqServices servicesSearch)
        {
            try
            {
                if (servicesSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResServices> res_Obj = new List<ResServices>();
                string destination_name = servicesSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetServices(servicesSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(servicesSearch.destination_name).ApiLog("Create", servicesSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(servicesSearch), "500", e.Message);

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

        [HttpPost("SaveServices", Name = "SaveServices")]
        public IActionResult SaveServices(ReqServices servicesSave)
        {
            try
            {
                if (servicesSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = servicesSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveServices(servicesSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(servicesSave.destination_name).ApiLog("Create", servicesSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(servicesSave), "500", e.Message);

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


        [HttpPost("GetRole", Name = "GetRole")]
        public IActionResult GetRole(ReqRole roleSearch)
        {
            try
            {
                if (roleSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRole> res_Obj = new List<ResRole>();
                string destination_name = roleSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetRole(roleSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(roleSearch.destination_name).ApiLog("Create", roleSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(roleSearch), "500", e.Message);

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


        [HttpPost("SaveRole", Name = "SaveRole")]
        public IActionResult SaveRole(ReqRole roleSave)
        {
            try
            {
                if (roleSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = roleSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveRole(roleSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(roleSave.destination_name).ApiLog("Create", roleSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(roleSave), "500", e.Message);

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


        [HttpPost("GetBank", Name = "GetBank")]
        public IActionResult GetBank(ReqBank bankSearch)
        {
            try
            {
                if (bankSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResBank> res_Obj = new List<ResBank>();
                string destination_name = bankSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetBank(bankSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(bankSearch.destination_name).ApiLog("Create", bankSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(bankSearch), "500", e.Message);

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

        [HttpPost("SaveBank", Name = "SaveBank")]
        public IActionResult SaveBank(ReqBank bankSave)
        {
            try
            {
                if (bankSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = bankSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveBank(bankSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(bankSave.destination_name).ApiLog("Create", bankSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(bankSave), "500", e.Message);

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

        [HttpPost("GetBankBranch", Name = "GetBankBranch")]
        public IActionResult GetBankBranch(ReqBankBranch bankBranchSearch)
        {
            try
            {
                if (bankBranchSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResBankBranch> res_Obj = new List<ResBankBranch>();
                string destination_name = bankBranchSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetBankBranch(bankBranchSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(bankBranchSearch.destination_name).ApiLog("Create", bankBranchSearch.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(bankBranchSearch), "500", e.Message);

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

        [HttpPost("SaveBankBranch", Name = "SaveBankBranch")]
        public IActionResult SaveBankBranch(ReqBankBranch bankBranchSave)
        {
            try
            {
                if (bankBranchSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = bankBranchSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveBankBranch(bankBranchSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(bankBranchSave.destination_name).ApiLog("Create", bankBranchSave.org_id, "MastersController", currentUrl, JsonConvert.SerializeObject(bankBranchSave), "500", e.Message);

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
