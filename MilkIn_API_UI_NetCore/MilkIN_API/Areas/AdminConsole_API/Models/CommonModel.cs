namespace MilkIN_API.Areas.AdminConsole_API.Models
{
	public class CommonOutput
	{
		public int result_id { get; set; }
		public string? result_description { get; set; }
		public string? result_extra_key { get; set; }
	}

    public class OrgOutPut
    {
        public string? ConnectionName { get; set; }
    }

    public class SAPCommonOutput
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? entry_id { get; set; }
        public string? transaction_name { get; set; }

        public string? request_url { get; set; }

        public string? request_body { get; set; }

        public string? response_code { get; set; }
        public string? response_body { get; set; }

    }
}
