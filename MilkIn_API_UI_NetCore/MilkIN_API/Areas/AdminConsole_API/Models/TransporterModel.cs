namespace MilkIN_API.Areas.AdminConsole_API.Models
{
    // ROUTE ENTRY SAVE SEARCH REQUEST
    public class ReqRoute
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }




        // ENTRY DETAILS
        public string? route_id { get; set; }   // search
        public string? route_code { get; set; } // search
        public string? route_name { get; set; } // search
        public string? collectionshift_id { get; set; }
        public string? vehicletype_id { get; set; }
        public string? freight_fix_cost { get; set; }
        public string? frequency_id { get; set; }
        public string? duration { get; set; }
        public string? fuel_required { get; set; }
        public TimeSpan start_time { get; set; }
        public TimeSpan end_time { get; set; }
        public string? start_date { get; set; }
        public string? end_date { get; set; }

        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_lived { get; set; }


        // SEARCH ENTRY DETAILS
        public string? route_status_id { get; set; }    // search

        public string total_distance { get; set; }

    }

    // ROUTE Response
    public class ResRoute
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? is_locked { get; set; }
        public int is_lived { get; set; }


        // ENTRY DETAILS
        public string? route_id { get; set; }
        public string? route_name { get; set; }
        public string? route_code { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }

        public string? freight_fix_cost { get; set; }
        public string? frequency_id { get; set; }
        public string? duration { get; set; }
        public string? fuel_required { get; set; }
        public TimeSpan start_time { get; set; }
        public TimeSpan end_time { get; set; }
        public string? start_date { get; set; }
        public string? end_date { get; set; }


        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string total_distance { get; set; }

    }
    // ROUTE ITEM SAVE SEARCH REQUEST
    public class ReqRouteItem
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }



        // ENTRY DETAILS
        public string? route_id { get; set; }   // search
        public int stage_no { get; set; }   // search
        public string? mcc_id { get; set; }
        public string? distance { get; set; }
        public string? arrival_time { get; set; }
        public string? departure_time { get; set; }
    }
    // ROUTE ITEM Response
    public class ResRouteItem
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? route_id { get; set; }
        public int stage_no { get; set; }
        public string? mcc_name { get; set; }
        public string? mcc_id { get; set; }
        public string? distance { get; set; }
        public TimeSpan arrival_time { get; set; }
        public TimeSpan departure_time { get; set; }
        public string? arrival_times { get; set; }
        public string? departure_times { get; set; }
    }
    // TRUCK SHEET SAVE SEARCH REQUEST
    public class ReqVehicleSheet
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }



        // ENTRY DETAILS
        public string? route_id { get; set; }
        public string? vehicletype_id { get; set; } // search
        public string? vehicle_no_id { get; set; }  // search
        public string? driver_id { get; set; }
        public string? chemist_id { get; set; }
        public string? from_date { get; set; }
        public string? to_date { get; set; }
        public string? entry_id { get; set; }   // search
        public string? vehicletype { get; set; }


        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        // SEARCH DETAILS
        public string? active_as_on_date { get; set; }
    }
    // TRUCK SHEET Response
    public class ResVehicleSheet
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }



        // ENTRY DETAILS
        public string? route_id { get; set; }
        public string? route_code { get; set; }
        public string? route_name { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? chemist_id { get; set; }
        public string? from_date { get; set; }
        public string? to_date { get; set; }
        public string? entry_id { get; set; }
        public string? start_date { get; set; }
        public string? end_date { get; set; }

        // ACTIVE/DELETE STATUS IN DB
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public string? is_locked { get; set; }
    }

    public class ReqManageTrip
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }

        public string? search_period { get; set; }

        public string? entry_id { get; set; }



        public string? route_id { get; set; }
        public string? route_name { get; set; }

        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }


        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? chemist_id { get; set; }

        public string? chemist_name { get; set; }


        public string? tripdocument_id { get; set; }
        public string? is_tripassigned { get; set; }

        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }

        public string reason { get; set; }


        public string? is_reached { get; set; }
        public string? is_vehicle_breakdown { get; set; }

        public string is_endtrip_available { get; set; }

        public string expected_time { get; set; }

        public string arrival_at { get; set; }

        public string order_by { get; set; }

        public string weight { get; set; }

        public string liters { get; set; }

        public string is_collected { get; set; }

        public string mcc_collectionshift_id { get; set; }

        public string trip_status { get; set; }

        public string farmer_id { get; set; }
        public string farmer_name { get; set; }

        public string farmer_code { get; set; }
        public string fat { get; set; }
        public string snf { get; set; }


        public string milktype_id { get; set; }

        public string milktype_name { get; set; }
        public string milkstatus_id { get; set; }
        public string milkstatus_name { get; set; }


        public string? profile_id { get; set; }

        public string? collection_data { get; set; }
        public string? cell_no { get; set; }

    }

    public class ResManageTrip
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }


        public string? search_period { get; set; }

        public string? route_id { get; set; }
        public string? route_name { get; set; }

        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }


        public string? driver_id { get; set; }
        public string? driver_name { get; set; }
        public string? chemist_id { get; set; }

        public string? chemist_name { get; set; }

        public string? entry_id { get; set; }

        public string? tripdocument_id { get; set; }
        public string? is_tripassigned { get; set; }

        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }

        public string reason { get; set; }

        public string? is_reached { get; set; }
        public string? is_vehicle_breakdown { get; set; }

        public string is_endtrip_available { get; set; }

        public string expected_time { get; set; }

        public string arrival_at { get; set; }

        public string order_by { get; set; }

        public string weight { get; set; }

        public string liters { get; set; }

        public string is_collected { get; set; }

        public string mcc_collectionshift_id { get; set; }
        public string trip_status { get; set; }

        public string farmer_id { get; set; }
        public string farmer_name { get; set; }

        public string farmer_code { get; set; }
        public string fat { get; set; }
        public string snf { get; set; }

        public string milktype_id { get; set; }

        public string milktype_name { get; set; }
        public string milkstatus_id { get; set; }
        public string milkstatus_name { get; set; }

        public string? profile_id { get; set; }
        public string? cell_no { get; set; }

        public string? rateavailableflag { get; set; }

        public int is_locked { get; set; }

    }

    public class ReqSurvey
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? mcc_id { get; set; }
        public string? survey_id { get; set; }
        public string? applicable_date { get; set; }
        public string? chemist_id { get; set; }
        public string? chemist_name { get; set; }
        public int assign { get; set; }
        public int conducted { get; set; }
        public int is_started { get; set; }

    }

    public class ResSurvey
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }

        public string? survey_id { get; set; }
        public string? applicable_date { get; set; }
        public string? chemist_id { get; set; }
        public string? chemist_name { get; set; }
        public int assign { get; set; }
        public int conducted { get; set; }
        public int is_started { get; set; }
        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }
        public string? mcc_code { get; set; }
        public string? taluka_name { get; set; }
        public string? village_name { get; set; }


    }

    public class ReqDieselUpload
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        // ENTRY DETAILS
        public string? upload_on { get; set; }
        public string? file_name { get; set; }
        public string? success_count { get; set; }
        public string? error_count { get; set; }
        public string? duplicate_count { get; set; }


        public string? transporter_id { get; set; }
        public string? transporter_name { get; set; }
        public string? transporter_code { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }

        public string? entry_on { get; set; }
        public string? quantity_ltr { get; set; }

        public string? dieselupload_id { get; set; }
        public string? dieselupload_data { get; set; }

        public string? search_period { get; set; }

    }

    // ROUTE Response
    public class ResDieselUpload
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? is_locked { get; set; }
        public int is_lived { get; set; }


        // ENTRY DETAILS
        public string? upload_on { get; set; }
        public string? file_name { get; set; }
        public string? success_count { get; set; }
        public string? error_count { get; set; }
        public string? duplicate_count { get; set; }

        public string? total_count { get; set; }


        public string? transporter_id { get; set; }
        public string? transporter_name { get; set; }
        public string? transporter_code { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }

        public string? entry_on { get; set; }
        public string? quantity_ltr { get; set; }

        public string? dieselupload_id { get; set; }
        public string? dieselupload_data { get; set; }

        public string? date { get; set; }


        public string? entry_date { get; set; }

        public string? status { get; set; }

        public int result_id { get; set; }
        public string? result_description { get; set; }
        public string? result_extra_key { get; set; }

    }

}
