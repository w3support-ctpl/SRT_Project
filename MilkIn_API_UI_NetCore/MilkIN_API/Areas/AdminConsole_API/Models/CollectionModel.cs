namespace MilkIN_API.Areas.AdminConsole_API.Models
{


    /*----  ----    ----    ----    MilkCollection Request & Response Models   ----    ----    ----    ----*/
    public class ReqMilkCollection
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? vehicle_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }
        public int is_collected { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? vehicletype { get; set; }
        public string? milkdata { get; set; }
        public int is_confirm { get; set; }
        public int is_release { get; set; }
        public string? vehicletype_id { get; set; }
        public string? reasons { get; set; }




        public string? mcc_name { get; set; }
        public string? milktype_id { get; set; }

        public string? milktype_name { get; set; }

        public string? milkstatus_id { get; set; }

        public string? milkstatus_name { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }


        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? search_period { get; set; }

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
    public class ResMilkCollection
    {
        public string? is_km { get; set; }
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? vehicle_no { get; set; }
        public string? route_name { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? mcccollectionshift_name { get; set; }

        public string? collectionshift_name { get; set; }
        public string? collectionshift_id { get; set; }

        public string? end_time { get; set; }
        public string? weight { get; set; }
        public int totalcans { get; set; }
        public string? vehicle_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }
        public string? tripdocument_id { get; set; }
        public int is_collected { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milktype_id { get; set; }
        public string? milkstatus_name { get; set; }
        public string? milktype_name { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? created_on { get; set; }
        public string? quantity_ltr { get; set; }
        public int cans { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public int is_confirm { get; set; }
        public int is_release { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }
        public string? cellno { get; set; }
        public string? liter { get; set; }

        public string? batch_id { get; set; }

        public string? liters { get; set; }

        public string? start_time { get; set; }

        public string? sample_no { get; set; }
        public string? reasons { get; set; }
        public string? search_period { get; set; }




        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? rate { get; set; }
        public string? mppitype_id { get; set; }

        public string? mppitype_name { get; set; }


    }

    /*----  ----    ----    ----    MilkCollection Quantity Request & Response Models   ----    ----    ----    ----*/

    public class ReqMilkCollectionQuantity
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? entry_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? milktype_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? weight { get; set; }
        public string? gross_weight { get; set; }
        public string? tare_weight { get; set; }
        public string? cans { get; set; }
        public string? cellno { get; set; }
        public string? stored_procedure { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? vehicle_id { get; set; }

        public string? batch_id { get; set; }

        public string? supervisordata { get; set; }

        public string? reasons { get; set; }

        public string? search_period { get; set; }



    }

    public class ResMilkCollectionQuantity
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? liters { get; set; }
        public string? entry_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }
        public string? weight { get; set; }
        public string? cans { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? start_time { get; set; }
        public string? milktype_id { get; set; }
        public string? milktype_name { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? cellno { get; set; }
        public string? vehicle_id { get; set; }
        public string? batch_id { get; set; }
        public string? loss { get; set; }

        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }

        public string? gross_weight { get; set; }
        public string? tare_weight { get; set; }

        public string? reasons { get; set; }

        public string? search_period { get; set; }

    }



    /*----  ----    ----    ----    MilkCollection Quality Request & Response Models   ----    ----    ----    ----*/

    public class ReqMilkCollectionQuality
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? entry_id { get; set; }
        public string? milkstatus_id { get; set; }

        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? sample_no { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? cellno { get; set; }
        public string? stored_procedure { get; set; }
        public string? vehicle_id { get; set; }
        public string? batch_id { get; set; }

        public string? cans { get; set; }

        public string? reasons { get; set; }

        public string? search_period { get; set; }



    }

    public class ResMilkCollectionQuality
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? entry_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? sample_no { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? cellno { get; set; }
        public string? vehicle_id { get; set; }
        public string? batch_id { get; set; }

        public string? reasons { get; set; }
        public string? search_period { get; set; }


    }

    /*----  ----    ----    ----    Milk Collection Route Chemist Request & Response Model   ----    ----    ----    ----*/
    /*
    public class ReqMilkCollectionSupervisor
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? milkstatus_name { get; set; }
        public string? weight {  get; set; }
        public string? liter { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? cellno { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicle_id { get; set; }


    }


    public class ResMilkCollectionSupervisor
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? milkstatus_name { get; set; }
        public string? weight { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? cellno { get; set; }
        public string? liter { get; set; }

        public string? tripdocument_id { get; set; }


    }
    */

    /*----  ----    ----    ----    Milk Collection Analyst Request & Response Model   ----    ----    ----    ----*/


    /*
    public class ReqMilkCollectionAnalyst
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicle_id { get; set; }



    }

    public class ResMilkCollectionAnalyst
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? mcc_name { get; set; }
        public string? weight_loss { get; set; }
        public string? ts_loss { get; set; }
        public string? tripdocument_id { get; set; }

    }

    */

    /*----  ----    ----    ----    Trip Document Request & Response Models   ----    ----    ----    ----*/
    public class ReqTripDocument
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? tripdocumentstatus_id { get; set; }
        public string? date { get; set; }
        public string? trip_no { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? route_name { get; set; }
        public string? collectionshift_name { get; set; }
        public string? driver_name { get; set; }
        public string? disatance { get; set; }
        public string? disatance_driver { get; set; }
        public string? disatance_fleetx { get; set; }
        public string? finaldistance { get; set; }
        public string? rate { get; set; }
        public string? tripamount { get; set; }
        public string? freightratetype_id { get; set; }


        public string? dieselbaserate { get; set; }
        public string? currentdieselrate { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }
        public string? fleetx_id { get; set; }

        public string? in_km { get; set; }
        public string? out_km { get; set; }
    }
    public class ResTripDocument
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? tripdocumentstatus_id { get; set; }
        public string? duration { get; set; }
        public string? trip_no { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? route_name { get; set; }
        public string? driver_name { get; set; }
        public string? collectionshift_name { get; set; }
        public string? date { get; set; }
        public string? distanceasperapp { get; set; }
        public string? distanceasperfleetx { get; set; }
        public string? finaldistance { get; set; }
        public string? rate { get; set; }
        public string? tripamount { get; set; }
        public string? freightratetype_id { get; set; }

        public string? sap_document_no { get; set; }

        public int is_postedinsap { get; set; }
        public int is_tripdocument_locked { get; set; }
        public string? baserate { get; set; }


        public string? dieselbaserate { get; set; }
        public string? freightratetype_name { get; set; }
        public string? currentdieselrate { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }
        public string? fleetx_id { get; set; }

        public string? disatance_driver { get; set; }
        public string? disatance_fleetx { get; set; }
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

    public class ReqSAPMilkBatchGoodsMovementCode
    {
        public string? GoodsMovementCode { get; set; }
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
    }

    public class ReqSAPMilkBatchHeader
    {
        public string? Material { get; set; }
        public string? BatchIdentifyingPlant { get; set; }
        public string? Batch { get; set; }
        public string? CharcInternalID { get; set; }
        public string? CharcValueDependency { get; set; }
        public string? CharcFromNumericValue { get; set; }


    }

    public class ReqSAPMilkSOAP
    {

        //public string? Amount { get; set; }
        //public string? Farmer_Code { get; set; }
        //public string? Invoice_Id { get; set; }

        public string? xmlData { get; set; }

    }


    public class ReqSAPMilkSOAPIncome
    {
        public string FiscalYear { get; set; }
        public string CompanyCode { get; set; }
        public string DocumentDate { get; set; }
        public string PostingDate { get; set; }
        public string CreationDate { get; set; }
        public string SupplierInvoiceIDByInvcgParty { get; set; }
        public string InvoicingParty { get; set; }
        public string DocumentCurrency { get; set; }
        public string InvoiceGrossAmount { get; set; }
        public string PaymentTerms { get; set; }
        public string AccountingDocumentType { get; set; }
        public string SupplierInvoiceStatus { get; set; }
        public bool TaxIsCalculatedAutomatically { get; set; }
        public string BusinessPlace { get; set; }
        public string BusinessSectionCode { get; set; }
        public bool SuplrInvcIsCapitalGoodsRelated { get; set; }
        public string TaxDeterminationDate { get; set; }
        public string TaxReportingDate { get; set; }
        public string TaxFulfillmentDate { get; set; }
        public string InvoiceReceiptDate { get; set; }
        public bool IsEUTriangularDeal { get; set; }
        public string RetentionDueDate { get; set; }
        public bool IsReversal { get; set; }
        public bool IsReversed { get; set; }

        public string SupplierPostingLineItemText { get; set; }

        public List<To_Supplierinvoiceitemglacct> to_SupplierInvoiceItemGLAcct { get; set; }
        public List<To_Supplierinvoicewhldgtax> to_SupplierInvoiceWhldgTax { get; set; }
        public string SupplierInvoiceIsCreditMemo { get; set; }
    }

    public class To_Supplierinvoiceitemglacct
    {
        public string FiscalYear { get; set; }
        public string SupplierInvoiceItem { get; set; }
        public string CompanyCode { get; set; }
        public string CostCenter { get; set; }
        public string ProfitCenter { get; set; }
        public string GLAccount { get; set; }
        public string DocumentCurrency { get; set; }
        public string SupplierInvoiceItemAmount { get; set; }
        public string TaxCode { get; set; }
        public string DebitCreditCode { get; set; }
        public bool IsNotCashDiscountLiable { get; set; }
        public string TaxBaseAmountInTransCrcy { get; set; }

        public string SupplierInvoiceItemText { get; set; }
    }

    public class To_Supplierinvoicewhldgtax
    {
        public string WithholdingTaxType { get; set; }
        public string DocumentCurrency { get; set; }
        public string WithholdingTaxCode { get; set; }
        public string WithholdingTaxBaseAmount { get; set; }
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
        public string? mcc_id { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }
        public string? protein { get; set; }
        public string? ash { get; set; }
        public string? sodium { get; set; }
    }

    public class ResGoodsInwardPosting
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? posting_date { get; set; }
        public string? milktype_name { get; set; }
        public string? quality { get; set; }
        public string? quantity { get; set; }
        public string? milkcost { get; set; }
        public string? agentcost { get; set; }
        public string? transportcost { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? snfcost { get; set; }
        public string? fatcost { get; set; }
        public string? status { get; set; }
        public int is_posted { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? entry_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? milkprice { get; set; }
        public string? snfkg { get; set; }
        public string? fatkg { get; set; }
        public string? feq { get; set; }

        public string? fatrate { get; set; }
        public string? snfrate { get; set; }
        public string? fatvalue { get; set; }
        public string? snfvalue { get; set; }

        public string? totallandedcost { get; set; }

        public string? mcc_id { get; set; } // search
        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }

        public string? milktype_id { get; set; }

        public string? farmer_id { get; set; }
        public string? farmer_name { get; set; }
        public string? farmer_code { get; set; }

        public string? rate { get; set; }
        public string? amount { get; set; }

        public string? sap_document_id { get; set; }
        public string? year { get; set; }

        public string? total_gainloss { get; set; }

        public string? protein { get; set; }
        public string? ash { get; set; }

        public string? sodium { get; set; }

    }

    public class ReqCollectionApproval
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
        public string? vehicletype_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }

        public string? mcc_id { get; set; }

        public string? mcc_name { get; set; }
        public string? milktype_id { get; set; }

        public string? milktype_name { get; set; }

        public string? milkstatus_id { get; set; }

        public string? milkstatus_name { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }


        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? mcc_commission { get; set; }

        public string? cellno { get; set; }

        public string? checkavailableflag { get; set; }

        public string? sour_compartment_grn_flag { get; set; }
        public string? sour_compartment_adjustment_mcc_id { get; set; }
        public string? sour_compartment_adjustment_entry_id { get; set; }
        public string? sour_compartment_adjustment_done_flag { get; set; }

        public string? sour_compartment_adjustment_flag { get; set; }



    }

    public class ResCollectionApproval
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? posting_date { get; set; }
        public string? milktype_name { get; set; }
        public string? quality { get; set; }
        public string? quantity { get; set; }
        public string? milkcost { get; set; }
        public string? agentcost { get; set; }
        public string? transportcost { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? snfcost { get; set; }
        public string? fatcost { get; set; }
        public string? status { get; set; }
        public int is_locked { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? entry_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }
        public string? vehicle_no { get; set; }
        public string? route_name { get; set; }
        public string? collectionshift_name { get; set; }
        public string? end_time { get; set; }
        public string? weight { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }

        public string? mcc_id { get; set; }

        public string? mcc_name { get; set; }
        public string? milktype_id { get; set; }

        public string? milkstatus_id { get; set; }

        public string? milkstatus_name { get; set; }

        public string? liters { get; set; }



        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? cellno { get; set; }

        public string? checkavailableflag { get; set; }




        public string? total_gainloss { get; set; }

    }

    public class ReqGainLossEntry
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
        public string? vehicletype_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }

        public string? mcc_id { get; set; }

        public string? mcc_name { get; set; }
        public string? milktype_id { get; set; }

        public string? milktype_name { get; set; }

        public string? milkstatus_id { get; set; }

        public string? milkstatus_name { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }


        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? mcc_commission { get; set; }

        public string? cellno { get; set; }


        public string? agent_ltr { get; set; }
        public string? agent_fat { get; set; }
        public string? agent_snf { get; set; }

        public string? chemist_ltr { get; set; }
        public string? chemist_fat { get; set; }
        public string? chemist_snf { get; set; }

        public string? composite_ltr { get; set; }
        public string? composite_fat { get; set; }
        public string? composite_snf { get; set; }

        public string? composite_protein { get; set; }
        public string? composite_ash { get; set; }
        public string? composite_sodium { get; set; }


        public string? final_ltr { get; set; }
        public string? final_fat { get; set; }
        public string? final_snf { get; set; }

        public string? chemistcollection_id { get; set; }


        public string? lab_fat { get; set; }
        public string? lab_snf { get; set; }

        public string? sour_compartment_grn_flag { get; set; }
        public string? sour_compartment_adjustment_mcc_id { get; set; }
        public string? sour_compartment_adjustment_entry_id { get; set; }
        public string? sour_compartment_adjustment_done_flag { get; set; }

        public string? sour_compartment_adjustment_flag { get; set; }




    }

    public class ResGainLossEntry
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? posting_date { get; set; }
        public string? milktype_name { get; set; }
        public string? quality { get; set; }
        public string? quantity { get; set; }
        public string? milkcost { get; set; }
        public string? agentcost { get; set; }
        public string? transportcost { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? snfcost { get; set; }
        public string? fatcost { get; set; }
        public string? status { get; set; }
        public int is_locked { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? entry_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }
        public string? vehicle_no { get; set; }
        public string? route_name { get; set; }
        public string? collectionshift_name { get; set; }
        public string? end_time { get; set; }
        public string? weight { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }

        public string? mcc_id { get; set; }

        public string? mcc_name { get; set; }
        public string? milktype_id { get; set; }


        public string? milkstatus_id { get; set; }

        public string? milkstatus_name { get; set; }

        public string? liters { get; set; }



        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? cellno { get; set; }

        public string? agent_ltr { get; set; }
        public string? agent_fat { get; set; }
        public string? agent_snf { get; set; }

        public string? chemist_ltr { get; set; }
        public string? chemist_fat { get; set; }
        public string? chemist_snf { get; set; }

        public string? composite_ltr { get; set; }
        public string? composite_fat { get; set; }
        public string? composite_snf { get; set; }

        public string? composite_protein { get; set; }
        public string? composite_ash { get; set; }
        public string? composite_sodium { get; set; }

        public string? chemistcollection_id { get; set; }

        public string? final_ltr { get; set; }
        public string? final_fat { get; set; }
        public string? final_snf { get; set; }

        public string? lab_fat { get; set; }
        public string? lab_snf { get; set; }


        public string? message { get; set; }
        public string? mobileno { get; set; }

        public string? sour_compartment_grn_flag { get; set; }
        public string? sour_compartment_adjustment_mcc_id { get; set; }
        public string? sour_compartment_adjustment_entry_id { get; set; }
        public string? sour_compartment_adjustment_done_flag { get; set; }

        public string? sour_compartment_adjustment_flag { get; set; }



    }

    public class ReqQualityEntry
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? search_period { get; set; }

        public string? method_name { get; set; }


        public string? entry_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }

        public string? protein { get; set; }


        public string? ash { get; set; }
        public string? sodium { get; set; }

        public string? adulteration { get; set; }

        public string? milkstatus_id { get; set; }

        public string? collectionshift_id { get; set; }

        public string? collectionshift_name { get; set; }

    }

    public class ResQualityEntry
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? search_period { get; set; }

        public string? method_name { get; set; }


        public string? entry_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }

        public string? protein { get; set; }


        public string? ash { get; set; }
        public string? sodium { get; set; }
        public string? adulteration { get; set; }

        public string? sample_no { get; set; }

        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }

        public string? is_locked { get; set; }
        public string? milkstatus_id { get; set; }
        public string? is_mcc { get; set; }

        public string? collectionshift_id { get; set; }

        public string? collectionshift_name { get; set; }


    }


    public class ReqMachineData
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? method_name { get; set; }

        public string? machine_data { get; set; }

    }

    public class ResMachineData
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? method_name { get; set; }

        public string? machine_data { get; set; }

    }

    public class ReqSendSMS
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }
    }
    public class ResSendSMS
    {
        public string? message { get; set; }
        public string? mobileno { get; set; }

        public string? vehicletype_id { get; set; }

    }

}
