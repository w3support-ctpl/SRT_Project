namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
   
    public class ReqRoute
    {
        // REQUIRED FIELDS IN EVERY MODEL
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }


public string? api_end_point { get; set; }



        public int is_active { get; set; }
        public int is_deleted { get; set; }

        public int search_text { get; set; }
public string?  route_id  { get; set; } 
public string?  route_name  { get; set; } 
public string?  vehicle_no  { get; set; } 
public string?  createdby_id  { get; set; } 
public string?  createdby_name  { get; set; } 
public string?  entry_id  { get; set; } 
public string?  type  { get; set; } 


public string?  date  { get; set; } 

public string?  search_period  { get; set; } 


    }
    public class ResRoute
    {
        public string? method_name { get; set; }
        public string? org_id { get; set; }
        public string? user_id { get; set; }
        public string? destination_name { get; set; }
        public string? user_name { get; set; }
        public string? api_end_point { get; set; }
               public int is_active { get; set; }
        public int is_deleted { get; set; }


public string?  route_id  { get; set; } 
public string?  route_name  { get; set; } 
public string?  vehicle_no  { get; set; } 
public string?  createdby_id  { get; set; } 
public string?  createdby_name  { get; set; } 
public string?  entry_id  { get; set; } 
public string?  type  { get; set; } 

public string?  date  { get; set; } 

public string?  search_period  { get; set; } 

public string?  title  { get; set; } 

public string?  body  { get; set; }
public string?  created_on  { get; set; }

    }
}