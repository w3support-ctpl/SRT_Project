using System.Security.Policy;

namespace MilkIN_API.Areas.FarmerApp_API.Models
{
    public class ReqSignUp
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? profile_id { get; set; }
        public string? mobile_no { get; set; }
        public string? otp { get; set; }
        public string? password { get; set; }
        public string? destination_name { get; set; }

        public string? farmer_name { get; set; }

    }

    public class ReqSignIn
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

    public class ResFarmerInfo
    {
        public string? Is_Approved { get; set; }
        public string? Farmer_Id { get; set; }
        public string? Farmer_Name { get; set; }
        public string? Address_Text { get; set; }
        public FAProfileMaster? Statedata { get; set; }
        public FAProfileMaster? Districtdata { get; set; }

        public FAProfileMaster? Villagedata { get; set; }

        public FAProfileMaster? Talukadata { get; set; }

        public FAProfileMaster? Bankdata { get; set; }
        public FAProfileMaster? Branchdata { get; set; }
        public string? Pincode { get; set; }
        public string? Cow_Count { get; set; }
        public string? Buffalo_Count { get; set; }
        public string? Calf_Count { get; set; }
        public string? Milk_Capacity  { get; set; }
        public string? Bank_id { get; set; }

        public string? Branch_Id{ get; set; }
        public string? Email_Id { get; set; }
        public string? Pan_No { get; set; }
        public string? Aadhar_No { get; set; }

        public string? AlternateMobile_No { get; set; }
        public string? Account_Name { get; set; }
        public string? Account_No { get; set; }
        public string? IFSC_Code { get; set; }
        public string? Nominee_Name { get; set; }
        public string? Nominee_Relation { get; set; }
        public string? NomineeRelation_Name { get; set; }
        public string? Nominee_Mobile_No { get; set; }
        public string? Nominee_Aadhar_No { get; set; }
        public string? Birth_Date { get; set; }
        public string? Profile_Photo { get; set; }
        public string? Pan_Card_Photo { get; set; }
        public string? Aadhar_Card_Photo { get; set; }
        public string? Ration_Card_Photo { get; set; }
        public string? Bank_Cheque_Photo { get; set; }
    }

    public class ReqSaveFarmer
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? profile_id { get; set; }
        public string? xmldata { get; set; }
        public string? destination_name { get; set; }

        public string? Mobile_Number { get; set; }
         

    }

    public class ReqGetFarmer
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? profile_id { get; set; }
        public string? destination_name { get; set; }

    }
    public class ResFarmerDetails
    {
        public string? is_approved { get; set; }
        public string? farmer_id { get; set; }
        public string? farmer_name { get; set; }
        public string? collection_centre_name { get; set; }
        public string? profile_photo { get; set; }
        public int? is_password_reset { get; set; }

        public string? MusterType { get; set; }

        public string? app_version { get; set; }

    }


    public class FAProfileMaster
    {
        public string? Item_Id { get; set; }
        public string? Item_Value { get; set; }
    }


}
