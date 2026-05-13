namespace MilkOUT_FleetX.Models
{

    public class FleetXModel
    {
        public string? Org_Id { get; set; }
        public string? User_Id { get; set; }
        public string? Device_Id { get; set; }

        public string? Vehicle_No { get; set; }


                public string? ShopLatitude { get; set; }

        public string? ShopLongitude { get; set; }

        public string? User_Name { get; set; }

        public string? Entry_Id { get; set; }
        public string? Route_Id { get; set; }

    }

     public class CommonOutput
    {
        public int result_id { get; set; }
        public string? result_description { get; set; }
        public string? result_extra_key { get; set; }
    }

}
