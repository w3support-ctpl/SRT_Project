namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
	public class ReqMasterData
	{
		public string? method_name { get; set; }
		public string? org_id { get; set; }
		public string? parentfield_id { get; set; }

		public string? param1 { get; set; }
		public string? param2 { get; set; }

		public string? user_id { get; set; }
		public string? destination_name { get; set; }
	}

	public class MasterDetails
	{
		public string? item_id { get; set; }
		public string? item_value { get; set; }

		public string? item_uom { get; set; }
	}
}
