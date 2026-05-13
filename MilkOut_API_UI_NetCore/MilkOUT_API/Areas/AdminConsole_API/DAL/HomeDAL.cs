using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;


namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
	public class HomeDAL
	{
		private IConfigurationRoot configuration = new ConfigurationBuilder()
			.SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
			.AddJsonFile("appsettings.json")
			.Build();

		private IDbConnection db;

		public HomeDAL(string Destination)
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

		public List<MasterDetails> GetMasterData(ReqMasterData masterData)
		{
			var parameters = new DynamicParameters(new
			{
				var_Method_Name = masterData.method_name,
				var_Org_Id = masterData.org_id,
				var_ParentField_Id = masterData.parentfield_id,
				var_User_Id = masterData.user_id
			});

			List<MasterDetails> res_Obj = this.db.Query<MasterDetails>("USP_SAdminMaster", parameters, commandType: CommandType.StoredProcedure).ToList();

			return res_Obj;
		}

		public List<MasterDetails> GetMastersData(ReqMasterData masterData)
		{
			
			var parameters = new DynamicParameters(new
			{
				var_Method_Name = masterData.method_name,
				var_Org_Id = masterData.org_id,
				var_Param1 = masterData.param1,
				var_Param2 = masterData.param2,
				var_User_Id = masterData.user_id
			});

			List<MasterDetails> res_Obj = this.db.Query<MasterDetails>("USP_AdminMasters", parameters, commandType: CommandType.StoredProcedure).ToList();

			return res_Obj;
		}
	}
}
