using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using System.Xml;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
	public class LocationDAL
	{
		private IConfigurationRoot configuration = new ConfigurationBuilder()
			.SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
			.AddJsonFile("appsettings.json")
			.Build();

		private IDbConnection db;

		public LocationDAL(string Destination)
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

        /*----  ----    ----    ----    State Get   ----    ----    ----    ----*/

        public List<ResState> GetState(ReqState stateSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = stateSearch.method_name,
                var_Org_Id = stateSearch.org_id,
                var_State_Id = stateSearch.state_id,
                var_State_Name = stateSearch.state_name,
                var_User_id = stateSearch.user_id,
            });

            return this.db.Query<ResState>("USP_AdminState_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    District Get & Save   ----    ----    ----    ----*/

        public List<ResDistrict> GetDistrict(ReqDistrict districtSearch)
		{
			var parameters = new DynamicParameters(new
			{
				var_Method_Name = districtSearch.method_name,
				var_Org_Id = districtSearch.org_id,
				var_State_Id = districtSearch.state_id,
				var_District_Id = districtSearch.district_id,
				var_District_Name = districtSearch.district_name,
                var_User_id = districtSearch.user_id,
			});

			return this.db.Query<ResDistrict>("USP_AdminDistrict_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
		}

		public List<CommonOutput> SaveDistrict(ReqDistrict districtSave)
		{
			var parameters = new DynamicParameters(new
			{
				var_Method_Name = districtSave.method_name,
				var_Org_Id = districtSave.org_id,
				var_State_Id = districtSave.state_id,
				var_District_Id = districtSave.district_id,
				var_District_Name = districtSave.district_name,
				var_District_Code = districtSave.district_code,
				var_User_Id = districtSave.user_id,
                var_User_Name = districtSave.user_name,
                var_Destination_Name = districtSave.destination_name,
                var_Is_Active = districtSave.is_active,
                var_Is_Deleted = districtSave.is_deleted,
			});

			return this.db.Query<CommonOutput>("USP_AdminDistrict_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
		}

        /*----  ----    ----    ----    Taluka Get & Save   ----    ----    ----    ----*/

        public List<ResTaluka> GetTaluka(ReqTaluka talukaSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = talukaSearch.method_name,
                var_Org_Id = talukaSearch.org_id,
                var_State_Id = talukaSearch.state_id,
                var_District_Id = talukaSearch.district_id,
                var_Taluka_Id = talukaSearch.taluka_id,
                var_Taluka_Name = talukaSearch.taluka_name,
                var_User_Id = talukaSearch.user_id,
            });

            return this.db.Query<ResTaluka>("USP_AdminTaluka_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveTaluka(ReqTaluka talukaSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = talukaSave.method_name,
                var_Org_Id = talukaSave.org_id,
                var_State_Id = talukaSave.state_id,
                var_District_Id = talukaSave.district_id,
                var_Taluka_Id = talukaSave.taluka_id,
                var_Taluka_Name = talukaSave.taluka_name,
                var_Taluka_Code = talukaSave.taluka_code,
                var_User_Id = talukaSave.user_id,
                var_User_Name = talukaSave.user_name,
                var_Destination_Name = talukaSave.destination_name,
                var_Is_Active = talukaSave.is_active,
                var_Is_Deleted = talukaSave.is_deleted,
            });

            return this.db.Query<CommonOutput>("USP_AdminTaluka_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        /*----  ----    ----    ----    Village Get & Save   ----    ----    ----    ----*/

        public List<ResVillage> GetVillage(ReqVillage villageSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = villageSearch.method_name,
                var_Org_Id = villageSearch.org_id,
                var_State_Id = villageSearch.state_id,
                var_District_Id = villageSearch.district_id,
                var_Taluka_Id = villageSearch.taluka_id,
                var_Village_Id = villageSearch.village_id,
                //var_Village_Name = villageSearch.village_name,
                var_User_Id = villageSearch.user_id,
            });

            return this.db.Query<ResVillage>("USP_AdminVillage_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveVillage(ReqVillage villageSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = villageSave.method_name,
                var_Org_Id = villageSave.org_id,
                var_State_Id = villageSave.state_id,
                var_District_Id = villageSave.district_id,
                var_Taluka_Id = villageSave.taluka_id,
                var_Village_Id = villageSave.village_id,
                var_Village_Name = villageSave.village_name,
                var_Pin_Code = villageSave.pin_code,
                var_User_Id = villageSave.user_id,
                var_User_Name = villageSave.user_name,
                var_Destination_Name = villageSave.destination_name,
                var_Is_Active = villageSave.is_active,
                var_Is_Deleted = villageSave.is_deleted,
            });

            return this.db.Query<CommonOutput>("USP_AdminVillage_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
    }
}
