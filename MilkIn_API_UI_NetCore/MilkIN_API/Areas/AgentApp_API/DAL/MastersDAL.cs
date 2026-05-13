using Dapper;
using MilkIN_API.Areas.AgentApp_API.Models;
using MySql.Data.MySqlClient;
using System.Data;

namespace MilkIN_API.Areas.AgentApp_API.DAL
{
    public class MastersDAL
    {
        private readonly IConfiguration configuration;

        private IDbConnection db;

        public MastersDAL(string Destination, IConfiguration configuration)
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


        public List<AGMasterDetails> GetMastersData(ReqAGMasterData masterData)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = masterData.Method_Name,
                var_Org_Id = masterData.Org_Id,
                var_ParentField_Id = masterData.ParentField_Id
            });

            return this.db.Query<AGMasterDetails>("USP_CommonMaster", parameters, commandType: CommandType.StoredProcedure).ToList();
        }





    }
}
