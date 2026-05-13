namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    /*-----     -----       Retailer Authorization      -----       -----*/
    public class ReqRetailersAuthorization
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? retailer_id { get; set; }
        public string? salesuser_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? request_period { get; set; }
        public string? approval_remarks { get; set; }



        // ENTRY DETAILS
        public string? retailer_code { get; set; }
        public string? retailer_name { get; set; }
        public string? salesarea_id { get; set; }
        public string? dealer_id { get; set; }
        public string? pan_no { get; set; }

        public string? phone_no { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }

        public string? shop_license_no { get; set; }


        // ADDRESS DETAILS
        public string? address_line_1_text { get; set; }
        public string? address_line_2_text { get; set; }
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





    }
    public class ResRetailersAuthorization
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? retailer_id { get; set; }
        public string? retailer_code { get; set; }
        public string? retailer_name { get; set; }
        public string? salesarea_id { get; set; }
        public string? salesuser_id { get; set; }
        public string? salesarea_name { get; set; }
        public string? salesuser_name { get; set; }
        public string? dealer_id { get; set; }
        public string? pan_no { get; set; }
        public string? phone_no { get; set; }
        public string? mobile_no { get; set; }
        public string? email_id { get; set; }
        public string? shop_license_no { get; set; }
        public string? dealer_name { get; set; }
        public string? shoplatitude { get; set; }
        public string? shoplongtitude { get; set; }
        public string? securitydepositamount { get; set; }
        public string? cratelimit { get; set; }

        // ADDRESS DETAILS
        public string? address_line_1_text { get; set; }
        public string? address_line_2_text { get; set; }
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
        public string? approval_remarks { get; set; }
        public string? approved_on { get; set; }




        // image upload
        public string? pan_card_photo { get; set; }
        public string? shop_license_photo { get; set; }
        public string? cheque_leaf_photo { get; set; }
        public string? shop_name_photo { get; set; }
        public string? aadhar_photo { get; set; }
        public string? udyam_aadhar_photo { get; set; }
        public string? fssai_license_photo { get; set; }
        public string? gst_certificate_photo { get; set; }

    }







    /*-----     -----       Sales User      -----       -----*/
    public class ReqSalesUserRoute
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? dealer_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? rid { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int total_retailers { get; set; }
        public int working_status { get; set; }
        public string? salesuser_id { get; set; }
        public string? salesarea_id { get; set; }
        public string? route_id { get; set; }
        public string? retailer_list { get; set; }
        public string? remarks { get; set; }

        public string? route_name { get; set; }

        public string? routeday_id { get; set; }
    }

    public class ResSalesUserRoute
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public string? Assigned_To_Other_User { get; set; }
        public string? assigned { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int working_status { get; set; }
        public int total_retailers { get; set; }
        public string? remarks { get; set; }
        public int is_locked { get; set; }
        public string? salesuser_id { get; set; }
        public string? salesuser_name { get; set; }
        public string? salesarea_id { get; set; }
        public string? salesarea_name { get; set; }
        public string? route_id { get; set; }
        public string? routeday_id { get; set; }
        public string? routeday_name { get; set; }
        public string? retailer_id { get; set; }
        public string? retailer_name { get; set; }

        public string? route_name { get; set; }

        public string? dealer_id { get; set; }
        public string? dealer_code { get; set; }

        public string? dealer_name { get; set; }


        public int is_dealer { get; set; }

    }







    /*-----     -----       Targets      -----       -----*/
    public class ReqTargets
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? salesuser_id { get; set; }
        public string? financialyear_id { get; set; }
        public string? entry_id { get; set; }
        public string? dealer_id { get; set; }
        public string? product_id { get; set; }
        public string? quantity { get; set; }
        public string? target_date { get; set; }

        public string? productgroup_id { get; set; }
        public string? productgroup_name { get; set; }
        public string? productuom { get; set; }

        public string? target_id { get; set; }
        public string? type { get; set; }
        

    }
    public class ResTargets
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? salesuser_id { get; set; }
        public string? financialyear_id { get; set; }
        public string? entry_id { get; set; }
        public string? dealer_id { get; set; }
        public string? dealer_name { get; set; }
        public string? product_id { get; set; }
        public string? product_name { get; set; }
        public string? quantity { get; set; }
        public string? month_year { get; set; }
        public string? month_year_name { get; set; }

        public string? productgroup_id { get; set; }
        public string? productgroup_name { get; set; }
        public string? productuom { get; set; }
        public string? target_id { get; set; }
    }







    /*-----     -----       Complaints      -----       -----*/
    public class ReqComplaints
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? complaint_id { get; set; }
        public string? complainttype_id { get; set; }
        public string? complaintstatus_id { get; set; }
        public string? complaint_period { get; set; }

         public string? qualitynotification { get; set; }

         public string? complaint_remark { get; set; }




    }
    public class ResComplaints
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_closed { get; set; }
        public string? complaint_id { get; set; }
        public string? complainttype_id { get; set; }
        public string? complaintstatus_id { get; set; }
        public string? complaint_date { get; set; }
        public string? formatted_complaint_date { get; set; }
        public string? complainttype_name { get; set; }
        public string? complaintstatus_name { get; set; }
        public string? complaint_for { get; set; }
        public string? complaint_for_user_name { get; set; }
        public string? closing_date { get; set; }
        public string? action_date { get; set; }
        public string? formatted_action_date { get; set; }
        public string? action_by_name { get; set; }
        public string? remarks { get; set; }
        public string? latitude { get; set; }
        public string? longitude { get; set; }

        public string? link { get; set; }

        public string? qualitynotification { get; set; }

    }






    /*-----     -----       Crate Received      -----       -----*/
    public class ReqCrateReceived
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? receivedcrate_id { get; set; }
        public int is_approved { get; set; }
        public string? approved_data { get; set; }
        public string? dealer_id { get; set; }
        public string? received_period { get; set; }
    }
    public class ResCrateReceived
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? receivedcrate_id { get; set; }
        public int is_approved { get; set; }
        public string? dealer_id { get; set; }
        public string? received_period { get; set; }
        public string? dealer_name { get; set; }
        public string? created_on { get; set; }
        public string? quantity { get; set; }
        public string? approved_quantity { get; set; }
        public string? cratebalance { get; set; }
        public string? material_id { get; set; }
        public string? material_name { get; set; }
        public string? materialtype_id { get; set; }
        public string? materialtype_name { get; set; }

        public string? good_quantity { get; set; }
        public string? broken_quantity { get; set; }
        public string? thirdparty_quantity { get; set; }

    }






    public class ReqCrateDispatched
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? dispatch_id { get; set; }
        public int is_approved { get; set; }
        public string? dealer_code { get; set; }
        public string? dealer_name { get; set; }
        public string? dispatch_date { get; set; }
        public string? quantity { get; set; }
        public string? material_code { get; set; }
        public string? invoice_number { get; set; }
        public string? dealer_id { get; set; }
        public string? dispatch_period { get; set; }
    }
    public class ResCrateDispatched
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? dispatch_id { get; set; }
        public int is_approved { get; set; }
        public string? dealer_code { get; set; }
        public string? dealer_name { get; set; }
        public string? dispatch_date { get; set; }
        public string? quantity { get; set; }
        public string? material_code { get; set; }
        public string? material_name { get; set; }
        public string? invoice_number { get; set; }
        public string? dealer_id { get; set; }
    }






    public class ReqNotification
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? notification_id { get; set; }
        public string? notificationfor_id { get; set; }
        public string? notificationtype_id { get; set; }
        public string? schedule_date { get; set; }
        public string? notification_subject { get; set; }
        public string? notification_message { get; set; }
        public string? notification_period { get; set; }

    }
    public class ResNotification
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? notification_id { get; set; }
        public string? notificationfor_id { get; set; }
        public string? notificationfor_name { get; set; }
        public string? notificationtype_id { get; set; }
        public string? notificationtype_name { get; set; }
        public string? schedule_date { get; set; }
        public string? notification_subject { get; set; }
        public string? notification_message { get; set; }
        public string? notification_date { get; set; }
        public int notification_status { get; set; }

    }


    public class ReqCrateApprove
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? receivedcrate_id { get; set; }
        public int is_approved { get; set; }
        public string? approved_data { get; set; }
        public string? dealer_id { get; set; }
        public string? received_period { get; set; }
    }








}


