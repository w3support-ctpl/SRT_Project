using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;


namespace MilkIN_API.Areas.AdminConsole_API.DAL
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

			List<MasterDetails> res_Obj = this.db.Query<MasterDetails>("USP_AdminMaster", parameters, commandType: CommandType.StoredProcedure).ToList();

			return res_Obj;
		}

        public List<MasterDetails> GetMastersData(ReqMasterData masterData)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = masterData.method_name,
                var_Org_Id = masterData.org_id,
                var_Param1 = masterData.mcctype_id,
                var_Param2 = masterData.mccworktype_id,
                var_User_Id = masterData.user_id
            });

            List<MasterDetails> res_Obj = this.db.Query<MasterDetails>("USP_AdminMasters", parameters, commandType: CommandType.StoredProcedure).ToList();

            return res_Obj;
        }

        public List<DashboardDetails> GetAdminDashboard(ReqDashboard dashboardData)
		{
			var parameters = new DynamicParameters(new
			{
				var_Method_Name = dashboardData.method_name,
				var_Org_Id = dashboardData.org_id,
				var_User_Id = dashboardData.user_id,
                var_MCC_Id = dashboardData.mcc_id,
                var_Date = dashboardData.date,
				var_Type = dashboardData.user_type
            });

			List<DashboardDetails> res_Obj = this.db.Query<DashboardDetails>("USP_AdminDashboard", parameters, commandType: CommandType.StoredProcedure).ToList();

			return res_Obj;
		}

		public List<CommonOutput> SaveRate(ReqMasterData rateSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = rateSave.method_name,
                var_Org_Id = rateSave.org_id,
                var_User_Id = rateSave.user_id,
                var_User_Name = rateSave.user_name,
				var_MCC_Id = rateSave.mcc_id,
                var_Date = rateSave.date
            });

            return this.db.Query<CommonOutput>("USP_AdminMilkRate_Checker_Set", parameters, commandType: CommandType.StoredProcedure, commandTimeout: 0).ToList();
        }
	}
}
