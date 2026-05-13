namespace MilkIN_API.Areas.AdminConsole_API.Models
{
    public class ReqFarmerRegistration
    {
        // ReqFarmerRegistrationSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? farmer_id { get; set; }
        public string? request_date { get; set; }
        public string? approvalstatus_id { get; set; }


        // ReqFarmerRegistrationSave
        public string? approval_remarks { get; set; }
        public string? farmer_name { get; set; }
        public string? mcc_farmer_code { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? agent_id { get; set; }
        public string? mcc_id { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public string? alternatemobile_no { get; set; }
        public int cow_count { get; set; }
        public int buffalo_count { get; set; }
        public int calf_count { get; set; }
        public int milk_capacity { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }
        public string? nominee_name { get; set; }
        public string? nominee_relation { get; set; }
        public string? nomineemobile_no { get; set; }
        public string? nomineeaadhar_no { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? withholdingtaxtype_id { get; set; }

        public string? gov_farmer_id { get; set; }
        public string? gov_farmer_name { get; set; }
    }

    public class ResFarmerRegistration
    {
        public int is_approved { get; set; }
        public string? approval_remarks { get; set; }
        public string? farmer_id { get; set; }
        public string? mcc_farmer_code { get; set; }
        public string? farmer_name { get; set; }
        public string? request_date { get; set; }
        public string? approved_on { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? agent_id { get; set; }
        public string? mcc_id { get; set; }
        public string? village_name { get; set; }
        public string? agent_name { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public string? alternatemobile_no { get; set; }
        public int cow_count { get; set; }
        public int buffalo_count { get; set; }
        public int calf_count { get; set; }
        public int milk_capacity { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }
        public string? nominee_name { get; set; }
        public string? nominee_relation { get; set; }
        public string? nominee_mobile_no { get; set; }
        public string? nominee_aadhar_no { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? withholdingtaxtype_id { get; set; }


        public string? gov_farmer_id { get; set; }
        public string? gov_farmer_name { get; set; }


    }

    public class ReqFarmerService
    {
        // ReqFarmerServiceSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_id { get; set; }
        public string? request_date { get; set; }
        public string? approvalstatus_id { get; set; }


        // ReqFarmerServiceSave
        public string? service_id { get; set; }
        public string? approval_remarks { get; set; }
        public int is_approved { get; set; }
        public int approved_on { get; set; }
        public int approved_id { get; set; }
        public int approved_name { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? approved_amount { get; set; }
        public string? veterinaryservice_date { get; set; }
        public string? requestfor_id { get; set; }
        public string? request_for { get; set; }
        public string? order_type { get; set; }
        public string? servicetype_id { get; set; }
        public string? order_data { get; set; }


        public string? quantity { get; set; }
        public string? product_id { get; set; }
        public string? mcc_id { get; set; }

    }

    public class ResFarmerService
    {
        public string? request_id { get; set; }
        public int is_approved { get; set; }
        public string? approval_remarks { get; set; }
        public string? farmer_agent_id_request_for { get; set; }
        public string? farmer_agent_name_request_for { get; set; }
        public string? request_date { get; set; }
        public string? service_name { get; set; }
        public string? mobile_no_request_for { get; set; }
        public string? approved_on { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? servicetype_id { get; set; }
        public string? servicetype_name { get; set; }
        public string? request_amount { get; set; }
        public string? request_remark { get; set; }
        public string? approved_amount { get; set; }
        public string? veternaryservice_date { get; set; }
        public string? veterinaryservice_id { get; set; }
        public string? veterinaryservice_name { get; set; }
        public string? requestfor_id { get; set; }
        public string? request_for { get; set; }
        public string? order_type { get; set; }
        public string? material_id { get; set; }
        public string? material_name { get; set; }
        public string? quantity { get; set; }
        public string? rate { get; set; }
        public string? total_price { get; set; }
        public string? approved_quantity { get; set; }


    }

    public class ReqAgentService
    {
        // ReqAgentServiceSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? request_date { get; set; }
        public string? api_end_point { get; set; }


        // ReqAgentServiceSave
        public string? service_id { get; set; }
        public string? approval_remarks { get; set; }
        public string? request_for { get; set; }
        public string? request_for_user_id { get; set; }
        public string? request_by { get; set; }
        public string? request_by_user_id { get; set; }
        public int is_approved { get; set; }
        public int approved_on { get; set; }
        public int approved_id { get; set; }
        public int approved_name { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? approved_amount { get; set; }
        public string? veterinaryservice_date { get; set; }
        public string? requestfor_id { get; set; }
        public string? order_type { get; set; }
        public string? servicetype_id { get; set; }
        public string? order_data { get; set; }

        public string? quantity { get; set; }
        public string? product_id { get; set; }
        public string? mcc_id { get; set; }
        


    }

    public class ResAgentService
    {
        public string? request_id { get; set; }
        public int is_approved { get; set; }
        public string? approval_remarks { get; set; }
        public string? farmer_agent_id_request_for { get; set; }
        public string? farmer_agent_name_request_for { get; set; }
        public string? request_date { get; set; }
        public string? service_name { get; set; }
        public string? mobile_no_request_for { get; set; }
        public string? approved_on { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? servicetype_id { get; set; }
        public string? servicetype_name { get; set; }
        public string? request_amount { get; set; }
        public string? request_remark { get; set; }
        public string? approved_amount { get; set; }
        public string? veternaryservice_date { get; set; }
        public string? veterinaryservice_id { get; set; }
        public string? veterinaryservice_name { get; set; }
        public string? requestfor_id { get; set; }
        public string? request_for { get; set; }
        public string? order_type { get; set; }

        public string? material_id { get; set; }
        public string? material_name { get; set; }
        public string? quantity { get; set; }
        public string? rate { get; set; }
        public string? total_price { get; set; }
        public string? approved_quantity { get; set; }

    }

    public class ReqCollectionRequest
    {
        // ReqCollectionRequest
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? collectionrequest_id { get; set; }
        public string? request_date { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? api_end_point { get; set; }


        // ReqCollectionRequestSave
        public string? mcc_id { get; set; }
        public string? approved_id { get; set; }
        public string? approved_name { get; set; }
        public string? request_details { get; set; }
        public string? expected_time { get; set; }
        public string? requesttype_id { get; set; }
        public string? request_remarks { get; set; }
        public string? approved_on { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? agent_id { get; set; }
        public string? mcccollectionshift_id { get; set; }

    }

    public class ResCollectionRequest
    {
        public string? collectionrequest_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }
        public string? is_approved { get; set; }
        public string? approved_name { get; set; }
        public string? request_details { get; set; }
        public string? expected_time { get; set; }
        public string? requesttype_id { get; set; }
        public string? requesttype_name { get; set; }
        public string? request_remarks { get; set; }
        public string? approved_on { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? shiftend_time { get; set; }
        public string? request_date { get; set; }
        public string? createdby_id { get; set; }
        public string? created_on { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
    }

    public class ReqCorrectionL1
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? correction_request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approved_quantity_ltr { get; set; }
        public string? approved_fat { get; set; }
        public string? approved_snf { get; set; }
        public string? approval_id { get; set; }
        public string? date { get; set; }
        public string? approved_remarks { get; set; }
        public string? agent_id { get; set; }



    }
    public class ResCorrectionL1
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? correction_request_id { get; set; }
        public string? created_on { get; set; }
        public string? agent_id { get; set; }
        public string? agent_name { get; set; }
        public string? farmer_name { get; set; }

        public string? mobile_no { get; set; }
        public string? mcc_name { get; set; }
        public string? request_quantity_ltr { get; set; }
        public string? request_fat { get; set; }
        public string? request_snf { get; set; }
        public string? request_remark { get; set; }
        public string? current_quantity_ltr { get; set; }
        public string? current_snf { get; set; }
        public string? current_fat { get; set; }
        public string? approved_on_l1 { get; set; }
        public string? approved_remark_l1 { get; set; }

        public string? collectionshift_name { get; set; }
        public int is_approved_l1 { get; set; }

    }






    public class ReqCorrectionL2
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? correction_request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approved_quantity_ltr { get; set; }
        public string? approved_fat { get; set; }
        public string? approved_snf { get; set; }
        public string? approval_id { get; set; }
        public string? date { get; set; }
        public string? approved_remarks { get; set; }
        public string? agent_id { get; set; }
    }
    public class ResCorrectionL2
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? correction_request_id { get; set; }
        public string? created_on { get; set; }
        public string? agent_id { get; set; }
        public string? agent_name { get; set; }
        public string? mobile_no { get; set; }
        public string? mcc_name { get; set; }
        public string? request_quantity_ltr { get; set; }
        public string? request_fat { get; set; }
        public string? request_snf { get; set; }
        public string? request_remark { get; set; }
        public string? current_quantity_ltr { get; set; }
        public string? current_snf { get; set; }
        public string? current_fat { get; set; }
        public string? approved_on_l2 { get; set; }
        public string? approved_remark_l2 { get; set; }
        public int is_approved_l2 { get; set; }

        public string? farmer_name { get; set; }

        public string? collectionshift_name { get; set; }

        public string? is_locked { get; set; }

        public string? approved_quantity_ltr { get; set; }
        public string? approved_fat { get; set; }
        public string? approved_snf { get; set; }

        public string? approved_remark_l1 { get; set; }

    }






    public class ReqDataCorrection
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_date { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? api_end_point { get; set; }
        public string? request_for_user_id { get; set; }
        public string? request_for { get; set; }

        public string? approval_remarks { get; set; }

        public string? mobile_no { get; set; }

        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }

        public string? nominee_name { get; set; }
        public string? nominee_relation { get; set; }
        public string? nominee_mobile_no { get; set; }
        public string? nominee_aadhar_no { get; set; }

        public string? request_id { get; set; }
        public string? request_type { get; set; }
        public string? request_data { get; set; }


        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }


    }
    public class ResDataCorrection
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_date { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? api_end_point { get; set; }

        public string? approval_remarks { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? agent_id { get; set; }
        public string? mcc_id { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public string? alternatemobile_no { get; set; }

        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }

        public string? nominee_name { get; set; }
        public string? nominee_relation { get; set; }
        public string? nominee_mobile_no { get; set; }
        public string? nominee_aadhar_no { get; set; }

        public string? request_id { get; set; }
        public string? request_type { get; set; }

        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? request_for { get; set; }
        public string? request_for_user_id { get; set; }
        public string? request_for_user_name { get; set; }
        public string? request_by { get; set; }
        public string? request_by_user_id { get; set; }
        public string? request_data { get; set; }
        public int is_approved { get; set; }
        public string? approved_id { get; set; }
        public string? approved_name { get; set; }
        public string? village_name { get; set; }
        public string? approved_on { get; set; }
        public string? mcc_name { get; set; }

    }


    public class ReqFarmerOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? farmer_id { get; set; }
        public string? order_date { get; set; }
        public string? order_id { get; set; }
        public string? api_end_point { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? order_data { get; set; }
        public string? total_item { get; set; }
        public string? orderfor_id { get; set; }


    }

    public class ResFarmerOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? farmer_id { get; set; }
        public string? order_date { get; set; }
        public string? order_id { get; set; }
        public string? api_end_point { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }
        public string? approved_on { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? order_data { get; set; }
        public string? product_id { get; set; }
        public string? product_name { get; set; }
        public string? quantity { get; set; }
        public string? approved_quantity { get; set; }
        public string? total_item { get; set; }
        public string? orderfor_id { get; set; }
        public string? farmer_agent_name_order_for { get; set; }
        public string? mobile_no_order_for { get; set; }
        public string? is_approved { get; set; }
        public string? rate { get; set; }


    }


    public class ReqAgentOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? agent_id { get; set; }
        public string? order_date { get; set; }
        public string? api_end_point { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? order_data { get; set; }
        public string? total_item { get; set; }
        public string? order_id { get; set; }
        public string? orderfor_id { get; set; }

    }
    public class ResAgentOrder
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? agent_id { get; set; }
        public string? order_date { get; set; }
        public string? api_end_point { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? order_data { get; set; }
        public string? total_item { get; set; }
        public string? order_id { get; set; }
        public string? orderfor_id { get; set; }
        public string? farmer_agent_name_order_for { get; set; }
        public string? mobile_no_order_for { get; set; }
        public string? is_approved { get; set; }
        public string? rate { get; set; }
        public string? approved_on { get; set; }
        public string? product_id { get; set; }
        public string? product_name { get; set; }
        public string? quantity { get; set; }
        public string? approved_quantity { get; set; }

    }
    public class ReqFarmerIncentive
    {
        // ReqFarmerIncentiveSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? request_date { get; set; }
        public string? api_end_point { get; set; }

        // ReqFarmerIncentiveSave
        public string? approval_remarks { get; set; }
        public int is_approved { get; set; }
        public string? approved_on { get; set; }
        public string? approved_id { get; set; }
        public string? approved_name { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? requestfor_id { get; set; }
        public string? farmer_id { get; set; }


    }
    public class ResFarmerIncentive
    {
        // ReqFarmerIncentiveSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? request_date { get; set; }
        public string? api_end_point { get; set; }

        // ReqFarmerIncentiveSave
        public string? approval_remarks { get; set; }
        public int is_approved { get; set; }
        public string? approved_on { get; set; }
        public string? approved_id { get; set; }
        public string? approved_name { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? requestfor_id { get; set; }
        public string? incentivescheme_id { get; set; }
        public string? scheme_name { get; set; }
        public string? request_for { get; set; }
        public string? request_by { get; set; }
        public string? farmer_agent_id_request_for { get; set; }
        public string? farmer_agent_name_request_for { get; set; }
        public string? farmer_agent_id_request_by { get; set; }
        public string? farmer_agent_name_request_by { get; set; }

        public string? farmer_agent_mobile_request_for { get; set; }
        public string? farmer_agent_mobile_request_by { get; set; }


    }

    public class ReqAgentIncentive
    {
        // ReqFarmerServiceSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? request_date { get; set; }
        public string? api_end_point { get; set; }

        // ReqFarmerServiceSave
        public string? approval_remarks { get; set; }
        public int is_approved { get; set; }
        public string? approved_on { get; set; }
        public string? approved_id { get; set; }
        public string? approved_name { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? requestfor_id { get; set; }
        public string? request_for { get; set; }
        public string? agent_id { get; set; }

    }


    public class ResAgentIncentive
    {
        // ReqFarmerServiceSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? request_date { get; set; }
        public string? api_end_point { get; set; }

        // ReqFarmerServiceSave
        public string? approval_remarks { get; set; }
        public int is_approved { get; set; }
        public string? approved_on { get; set; }
        public string? approved_id { get; set; }
        public string? approved_name { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? requestfor_id { get; set; }
        public string? request_for { get; set; }
        public string? incentivescheme_id { get; set; }
        public string? scheme_name { get; set; }
        public string? request_by { get; set; }
        public string? farmer_agent_id_request_for { get; set; }
        public string? farmer_agent_name_request_for { get; set; }
        public string? farmer_agent_id_request_by { get; set; }
        public string? farmer_agent_name_request_by { get; set; }
        public string? farmer_agent_mobile_request_for { get; set; }
        public string? farmer_agent_mobile_request_by { get; set; }


    }



}
