namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
    public class CommonOutput
    {
        public int result_id { get; set; }
        public string? result_description { get; set; }
        public string? result_extra_key { get; set; }
    }


    public class ReqGetDealer
    {
        public string? org_id { get; set; }
        public string? dealer_id { get; set; }

    }

    public class ResGetDealer
    {
        public string? dealer_code { get; set; }

    }
    public class ReqGetProduct
    {
        public string? org_id { get; set; }
        public string? product_id { get; set; }

    }

    public class ResGetProduct
    {
        public string? product_code { get; set; }

    }
    public class ReqOrgOutPut
    {
        public string? org_id { get; set; }
        public string? method_name { get; set; }
        public string? destination_name { get; set; }

        public string? dealer_code { get; set; }

    }
    public class ResOrgOutPut
    {
        public string? ConnectionName { get; set; }
    }

    public class OrgOutPut
    {
        public string? ConnectionName { get; set; }
    }

    public class ReqSalesOrgOutPut
    {
        public string? org_id { get; set; }
        public string? method_name { get; set; }
        public string? destination_name { get; set; }

        public string? dealer_code { get; set; }
    }


}
