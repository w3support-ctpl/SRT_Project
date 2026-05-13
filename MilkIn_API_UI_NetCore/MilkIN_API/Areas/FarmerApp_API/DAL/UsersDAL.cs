using Dapper;
using MilkIN_API.Areas.FarmerApp_API.Models;
using MySql.Data.MySqlClient;
using System.Data;

namespace MilkIN_API.Areas.FarmerApp_API.DAL
{
    public class UsersDAL
    {


        private readonly IConfiguration configuration;

        private IDbConnection db;

        public UsersDAL(string Destination, IConfiguration configuration)
        {
            this.configuration = configuration;
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

        public List<CommonOutput> SignUp(ReqSignUp SignUp)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = SignUp.method_name,
                var_Org_Id = SignUp.org_id,
                var_Mobile_No = SignUp.mobile_no,
                var_Otpvalue = SignUp.otp,
                var_Password = SignUp.password,
                var_Profile_Id = SignUp.profile_id,
                Var_Farmer_Name  = SignUp.farmer_name,

            });

            return this.db.Query<CommonOutput>("USP_FarmerSign_Up", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

        public List<ResFarmerDetails> SignIn(ReqSignIn SignIn)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = SignIn.method_name,
                var_Org_Id = SignIn.org_id,
                var_Mobile_No = SignIn.mobile_no,
                var_Password = SignIn.password,
                var_Profile_Id = SignIn.profile_id,
                Var_Device_id = SignIn.device_id,
                var_android_version = SignIn.android_version,
                var_make_model = SignIn.make_model,
                var_app_version = SignIn.app_version
            });

            return this.db.Query<ResFarmerDetails>("USP_FarmerSign_In", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<CommonOutput> SaveFarmerDetails(ReqSaveFarmer SaveFarmer)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = SaveFarmer.method_name,
                var_Org_Id = SaveFarmer.org_id,
                var_XMLData = SaveFarmer.xmldata,
                var_Profile_Id = SaveFarmer.profile_id  ,
                Var_Mobile_Number = SaveFarmer.Mobile_Number,

            });

            return this.db.Query<CommonOutput>("USP_FarmerProfile_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
    }


        public List<ResFarmerInfo> GetFarmerProfileInfo(ReqGetFarmer GetFarmer)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = GetFarmer.method_name,
                var_Org_Id = GetFarmer.org_id,
                var_Profile_Id = GetFarmer.profile_id,
            });

            var result = this.db.QueryMultiple("USP_FarmerProfile_Get", parameters, commandType: CommandType.StoredProcedure);

            List<ResFarmerInfo> res_Obj = new List<ResFarmerInfo>();
            res_Obj = result.Read<ResFarmerInfo>().ToList();

                if (res_Obj.Count > 0)
                {

                res_Obj[0].Statedata = result.ReadFirstOrDefault<FAProfileMaster>();
                res_Obj[0].Districtdata = result.ReadFirstOrDefault<FAProfileMaster>();
                res_Obj[0].Villagedata = result.ReadFirstOrDefault<FAProfileMaster>();
                res_Obj[0].Talukadata = result.ReadFirstOrDefault<FAProfileMaster>();
                res_Obj[0].Bankdata = result.ReadFirstOrDefault<FAProfileMaster>();
                res_Obj[0].Branchdata = result.ReadFirstOrDefault<FAProfileMaster>();
                return res_Obj;
                }
                else
                {

                    return res_Obj;
                }

        }



    }
}
