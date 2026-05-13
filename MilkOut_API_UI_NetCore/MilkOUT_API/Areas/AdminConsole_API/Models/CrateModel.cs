namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    public class IssueCrateModel
    {

        public string? org_id { get; set; }
        public string? dealer_code { get; set; }

        public string? dealer_name { get; set; }

        public string? dispatch_date { get; set; }

        public string? quantity { get; set; }

        public string? material_code { get; set; }

        public string? invoice_number { get; set; }

        public string? batch { get; set; }

        public string? dispatch_time { get; set; }

        public string? delivery_item { get; set; }

    }



    public class Reqcratestock
    {

        public string? method { get; set; }
        public string? dealer_code { get; set; }

        public string? start_date { get; set; }

        public string? end_date { get; set; }


    }
















    public class ReqSAPMilkBatch
    {
        public string? PostingDate { get; set; }
        public string? GoodsMovementCode { get; set; }
        public string? MaterialDocumentHeaderText { get; set; }
        public string? ReferenceDocument { get; set; }
        public List<ReqSAPMilkBatchItem>? to_MaterialDocumentItem { get; set; }

    }
    public class ReqSAPMilkBatchGoodsMovementCode
    {
        public string? GoodsMovementCode { get; set; }
    }

    public class ReqSAPMilkBatchItem
    {
        public string? Material { get; set; }

        public string? Plant { get; set; }
        public string? Batch { get; set; }

        public string? StorageLocation { get; set; }

        public string? GoodsMovementType { get; set; }

        public string? PurchaseOrder { get; set; }

        public string? PurchaseOrderItem { get; set; }

        public string? GoodsMovementRefDocType { get; set; }

        public string? EntryUnit { get; set; }
        public string? QuantityInEntryUnit { get; set; }
        // public string? GdsMvtExtAmtInCoCodeCrcy { get; set; }
        public string? MaterialDocumentItemText { get; set; }
        public string? Supplier { get; set; }
        // public string? ManufactureDate { get; set; }

        public string? Customer { get; set; }

    }

}
