using Dapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.DotNet.MSIdentity.Shared;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;
using MilkOUT_API.Areas.AdminConsole_API.SAP;
using MilkOUT_API.Middleware;
using MySqlX.XDevAPI.Common;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Xml;
using System.Xml.Linq;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;


using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Net;
using System.Text;
using System.Threading.Tasks;



using System.Data;
using MySql.Data.MySqlClient;
using System.Configuration;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
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


        /*----  ----    ----    ----    Retailer   ----    ----    ----    ----*/
        [HttpPost("SaveRetailer", Name = "SaveRetailer")]
        public IActionResult SaveRetailer(ReqRetailer retailerSave)
        {
            try
            {
                if (retailerSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = retailerSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveRetailer(retailerSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetRetailer", Name = "GetRetailer")]
        public IActionResult GetRetailer(ReqRetailer retailerSearch)
        {
            try
            {
                if (retailerSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRetailer> res_Obj = new List<ResRetailer>();
                string destination_name = retailerSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetRetailer(retailerSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        /*----  ----    ----    ----    Dealer   ----    ----    ----    ----*/
        [HttpPost("SaveDealer", Name = "SaveDealer")]
        public IActionResult SaveDealer(ReqDealer dealerSave)
        {
            try
            {
                if (dealerSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = dealerSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveDealer(dealerSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("GetDealer", Name = "GetDealer")]
        public IActionResult GetDealer(ReqDealer dealerSearch)
        {
            try
            {
                if (dealerSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDealer> res_Obj = new List<ResDealer>();
                string destination_name = dealerSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetDealer(dealerSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        /*----  ----    ----    ----    Sales Area   ----    ----    ----    ----*/
        [HttpPost("GetSalesGroup", Name = "GetSalesGroup")]
        public IActionResult GetSalesGroup(ReqSalesGroup salesAreaSearch)
        {
            try
            {
                if (salesAreaSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResSalesGroup> res_Obj = new List<ResSalesGroup>();
                string destination_name = salesAreaSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetSalesGroup(salesAreaSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("SaveSalesGroup", Name = "SaveSalesGroup")]
        public IActionResult SaveSalesGroup(ReqSalesGroup salesAreaSave)
        {
            try
            {
                if (salesAreaSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = salesAreaSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveSalesGroup(salesAreaSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }







        /*----  ----    ----    ----    Sales User   ----    ----    ----    ----*/
        [HttpPost("GetSalesUser", Name = "GetSalesUser")]
        public IActionResult GetSalesUser(ReqSalesUser salesUserSearch)
        {
            try
            {
                if (salesUserSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResSalesUser> res_Obj = new List<ResSalesUser>();
                string destination_name = salesUserSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetSalesUser(salesUserSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("SaveSalesUser", Name = "SaveSalesUser")]
        public IActionResult SaveSalesUser(ReqSalesUser salesUserSave)
        {
            try
            {
                if (salesUserSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = salesUserSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveSalesUser(salesUserSave);

                if (salesUserSave.method_name == "Update" && salesUserSave.is_active == 0 && res_Obj[0].result_id == 1)
                {
                    new Notify_Data(destination_name).Send_Notification(res_Obj[0].result_extra_key, salesUserSave.org_id, "SalesPerson", "SalesPersonBlocked");

                }
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        /*----  ----    ----    ----    Sales User ReOpen  ----    ----    ----    ----*/
        [HttpPost("GetSalesUserReOpen", Name = "GetSalesUserReOpen")]
        public IActionResult GetSalesUserReOpen(ReqSalesUserReOpen salesUserReOpenSearch)
        {
            try
            {
                if (salesUserReOpenSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResSalesUserReOpen> res_Obj = new List<ResSalesUserReOpen>();
                string destination_name = salesUserReOpenSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetSalesUserReOpen(salesUserReOpenSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("SaveSalesUserReOpen", Name = "SaveSalesUserReOpen")]
        public IActionResult SaveSalesUserReOpen(ReqSalesUserReOpen salesUserReOpenSave)
        {
            try
            {
                if (salesUserReOpenSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = salesUserReOpenSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveSalesUserReOpen(salesUserReOpenSave);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }





        /*----  ----    ----    ----    Product   ----    ----    ----    ----*/
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
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
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
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        [HttpPost("GetDownloadRoute", Name = "GetDownloadRoute")]
        public IActionResult GetDownloadRoute([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }


                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = inputParam.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new MasterSAP(res_DestinationName[0].ConnectionName).DownloaddealerRoute();



                JObject jsonResponse = JObject.Parse(res_output);
                string res_Str = "";


                var xmlDocument = "";

                if (jsonResponse.ContainsKey("d"))
                {
                    var results = jsonResponse["d"]["results"];

                    if (results != null)
                    {

                        foreach (var res in results)
                        {


                            xmlDocument += "<RouteData><DealerCode>" + res["Customer"].ToString() + "</DealerCode>" +
                                             "<RouteId>" + res["Supplier"].ToString() + "</RouteId></RouteData>";


                        }

                        var XML_Data = "<Data>" + xmlDocument + "</Data>";

                        inputParam.xml_data = XML_Data;
                        inputParam.method_name = "DealerRouteMapped";

                        res_Str = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdminRoute");


                    }
                }




                string res_output1 = new MasterSAP(res_DestinationName[0].ConnectionName).DownloadAllRoute();


                JObject jsonResponse1 = JObject.Parse(res_output1);

                var xmlDocument1 = "";

                if (jsonResponse1.ContainsKey("d"))
                {
                    var results1 = jsonResponse1["d"]["results"];

                    if (results1 != null)
                    {

                        foreach (var res1 in results1)
                        {


                            xmlDocument1 += "<AllRoute><RouteName>" + res1["BusinessPartnerFullName"].ToString() + "</RouteName>" +
                                             "<RouteId>" + res1["Supplier"].ToString() + "</RouteId></AllRoute>";


                        }


                        var XML_Data = "<Data>" + xmlDocument1 + "</Data>";

                        inputParam.xml_data = XML_Data;

                        inputParam.method_name = "AllRoute";

                        res_Str = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdminRoute");


                    }
                }


                return Ok(res_Str);



            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        [HttpPost("GetPaymentTerm", Name = "GetPaymentTerm")]
        public IActionResult GetPaymentTerm([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }


                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;

                List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = inputParam.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new MasterSAP(res_DestinationName[0].ConnectionName).GetPaymentTerm();



                JObject jsonResponse = JObject.Parse(res_output);
                string res_Str = "";


                var xmlDocument = "";

                if (jsonResponse.ContainsKey("d"))
                {
                    var results = jsonResponse["d"]["results"];

                    if (results != null)
                    {
                        List<string> strings = new List<string>();

                        foreach (var res in results)
                        {


                            if (strings.Contains(res["PaymentTerms"].ToString()) == false)
                            {



                                xmlDocument += "<Payment><PaymentTerms>" + res["PaymentTerms"].ToString() + "</PaymentTerms>" +
                                                 "<PaymentTermsName>" + res["PaymentTermsDescription_1"].ToString() + "</PaymentTermsName></Payment>";


                            }

                            strings.Add(res["PaymentTerms"].ToString());
                        }

                        var XML_Data = "<Data>" + xmlDocument + "</Data>";

                        inputParam.xml_data = XML_Data;
                        inputParam.method_name = "PaymentTerms";

                        res_Str = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdminPaymentterm");


                    }
                }




                string res_output1 = new MasterSAP(res_DestinationName[0].ConnectionName).DownloadAllRoute();


                JObject jsonResponse1 = JObject.Parse(res_output1);

                var xmlDocument1 = "";

                if (jsonResponse1.ContainsKey("d"))
                {
                    var results1 = jsonResponse1["d"]["results"];

                    if (results1 != null)
                    {

                        foreach (var res1 in results1)
                        {


                            xmlDocument1 += "<AllRoute><RouteName>" + res1["BusinessPartnerFullName"].ToString() + "</RouteName>" +
                                             "<RouteId>" + res1["Supplier"].ToString() + "</RouteId></AllRoute>";


                        }


                        var XML_Data = "<Data>" + xmlDocument1 + "</Data>";

                        inputParam.xml_data = XML_Data;

                        inputParam.method_name = "AllRoute";

                        res_Str = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdminRoute");


                    }
                }


                return Ok(res_Str);



            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        // [HttpPost("GetNotificationCode", Name = "GetNotificationCode")]
        // public IActionResult GetNotificationCode([FromBody] object reqObject)
        // {
        //     try
        //     {

        //         if (reqObject == null)
        //         {
        //             return BadRequest();
        //         }


        //         dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
        //         string destination_name = inputParam.Destination_Name;

        //         // List<ResGetDealer> res_Obj = new List<ResGetDealer>();
        //         List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


        //         ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
        //         req_DestinationName.org_id = inputParam.org_id;


        //         res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);
        //         Console.WriteLine("1");
        //         Console.WriteLine(res_DestinationName[0].ConnectionName);
        //         Console.WriteLine("1");

        //         string res_output = new MasterSAP(res_DestinationName[0].ConnectionName).GetNotificationCode();

        //         Console.WriteLine(res_output);



        //         JObject jsonResponse = JObject.Parse(res_output);
        //         string res_Str = "";


        //         var xmlDocument = "";

        //         if (jsonResponse.ContainsKey("d"))
        //         {
        //             var results = jsonResponse["d"]["results"];

        //             if (results != null)
        //             {
        //                 List<string> strings = new List<string>();

        //                 foreach (var res in results)
        //                 {


        //                     if (strings.Contains(res["InspectionCode_1"].ToString()) == false)
        //                     {



        //                         xmlDocument += "<NotificationCode><InspectionCode_1>" + res["InspectionCode_1"].ToString() + "</InspectionCode_1>" +
        //                                          "<InspectionCodeText>" + res["InspectionCodeText"].ToString() + "</InspectionCodeText></NotificationCode>";


        //                     }

        //                     strings.Add(res["InspectionCode_1"].ToString());
        //                 }

        //                 var XML_Data = "<Data>" + xmlDocument + "</Data>";

        //                 inputParam.xml_data = XML_Data;
        //                 inputParam.method_name = "InspectionCode_1";

        //                 res_Str = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdminNotificationCode");


        //             }
        //         }





        //         return Ok(res_Str);



        //     }
        //     catch (Exception e)
        //     {
        //         var ErrMsg = e.Message;

        //         return StatusCode(500, ErrMsg);
        //     }
        // }



        [HttpPost("GetNotificationCode", Name = "GetNotificationCode")]
        public IActionResult GetNotificationCode([FromBody] object reqObject)
        {
            try
            {
                if (reqObject == null)
                {
                    return BadRequest();
                }




                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
                string destination_name = inputParam.Destination_Name;

                // List<ResGetDealer> res_Obj = new List<ResGetDealer>();
                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = inputParam.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                string res_output = new MasterSAP(res_DestinationName[0].ConnectionName).GetNotificationCode();



                JObject jsonResponse = JObject.Parse(res_output);
                string res_Str = "";


                var xmlDocument = "";

                if (jsonResponse.ContainsKey("d"))
                {
                    var results = jsonResponse["d"]["results"];

                    if (results != null)
                    {
                        List<string> strings = new List<string>();

                        foreach (var res in results)
                        {


                            if (strings.Contains(res["InspectionCode_1"].ToString()) == false)
                            {



                                xmlDocument += "<NotificationCode><InspectionCode_1>" + res["InspectionCode_1"].ToString() + "</InspectionCode_1>" +
                                                 "<InspectionCodeText>" + res["InspectionCodeText"].ToString() + "</InspectionCodeText></NotificationCode>";


                            }

                            strings.Add(res["InspectionCode_1"].ToString());
                        }

                        var XML_Data = "<Data>" + xmlDocument + "</Data>";

                        inputParam.xml_data = XML_Data;
                        inputParam.method_name = "InspectionCode_1";

                        res_Str = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdminNotificationCode");


                    }
                }




                return Ok(res_Str);



            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        //  [HttpPost("GetNotificationCode", Name = "GetNotificationCode")]
        //         public IActionResult GetNotificationCode([FromBody] object reqObject)
        //         {
        //             try
        //             {
        //                 if (reqObject == null)
        //                 {
        //                     return BadRequest();
        //                 }

        //                 // List<CommonOutput> res_Obj = new List<CommonOutput>();
        //                 // string destination_name = notificationCode.destination_name + "";

        //                 dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
        //                 string destination_name = inputParam.Destination_Name;

        //                 List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


        //                 ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
        //                 req_DestinationName.org_id = inputParam.org_id;


        //                 res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



        //                 // res_Obj = new UsersDAL(destination_name).SaveFarmer(farmerSave);

        //                var  res_output = new MasterSAP(res_DestinationName[0].ConnectionName).GetNotificationCode();


        //                 JObject jsonResponse = JObject.Parse(res_output);
        //                 string res_Str = "";


        //                 var xmlDocument = "";

        //                 if (jsonResponse.ContainsKey("d"))
        //                 {
        //                     var results = jsonResponse["d"]["results"];

        //                     if (results != null)
        //                     {
        //                         List<string> strings = new List<string>();

        //                         foreach (var res in results)
        //                         {


        //                             if (strings.Contains(res["InspectionCode_1"].ToString()) == false)
        //                             {



        //                                 xmlDocument += "<NotificationCode><InspectionCode_1>" + res["InspectionCode_1"].ToString() + "</InspectionCode_1>" +
        //                                                  "<InspectionCodeText>" + res["InspectionCodeText"].ToString() + "</InspectionCodeText></NotificationCode>";


        //                             }

        //                             strings.Add(res["InspectionCode_1"].ToString());
        //                         }

        //                         var XML_Data = "<Data>" + xmlDocument + "</Data>";



        //                                 inputParam.method_name = "InspectionCode_1";
        //                                 inputParam.org_id = inputParam.org_id;
        //                                 inputParam.xml_data =XML_Data;


        //                         // notificationCode.xml_data = XML_Data;
        //                         // notificationCode.method_name = "InspectionCode_1";

        //                         res_Str = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdminNotificationCode");


        //                     }
        //                 }





        //                 return Ok(res_Str);


        //             }
        //             catch (Exception e)
        //             {
        //                 var ErrMsg = e.Message;

        //                 return StatusCode(500, ErrMsg);
        //             }
        //         }




        // [HttpPost("GetNotificationCode", Name = "GetNotificationCode")]

        //         public IActionResult GetNotificationCode([FromBody] object reqObject)
        //         {
        //            try
        //            {
        //                if (reqObject == null)
        //                {
        //                    return BadRequest();
        //                }


        //                dynamic inputParam = JsonConvert.DeserializeObject(reqObject.ToString());
        //                string destination_name = inputParam.Destination_Name;

        //                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


        //             //    dynamic res = new CommonDAL(destination_name).RunDBQuery(inputParam, "USP_SAdmin_ProductUOM");

        //                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
        //                req_DestinationName.org_id = inputParam.org_id;


        //                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


        //                string res_output = new MasterSAP(res_DestinationName[0].ConnectionName).GetNotificationCode();


        //                return Ok(res_output);



        //            }
        //            catch (Exception e)
        //            {
        //                var ErrMsg = e.Message;

        //                return StatusCode(500, ErrMsg);
        //            }
        //         }


        [HttpPost("SaveMasterProductUOM", Name = "SaveMasterProductUOM")]

        public IActionResult SaveMasterProductUOM(Reqproductuom productSave)
        {
            try
            {
                if (productSave.method_name == null)
                {
                    return BadRequest();
                }

                string destination_name = productSave.destination_name + "";



                string res_Obj = new MastersDAL(destination_name).SaveProductUOM(productSave);


                dynamic resobj = JsonConvert.DeserializeObject(res_Obj.ToString());


                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = productSave.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                var xmlDocument = "";

                foreach (var result in resobj)
                {



                    string res_output = new MasterSAP(res_DestinationName[0].ConnectionName).SaveProductMasterUOM(result.Productcode.ToString());


                    JObject jsonResponse = JObject.Parse(res_output);


                    if (jsonResponse.ContainsKey("d"))
                    {
                        var results = jsonResponse["d"]["results"];

                        if (results != null)
                        {
                            //XDocument xmlDocument = new XDocument(new XElement("Dealer"));



                            foreach (var res in results)
                            {


                                xmlDocument += "<ProductData><ProductCode>" + res["Product"].ToString() + "</ProductCode>" +
                                                 "<Productuom>" + res["AlternativeUnit"].ToString() + "</Productuom></ProductData>";


                            }

                        }
                    }

                }

                var XML_Data = "<product>" + xmlDocument + "</product>";


                productSave.method_name = "SaveProductUOM";
                productSave.xml_data = XML_Data;


                string rObj = new MastersDAL(destination_name).SaveProductUOM(productSave);


                return Ok();

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("SaveSAPMasterProduct", Name = "SaveSAPMasterProduct")]

        public IActionResult SaveSAPMasterProduct(ReqProduct productSave)
        {
            try
            {
                if (productSave.method_name == null)
                {
                    return BadRequest();
                }

                string destination_name = productSave.destination_name + "";



                // string res_Obj = new MastersDAL(destination_name).SaveProductXML(productSave);


                // dynamic resobj = JsonConvert.DeserializeObject(res_Obj.ToString());


                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();

                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = productSave.org_id;


                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);




                string res_output = new MasterSAP(res_DestinationName[0].ConnectionName).SaveProductMaster(productSave.org_id);


                JObject jsonResponse = JObject.Parse(res_output);


                if (jsonResponse.ContainsKey("d"))
                {
                    var results = jsonResponse["d"]["results"];

                    if (results != null)
                    {
                        //XDocument xmlDocument = new XDocument(new XElement("Dealer"));

                        XDocument xmlDocument = new XDocument(new XElement("Product"));

                        foreach (var result in results)
                        {
                            string productCode = result["Product"].ToString();
                            string productDescription = result["to_Description"]["results"][0]["ProductDescription"].ToString();
                            string productGroup = result["ProductGroup"].ToString();
                            string baseUnit = result["BaseUnit"].ToString();
                            string division = result["Division"].ToString();
                            string productType = result["ProductType"].ToString();

                            XElement productData = new XElement("ProductData",
                                new XElement("Product_Code", productCode),
                                new XElement("Product_Name", productDescription),
                                new XElement("Product_Group", productGroup),
                                new XElement("BaseUnit", baseUnit),
                                new XElement("Division", division),
                                new XElement("ProductType", productType)
                            );

                            xmlDocument.Root.Add(productData);
                        }

                        string xmlString = xmlDocument.ToString();

                        productSave.method_name = productSave.method_name;
                        productSave.org_id = productSave.org_id;
                        productSave.destination_name = productSave.destination_name;
                        productSave.search_text = productSave.search_text;
                        productSave.product_id = productSave.product_id;
                        productSave.user_id = productSave.user_id;
                        productSave.user_name = productSave.user_name;
                        productSave.is_active = productSave.is_active;
                        productSave.is_deleted = productSave.is_deleted;
                        productSave.product_photo = productSave.product_photo;
                        productSave.product_data = xmlString;


                        string rObj = new MastersDAL(destination_name).SaveProductXML(productSave);


                    }
                }





                return Ok();

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        /*----  ----    ----    ----    Role   ----    ----    ----    ----*/

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
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
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
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }






        /*----  ----    ----    ----    Office User   ----    ----    ----    ----*/
        [HttpPost("GetOfficeUsers", Name = "GetOfficeUsers")]
        public IActionResult GetOfficeUsers(ReqOfficeUsers userSearch)
        {
            try
            {
                if (userSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOfficeUsers> res_Obj = new List<ResOfficeUsers>();
                string destination_name = userSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetOfficeUsers(userSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("SaveOfficeUsers", Name = "SaveOfficeUsers")]
        public IActionResult SaveOfficeUsers(ReqOfficeUsers userSave)
        {
            try
            {
                if (userSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = userSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveOfficeUsers(userSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetProductRateByDealerCode", Name = "GetProductRateByDealerCode")]
        public IActionResult GetProductRateByDealerCode(ReqProductRate productRate)
        {
            try
            {
                if (productRate.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = productRate.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = productRate.org_id;



                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new RateSAP(res_DestinationName[0].ConnectionName).GetProductRateByDealer(productRate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [HttpPost("GetProductRateByDealerCodeNew", Name = "GetProductRateByDealerCodeNew")]
        public IActionResult GetProductRateByDealerCodeNew(ReqProductRate productRate)
        {
            try
            {
                if (productRate.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = productRate.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = productRate.org_id;



                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);



                string res_output = new RateSAP(res_DestinationName[0].ConnectionName).GetProductRateByDealerNew(productRate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetProductRateByDealerId", Name = "GetProductRateByDealerId")]
        public IActionResult GetProductRateByDealerId(ReqProductRate productRate)
        {
            try
            {
                if (productRate.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = productRate.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = productRate.org_id;



                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                List<ResGetDealer> res_Obj = new List<ResGetDealer>();

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = productRate.org_id;
                req_Obj.dealer_id = productRate.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);


                List<ResGetProduct> res_ObjProduct = new List<ResGetProduct>();

                ReqGetProduct req_ObjProduct = new ReqGetProduct();
                req_ObjProduct.org_id = productRate.org_id;
                req_ObjProduct.product_id = productRate.product_id;

                res_ObjProduct = new CommonDAL(destination_name).GetProductCode(req_ObjProduct);



                ReqProductRate req_ProductRate = new ReqProductRate();
                req_ProductRate.method_name = productRate.method_name;
                req_ProductRate.org_id = productRate.org_id;
                req_ProductRate.destination_name = productRate.destination_name;
                req_ProductRate.dealer_code = res_Obj[0].dealer_code;
                req_ProductRate.product_code = res_ObjProduct[0].product_code;
                req_ProductRate.api_end_point = productRate.api_end_point;




                string res_output = new RateSAP(res_DestinationName[0].ConnectionName).GetProductRateByDealer(req_ProductRate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [HttpPost("GetProductRateByDealerIdProductCode", Name = "GetProductRateByDealerIdProductCode")]
        public IActionResult GetProductRateByDealerIdProductCode(ReqProductRate productRate)
        {
            try
            {
                if (productRate.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = productRate.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = productRate.org_id;



                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                List<ResGetDealer> res_Obj = new List<ResGetDealer>();

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = productRate.org_id;
                req_Obj.dealer_id = productRate.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);


                ReqProductRate req_ProductRate = new ReqProductRate();
                req_ProductRate.method_name = productRate.method_name;
                req_ProductRate.org_id = productRate.org_id;
                req_ProductRate.destination_name = productRate.destination_name;
                req_ProductRate.dealer_code = res_Obj[0].dealer_code;
                req_ProductRate.product_code = productRate.product_code;
                req_ProductRate.api_end_point = productRate.api_end_point;




                string res_output = new RateSAP(res_DestinationName[0].ConnectionName).GetProductRateByDealer(req_ProductRate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [HttpPost("GetProductRateByDealerIdProductCodeNew", Name = "GetProductRateByDealerIdProductCodeNew")]
        public IActionResult GetProductRateByDealerIdProductCodeNew(ReqProductRate productRate)
        {
            try
            {
                if (productRate.method_name == null)
                {
                    return BadRequest();
                }

                List<ResOrgOutPut> res_DestinationName = new List<ResOrgOutPut>();


                string destination_name = productRate.destination_name + "";


                ReqOrgOutPut req_DestinationName = new ReqOrgOutPut();
                req_DestinationName.org_id = productRate.org_id;



                res_DestinationName = new CommonDAL(destination_name).GetDestinationName(req_DestinationName);


                List<ResGetDealer> res_Obj = new List<ResGetDealer>();

                ReqGetDealer req_Obj = new ReqGetDealer();
                req_Obj.org_id = productRate.org_id;
                req_Obj.dealer_id = productRate.dealer_id;

                res_Obj = new CommonDAL(destination_name).GetDealerCode(req_Obj);


                ReqProductRate req_ProductRate = new ReqProductRate();
                req_ProductRate.method_name = productRate.method_name;
                req_ProductRate.org_id = productRate.org_id;
                req_ProductRate.destination_name = productRate.destination_name;
                req_ProductRate.dealer_code = res_Obj[0].dealer_code;
                req_ProductRate.product_code = productRate.product_code;
                req_ProductRate.api_end_point = productRate.api_end_point;
                req_ProductRate.sales_organization = productRate.sales_organization;
                req_ProductRate.distribution_channel = productRate.distribution_channel;
                req_ProductRate.division = productRate.division;




                string res_output = new RateSAP(res_DestinationName[0].ConnectionName).GetProductRateByDealerNew(req_ProductRate);


                return Ok(res_output);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Complaint Type   ----    ----    ----    ----*/
        [HttpPost("GetComplaintType", Name = "GetComplaintType")]
        public IActionResult GetComplaintType(ReqComplaintType salesUserSearch)
        {
            try
            {
                if (salesUserSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResComplaintType> res_Obj = new List<ResComplaintType>();
                string destination_name = salesUserSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetComplaintType(salesUserSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("SaveComplaintType", Name = "SaveComplaintType")]
        public IActionResult SaveComplaintType(ReqComplaintType salesUserSave)
        {
            try
            {
                if (salesUserSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = salesUserSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveComplaintType(salesUserSave);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        /*----  ----    ----    ----    Route   ----    ----    ----    ----*/
        [HttpPost("GetRouteSU", Name = "GetRouteSU")]
        public IActionResult GetRouteSU(ReqRouteSU RouteSearch)
        {
            try
            {
                if (RouteSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResRouteSU> res_Obj = new List<ResRouteSU>();
                string destination_name = RouteSearch.destination_name + "";
                res_Obj = new MastersDAL(destination_name).GetRouteSU(RouteSearch);  

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        [HttpPost("SaveRouteSU", Name = "SaveRouteSU")]
        public IActionResult SaveRouteSU(ReqRouteSU RouteSave)
        {
            try
            {
                if (RouteSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = RouteSave.destination_name + "";
                res_Obj = new MastersDAL(destination_name).SaveRouteSU(RouteSave);

                
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


    }
}
