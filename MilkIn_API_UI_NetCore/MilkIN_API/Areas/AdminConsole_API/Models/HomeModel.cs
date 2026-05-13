namespace MilkIN_API.Areas.AdminConsole_API.Models
{
	public class ReqMasterData
	{
		public string? method_name { get; set; }
		public string? org_id { get; set; }
		public string? parentfield_id { get; set; }
		public string? user_id { get; set; }
		public string? destination_name { get; set; }

        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }

        public string? user_name { get; set; }

        public string? date { get; set; }

        public string? mcc_id { get; set; }


    }

    public class MasterDetails
	{
		public string? item_id { get; set; }
		public string? item_value { get; set; }
	}

	public class ReqDashboard
	{
		public string? method_name { get; set; }
		public string? org_id { get; set; }
		public string? user_id { get; set; }
		public string? destination_name { get; set; }

        public string? date { get; set; }

        public string? mcc_id { get; set; }
        public string? user_type { get; set; }

    }

	public class DashboardDetails
	{
		public string? collection_rmrdmorning { get; set; }
		public string? collection_rmrdevening { get; set; }
		public string? collection_bmc { get; set; }
		public string? collection_total { get; set; }
		public string? grn_rmrdmorning { get; set; }
		public string? grn_rmrdevening { get; set; }
		public string? grn_bmc { get; set; }
		public string? grn_total { get; set; }

        public string? date { get; set; }

        public string? created_on { get; set; }

        public string? mcc_id { get; set; }

        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }
        public string? mcctype_name { get; set; }
        public string? mccworktype_name { get; set; }



        public string? collection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? farmer_name { get; set; }
        public string? quantity_ltr { get; set; }
        public string? fat { get; set; }
        public string? snf { get; set; }
        public string? old_rate { get; set; }
        public string? old_amount { get; set; }
        public string? new_rate { get; set; }
        public string? new_amount { get; set; }
        public string? diff_amount { get; set; }
        public string? collectionshift_name { get; set; }



        public string? id { get; set; }
        public string? name { get; set; }
        public string? user_type { get; set; }


        public string? code { get; set; }
        public string? mustercycle { get; set; }
        public string? amount { get; set; }





    }
}
