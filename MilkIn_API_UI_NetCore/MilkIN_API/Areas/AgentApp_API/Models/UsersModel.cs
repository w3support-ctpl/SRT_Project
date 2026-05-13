namespace MilkIN_API.Areas.AgentApp_API.Models
{
    public class ReqAgentSignIn
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? profile_id { get; set; }
        public string? mobile_no { get; set; }
        public string? password { get; set; }
        public string? destination_name { get; set; }

        public string? device_id { get; set; }

        public string? android_version { get; set; }

        public string? make_model { get; set; }

        public string? app_version { get; set; }

    }

    public class ResAgentDetails
    {
        public string? agent_id { get; set; }

        public string? app_version { get; set; }

        public string? agent_name { get; set; }
        public string? profile_photo { get; set; }
        public string? collection_centre_name { get; set; }
        public string? mcc_id { get; set; }
        public int? is_password_reset { get; set; }
        public int? is_app_active { get; set; }
        public int? is_multiple_centre { get; set; }
        public int? Is_ManualWeight { get; set; }
        public int? Is_ManualQuantity { get; set; }
        public int? Is_ExtraTime { get; set; }

    }


    public class ReqAgentVerify
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? profile_id { get; set; }
        public string? mobile_no { get; set; }
        public string? otp { get; set; }
        public string? password { get; set; }
        public string? destination_name { get; set; }
        public string? device_id { get; set; }

        public string? android_version { get; set; }

        public string? make_model { get; set; }

        public string? app_version { get; set; }



    }


    public class ReqSaveAgent
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? profile_id { get; set; }
        public string? xmldata { get; set; }
        public string? destination_name { get; set; }

    }


    public class ReqGetAgent
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? profile_id { get; set; }

        public string? mcc_id { get; set; }
        public string? destination_name { get; set; }
    }



    public class ResAgentInfo
    {
        public string? Agent_Id { get; set; }
        public string? Agent_Name { get; set; }
        public string? collection_centre_name { get; set; }
        public string? Pincode { get; set; }
        public string? Address_Text { get; set; }
        public string? Bank_Name { get; set; }
        public string? Account_Name { get; set; }
        public string? Account_No { get; set; }
        public string? IFSC_Code { get; set; }
        public string? Profile_Photo { get; set; }
        public string? Bank_Cheque_Photo { get; set; }

        public string? MCC_Name { get; set; }
        public string? Premises_State { get; set; }
        public string? Premises_District { get; set; }
        public string? Premises_Taluka { get; set; }
        public string? Premises_Village { get; set; }
        public string? Premises_Address_Text { get; set; }
        public AGProfileMaster? Statedata { get; set; }
        public AGProfileMaster? Districtdata { get; set; }
        public AGProfileMaster? Villagedata { get; set; }
        public AGProfileMaster? Talukadata { get; set; }

    }

    public class AGProfileMaster
    {
        public string? Item_Id { get; set; }
        public string? Item_Value { get; set; }
    }




}