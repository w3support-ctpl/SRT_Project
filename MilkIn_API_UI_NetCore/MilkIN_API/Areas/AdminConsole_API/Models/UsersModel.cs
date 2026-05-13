namespace MilkIN_API.Areas.AdminConsole_API.Models
{
    public class ReqFarmer
    {
        // ReqFarmerSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? agent_id { get; set; }
        public string? mcc_id { get; set; }
        public string? farmer_id { get; set; }
        public string? farmer_name { get; set; }
        public string? search_text { get; set; }


        // ReqFarmerSave
        public string? farmer_code { get; set; }
        public string? mcc_farmer_code { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
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

    public class ResFarmer
    {
        public string? farmer_id { get; set; }
        public string? farmer_code { get; set; }
        public string? mcc_farmer_code { get; set; }
        public string? farmer_name { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? agent_id { get; set; }
        public string? mcc_name { get; set; }
        public string? mcc_id { get; set; }
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
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? district_name { get; set; }
        public string? taluka_name { get; set; }
        public string? village_name { get; set; }
        public string? pincode { get; set; }
        public string? bank_name { get; set; }
        public string? nomineerelation_name { get; set; }

        public string? withholdingtaxtype_id { get; set; }


        public string? gov_farmer_id { get; set; }
        public string? gov_farmer_name { get; set; }
    }

    public class ReqAgent
    {
        // ReqAgentSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? agent_id { get; set; }
        public string? agent_name { get; set; }
        public string? search_text { get; set; }


        //ReqAgentSave
        public string? agent_code { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? joining_date { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int onlineapp_flag { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? email_id { get; set; }
    }

    public class ResAgent
    {
        public string? agent_id { get; set; }
        public string? agent_code { get; set; }
        public string? agent_name { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? joining_date { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }
        public int online_app_flag { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? email_id { get; set; }
    }

    public class ReqDriver
    {
        // ReqDriverSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? drivertype_id { get; set; }
        public string? search_text { get; set; }

        // ReqDriverSave
        public string? driver_code { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? joining_date { get; set; }
        public string? license_no { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int onlineapp_flag { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
    }

    public class ResDriver
    {
        public string? driver_id { get; set; }
        public string? driver_code { get; set; }
        public string? driver_name { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? joining_date { get; set; }
        public string? drivertype_id { get; set; }
        public string? drivertype_name { get; set; }
        public string? drivinglicense_no { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }
        public int online_app_flag { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
    }

    public class ReqChemist
    {
        // ReqChemistSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? chemist_id { get; set; }
        public string? chemist_name { get; set; }
        public string? search_text { get; set; }

        // ReqChemistSave
        public string? chemist_code { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? joining_date { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public int onlineapp_flag { get; set; }
    }

    public class ResChemist
    {
        public string? chemist_code { get; set; }
        public string? chemist_id { get; set; }
        public string? chemist_name { get; set; }
        public string? birth_date { get; set; }
        public string? mobile_no { get; set; }
        public string? joining_date { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public int is_active { get; set; }
        public int onlineapp_flag { get; set; }
    }

    public class ReqUser
    {
        // ReqUserSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? officeuser_id { get; set; }
        public string? officeuser_name { get; set; }
        public string? role_id { get; set; }


        // ReqUserSave
        public string? joining_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? employee_id { get; set; }
    }

    public class ResUser
    {
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? mobile_no { get; set; }
        public string? role_id { get; set; }
        public string? role_name { get; set; }
        public string? joining_date { get; set; }
        public string? email_id { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public int is_active { get; set; }

        public string? employee_id { get; set; }
    }

    public class ReqChangePassword
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? current_password { get; set; }
        public string? new_password { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
    }
}
