using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkIn_SAPPosting.Models
{
    public class ReqSAPMilkBatchHeader
    {
        public string? Material { get; set; }
        public string? BatchIdentifyingPlant { get; set; }
        public string? Batch { get; set; }
        public string? CharcInternalID { get; set; }
        public string? CharcValueDependency { get; set; }
        public string? CharcFromNumericValue { get; set; }


    }

    public class ReqMilkCollectionInSAP
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? year { get; set; }
        public string? sap_doument_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }



    }

    public class ReqSAPMilkBatch
    {
        public string? PostingDate { get; set; }
        public string? GoodsMovementCode { get; set; }
        public string? MaterialDocumentHeaderText { get; set; }
        public string? ReferenceDocument { get; set; }
        public List<ReqSAPMilkBatchItem>? to_MaterialDocumentItem { get; set; }

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
        public string? GdsMvtExtAmtInCoCodeCrcy { get; set; }
        public string? MaterialDocumentItemText { get; set; }
        public string? Supplier { get; set; }
        public string? ManufactureDate { get; set; }

    }

    public class ReqGoodsInwardPosting
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? entry_id { get; set; }
        public string? tripdocument_id { get; set; }
    }

    public class ReqSAPMilkBatchItemCost
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
        public string? GdsMvtExtAmtInCoCodeCrcy { get; set; }
        public string? MaterialDocumentItemText { get; set; }
        public string? Supplier { get; set; }
        public string? ManufactureDate { get; set; }

        public string? Fat { get; set; }
        public string? FatCost { get; set; }

        public string? TOTFAT { get; set; }

        public string? SNF { get; set; }

        public string? SNFCost { get; set; }
        public string? TOTSNF { get; set; }
        public string? TOTQTY { get; set; }


        public string? CharcInternalID_TOTQTY { get; set; }
        public string? CharcInternalID_FAT { get; set; }

        public string? CharcInternalID_SNF { get; set; }

        public string? CharcInternalID_TOTFAT { get; set; }

        public string? CharcInternalID_TOTSNF { get; set; }
        public string? CharcInternalID_FATCOST { get; set; }
        public string? CharcInternalID_SNFCOST { get; set; }

        public string? CharcInternalID_SPGRYCOST { get; set; }
        public string? SPGRYCost { get; set; }
    }

    public class ReqSAPMilkBatchGoodsMovementCode
    {
        public string? GoodsMovementCode { get; set; }
    }

    public class OrgOutPut
    {
        public string? ConnectionName { get; set; }
    }

    public class ReqCrateGRNPosting
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? dealer_id { get; set; }
    }

    public class ReqSAPGRNCrateBatch
    {
        public string? PostingDate { get; set; }
        public string? GoodsMovementCode { get; set; }
        public string? MaterialDocumentHeaderText { get; set; }
        public string? ReferenceDocument { get; set; }
        public List<ReqSAPCrateBatchItem>? to_MaterialDocumentItem { get; set; }

    }

    public class ReqSAPCrateBatchItem
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
        public string? GdsMvtExtAmtInCoCodeCrcy { get; set; }
        public string? MaterialDocumentItemText { get; set; }
        public string? Supplier { get; set; }
        public string? ManufactureDate { get; set; }


        public string? Customer { get; set; }


    }
}
