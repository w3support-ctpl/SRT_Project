using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.Models;
using Newtonsoft.Json;
using MilkIN_UI.DAL;

namespace MilkIN_UI.Controllers
{
    public class CollectionController : Controller
    {
        /*----  ----    ----    ----    Milk Collection   ----    ----    ----    ----*/

        public IActionResult MilkCollection()
        {
            return View();
        }
        public IActionResult MilkCollectionAdd()
        {
            return PartialView("_MilkCollectionEntry");
        }
        /*----  ----    ----    ----    Milk Collection Truck, Tanker, & MCC   ----    ----    ----    ----*/

        public IActionResult MilkCollectionTruckEntry()
        {
            return PartialView("_MilkCollectionTruckEntry");
        }
        public IActionResult MilkCollectionTankerEntry()
        {
            return PartialView("_MilkCollectionTankerEntry");
        }
        public IActionResult MilkCollectionMCCEntry()
        {
            return PartialView("_MilkCollectionMCCEntry");
        }
        [HttpPost]
        public IActionResult MilkCollection(ReqMilkCollection milkCollection)
        {
            try
            {
                if (milkCollection.method_name == null || milkCollection.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkCollection.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkCollection.user_id = HttpContext.Session.GetString("SessionUserId");
                milkCollection.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkCollection);
                string APIEndPoint = "/v1/api/admin/collection/" + milkCollection.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Milk Collection Quantity   ----    ----    ----    ----*/

        [HttpPost]
        public IActionResult MilkCollectionQuantity(ReqMilkCollectionQuantity milkCollectionQuantity)
        {
            try
            {
                if (milkCollectionQuantity.method_name == null || milkCollectionQuantity.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkCollectionQuantity.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkCollectionQuantity.user_id = HttpContext.Session.GetString("SessionUserId");
                milkCollectionQuantity.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkCollectionQuantity);
                string APIEndPoint = "/v1/api/admin/collection/" + milkCollectionQuantity.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Milk Collection Quality   ----    ----    ----    ----*/

        [HttpPost]
        public IActionResult MilkCollectionQuality(ReqMilkCollectionQuality milkCollectionQuality)
        {
            try
            {
                if (milkCollectionQuality.method_name == null || milkCollectionQuality.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkCollectionQuality.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkCollectionQuality.user_id = HttpContext.Session.GetString("SessionUserId");
                milkCollectionQuality.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkCollectionQuality);
                string APIEndPoint = "/v1/api/admin/collection/" + milkCollectionQuality.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /*----  ----    ----    ----    Milk Collection Supervisor - Chemist   ----    ----    ----    ----*/
        /*
        [HttpPost]
        public IActionResult MilkCollectionSupervisor(ReqMilkCollectionSupervisor milkCollectionSupervisor)
        {
            try
            {
                if (milkCollectionSupervisor.method_name == null || milkCollectionSupervisor.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkCollectionSupervisor.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkCollectionSupervisor.user_id = HttpContext.Session.GetString("SessionUserId");
                milkCollectionSupervisor.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkCollectionSupervisor);
                string APIEndPoint = "/v1/api/admin/collection/" + milkCollectionSupervisor.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
        */


        /*----  ----    ----    ----    Milk Collection Analyst   ----    ----    ----    ----*/
        /*

        [HttpPost]
        public IActionResult MilkCollectionAnalyst(ReqMilkCollectionAnalyst milkCollectionAnalyst)
        {
            try
            {
                if (milkCollectionAnalyst.method_name == null || milkCollectionAnalyst.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                milkCollectionAnalyst.org_id = HttpContext.Session.GetString("SessionOrgId");
                milkCollectionAnalyst.user_id = HttpContext.Session.GetString("SessionUserId");
                milkCollectionAnalyst.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(milkCollectionAnalyst);
                string APIEndPoint = "/v1/api/admin/collection/" + milkCollectionAnalyst.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        */


        /*----  ----    ----    ----    Trip Document   ----    ----    ----    ----*/

        public IActionResult Trip()
        {
            return View();
        }
        public IActionResult TripEdit()
        {
            return PartialView("_TripEntry");
        }
        [HttpPost]
        public IActionResult TripDocument(ReqTripDocument tripDocument)
        {
            try
            {
                if (tripDocument.method_name == null || tripDocument.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                tripDocument.org_id = HttpContext.Session.GetString("SessionOrgId");
                tripDocument.user_id = HttpContext.Session.GetString("SessionUserId");
                tripDocument.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(tripDocument);
                string APIEndPoint = "/v1/api/admin/collection/" + tripDocument.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        public IActionResult GoodsInwardPosting()
        {
            return View();
        }
        public IActionResult GoodsInwardPostingView()
        {
            return PartialView("_GoodsInwardPostingView");
        }
        public IActionResult GoodsInwardPostingEdit()
        {
            return PartialView("_GoodsInwardPostingEdit");
        }
        [HttpPost]
        public IActionResult GoodsInwardPosting(ReqGoodsInwardPosting GoodsInwardPosting)
        {
            try
            {
                if (GoodsInwardPosting.method_name == null || GoodsInwardPosting.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                GoodsInwardPosting.org_id = HttpContext.Session.GetString("SessionOrgId");
                GoodsInwardPosting.user_id = HttpContext.Session.GetString("SessionUserId");
                GoodsInwardPosting.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(GoodsInwardPosting);
                string APIEndPoint = "/v1/api/admin/collection/" + GoodsInwardPosting.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        /** */

        public IActionResult GainLossEntry()
        {
            return View();
        }

        public IActionResult GainLossEntryEdit()
        {
            return PartialView("_GainLossEntryEntry");
        }

        [HttpPost]
        public IActionResult GainLossEntry(ReqGainLossEntry gainLossEntry)
        {
            try
            {
                if (gainLossEntry.method_name == null || gainLossEntry.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                gainLossEntry.org_id = HttpContext.Session.GetString("SessionOrgId");
                gainLossEntry.user_id = HttpContext.Session.GetString("SessionUserId");
                gainLossEntry.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(gainLossEntry);
                string APIEndPoint = "/v1/api/admin/collection/" + gainLossEntry.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        /** */



        public IActionResult CollectionApproval()
        {
            return View();
        }

        public IActionResult CollectionApprovalEdit()
        {
            return PartialView("_CollectionApprovalEntry");
        }

        [HttpPost]
        public IActionResult CollectionApproval(ReqCollectionApproval collectionApproval)
        {
            try
            {
                if (collectionApproval.method_name == null || collectionApproval.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                collectionApproval.org_id = HttpContext.Session.GetString("SessionOrgId");
                collectionApproval.user_id = HttpContext.Session.GetString("SessionUserId");
                collectionApproval.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(collectionApproval);
                string APIEndPoint = "/v1/api/admin/collection/" + collectionApproval.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        public IActionResult QualityEntry()
        {
            return View();
        }
        public IActionResult QualityEntryEdit()
        {
            return PartialView("_QualityEntryEntry");
        }
        [HttpPost]
        public IActionResult QualityEntry(ReqQualityEntry qualityEntry)
        {
            try
            {
                if (qualityEntry.method_name == null || qualityEntry.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                qualityEntry.org_id = HttpContext.Session.GetString("SessionOrgId");
                qualityEntry.user_id = HttpContext.Session.GetString("SessionUserId");
                qualityEntry.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(qualityEntry);
                string APIEndPoint = "/v1/api/admin/collection/" + qualityEntry.api_end_point;
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
