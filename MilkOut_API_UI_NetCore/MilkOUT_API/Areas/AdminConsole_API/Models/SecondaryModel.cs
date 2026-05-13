namespace MilkOUT_API.Areas.AdminConsole_API.Models
{

    /*----  ----    ----    ----    Retailer Order - Request & Response Model   ----    ----    ----    ----*/
    public class ReqRetailerOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? retailerorder_id { get; set; }
        public string? retailer_id { get; set; }
        public string? dealer_id { get; set; }
        public string? salesuser_id { get; set; }
        public string? remarks { get; set; }
        public string? search_period { get; set; }
        public string? salesarea_id { get; set; }

        public string? retailerorderitem_id { get; set; }
        public string? product_id { get; set; }

        public string? uom { get; set; }
        public string? quantity { get; set; }

        public string? request_for { get; set; }


 public string? status { get; set; }

    }
    public class ResRetailerOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_closed { get; set; }
        public string? retailerorder_id { get; set; }
        public string? retailer_id { get; set; }
        public string? dealer_id { get; set; }
        public string? salesuser_id { get; set; }
        public string? remarks { get; set; }
        public string? search_period { get; set; }
        public string? salesarea_id { get; set; }
        public string? order_no { get; set; }
        public string? order_date { get; set; }
        public string? retailer_name { get; set; }
        public string? salesuser_name { get; set; }
        public string? dealer_name { get; set; }
        public string? no_of_items { get; set; }

        public string? retailerorderitem_id { get; set; }
        public string? product_id { get; set; }
        public string? product_name { get; set; }
        public string? quantity { get; set; }
        public string? rate { get; set; }

        public string? uom { get; set; }


        public string? total_quantity { get; set; }

    }


    /*----  ----    ----    ----    Dealer Stock - Request & Response Model   ----    ----    ----    ----*/
    public class ReqDealerStock
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? dealerstock_id { get; set; }
        public string? entry_period { get; set; }
        public string? dealer_id { get; set; }
        public int month_year { get; set; }
        public string? product_data { get; set; }
        public string? dealerstock_date { get; set; }

    }
    public class ResDealerStock
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }


        public string? entry_date { get; set; }
        public string? created_on { get; set; }
        public string? no_of_items { get; set; }
        public string? product_data { get; set; }
        public string? month_year { get; set; }
        public string? month_year_name { get; set; }
        public string? product_id { get; set; }
        public string? product_name { get; set; }
        public string? quantity { get; set; }

        public string? dealerstock_id { get; set; }
        public string? entry_period { get; set; }
        public string? dealer_id { get; set; }
        public string? dealer_name { get; set; }

    }
}
