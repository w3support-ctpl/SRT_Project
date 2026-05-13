namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    public class ReqInquiry
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? salesinquiry { get; set; }
        public string? salesarea { get; set; }
        public string? destination { get; set; }
        public string? customerreference { get; set; }
        public string? salesnote { get; set; }
        public string? item_id { get; set; }
        public string? rate { get; set; }
        public string? quantity { get; set; }
        public string? uom { get; set; }
        public string? price { get; set; }
        public string? lrdetails { get; set; }
        public string? productioninstructions { get; set; }
        public string? search_period { get; set; }
        public string? entry_item_id { get; set; }
        public string? dealer_id { get; set; }
        public string? inquiry_status { get; set; }

        public string? sales_person { get; set; }

        public string? lr_details { get; set; }

        public string? retailer_id { get; set; }

         public string? salesuser_id { get; set; }


    }

    public class ResProductMaster
    {
        public string? item_id { get; set; }
        public string? item_value { get; set; }
        public string? item_unit { get; set; }

    }

    public class ResInquiry
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? inquiry_no { get; set; }
        public string? inquiry_date { get; set; }
        public string? inquiry_status { get; set; }
        public string? customer_reference { get; set; }
        public string? amount { get; set; }
        public string? currency { get; set; }
        public string? salesinquiry { get; set; }
        public string? destination { get; set; }
        public string? salesnote { get; set; }
        public string? salesarea { get; set; }
        public string? material { get; set; }
        public string? item_id { get; set; }
        public string? quantity { get; set; }
        public string? lrdetails { get; set; }
        public string? production_instructions { get; set; }
        public string? item_description { get; set; }
        public string? rate { get; set; }
        public string? uom { get; set; }
        public string? price { get; set; }
        public string? dealer_id { get; set; }
public string? dealer_name { get; set; }
        public string? sales_person { get; set; }

        public string? productgroup_id { get; set; }

        public string? uom_list { get; set; }

        public string? retailer_id { get; set; }

         public string? salesuser_id { get; set; }

         public string? retailer_name { get; set; }

         public string? salesuser_name { get; set; }

    }
}
