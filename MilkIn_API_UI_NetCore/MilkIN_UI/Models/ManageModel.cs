namespace MilkIN_UI.Models
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

    }

    /*----  ----    ----    ----    Material Return From MCC   ----    ----    ----    ----*/

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

    /*----  ----    ----    ----    Issue Empty Cans Request Modle   ----    ----    ----    ----*/
    public class ReqIssueEmptyCans
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

    /*----  ----    ----    ----    Farmer Incentive Schemes Request Modle   ----    ----    ----    ----*/
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

    /*----  ----    ----    ----    Agent Incentive Schemes Request Modle   ----    ----    ----    ----*/
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
}
