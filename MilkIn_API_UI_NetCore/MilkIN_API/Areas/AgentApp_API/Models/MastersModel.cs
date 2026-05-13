namespace MilkIN_API.Areas.AgentApp_API.Models
{
    public class ReqAGMasterData
    {
        public string? Method_Name { get; set; }
        public string? Org_Id { get; set; }
        public string? ParentField_Id { get; set; }
        public string? destination_name { get; set; }

    }

    public class AGMasterDetails
    {
        public string? Item_Id { get; set; }
        public string? Item_Value { get; set; }
    }

}
