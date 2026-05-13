namespace MilkIN_UI.Models
{
    public class ReqInvoiceFarmer
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }


        public string? invoice_no { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }

        public string? entry_on { get; set; }
        public string? entry_type { get; set; }
        public string? particulars { get; set; }

        public string? is_voucher { get; set; }
        public string? check_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }

        public string? mccworktype_id { get; set; }

        public string? farmer_id { get; set; }


        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }

    }

    public class ReqInvoiceMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }

        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? mcc_code { get; set; }
        public string? mcc_id { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }


        public string? invoice_no { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }

        public string? entry_on { get; set; }
        public string? entry_type { get; set; }
        public string? particulars { get; set; }

        public string? is_voucher { get; set; }
        public string? check_id { get; set; }

        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }
    }

    public class ReqInvoiceTransporter
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }



        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? mcc_code { get; set; }
        public string? mcc_id { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }


        public string? invoice_no { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }

        public string? entry_on { get; set; }
        public string? entry_type { get; set; }
        public string? particulars { get; set; }

        public string? is_voucher { get; set; }
        public string? check_id { get; set; }

        public string? transporter_code { get; set; }
        public string? transporter_id { get; set; }

        public string? transporter_name { get; set; }
    }

    public class ReqInvoiceFarmerIncome
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }

        public string? search_period { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }

        public string? mcc_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? mcccollectionshift_id { get; set; }

        public string? entry_id { get; set; }

        public string farmer_id { get; set; }

        public string fat { get; set; }
        public string snf { get; set; }

        public string protein { get; set; }
        public string weight { get; set; }

        public string liters { get; set; }

        public string milktype_id { get; set; }

        public string milkstatus_id { get; set; }

        public string? collection_data { get; set; }
    }

    public class ReqInvoicedownloadPublish
    {
        public string? farmer_name { get; set; }
        public string? invoice_link { get; set; }
    }

    public class ReqInvoicePublish
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }


        public string? invoice_no { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }

        public string? entry_on { get; set; }
        public string? entry_type { get; set; }
        public string? particulars { get; set; }

        public string? is_voucher { get; set; }
        public string? check_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }
        public string? vouchertype_id { get; set; }
        public string? fileName { get; set; }
        public List<string> files { get; set; }

    }

    public class ReqMissingFarmer
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? farmer_id { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }



        public string? collection_date { get; set; }
        public string? liters { get; set; }
        public string? weight { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }

        public string? milktype_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }

        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? mcccollectionshift_id { get; set; }

        public string? entry_id { get; set; }


        public string protein { get; set; }

        public string? collection_data { get; set; }



        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }


    }



    public class ReqRebate
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? farmer_id { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }



        public string? collection_date { get; set; }
        public string? liters { get; set; }
        public string? weight { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }

        public string? milktype_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }

        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? mcccollectionshift_id { get; set; }

        public string? entry_id { get; set; }


        public string protein { get; set; }

        public string? collection_data { get; set; }



        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? mcc_code { get; set; }



    }


    public class ReqRateChange
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? farmer_id { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }

        public string? mccworktype_id { get; set; }

        public string? collection_date { get; set; }
        public string? liters { get; set; }
        public string? weight { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }

        public string? milktype_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }

        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? mcccollectionshift_id { get; set; }

        public string? entry_id { get; set; }


        public string protein { get; set; }

        public string? collection_data { get; set; }



        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? mcc_code { get; set; }


        public string? chart_id { get; set; }


    }


    public class SAPPosting
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
        public string? created_on { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? quantity { get; set; }
        public string? quality { get; set; }
        public string? rate { get; set; }
        public string? amount { get; set; }
        public string? farmercollection_id { get; set; }
        public string? farmer_code { get; set; }
        public string? search_period { get; set; }

        public string? invoicedata { get; set; }

        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }


        public string? invoice_no { get; set; }

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }

        public string? entry_on { get; set; }
        public string? entry_type { get; set; }
        public string? particulars { get; set; }

        public string? is_voucher { get; set; }
        public string? check_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }

        public string? farmer_id { get; set; }


        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }

        public string? incomefor { get; set; }
        public string? remark { get; set; }

        public string? milkpayment { get; set; }
    }

}