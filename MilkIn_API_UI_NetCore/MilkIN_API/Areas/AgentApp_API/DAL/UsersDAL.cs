using Dapper;
using MilkIN_API.Areas.AgentApp_API.Models;
using MySql.Data.MySqlClient;
using System.Data;


namespace MilkIN_API.Areas.AgentApp_API.DAL
{
    public class UsersDAL
    {

        private readonly IConfiguration configuration;

        private IDbConnection db;

        public UsersDAL(string Destination , IConfiguration configuration)
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

   
        public List<ResAgentDetails> SignIn(ReqAgentSignIn SignIn)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = SignIn.method_name,
                var_Org_Id = SignIn.org_id,
                var_Mobile_No = SignIn.mobile_no,
                var_Password = SignIn.password,
                var_Profile_Id = SignIn.profile_id,
                var_Otpvalue = "",
                var_Device_Id = SignIn.device_id,
                var_android_version = SignIn.android_version,
                var_make_model = SignIn.make_model,
                var_app_version = SignIn.app_version


            });

     
            return this.db.Query<ResAgentDetails>("USP_AgentSign_In", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<ResAgentDetails> SignInv2(ReqAgentSignIn SignIn)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = SignIn.method_name,
                var_Org_Id = SignIn.org_id,
                var_Mobile_No = SignIn.mobile_no,
                var_Password = SignIn.password,
                var_Profile_Id = SignIn.profile_id,
                var_Otpvalue = "",
                var_Device_Id = SignIn.device_id,
                var_android_version = SignIn.android_version,
                var_make_model = SignIn.make_model,
                var_app_version = SignIn.app_version


            });


            return this.db.Query<ResAgentDetails>("USP_AgentSign_Inv2", parameters, commandType: CommandType.StoredProcedure).ToList();
        }


        public List<CommonOutput> AgentVerify(ReqAgentVerify AgentVerify)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = AgentVerify.method_name,
                var_Org_Id = AgentVerify.org_id,
                var_Mobile_No = AgentVerify.mobile_no,
                var_Password = AgentVerify.password,
                var_Profile_Id = AgentVerify.profile_id,
                var_Otpvalue = AgentVerify.otp,
                var_Device_Id = AgentVerify.device_id,
                var_android_version = AgentVerify.android_version,
                var_make_model = AgentVerify.make_model,
                var_app_version = AgentVerify.app_version
            });





            return this.db.Query<CommonOutput>("USP_AgentSign_Inv2", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



        public List<CommonOutput> SaveAgentDetails(ReqSaveAgent SaveAgent)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = SaveAgent.method_name,
                var_Org_Id = SaveAgent.org_id,
                var_XMLData = SaveAgent.xmldata,
                var_Profile_Id = SaveAgent.profile_id,
            });


  

            return this.db.Query<CommonOutput>("USP_AgentProfile_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }



        public List <ResAgentInfo> GetAgentProfileInfo(ReqGetAgent GetAgent)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = GetAgent.method_name,
                var_Org_Id = GetAgent.org_id,
                var_Profile_Id = GetAgent.profile_id,
                var_MCC_Id = GetAgent.mcc_id,

            });

            var result = this.db.QueryMultiple("USP_AgentProfile_Get", parameters, commandType: CommandType.StoredProcedure);

            List<ResAgentInfo> res_Obj = new List<ResAgentInfo>();
            res_Obj = result.Read<ResAgentInfo>().ToList();

            if (res_Obj.Count < 3)
            {

                return res_Obj;
            }
            else
            {
                res_Obj[0].Statedata = result.ReadFirst<AGProfileMaster>() == null ? new AGProfileMaster () : result.ReadFirst<AGProfileMaster>();
                res_Obj[0].Districtdata = result.ReadFirst<AGProfileMaster>() == null ? new AGProfileMaster() : result.ReadFirst<AGProfileMaster>(); 
                res_Obj[0].Villagedata = result.ReadFirst<AGProfileMaster>() == null ? new AGProfileMaster() : result.ReadFirst<AGProfileMaster>(); 
                res_Obj[0].Talukadata = result.ReadFirst<AGProfileMaster>() == null ? new AGProfileMaster() : result.ReadFirst<AGProfileMaster>(); 


                return res_Obj;

            }



           



        }


    }

}
