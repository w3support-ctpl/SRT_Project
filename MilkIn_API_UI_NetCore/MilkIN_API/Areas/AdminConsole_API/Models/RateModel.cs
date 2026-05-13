namespace MilkIN_API.Areas.AdminConsole_API.Models
{
    /*----  ----    ----    ----    Slab Request & Response Modle   ----    ----    ----    ----*/

    public class ReqSlab
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? slab_id { get; set; }
        public string? slab_name { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? slab_min { get; set; }
        public string? slab_max { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? slab_type { get; set; }

    }

    public class ResSlab
    {
        public string? org_id { get; set; }
        public string? slab_id { get; set; }
        public string? slab_name { get; set; }
        public string? slab_min { get; set; }
        public string? slab_max { get; set; }
        public string? is_active { get; set; }
        public int is_locked { get; set; }
    }

    /*----  ----    ----    ----    Diesel Request & Response Modle   ----    ----    ----    ----*/

    public class ReqDiesel
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? date { get; set; }
        public string? dieselrate_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? dieselrate { get; set; }
        public string? dieselrate_date { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? destination_name { get; set; }
    }

    public class ResDiesel
    {
        public string? org_id { get; set; }
        public string? dieselrate_date { get; set; }
        public string? dieselrate_id { get; set; }
        public string? dieselrate { get; set; }
        public int is_active { get; set; }
        public int is_locked { get; set; }
    }

    /*----  ----    ----    ----    Milk Rate Request & Response Modle   ----    ----    ----    ----*/

    public class ReqMilkRate
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
        public string? chart_name { get; set; } // search
        public string? milktype_id { get; set; }    // search
        public string? milkstatus_id { get; set; }  // search
        public string? chart_id { get; set; }
        public string? uom_id { get; set; }
        public string? mcc_id { get; set; }
        public string? collectionshift_id { get; set; }
        public int is_lived { get; set; }
        public string? rate_date { get; set; }
        public string? mcc_name { get; set; }

        public string? fat_incentives { get; set; }
        public string? fat_deduction { get; set; }
        public string? snf_incentives { get; set; }
        public string? snf_deduction { get; set; }

        public string? base_rate { get; set; }



    }

    public class ResMilkRate
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? chart_name { get; set; } // search
        public string? milktype_id { get; set; }    // search
        public string? milktype_name { get; set; }
        public string? milkstatus_id { get; set; }  // search
        public string? milkstatus_name { get; set; }
        public string? chart_id { get; set; }
        public string? uom_id { get; set; }
        public string? uom_name { get; set; }
        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }
        public int is_lived { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? basefat { get; set; }
        public string? basesnf { get; set; }
        public string? milkrateentrytype_name { get; set; }
        public string? milkrateentrytype_id { get; set; }
        public string? slab_min { get; set; }
        public string? slab_max { get; set; }
        public string? amount { get; set; }
        public string? mcc_id { get; set; }
        public string? mcc_name { get; set; }

        public string? fat_incentives { get; set; }
        public string? fat_deduction { get; set; }
        public string? snf_incentives { get; set; }
        public string? snf_deduction { get; set; }


        public string? base_rate { get; set; }


    }

    /*----  ----    ----    ----    Milk Rate Item Request & Response Modle   ----    ----    ----    ----*/

    public class ReqMilkRateItem
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }

        // Base Rate
        public string? basefat { get; set; }
        public string? basesnf { get; set; }

        // Common
        public string? chart_id { get; set; }
        public string? milkrateentrytype_id { get; set; }
        public string? entry_id { get; set; }
        public string? amount { get; set; }
        public string? applicable_date { get; set; }
        public string? slab_id { get; set; }
        public string? version_no { get; set; }

        public string? is_backdate { get; set; }
        public string? back_date { get; set; }

        public string? is_accessdate { get; set; }


    }

    public class ResMilkRateItem
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }

        // Base Rate
        public string? basefat { get; set; }
        public string? basesnf { get; set; }

        // Common
        public string? chart_id { get; set; }
        public string? milkrateentrytype_id { get; set; }
        public string? milkrateentrytype_name { get; set; }
        public string? entry_id { get; set; }
        public string? amount { get; set; }
        public string? applicable_date { get; set; }
        public string? slab_id { get; set; }
        public string? slab_name { get; set; }
        public string? version_no { get; set; }
        public string? slab_range { get; set; }
        public int is_locked { get; set; }

        public string? is_backdate { get; set; }
        public string? back_date { get; set; }
        public string? is_accessdate { get; set; }

    }

    /*----  ----    ----    ----    Milk Rate MCC Request & Response Modle   ----    ----    ----    ----*/

    public class ReqMilkRateMCC
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? version_no { get; set; }
        public string? chart_id { get; set; }
        public string? mcc_id { get; set; }
        public string? milktype_id { get; set; }
        public string? collectionshift_id { get; set; }
        public string? applicable_date { get; set; }
        public string? search_text { get; set; }

        public string? is_backdate { get; set; }
        public string? back_date { get; set; }
        public string? is_accessdate { get; set; }

    }

    public class ResMilkRateMCC
    {
        public string? chart_id { get; set; }
        public string? version_no { get; set; }
        public string? applicable_date { get; set; }
        public string? set_date { get; set; }
        public int is_locked { get; set; }
        public string? mcc_id { get; set; }
        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }
        public string? taluka_name { get; set; }
        public string? village_name { get; set; }

        public string? district_name { get; set; }
        public string? mcctype_name { get; set; }

        public string? is_backdate { get; set; }
        public string? back_date { get; set; }

        public string? is_accessdate { get; set; }
    }

    /*----  ----    ----    ----    MCC Commission Request & Response Modle   ----    ----    ----    ----*/

    public class ReqMCCCommission
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? mppi_name { get; set; } // search
        public string? mppi_id { get; set; }
        public string? milktype_id { get; set; } //search
        public string? milkstatus_id { get; set; }
        public string? uom_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }
        public int? is_lived { get; set; }

        public string? taluka_name { get; set; }
        public string? village_name { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? mppitype_id { get; set; }

        public string? district_name { get; set; }
        public string? mcctype_name { get; set; }

    }
    public class ResMCCCommission
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? mppi_name { get; set; } // search
        public string? mppi_id { get; set; }
        public string? milktype_id { get; set; } //search
        public string? milktype_name { get; set; }
        public string? milkstatus_id { get; set; }
        public string? milkstatus_name { get; set; }
        public string? uom_id { get; set; }
        public string? uom_name { get; set; }
        public string? mcctype_id { get; set; }
        public string? mcctype_name { get; set; }
        public string? mccworktype_id { get; set; }
        public string? mccworktype_name { get; set; }
        public int? is_lived { get; set; }

        public string? taluka_name { get; set; }
        public string? village_name { get; set; }

        public string? collectionshift_id { get; set; }
        public string? collectionshift_name { get; set; }

        public string? mppitype_id { get; set; }

        public string? district_name { get; set; }

    }

    /*----  ----    ----    ----    MCC Commission Item Request & Response Modle   ----    ----    ----    ----*/

    public class ReqMCCCommissionItem
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? entry_id { get; set; }
        public string? mppi_id { get; set; }
        public string? minimumquantity { get; set; }
        public string? baserate { get; set; }
        public string? applicable_date { get; set; }
        public string? basefat { get; set; }
        public string? basesnf { get; set; }
        public string? minimumfat { get; set; }
        public string? minimumsnf { get; set; }
        public string? qualitydeduction { get; set; }
        public string? servicecharge { get; set; }
        public int? version_no { get; set; }
        public string? snf_deduction { get; set; }
        public string? fat_deduction { get; set; }
        public string? fat_incentive { get; set; }
        public string? snf_incentive { get; set; }
        public string? taluka_name { get; set; }
        public string? village_name { get; set; }

        public string? maximumquantity { get; set; }
        public string? maximumfat { get; set; }
        public string? maximumsnf { get; set; }

        public string? district_name { get; set; }
        public string? mcctype_name { get; set; }

        public string? minimumprotein { get; set; }
        public string? maximumprotein { get; set; }

        public string? minimumash { get; set; }
        public string? maximumash { get; set; }

    }
    public class ResMCCCommissionItem
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? entry_id { get; set; }
        public string? mppi_id { get; set; }
        public string? minimumquantity { get; set; }
        public string? baserate { get; set; }
        public string? applicable_date { get; set; }
        public string? basefat { get; set; }
        public string? basesnf { get; set; }
        public string? minimumfat { get; set; }
        public string? minimumsnf { get; set; }
        public string? qualitydeduction { get; set; }
        public string? servicecharge { get; set; }
        public int? version_no { get; set; }
        public string? snf_deduction { get; set; }
        public string? fat_deduction { get; set; }
        public string? fat_incentive { get; set; }
        public string? snf_incentive { get; set; }
        public int is_locked { get; set; }

        public string? taluka_name { get; set; }
        public string? village_name { get; set; }

        public string? maximumquantity { get; set; }
        public string? maximumfat { get; set; }
        public string? maximumsnf { get; set; }
        public string? district_name { get; set; }
        public string? mcctype_name { get; set; }



        public string? minimumprotein { get; set; }
        public string? maximumprotein { get; set; }

        public string? minimumash { get; set; }
        public string? maximumash { get; set; }

    }

    /*----  ----    ----    ----    MCC Commission MCC Request & Response Modle   ----    ----    ----    ----*/

    public class ReqMCCCommissionMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? mppi_id { get; set; }
        public string? applicable_date { get; set; }
        public string? version_no { get; set; }
        public string? chart_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }
        public string? search_text { get; set; }

        public string? taluka_name { get; set; }
        public string? village_name { get; set; }

        public string? district_name { get; set; }
        public string? mcctype_name { get; set; }

    }

    public class ResMCCCommissionMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }
        public string? mppi_id { get; set; }
        public string? applicable_date { get; set; }
        public string? version_no { get; set; }
        public string? chart_id { get; set; }
        public string? mcc_id { get; set; }
        public string? set_date { get; set; }
        public string? mcc_code { get; set; }
        public string? mcc_name { get; set; }
        public string? taluka_name { get; set; }
        public string? village_name { get; set; }
        public string? mppi_name { get; set; }

        public string? is_mcc { get; set; }
        public string? district_name { get; set; }
        public string? mcctype_name { get; set; }
    }

    /*----  ----    ----    ----    Freight Request & Response Modle   ----    ----    ----    ----*/

    public class ReqFreight
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_locked { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? freight_id { get; set; }
        public string? vehicle_id { get; set; }
        public string? freightratetype_id { get; set; }
        public string? amount { get; set; }
        public string? applicable_date { get; set; }
        public string? baserate { get; set; }
        public string? version_no { get; set; }

    }

    public class ResFreight
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }
        public string? freight_id { get; set; }
        public string? vehicle_id { get; set; }
        public string? vehicle_no { get; set; }
        public string? freightratetype_id { get; set; }
        public string? freightratetype_name { get; set; }
        public string? amount { get; set; }
        public string? applicable_date { get; set; }
        public string? baserate { get; set; }
        public string? version_no { get; set; }

    }

    /*----  ----    ----    ----    Fat SNF Ratio Request & Response Modle   ----    ----    ----    ----*/

    public class ReqFatSNFRatio
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }
        public string? fat { get; set; }
        public string? snf { get; set; }
        public string? ratio_date { get; set; }
        public string? ratio_id { get; set; }
        public string? overhead { get; set; }
    }

    public class ResFatSNFRatio
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public int is_locked { get; set; }
        public string? fat { get; set; }
        public string? snf { get; set; }
        public string? ratio_date { get; set; }
        public string? ratio_id { get; set; }
        public string? overhead { get; set; }
    }
}
