using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using System.Data;
using Dapper;
using System.Text.Json;
using Newtonsoft.Json.Linq;
using MilkIN_API.Areas.AdminConsole_API.DAL;

public class CommonSAPDAL
{

    private readonly IConfiguration configuration;

    private IDbConnection db;


    public CommonSAPDAL(string Destination, IConfiguration configuration)
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
    public int SAPApiLog(
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

            dynamic resObj = this.db.Query<dynamic>("USP_AdminSAPApiLog_Set", parameters, commandType: CommandType.StoredProcedure).ToList();



            return 1;

        }
        catch (Exception e)
        {
            var ErrMsg = e.Message;


            return 1;
        }

    }

}

