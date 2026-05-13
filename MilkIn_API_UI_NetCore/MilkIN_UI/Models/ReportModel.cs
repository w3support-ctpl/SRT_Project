namespace MilkIN_UI.Models
{
    public class ReqMilkCollectionReport
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? api_end_point { get; set; }
        public string? user_name { get; set; }
        public string? Report_Type { get; set; }
        public string? MCCType_Id { get; set; }
        public string? ReportPeriod { get; set; }
        public string? MCCCollectionShift_Id { get; set; }
        public string? MilkType_Id { get; set; }
        public string? MCC_Id { get; set; }
        public string? MCCWorkType_Id { get; set; } 

        public string? MusterStartDate { get; set; }
        public string? MusterEndDate { get; set; } 
    }
}
