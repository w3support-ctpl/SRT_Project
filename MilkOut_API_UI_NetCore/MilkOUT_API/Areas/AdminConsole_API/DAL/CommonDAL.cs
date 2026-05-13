

using MilkOUT_API.Areas.AdminConsole_API.Models;
using Dapper;
using MySql.Data.MySqlClient;
using System.Data;
using Newtonsoft.Json;

namespace MilkOUT_API.Areas.AdminConsole_API.DAL
{
    public class CommonDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        public CommonDAL(string Destination)
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

        public List<ResGetDealer> GetDealerCode(ReqGetDealer ReqGetDealer)
        {
            
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = ReqGetDealer.org_id,
                var_Dealer_Id = ReqGetDealer.dealer_id
            });


            List<ResGetDealer> res_Obj = this.db.Query<ResGetDealer>("USP_SAdminDealerCode_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            return res_Obj;
        }

        public List<ResGetProduct> GetProductCode(ReqGetProduct ReqGetProduct)
        {
            var parameters = new DynamicParameters(new
            {
                var_Org_Id = ReqGetProduct.org_id,
                var_Product_Id = ReqGetProduct.product_id
            });


            List<ResGetProduct> res_Obj = this.db.Query<ResGetProduct>("USP_SAdminProductCode_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            return res_Obj;
        }



        public List<ResOrgOutPut> GetDestinationName(ReqOrgOutPut ReqOrgOutPut)
        {
            var parameters = new DynamicParameters(new
            {
                var_Method_Name = "Get",
                var_Org_Id = ReqOrgOutPut.org_id,
            });


            List<ResOrgOutPut> res_Obj = this.db.Query<ResOrgOutPut>("USP_AdminOrg_Get", parameters, commandType: CommandType.StoredProcedure).ToList();

            return res_Obj;
        }




        public string RunDBQuery(dynamic InputParam, string StoredProcName)
        {
            DynamicParameters parameters = new DynamicParameters();

            // Convert input string to object
            // dynamic inputParam = JsonConvert.DeserializeObject(InputParam);

            foreach (var parameter in InputParam)
            {
                string paramName = "Var_" + parameter.Name;
                string paramValue = parameter.Value;

                parameters.Add(paramName, paramValue);
            }

            // Get response in dynamic object
            dynamic resObj = this.db.Query<dynamic>(StoredProcName, parameters, commandType: CommandType.StoredProcedure).ToList();

            // Convert response to string and return
            return JsonConvert.SerializeObject(resObj);
        }




        public string GetDealerCode(string StoredProcName)
        {
            DynamicParameters parameters = new DynamicParameters();

            // Convert input string to object
            // dynamic inputParam = JsonConvert.DeserializeObject(InputParam);



            // Get response in dynamic object
            dynamic resObj = this.db.Query<dynamic>(StoredProcName, parameters, commandType: CommandType.StoredProcedure).ToList();

            // Convert response to string and return
            return JsonConvert.SerializeObject(resObj);
        }


        public string GetSalesAreaCode(string StoredProcName)
        {
            DynamicParameters parameters = new DynamicParameters();

            // Convert input string to object
            // dynamic inputParam = JsonConvert.DeserializeObject(InputParam);



            // Get response in dynamic object
            dynamic resObj = this.db.Query<dynamic>(StoredProcName, parameters, commandType: CommandType.StoredProcedure).ToList();

            // Convert response to string and return
            return JsonConvert.SerializeObject(resObj);
        }









    }
}

