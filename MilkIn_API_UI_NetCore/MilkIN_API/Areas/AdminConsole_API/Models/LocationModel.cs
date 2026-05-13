 namespace MilkIN_API.Areas.AdminConsole_API.Models
{
    public class ReqState
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? state_id { get; set; }
        public string? state_name { get; set; }
        public string? state_code { get; set; }
        public string? destination_name { get; set; }
        public string? user_id { get; set; }
        
    }
    public class ResState
    {
        public string? org_id { get; set; }
        public string? state_id { get; set; }
        public string? state_name { get; set; }
        public string? state_code { get; set; }
        public string? destination_name { get; set; }

    }
    public class ReqDistrict
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? district_name { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? district_code { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        
    }
    public class ResDistrict
	{
		public string? org_id { get; set; }
		public string? district_id { get; set; }
		public string? state_id { get; set; }
		public string? district_name { get; set; }
		public string? state_name { get; set; }
		public string? district_code { get; set; }
		public string? is_active { get; set; }
        public int is_locked { get; set; }
    }
    public class ReqTaluka
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? taluka_id { get; set; }
        public string? district_id { get; set; }
        public string? state_id { get; set; }
        public string? taluka_name { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? taluka_code { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }

    }
    public class ResTaluka
    {
        public string? org_id { get; set; }
        public string? taluka_id { get; set; }
        public string? taluka_name { get; set; }
        public string? taluka_code { get; set; }
        public string? district_id { get; set; }
        public string? district_name { get; set; }
        public string? state_id { get; set; }
        public string? state_name { get; set; }
        public string? is_active { get; set; }
        public int is_locked { get; set; }
    }
    public class ReqVillage
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? village_name { get; set; }
        public string? pin_code { get; set; }
        public string? destination_name { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        
    }
    public class ResVillage
    {
        public string? org_id { get; set; }
        public string? village_name { get; set; }
        public string? village_id { get; set; }
        public string? taluka_id { get; set; }
        public string? taluka_name { get; set; }
        public string? district_id { get; set; }
        public string? district_name { get; set; }
        public string? state_id { get; set; }
        public string? state_name { get; set; }
        public string? pin_code { get; set; }
        public string? is_active { get; set; }
        public int is_locked { get; set; }
    }
}
