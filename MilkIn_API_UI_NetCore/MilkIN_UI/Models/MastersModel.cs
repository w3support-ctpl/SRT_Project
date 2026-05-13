namespace MilkIN_UI.Models
{
    /*----  ----    ----    ----    MCC - Request Model   ----    ----    ----    ----*/
    public class ReqMCC
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }


        // ENTRY DETAILS
        public string? mcc_id { get; set; } // search
        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }
        public string? search_text { get; set; } // search
        public string? mcccategory_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? agent_id { get; set; }
        public string? mobile_no { get; set; }

        // ADDRESS DETAILS
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }

        // BANK DETAILS
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }

        // OTHER DETAILS
        public string? mustertype_id { get; set; }
        public string? mccworktype_id { get; set; }
        public string? paymentcycle_id { get; set; }
        public string? milktype_id { get; set; }
        public string? collectionshift_id { get; set; }

        public string? latitude { get; set; }
        public string? longitude { get; set; }
        public string? fssailicense_no { get; set; }
        public string? fssailicensevalidity_on { get; set; }
        public string? paymenttype_id { get; set; }

        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public int is_manualweight { get; set; }
        public int is_manualquality { get; set; }
        public int is_manualshiftend { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }



        public string? anamat { get; set; }
        public string? freight { get; set; }
        public string? anamat_tds { get; set; }
        public string? freight_tds { get; set; }
        public string? rebate { get; set; }

        public string? withholdingtaxtype_id { get; set; }

        public string? plant_code { get; set; }
        public string? alternate { get; set; }

    }






    /*----  ----    ----    ----    Payment Settings - Request Model   ----    ----    ----    ----*/
    public class ReqPaymentSettings
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }

        public string? version_no { get; set; }
        public string? mustertype_id { get; set; }
        public string? mustertype_name { get; set; }
        public string? paymentcycle_id { get; set; }
        public string? paymentcycle_name { get; set; }
        public string? milktype_id { get; set; }
        public string? collectionshift_id { get; set; }
        public string? applicable_date { get; set; }
        public string? to_date { get; set; }
        public string? mcc_id { get; set; }
        public string? paymentSettings_id { get; set; }
        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? anamat { get; set; }
        public string? freight { get; set; }
        public string? anamat_tds { get; set; }
        public string? freight_tds { get; set; }

        public string? rebate { get; set; }
    }






    /*----  ----    ----    ----    Transporter - Request Model   ----    ----    ----    ----*/
    public class ReqTransporter
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }


        // ENTRY DETAILS
        public string? transporter_id { get; set; } // search
        public string? transporter_name { get; set; }   // search
        public string? transporter_code { get; set; }
        public string? contactperson_name { get; set; }
        public string? mobile_no { get; set; }


        // ADDRESS DETAILS
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }

        // BANK DETAILS
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }

        // OTHER DETAILS
        public string? company_pan_no { get; set; }
        public string? fssai_license_no { get; set; }
        public string? licensevalidity_on { get; set; }


        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? withholdingtaxtype_id { get; set; }
    }






    /*----  ----    ----    ----    Vehicle - Request Model   ----    ----    ----    ----*/
    public class ReqVehicle
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }



        // ENTRY DETAILS
        public string? vehicle_id { get; set; } // search variable
        public string? vehicle_no { get; set; } // search variable
        public string? vehiclemake_id { get; set; }
        public string? vehicletype_id { get; set; }
        public string? chassis_no { get; set; }
        public string? ownername { get; set; }
        public string? vehicleownershiptype_id { get; set; } // search variable
        public string? transporter_id { get; set; }
        public string? capacityinkg { get; set; }
        public string? noofcellsintanker { get; set; }
        public string? laborcharge { get; set; }
        public string? vehicleaverage { get; set; }
        public string? celldata { get; set; }



        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? fssailicense_no { get; set; }
        public string? fssailicensevalidity_on { get; set; }

    }






    /*----  ----    ----    ----    Incentive Scheme - Request Model   ----    ----    ----    ----*/
    public class ReqIncentiveScheme
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }



        // ENTRY DETAILS
        public string? incentivescheme_id { get; set; } // search
        public string? incentivetype_id { get; set; }   // search
        public string? duration { get; set; }   // search
        public string? scheme_name { get; set; }
        public string? from_date { get; set; }
        public string? to_date { get; set; }
        public string? incentivefrequency_id { get; set; }
        public string? criteria { get; set; }
        public string? scheme_description { get; set; }
        public string? is_for_farmer { get; set; }
        public string? is_for_agent { get; set; }

        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? entry_id { get; set; }
        public string? mcc_id { get; set; }


    }






    /*----  ----    ----    ----    Services - Request Model   ----    ----    ----    ----*/
    public class ReqServices
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }


        // ENTRY DETAILS
        public string? service_id { get; set; } // search
        public string? service_code { get; set; }
        public string? service_name { get; set; }   // search
        public string? servicetype_id { get; set; } // search
        public string? material_id { get; set; }
        public string? service_description { get; set; }
        public string? condition_1 { get; set; }
        public string? condition_2 { get; set; }
        public string? condition_3 { get; set; }
        public string? condition_4 { get; set; }
        public string? condition_5 { get; set; }
        public int? is_for_farmer { get; set; }
        public int? is_for_agent { get; set; }





        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }
    }







    /*----  ----    ----    ----    Material - Request Model   ----    ----    ----    ----*/
    public class ReqMaterial
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }

        public string? search_text { get; set; }
        public string? material_id { get; set; }
        public string? materialtype_id { get; set; }

    }







    /*----  ----    ----    ----    Product - Request Model   ----    ----    ----    ----*/
    public class ReqProduct
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }

        public string? search_text { get; set; }
        public string? product_id { get; set; }
        public string? product_photo { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
    }






    /*----  ----    ----    ----    Role - Request Model   ----    ----    ----    ----*/
    public class ReqRole
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }

        public string? application_id { get; set; } // search
        public string? role_name { get; set; }  // search

        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? role_id { get; set; }
        public string? role_menu { get; set; }
    }






    /*----  ----    ----    ----    Bank - Request Model   ----    ----    ----    ----*/
    public class ReqBank
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? bank_id { get; set; }
        public string? bank_name { get; set; }
        public string? search_text { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public int is_locked { get; set; }



    }






    /*----  ----    ----    ----    Bank Branch - Request Model   ----    ----    ----    ----*/
    public class ReqBankBranch
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? branch_name { get; set; }
        public string? ifsc_code { get; set; }
        public string? address_text { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public int is_locked { get; set; }



    }
}