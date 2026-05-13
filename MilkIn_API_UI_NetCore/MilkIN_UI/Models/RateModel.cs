namespace MilkIN_UI.Models
{
    /*----  ----    ----    ----    Slab Request Modle   ----    ----    ----    ----*/

    public class ReqSlab
    {
        public string? slab_id { get; set; }
        public string? slab_name { get; set; }
        public string? slab_min { get; set; }
        public string? slab_max { get; set; }
        public string? slab_type { get; set; }

        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? is_active { get; set; }
        public string? is_deleted { get; set; }
        public string? api_end_point { get; set; }
    }

    /*----  ----    ----    ----    Diesel Request Modle   ----    ----    ----    ----*/

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
        public string? api_end_point { get; set; }

    }

    /*----  ----    ----    ----    Milk Rate Request Modle   ----    ----    ----    ----*/

    public class ReqMilkRate
    {
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

        public string? is_backdate { get; set; }
        public string? back_date { get; set; }


    }

    /*----  ----    ----    ----    Milk Rate Item Request Modle   ----    ----    ----    ----*/

    public class ReqMilkRateItem
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
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

    }

    /*----  ----    ----    ----    Milk Rate MCC Request Modle   ----    ----    ----    ----*/

    public class ReqMilkRateMCC
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? user_name { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public int is_active { get; set; }
        public int is_deleted { get; set; }
        public string? applicable_date { get; set; }
        public string? milktype_id { get; set; }
        public string? collectionshift_id { get; set; }
        public string? version_no { get; set; }
        public string? chart_id { get; set; }
        public string? mcc_id { get; set; }
        public string? search_text { get; set; }

        public string? is_backdate { get; set; }
        public string? back_date { get; set; }

    }

    /*----  ----    ----    ----    MCC Commission Request Modle   ----    ----    ----    ----*/

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
        public string? collectionshift_id { get; set; }

        public string? mppitype_id { get; set; }

    }

    /*----  ----    ----    ----    MCC Commission Item Request Modle   ----    ----    ----    ----*/

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

        public int is_locked { get; set; }
        public string? maximumquantity { get; set; }
        public string? maximumfat { get; set; }
        public string? maximumsnf { get; set; }

        public string? mppitype_id { get; set; }

        public string? minimumprotein { get; set; }
        public string? maximumprotein { get; set; }

        public string? minimumash { get; set; }
        public string? maximumash { get; set; }


    }

    /*----  ----    ----    ----    MCC Commission MCC Request Modle   ----    ----    ----    ----*/

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
        public int is_locked { get; set; }
        public string? mppi_id { get; set; }
        public string? applicable_date { get; set; }
        public string? version_no { get; set; }
        public string? chart_id { get; set; }
        public string? mcc_id { get; set; }
        public string? mcctype_id { get; set; }
        public string? mccworktype_id { get; set; }
        public string? search_text { get; set; }

        public string? mppitype_id { get; set; }

    }

    /*----  ----    ----    ----    Freight Request Modle   ----    ----    ----    ----*/

    public class ReqFreight
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
        public string? freightratetype_id { get; set; }
        public string? amount { get; set; }
        public string? applicable_date { get; set; }
        public string? baserate { get; set; }
        public string? version_no { get; set; }

    }

    /*----  ----    ----    ----    Fat SNF Ratio Request Modle   ----    ----    ----    ----*/

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

}
