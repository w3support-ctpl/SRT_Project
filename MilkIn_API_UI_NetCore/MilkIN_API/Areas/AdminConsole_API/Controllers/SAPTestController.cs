using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.AdminConsole_API.FleetX;
using MilkIN_API.Areas.AdminConsole_API.Models;
using MilkIN_API.Areas.AdminConsole_API.SAP;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/saptest/")]
    [ApiController]

    // The API's in this controller are only for testing purpose. The methods used in this controller are actually used from
    // other DAL's as per the requirement.

    public class SAPTestController : Controller
    {
        private readonly ILogger<SAPTestController> _logger;

        public SAPTestController(ILogger<SAPTestController> logger)
        {
            _logger = logger;

        }

        [HttpPost("SaveMilkBatch", Name = "SaveMilkBatch")]
        public IActionResult SaveMilkBatch(ReqSAPMilkBatch ReqObj)
        {
            try
            {

                string resString = new CollectionSAP("Dev").SaveMilkBatch(ReqObj, "C001");
                return Ok(resString);

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

        [HttpPost("SaveMilkBatchHeader", Name = "SaveMilkBatchHeader")]
        public IActionResult SaveMilkBatchHeader(ReqSAPMilkBatchHeader ReqObj)
        {
            try
            {

                string resString = new CollectionSAP("Dev").SaveMilkBatchHeader(ReqObj, "C001");
                return Ok(resString);

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

        [HttpPost("SaveMilkSOAP", Name = "SaveMilkSOAP")]
        public IActionResult SaveMilkSOAP(ReqSAPMilkSOAP ReqObj)
        {
            try
            {

                string resString = new CollectionSAP("Dev").SaveMilkSOAP(ReqObj, "C001");
                return Ok(resString);

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

        [HttpPost("SaveMilkSOAPJson", Name = "SaveMilkSOAPJson")]
        public IActionResult SaveMilkSOAPJson(ReqSAPMilkSOAPIncome ReqObj)
        {
            try
            {

                string resString = new CollectionSAP("PRD").SaveMilkSOAPJson(ReqObj, "C001");
                return Ok(resString);

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

        [HttpPost("BusinessPartner", Name = "BusinessPartner")]
        public IActionResult BusinessPartner(ReqSAPBusinessPartner ReqObj)
        {
            try
            {

                string resString = new BusinessPartnerSAP("Dev").SaveBusinessPartner(ReqObj, "C001");
                return Ok(resString);

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


        [HttpPost("SaveBusinessPartnerTest", Name = "SaveBusinessPartnerTest")]
        public IActionResult BusinessPartner(BusinessPartner_List ReqObj)
        {
            try
            {

                string resString = new BusinessPartnerSAP("Dev").SaveBusinessPartnerTest(ReqObj, "C001");
                return Ok(resString);

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

        [HttpPost("SaveBankSAP", Name = "SaveBankSAP")]
        public IActionResult SaveBankSAP(Rootobject ReqObj)
        {
            try
            {

                string resString = new MasterSAP("Dev").SaveBankMaster(ReqObj, "C001");
                return Ok(resString);

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
        [HttpPost("SaveProductSAP", Name = "SaveProductSAP")]
        public IActionResult SaveProductSAP()
        {
            try
            {

                string resString = new MasterSAP("Dev").SaveProductMaster("C001");
                return Ok(resString);

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

        [HttpPost("SaveMaterialSAP", Name = "SaveMaterialSAP")]
        public IActionResult SaveMaterialSAP()
        {
            try
            {

                string resString = new MasterSAP("Dev").SaveMaterialMaster("C001", "ZRMK");
                return Ok(resString);

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

        [HttpPost("SaveSalesOrder", Name = "SaveSalesOrder")]
        public IActionResult SaveSalesOrder(SalesOrder ReqObj)
        {
            try
            {

                string resString = new SalesOrderSAP("Dev").SaveSalesOrder(ReqObj, "C001");
                return Ok(resString);

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

        [HttpPost("GetFleetXData", Name = "GetFleetXData")]
        public IActionResult GetFleetXData(ReqTripDocument ReqObj)
        {
            try
            {

                string resString = new FleetX_Data().GetFleetXData(ReqObj.fleetx_id);
                return Ok(resString);

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


    }
}
