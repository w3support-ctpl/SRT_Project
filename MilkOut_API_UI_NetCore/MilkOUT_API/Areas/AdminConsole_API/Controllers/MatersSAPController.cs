

using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;
using Dapper;
using Newtonsoft.Json.Linq;
using System.Data;
using MySql.Data.MySqlClient;
using System.Configuration;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/sapmaster/")]
    [ApiController]
    public class MatersSAPController : Controller
    {
        private readonly ILogger<MatersSAPController> _logger;
        public MatersSAPController(ILogger<MatersSAPController> logger)
        {
            _logger = logger;
        }



        // [HttpPost("GetDealerMaster", Name = "GetDealerMaster")]
        // public IActionResult GetDealerMaster([FromBody] object reqObject)
        // {
        //     try
        //     {
        //         if (reqObject == null)
        //         {
        //             return BadRequest();
        //         }


        //         string destination_name = "";
        //         string res_Str = new DealerMasterSAP(destination_name).SaveDealerMaster("C001");
        //         return Ok(res_Str);

        //     }
        //     catch (Exception e)
        //     {
        //         var ErrMsg = e.Message;

        //         return StatusCode(500, ErrMsg);
        //     }
        // }

        [HttpPost("GetDealerMaster", Name = "GetDealerMaster")]
        public IActionResult GetDealerMaster(ReqOrgOutPut dealer)
        {
            try
            {
                if (dealer.method_name == null)
                {
                    return BadRequest();
                }
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = dealer.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = dealer.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                dynamic ResObj = new CommonDAL(destination_name).GetDealerCode("USP_SAdmin_GetDealerCode");

                var Data = JsonConvert.DeserializeObject(ResObj.ToString());

                

                string res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).SaveDealerMaster(dealer.org_id , ResObj.ToString());
                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("GetDealerCrateLimit", Name = "GetDealerCrateLimit")]
        public IActionResult GetDealerCrateLimit(ReqOrgOutPut dealer)
        {
            try
            {
                if (dealer.method_name == null)
                {
                    return BadRequest();
                }
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = dealer.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = dealer.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                dynamic ResObj = new CommonDAL(destination_name).GetDealerCode("USP_SAdmin_GetDealerCode");

                var Data = JsonConvert.DeserializeObject(ResObj.ToString());

                

                string res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).SaveDealerCrateLimit(dealer.org_id , ResObj.ToString());
                //return Ok(res_Str);

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1, // Assuming result_id is an integer
                    result_description = "Download",
                    result_extra_key = "Download"
                };

                return Ok(commonOutput);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1, // Assuming result_id is an integer
                    result_description = ErrMsg,
                    result_extra_key = ErrMsg
                };

                return Ok(commonOutput);
            }
        }

        


        [HttpPost("GetDealerMasterSalesArea", Name = "GetDealerMasterSalesArea")]
        public IActionResult GetDealerMasterSalesArea(ReqOrgOutPut dealer)
        {
            try
            {
                if (dealer.method_name == null)
                {
                    return BadRequest();
                }
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = dealer.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = dealer.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                dynamic ResObj = new CommonDAL(destination_name).GetDealerCode("USP_SAdmin_GetDealerCode");

                var Data = JsonConvert.DeserializeObject(ResObj.ToString());



                string res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).SaveDealerMasterSalesArea(dealer.org_id, dealer.dealer_code, ResObj.ToString());
                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetDealerMasterSalesAreaAll", Name = "GetDealerMasterSalesAreaAll")]
        public IActionResult GetDealerMasterSalesAreaAll(ReqOrgOutPut dealer)
        {
            try
            {
                if (dealer.method_name == null)
                {
                    return BadRequest();
                }
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = dealer.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = dealer.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                dynamic ResObj = new CommonDAL(destination_name).GetDealerCode("USP_SAdmin_GetDealerCode");

                var Data = JsonConvert.DeserializeObject(ResObj.ToString());

                for (int i = 0; i < Data.Count; i++)
                {
                    var res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).SaveDealerMasterSalesAreaAll(dealer.org_id,ResObj.ToString() );
                }

                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1, // Assuming result_id is an integer
                    result_description = "SalesArea has been saved successfully.",
                    result_extra_key = "SalesArea has been saved successfully."
                };

                return Ok(commonOutput);


                // string res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).SaveDealerMasterSalesArea(dealer.org_id, "", ResObj.ToString());
                // return Ok(res_Str);



            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetMasterSalesArea", Name = "GetMasterSalesArea")]
        public IActionResult GetMasterSalesArea(ReqSalesOrgOutPut salesarea)
        {
            try
            {
                if (salesarea.method_name == null)
                {
                    return BadRequest();
                }
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = salesarea.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesarea.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                dynamic ResObj = new CommonDAL(destination_name).GetSalesAreaCode("USP_SAdminSalesArea_Get");

                var Data = JsonConvert.DeserializeObject(ResObj.ToString());



                string res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).SaveMasterSalesArea(salesarea.org_id, ResObj.ToString());
                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


         [HttpPost("GetMasterSalesAreaItem", Name = "GetMasterSalesAreaItem")]
        public IActionResult GetMasterSalesAreaItem(ReqSalesOrgOutPut salesarea)
        {
            try
            {
                if (salesarea.method_name == null)
                {
                    return BadRequest();
                }
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = salesarea.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = salesarea.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                string res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).SaveMasterSalesAreaItem(salesarea.org_id);
                return Ok(res_Str);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetDealerMasterSecurityDeposits", Name = "GetDealerMasterSecurityDeposits")]
        public IActionResult GetDealerMasterSecurityDeposits(ReqOrgOutPut dealer)
        {
             
            try
            {
                if (dealer.method_name == null)
                {
                    return BadRequest();
                }
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = dealer.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = dealer.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);

                dynamic ResObj = new CommonDAL(destination_name).GetDealerCode("USP_SAdmin_GetDealerCode");

                var Data = JsonConvert.DeserializeObject(ResObj.ToString());

                for (int i = 0; i < Data.Count; i++)
                {
                string res_Str = new DealerMasterSAP(res_DestinationName[0].ConnectionName).GetDealerMasterSecurityDeposit(Data[i].Dealer_Code.ToString());
                JObject jsonResponse = JObject.Parse(res_Str);

                if (jsonResponse["d"]?["results"] != null && jsonResponse["d"]["results"].Any())
                {
                    var results = jsonResponse["d"]["results"];
                    int count = results.Count();
                    decimal totalSum = 0;

                    // Console.WriteLine($"Total records found: {count}");

                    foreach (var item in results)
                    {
                        decimal amount = Math.Abs(Convert.ToDecimal(item["AmountInBalanceTransacCrcy"].ToString()));
                        totalSum += amount;
                        // Console.WriteLine($"Absolute Amount: {amount}");
                    }
                    // Console.WriteLine($"Total Sum: {totalSum}");
                    new MastersDAL(destination_name).SaveDealerSecurityDepositAmount(dealer.org_id,Data[i].Dealer_Code.ToString(),totalSum.ToString());
                    
                }
                else
                {
                     new MastersDAL(destination_name).SaveDealerSecurityDepositAmount(dealer.org_id,Data[i].Dealer_Code.ToString(),"0");
                    
                    // Console.WriteLine("No data found in results.");
                }
                }
                CommonOutput commonOutput = new CommonOutput
                {
                    result_id = 1, // Assuming result_id is an integer
                    result_description = "Security deposit amount has been saved successfully.",
                    result_extra_key = "Security deposit amount has been saved successfully."
                };

                return Ok(commonOutput);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



    }


}
