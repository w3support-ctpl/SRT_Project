using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilkOUT_DayEnd_Jobs.Models
{

    public class ReqDealerSalesArea
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? dealer_id { get; set; }
        public string? dealer_code { get; set; }
        public string? dealerdata { get; set; }
    }


    public class ReqDealerCrateDump
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? api_end_point { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? dealer_id { get; set; }
        public string? dealer_code { get; set; }
        public string? dealerdata { get; set; }
        public string? formattedstartdate { get; set; }
        public string? formattedenddate { get; set; }
    }

    public class ReqDealerSalesAreaData
    {
        public string? org_id { get; set; }
        public string? dealer_code { get; set; }
        public string? dealerdata { get; set; }
    }

    public class ReqRetailerOrder

    {
        public string? org_id { get; set; }
        public string? retailerorder_id { get; set; }
    }

}
