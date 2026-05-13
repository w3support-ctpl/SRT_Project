using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using Middleware;
using Newtonsoft.Json;


namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/invoice/")]
    [ApiController]
    public class InvoiceController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public InvoiceController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }

        /*----  ----    ----    ----    Invoice Farmer Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetInvoiceFarmer", Name = "GetInvoiceFarmer")]
        public IActionResult GetInvoiceFarmer(ReqInvoiceFarmer invoiceFarmerSearch)
        {
            try
            {

                if (invoiceFarmerSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInvoiceFarmer> res_Obj = new List<ResInvoiceFarmer>();
                string destination_name = invoiceFarmerSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetInvoiceFarmer(invoiceFarmerSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceFarmerSearch.destination_name).ApiLog("Create", invoiceFarmerSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceFarmerSearch), "500", e.Message);

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

        [HttpPost("SaveInvoiceFarmer", Name = "SaveInvoiceFarmer")]
        public IActionResult SaveInvoiceFarmer(ReqInvoiceFarmer invoiceFarmerSave)
        {
            try
            {
                if (invoiceFarmerSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceFarmerSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceFarmer(invoiceFarmerSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceFarmerSave.destination_name).ApiLog("Create", invoiceFarmerSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceFarmerSave), "500", e.Message);

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

        [HttpPost("SaveInvoiceFarmerInSap", Name = "SaveInvoiceFarmerInSap")]
        public IActionResult SaveInvoiceFarmerInSap(ReqInvoiceFarmer invoiceFarmerSave)
        {
            try
            {
                if (invoiceFarmerSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceFarmerSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceFarmerInSap(invoiceFarmerSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceFarmerSave.destination_name).ApiLog("Create", invoiceFarmerSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceFarmerSave), "500", e.Message);

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



        /*----  ----    ----    ----    Invoice MCC Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetInvoiceMCC", Name = "GetInvoiceMCC")]
        public IActionResult GetInvoiceMCC(ReqInvoiceMCC invoiceMCCSearch)
        {
            try
            {

                if (invoiceMCCSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInvoiceMCC> res_Obj = new List<ResInvoiceMCC>();
                string destination_name = invoiceMCCSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetInvoiceMCC(invoiceMCCSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceMCCSearch.destination_name).ApiLog("Create", invoiceMCCSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceMCCSearch), "500", e.Message);

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

        [HttpPost("SaveInvoiceMCC", Name = "SaveInvoiceMCC")]
        public IActionResult SaveInvoiceMCC(ReqInvoiceMCC invoiceMCCSave)
        {
            try
            {
                if (invoiceMCCSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceMCCSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceMCC(invoiceMCCSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceMCCSave.destination_name).ApiLog("Create", invoiceMCCSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceMCCSave), "500", e.Message);

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


        [HttpPost("SaveInvoiceMCCInSap", Name = "SaveInvoiceMCCInSap")]
        public IActionResult SaveInvoiceMCCInSap(ReqInvoiceMCC invoiceMCCSave)
        {
            try
            {
                if (invoiceMCCSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceMCCSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceMCCInSap(invoiceMCCSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceMCCSave.destination_name).ApiLog("Create", invoiceMCCSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceMCCSave), "500", e.Message);

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




        /*----  ----    ----    ----    Invoice Transporter Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetInvoiceTransporter", Name = "GetInvoiceTransporter")]
        public IActionResult GetInvoiceTransporter(ReqInvoiceTransporter invoiceTransporterSearch)
        {
            try
            {

                if (invoiceTransporterSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInvoiceTransporter> res_Obj = new List<ResInvoiceTransporter>();
                string destination_name = invoiceTransporterSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetInvoiceTransporter(invoiceTransporterSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceTransporterSearch.destination_name).ApiLog("Create", invoiceTransporterSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceTransporterSearch), "500", e.Message);

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

        [HttpPost("SaveInvoiceTransporter", Name = "SaveInvoiceTransporter")]
        public IActionResult SaveInvoiceTransporter(ReqInvoiceTransporter invoiceTransporterSave)
        {
            try
            {
                if (invoiceTransporterSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceTransporterSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceTransporter(invoiceTransporterSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceTransporterSave.destination_name).ApiLog("Create", invoiceTransporterSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceTransporterSave), "500", e.Message);

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


        [HttpPost("SaveInvoiceTransporterInSap", Name = "SaveInvoiceTransporterInSap")]
        public IActionResult SaveInvoiceTransporterInSap(ReqInvoiceTransporter invoiceTransporterSave)
        {
            try
            {
                if (invoiceTransporterSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceTransporterSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceTransporterInSap(invoiceTransporterSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceTransporterSave.destination_name).ApiLog("Create", invoiceTransporterSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceTransporterSave), "500", e.Message);

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





        /*----  ----    ----    ----    Invoice Farmer Income Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetInvoiceFarmerIncome", Name = "GetInvoiceFarmerIncome")]
        public IActionResult GetInvoiceFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSearch)
        {
            try
            {

                if (invoiceFarmerIncomeSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInvoiceFarmerIncome> res_Obj = new List<ResInvoiceFarmerIncome>();
                string destination_name = invoiceFarmerIncomeSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetInvoiceFarmerIncome(invoiceFarmerIncomeSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceFarmerIncomeSearch.destination_name).ApiLog("Create", invoiceFarmerIncomeSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceFarmerIncomeSearch), "500", e.Message);

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

        [HttpPost("SaveInvoiceFarmerIncome", Name = "SaveInvoiceFarmerIncome")]
        public IActionResult SaveInvoiceFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSave)
        {
            try
            {
                if (invoiceFarmerIncomeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceFarmerIncomeSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceFarmerIncome(invoiceFarmerIncomeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceFarmerIncomeSave.destination_name).ApiLog("Create", invoiceFarmerIncomeSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceFarmerIncomeSave), "500", e.Message);

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



        [HttpPost("SavedInvoiceFarmerIncome", Name = "SavedInvoiceFarmerIncome")]
        public IActionResult SavedInvoiceFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSave)
        {
            try
            {
                if (invoiceFarmerIncomeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceFarmerIncomeSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SavedInvoiceFarmerIncome(invoiceFarmerIncomeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceFarmerIncomeSave.destination_name).ApiLog("Create", invoiceFarmerIncomeSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceFarmerIncomeSave), "500", e.Message);

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



        [HttpPost("SavedInvoicedFarmerIncome", Name = "SavedInvoicedFarmerIncome")]
        public IActionResult SavedInvoicedFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncomeSave)
        {
            try
            {
                if (invoiceFarmerIncomeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceFarmerIncomeSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SavedInvoicedFarmerIncome(invoiceFarmerIncomeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceFarmerIncomeSave.destination_name).ApiLog("Create", invoiceFarmerIncomeSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceFarmerIncomeSave), "500", e.Message);

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

        [HttpPost("GetInvoicePublish", Name = "GetInvoicePublish")]
        public IActionResult GetInvoicePublish(ReqInvoicePublish invoicePublishSearch)
        {
            try
            {

                if (invoicePublishSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInvoicePublish> res_Obj = new List<ResInvoicePublish>();
                string destination_name = invoicePublishSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetInvoicePublish(invoicePublishSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoicePublishSearch.destination_name).ApiLog("Create", invoicePublishSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoicePublishSearch), "500", e.Message);

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

        [HttpPost("SaveInvoicePublish", Name = "SaveInvoicePublish")]
        public IActionResult SaveInvoicePublish(ReqInvoicePublish invoicePublishSave)
        {
            try
            {
                if (invoicePublishSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoicePublishSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoicePublish(invoicePublishSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoicePublishSave.destination_name).ApiLog("Create", invoicePublishSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoicePublishSave), "500", e.Message);

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



        [HttpPost("GetMissingFarmer", Name = "GetMissingFarmer")]
        public IActionResult GetMissingFarmer(ReqMissingFarmer missingFarmerSearch)
        {
            try
            {

                if (missingFarmerSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMissingFarmer> res_Obj = new List<ResMissingFarmer>();
                string destination_name = missingFarmerSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetMissingFarmer(missingFarmerSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(missingFarmerSearch.destination_name).ApiLog("Create", missingFarmerSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(missingFarmerSearch), "500", e.Message);

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

        [HttpPost("SaveMissingFarmer", Name = "SaveMissingFarmer")]
        public IActionResult SaveMissingFarmer(ReqMissingFarmer missingFarmerSave)
        {
            try
            {
                if (missingFarmerSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = missingFarmerSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveMissingFarmer(missingFarmerSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(missingFarmerSave.destination_name).ApiLog("Create", missingFarmerSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(missingFarmerSave), "500", e.Message);

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


        [HttpPost("GetRebate", Name = "GetRebate")]
        public IActionResult GetRebate(ReqRebate rebateSearch)
        {
            try
            {

                if (rebateSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRebate> res_Obj = new List<ResRebate>();
                string destination_name = rebateSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetRebate(rebateSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(rebateSearch.destination_name).ApiLog("Create", rebateSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(rebateSearch), "500", e.Message);

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


        [HttpPost("SaveRebate", Name = "SaveRebate")]
        public IActionResult SaveRebate(ReqRebate rebateSave)
        {
            try
            {
                if (rebateSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = rebateSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveRebate(rebateSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(rebateSave.destination_name).ApiLog("Create", rebateSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(rebateSave), "500", e.Message);


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



        /*----  ----    ----    ----    Invoice Rate Change Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetInvoiceRateChange", Name = "GetInvoiceRateChange")]
        public IActionResult GetInvoiceRateChange(ReqInvoiceRateChange invoiceInvoiceRateSearch)
        {
            try
            {

                if (invoiceInvoiceRateSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInvoiceRateChange> res_Obj = new List<ResInvoiceRateChange>();
                string destination_name = invoiceInvoiceRateSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetInvoiceRateChange(invoiceInvoiceRateSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceInvoiceRateSearch.destination_name).ApiLog("Create", invoiceInvoiceRateSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceInvoiceRateSearch), "500", e.Message);


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

        [HttpPost("SaveInvoiceRateChange", Name = "SaveInvoiceRateChange")]
        public IActionResult SaveInvoiceRateChange(ReqInvoiceRateChange invoiceRateChangeSave)
        {
            try
            {
                if (invoiceRateChangeSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceRateChangeSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceRateChange(invoiceRateChangeSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceRateChangeSave.destination_name).ApiLog("Create", invoiceRateChangeSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceRateChangeSave), "500", e.Message);


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


        /*----  ----    ----    ----    Invoice SAP Posting Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetInvoiceSAPPosting", Name = "GetInvoiceSAPPosting")]
        public IActionResult GetInvoiceSAPPosting(ReqInvoiceSAPPosting invoiceInvoiceSAPPostingSearch)
        {
            try
            {

                if (invoiceInvoiceSAPPostingSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResInvoiceSAPPosting> res_Obj = new List<ResInvoiceSAPPosting>();
                string destination_name = invoiceInvoiceSAPPostingSearch.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).GetInvoiceSAPPosting(invoiceInvoiceSAPPostingSearch);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceInvoiceSAPPostingSearch.destination_name).ApiLog("Create", invoiceInvoiceSAPPostingSearch.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceInvoiceSAPPostingSearch), "500", e.Message);


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

        [HttpPost("SaveInvoiceSAPPosting", Name = "SaveInvoiceSAPPosting")]
        public IActionResult SaveInvoiceSAPPosting(ReqInvoiceSAPPosting invoiceSAPPostingSave)
        {
            try
            {
                if (invoiceSAPPostingSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = invoiceSAPPostingSave.destination_name + "";
                res_Obj = new InvoiceDAL(destination_name).SaveInvoiceSAPPosting(invoiceSAPPostingSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {

                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(invoiceSAPPostingSave.destination_name).ApiLog("Create", invoiceSAPPostingSave.org_id, "InvoiceController", currentUrl, JsonConvert.SerializeObject(invoiceSAPPostingSave), "500", e.Message);


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
