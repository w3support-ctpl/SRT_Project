namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    public class ReqDelivery
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? start_date { get; set; }
        public string? end_date { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? dealer_id { get; set; }

        public string? delivery_no { get; set; }

    }

    public class ResDelivery
    {
        public string? DeliveryDocument { get; set; }
        public string? ActualGoodsMovementDate { get; set; }
        public string? ShipToParty { get; set; }
        public string? SoldToParty { get; set; }
        public string? OrderID { get; set; }
        public string? TransportationGroup { get; set; }
        public string? CreatedByUser { get; set; }

        public string? CreationDate { get; set; }

        public string? OverallGoodsMovementStatus  { get; set; }
    }


    public class ResDeliveryitem
    {
        public string? Material { get; set; }
        public string? BillingDocument { get; set; }
        public string? BillingDocumentItem { get; set; }
        public string? BillingDocumentItemText { get; set; }
        public string? Plant { get; set; }
        public string? ItemWeightUnit { get; set; }
        public string? NetAmount { get; set; }
        public string? BillingDocumentDate { get; set; }
        public string? BillingQuantity { get; set; }
        public string? ReferenceSDDocument { get; set; }

        public string? ReferenceSDDocumentItem { get; set; }
    }



}
