namespace MilkIN_API.Areas.AdminConsole_API.Models
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

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }

        public string? farmer_id { get; set; }

        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }

        public string? mccworktype_id { get; set; }



    }

    public class ResInvoiceFarmer
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

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_posted { get; set; }
        public string? is_incomeposted { get; set; }
        public string? is_deductionposted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcctype_id { get; set; }

        public string? income_document { get; set; }

        public string? deduction_document { get; set; }

        public string? request_body { get; set; }

        public string? response_body { get; set; }

        public string? is_locked { get; set; }

        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }

        public string? milk_deposit { get; set; }
        public string? bank_loan { get; set; }
        public string? dairy_advance { get; set; }
        public string? mcc_advance { get; set; }
        public string? product_sales { get; set; }
        public string? trading_material { get; set; }
        public string? freight { get; set; }
        public string? anamat { get; set; }


        public string? mccworktype_id { get; set; }
        



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

        public string? mcc_code { get; set; }
        public string? mcc_id { get; set; }


        public string? mcctype_id { get; set; }
    }

    public class ResInvoiceMCC
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

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_posted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcc_code { get; set; }


        public string? mcctype_id { get; set; }

        public string? mppitype_id { get; set; }
        public string? mppitype_name { get; set; }


        public string? collection_date { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public string? milktype_id { get; set; }
        public string? agent_quantity_kg { get; set; }
        public string? agent_quantity_ltr { get; set; }
        public string? agent_fat { get; set; }
        public string? agent_snf { get; set; }
        public string? agent_fat_kg { get; set; }
        public string? agent_snf_kg { get; set; }
        public string? dairy_quantity_kg { get; set; }
        public string? dairy_quantity_ltr { get; set; }
        public string? dairy_fat { get; set; }
        public string? dairy_snf { get; set; }
        public string? dairy_fat_kg { get; set; }
        public string? dairy_snf_kg { get; set; }
        public string? fatkg_gainloss { get; set; }
        public string? snfkg_gainloss { get; set; }
        public string? fatkg_rate { get; set; }
        public string? snfkg_rate { get; set; }
        public string? total_gainloss { get; set; }
        public string? agentcost { get; set; }

        public string? is_incomeposted { get; set; }
        public string? is_deductionposted { get; set; }

        public string? income_document { get; set; }

        public string? request_body { get; set; }

        public string? response_body { get; set; }

        public string? is_locked { get; set; }

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

        public string? mcc_code { get; set; }
        public string? mcc_id { get; set; }

        public string? transporter_code { get; set; }
        public string? transporter_id { get; set; }

        public string? transporter_name { get; set; }

    }

    public class ResInvoiceTransporter
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

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_posted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcc_code { get; set; }

        public string? transporter_code { get; set; }
        public string? transporter_id { get; set; }

        public string? transporter_name { get; set; }


        public string? is_incomeposted { get; set; }
        public string? is_deductionposted { get; set; }

        public string? mcctype_id { get; set; }

        public string? income_document { get; set; }

        public string? deduction_document { get; set; }

        public string? request_body { get; set; }

        public string? response_body { get; set; }
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
    public class ResInvoiceFarmerIncome
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }

        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }
        public string? mcc_id { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? mcccollectionshift_id { get; set; }

        public string? agent_ltr { get; set; }
        public string? agent_fat { get; set; }
        public string? agent_snf { get; set; }


        public string? dairy_ltr { get; set; }
        public string? dairy_fat { get; set; }
        public string? dairy_snf { get; set; }


        public int is_locked { get; set; }


        public string weight { get; set; }

        public string liters { get; set; }

        public string fat { get; set; }
        public string snf { get; set; }

        public string fatkg { get; set; }
        public string snfkg { get; set; }

        public string location { get; set; }

        public string milktype_id { get; set; }

        public string milktype_name { get; set; }
        public string milkstatus_id { get; set; }
        public string milkstatus_name { get; set; }

        public string farmer_id { get; set; }
        public string farmer_name { get; set; }

        public string farmer_code { get; set; }

        public string mcc_farmer_code { get; set; }

        public string? entry_id { get; set; }


        public string protein { get; set; }

        public string? collection_data { get; set; }
        public string? setentry_id { get; set; }


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

        public string? search_period { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }
        public string? vouchertype_id { get; set; }
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
        public string? invoice_id { get; set; }
        


    }
    public class ResInvoicePublish
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }

        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }
        public string? mcc_id { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? mcccollectionshift_id { get; set; }

        public string? agent_ltr { get; set; }
        public string? agent_fat { get; set; }
        public string? agent_snf { get; set; }


        public string? dairy_ltr { get; set; }
        public string? dairy_fat { get; set; }
        public string? dairy_snf { get; set; }


        public int is_locked { get; set; }


        public string weight { get; set; }

        public string liters { get; set; }

        public string fat { get; set; }
        public string snf { get; set; }

        public string fatkg { get; set; }
        public string snfkg { get; set; }

        public string location { get; set; }

        public string milktype_id { get; set; }

        public string milktype_name { get; set; }
        public string milkstatus_id { get; set; }
        public string milkstatus_name { get; set; }

        public string farmer_id { get; set; }
        public string farmer_name { get; set; }

        public string farmer_code { get; set; }

        public string mcc_farmer_code { get; set; }

        public string? entry_id { get; set; }


        public string protein { get; set; }

        public string? collection_data { get; set; }
        public string? setentry_id { get; set; }

        public string? invoice_date { get; set; }
        public string? mcctype_id { get; set; }
        public string? mcctype_name { get; set; }
        public string? invoice_no { get; set; }
        public string? mustercycle { get; set; }
        public string? amount { get; set; }
        public string? generated_date { get; set; }
        public string? is_published { get; set; }

        public string? invoice_id { get; set; }
        public string? invoice_link { get; set; }

        public string? mccworktype_id { get; set; }
        public string? mccworktype_name { get; set; }


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



        public string? collection_date { get; set; }
        public string? liters { get; set; }
        public string? weight { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }

        public string? milktype_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
    }

    public class ResMissingFarmer
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

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_locked { get; set; }
        public string? is_posted { get; set; }
        public string? is_incomeposted { get; set; }
        public string? is_deductionposted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcctype_id { get; set; }

        public string? income_document { get; set; }

        public string? deduction_document { get; set; }

        public string? request_body { get; set; }

        public string? response_body { get; set; }



        public string? collection_date { get; set; }
        public string? liters { get; set; }
        public string? weight { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }

        public string? milktype_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }

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

        public string? mcc_code { get; set; }
        public string? mcc_id { get; set; }


        public string? mcctype_id { get; set; }

        public string? mccworktype_id { get; set; }
    }

    public class ResRebate
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

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_posted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcc_code { get; set; }


        public string? mcctype_id { get; set; }

        public string? mppitype_id { get; set; }
        public string? mppitype_name { get; set; }


        public string? collection_date { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public string? milktype_id { get; set; }
        public string? agent_quantity_kg { get; set; }
        public string? agent_quantity_ltr { get; set; }
        public string? agent_fat { get; set; }
        public string? agent_snf { get; set; }
        public string? agent_fat_kg { get; set; }
        public string? agent_snf_kg { get; set; }
        public string? dairy_quantity_kg { get; set; }
        public string? dairy_quantity_ltr { get; set; }
        public string? dairy_fat { get; set; }
        public string? dairy_snf { get; set; }
        public string? dairy_fat_kg { get; set; }
        public string? dairy_snf_kg { get; set; }
        public string? fatkg_gainloss { get; set; }
        public string? snfkg_gainloss { get; set; }
        public string? fatkg_rate { get; set; }
        public string? snfkg_rate { get; set; }
        public string? total_gainloss { get; set; }
        public string? agentcost { get; set; }

        public string? is_incomeposted { get; set; }
        public string? is_deductionposted { get; set; }

        public string? income_document { get; set; }

        public string? request_body { get; set; }

        public string? response_body { get; set; }

        public string? quantity_ltr { get; set; }
        

    }

    public class ReqInvoiceRateChange
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

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }

        public string? farmer_id { get; set; }

        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }


        public string? chart_id { get; set; }


    }

    public class ResInvoiceRateChange
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

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_posted { get; set; }
        public string? is_incomeposted { get; set; }
        public string? is_deductionposted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcctype_id { get; set; }

        public string? income_document { get; set; }

        public string? deduction_document { get; set; }

        public string? request_body { get; set; }

        public string? response_body { get; set; }

        public string? is_locked { get; set; }

        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }





        public string? mcc_code { get; set; }

        public string? old_rate { get; set; }

        public string? old_amount { get; set; }
        public string? new_rate { get; set; }
        public string? new_amount { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }

    }



    public class ReqInvoiceSAPPosting
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

        public string? sap_document_id { get; set; }
        public string? sap_document_year { get; set; }
        public string? invoice_id { get; set; }

        public string? approvalstatus_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }

        public string? farmer_id { get; set; }

        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }
        public string? incomefor { get; set; }

        public string? remark { get; set; }

        public string? milkpayment { get; set; }


    }

    public class ResInvoiceSAPPosting
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

        public string? mustertype_name { get; set; }

        public string? farmer_id { get; set; }
        public string? mcc_id { get; set; }

        public string? startdate { get; set; }
        public string? enddate { get; set; }


        public string? mustertype_id { get; set; }
        public string? mustercycle { get; set; }

        public string? is_posted { get; set; }
        public string? is_incomeposted { get; set; }
        public string? is_deductionposted { get; set; }
        public string? invoice_date { get; set; }


        public string? invoice_id { get; set; }
        public string? invoice_no { get; set; }


        public string? entry_on { get; set; }
        public string? entry_type { get; set; }

        public string? particulars { get; set; }

        public string? is_voucher { get; set; }


        public string? check_id { get; set; }

        public string? xmlData { get; set; }

        public string? mcctype_id { get; set; }

        public string? income_document { get; set; }

        public string? deduction_document { get; set; }

        public string? request_body { get; set; }

        public string? response_body { get; set; }

        public string? is_locked { get; set; }

        public string? entry_id { get; set; }
        public string? deductions_id { get; set; }

        public string? remark { get; set; }

        public string? milkpayment { get; set; }


    }




}
