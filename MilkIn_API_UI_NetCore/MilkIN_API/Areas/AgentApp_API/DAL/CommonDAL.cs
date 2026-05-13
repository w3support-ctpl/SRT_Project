using Dapper;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using System.Data;

namespace MilkIN_API.Areas.AgentApp_API.DAL
{
    public class CommonDAL
    {
        private readonly IConfiguration configuration;

        private IDbConnection db;
        private dynamic destination_name;

        public CommonDAL(string Destination, IConfiguration configuration)
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

        public CommonDAL(dynamic destination_name)
        {
            this.destination_name = destination_name;
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


        public int ApiLogs(
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

        public class Common____Output
        {
            public int result_id { get; set; }
            public string? result_description { get; set; }
            public string? result_extra_key { get; set; }
        }






    }


}
