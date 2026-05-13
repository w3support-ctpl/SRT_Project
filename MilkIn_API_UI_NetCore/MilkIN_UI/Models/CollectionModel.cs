namespace MilkIN_UI.Models
{


    /*----  ----    ----    ----    Milk Collection Request Model   ----    ----    ----    ----*/
    public class ReqMilkCollection
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? vehicle_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }
        public int is_collected { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? vehicletype { get; set; }
        public string? milkdata { get; set; }

        public int is_locked { get; set; }
        public string? vehicle_no { get; set; }
        public string? route_name { get; set; }
        public string? mcccollectionshift_name { get; set; }

        public string? collectionshift_name { get; set; }
        public string? collectionshift_id { get; set; }

        public string? end_time { get; set; }
        public string? weight { get; set; }
        public int totalcans { get; set; }
        public string? mcc_name { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milktype_id { get; set; }
        public string? milkstatus_name { get; set; }
        public string? milktype_name { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? created_on { get; set; }
        public string? quantity_ltr { get; set; }
        public int cans { get; set; }
        public string? vehicletype_id { get; set; }
        public string? machine_data { get; set; }
        public string? gross_weight { get; set; }
        public string? tare_weight { get; set; }
        public string? reasons { get; set; }

        public string? search_period { get; set; }

        public string? liter { get; set; }

    }

    /*----  ----    ----    ----    Milk Collection Quantity Request Model   ----    ----    ----    ----*/
    public class ReqMilkCollectionQuantity
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? entry_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? milktype_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? weight { get; set; }
        public string? cans { get; set; }
        public string? cellno { get; set; }
        public string? stored_procedure { get; set; }
        public string? vehicle_id { get; set; }
        public string? batch_id { get; set; }

        public string? supervisordata { get; set; }
        public string? machine_data { get; set; }

        public string? gross_weight { get; set; }
        public string? tare_weight { get; set; }
        public string? reasons { get; set; }

        public string? search_period { get; set; }



    }

    /*----  ----    ----    ----    Milk Collection Quality Request Model   ----    ----    ----    ----*/
    public class ReqMilkCollectionQuality
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        public string? entry_id { get; set; }
        public string? milkstatus_id { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? mcc_id { get; set; }
        public string? mcccollectionshift_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? sample_no { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? milkstatus_name { get; set; }
        public string? cellno { get; set; }
        public string? stored_procedure { get; set; }
        public string? vehicle_id { get; set; }
        public string? batch_id { get; set; }

        public string? cans { get; set; }
        public string? machine_data { get; set; }
        public string? gross_weight { get; set; }
        public string? tare_weight { get; set; }
        public string? reasons { get; set; }

        public string? search_period { get; set; }


    }

    /*----  ----    ----    ----    Milk Collection Route Chemist Request Model   ----    ----    ----    ----*/
    /*

    public class ReqMilkCollectionSupervisor
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? mcc_name { get; set; }
        public string? milktype_name { get; set; }
        public string? milkstatus_name { get; set; }
        public string? weight {  get; set; }
        public string? liter { get; set; }
        public string? snf { get; set; }
        public string? fat { get; set; }
        public string? cellno { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

    }
    */


    /*----  ----    ----    ----    Milk Collection Analyst Request Model   ----    ----    ----    ----*/
    /*
    public class ReqMilkCollectionAnalyst
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? tripdocument_id { get; set; }

        public string? vehicle_id { get; set; }


    }
    */


    /*----  ----    ----    ----    Trip Document Request Model   ----    ----    ----    ----*/
    public class ReqTripDocument
    {

        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? tripdocumentstatus_id { get; set; }
        public string? date { get; set; }
        public string? trip_no { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? route_name { get; set; }
        public string? collectionshift_name { get; set; }
        public string? driver_name { get; set; }
        public string? disatance { get; set; }
        public string? disatance_driver { get; set; }
        public string? disatance_fleetx { get; set; }
        public string? distanceasperfleetx { get; set; }
        public string? finaldistance { get; set; }
        public string? rate { get; set; }
        public string? tripamount { get; set; }
        public string? freightratetype_id { get; set; }

        public string? dieselbaserate { get; set; }
        public string? freightratetype_name { get; set; }
        public string? currentdieselrate { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }
        public string? fleetx_id { get; set; }

        public string? in_km { get; set; }
        public string? out_km { get; set; }
    }

    public class ReqGoodsInwardPosting
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? entry_id { get; set; }
        public string? tripdocument_id { get; set; }



        public string? mcc_id { get; set; } // search
        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }

        public string? milktype_id { get; set; }
        public string? milktype_name { get; set; }

        public string? quantity { get; set; }
        public string? quality { get; set; }

        public string? fat { get; set; }
        public string? snf { get; set; }
        public string? protein { get; set; }
        public string? ash { get; set; }
        public string? sodium { get; set; }

    }


    public class ReqCollectionApproval
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? entry_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicletype_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }


        public string? mcc_id { get; set; }

        public string? mcc_name { get; set; }
        public string? milktype_id { get; set; }

        public string? milktype_name { get; set; }

        public string? milkstatus_id { get; set; }

        public string? milkstatus_name { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }


        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? cellno { get; set; }


        public string? mcc_commission { get; set; }
    }

    public class ReqQualityEntry
    {
        public string? org_id { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? search_period { get; set; }

        public string? method_name { get; set; }

        public string? api_end_point { get; set; }


        public string? entry_id { get; set; }
        public string? milkcollectiondairy_id { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }

        public string? protein { get; set; }


        public string? ash { get; set; }
        public string? sodium { get; set; }

        public string? adulteration { get; set; }

        public string? sample_no { get; set; }

        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? vehicletype_id { get; set; }
        public string? vehicletype_name { get; set; }

        public string? is_locked { get; set; }

        public string? milkstatus_id { get; set; }


        public string? is_mcc { get; set; }



    }

    public class ReqGainLossEntry
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? batch_id { get; set; }
        public string? search_period { get; set; }
        public string? milkcollectiondairy_id { get; set; }
        public string? entry_id { get; set; }
        public string? tripdocument_id { get; set; }
        public string? vehicletype_id { get; set; }
        public string? approvalstatus_id { get; set; }
        public string? approval_remarks { get; set; }


        public string? mcc_id { get; set; }

        public string? mcc_name { get; set; }
        public string? milktype_id { get; set; }

        public string? milktype_name { get; set; }

        public string? milkstatus_id { get; set; }

        public string? milkstatus_name { get; set; }

        public string? weight { get; set; }
        public string? liters { get; set; }


        public string? snf { get; set; }
        public string? fat { get; set; }


        public string? baserate { get; set; }

        public string? servicecharge { get; set; }

        public string? amount { get; set; }

        public string? cellno { get; set; }


        public string? mcc_commission { get; set; }


        public string? agent_ltr { get; set; }
        public string? agent_fat { get; set; }
        public string? agent_snf { get; set; }

        public string? chemist_ltr { get; set; }
        public string? chemist_fat { get; set; }
        public string? chemist_snf { get; set; }

        public string? composite_ltr { get; set; }
        public string? composite_fat { get; set; }
        public string? composite_snf { get; set; }

        public string? composite_protein { get; set; }
        public string? composite_ash { get; set; }
        public string? composite_sodium { get; set; }


        public string? chemistcollection_id { get; set; }

        public string? final_ltr { get; set; }
        public string? final_fat { get; set; }
        public string? final_snf { get; set; }


        public string? lab_fat { get; set; }
        public string? lab_snf { get; set; }

    }


}


