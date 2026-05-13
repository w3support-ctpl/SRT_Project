using Dapper;
using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/delivery/")]
    [ApiController]
    public class DeliveryController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public DeliveryController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }
        [HttpPost("GetDelivery", Name = "GetDelivery")]
        public IActionResult GetDelivery(ReqDelivery delivery)
        {
            try
            {
                if (delivery.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = delivery.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = delivery.org_id;
                req_Obj.dealer_id = delivery.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = delivery.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_Output = new DeliverySAP(res_DestinationName[0].ConnectionName).GetAllDeliveries(delivery.start_date, delivery.end_date, res_Obj[0].dealer_code);


                return Ok(res_Output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetOneDelivery", Name = "GetOneDelivery")]
        public IActionResult GetOneDelivery(ReqDelivery delivery)
        {
            try
            {
                if (delivery.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = delivery.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = delivery.org_id;
                req_Obj.dealer_id = delivery.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = delivery.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_Output = new DeliverySAP(res_DestinationName[0].ConnectionName).GetOneDelivery(delivery.delivery_no);



                return Ok(res_Output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetSalesOrderByDelivery", Name = "GetSalesOrderByDelivery")]
        public IActionResult GetSalesOrderByDelivery(ReqDelivery delivery)
        {
            try
            {
                if (delivery.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = delivery.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = delivery.org_id;
                req_Obj.dealer_id = delivery.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = delivery.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_Output = new DeliverySAP(res_DestinationName[0].ConnectionName).GetSalesOrderByDelivery(delivery.delivery_no);



                return Ok(res_Output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        [HttpPost("GetSalesOrderByInvoice", Name = "GetSalesOrderByInvoice")]
        public IActionResult GetSalesOrderByInvoice(ReqDelivery delivery)
        {
            try
            {
                if (delivery.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = delivery.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = delivery.org_id;
                req_Obj.dealer_id = delivery.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = delivery.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_Output = new DeliverySAP(res_DestinationName[0].ConnectionName).GetSalesOrderByInvoice(delivery.delivery_no);



                return Ok(res_Output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("GetDeliverydata", Name = "GetDeliverydata")]
        public IActionResult GetDeliverydata(ReqDelivery delivery)
        {
            try
            {
                if (delivery.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = delivery.destination_name + "";

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = delivery.org_id;
                req_Obj.dealer_id = delivery.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = delivery.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_Output = new DeliverySAP(res_DestinationName[0].ConnectionName).GetDeliverydata(delivery.delivery_no);


                return Ok(res_Output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

               [HttpPost("GetDeliveryPDF", Name = "GetDeliveryPDF")]
        public IActionResult GetDeliveryPDF(ReqDelivery delivery)
        {
            try
            {
                if (delivery.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = delivery.destination_name + "";

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = delivery.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new DeliverySAP(res_DestinationName[0].ConnectionName).GetDeliveryPDF(delivery.delivery_no);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



    

    }

}
