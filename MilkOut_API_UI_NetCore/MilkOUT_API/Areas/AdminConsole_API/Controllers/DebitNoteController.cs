using Microsoft.AspNetCore.Mvc;
using MilkOUT_API.Areas.AdminConsole_API.DAL;
using MilkOUT_API.Areas.AdminConsole_API.Models;

namespace MilkOUT_API.Areas.AdminConsole_API.Controllers
{
    [Route("v1/api/admin/debitNote/")]
    [ApiController]
    public class DebitNoteController : Controller
    {
        private readonly ILogger<LoginController> _logger;

        public DebitNoteController(ILogger<LoginController> logger)
        {
            _logger = logger;
        }
        [HttpPost("GetDebitNote", Name = "GetDebitNote")]
        public IActionResult GetDebitNote(ReqDebitNote debitNote)
        {
            try
            {
                if (debitNote.method_name == null)
                {
                    return BadRequest();
                }

                List<ResDebitNote> res_Obj = new List<ResDebitNote>();
                string destination_name = debitNote.destination_name + "";
                // res_Obj = new DebitNoteDAL(destination_name).GetDebitNote(DebitNoteSearch);

                return Ok();

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;

                return StatusCode(500, ErrMsg);
            }
        }
    }
}
