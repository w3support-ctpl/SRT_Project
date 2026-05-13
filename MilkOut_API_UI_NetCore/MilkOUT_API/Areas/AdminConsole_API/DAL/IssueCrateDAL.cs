

using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using Microsoft.AspNetCore.Components;
using Newtonsoft.Json;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class IssueCrateDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        string ConnectionName;


        public IssueCrateDAL(string Destination)
        {
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


        public List<CommonOutput> IssueCrate(IssueCrateModel IssueCrateModel)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = IssueCrateModel.org_id,
                var_Dealer_Code = IssueCrateModel.dealer_code,
                var_Dealer_Name = IssueCrateModel.dealer_name,
                var_Dispatch_Date = IssueCrateModel.dispatch_date,
                var_Quantity = IssueCrateModel.quantity,
                var_Material_Code = IssueCrateModel.material_code,
                var_Invoice_Number = IssueCrateModel.invoice_number,
                var_Delivery_Item = IssueCrateModel.delivery_item
            });

            var result = this.db.Query<CommonOutput>("USP_SAdminIssueCrate", parameters, commandType: CommandType.StoredProcedure).ToList();

            return result;
        }

        public List<CommonOutput> SaveIssueCrate(IssueCrateModel IssueCrateModel)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = IssueCrateModel.org_id,
                var_Dealer_Code = IssueCrateModel.dealer_code,
                var_Dealer_Name = IssueCrateModel.dealer_name,
                var_Dispatch_Date = IssueCrateModel.dispatch_date,
                var_Quantity = IssueCrateModel.quantity,
                var_Material_Code = IssueCrateModel.material_code,
                var_Invoice_Number = IssueCrateModel.invoice_number,
                var_Batch = IssueCrateModel.batch
            });

            var result = this.db.Query<CommonOutput>("USP_SAdminIssueCrateBatch", parameters, commandType: CommandType.StoredProcedure).ToList();

            return result;
        }


        public string GetCrateStock(Reqcratestock cratestock)
        {
            var parameters = new DynamicParameters(new
            {

                var_method = cratestock.method,
                var_Dealer_Code = cratestock.dealer_code,
                var_start_date = cratestock.start_date,
                var_end_date = cratestock.end_date,

            });

            dynamic result = this.db.Query<dynamic>("USP_SAdminCrateStock_Sap", parameters, commandType: CommandType.StoredProcedure).ToList();

            return JsonConvert.SerializeObject(result);
        }


        public List<CommonOutput> IssueCrateTime(IssueCrateModel IssueCrateModel)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = IssueCrateModel.org_id,
                var_Dealer_Code = IssueCrateModel.dealer_code,
                var_Dealer_Name = IssueCrateModel.dealer_name,
                var_Dispatch_Date = IssueCrateModel.dispatch_date,
                var_Dispatch_Time = IssueCrateModel.dispatch_time,
                var_Quantity = IssueCrateModel.quantity,
                var_Material_Code = IssueCrateModel.material_code,
                var_Invoice_Number = IssueCrateModel.invoice_number
            });

            var result = this.db.Query<CommonOutput>("USP_SAdminIssueCrate", parameters, commandType: CommandType.StoredProcedure).ToList();

            return result;
        }






    }
}
