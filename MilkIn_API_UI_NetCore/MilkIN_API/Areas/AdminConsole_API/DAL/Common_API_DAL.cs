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
    public class Common_API_DAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;
        private string ConnectionName;

        public Common_API_DAL(string Destination)
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


        public int ApiLog(
        string method_name,
        string org_id,
        string transaction_name,
        object request_url,
        object request_body,
        string response_code,
        object response_body

        )
        {

            try
            {

                var parameters = new
                {
                    var_Method_Name = method_name,
                    var_Org_Id = org_id,
                    var_Transaction_Name = transaction_name,
                    var_Request_URL = request_url,
                    var_Request_Body = request_body,
                    var_Response_Code = response_code,
                    var_Response_Body = response_body,
                };

                string ReqParams = JsonConvert.SerializeObject(parameters);

                dynamic inputParam = JsonConvert.DeserializeObject(ReqParams.ToString());


                string destination_name = "";
                //return new CommonDAL(destination_name, configuration).RunDBQuery(inputParam, "USP_AdminSAPApiLog_Set");

                dynamic resObj = this.db.Query<dynamic>("USP_AdminApiLog_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



                return 1;

            }
            catch (Exception e)
            {
                var ErrMsg = e.Message;


                return 1;
            }

        }


    }
}
