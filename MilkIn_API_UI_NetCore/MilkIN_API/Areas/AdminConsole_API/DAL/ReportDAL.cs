using Dapper;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using System.Data;

namespace MilkIN_API.Areas.AdminConsole_API.DAL
{
    public class ReportDAL
    {
        private IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
            .AddJsonFile("appsettings.json")
            .Build();

        private IDbConnection db;

        public ReportDAL(string Destination)
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

        public string RunDBQuery(dynamic InputParam, string StoredProcName)
        {
            DynamicParameters parameters = new DynamicParameters();

            // Convert input string to object
            // dynamic inputParam = JsonConvert.DeserializeObject(InputParam);

            foreach (var parameter in InputParam)
            {
                string paramName = "var_" + parameter.Name;
                string paramValue = parameter.Value;

                parameters.Add(paramName, paramValue);
            }

            // Get response in dynamic object
            dynamic resObj = this.db.Query<dynamic>(StoredProcName, parameters, commandType: CommandType.StoredProcedure,commandTimeout: 0).ToList();

            // Convert response to string and return
            return JsonConvert.SerializeObject(resObj);
        }
    }
}
