namespace MilkIN_API.Areas.AgentApp_API.Models
{
    public class CommonOutput
    {
        public int result_id { get; set; }
        public string? result_description { get; set; }
        public string? result_extra_key { get; set; }
        public string? sms_msg { get; set; }
        public string? mobile_no { get; set; }

    }

    public class Common_Output
	{
		public int result_id { get; set; }
		public string? result_description { get; set; }
		public string? result_extra_key { get; set; }
	}


    public class Output
    {
        public int result_id { get; set; }
        public string? result_description { get; set; }
        public string? result_extra_key { get; set; }
        public string? sms_msg { get; set; }
        public string? temp_id { get; set; }
        public string? mobile_no { get; set; }
    }


}
