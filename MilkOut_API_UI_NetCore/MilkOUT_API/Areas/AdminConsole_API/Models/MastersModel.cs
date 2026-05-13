using Org.BouncyCastle.Bcpg.OpenPgp;

namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    /*----  ----    ----    ----    Retailer - Request & Response Model   ----    ----    ----    ----*/
    public class ReqRetailer
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? api_end_point { get; set; }


        // ENTRY DETAILS
        public string? retailer_id { get; set; }
        public string? retailer_code { get; set; }
        public string? retailer_name { get; set; }
        public string? salesarea_id { get; set; }
        public string? salesuser_id { get; set; }
        public string? route_id { get; set; }

        public string? dealer_id { get; set; }
        public string? pan_no { get; set; }

        public string? phone_no { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }

        public string? shop_license_no { get; set; }
        public string? msme { get; set; }


        // ADDRESS DETAILS
        public string? address_line_1_text { get; set; }
        public string? address_line_2_text { get; set; }
        public string? address_line_3_text { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? pincode { get; set; }
        public string? contact_person { get; set; }


        // BANK DETAILS
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_no { get; set; }
        public string? account_name { get; set; }
        public string? ifsc_code { get; set; }


        // other details
        public string? fssai_license_no { get; set; }
        public string? fssai_licensevalidity_on { get; set; }
        public string? agreement_validity_period { get; set; }
        public string? gst_no { get; set; }
        public int is_agreement_done { get; set; }

        // image upload
        public string? pan_card_photo { get; set; }
        public string? shop_license_photo { get; set; }
        public string? cheque_leaf_photo { get; set; }
        public string? shop_name_photo { get; set; }
        public string? aadhar_photo { get; set; }
        public string? udyam_aadhar_photo { get; set; }
        public string? fssai_license_photo { get; set; }
        public string? gst_certificate_photo { get; set; }
        public int is_approved { get; set; }

        public string? asme { get; set; }
        public string? aadhar_no { get; set; }





        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? landline_number { get; set; }


    }

    public class NotificationCode
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }

        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? xml_data { get; set; }

    }

    // Retailer Response
    public class ResRetailer
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? Monday_User    {get; set;}
        public string? Tuesday_User   {get; set;}
        public string? Wednesday_User {get; set;}
        public string? Thursday_User  {get; set;}
        public string? Friday_User    {get; set;}
        public string? Saturday_User  {get; set;}
        public string? Sunday_User { get; set; }
        public string? retailer_id { get; set; }
        public string? retailer_code { get; set; }
        public string? retailer_name { get; set; }
        public string? route_name { get; set; }
        public string? salesarea_id { get; set; }
        public string? route_id { get; set; }
        public string? dealer_id { get; set; }
        public string? pan_no { get; set; }
        public string? phone_no { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? shop_license_no { get; set; }
        public string? msme { get; set; }
        public string? salesarea_name { get; set; }
        public string? dealer_name { get; set; }
        public string? shoplatitude { get; set; }
        public string? shoplongitude { get; set; }
        public string? securitydepositamount { get; set; }

        public string? cratelimit { get; set; }
        // ADDRESS DETAILS
        public string? address_line_1_text { get; set; }
        public string? address_line_2_text { get; set; }
        public string? address_line_3_text { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? pincode { get; set; }
        public string? contact_person { get; set; }


        // BANK DETAILS
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_no { get; set; }
        public string? account_name { get; set; }
        public string? ifsc_code { get; set; }


        // other details
        public string? fssai_license_no { get; set; }
        public string? fssai_licensevalidity_on { get; set; }
        public string? agreement_validity_period { get; set; }
        public string? gst_no { get; set; }
        public int is_agreement_done { get; set; }
        public int is_approved { get; set; }


        // image upload
        public string? pan_card_photo { get; set; }
        public string? shop_license_photo { get; set; }
        public string? cheque_leaf_photo { get; set; }
        public string? shop_name_photo { get; set; }
        public string? aadhar_photo { get; set; }
        public string? udyam_aadhar_photo { get; set; }
        public string? fssai_license_photo { get; set; }
        public string? gst_certificate_photo { get; set; }

        public string? asme { get; set; }
        public string? aadhar_no { get; set; }

        public string? dealer_code { get; set; }
        public string? state_name { get; set; }
        public string? district_name { get; set; }
        public string? taluka_name { get; set; }
        public string? bank_name { get; set; }
        public string? branch_name { get; set; }
        public string? agreementvalidiy_startdate { get; set; }
        public string? agreementvalidity_enddate { get; set; }

        public string? landline_number { get; set; }

        public string? salesuser_name { get; set; }

        public string? salesuser_id { get; set; }


    }






    /*----  ----    ----    ----    Dealer - Request & Response Model   ----    ----    ----    ----*/
    public class ReqDealer
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }

        // ENTRY DETAILS
        public string? dealer_id { get; set; }
        public string? dealer_code { get; set; }
        public string? dealer_name { get; set; }
        public string? salesarea_id { get; set; }
        public string? salesuser_id { get; set; }
        public string? pan_no { get; set; }
        public string? phone_no { get; set; }
        public string? email_id { get; set; }



        // ADDRESS DETAILS
        public string? address_line_1_text { get; set; }
        public string? address_line_2_text { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        //public string? village_id { get; set; }
        public string? pincode { get; set; }
        public string? contact_person { get; set; }
        public string? mobile_no { get; set; }




        // BANK DETAILS
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_no { get; set; }
        public string? account_name { get; set; }
        public string? ifsc_code { get; set; }



        public string? msme_no { get; set; }
        public string? fssai_license_no { get; set; }
        public string? fssai_licensevalidity_on { get; set; }
        public string? agreement_validity_period { get; set; }
        public string? gst_no { get; set; }
        public int is_agreement_done { get; set; }
        public string? shoplatitude { get; set; }
        public string? shoplongitude { get; set; }




        // IMG DETAILS
        //  public byte[]? pan_card_photo{ get; set; }
        //   public byte[]? shop_license_photo { get; set; }
        //public byte[]? cheque_leaf_photo { get; set; }



        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }


        public int is_payment { get; set; }

        public string? payment_url { get; set; }

        public string? login_password { get; set; }


    }

    // Dealer Response
    public class ResDealer
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }


        // ENTRY DETAILS
        public string? dealer_id { get; set; }
        public string? dealer_code { get; set; }
        public string? dealer_name { get; set; }
        public string? salesarea_id { get; set; }
        public string? salesarea_name { get; set; }
        public string? salesuser_id { get; set; }
        public string? salesuser_name { get; set; }
        public string? pan_no { get; set; }
        public string? phone_no { get; set; }
        public string? email_id { get; set; }

        // ADDRESS DETAILS
        public string? address_line_1_text { get; set; }
        public string? address_line_2_text { get; set; }
        public string? address_line_3_text { get; set; }

        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }

        public string? state_name { get; set; }
        public string? district_name { get; set; }
        public string? taluka_name { get; set; }

        public string? pincode { get; set; }
        public string? contact_person { get; set; }
        public string? mobile_no { get; set; }

        // BANK DETAILS
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }

        public string? bank_name { get; set; }
        public string? branch_name { get; set; }

        public string? account_no { get; set; }
        public string? account_name { get; set; }
        public string? ifsc_code { get; set; }




        public string? msme_no { get; set; }
        public string? fssai_license_no { get; set; }
        public string? fssai_licensevalidity_on { get; set; }
        public string? agreement_validity_period { get; set; }
        public string? gst_no { get; set; }
        public int is_agreement_done { get; set; }
        public string? securitydepositamount { get; set; }
        public string? shoplatitude { get; set; }
        public string? shoplongitude { get; set; }
        public string? cratelimit { get; set; }



        // IMG DETAILS
        //  public byte[]? pan_card_photo{ get; set; }
        //   public byte[]? shop_license_photo { get; set; }
        //public byte[]? cheque_leaf_photo { get; set; }

        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public int is_payment { get; set; }

        public string? payment_url { get; set; }

        public string? login_password { get; set; }




        public string? village_name { get; set; }

        public string? agreementvalidiy_startdate { get; set; }
        public string? agreementvalidity_enddate { get; set; }




    }






    /*----  ----    ----    ----    Sales Area - Request & Response Model   ----    ----    ----    ----*/
    public class ReqSalesGroup
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public string? user_name { get; set; }

        // SEARCH ENTRY DETAILS
        public string? salesarea_id { get; set; }
        public string? salesarea_code { get; set; }
        public string? salesarea_name { get; set; }


        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

    }
    public class ResSalesGroup
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }


        // ENTRY DETAILS
        public string? salesarea_id { get; set; }
        public string? salesarea_code { get; set; }
        public string? salesarea_name { get; set; }


        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

    }











    /*----  ----    ----    ----    Sales User - Request & Response Model   ----    ----    ----    ----*/
    public class ReqSalesUser
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? search_text { get; set; }
        public string? salesuser_id { get; set; }
        public string? sap_bp_partner_code { get; set; }
        public string? salesuser_code { get; set; }
        public string? salesuser_name { get; set; }
        public string? route_id { get; set; }
        public string? reportingto_id { get; set; }
        public string? salesuserrole_id { get; set; }
        public string? salesarea_id { get; set; }
        public string? salesuserrole_name { get; set; }
        public string? joining_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }
        public int online_app_flag { get; set; }
        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }
        public string? nominee_name { get; set; }
        public string? nominee_relation { get; set; }
        public string? nomineemobile_no { get; set; }
        public string? nomineeaadhar_no { get; set; }

        public string? salesemployee { get; set; }

        public string? login_password { get; set; }
    }
    public class ResSalesUser
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? salesuser_id { get; set; }
        public string? route_id { get; set; }
        public string? route_name { get; set; }
        public string? salesuser_code { get; set; }
        public string? salesuser_name { get; set; }
        public string? reportingto_id { get; set; }
        public string? reportingto_name { get; set; }
        public string? salesuserrole_id { get; set; }
        public string? salesuserrole_name { get; set; }
        public string? sap_bp_partner_code { get; set; }
        public string? joining_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public string? state_id { get; set; }
        public string? district_id { get; set; }
        public string? taluka_id { get; set; }
        public string? taluka_name { get; set; }
        public string? village_id { get; set; }
        public string? address_text { get; set; }
        public int online_app_flag { get; set; }

        public string? bank_id { get; set; }
        public string? branch_id { get; set; }
        public string? account_name { get; set; }
        public string? account_no { get; set; }
        public string? ifsc_code { get; set; }
        public string? nominee_name { get; set; }
        public string? nominee_relation { get; set; }
        public string? nomineemobile_no { get; set; }
        public string? nomineeaadhar_no { get; set; }

        public string? salesemployee { get; set; }




        public string? birth_date { get; set; }
        public string? state_name { get; set; }
        public string? district_name { get; set; }
        public string? pincode { get; set; }
        public string? bank_name { get; set; }

        public string? login_password { get; set; }
        public string? salesarea_id { get; set; }

    }



    /*----  ----    ----    ----    Sales User ReOpen - Request & Response Model   ----    ----    ----    ----*/
    public class ReqSalesUserReOpen
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }

        public string? entry_id { get; set; }
    }
    public class ResSalesUserReOpen
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }

        public string? entry_id { get; set; }
        public string? salesuser_id { get; set; }
        public string? salesuser_name { get; set; }
        public string? route_id { get; set; }
        public string? route_name { get; set; }
        public string? routeday_id { get; set; }
        public string? routeday_name { get; set; }
        public string? start_time { get; set; }
        public string? end_time { get; set; }
        public string? status { get; set; }
        public string? date { get; set; }
        public string? is_open { get; set; }



    }






    /*----  ----    ----    ----    Product - Request & Response Model   ----    ----    ----    ----*/
    public class ReqProduct
    {
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

        public string? product_data { get; set; }

    }
    public class ResProduct
    {
        public string? org_id { get; set; }
        public string? user_name { get; set; }
        public string? product_name { get; set; }
        public string? product_code { get; set; }
        public string? product_id { get; set; }
        public string? product_photo { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
    }





    /*----  ----    ----    ----    Role - Request & Response Model   ----    ----    ----    ----*/
    public class ReqRole
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }


        public string? application_id { get; set; } // search
        public string? role_name { get; set; }  // search
        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? role_id { get; set; }
        public string? role_menu { get; set; }

    }

    // ROLE AND ROLE MENU RESPONSE
    public class ResRole
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
        public string? role_id { get; set; }
        public string? role_menu { get; set; }
        public int display_flag { get; set; }
        public int add_flag { get; set; }
        public int edit_flag { get; set; }
        public int delete_flag { get; set; }
        public string? menu_id { get; set; }
        public string? menu_name { get; set; }
        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }


        public int flag { get; set; }
        public string? reporttype_id { get; set; }
        public string? reporttype_name { get; set; }
    }






    /*----  ----    ----    ----    Office OfficeUsers - Request & Response Model   ----    ----    ----    ----*/

    public class ReqOfficeUsers
    {
        // ReqOfficeUsersSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? officeuser_id { get; set; }
        public string? officeuser_name { get; set; }
        public string? role_id { get; set; }


        // ReqOfficeUsersSave
        public string? joining_date { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? pan_no { get; set; }
        public string? aadhar_no { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? employee_id { get; set; }
    }
    public class ResOfficeUsers
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
        public string? login_password { get; set; }
        public string? is_passwordreset { get; set; }

    }



    public class Reqproductuom
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }

        public string? xml_data { get; set; }

        public string? api_end_point { get; set; }


        public string? destination_name { get; set; }



    }


    public class ReqProductRate
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }


        public string? api_end_point { get; set; }


        public string? destination_name { get; set; }

        public string? dealer_code { get; set; }

        public string? product_code { get; set; }


        public string? product_id { get; set; }

        public string? dealer_id { get; set; }

        public string? uom { get; set; }

        public string? sales_organization { get; set; }

        public string? distribution_channel { get; set; }

        public string? division { get; set; }

    }

    public class ResProductRate
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }


        public string? api_end_point { get; set; }


        public string? destination_name { get; set; }

        public string? dealer_code { get; set; }

        public string? product_code { get; set; }



    }

    public class ReqComplaintType
    {
        // ReqOfficeUsersSearch
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }

        public string? complainttype_id { get; set; }
        public string? complainttype_name { get; set; }
    }
    public class ResComplaintType
    {
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? complainttype_id { get; set; }
        public string? complainttype_name { get; set; }
        public int is_active { get; set; }

    }
    public class ReqRouteSU
    {
        // Common API Fields
        public string method_name { get; set; }
        public string api_end_point { get; set; }
        public string org_id { get; set; }
        public string user_id { get; set; } // Sent from session usually
        public string user_name { get; set; }

        // Search/List Fields
        public string retailer_list { get; set; }
        public string search_text { get; set; }
        public string status { get; set; }

        // Entry Specific Fields
        public string entry_id { get; set; }
        public string salesarea_id { get; set; } // Matches JS reqdata.sales_area_id
        public string route_name { get; set; }
        public string route_day_id { get; set; }
        public string working_status { get; set; } // Receives "1" or "0"
        public int is_active { get; set; }        // Receives 1 or 0
        public string remarks { get; set; }
        public string dealer_id { get; set; }

        // Additional fields that might be used in Edit/Delete
        public string route_id { get; set; }
        public string destination_name { get; set; }
    }

    public class ResRouteSU
    {
        
            public string Org_Id { get; set; }
            public string Route_Id { get; set; }
            public string Route_Name { get; set; }
            public string Remarks { get; set; }
            public string RouteDay_Id { get; set; }
        public string SalesArea_Id { get; set; }
        public string Dealer_Id { get; set; }
            public string RouteDay_Name { get; set; }
            public string Working_Status { get; set; }
            public int Total_Retailers { get; set; }
            public bool Is_Active { get; set; }
            public bool Is_Deleted { get; set; }
        

    }
}
