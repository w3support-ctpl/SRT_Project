using MilkIN_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using MySqlX.XDevAPI.Common;
using Newtonsoft.Json;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json.Linq;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class MachineDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        private string ConnectionName;

        public MachineDAL(string Destination)
        {
            //string ConnectionName;
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

        /*----  ----    ----    ----    Machine Get & Save   ----    ----    ----    ----*/

        public List<CommonOutput> SaveMachine(ReqMachine machineSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = machineSave.method_name,
                var_Org_Id = machineSave.org_id,
                var_Machine_Type = machineSave.machine_type,
                var_Machine_Value = machineSave.machine_value,
            });

            return this.db.Query<CommonOutput>("USP_AdminMachine_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }

    }
}
