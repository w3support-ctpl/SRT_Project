

using Microsoft.AspNetCore.Mvc;
using MilkIN_API.Areas.Common_Api.Models;
using System.Net.Http.Headers;

namespace MilkIN_API.Areas.Common_Api.Controllers
{
    [Route("v1/api/common/upload/")]
    [ApiController]
    public class UploadFileController : Controller
    {
        private readonly ILogger<UploadFileController> _logger;

        private readonly IConfiguration _configuration;
        public UploadFileController(ILogger<UploadFileController> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
        }


        [HttpPost("UploadFile", Name = "UploadFile")]
        public IActionResult UploadFile([FromForm] ReqFileInput req)
        {
            var uploadfilebasepath = _configuration.GetValue<string>("AppSettings:UploadFolderPath", "");
            var files = HttpContext.Request.Form.Files;
            long size = 0;
            var file = Request.Form.Files;
            var filename = ContentDispositionHeaderValue
            .Parse(files[0].ContentDisposition)
            .FileName
            .Trim('"');
            var Orgfilename = ContentDispositionHeaderValue
          .Parse(files[0].ContentDisposition)
          .FileName
          .Trim('"');

            size += files[0].Length;
            string FilePath;
            string Relative_FilePathname;
            string Document_Path = uploadfilebasepath + "/" + req.AppName + "/";
            if (!Directory.Exists(Document_Path))
            {
                Directory.CreateDirectory(Document_Path);
            }
            Guid loGuid = Guid.NewGuid();
            filename = loGuid + "_" + filename;
            FilePath = Document_Path+ "/" + $@"{filename}";
            Relative_FilePathname = "/" + req.AppName + "/" + $@"{filename}";
            size += files[0].Length;
            using (FileStream fs = System.IO.File.Create(FilePath))
            {
                files[0].CopyTo(fs);
                fs.Flush();
            }


            try
            {
                return Ok(new { status = 200, data = Relative_FilePathname, newfilename = filename, orginalfilename = Orgfilename, Relative_FilePath = Relative_FilePathname });

            }

            catch (Exception ex)
            {
                var ErrMsg = ex.Message;
                return Json(new { status = 500, data = ErrMsg });
            }
        }







    }






    //[HttpPost("UploadImages", Name = "UploadImages")]
    //public IActionResult UploadImages([FromForm] ReqFileInput req)
    //{
    //    var uploadfilebasepath = _configuration.GetValue<string>("AppSettings:UploadFolderPath", "");
    //    var files = HttpContext.Request.Form.Files;
    //    long size = 0;
    //    var file = Request.Form.Files;
    //    var filename = ContentDispositionHeaderValue
    //    .Parse(files[0].ContentDisposition)
    //    .FileName
    //    .Trim('"');
    //    var Orgfilename = ContentDispositionHeaderValue
    //  .Parse(files[0].ContentDisposition)
    //  .FileName
    //  .Trim('"');

    //    size += files[0].Length;
    //    string FilePath;
    //    string Relative_FilePathname;
    //    string Document_Path = uploadfilebasepath + req.AppName + "/UserImage/";
    //    if (!Directory.Exists(Document_Path))
    //    {
    //        Directory.CreateDirectory(Document_Path);
    //    }
    //    Guid loGuid = Guid.NewGuid();
    //    filename = loGuid + "_" + filename;
    //    FilePath = uploadfilebasepath + req.AppName + "/UserImage/" + $@"{filename}";
    //    Relative_FilePathname = req.AppName + "/UserImage/" + $@"{filename}";
    //    size += files[0].Length;
    //    using (FileStream fs = System.IO.File.Create(FilePath))
    //    {
    //        files[0].CopyTo(fs);
    //        fs.Flush();
    //    }


    //    try
    //    {

    //        return Ok(new { status = 200, data = Relative_FilePathname, newfilename = filename, orginalfilename = Orgfilename, Relative_FilePath = Relative_FilePathname });

    //    }

    //    catch (Exception ex)
    //    {
    //        var ErrMsg = ex.Message;
    //        return Json(new { status = 500, data = ErrMsg });
    //    }
    //}



}
