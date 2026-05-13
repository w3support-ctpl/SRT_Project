using System.Net;

namespace MilkIN_UI.Models
{
	public class ResAPICommonOutput
	{
		public HttpStatusCode ResponseCode { get; set; }
		public string? ResponseMessage { get; set; }
		public string? ResponseData { get; set; }
	}

	public class ResJSCommonOutput
	{
		public int result_id { get; set; }
		public string? result_description { get; set; }
		public string? result_extra_key { get; set; }
	}
}
