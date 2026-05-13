using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.Models;
using Newtonsoft.Json;
using MilkIN_UI.DAL;
using System.Net.Http.Headers;
using System.Text;
using System.Data;
using ExcelDataReader;
using MilkIN_UI.Filters;

namespace MilkIN_UI.Controllers
{
    public class TransporterController : Controller
    {
        private readonly IConfiguration _configuration;
        public TransporterController(IConfiguration IConfiguration) {
            _configuration = IConfiguration;
        }

        [LoginAuthFilter("M022", "Display")]
        public IActionResult Route()
        {
            return View();
        }

        public IActionResult RouteAdd()
        {
            return PartialView("_RouteEntry");
        }

        public IActionResult RouteEdit()
        {
            return PartialView("_RouteEntry");
        }
        [HttpPost]
        public IActionResult Route(ReqRoute route)
        {
            try
            {
                if (route.method_name == null || route.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                route.org_id = HttpContext.Session.GetString("SessionOrgId");
                route.user_id = HttpContext.Session.GetString("SessionUserId");
                route.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(route);
                string APIEndPoint = "/v1/api/admin/transporter/" + route.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        // ROUTE ITEM  GET SAVE
        [HttpPost]
        public IActionResult RouteItem(ReqRouteItem routeItem)
        {
            try
            {
                if (routeItem.method_name == null || routeItem.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                routeItem.org_id = HttpContext.Session.GetString("SessionOrgId");
                routeItem.user_id = HttpContext.Session.GetString("SessionUserId");
                routeItem.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(routeItem);
                string APIEndPoint = "/v1/api/admin/transporter/" + routeItem.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M023", "Display")]
        public IActionResult TruckSheet()
        {
            ViewBag.VehicleType = "Truck";
            return View();
        }

        [LoginAuthFilter("M023", "Display")]
        public IActionResult TankerSheet()
        {
            ViewBag.VehicleType = "Tanker";
            return View("TruckSheet");
        }

        public IActionResult VehicleSheetAdd()
        {
            return PartialView("_TruckSheetEntry");
        }

        public IActionResult VehicleSheetEdit()
        {
            return PartialView("_TruckSheetEntry");
        }
        // For Truck & Tanker
        [HttpPost]
        public IActionResult VehicleSheet(ReqVehicleSheet vehicleSheet)
        {
            try
            {
                if (vehicleSheet.method_name == null || vehicleSheet.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                vehicleSheet.org_id = HttpContext.Session.GetString("SessionOrgId");
                vehicleSheet.user_id = HttpContext.Session.GetString("SessionUserId");
                vehicleSheet.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(vehicleSheet);
                string APIEndPoint = "/v1/api/admin/transporter/" + vehicleSheet.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [LoginAuthFilter("M064", "Display")]
        public IActionResult ManageTrip()
        {
            return View();
        }

        public IActionResult ManageTripAdd()
        {
            return PartialView("_ManageTripEntry");
        }

        public IActionResult ManageTripEdit()
        {
            return PartialView("_ManageTripEntry");
        }
        public IActionResult ManageTripMCC()
        {
            return PartialView("_ManageTripMCCEntry");
        }
        [HttpPost]
        public IActionResult ManageTrip(ReqManageTrip manageTrip)
        {
            try
            {
                if (manageTrip.method_name == null || manageTrip.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                manageTrip.org_id = HttpContext.Session.GetString("SessionOrgId");
                manageTrip.user_id = HttpContext.Session.GetString("SessionUserId");
                manageTrip.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(manageTrip);
                string APIEndPoint = "/v1/api/admin/transporter/" + manageTrip.api_end_point;
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
        public JsonResult CovertExcelToTable([FromForm] ReqModuleExport req)
        {
           // var uploadfilebasepath = _configuration.GetValue<string>("AppSettings:UploadFolderPath", "");
            var files = HttpContext.Request.Form.Files;
           // long size = 0;
            var file = Request.Form.Files;
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
            //var httpRequest = files.Request;
            IExcelDataReader excelReader = null;
            IFormFile Inputfile = null;
            Stream FileStream = null;
            DataSet ds = new DataSet();
            try
            {
                if (files.Count > 0)
                {
                    Inputfile = files[0];
                    FileStream = Inputfile.OpenReadStream();
                    if (Inputfile != null && FileStream != null)
                    {
                        excelReader = ExcelReaderFactory.CreateReader(FileStream);
                    }
                }
                if (excelReader != null)
                {
                    ds = excelReader.AsDataSet();
                }
                DataTable dt = ds.Tables[0];
                var firstrow = dt.Rows[0];

               
                DataTable newdt = dt;
                for (int i = 0; i < firstrow.ItemArray.Length; i++)
                {

                    dt.Columns["Column" + i].ColumnName = firstrow.ItemArray[i].ToString();
                }
                dt.Rows.RemoveAt(0);

                return Json(new { status = 200, data = JsonConvert.SerializeObject(newdt) });
            }
            catch (Exception ex)
            {
                var ErrMsg = ex.Message;
                return Json(new { status = 500, data = ErrMsg });
            }
        }



        [LoginAuthFilter("M067", "Display")]
        public IActionResult Survey()
        {
            return View();
        }

        public IActionResult SurveyAdd()
        {
            return PartialView("_SurveyEntry");
        }

        public IActionResult SurveyEdit()
        {
            return PartialView("_SurveyEntry");
        }
        [HttpPost]
        public IActionResult Survey(ReqSurvey survey)
        {
            try
            {
                if (survey.method_name == null || survey.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                survey.org_id = HttpContext.Session.GetString("SessionOrgId");
                survey.user_id = HttpContext.Session.GetString("SessionUserId");
                survey.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(survey);
                string APIEndPoint = "/v1/api/admin/transporter/" + survey.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [LoginAuthFilter("M081", "Display")]
        public IActionResult DieselUpload()
        {
            return View();
        }

        public IActionResult DieselUploadAdd()
        {
            return PartialView("_DieselUploadEntry");
        }

        public IActionResult DieselUploadEdit()
        {
            return PartialView("_DieselUploadEntry");
        }
        [HttpPost]
        public IActionResult DieselUpload(ReqDieselUpload dieselUpload)
        {
            try
            {
                if (dieselUpload.method_name == null || dieselUpload.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                dieselUpload.org_id = HttpContext.Session.GetString("SessionOrgId");
                dieselUpload.user_id = HttpContext.Session.GetString("SessionUserId");
                dieselUpload.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(dieselUpload);
                string APIEndPoint = "/v1/api/admin/transporter/" + dieselUpload.api_end_point;
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
