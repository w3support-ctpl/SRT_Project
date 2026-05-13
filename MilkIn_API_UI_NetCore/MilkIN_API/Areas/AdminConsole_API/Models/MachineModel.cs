namespace MilkIN_API.Areas.AdminConsole_API.Models
{
    public class ReqMachine
    {
        // ReqFarmerSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? machine_type { get; set; }
        public string? machine_value { get; set; }

        public string? destination_name { get; set; }
    }

}
