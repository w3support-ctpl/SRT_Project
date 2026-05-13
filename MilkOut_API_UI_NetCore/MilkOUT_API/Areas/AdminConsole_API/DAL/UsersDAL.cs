using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using static MilkOUT_API.Areas.AdminConsole_API.Models.UsersModel;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class UsersDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        public UsersDAL(string Destination)
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

        public List<ResFarmer> GetFarmer(UsersModel.ReqFarmerSearch farmerSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerSearch.method_name,
                var_Org_Id = farmerSearch.org_id,
                var_Farmer_Id = farmerSearch.farmer_id,
                var_Farmer_Name = farmerSearch.farmer_name,
                var_Agent_Id = farmerSearch.agent_id
            });

            return this.db.Query<ResFarmer>("USP_AdminFarmer_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveFarmer(UsersModel.ReqFarmerSave farmerSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = farmerSave.method_name,
                var_Org_Id = farmerSave.org_id,
                var_Farmer_Code = farmerSave.farmer_code,
                var_Farmer_Id = farmerSave.farmer_id,
                var_Farmer_Name = farmerSave.farmer_name,
                var_Mobile_No = farmerSave.mobile_no,
                var_Agent_Id = farmerSave.agent_id,
                var_Pan_No = farmerSave.pan_no,
                var_Aadhar_No = farmerSave.aadhar_no,
                var_Cow_Count = farmerSave.cow_count,
                var_Buffalo_Count = farmerSave.buffalo_count,
                var_Calf_Count = farmerSave.calf_count,
                var_Milk_Capacity = farmerSave.milk_capacity,
                var_State_Id = farmerSave.state_id,
                var_District_Id = farmerSave.district_id,
                var_Taluka_Id = farmerSave.taluka_id,
                var_Village_Id = farmerSave.village_id,
                var_Address = farmerSave.address,
                var_Bank_Name = farmerSave.bank_name,
                var_Account_Name = farmerSave.account_name,
                var_Account_No = farmerSave.account_no,
                var_Ifsc_Code = farmerSave.ifsc_code,
                var_Nominee_Name = farmerSave.nominee_name,
                var_Nominee_Relation = farmerSave.nominee_relation,
                var_NomineeMobile_No = farmerSave.nomineemobile_no,
                var_NomineeAadhar_No = farmerSave.nomineeaadhar_no,
                var_Is_Active = farmerSave.is_active,
                var_Is_Deleted = farmerSave.is_deleted
            });

            return this.db.Query<CommonOutput>("USP_AdminFarmer_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<ResAgent> GetAgent(UsersModel.ReqAgentSearch agentSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = agentSearch.method_name,
                var_Org_Id = agentSearch.org_id,
                var_Agent_Id = agentSearch.agent_id,
                var_Agent_Name = agentSearch.agent_name
            });

            return this.db.Query<ResAgent>("USP_AdminAgent_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveAgent(UsersModel.ReqAgentSave agentSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = agentSave.method_name,
                var_Org_Id = agentSave.org_id,
                var_Agent_Code = agentSave.agent_code,
                var_Agent_Id = agentSave.agent_id,
                var_Agent_Name = agentSave.agent_name,
                var_Mobile_No = agentSave.mobile_no,
                var_Joining_Date = agentSave.joining_date,
                var_Pan_No = agentSave.pan_no,
                var_Aadhar_No = agentSave.aadhar_no,
                var_State_Id = agentSave.state_id,
                var_District_Id = agentSave.district_id,
                var_Taluka_Id = agentSave.taluka_id,
                var_Village_Id = agentSave.village_id,
                var_Address = agentSave.address,
                var_Is_Active = agentSave.is_active,
                var_Is_Deleted = agentSave.is_deleted,
                var_OnlineApp_Flag = agentSave.onlineapp_flag
            });

            return this.db.Query<CommonOutput>("USP_AdminAgent_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<ResDriver> GetDriver(UsersModel.ReqDriverSearch driverSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = driverSearch.method_name,
                var_Org_Id = driverSearch.org_id,
                var_Driver_Id = driverSearch.driver_id,
                var_Driver_Name = driverSearch.driver_name,
                var_DriverType_Id = driverSearch.drivertype_id
            });

            return this.db.Query<ResDriver>("USP_AdminDriver_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveDriver(UsersModel.ReqDriverSave driverSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = driverSave.method_name,
                var_Org_Id = driverSave.org_id,
                var_Driver_Code = driverSave.driver_code,
                var_Driver_Id = driverSave.driver_id,
                var_Driver_Name = driverSave.driver_name,
                var_Mobile_No = driverSave.mobile_no,
                var_Joining_Date = driverSave.joining_date,
                var_DriverType_Id = driverSave.drivertype_id,
                var_License_No = driverSave.license_no,
                var_Pan_No = driverSave.pan_no,
                var_Aadhar_No = driverSave.aadhar_no,
                var_Is_Active = driverSave.is_active,
                var_Is_Deleted = driverSave.is_deleted,
                var_OnlineApp_Flag = driverSave.onlineapp_flag
            });

            return this.db.Query<CommonOutput>("USP_AdminDriver_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<ResChemist> GetChemist(UsersModel.ReqChemistSearch chemistSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = chemistSearch.method_name,
                var_Org_Id = chemistSearch.org_id,
                var_Chemist_Id = chemistSearch.chemist_id,
                var_Chemist_Name = chemistSearch.chemist_name
            });

            return this.db.Query<ResChemist>("USP_AdminChemist_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveChemist(UsersModel.ReqChemistSave chemistSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = chemistSave.method_name,
                var_Org_Id = chemistSave.org_id,
                var_Chemist_Code = chemistSave.chemist_code,
                var_Chemist_Id = chemistSave.chemist_id,
                var_Chemist_Name = chemistSave.chemist_name,
                var_Mobile_No = chemistSave.mobile_no,
                var_Joining_Date = chemistSave.joining_date,
                var_Pan_No = chemistSave.pan_no,
                var_Aadhar_No = chemistSave.aadhar_no,
                var_Is_Active = chemistSave.is_active,
                var_Is_Deleted = chemistSave.is_deleted
            });

            return this.db.Query<CommonOutput>("USP_AdminChemist_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<ResUser> GetOfficeUser(UsersModel.ReqUserSearch userSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = userSearch.method_name,
                var_Org_Id = userSearch.org_id,
                var_User_Id = userSearch.officeuser_id,
                var_User_Name = userSearch.officeuser_name,
                var_Role_Id = userSearch.role_id
            });

            return this.db.Query<ResUser>("USP_AdminUser_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<CommonOutput> SaveOfficeUser(UsersModel.ReqUserSave userSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = userSave.method_name,
                var_Org_Id = userSave.org_id,
                var_OfficeUser_Id = userSave.officeuser_id,
                var_OfficeUser_Name = userSave.officeuser_name,
                var_User_Role = userSave.user_role,
                var_Mobile_No = userSave.mobile_no,
                var_Joining_Date = userSave.joining_date,
                var_Email_Id = userSave.email_id,
                var_Pan_No = userSave.pan_no,
                var_Aadhar_No = userSave.aadhar_no,
                var_Is_Active = userSave.is_active,
                var_Is_Deleted = userSave.is_deleted
            });

            return this.db.Query<CommonOutput>("USP_AdminOfficeUser_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }
    }
}
