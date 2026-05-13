namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    public class UsersModel
    {
        public class ReqFarmerSearch
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? agent_id { get; set; }
            public string? farmer_id { get; set; }
            public string? farmer_name { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
        }

        public class ResFarmer
        {
            public string? org_id { get; set; }
            public string? farmer_id { get; set; }
            public string? farmer_name { get; set; }

        }

        public class ReqFarmerSave
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? farmer_id { get; set; }
            public string? farmer_code { get; set; }
            public string? farmer_name { get; set; }
            public string? mobile_no { get; set; }
            public string? agent_id { get; set; }
            public string? pan_no { get; set; }
            public string? aadhar_no { get; set; }
            public string? cow_count { get; set; }
            public string? buffalo_count { get; set; }
            public string? calf_count { get; set; }
            public string? milk_capacity { get; set; }
            public string? state_id { get; set; }
            public string? district_id { get; set; }
            public string? taluka_id { get; set; }
            public string? village_id { get; set; }
            public string? address { get; set; }
            public string? bank_name { get; set; }
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
        }

        public class ReqAgentSearch
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? agent_id { get; set; }
            public string? agent_name { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
        }

        public class ResAgent
        {
            public string? org_id { get; set; }
            public string? agent_id { get; set; }
            public string? agent_name { get; set; }

        }

        public class ReqAgentSave
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? agent_id { get; set; }
            public string? agent_code { get; set; }
            public string? agent_name { get; set; }
            public string? mobile_no { get; set; }
            public string? joining_date { get; set; }
            public string? pan_no { get; set; }
            public string? aadhar_no { get; set; }
            public string? state_id { get; set; }
            public string? district_id { get; set; }
            public string? taluka_id { get; set; }
            public string? village_id { get; set; }
            public string? address { get; set; }
            public int is_active { get; set; }
            public int is_deleted { get; set; }
            public int onlineapp_flag { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
            public string? user_name { get; set; }
        }

        public class ReqDriverSearch
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? driver_id { get; set; }
            public string? driver_name { get; set; }
            public string? drivertype_id { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
        }

        public class ResDriver
        {
            public string? org_id { get; set; }
            public string? driver_id { get; set; }
            public string? driver_name { get; set; }

        }

        public class ReqDriverSave
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? driver_id { get; set; }
            public string? driver_code { get; set; }
            public string? driver_name { get; set; }
            public string? mobile_no { get; set; }
            public string? joining_date { get; set; }
            public string? drivertype_id { get; set; }
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

        public class ReqChemistSearch
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? chemist_id { get; set; }
            public string? chemist_name { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
        }

        public class ResChemist
        {
            public string? org_id { get; set; }
            public string? chemist_id { get; set; }
            public string? chemist_name { get; set; }

        }

        public class ReqChemistSave
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? chemist_id { get; set; }
            public string? chemist_code { get; set; }
            public string? chemist_name { get; set; }
            public string? mobile_no { get; set; }
            public string? joining_date { get; set; }
            public string? pan_no { get; set; }
            public string? aadhar_no { get; set; }
            public int is_active { get; set; }
            public int is_deleted { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
            public string? user_name { get; set; }
        }

        public class ReqUserSearch
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? officeuser_id { get; set; }
            public string? officeuser_name { get; set; }
            public string? role_id { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
        }

        public class ResUser
        {
            public string? Org_Id { get; set; }
            public string? User_Id { get; set; }
            public string? User_Name { get; set; }

        }

        public class ReqUserSave
        {
            public string? method_name { get; set; }
            public string? org_id { get; set; }
            public string? officeuser_id { get; set; }
            public string? officeuser_name { get; set; }
            public string? user_role { get; set; }
            public string? mobile_no { get; set; }
            public string? joining_date { get; set; }
            public string? email_id { get; set; }
            public string? pan_no { get; set; }
            public string? aadhar_no { get; set; }
            public int is_active { get; set; }
            public int is_deleted { get; set; }
            public string? user_id { get; set; }
            public string? destination_name { get; set; }
            public string? user_name { get; set; }
        }
    }
}
