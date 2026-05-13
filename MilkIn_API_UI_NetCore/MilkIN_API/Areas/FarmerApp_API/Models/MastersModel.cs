namespace MilkIN_API.Areas.FarmerApp_API.Models
{
    public class ReqFAMasterData
    {
        public string? Method_Name { get; set; }
        public string? Org_Id { get; set; }
        public string? ParentField_Id { get; set; }
        public string? destination_name { get; set; }

    }


    public class MasterDetails
    {
        public string? Item_Id { get; set; }
        public string? Item_Value { get; set; }
    }









}
