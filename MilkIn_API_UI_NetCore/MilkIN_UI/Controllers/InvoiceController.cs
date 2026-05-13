using Microsoft.AspNetCore.Mvc;
using MilkIN_UI.Models;
using Newtonsoft.Json;
using MilkIN_UI.DAL;
using System.Text.Json;
using MilkIN_UI.Filters;
using System.Net.Http.Headers;
using System.Text;
using System.Data;
using ExcelDataReader;
using System.IO.Compression;
using Microsoft.AspNetCore.Mvc.Filters;


namespace MilkIN_UI.Controllers
{
    public class InvoiceController : Controller
    {
        private readonly IConfiguration _configuration;

        public InvoiceController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [LoginAuthFilter("M071", "Display")]
        public IActionResult Farmer()
        {
            return View();
        }
        public IActionResult FarmerAdd()
        {
            return PartialView("_FarmerEntry");
        }
        [HttpPost]
        public IActionResult InvoiceFarmer(ReqInvoiceFarmer invoiceFarmer)
        {
            try
            {
                if (invoiceFarmer.method_name == null || invoiceFarmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceFarmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceFarmer.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceFarmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceFarmer);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceFarmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M072", "Display")]
        public IActionResult MCC()
        {
            return View();
        }
        public IActionResult MCCAdd()
        {
            return PartialView("_MCCEntry");
        }
        public IActionResult MCCView()
        {
            return PartialView("_MCCEntryView");
        }
        [HttpPost]
        public IActionResult InvoiceMCC(ReqInvoiceMCC invoiceMCC)
        {
            try
            {
                if (invoiceMCC.method_name == null || invoiceMCC.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceMCC.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceMCC.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceMCC.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceMCC);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceMCC.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }

        [LoginAuthFilter("M073", "Display")]
        public IActionResult Transporter()
        {
            return View();
        }
        public IActionResult TransporterAdd()
        {
            return PartialView("_TransporterEntry");
        }

        [HttpPost]
        public IActionResult InvoiceTransporter(ReqInvoiceTransporter invoiceTransporter)
        {
            try
            {
                if (invoiceTransporter.method_name == null || invoiceTransporter.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceTransporter.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceTransporter.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceTransporter.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceTransporter);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceTransporter.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [LoginAuthFilter("M077", "Display")]
        public IActionResult FarmerIncome()
        {
            return View();
        }
        public IActionResult FarmerIncomeAdd()
        {
            return PartialView("_FarmerIncomeEntry");
        }
        public IActionResult FarmerIncomeView()
        {
            return PartialView("_FarmerIncomeEntry");
        }
        [HttpPost]
        public IActionResult InvoiceFarmerIncome(ReqInvoiceFarmerIncome invoiceFarmerIncome)
        {
            try
            {
                if (invoiceFarmerIncome.method_name == null || invoiceFarmerIncome.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceFarmerIncome.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceFarmerIncome.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceFarmerIncome.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceFarmerIncome);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceFarmerIncome.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [LoginAuthFilter("M082", "Display")]
        public IActionResult MissingFarmerMilkEntry()
        {
            return View();
        }
        
        [HttpPost]
        public IActionResult InvoiceMissingFarmer(ReqMissingFarmer invoiceMissingFarmer)
        {
            try
            {
                if (invoiceMissingFarmer.method_name == null || invoiceMissingFarmer.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceMissingFarmer.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceMissingFarmer.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceMissingFarmer.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceMissingFarmer);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceMissingFarmer.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }



        [LoginAuthFilter("M083", "Display")]
        public IActionResult Rebate()
        {
            return View();
        }

        [HttpPost]
        public IActionResult InvoiceRebate(ReqRebate invoiceRebate)
        {
            try
            {
                if (invoiceRebate.method_name == null || invoiceRebate.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceRebate.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceRebate.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceRebate.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceRebate);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceRebate.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [LoginAuthFilter("M084", "Display")]
        public IActionResult RateChange()
        {
            return View();
        }

        [HttpPost]
        public IActionResult InvoiceRateChange(ReqRateChange invoiceRateChange)
        {
            try
            {
                if (invoiceRateChange.method_name == null || invoiceRateChange.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceRateChange.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceRateChange.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceRateChange.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceRateChange);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceRateChange.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }


        [LoginAuthFilter("M085", "Display")]
        public IActionResult SAPPosting()
        {
            return View();
        }

        [HttpPost]
        public IActionResult InvoiceSAPPosting(SAPPosting invoiceSAPPosting)
        {
            try
            {
                if (invoiceSAPPosting.method_name == null || invoiceSAPPosting.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoiceSAPPosting.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoiceSAPPosting.user_id = HttpContext.Session.GetString("SessionUserId");
                invoiceSAPPosting.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoiceSAPPosting);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoiceSAPPosting.api_end_point;
                string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);
                return Ok(response);
            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }




        public JsonResult CovertExcelToTable([FromForm] ReqModuleExport req)
        {
            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
            try
            {
                if (req.File != null && req.File.Length > 0)
                {
                    DataSet ds = new DataSet();
                    using (var fileStream = req.File.OpenReadStream())
                    {
                        if (Path.GetExtension(req.File.FileName).Equals(".xls") ||
                            Path.GetExtension(req.File.FileName).Equals(".xlsx"))
                        {
                            // Excel file
                            IExcelDataReader excelReader = ExcelReaderFactory.CreateReader(fileStream);
                            ds = excelReader.AsDataSet();
                        }
                        else if (Path.GetExtension(req.File.FileName).Equals(".csv"))
                        {
                            // CSV file
                            using (var reader = new StreamReader(fileStream, Encoding.UTF8))
                            {
                                ds.Tables.Add(ConvertCsvToDataTable(reader));
                            }
                        }
                        else
                        {
                            return Json(new { status = 400, message = "Unsupported file format. Please upload a CSV or Excel file." });
                        }
                    }

                    DataTable dt = ds.Tables[0];
                    var firstRow = dt.Rows[0];

                    DataTable newDt = dt.Copy();
                    for (int i = 0; i < firstRow.ItemArray.Length; i++)
                    {
                        newDt.Columns[i].ColumnName = firstRow.ItemArray[i].ToString();
                    }
                    newDt.Rows.RemoveAt(0);

                    return Json(new { status = 200, data = JsonConvert.SerializeObject(newDt) });
                }
                else
                {
                    return Json(new { status = 400, message = "No file uploaded." });
                }
            }
            catch (Exception ex)
            {
                var errMsg = ex.Message;
                return Json(new { status = 500, message = errMsg });
            }
        }

        private DataTable ConvertCsvToDataTable(StreamReader reader)
        {
            DataTable dt = new DataTable();
            bool isFirstRow = true;
            string line;
            while ((line = reader.ReadLine()) != null)
            {
                string[] data = line.Split(',');
                if (isFirstRow)
                {
                    foreach (string column in data)
                    {
                        dt.Columns.Add(column);
                    }
                    isFirstRow = false;
                }
                else
                {
                    dt.Rows.Add(data);
                }
            }
            return dt;
        }



        [LoginAuthFilter("M080", "Display")]
        public IActionResult InvoicePublish()
        {
            return View();
        }
        public IActionResult InvoicePublishAdd()
        {
            return PartialView("_InvoicePublishEntry");
        }
        [HttpPost]
        public IActionResult InvoicePublish(ReqInvoicePublish invoicePublish)
        {
            try
            {
                if (invoicePublish.method_name == null || invoicePublish.api_end_point == null)
                {
                    return BadRequest();
                }

                ResAPICommonOutput res_Obj = new ResAPICommonOutput();
                invoicePublish.org_id = HttpContext.Session.GetString("SessionOrgId");
                invoicePublish.user_id = HttpContext.Session.GetString("SessionUserId");
                invoicePublish.user_name = HttpContext.Session.GetString("SessionUserName");

                string res_Str = JsonConvert.SerializeObject(invoicePublish);
                string APIEndPoint = "/v1/api/admin/invoice/" + invoicePublish.api_end_point;
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
        public IActionResult CreateZipFile(ReqInvoicePublish invoicePublish)
        {
            ResAPICommonOutput res_Obj = new ResAPICommonOutput();
            invoicePublish.org_id = HttpContext.Session.GetString("SessionOrgId");
            invoicePublish.user_id = HttpContext.Session.GetString("SessionUserId");
            invoicePublish.user_name = HttpContext.Session.GetString("SessionUserName");

            string res_Str = JsonConvert.SerializeObject(invoicePublish);
            string APIEndPoint = "/v1/api/admin/invoice/" + invoicePublish.api_end_point;
            string response = new CommonDAL().CallAPI(APIEndPoint, res_Str);

            List<ReqInvoicedownloadPublish> reslist = Newtonsoft.Json.JsonConvert.DeserializeObject<List<ReqInvoicedownloadPublish>>(response);

            string filename = "InvoicePublish_" + DateTime.Now.ToString("yyyyMMddTHHmmss") + ".zip";
            if (!Directory.Exists(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", "")))
            {
                Directory.CreateDirectory(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", ""));
            }
            var zip = ZipFile.Open(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", "") + filename, ZipArchiveMode.Create);
            try
            {


                // Create and open a new ZIP file
                int i = 0;
                foreach (var file in reslist)
                {
                    // Add the entry for each file
                    zip.CreateEntryFromFile(_configuration.GetValue<string>("AppSettings:InvoiceFilePath", "") + file.invoice_link.ToString(),file.farmer_name+"_"+file.invoice_link.ToString(), CompressionLevel.Optimal);
                    i++;
                }
                zip.Dispose();



                var bytes = System.IO.File.ReadAllBytes(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", "") + filename);
                if (Directory.Exists(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", "")))
                    Directory.Delete(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", ""), true);

                HttpContext.Session.Set("Pdffiles", bytes);
                HttpContext.Session.SetString("filename", filename);

                return Ok(filename);
            }
            catch (Exception ex)
            {
                zip.Dispose();
                if (Directory.Exists(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", "")))
                    Directory.Delete(_configuration.GetValue<string>("AppSettings:InvoiceFolderPathZip", ""), true);
                return StatusCode(500, ex.Message.ToString());

            }
        }

        public IActionResult DownloadInvoiceFile()
        {
            
            var bytedata = HttpContext.Session.Get("Pdffiles");
            if (bytedata != null)
            {
                HttpContext.Session.Remove("Pdffiles");
                return File(bytedata, "application/zip", HttpContext.Session.GetString("filename"));
            }
            else
            {
                return null;

            }

        }


    }

    public class ReqModuleExport
    {
        public IFormFile File { get; set; }
    }



}