namespace MilkOUT_UI.Models
{
    public class ReqQuotation
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? formattedStartDate { get; set; }
        public string? formattedEndDate { get; set; }

        public string? quotation_id { get; set; }
        public string? dealer_id { get; set; }
    }
}
