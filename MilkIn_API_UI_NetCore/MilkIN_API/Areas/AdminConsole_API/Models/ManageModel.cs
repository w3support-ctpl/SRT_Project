using System.Security.Policy;

namespace MilkIN_API.Areas.AdminConsole_API.Models
{
    /*----  ----    ----    ----    Material Issue to MCC   ----    ----    ----    ----*/

    public class ReqMaterialIssueToMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public int totalcans { get; set; }
        public string? issuestocks_id { get; set; }
        public string? route_id { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public string? issuestocks_item { get; set; }
        public string? issuedate { get; set; }
        public int material_id { get; set; }
        public int material_name { get; set; }
        public int quantity { get; set; }
        public string? issuestock_type { get; set; }
        public string? mcc_id { get; set; }
        public string? issuestocks_date { get; set; }
        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? drivermobile_no { get; set; }
        public string? profile_id { get; set; }
        public string? xmldata { get; set; }
        public string? search_id { get; set; }

    }


    public class ResMaterialIssueToMCC
    {
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }

        public string? issuestocks_id { get; set; }
        public string? route_id { get; set; }
        public string? route_name { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public string? issueemptycan_item { get; set; }
        public string? mcc_name { get; set; }
        public int totalcans { get; set; }
        public string? issuedate { get; set; }
        public string? material_id { get; set; }
        public string? material_name { get; set; }
        public int quantity { get; set; }
        public string? issuestock_type { get; set; }
        public string? mcc_id { get; set; }
        public string? issuestocks_date { get; set; }
        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? drivermobile_no { get; set; }
        public string? profile_id { get; set; }
        public string? xmldata { get; set; }
        public string? org_id { get; set; }
        public string? mcc_code { get; set; }
        public string? is_driveraccepted { get; set; }
        public string? is_accepted { get; set; }
        public string? order_for_user_id { get; set; }
        public string? vehicle_number { get; set; }
        public string? order_id { get; set; }
        public string? order_type { get; set; }
        public int is_delivered { get; set; }
        public string? created_on { get; set; }
        public string? farmer_agent_name { get; set; }
        public string? product_id { get; set; }
        public string? product_name { get; set; }
        public string? order_for { get; set; }
    }

    /*----  ----    ----    ----    Material Return from MCC   ----    ----    ----    ----*/

    public class ReqMaterialReturnFromMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? search_period { get; set; }
        public string? search_mcc_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? dispatchstock_id { get; set; }
        public string? approval_remarks { get; set; }

    }

    public class ResMaterialReturnFromMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? dispatchstock_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }
        public string? agent_id { get; set; }
        public string? agent_name { get; set; }
        public string? mobile_no { get; set; }
        public string? is_dairy_accepted { get; set; }
        public string? dispatched_on { get; set; }
        public string? created_on { get; set; }
        public string? created_by { get; set; }
        public string? lastedited_on { get; set; }
        public string? lastedited_by { get; set; }
        public string? approval_remarks { get; set; }
        public string? approved_on { get; set; }
        public string? approved_id { get; set; }
        public string? approved_name { get; set; }
        public string? total_quantity { get; set; }

        // item response values
        public string? stock_type { get; set; }
        public string? dispatched_quantity { get; set; }
        public string? material_id { get; set; }
        public string? material_name { get; set; }
    }

    /*----  ----    ----    ----    Deductions   ----    ----    ----    ----*/
    public class ReqDeductions
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? deduction_data { get; set; }
        public string? ledger_status { get; set; }
        public string? search_period { get; set; }
        public string? deductions_id { get; set; }
        public int no_of_installments { get; set; }

        public string? usertype_id { get; set; }
        public string? username_id { get; set; }
        public string? requesttype_id { get; set; }
        public string? amount { get; set; }
        public string? date { get; set; }

        public string? is_locked { get; set; }

    }
    public class ResDeductions
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? deduction_data { get; set; }
        public string? ledger_status { get; set; }
        public string? search_period { get; set; }
        public string? deductions_id { get; set; }
        public string? deductionsitem_id { get; set; }
        public int no_of_installments { get; set; }

        public string? entry_date { get; set; }
        public string? request_user_type { get; set; }
        public string? request_user_name { get; set; }

        public string? mcc_name { get; set; }
        public string? request_user_id { get; set; }
        public string? request_user_mobile_no { get; set; }
        public string? request_type { get; set; }
        public string? total_amount { get; set; }
        public string? amount_deducted { get; set; }
        public string? balance { get; set; }
        public int is_closed { get; set; }

        public string? deduction_date { get; set; }
        public string? deduction_amount { get; set; }
        public int is_deducted { get; set; }

        public string? usertype_id { get; set; }
        public string? username_id { get; set; }
        public string? requesttype_id { get; set; }
        public string? amount { get; set; }
        public string? date { get; set; }
        public string? farmer_code { get; set; }
        public string? status { get; set; }

        public string? is_locked { get; set; }

    }

    /*----  ----    ----    ----    Incentives   ----    ----    ----    ----*/
    public class ReqIncentives
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? Incentive_data { get; set; }
        public string? ledger_status { get; set; }
        public string? search_period { get; set; }
        public string? Incentives_id { get; set; }
        public int no_of_installments { get; set; }

        public string? usertype_id { get; set; }
        public string? username_id { get; set; }
        public string? requesttype_id { get; set; }
        public string? amount { get; set; }
        public string? date { get; set; }
        public string? remarks { get; set; }

    }
    public class ResIncentives
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? Incentive_data { get; set; }
        public string? ledger_status { get; set; }
        public string? search_period { get; set; }
        public string? Incentives_id { get; set; }
        public string? Incentivesitem_id { get; set; }
        public int no_of_installments { get; set; }

        public string? entry_date { get; set; }
        public string? request_user_type { get; set; }
        public string? request_user_name { get; set; }
        public string? request_user_id { get; set; }
        public string? request_user_mobile_no { get; set; }
        public string? request_type { get; set; }
        public string? total_amount { get; set; }
        public string? amount_paid { get; set; }
        public string? balance { get; set; }
        public int is_closed { get; set; }

        public string? Incentive_date { get; set; }
        public string? Incentive_amount { get; set; }
        public int is_deducted { get; set; }

        public string? usertype_id { get; set; }
        public string? username_id { get; set; }
        public string? requesttype_id { get; set; }
        public string? amount { get; set; }
        public string? date { get; set; }
        public string? farmer_code { get; set; }
        public string? status { get; set; }
        public string? remarks { get; set; }

    }

    /*----  ----    ----    ----    Complaints   ----    ----    ----    ----*/
    public class ReqComplaints
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? complaint_id { get; set; }
        public string? complaint_period { get; set; }
        public string? complainttype_id { get; set; }
        public string? complaintstatus_id { get; set; }
        public string? remarks { get; set; }
        public int display_flag { get; set; }
        public string? newstatus_id { get; set; }
        public string? complaint_for_user_id { get; set; }
        public string? complaint_for { get; set; }
    }

    public class ResComplaints
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? complaint_id { get; set; }
        public string? complaint_period { get; set; }
        public string? complainttype_id { get; set; }
        public string? complainttype_name { get; set; }
        public string? complaintstatus_id { get; set; }
        public string? complaintstatus_name { get; set; }
        public string? remarks { get; set; }
        public int is_display { get; set; }
        public int is_closed { get; set; }
        public string? newstatus_id { get; set; }
        public string? currentstatus_id { get; set; }
        public string? new_status_id { get; set; }
        public string? current_status_id { get; set; }
        public string? new_status_name { get; set; }
        public string? current_status_name { get; set; }
        public string? complaint_remark { get; set; }
        public string? complaint_for { get; set; }
        public string? complaint_for_user_id { get; set; }
        public string? complaint_for_user_name { get; set; }
        public string? complaint_by { get; set; }
        public string? complaint_by_user_id { get; set; }
        public string? complaint_by_user_name { get; set; }
        public string? complaint_date { get; set; }
        public string? formatted_complaint_date { get; set; }
        public string? entry_id { get; set; }
        public string? action_date { get; set; }
        public string? action_by_id { get; set; }
        public string? action_by_name { get; set; }
        public string? closing_date { get; set; }
    }


    /*----  ----    ----    ----    Issue Empty Cans Request & Response Models   ----    ----    ----    ----*/

    public class ReqIssueEmptyCans
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int totalcans { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? issuestocks_id { get; set; }
        public string? route_id { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public string? issuestocks_item { get; set; }
        public string? issuedate { get; set; }
        public int material_id { get; set; }
        public int material_name { get; set; }
        public int quantity { get; set; }
        public string? issuestock_type { get; set; }
        public string? mcc_id { get; set; }
        public string? issuestocks_date { get; set; }
        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? drivermobile_no { get; set; }
        public string? profile_id { get; set; }
        public string? xmldata { get; set; }
        public string? search_id { get; set; }


    }
    public class ResIssueEmptyCans
    {
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }

        public string? issuestocks_id { get; set; }
        public string? route_id { get; set; }
        public string? route_name { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public string? issueemptycan_item { get; set; }
        public string? mcc_name { get; set; }
        public int totalcans { get; set; }
        public string? issuedate { get; set; }
        public string? material_id { get; set; }
        public string? material_name { get; set; }
        public int quantity { get; set; }
        public string? issuestock_type { get; set; }
        public string? mcc_id { get; set; }
        public string? issuestocks_date { get; set; }
        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? drivermobile_no { get; set; }
        public string? profile_id { get; set; }
        public string? xmldata { get; set; }
        public string? org_id { get; set; }
        public string? mcc_code { get; set; }
        public string? is_driveraccepted { get; set; }
        public string? is_accepted { get; set; }
        public string? plastic_cans_with_lid { get; set; }
        public string? plastic_cans_without_lid { get; set; }
        public string? aluminium_cans_with_lid { get; set; }
        public string? aluminium_cans_without_lid { get; set; }
        public string? vehicle_number { get; set; }

    }


    /*----  ----    ----    ----    Farmer Incentive Schemes Request & Response Models   ----    ----    ----    ----*/
    public class ReqFarmerIncentiveSchemes
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? scheme_period { get; set; }
        public string? incentivetype_id { get; set; }
        public string? incentivescheme_id { get; set; }
        public string? incentivestatus_id { get; set; }
        public string? incentivestatus_name { get; set; }


    }
    /*----  ----    ----    ----    Farmer Incentive Schemes Request Modle   ----    ----    ----    ----*/
    public class ResFarmerIncentiveSchemes
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? scheme_period { get; set; }
        public string? incentivetype_id { get; set; }
        public string? incentivescheme_id { get; set; }
        public string? scheme_name { get; set; }
        public string? incentivetype_name { get; set; }
        public string? schemetype_id { get; set; }
        public string? applicable_from { get; set; }
        public string? applicable_to { get; set; }
        public string? frequency { get; set; }
        public string? incentivestatus_id { get; set; }
        public string? incentivestatus_name { get; set; }
        public string? scheme_duration { get; set; }
        public int is_completed { get; set; }
        public string? incentivefrequency_name { get; set; }
        public string? from_date { get; set; }
        public string? to_date { get; set; }
        public string? formatted_from_date { get; set; }
        public string? formatted_to_date { get; set; }
        public string? scheme_status { get; set; }
        public string? farmer_id { get; set; }

        public string? farmer_code { get; set; }
        public string? farmer_name { get; set; }
        public string? eligibility { get; set; }


    }



    /*----  ----    ----    ----    Agent Incentive Schemes Request & Response Models   ----    ----    ----    ----*/
    public class ReqAgentIncentiveSchemes
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? scheme_period { get; set; }
        public string? incentivetype_id { get; set; }
        public string? incentivescheme_id { get; set; }
        public string? incentivestatus_id { get; set; }
        public string? incentivestatus_name { get; set; }


    }
    /*----  ----    ----    ----    Agent Incentive Schemes Request Modle   ----    ----    ----    ----*/
    public class ResAgentIncentiveSchemes
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? scheme_period { get; set; }
        public string? incentivetype_id { get; set; }
        public string? incentivescheme_id { get; set; }
        public string? scheme_name { get; set; }
        public string? incentivetype_name { get; set; }
        public string? schemetype_id { get; set; }
        public string? applicable_from { get; set; }
        public string? applicable_to { get; set; }
        public string? frequency { get; set; }
        public string? incentivestatus_id { get; set; }
        public string? incentivestatus_name { get; set; }
        public string? scheme_duration { get; set; }
        public int is_completed { get; set; }
        public string? incentivefrequency_name { get; set; }
        public string? from_date { get; set; }
        public string? to_date { get; set; }
        public string? formatted_from_date { get; set; }
        public string? formatted_to_date { get; set; }
        public string? scheme_status { get; set; }
        public string? agent_id { get; set; }

        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }
        public string? agent_name { get; set; }
        public string? eligibility { get; set; }


    }

}
