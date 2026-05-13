using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using MilkIN_API.Areas.AdminConsole_API.SAP;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Routing;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class TransporterDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;


        public TransporterDAL(string Destination)
        {
            switch (Destination)
            {
                case "PRD":
                    ConnectionName = "ConnectionPRD";
                    break;
                case "UAT":
                    ConnectionName = "ConnectionUAT";
                    break;
                default:
                    ConnectionName = "ConnectionDEV";
                    break;

            }
            db = new MySqlConnection(configuration.GetConnectionString(ConnectionName));
        }







        public List<ResRoute> GetRoute(ReqRoute routeSearch)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = routeSearch.org_id,
                var_Method_Name = routeSearch.method_name,
                var_User_Id = routeSearch.user_id,
                var_Route_Id = routeSearch.route_id,
                var_Route_Name = routeSearch.route_name,
                 var_Date = routeSearch.search_period,

            });

            var result = this.db.Query<ResRoute>("USP_SAdminfleetx_Get", parameters, commandType: CommandType.StoredProcedure).ToList();
            return result;
        }

        public List<CommonOutput> SaveRoute(ReqRoute routeSave)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = routeSave.org_id,
                var_Method_Name = routeSave.method_name,
                var_Route_Id = routeSave.route_id,
                var_Route_Name = routeSave.route_name,
                var_Vehicle_No = routeSave.vehicle_no,
                var_CreatedBy_Id = routeSave.user_id,
                var_CreatedBy_Name = routeSave.user_name,
                var_Type = routeSave.type,
                var_User_Id = routeSave.createdby_id,
                var_Is_Active = routeSave.is_active,
                var_Is_Deleted = routeSave.is_deleted,
                var_Entry_Id = routeSave.entry_id,
                var_Title = "",
                var_Body = "",
            });
            return this.db.Query<CommonOutput>("USP_SAdminfleetx_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
        }








    }
}
