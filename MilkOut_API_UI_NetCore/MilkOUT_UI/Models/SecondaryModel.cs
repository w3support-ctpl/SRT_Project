namespace MilkOUT_UI.Models
{
    public class SecondaryModel
    {
        /*----  ----    ----    ----    Retailer Order - Request Model   ----    ----    ----    ----*/
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
            public string? quantity { get; set; }

            public string? request_for { get; set; }
            public string? uom { get; set; }

        }




        /*----  ----    ----    ----    Dealer Stock - Request Model   ----    ----    ----    ----*/
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
            public int month_id { get; set; }
            public int year_id { get; set; }
            public string? product_data { get; set; }
            public string? dealerstock_date { get; set; }

        }
    }
}
