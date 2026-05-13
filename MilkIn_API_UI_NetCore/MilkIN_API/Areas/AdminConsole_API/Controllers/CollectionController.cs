using Microsoft.AspNetCore.Mvc;
using Middleware;
using MilkIN_API.Areas.AdminConsole_API.DAL;
using MilkIN_API.Areas.AdminConsole_API.Models;
using System.Xml.Linq;
using Newtonsoft.Json;
using System.Text;
using System.Net.Http.Headers;
using MilkIN_API.Areas.AdminConsole_API.SAP;

namespace MilkIN_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/collection/")]
    [ApiController]
    public class CollectionController : Controller
    {
        private readonly ILogger<CollectionController> _logger;

        public CollectionController(ILogger<CollectionController> logger)
        {
            _logger = logger;

        }








        /*----  ----    ----    ----    Milk Collection Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMilkCollection", Name = "GetMilkCollection")]
        public IActionResult GetMilkCollection(ReqMilkCollection milkCollection)
        {
            try
            {
                if (milkCollection.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkCollection> res_Obj = new List<ResMilkCollection>();
                string destination_name = milkCollection.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetMilkCollection(milkCollection);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollection.destination_name).ApiLog("Create", milkCollection.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollection), "500", e.Message);


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

        [HttpPost("SaveMilkCollection", Name = "SaveMilkCollection")]
        public IActionResult SaveMilkCollection(ReqMilkCollection milkCollection)
        {
            try
            {
                if (milkCollection.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkCollection.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveMilkCollection(milkCollection);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollection.destination_name).ApiLog("Create", milkCollection.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollection), "500", e.Message);

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

        [HttpPost("SaveMilkCollectionReverse", Name = "SaveMilkCollectionReverse")]
        public IActionResult SaveMilkCollectionReverse(ReqMilkCollectionInSAP milkCollection)
        {
            try
            {
                if (milkCollection.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkCollection.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveMilkCollectionReverse(milkCollection);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollection.destination_name).ApiLog("Create", milkCollection.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollection), "500", e.Message);

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

        [HttpPost("SaveGoodsInwardPostingList", Name = "SaveGoodsInwardPostingList")]
        public IActionResult SaveGoodsInwardPostingList(ReqMilkCollectionInSAP milkCollection)
        {
            try
            {
                if (milkCollection.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkCollection.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveGoodsInwardPostingList(milkCollection);


                if (milkCollection.method_name == "SetFlag")
                {

                    List<ResSendSMS> res_SMS = new List<ResSendSMS>();


                    ReqSendSMS req_SMS = new ReqSendSMS();
                    req_SMS.method_name = "Send_SMS";
                    req_SMS.org_id = milkCollection.org_id;
                    req_SMS.milkcollectiondairy_id = milkCollection.milkcollectiondairy_id;


                    res_SMS = new CollectionDAL(destination_name).SendSMS(req_SMS);

                }

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollection.destination_name).ApiLog("Create", milkCollection.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollection), "500", e.Message);

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




        /*----  ----    ----    ----    MilkCollection Quantity Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMilkCollectionQuantity", Name = "GetMilkCollectionQuantity")]
        public IActionResult GetMilkCollectionQuantity(ReqMilkCollectionQuantity milkCollectionQuantitySearch)
        {
            try
            {
                if (milkCollectionQuantitySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkCollectionQuantity> res_Obj = new List<ResMilkCollectionQuantity>();
                string destination_name = milkCollectionQuantitySearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetMilkCollectionQuantity(milkCollectionQuantitySearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollectionQuantitySearch.destination_name).ApiLog("Create", milkCollectionQuantitySearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollectionQuantitySearch), "500", e.Message);

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

        [HttpPost("SaveMilkCollectionQuantity", Name = "SaveMilkCollectionQuantity")]
        public IActionResult SaveMilkCollectionQuantity(ReqMilkCollectionQuantity milkCollectionQuantitySave)
        {
            try
            {
                if (milkCollectionQuantitySave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkCollectionQuantitySave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveMilkCollectionQuantity(milkCollectionQuantitySave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollectionQuantitySave.destination_name).ApiLog("Create", milkCollectionQuantitySave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollectionQuantitySave), "500", e.Message);

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




        /*----  ----    ----    ----    MilkCollection Quality Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetMilkCollectionQuality", Name = "GetMilkCollectionQuality")]
        public IActionResult GetMilkCollectionQuality(ReqMilkCollectionQuality milkCollectionQualitySearch)
        {
            try
            {
                if (milkCollectionQualitySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkCollectionQuality> res_Obj = new List<ResMilkCollectionQuality>();
                string destination_name = milkCollectionQualitySearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetMilkCollectionQuality(milkCollectionQualitySearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollectionQualitySearch.destination_name).ApiLog("Create", milkCollectionQualitySearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollectionQualitySearch), "500", e.Message);

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

        [HttpPost("SaveMilkCollectionQuality", Name = "SaveMilkCollectionQuality")]
        public IActionResult SaveMilkCollectionQuality(ReqMilkCollectionQuality milkCollectionQualitySave)
        {
            try
            {
                if (milkCollectionQualitySave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkCollectionQualitySave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveMilkCollectionQuality(milkCollectionQualitySave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(milkCollectionQualitySave.destination_name).ApiLog("Create", milkCollectionQualitySave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(milkCollectionQualitySave), "500", e.Message);

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




        /*----  ----    ----    ----    MilkCollection Route Supervisor Get & Save   ----    ----    ----    ----*/
        /*
        [HttpPost("GetMilkCollectionSupervisor", Name = "GetMilkCollectionSupervisor")]
        public IActionResult GetMilkCollectionSupervisor(ReqMilkCollectionSupervisor milkCollectionSupervisorSearch)
        {
            try
            {
                if (milkCollectionSupervisorSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkCollectionSupervisor> res_Obj = new List<ResMilkCollectionSupervisor>();
                string destination_name = milkCollectionSupervisorSearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetMilkCollectionSupervisor(milkCollectionSupervisorSearch);

                return Ok(res_Obj);

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
        */

        /*
        [HttpPost("SaveMilkCollectionChemist", Name = "SaveMilkCollectionChemist")]
        public IActionResult SaveMilkCollectionChemist(ReqMilkCollectionChemist milkCollectionChemistSave)
        {
            try
            {
                if (milkCollectionChemistSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = milkCollectionChemistSave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveMilkCollectionChemist(milkCollectionChemistSave);
                return Ok(res_Obj);

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
        */



        /*----  ----    ----    ----    MilkCollection Analyst Get   ----    ----    ----    ----*/
        /*

        [HttpPost("GetMilkCollectionAnalyst", Name = "GetMilkCollectionAnalyst")]
        public IActionResult GetMilkCollectionAnalyst(ReqMilkCollectionAnalyst milkCollectionAnalystSearch)
        {
            try
            {
                if (milkCollectionAnalystSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMilkCollectionAnalyst> res_Obj = new List<ResMilkCollectionAnalyst>();
                string destination_name = milkCollectionAnalystSearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetMilkCollectionAnalyst(milkCollectionAnalystSearch);

                return Ok(res_Obj);

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
        */



        /*----  ----    ----    ----    Trip Document Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetTripDocument", Name = "GetTripDocument")]
        public IActionResult GetTripDocument(ReqTripDocument tripDocumentSearch)
        {
            try
            {
                if (tripDocumentSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResTripDocument> res_Obj = new List<ResTripDocument>();
                string destination_name = tripDocumentSearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetTripDocument(tripDocumentSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(tripDocumentSearch.destination_name).ApiLog("Create", tripDocumentSearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(tripDocumentSearch), "500", e.Message);

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

        [HttpPost("SaveTripDocument", Name = "SaveTripDocument")]
        public IActionResult SaveTripDocument(ReqTripDocument tripDocumentSave)
        {
            try
            {
                if (tripDocumentSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = tripDocumentSave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveTripDocument(tripDocumentSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(tripDocumentSave.destination_name).ApiLog("Create", tripDocumentSave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(tripDocumentSave), "500", e.Message);

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

        [HttpPost("SaveTripDocumentKM", Name = "SaveTripDocumentKM")]
        public IActionResult SaveTripDocumentKM(ReqTripDocument tripDocumentSave)
        {
            try
            {
                if (tripDocumentSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = tripDocumentSave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveTripDocumentKM(tripDocumentSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(tripDocumentSave.destination_name).ApiLog("Create", tripDocumentSave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(tripDocumentSave), "500", e.Message);

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


        [HttpPost("GetFleetXIdData", Name = "GetFleetXIdData")]
        public IActionResult GetFleetXIdData(ReqTripDocument tripDocumentSave)
        {
            try
            {
                if (tripDocumentSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = tripDocumentSave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetFleetXIdData(tripDocumentSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(tripDocumentSave.destination_name).ApiLog("Create", tripDocumentSave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(tripDocumentSave), "500", e.Message);

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

        /*----  ----    ----    ----    Goods Inward Posting Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetGoodsInwardPosting", Name = "GetGoodsInwardPosting")]
        public IActionResult GetGoodsInwardPosting(ReqGoodsInwardPosting GoodsInwardPostingSearch)
        {
            try
            {
                if (GoodsInwardPostingSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGoodsInwardPosting> res_Obj = new List<ResGoodsInwardPosting>();
                string destination_name = GoodsInwardPostingSearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetGoodsInwardPosting(GoodsInwardPostingSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(GoodsInwardPostingSearch.destination_name).ApiLog("Create", GoodsInwardPostingSearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(GoodsInwardPostingSearch), "500", e.Message);

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

        [HttpPost("SaveGoodsInwardPostingGRN", Name = "SaveGoodsInwardPostingGRN")]
        public IActionResult SaveGoodsInwardPostingGRN(ReqGoodsInwardPosting GoodsInwardPostingSave)
        {
            try
            {
                if (GoodsInwardPostingSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = GoodsInwardPostingSave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveGoodsInwardPostingGRN(GoodsInwardPostingSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(GoodsInwardPostingSave.destination_name).ApiLog("Create", GoodsInwardPostingSave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(GoodsInwardPostingSave), "500", e.Message);

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



        [HttpPost("SaveGoodsInwardPosting", Name = "SaveGoodsInwardPosting")]
        public IActionResult SaveGoodsInwardPosting(ReqGoodsInwardPosting GoodsInwardPostingSave)
        {
            try
            {
                if (GoodsInwardPostingSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = GoodsInwardPostingSave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveGoodsInwardPosting(GoodsInwardPostingSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(GoodsInwardPostingSave.destination_name).ApiLog("Create", GoodsInwardPostingSave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(GoodsInwardPostingSave), "500", e.Message);

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



        /*----  ----    ----    ----    Collection Approval Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetCollectionApproval", Name = "GetCollectionApproval")]
        public IActionResult GetCollectionApproval(ReqCollectionApproval collectionApprovalSearch)
        {
            try
            {
                if (collectionApprovalSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResCollectionApproval> res_Obj = new List<ResCollectionApproval>();
                string destination_name = collectionApprovalSearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetCollectionApproval(collectionApprovalSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(collectionApprovalSearch.destination_name).ApiLog("Create", collectionApprovalSearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(collectionApprovalSearch), "500", e.Message);

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

        [HttpPost("SaveCollectionApproval", Name = "SaveCollectionApproval")]
        public IActionResult SaveCollectionApproval(ReqCollectionApproval collectionApprovalSave)
        {
            try
            {
                if (collectionApprovalSave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = collectionApprovalSave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveCollectionApproval(collectionApprovalSave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(collectionApprovalSave.destination_name).ApiLog("Create", collectionApprovalSave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(collectionApprovalSave), "500", e.Message);

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



        /*----  ----    ----    ----    Quality Entry Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetQualityEntry", Name = "GetQualityEntry")]
        public IActionResult GetQualityEntry(ReqQualityEntry qualityEntrySearch)
        {
            try
            {
                if (qualityEntrySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResQualityEntry> res_Obj = new List<ResQualityEntry>();
                string destination_name = qualityEntrySearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetQualityEntry(qualityEntrySearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(qualityEntrySearch.destination_name).ApiLog("Create", qualityEntrySearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(qualityEntrySearch), "500", e.Message);

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

        [HttpPost("SaveQualityEntry", Name = "SaveQualityEntry")]
        public IActionResult SaveQualityEntry(ReqQualityEntry qualityEntrySave)
        {
            try
            {
                if (qualityEntrySave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = qualityEntrySave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveQualityEntry(qualityEntrySave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(qualityEntrySave.destination_name).ApiLog("Create", qualityEntrySave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(qualityEntrySave), "500", e.Message);

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


        [HttpPost("GetMachineData", Name = "GetMachineData")]
        public IActionResult GetMachineData(ReqMachineData machineDataSearch)
        {
            try
            {
                if (machineDataSearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResMachineData> res_Obj = new List<ResMachineData>();
                string destination_name = machineDataSearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetMachineData(machineDataSearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(machineDataSearch.destination_name).ApiLog("Create", machineDataSearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(machineDataSearch), "500", e.Message);

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



        /*----  ----    ----    ----    Gain Loss Entry Get & Save   ----    ----    ----    ----*/

        [HttpPost("GetGainLossEntry", Name = "GetGainLossEntry")]
        public IActionResult GetGainLossEntry(ReqGainLossEntry gainLossEntrySearch)
        {
            try
            {
                if (gainLossEntrySearch.method_name == null)
                {
                    return BadRequest();
                }

                List<ResGainLossEntry> res_Obj = new List<ResGainLossEntry>();
                string destination_name = gainLossEntrySearch.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).GetGainLossEntry(gainLossEntrySearch);

                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(gainLossEntrySearch.destination_name).ApiLog("Create", gainLossEntrySearch.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(gainLossEntrySearch), "500", e.Message);

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

        [HttpPost("SaveGainLossEntry", Name = "SaveGainLossEntry")]
        public IActionResult SaveGainLossEntry(ReqGainLossEntry gainLossEntrySave)
        {
            try
            {
                if (gainLossEntrySave.method_name == null)
                {
                    return BadRequest();
                }

                List<CommonOutput> res_Obj = new List<CommonOutput>();
                string destination_name = gainLossEntrySave.destination_name + "";
                res_Obj = new CollectionDAL(destination_name).SaveGainLossEntry(gainLossEntrySave);
                return Ok(res_Obj);

            }
            catch (Exception e)
            {
                var currentUrl = $"{HttpContext.Request.Scheme}://{HttpContext.Request.Host}{HttpContext.Request.Path}{HttpContext.Request.QueryString}";
                new Common_API_DAL(gainLossEntrySave.destination_name).ApiLog("Create", gainLossEntrySave.org_id, "CollectionController", currentUrl, JsonConvert.SerializeObject(gainLossEntrySave), "500", e.Message);

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
