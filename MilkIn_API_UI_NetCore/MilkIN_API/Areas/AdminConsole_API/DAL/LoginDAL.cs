using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
	public class LoginDAL
	{

		private IConfigurationRoot configuration = new ConfigurationBuilder()
			.SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
			.AddJsonFile("appsettings.json")
			.Build();

		private IDbConnection db;

		public LoginDAL(string Destination)
		{
			string ConnectionName;
			switch (Destination)
			{
				case "MIP":
					ConnectionName = "ConnectionPRD";
					break;
				case "MIU":
					ConnectionName = "ConnectionUAT";
					break;
				default:
					ConnectionName = "ConnectionDEV";
					break;

			}
			db = new MySqlConnection(configuration.GetConnectionString(ConnectionName));
		}



		public List<UserDetails> Login(ReqLogin login)
		{
			var parameters = new DynamicParameters(new
			{
				var_Method_Name = login.method_name,
				var_Org_Id = login.org_id,
				var_Login_Name = login.login_name,
				var_Login_Password = login.login_password,
			});

			List<UserDetails> res_Obj = this.db.Query<UserDetails>("USP_AdminLogin", parameters, commandType: CommandType.StoredProcedure).ToList();

			return res_Obj;
		}

		public List<UserMenu> GetUserMenu(string rold_id, string org_id)
		{
			var parameters = new DynamicParameters(new
			{
				var_Method_Name = "GetAdminMenu",
				var_Org_Id = org_id,
				var_Role_Id = rold_id
			});

			return this.db.Query<UserMenu>("USP_AdminRoleMenu_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
		}

	}
}
