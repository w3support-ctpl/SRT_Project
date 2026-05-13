namespace MilkIN_UI.Models
{

    /*----  ----    ----    ----    Farmer Registration   ----    ----    ----    ----*/
    public class ReqFarmerRegistration
    {
        // ReqFarmerRegistrationSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? farmer_id { get; set; }
        public string? request_date { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? api_end_point { get; set; }


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




    /*----  ----    ----    ----    Farmer Service Request   ----    ----    ----    ----*/
    public class ReqFarmerService
    {
        // ReqFarmerServiceSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? request_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? request_date { get; set; }
        public string? api_end_point { get; set; }

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




    /*----  ----    ----    ----    Agent Service Request   ----    ----    ----    ----*/
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




    /*----  ----    ----    ----    Milk Collection Request   ----    ----    ----    ----*/
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

        public string? quantity { get; set; }
        public string? product_id { get; set; }


    }




    /*----  ----    ----    ----    Correction L1   ----    ----    ----    ----*/
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




    /*----  ----    ----    ----    Correction L2   ----    ----    ----    ----*/
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





    /*----  ----    ----    ----    FarmerData Correction   ----    ----    ----    ----*/
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




    /*----  ----    ----    ----    Farmer Order   ----    ----    ----    ----*/
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




    /*----  ----    ----    ----    Agent Order   ----    ----    ----    ----*/
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




    /*----  ----    ----    ----    Farmer Incentive   ----    ----    ----    ----*/
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




    /*----  ----    ----    ----    Agent Incentive   ----    ----    ----    ----*/
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




}
