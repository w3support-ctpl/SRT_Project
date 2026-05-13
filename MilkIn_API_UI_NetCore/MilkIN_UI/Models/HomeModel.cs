namespace MilkIN_UI.Models
{
    public class ReqMasterData
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? parentfield_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }

        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }

        public string? collection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }
        public string? mcctype_name { get; set; }
        public string? mccworktype_name { get; set; }
        public string? quantity_ltr { get; set; }
        public string? fat { get; set; }
        public string? snf { get; set; }
        public string? old_rate { get; set; }
        public string? old_amount { get; set; }
        public string? new_rate { get; set; }
        public string? new_amount { get; set; }
        public string? diff_amount { get; set; }
        public string? collectionshift_name { get; set; }

        public string? user_name { get; set; }

        public string? created_on { get; set; }

        public string? mcc_id { get; set; }

        public string? date { get; set; }

        public string? user_type { get; set; }
    }

    public class MasterDetails
    {
        public string? item_id { get; set; }
        public string? item_value { get; set; }
    }
}
