namespace MilkOUT_API.Areas.AdminConsole_API.Models
{
	public class ReqLogin
	{
		public string? method_name { get; set; }
		public string? destination_name { get; set; }
		public string? org_id { get; set; }
		public string? login_name { get; set; }
		public string? login_password { get; set; }
		
	}


	public class UserDetails
	{

		public string? org_id { get; set; }
		public string? org_name { get; set; }
		public string? user_id { get; set; }
		public string? role_id { get; set; }
		public string? role_name { get; set; }
		public string? user_name { get; set; }
		public string? mobile_no { get; set; }	
		public string? email_id { get; set; }	
		public int is_active { get; set; }
		public int is_passwordreset { get; set; }
		public string? token { get; set; }
		public List<UserMenu>? usermenu { get; set; }	
	}

	public class UserMenu
	{
		public string? menu_id { get; set; }
		public string? menu_name { get; set; }
		public string? menu_level { get; set; }
		public string? parent_menu_id { get; set; }
		public double display_order_number { get; set; }
		public string? menu_link { get; set; }
		public string? menu_icon_name { get; set; }
		public string? menu_tooltip { get; set; }
		public int display_flag { get; set; }
		public int add_flag { get; set; }
		public int modify_flag { get; set; }
		public int delete_flag { get; set; }
	}
}
